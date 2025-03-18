#!/bin/bash

# 脚本功能：在 CentOS 7、Ubuntu 和 Debian 上安装、配置或卸载 Cloudflare Tunnel (cloudflared)
# 新增功能：临时 Argo Tunnel、更换隧道、快捷键支持（优化临时隧道实现）

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

# 检查现有 cloudflared 资源的函数
check_existing_cloudflared() {
    echo -e "${GREEN}检测系统中现有的 cloudflared 资源...${NC}"
    CLOUDFLARED_EXISTS=0

    if [ -f /usr/local/bin/cloudflared ] && [ -x /usr/local/bin/cloudflared ] && /usr/local/bin/cloudflared --version &> /dev/null; then
        echo "找到 cloudflared 二进制文件：/usr/local/bin/cloudflared，版本：$(/usr/local/bin/cloudflared --version)"
        CLOUDFLARED_EXISTS=1
    else
        echo "未找到可用的 cloudflared 二进制文件"
    fi

    if [ -d /root/.cloudflared ]; then
        echo "找到 cloudflared 配置文件目录：/root/.cloudflared"
    fi

    if systemctl is-active cloudflared &> /dev/null; then
        echo "找到运行中的 cloudflared 服务"
    fi

    return $CLOUDFLARED_EXISTS
}

# 安装 cloudflared 的函数
install_cloudflared() {
    check_existing_cloudflared
    if [ $? -eq 1 ]; then
        echo -e "${GREEN}系统中已存在可用的 cloudflared，继续配置...${NC}"
    else
        echo -e "${GREEN}未检测到可用 cloudflared，执行安装...${NC}"
        export PATH=$PATH:/usr/local/bin
        case $OS in
            "centos")
                echo -e "${GREEN}安装 Cloudflared for CentOS...${NC}"
                wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /usr/local/bin/cloudflared
                if [ $? -ne 0 ]; then
                    echo -e "${RED}下载 cloudflared 失败，请检查网络！${NC}"
                    exit 1
                fi
                chmod +x /usr/local/bin/cloudflared
                ;;
            "ubuntu")
                echo -e "${GREEN}安装 Cloudflared for Ubuntu...${NC}"
                wget -O /tmp/cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
                dpkg -i /tmp/cloudflared.deb || apt-get install -f -y
                rm -f /tmp/cloudflared.deb
                ;;
            "debian")
                echo -e "${GREEN}安装 Cloudflared for Debian...${NC}"
                wget -O /tmp/cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
                dpkg -i /tmp/cloudflared.deb || apt-get install -f -y
                rm -f /tmp/cloudflared.deb
                ;;
            *)
                echo -e "${RED}不支持的操作系统：$OS${NC}"
                exit 1
                ;;
        esac

        if [ ! -f /usr/local/bin/cloudflared ] || [ ! -x /usr/local/bin/cloudflared ] || ! /usr/local/bin/cloudflared --version &> /dev/null; then
            echo -e "${RED}Cloudflared 安装失败${NC}"
            exit 1
        else
            echo -e "${GREEN}Cloudflared 安装成功，版本：$(/usr/local/bin/cloudflared --version)${NC}"
        fi
    fi
}

