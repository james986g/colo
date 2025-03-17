#!/bin/bash

# 脚本功能：在 CentOS 7、Ubuntu 和 Debian 上安装或卸载 Cloudflare Tunnel (cloudflared)
# 优化功能：检测现有 cloudflared 资源并继续运行
# 使用方法：运行脚本，选择安装或卸载

# 检查是否以 root 或 sudo 权限运行
if [ "$EUID" -ne 0 ]; then
    echo "请以 root 或 sudo 权限运行此脚本"
    exit 1
fi

# 定义颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
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

    # 检查二进制文件
    if command -v cloudflared &> /dev/null; then
        echo "找到 cloudflared 二进制文件：$(which cloudflared)，版本：$(cloudflared --version)"
        CLOUDFLARED_EXISTS=1
    fi

    # 检查配置文件目录
    if [ -d /root/.cloudflared ]; then
        echo "找到 cloudflared 配置文件目录：/root/.cloudflared"
        CLOUDFLARED_EXISTS=1
    fi

    # 检查服务
    if systemctl is-active cloudflared &> /dev/null; then
        echo "找到运行中的 cloudflared 服务"
        CLOUDFLARED_EXISTS=1
    fi

    if [ $CLOUDFLARED_EXISTS -eq 0 ]; then
        echo "系统中未找到现有 cloudflared 资源"
    fi
    return $CLOUDFLARED_EXISTS
}

# 安装 cloudflared 的函数
install_cloudflared() {
    check_existing_cloudflared
    if [ $? -eq 1 ]; then
        echo -e "${GREEN}系统中已存在 cloudflared，继续配置...${NC}"
        return 0
    fi

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

    # 验证安装
    if ! command -v cloudflared &> /dev/null; then
        echo -e "${RED}Cloudflared 安装失败${NC}"
        exit 1
    else
        echo -e "${GREEN}Cloudflared 安装成功，版本：$(cloudflared --version)${NC}"
    fi
}

# 配置 Cloudflare Tunnel 的函数
configure_tunnel() {
    # 检查是否已登录
    if [ ! -f /root/.cloudflared/cert.pem ]; then
        echo -e "${GREEN}正在登录 Cloudflare...${NC}"
        cloudflared login
        if [ ! -f /root/.cloudflared/cert.pem ]; then
            echo -e "${RED}登录失败，请确保正确完成浏览器认证${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}已检测到登录凭证，跳过登录步骤${NC}"
    fi

    # 获取用户输入
    read -p "请输入要使用的域名（例如 tunnel.example.com）： " TUNNEL_DOMAIN
    read -p "请输入 VPS 本地服务的地址和端口（例如 http://localhost:80）： " LOCAL_SERVICE

    # 检查是否已有 Tunnel
    if [ -n "$(cloudflared tunnel list | grep -v 'No tunnels')" ]; then
        echo -e "${GREEN}检测到现有 Tunnel，请选择：${NC}"
        echo "1) 使用现有 Tunnel"
        echo "2) 创建新 Tunnel"
        read -p "请输入选项 (1 或 2): " TUNNEL_CHOICE
        if [ "$TUNNEL_CHOICE" = "1" ]; then
            echo "现有 Tunnel 列表："
            cloudflared tunnel list
            read -p "请输入要使用的 Tunnel 名称： " TUNNEL_NAME
        else
            TUNNEL_NAME="my-tunnel-$(date +%s)"
            echo -e "${GREEN}创建新 Tunnel：$TUNNEL_NAME${NC}"
            cloudflared tunnel create $TUNNEL_NAME
        fi
    else
        TUNNEL_NAME="my-tunnel-$(date +%s)"
        echo -e "${GREEN}创建新 Tunnel：$TUNNEL_NAME${NC}"
        cloudflared tunnel create $TUNNEL_NAME
    fi

    # 生成配置文件
    CONFIG_FILE="/root/.cloudflared/config.yml"
    cat > $CONFIG_FILE <<EOF
tunnel: $TUNNEL_NAME
credentials-file: /root/.cloudflared/${TUNNEL_NAME}.json
ingress:
  - hostname: $TUNNEL_DOMAIN
    service: $LOCAL_SERVICE
  - service: http_status:404
EOF

    echo -e "${GREEN}配置文件已生成：$CONFIG_FILE${NC}"
    cat $CONFIG_FILE

    # 添加 DNS 记录
    echo -e "${GREEN}添加 DNS 记录...${NC}"
    cloudflared tunnel route dns $TUNNEL_NAME $TUNNEL_DOMAIN

    # 检查是否已有运行的 Tunnel
    if systemctl is-active cloudflared &> /dev/null || pgrep cloudflared &> /dev/null; then
        echo -e "${GREEN}检测到运行中的 Tunnel，重新启动...${NC}"
        pkill -9 cloudflared 2>/dev/null
        systemctl stop cloudflared 2>/dev/null
    fi

    # 启动 Tunnel
    echo -e "${GREEN}启动 Tunnel...${NC}"
    cloudflared tunnel --config $CONFIG_FILE run $TUNNEL_NAME &

    # 安装为系统服务（可选）
    read -p "是否将 Tunnel 安装为系统服务？(y/n): " INSTALL_SERVICE
    if [ "$INSTALL_SERVICE" = "y" ] || [ "$INSTALL_SERVICE" = "Y" ]; then
        cloudflared service install --config $CONFIG_FILE
        systemctl enable cloudflared
        systemctl start cloudflared
        echo -e "${GREEN}Tunnel 已安装为系统服务并启动${NC}"
    fi
}

