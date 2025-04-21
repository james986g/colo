#!/bin/bash

# 脚本功能：在 CentOS 7、Ubuntu 和 Debian 上安装、配置或卸载 Cloudflare Tunnel (cloudflared)
# 优化：模块化函数、性能提升、健壮性改进、用户体验优化

# 检查是否以 root 或 sudo 权限运行
if [ "$EUID" -ne 0 ]; then
    echo "请以 root 或 sudo 权限运行此脚本"
    exit 1
fi

# 定义颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检测操作系统
OS=""
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION_ID=$VERSION_ID
else
    echo -e "${RED}无法检测操作系统${NC}"
    exit 1
fi
echo -e "${GREEN}检测到的操作系统：$OS $VERSION_ID${NC}"

# 检查依赖工具
check_dependencies() {
    for cmd in wget awk ss; do
        if ! command -v "$cmd" &>/dev/null; then
            echo -e "${RED}缺少依赖工具 $cmd，正在安装...${NC}"
            case $OS in
                "centos") yum install -y "$cmd" ;;
                "ubuntu"|"debian") apt-get update -y && apt-get install -y "$cmd" ;;
            esac || {
                echo -e "${RED}安装 $cmd 失败，请手动安装${NC}"
                exit 1
            }
        fi
    done
}

# 检查现有 cloudflared 资源的函数
check_existing_cloudflared() {
    echo -e "${GREEN}检测系统中现有的 cloudflared 资源...${NC}"
    CLOUDFLARED_EXISTS=0
    CLOUDFLARED_VERSION=""

    if [ -f /usr/local/bin/cloudflared ] && [ -x /usr/local/bin/cloudflared ]; then
        CLOUDFLARED_VERSION=$(/usr/local/bin/cloudflared --version 2>/dev/null)
        if [ $? -eq 0 ]; then
            echo "找到 cloudflared 二进制文件：/usr/local/bin/cloudflared，版本：$CLOUDFLARED_VERSION"
            CLOUDFLARED_EXISTS=1
        else
            echo "找到 cloudflared 二进制文件，但无法获取版本信息"
        fi
    else
        echo "未找到可用的 cloudflared 二进制文件"
    fi

    [ -d /root/.cloudflared ] && echo "找到 cloudflared 配置文件目录：/root/.cloudflared"
    systemctl is-active cloudflared &>/dev/null && echo "找到运行中的 cloudflared 服务"

    return $CLOUDFLARED_EXISTS
}

# 下载 cloudflared 的辅助函数
download_cloudflared() {
    local url=$1
    local retries=3
    while [ "$retries" -gt 0 ]; do
        wget -q "$url" -O /usr/local/bin/cloudflared && break
        ((retries--))
        echo -e "${YELLOW}下载失败，剩余 $retries 次重试...${NC}"
        sleep 5
    done
    if [ "$retries" -eq 0 ]; then
        echo -e "${RED}下载 cloudflared 失败，请检查网络！${NC}"
        exit 1
    fi
}

# 安装 cloudflared 的函数
install_cloudflared() {
    check_existing_cloudflared
    if [ $? -eq 1 ]; then
        echo -e "${GREEN}系统中已存在可用的 cloudflared，继续配置...${NC}"
        return
    fi

    echo -e "${GREEN}未检测到可用 cloudflared，执行安装...${NC}"
    export PATH=$PATH:/usr/local/bin
    ARCH=$(uname -m)
    case $OS in
        "centos")
            echo -e "${GREEN}安装 Cloudflared for CentOS...${NC}"
            CF_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$([ "$ARCH" = "x86_64" ] && echo "amd64" || echo "arm64")"
            download_cloudflared "$CF_URL"
            ;;
        "ubuntu"|"debian")
            echo -e "${GREEN}安装 Cloudflared for $OS...${NC}"
            CF_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$([ "$ARCH" = "x86_64" ] && echo "amd64.deb" || echo "arm64.deb")"
            download_cloudflared "$CF_URL" && dpkg -i /usr/local/bin/cloudflared || apt-get install -f -y
            rm -f /usr/local/bin/cloudflared.deb
            ;;
        *)
            echo -e "${RED}不支持的操作系统：$OS${NC}"
            exit 1
            ;;
    esac

    chmod +x /usr/local/bin/cloudflared
    /usr/local/bin/cloudflared --version &>/dev/null || {
        echo -e "${RED}Cloudflared 安装失败${NC}"
        exit 1
    }
    echo -e "${GREEN}Cloudflared 安装成功，版本：$(/usr/local/bin/cloudflared --version)${NC}"
}

