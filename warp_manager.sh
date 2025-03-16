#!/bin/bash

# 一键脚本：安装 WARP 并优化马来西亚网络，支持多种账户、IP 更换和快捷命令
# 作者：为个人使用定制
# 当前日期：2025-03-16

# 定义颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}请以 root 权限运行此脚本！${NC}"
  exit 1
fi

# 检查网络连通性
check_network() {
  echo -e "${GREEN}检查网络连通性...${NC}"
  if ! ping -c 3 8.8.8.8 &> /dev/null; then
    echo -e "${RED}无法访问网络，请检查网络设置！${NC}"
    exit 1
  fi
}

# 安装依赖
install_dependencies() {
  echo -e "${GREEN}安装必要的依赖...${NC}"
  if [ -f /etc/centos-release ]; then
    # 修复 CentOS 7 EOL 源
    if grep -q "mirrorlist.centos.org" /etc/yum.repos.d/CentOS-Base.repo; then
      echo -e "${GREEN}修复 CentOS 7 EOL 源...${NC}"
      sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Base.repo
      sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Base.repo
      yum makecache
    fi
    yum install -y curl jq iputils wireguard-tools bc
  elif [ -f /etc/debian_version ]; then
    apt update -y && apt install -y curl jq iputils-ping wireguard-tools bc
  else
    echo -e "${RED}仅支持 CentOS 或 Debian/Ubuntu 系统！${NC}"
    exit 1
  fi
}

# 安装 Cloudflare WARP 客户端
install_warp() {
  echo -e "${GREEN}安装 Cloudflare WARP 客户端...${NC}"
  check_network
  if [ -f /etc/centos-release ]; then
    # 确保 GPG 密钥目录存在
    mkdir -p /etc/pki/rpm-gpg/
    # 下载并安装 Cloudflare GPG 密钥
    curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg -o /tmp/cloudflare-pubkey.gpg
    if [ $? -ne 0 ]; then
      echo -e "${RED}下载 GPG 密钥失败，请检查网络！${NC}"
      exit 1
    fi
    gpg --yes --dearmor -o /etc/pki/rpm-gpg/RPM-GPG-KEY-CLOUDFLARE /tmp/cloudflare-pubkey.gpg
    rm -f /tmp/cloudflare-pubkey.gpg
    # 配置正确的 Yum 源
    cat > /etc/yum.repos.d/cloudflare-warp.repo << EOF
[cloudflare-warp]
name=Cloudflare WARP
baseurl=https://pkg.cloudflareclient.com/yum/rhel/\$releasever/\$basearch
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CLOUDFLARE
EOF
    yum install -y cloudflare-warp
  elif [ -f /etc/debian_version ]; then
    mkdir -p /usr/share/keyrings/
    curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ focal main" > /etc/apt/sources.list.d/cloudflare-warp.list
    apt update -y && apt install -y cloudflare-warp
  fi

  if ! command -v warp-cli &> /dev/null; then
    echo -e "${RED}WARP 安装失败，请检查网络或手动安装！${NC}"
    exit 1
  else
    echo -e "${GREEN}WARP 安装成功，版本：$(warp-cli --version)${NC}"
  fi
}

# 注册 WARP（免费账户或 Zero Trust）
register_warp() {
  if ! warp-cli status &> /dev/null; then
    echo -e "${GREEN}选择账户类型：${NC}"
    echo "1. 免费 WARP 账户"
    echo "2. Zero Trust 账户（需要注册密钥）"
    read -p "请输入选项 [1-2]: " account_type
    case $account_type in
      1)
        echo -e "${GREEN}注册免费 WARP 账户...${NC}"
        warp-cli register
        ;;
      2)
        echo -e "${GREEN}请登录 Cloudflare Zero Trust 仪表板，获取 WARP 客户端注册密钥${NC}"
        echo -e "${GREEN}参考：https://dash.teams.cloudflare.com -> Devices -> Add a device${NC}"
        read -p "请输入你的 WARP 注册密钥（格式如 xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx）： " WARP_KEY
        echo -e "${GREEN}注册 WARP 设备...${NC}"
        warp-cli register --key "$WARP_KEY"
        ;;
      *)
        echo -e "${RED}无效选项，使用默认免费账户${NC}"
        warp-cli register
        ;;
    esac
    if [ $? -ne 0 ]; then
      echo -e "${RED}注册失败，请检查密钥或网络！${NC}"
      exit 1
    fi
  fi
}