# 配置持久化 Cloudflare Tunnel 的函数
configure_tunnel() {
    export PATH=$PATH:/usr/local/bin
    if [ ! -f /root/.cloudflared/cert.pem ]; then
        echo -e "${GREEN}正在登录 Cloudflare...${NC}"
        cloudflared login
        [ ! -f /root/.cloudflared/cert.pem ] && {
            echo -e "${RED}登录失败，请确保正确完成浏览器认证${NC}"
            exit 1
        }
    else
        echo -e "${GREEN}已检测到登录凭证，跳过登录步骤${NC}"
    fi

    # 输入域名并验证不含端口
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

    # 输入本地服务地址
    read -p "请输入 VPS 本地服务的地址和端口（例如 http://localhost:80）： " LOCAL_SERVICE
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

    # 创建或选择 Tunnel
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
            [ ! -f "$CREDENTIALS_FILE" ] && {
                echo -e "${RED}错误：凭证文件 $CREDENTIALS_FILE 未生成${NC}"
                exit 1
            }
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
        [ ! -f "$CREDENTIALS_FILE" ] && {
            echo -e "${RED}错误：凭证文件 $CREDENTIALS_FILE 未生成${NC}"
            exit 1
        }
    fi

    # 生成配置文件
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

    # 清理旧日志和进程
    echo -e "${YELLOW}清理旧日志和进程...${NC}"
    [ -f /var/log/cloudflared.log ] && mv /var/log/cloudflared.log /var/log/cloudflared.log.bak
    systemctl stop cloudflared 2>/dev/null
    pkill -f "cloudflared.*tunnel.*run.*$TUNNEL_ID" 2>/dev/null

    # 启动 Tunnel 并调试
    echo -e "${GREEN}启动 Tunnel（隧道 ID: $TUNNEL_ID）...${NC}"
    cloudflared --config "$CONFIG_FILE" --logfile /var/log/cloudflared.log tunnel run "$TUNNEL_ID" &
    TUNNEL_PID=$!
    sleep 15  # 延长等待时间，确保日志有内容

    # 检查进程状态
    if ps -p "$TUNNEL_PID" > /dev/null; then
        echo -e "${GREEN}Tunnel 已启动 (PID: $TUNNEL_PID)${NC}"
        tail -n 10 /var/log/cloudflared.log  # 显示启动后的最新日志
    else
        echo -e "${RED}Tunnel 启动失败，请检查以下日志${NC}"
        if [ -f /var/log/cloudflared.log ]; then
            tail -n 20 /var/log/cloudflared.log
            tail -n 20 /var/log/cloudflared.log | grep -i "error" && {
                echo -e "${RED}错误详情：$(tail -n 20 /var/log/cloudflared.log | grep -i "error" | tail -n 1)${NC}"
            }
        else
            echo -e "${RED}日志文件未生成，可能是 cloudflared 未正确启动${NC}"
        fi
        exit 1
    fi

    # 安装为系统服务
    read -p "是否将 Tunnel 安装为系统服务？(y/n): " INSTALL_SERVICE
    if [ "$INSTALL_SERVICE" = "y" ] || [ "$INSTALL_SERVICE" = "Y" ]; then
        cloudflared --config "$CONFIG_FILE" service install
        systemctl daemon-reload
        systemctl enable cloudflared
        systemctl start cloudflared
        systemctl is-active cloudflared &> /dev/null && echo -e "${GREEN}cloudflared 服务已启动${NC}" || {
            echo -e "${RED}服务启动失败${NC}"
            systemctl status cloudflared
            exit 1
        }
    fi
}
# 设置临时 Argo Tunnel 的服务
setup_argo_service() {
    install_cloudflared
    read -p "请输入本地服务的地址和端口（例如 http://localhost:8080）： " LOCAL_SERVICE
    LOCAL_PORT=$(echo $LOCAL_SERVICE | grep -oP '(?<=:)\d+')
    if ! netstat -tuln | grep -q ":${LOCAL_PORT} "; then
        echo -e "${RED}警告：本地服务 $LOCAL_SERVICE 未运行${NC}"
        read -p "是否继续？(y/n): " CONTINUE
        [ "$CONTINUE" != "y" ] && [ "$CONTINUE" != "Y" ] && exit 1
    fi

    # 定义变量以适配脚本环境
    WORK_DIR="/usr/local/bin"
    METRICS_PORT="9999" # 默认端口，可根据需要调整

    echo -e "${GREEN}设置临时 Argo Tunnel 服务...${NC}"
    cat > /etc/systemd/system/argo.service << EOF
[Unit]
Description=Cloudflare Temporary Argo Tunnel
After=network.target

[Service]
Type=simple
NoNewPrivileges=yes
TimeoutStartSec=0
ExecStart=$WORK_DIR/cloudflared tunnel --edge-ip-version auto --no-autoupdate --metrics 0.0.0.0:${METRICS_PORT} --url $LOCAL_SERVICE
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable --now argo
    if [ "$(systemctl is-active argo)" = 'active' ]; then
        echo -e "${GREEN}临时 Argo Tunnel 启动成功${NC}"
    else
        echo -e "${RED}临时 Argo Tunnel 启动失败${NC}"
        systemctl status argo
        exit 1
    fi

    get_tunnel_domain
}

