#!/bin/bash

# 脚本功能：在 CentOS 7、Ubuntu 和 Debian 上安装或卸载 Cloudflare Tunnel (cloudflared)
# 使用方法：运行脚本，选择安装或卸载

# 检查是否以 root 或 sudo 权限运行
if [ "$EUID" -ne 0 ]; then
    echo "请以 root 或 sudo 权限运行此脚本"
    exit 1
fi

# 检测操作系统
OS=""
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION_ID=$VERSION_ID
else
    echo "无法检测操作系统"
    exit 1
fi

echo "检测到的操作系统：$OS $VERSION_ID"

# 安装 cloudflared 的函数
install_cloudflared() {
    case $OS in
        "centos")
            if [[ "$VERSION_ID" =~ ^7 ]]; then
                echo "安装 Cloudflared for CentOS 7..."
                wget -O /tmp/cloudflared.rpm https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.rpm
                yum install -y /tmp/cloudflared.rpm
                rm -f /tmp/cloudflared.rpm
            else
                echo "此脚本仅支持 CentOS 7"
                exit 1
            fi
            ;;
        "ubuntu")
            echo "安装 Cloudflared for Ubuntu..."
            wget -O /tmp/cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
            dpkg -i /tmp/cloudflared.deb || apt-get install -f -y
            rm -f /tmp/cloudflared.deb
            ;;
        "debian")
            echo "安装 Cloudflared for Debian..."
            wget -O /tmp/cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
            dpkg -i /tmp/cloudflared.deb || apt-get install -f -y
            rm -f /tmp/cloudflared.deb
            ;;
        *)
            echo "不支持的操作系统：$OS"
            exit 1
            ;;
    esac

    # 验证安装
    if ! command -v cloudflared &> /dev/null; then
        echo "Cloudflared 安装失败"
        exit 1
    else
        echo "Cloudflared 安装成功，版本：$(cloudflared --version)"
    fi
}

# 配置 Cloudflare Tunnel 的函数
configure_tunnel() {
    echo "正在登录 Cloudflare..."
    cloudflared login

    # 检查登录是否成功
    if [ ! -f ~/.cloudflared/cert.pem ]; then
        echo "登录失败，请确保正确完成浏览器认证"
        exit 1
    fi

    # 获取用户输入
    read -p "请输入要使用的域名（例如 tunnel.example.com）： " TUNNEL_DOMAIN
    read -p "请输入 VPS 本地服务的地址和端口（例如 http://localhost:80）： " LOCAL_SERVICE

    # 创建 Tunnel
    echo "创建 Tunnel..."
    TUNNEL_NAME="my-tunnel-$(date +%s)"
    cloudflared tunnel create $TUNNEL_NAME

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

    echo "配置文件已生成：$CONFIG_FILE"
    cat $CONFIG_FILE

    # 添加 DNS 记录
    echo "添加 DNS 记录..."
    cloudflared tunnel route dns $TUNNEL_NAME $TUNNEL_DOMAIN

    # 启动 Tunnel
    echo "启动 Tunnel..."
    cloudflared tunnel --config $CONFIG_FILE run $TUNNEL_NAME &

    # 安装为系统服务（可选）
    read -p "是否将 Tunnel 安装为系统服务？(y/n): " INSTALL_SERVICE
    if [ "$INSTALL_SERVICE" = "y" ] || [ "$INSTALL_SERVICE" = "Y" ]; then
        cloudflared service install --config $CONFIG_FILE
        systemctl enable cloudflared
        systemctl start cloudflared
        echo "Tunnel 已安装为系统服务并启动"
    fi
}

# 卸载 Cloudflare Tunnel 的函数
uninstall_cloudflared() {
    echo "开始卸载 Cloudflare Tunnel..."

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

    # 根据系统清理包管理器安装的依赖（可选）
    case $OS in
        "centos")
            yum remove -y cloudflared 2>/dev/null
            ;;
        "ubuntu"|"debian")
            apt-get remove -y cloudflared 2>/dev/null
            apt-get autoremove -y 2>/dev/null
            ;;
    esac

    echo "Cloudflare Tunnel 已完全卸载"
}

# 主流程
echo "Cloudflare Tunnel 一键脚本"
echo "支持的系统：CentOS 7, Ubuntu, Debian"
echo "请选择操作："
echo "1) 安装 Cloudflare Tunnel"
echo "2) 卸载 Cloudflare Tunnel"
read -p "输入选项 (1 或 2): " CHOICE

case $CHOICE in
    1)
        echo "开始安装 Cloudflare Tunnel..."
        # 更新系统包（可选）
        case $OS in
            "centos") yum update -y ;;
            "ubuntu"|"debian") apt-get update -y ;;
        esac
        install_cloudflared
        configure_tunnel
        echo "Cloudflare Tunnel 安装和配置完成！"
        echo "如需卸载，请再次运行脚本并选择卸载选项"
        ;;
    2)
        uninstall_cloudflared
        ;;
    *)
        echo "无效选项，请输入 1 或 2"
        exit 1
        ;;
esac