# Cloudflare 登录
login_cloudflare() {
    export PATH=$PATH:/usr/local/bin
    if [ ! -f /root/.cloudflared/cert.pem ]; then
        echo -e "${GREEN}正在登录 Cloudflare...${NC}"
        cloudflared login || {
            echo -e "${RED}登录失败，请确保正确完成浏览器认证${NC}"
            exit 1
        }
    else
        echo -e "${GREEN}已检测到登录凭证，跳过登录步骤${NC}"
    fi
}

# 获取域名和服务地址
get_domain_and_service() {
    while true; do
        read -p "请输入要使用的域名（例如 tunnel.example.com，不含端口）： " TUNNEL_DOMAIN
        if echo "$TUNNEL_DOMAIN" | grep -q ":"; then
            echo -e "${RED}错误：域名不能包含端口号，请重新输入${NC}"
        elif [[ ! "$TUNNEL_DOMAIN" =~ ^[a-zA-Z0-9.-]+$ ]]; then
            echo -e "${RED}错误：域名格式无效，请重新输入${NC}"
        else
            break
        fi
    done

    read -p "请输入 VPS 本地服务的地址和端口（默认 http://localhost:8080）： " LOCAL_SERVICE
    [ -z "$LOCAL_SERVICE" ] && LOCAL_SERVICE="http://localhost:8080"
    if ! echo "$LOCAL_SERVICE" | grep -q "^http://\|^https://"; then
        LOCAL_SERVICE="http://$LOCAL_SERVICE"
        echo -e "${YELLOW}未指定协议，已自动添加 http:// 前缀：$LOCAL_SERVICE${NC}"
    fi

    LOCAL_PORT=$(echo "$LOCAL_SERVICE" | grep -oP '(?<=:)\d+')
    if ! ss -tuln | grep -q ":${LOCAL_PORT} "; then
        echo -e "${RED}警告：本地服务 $LOCAL_SERVICE 未运行${NC}"
        read -p "是否继续？(y/n): " CONTINUE
        [ "$CONTINUE" != "y" ] && [ "$CONTINUE" != "Y" ] && exit 1
    fi
}