# 使用 WARP+ 账户
upgrade_to_warp_plus() {
  echo -e "${GREEN}升级到 WARP+ 账户...${NC}"
  read -p "请输入 WARP+ License Key（26位，如 xxxx-xxxx-xxxx）： " LICENSE_KEY
  if [[ ! "$LICENSE_KEY" =~ ^[A-Za-z0-9]{8}-[A-Za-z0-9]{8}-[A-Za-z0-9]{8}$ ]]; then
    echo -e "${RED}License Key 格式错误，应为 26 位！${NC}"
    return 1
  fi
  warp-cli disconnect
  warp-cli set-license "$LICENSE_KEY"
  warp-cli connect
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}成功升级到 WARP+ 账户！${NC}"
  else
    echo -e "${RED}WARP+ 升级失败，请检查 License Key！${NC}"
  fi
}

# 测试并优化马来西亚网络 Endpoint
optimize_endpoint() {
  echo -e "${GREEN}测试并优化马来西亚网络的 WARP Endpoint...${NC}"
  ENDPOINTS=(
    "162.159.192.1:2408"
    "162.159.193.10:1701"
    "162.159.195.1:2408"
    "[2606:4700:d0::a29f:c001]:2408"
    "[2606:4700:d1::a29f:c001]:2408"
  )

  BEST_ENDPOINT=""
  BEST_DELAY=9999

  for ENDPOINT in "${ENDPOINTS[@]}"; do
    echo -e "${GREEN}测试 Endpoint: $ENDPOINT${NC}"
    IP=${ENDPOINT%%:*}
    DELAY=$(ping -c 5 -W 2 "$IP" | grep 'avg' | awk -F'/' '{print $5}')
    if [ -n "$DELAY" ] && [ $(echo "$DELAY < $BEST_DELAY" | bc) -eq 1 ]; then
      BEST_DELAY=$DELAY
      BEST_ENDPOINT=$ENDPOINT
    fi
    echo "延迟: ${DELAY:-超时} ms"
  done

  if [ -z "$BEST_ENDPOINT" ]; then
    echo -e "${RED}未找到可用 Endpoint，使用默认值 162.159.193.10:2408${NC}"
    BEST_ENDPOINT="162.159.193.10:2408"
  else
    echo -e "${GREEN}最佳 Endpoint: $BEST_ENDPOINT (延迟: $BEST_DELAY ms)${NC}"
  fi
  warp-cli set-custom-endpoint "$BEST_ENDPOINT"
}

# 配置 WARP 开机自启和保活
setup_keepalive() {
  echo -e "${GREEN}设置 WARP 开机自启和自动保活...${NC}"
  systemctl enable warp-svc
  systemctl start warp-svc

  cat > /usr/local/bin/warp-keepalive.sh << EOF
#!/bin/bash
while true; do
  if ! warp-cli status | grep -q "Connected"; then
    echo "WARP 已断开，正在重连..."
    warp-cli disconnect
    sleep 2
    warp-cli connect
  fi
  sleep 60
done
EOF
  chmod +x /usr/local/bin/warp-keepalive.sh

  cat > /etc/systemd/system/warp-keepalive.service << EOF
[Unit]
Description=WARP Keepalive Service
After=network.target warp-svc.service

[Service]
ExecStart=/usr/local/bin/warp-keepalive.sh
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF
  systemctl daemon-reload
  systemctl enable warp-keepalive.service
  systemctl start warp-keepalive.service
}

# 验证 WARP 是否生效
verify_warp() {
  echo -e "${GREEN}验证 WARP 是否生效...${NC}"
  WARP_IP=$(curl -s ifconfig.me)
  echo -e "${GREEN}当前 VPS 出站 IP: $WARP_IP${NC}"
  echo -e "${GREEN}请检查是否为 Cloudflare IP（如 100.96.x.x 或其他 Cloudflare 范围）${NC}"
}

# 一键卸载 WARP
uninstall_warp() {
  echo -e "${GREEN}卸载 WARP...${NC}"
  warp-cli disconnect
  systemctl stop warp-svc warp-keepalive.service
  systemctl disable warp-svc warp-keepalive.service
  if [ -f /etc/centos-release ]; then
    yum remove -y cloudflare-warp
    rm -f /etc/yum.repos.d/cloud
