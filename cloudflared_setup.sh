#!/bin/bash

# 脚本功能：在 CentOS 7、Ubuntu 和 Debian 上安装或卸载 Cloudflare Tunnel (cloudflared)
# 优化功能：检测现有 cloudflared 资源并继续运行

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
            echo "诊断信息："
            [ -f /usr/local/bin/cloudflared ] && echo "文件存在，但可能不可执行" || echo "文件不存在"
            file /usr/local/bin/cloudflared 2>/dev/null || echo "无法检查文件类型"
            exit 1
        else
            echo -e "${GREEN}Cloudflared 安装成功，版本：$(/usr/local/bin/cloudflared --version)${NC}"
        fi
    fi
}

# 配置 Cloudflare Tunnel 的函数
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

    # 检查本地服务是否运行
    LOCAL_PORT=$(echo $LOCAL_SERVICE | grep -oP '(?<=:)\d+')
    if ! netstat -tuln | grep -q ":${LOCAL_PORT} "; then
        echo -e "${RED}警告：本地服务 $LOCAL_SERVICE 未运行，隧道可能无法工作${NC}"
        read -p "是否继续？(y/n): " CONTINUE
        if [ "$CONTINUE" != "y" ] && [ "$CONTINUE" != "Y" ]; then
            exit 1
        fi
    fi

    if [ -n "$(/usr/local/bin/cloudflared tunnel list | grep -v 'No tunnels')" ]; then
        echo -e "${GREEN}检测到现有 Tunnel，请选择：${NC}"
        echo "1) 使用现有 Tunnel"
        echo "2) 创建新 Tunnel"
        read -p "请输入选项 (1 或 2): " TUNNEL_CHOICE
        if [ "$TUNNEL_CHOICE" = "1" ]; then
            echo "现有 Tunnel 列表："
            /usr/local/bin/cloudflared tunnel list
            read -p "请输入要使用的 Tunnel 名称： " TUNNEL_NAME
            CREDENTIALS_FILE=$(ls -t /root/.cloudflared/*.json | head -n 1)
            if [ -z "$CREDENTIALS_FILE" ] || [ ! -s "$CREDENTIALS_FILE" ]; then
                echo -e "${RED}错误：无法找到现有隧道的有效凭证文件${NC}"
                exit 1
            fi
            TUNNEL_ID=$(basename "$CREDENTIALS_FILE" .json)
        else
            TUNNEL_NAME="my-tunnel-$(date +%s)"
            echo -e "${GREEN}创建新 Tunnel：$TUNNEL_NAME${NC}"
            OUTPUT=$(/usr/local/bin/cloudflared tunnel create $TUNNEL_NAME 2>&1)
            echo "$OUTPUT"
            CREDENTIALS_FILE=$(echo "$OUTPUT" | grep -oP '(?<=Tunnel credentials written to ).*\.json')
            if [ -z "$CREDENTIALS_FILE" ] || [ ! -s "$CREDENTIALS_FILE" ]; then
                echo -e "${RED}错误：隧道凭证文件未生成或为空${NC}"
                echo "尝试重新创建隧道..."
                /usr/local/bin/cloudflared tunnel delete $TUNNEL_NAME 2>/dev/null
                OUTPUT=$(/usr/local/bin/cloudflared tunnel create $TUNNEL_NAME 2>&1)
                echo "$OUTPUT"
                CREDENTIALS_FILE=$(echo "$OUTPUT" | grep -oP '(?<=Tunnel credentials written to ).*\.json')
                if [ -z "$CREDENTIALS_FILE" ] || [ ! -s "$CREDENTIALS_FILE" ]; then
                    echo -e "${RED}仍然无法生成有效凭证文件，请检查 cloudflared 权限、登录状态或磁盘空间${NC}"
                    df -h
                    ls -ld /root/.cloudflared
                    exit 1
                fi
            fi
            TUNNEL_ID=$(basename "$CREDENTIALS_FILE" .json)
        fi
    else
        TUNNEL_NAME="my-tunnel-$(date +%s)"
        echo -e "${GREEN}创建新 Tunnel：$TUNNEL_NAME${NC}"
        OUTPUT=$(/usr/local/bin/cloudflared tunnel create $TUNNEL_NAME 2>&1)
        echo "$OUTPUT"
        CREDENTIALS_FILE=$(echo "$OUTPUT" | grep -oP '(?<=Tunnel credentials written to ).*\.json')
        if [ -z "$CREDENTIALS_FILE" ] || [ ! -s "$CREDENTIALS_FILE" ]; then
            echo -e "${RED}错误：隧道凭证文件未生成或为空${NC}"
            echo "尝试重新创建隧道..."
            /usr/local/bin/cloudflared tunnel delete $TUNNEL_NAME 2>/dev/null
            OUTPUT=$(/usr/local/bin/cloudflared tunnel create $TUNNEL_NAME 2>&1)
            echo "$OUTPUT"
            CREDENTIALS_FILE=$(echo "$OUTPUT" | grep -oP '(?<=Tunnel credentials written to ).*\.json')
            if [ -z "$CREDENTIALS_FILE" ] || [ ! -s "$CREDENTIALS_FILE" ]; then
                echo -e "${RED}仍然无法生成有效凭证文件，请检查 cloudflared 权限、登录状态或磁盘空间${NC}"
                df -h
                ls -ld /root/.cloudflared
                exit 1
            fi
        fi
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
    cat $CONFIG_FILE

    echo -e "${GREEN}添加 DNS 记录...${NC}"
    if ! /usr/local/bin/cloudflared tunnel route dns $TUNNEL_NAME $TUNNEL_DOMAIN; then
        echo -e "${RED}警告：添加 DNS 记录失败，请检查域名 $TUNNEL_DOMAIN 是否正确或是否有权限${NC}"
        echo "你可以稍后手动在 Cloudflare 仪表板中添加 CNAME 记录指向 $TUNNEL_ID.cfargotunnel.com"
    else
        echo -e "${GREEN}DNS 记录添加成功${NC}"
    fi

    if systemctl is-active cloudflared &> /dev/null || pgrep -f "cloudflared.*tunnel.*run" &> /dev/null; then
        echo -e "${GREEN}检测到运行中的 Tunnel，重新启动...${NC}"
        pkill -f "cloudflared.*tunnel.*run" 2>/dev/null
        systemctl stop cloudflared 2>/dev/null
        sleep 2
    fi

    echo -e "${GREEN}启动 Tunnel...${NC}"
    free -m | grep "Mem:" | awk '{if ($4 < 100) {print "\033[31m警告：可用内存不足 " $4 "MB，可能导致启动失败\033[0m"}}'
    /usr/local/bin/cloudflared tunnel --config $CONFIG_FILE run $TUNNEL_ID --logfile /var/log/cloudflared.log &
    TUNNEL_PID=$!
    sleep 5
    if ps -p $TUNNEL_PID > /dev/null; then
        echo -e "${GREEN}Tunnel 已成功启动 (PID: $TUNNEL_PID)${NC}"
        echo "隧道日志已记录到 /var/log/cloudflared.log"
    else
        echo -e "${RED}Tunnel 启动失败，请检查配置或日志${NC}"
        cat /var/log/cloudflared.log
        exit 1
    fi

    read -p "是否将 Tunnel 安装为系统服务？(y/n): " INSTALL_SERVICE
    if [ "$INSTALL_SERVICE" = "y" ] || [ "$INSTALL_SERVICE" = "Y" ]; then
        echo -e "${GREEN}安装 cloudflared 为系统服务...${NC}"
        /usr/local/bin/cloudflared service install
        if [ $? -eq 0 ] && [ -f /etc/systemd/system/cloudflared.service ]; then
            sed -i "s|--config .* tunnel run|--config $CONFIG_FILE tunnel run $TUNNEL_ID|" /etc/systemd/system/cloudflared.service
            systemctl daemon-reload
            systemctl enable cloudflared
            systemctl start cloudflared
            if systemctl is-active cloudflared &> /dev/null; then
                echo -e "${GREEN}cloudflared 服务已成功启动${NC}"
            else
                echo -e "${RED}cloudflared 服务启动失败，请检查日志${NC}"
                systemctl status cloudflared
                exit 1
            fi
        else
            echo -e "${RED}cloudflared 服务安装失败，可能是权限问题或版本不兼容${NC}"
            echo "请手动检查：/usr/local/bin/cloudflared service install"
            exit 1
        fi
    fi
}

# 卸载 Cloudflare Tunnel 的函数
uninstall_cloudflared() {
    echo -e "${GREEN}开始卸载 Cloudflare Tunnel...${NC}"

    if systemctl is-active cloudflared &> /dev/null; then
        systemctl stop cloudflared
        systemctl disable cloudflared
        rm -f /etc/systemd/system/cloudflared.service
        systemctl daemon-reload
        echo "已停止并删除 cloudflared 系统服务"
    fi

    if pkill -f "cloudflared.*tunnel.*run" 2>/dev/null; then
        echo "已终止所有 cloudflared 进程"
    fi

    if [ -f /usr/local/bin/cloudflared ]; then
        rm -f /usr/local/bin/cloudflared
        echo "已删除 /usr/local/bin/cloudflared"
    elif command -v cloudflared &> /dev/null; then
        rm -f "$(which cloudflared)"
        echo "已删除 cloudflared 二进制文件"
    fi

    if [ -d /root/.cloudflared ]; then
        rm -rf /root/.cloudflared
        echo "已删除 /root/.cloudflared 目录及其所有文件"
    fi

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