# 配置持久化 Cloudflare Tunnel
configure_tunnel() {
    login_cloudflare
    get_domain_and_service

    if cloudflared tunnel list | grep -qv 'No tunnels'; then
        echo -e "${GREEN}检测到现有 Tunnel，请选择：${NC}"
        echo "1) 使用现有 Tunnel"
        echo "2) 创建新 Tunnel"
        read -p "请输入选项 (1 或 2): " TUNNEL_CHOICE
        if [ "$TUNNEL_CHOICE" = "1" ]; then
            cloudflared tunnel list
            read -p "请输入要使用的 Tunnel ID（UUID）： " TUNNEL_ID
            CREDENTIALS_FILE="/root/.cloudflared/${TUNNEL_ID}.json"
            [ ! -f "$CREDENTIALS_FILE" ] && {
                echo -e "${RED}错误：凭证文件 $CREDENTIALS_FILE 不存在${NC}"
                exit 1
            }
            TUNNEL_NAME=$(cloudflared tunnel info "$TUNNEL_ID" | grep "Name" | awk '{print $2}')
        else
            TUNNEL_NAME="my-tunnel-$(date +%s)"
            echo -e "${GREEN}创建新 Tunnel：$TUNNEL_NAME${NC}"
            cloudflared tunnel create "$TUNNEL_NAME" || {
                echo -e "${RED}创建 Tunnel 失败，请检查 Cloudflare 账户权限或网络${NC}"
                exit 1
            }
            TUNNEL_ID=$(cloudflared tunnel list | grep "$TUNNEL_NAME" | awk '{print $1}')
            CREDENTIALS_FILE="/root/.cloudflared/${TUNNEL_ID}.json"
        fi
    else
        TUNNEL_NAME="my-tunnel-$(date +%s)"
        echo -e "${GREEN}创建新 Tunnel：$TUNNEL_NAME${NC}"
        cloudflared tunnel create "$TUNNEL_NAME" || {
            echo -e "${RED}创建 Tunnel 失败，请检查 Cloudflare 账户权限或网络${NC}"
            exit 1
        }
        TUNNEL_ID=$(cloudflared tunnel list | grep "$TUNNEL_NAME" | awk '{print $1}')
        CREDENTIALS_FILE="/root/.cloudflared/${TUNNEL_ID}.json"
    fi

    CONFIG_FILE="/root/.cloudflared/config.yml"
    cat > "$CONFIG_FILE" <<EOF
tunnel: $TUNNEL_ID
credentials-file: $CREDENTIALS_FILE
ingress:
  - hostname: $TUNNEL_DOMAIN
    service: $LOCAL_SERVICE
  - service: http_status:404
EOF
    echo -e "${GREEN}配置文件已生成：$CONFIG_FILE${NC}"
    cloudflared tunnel route dns "$TUNNEL_ID" "$TUNNEL_DOMAIN" || {
        echo -e "${RED}DNS 路由添加失败，请检查域名权限${NC}"
        exit 1
    }

    [ -f /var/log/cloudflared.log ] && mv /var/log/cloudflared.log "/var/log/cloudflared.log.$(date +%s).bak"
    systemctl stop cloudflared 2>/dev/null
    pkill -f "cloudflared.*tunnel.*run.*$TUNNEL_ID" 2>/dev/null

    echo -e "${GREEN}启动 Tunnel（隧道 ID: $TUNNEL_ID）...${NC}"
    cloudflared --config "$CONFIG_FILE" --logfile /var/log/cloudflared.log tunnel run "$TUNNEL_ID" &
    TUNNEL_PID=$!
    for i in {10..1}; do
        echo -e "${YELLOW}等待 Tunnel 启动 ($i 秒剩余)...${NC}"
        sleep 1
    done

    if ps -p "$TUNNEL_PID" >/dev/null; then
        echo -e "${GREEN}Tunnel 已启动 (PID: $TUNNEL_PID)${NC}"
        [ -f /var/log/cloudflared.log ] && tail -n 10 /var/log/cloudflared.log
    else
        echo -e "${RED}Tunnel 启动失败，请检查以下日志${NC}"
        [ -f /var/log/cloudflared.log ] && tail -n 20 /var/log/cloudflared.log || echo -e "${RED}日志文件未生成${NC}"
        exit 1
    fi

    read -p "是否将 Tunnel 安装为系统服务？(y/n): " INSTALL_SERVICE
    if [ "$INSTALL_SERVICE" = "y" ] || [ "$INSTALL_SERVICE" = "Y" ]; then
        cloudflared --config "$CONFIG_FILE" service install
        systemctl daemon-reload
        systemctl enable cloudflared
        systemctl start cloudflared
        systemctl is-active cloudflared &>/dev/null && echo -e "${GREEN}cloudflared 服务已启动${NC}" || {
            echo -e "${RED}服务启动失败${NC}"
            systemctl status cloudflared
            exit 1
        }
    fi
}