# 卸载 Cloudflare Tunnel 的函数
uninstall_cloudflared() {
    echo -e "${GREEN}开始卸载 Cloudflare Tunnel...${NC}"

    # 停止并删除系统服务（如果存在）
    if systemctl is-active cloudflared &> /dev/null; then
        systemctl stop cloudflared
        systemctl disable cloudflared
        rm -f /etc/systemd/system/cloudflared.service
        systemctl daemon-reload
        echo "已停止并删除 cloudflared 系统服务"
    fi

    # 杀死运行中的 cloudflared 进程
    if pkill -9 cloudflared 2>/dev/null; then
        echo "已终止所有 cloudflared 进程"
    fi

    # 删除 cloudflared 二进制文件
    if [ -f /usr/local/bin/cloudflared ]; then
        rm -f /usr/local/bin/cloudflared
        echo "已删除 /usr/local/bin/cloudflared"
    elif command -v cloudflared &> /dev/null; then
        rm -f "$(which cloudflared)"
        echo "已删除 cloudflared 二进制文件"
    fi

    # 删除配置文件和相关文件
    if [ -d /root/.cloudflared ]; then
        rm -rf /root/.cloudflared
        echo "已删除 /root/.cloudflared 目录及其所有文件"
    fi

    # 删除可能的临时文件
    rm -f /tmp/cloudflared.deb /tmp/cloudflared.rpm 2>/dev/null

    echo -e "${GREEN}Cloudflare Tunnel 已完全卸载${NC}"
}

# 主流程
echo -e "${GREEN}Cloudflare Tunnel 一键脚本${NC}"
echo "支持的系统：CentOS, Ubuntu, Debian"
echo "请选择操作："
echo "1) 安装 Cloudflare Tunnel"
echo "2) 卸载 Cloudflare Tunnel"
read -p "输入选项 (1 或 2): " CHOICE

case $CHOICE in
    1)
        echo -e "${GREEN}开始安装 Cloudflare Tunnel...${NC}"
        # 更新系统包（可选）
        case $OS in
            "centos") yum update -y ;;
            "ubuntu"|"debian") apt-get update -y ;;
        esac
        install_cloudflared
        configure_tunnel
        echo -e "${GREEN}Cloudflare Tunnel 安装和配置完成！${NC}"
        echo "如需卸载，请再次运行脚本并选择卸载选项"
        ;;
    2)
        uninstall_cloudflared
        ;;
    *)
        echo -e "${RED}无效选项，请输入 1 或 2${NC}"
        exit 1
        ;;
esac
