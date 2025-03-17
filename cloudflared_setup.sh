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
        /usr/local/bin/cloudflared login
        if [ ! -f /root/.cloudflared/cert.pem ]; then
            echo -e "${RED}登录失败，请确保正确完成浏览器认证${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}已检测到登录凭证，跳过登录步骤${NC}"
    fi

    read -p "请输入要使用的域名（例如 tunnel.example.com）： " TUNNEL_DOMAIN
    read -p "请输入 VPS 本地服务的地址和端口（例如 http://localhost:80）： " LOCAL_SERVICE

    LOCAL_PORT=$(echo $LOCAL_SERVICE | grep -oP '(?<=:)\d+')
    if ! netstat -tuln | grep -q ":${LOCAL_PORT} "; then
        echo -e "${RED}警告：本地服务 $LOCAL_SERVICE 未运行${NC}"
        read -p "是否继续？(y/n): " CONTINUE
        [ "$CONTINUE" != "y" ] && [ "$CONTINUE" != "Y" ] && exit 1
    fi

    if [ -n "$(/usr/local/bin/cloudflared tunnel list | grep -v 'No tunnels')" ]; then
        echo -e "${GREEN}检测到现有 Tunnel，请选择：${NC}"
        echo "1) 使用现有 Tunnel"
        echo "2) 创建新 Tunnel"
        read -p "请输入选项 (1 或 2): " TUNNEL_CHOICE
        if [ "$TUNNEL_CHOICE" = "1" ]; then
            /usr/local/bin/cloudflared tunnel list
            read -p "请输入要使用的 Tunnel 名称： " TUNNEL_NAME
            CREDENTIALS_FILE=$(ls -t /root/.cloudflared/*.json | head -n 1)
            TUNNEL_ID=$(basename "$CREDENTIALS_FILE" .json)
        else
            TUNNEL_NAME="my-tunnel-$(date +%s)"
            echo -e "${GREEN}创建新 Tunnel：$TUNNEL_NAME${NC}"
            /usr/local/bin/cloudflared tunnel create $TUNNEL_NAME
            CREDENTIALS_FILE="/root/.cloudflared/${TUNNEL_NAME}.json"
            TUNNEL_ID=$(basename "$CREDENTIALS_FILE" .json)
        fi
    else
        TUNNEL_NAME="my-tunnel-$(date +%s)"
        echo -e "${GREEN}创建新 Tunnel：$TUNNEL_NAME${NC}"
        /usr/local/bin/cloudflared tunnel create $TUNNEL_NAME
        CREDENTIALS_FILE="/root/.cloudflared/${TUNNEL_NAME}.json"
        TUNNEL_ID=$(basename "$CREDENTIALS_FILE" .json)
    fi

    CONFIG_FILE="/root/.cloudflared/config.yml"
    cat > $CONFIG_FILE <<EOF
tunnel: $TUNNEL_ID
credentials-file: $CREDENTIALS_FILE
ingress:
  - hostname: $TUNNEL_DOMAIN
    service: $LOCAL_SERVICE
  - service: http_status:404
EOF

    echo -e "${GREEN}配置文件已生成：$CONFIG_FILE${NC}"
    /usr/local/bin/cloudflared tunnel route dns $TUNNEL_NAME $TUNNEL_DOMAIN

    systemctl stop cloudflared 2>/dev/null
    pkill -f "cloudflared.*tunnel.*run" 2>/dev/null
    /usr/local/bin/cloudflared --config $CONFIG_FILE --logfile /var/log/cloudflared.log tunnel run $TUNNEL_ID &
    TUNNEL_PID=$!
    sleep 5
    if ps -p $TUNNEL_PID > /dev/null; then
        echo -e "${GREEN}Tunnel 已启动 (PID: $TUNNEL_PID)${NC}"
    else
        echo -e "${RED}Tunnel 启动失败，请检查日志${NC}"
        cat /var/log/cloudflared.log
        exit 1
    fi

    read -p "是否将 Tunnel 安装为系统服务？(y/n): " INSTALL_SERVICE
    if [ "$INSTALL_SERVICE" = "y" ] || [ "$INSTALL_SERVICE" = "Y" ]; then
        /usr/local/bin/cloudflared --config $CONFIG_FILE service install
        systemctl daemon-reload
        systemctl enable cloudflared
        systemctl start cloudflared
        if systemctl is-active cloudflared &> /dev/null; then
            echo -e "${GREEN}cloudflared 服务已启动${NC}"
        else
            echo -e "${RED}服务启动失败${NC}"
            systemctl status cloudflared
            exit 1
        fi
    fi
}

# 优化后的临时 Argo Tunnel 函数（使用之前可靠的实现）
temporary_argo() {
    install_cloudflared
    read -p "请输入本地服务的地址和端口（例如 http://localhost:8080）： " LOCAL_SERVICE
    LOCAL_PORT=$(echo $LOCAL_SERVICE | grep -oP '(?<=:)\d+')
    if ! netstat -tuln | grep -q ":${LOCAL_PORT} "; then
        echo -e "${RED}警告：本地服务 $LOCAL_SERVICE 未运行${NC}"
        read -p "是否继续？(y/n): " CONTINUE
        [ "$CONTINUE" != "y" ] && [ "$CONTINUE" != "Y" ] && exit 1
    fi

    echo -e "${GREEN}生成临时 Argo Tunnel...${NC}"
    ARGO_DOMAIN=$(timeout 60s /usr/local/bin/cloudflared tunnel --url "$LOCAL_SERVICE" --logfile /var/log/argo_temp.log --loglevel error 2>/dev/null | grep -oE "https://[-0-9a-z]*\.trycloudflare.com" | head -n1)
    if [ -n "$ARGO_DOMAIN" ]; then
        echo -e "${GREEN}临时 Argo Tunnel 域名: $ARGO_DOMAIN${NC}"
        echo "临时隧道已在前台运行，按 Ctrl+C 停止"
        echo "日志记录在 /var/log/argo_temp.log"
        /usr/local/bin/cloudflared tunnel --url "$LOCAL_SERVICE" --logfile /var/log/argo_temp.log
    else
        echo -e "${RED}生成临时 Argo Tunnel 失败${NC}"
        echo "可能原因：1) 网络问题 2) 本地服务未正确监听 3) Cloudflare 服务不可用"
        echo "检查日志："
        cat /var/log/argo_temp.log 2>/dev/null || echo "无日志输出"
        exit 1
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
    rm -f /etc/systemd/system/cloudflared.service
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
            temporary_argo
            ;;
        4)
            replace_argo_tunnel
            ;;
        5)
            echo -e "${GREEN}退出脚本${NC}"
            exit 0
            ;;
        t) # 快捷键支持
            temporary_argo
            ;;
        *)
            echo -e "${RED}无效选项，请输入 1-5 或 't'${NC}"
            ;;
    esac
done