# 设置临时 Argo Tunnel 服务
setup_argo_service() {
    install_cloudflared

    # 输入本地服务地址并验证
    read -p "请输入本地服务的地址和端口（默认 http://localhost:8080）： " LOCAL_SERVICE
    [ -z "$LOCAL_SERVICE" ] && LOCAL_SERVICE="http://localhost:8080"
    LOCAL_PORT=$(echo "$LOCAL_SERVICE" | grep -oP '(?<=:)\d+')
    if ! ss -tuln | grep -q ":${LOCAL_PORT} "; then
        echo -e "${RED}错误：本地服务 $LOCAL_SERVICE 未运行${NC}"
        echo "请先启动本地服务，例如：'python -m http.server $LOCAL_PORT'"
        exit 1
    fi

    # 检查 metrics 端口
    METRICS_PORT="9999"
    if ss -tuln | grep -q ":${METRICS_PORT} "; then
        read -p "端口 $METRICS_PORT 已被占用，请输入新端口（例如 9998）： " METRICS_PORT
        if ss -tuln | grep -q ":${METRICS_PORT} "; then
            echo -e "${RED}错误：新端口 $METRICS_PORT 仍被占用${NC}"
            exit 1
        fi
    fi

    # 创建服务文件
    echo -e "${GREEN}设置临时 Argo Tunnel 服务...${NC}"
    cat > /etc/systemd/system/argo.service <<EOF
[Unit]
Description=Cloudflare Temporary Argo Tunnel
After=network.target

[Service]
Type=simple
NoNewPrivileges=yes
TimeoutStartSec=0
ExecStart=/usr/local/bin/cloudflared tunnel --edge-ip-version auto --no-autoupdate --metrics 0.0.0.0:${METRICS_PORT} --url $LOCAL_SERVICE --logfile /var/log/cloudflared_argo.log --no-tls-verify
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

    # 启动服务
    systemctl daemon-reload
    systemctl enable --now argo

    # 等待服务启动并检查状态
    local retries=3
    for i in {10..1}; do
        echo -e "${YELLOW}等待服务启动 ($i 秒剩余)...${NC}"
        sleep 1
    done
    while [ "$retries" -gt 0 ]; do
        if systemctl is-active argo &>/dev/null; then
            echo -e "${GREEN}临时 Argo Tunnel 启动成功${NC}"
            get_tunnel_domain "$METRICS_PORT"
            return
        else
            echo -e "${RED}临时 Argo Tunnel 启动失败（剩余 $retries 次尝试）${NC}"
            systemctl status argo -n 10
            if [ -f /var/log/cloudflared_argo.log ]; then
                echo -e "${YELLOW}最新日志：${NC}"
                tail -n 20 /var/log/cloudflared_argo.log
                if tail -n 20 /var/log/cloudflared_argo.log | grep -qi "429 Too Many Requests"; then
                    echo -e "${RED}检测到 429 错误（请求过于频繁），请稍后重试或使用命名隧道${NC}"
                elif tail -n 20 /var/log/cloudflared_argo.log | grep -qi "ping_group_range"; then
                    echo -e "${YELLOW}检测到 ICMP 权限问题，正在尝试修复...${NC}"
                    echo "1 65535" > /proc/sys/net/ipv4/ping_group_range  # 调整 ping_group_range
                    systemctl restart argo
                fi
            fi
            ((retries--))
            sleep 5
            systemctl restart argo
        fi
    done

    echo -e "${RED}多次尝试失败，请检查网络、本地服务或使用命名隧道${NC}"
    exit 1
}

# 获取临时隧道域名
get_tunnel_domain() {
    local METRICS_PORT=$1
    local ARGO_DOMAIN=""
    echo -e "${YELLOW}正在获取临时隧道域名...${NC}"
    for i in {10..1}; do
        ARGO_DOMAIN=$(wget -qO- --tries=3 --timeout=5 "http://localhost:${METRICS_PORT}/quicktunnel" 2>/dev/null | awk -F '"' '{print $4}')
        [ -n "$ARGO_DOMAIN" ] && break
        echo -e "${YELLOW}尝试获取域名 ($i 次剩余)${NC}"
        sleep 1
    done

    if [ -n "$ARGO_DOMAIN" ]; then
        echo -e "${GREEN}临时隧道域名: $ARGO_DOMAIN${NC}"
    else
        echo -e "${RED}无法获取临时隧道域名，请检查服务状态${NC}"
        systemctl status argo
        [ -f /var/log/cloudflared_argo.log ] && tail -n 20 /var/log/cloudflared_argo.log
        exit 1
    fi
}