# 获取临时隧道域名
get_tunnel_domain() {
    local a=5
    METRICS_PORT="9999" # 与 setup_argo_service 中保持一致
    until [[ -n "$ARGO_DOMAIN" || "$a" = 0 ]]; do
        sleep 2
        ARGO_DOMAIN=$(wget -qO- http://localhost:${METRICS_PORT}/quicktunnel 2>/dev/null | awk -F '"' '{print $4}')
        ((a--)) || true
    done
    if [ -n "$ARGO_DOMAIN" ]; then
        echo -e "${GREEN}临时隧道域名: $ARGO_DOMAIN${NC}"
    else
        echo -e "${RED}无法获取临时隧道域名，请检查服务状态${NC}"
        systemctl status argo
    fi
}

# 更换 Argo 隧道
replace_argo_tunnel() {
    echo -e "${GREEN}更换 Argo 隧道...${NC}"
    systemctl stop cloudflared 2>/dev/null
    pkill -f "cloudflared.*tunnel.*run" 2>/dev/null
    if [ -f /root/.cloudflared/config.yml ]; then
        CONFIG_FILE="/root/.cloudflared/config.yml"
        TUNNEL_ID=$(grep "tunnel:" $CONFIG_FILE | awk '{print $2}')
        CREDENTIALS_FILE=$(grep "credentials-file:" $CONFIG_FILE | awk '{print $2}')
        echo -e "${GREEN}删除现有隧道：$TUNNEL_ID${NC}"
        /usr/local/bin/cloudflared tunnel delete $TUNNEL_ID 2>/dev/null
        rm -f "$CREDENTIALS_FILE" "$CONFIG_FILE"
    fi
    configure_tunnel
    echo -e "${GREEN}Argo 隧道已更换${NC}"
}

# 卸载 Cloudflare Tunnel 的函数
uninstall_cloudflared() {
    echo -e "${GREEN}开始卸载 Cloudflare Tunnel...${NC}"
    systemctl stop cloudflared 2>/dev/null
    systemctl disable cloudflared 2>/dev/null
    systemctl stop argo 2>/dev/null
    systemctl disable argo 2>/dev/null
    rm -f /etc/systemd/system/cloudflared.service /etc/systemd/system/argo.service
    systemctl daemon-reload
    pkill -f "cloudflared.*tunnel.*run" 2>/dev/null
    rm -f /usr/local/bin/cloudflared
    rm -rf /root/.cloudflared /etc/cloudflared
    rm -f /tmp/cloudflared.deb /tmp/cloudflared.rpm 2>/dev/null
    echo -e "${GREEN}Cloudflare Tunnel 已完全卸载${NC}"
}

# 主菜单
show_menu() {
    echo -e "${GREEN}Cloudflare Tunnel 一键脚本${NC}"
    echo "支持的系统：CentOS, Ubuntu, Debian"
    echo "请选择操作："
    echo "1) 安装 Cloudflare Tunnel"
    echo "2) 卸载 Cloudflare Tunnel"
    echo "3) 生成临时 Argo Tunnel"
    echo "4) 更换 Argo 隧道"
    echo "5) 退出"
    echo -e "${YELLOW}快捷键：按 't' 快速生成临时隧道${NC}"
}

# 主流程
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
        t) # 快捷键支持
            setup_argo_service
            ;;
        *)
            echo -e "${RED}无效选项，请输入 1-5 或 't'${NC}"
            ;;
    esac
done