# 更换 Argo 隧道为临时隧道
replace_argo_tunnel() {
    echo -e "${GREEN}正在将现有 Argo 隧道更换为临时隧道...${NC}"

    # 停止并清理现有命名隧道
    systemctl stop cloudflared 2>/dev/null
    pkill -f "cloudflared.*tunnel.*run" 2>/dev/null
    if [ -f /root/.cloudflared/config.yml ]; then
        CONFIG_FILE="/root/.cloudflared/config.yml"
        TUNNEL_ID=$(grep "tunnel:" "$CONFIG_FILE" | awk '{print $2}')
        CREDENTIALS_FILE=$(grep "credentials-file:" "$CONFIG_FILE" | awk '{print $2}')
        echo -e "${GREEN}删除现有命名隧道：$TUNNEL_ID${NC}"
        /usr/local/bin/cloudflared tunnel delete "$TUNNEL_ID" 2>/dev/null
        rm -f "$CREDENTIALS_FILE" "$CONFIG_FILE"
    fi

    # 停止现有的临时隧道服务（如果有）
    systemctl stop argo 2>/dev/null
    systemctl disable argo 2>/dev/null
    rm -f /etc/systemd/system/argo.service
    systemctl daemon-reload

    # 创建新的临时隧道
    setup_argo_service
    echo -e "${GREEN}已成功更换为临时 Argo 隧道${NC}"
}

# 卸载 Cloudflare Tunnel
uninstall_cloudflared() {
    echo -e "${GREEN}开始卸载 Cloudflare Tunnel...${NC}"
    systemctl stop cloudflared argo 2>/dev/null
    systemctl disable cloudflared argo 2>/dev/null
    rm -f /etc/systemd/system/{cloudflared,argo}.service
    systemctl daemon-reload
    pkill -f "cloudflared.*tunnel.*run" 2>/dev/null
    rm -f /usr/local/bin/cloudflared
    rm -rf /root/.cloudflared /etc/cloudflared
    rm -f /tmp/cloudflared.{deb,rpm} 2>/dev/null
    echo -e "${GREEN}Cloudflare Tunnel 已完全卸载${NC}"
}

# 主菜单
show_menu() {
    echo -e "${GREEN}Cloudflare Tunnel 一键脚本${NC}"
    echo "支持的系统：CentOS, Ubuntu, Debian"
    echo "请选择操作：推荐选3"
    echo "1) 安装 Cloudflare Tunnel"
    echo "2) 卸载 Cloudflare Tunnel"
    echo "3) 生成临时 Argo Tunnel"
    echo "4) 更换为临时 Argo 隧道"
    echo "5) 退出"
    echo -e "${YELLOW}快捷键：按 't' 快速生成临时隧道${NC}"
}

# 主流程
check_dependencies
while true; do
    show_menu
    read -p "输入选项 (1-5 或快捷键): " CHOICE
    case $CHOICE in
        1)
            case $OS in
                "centos") yum update -y ;;
                "ubuntu"|"debian") apt-get update -y ;;
            esac
            install_cloudflared
            configure_tunnel
            echo -e "${GREEN}Cloudflare Tunnel 安装和配置完成！${NC}"
            ;;
        2)
            uninstall_cloudflared
            ;;
        3)
            setup_argo_service
            ;;
        4)
            replace_argo_tunnel
            ;;
        5)
            echo -e "${GREEN}退出脚本${NC}"
            exit 0
            ;;
        t)
            setup_argo_service
            ;;
        *)
            echo -e "${RED}无效选项，请输入 1-5 或 't'${NC}"
            ;;
    esac
done
