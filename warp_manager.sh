#!/bin/bash

# 一键脚本：安装 WARP 并优化网络，支持多种账户、IP 更换和快捷命令
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

# 安装依赖
install_dependencies() {
  echo -e "${GREEN}安装必要的依赖...${NC}"
  if [ -f /etc/centos-release ]; then
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
  if [ -f /etc/centos-release ]; then
    curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ fedora main" > /etc/yum.repos.d/cloudflare-warp.repo
    yum install -y cloudflare-warp
  elif [ -f /etc/debian_version ]; then
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
    rm -f /etc/yum.repos.d/cloudflare-warp.repo
  elif [ -f /etc/debian_version ]; then
    apt remove -y cloudflare-warp
    rm -f /etc/apt/sources.list.d/cloudflare-warp.list
  fi
  rm -f /usr/local/bin/warp-keepalive.sh /etc/systemd/system/warp-keepalive.service
  systemctl daemon-reload
  echo -e "${GREEN}WARP 已完全卸载！${NC}"
}

# 强制切换到 WARP IPv6
switch_to_ipv6() {
  echo -e "${GREEN}强制切换到 WARP IPv6...${NC}"
  register_warp
  warp-cli disconnect
  warp-cli set-mode proxy
  warp-cli set-custom-endpoint "[2606:4700:d0::a29f:c001]:2408"
  warp-cli connect
  optimize_endpoint
  echo "allowed-ips ::/0" > /etc/wireguard/warp.conf
  warp-cli set-config /etc/wireguard/warp.conf
  setup_keepalive
  verify_warp
}

# 强制切换到 WARP IPv4
switch_to_ipv4() {
  echo -e "${GREEN}强制切换到 WARP IPv4...${NC}"
  register_warp
  warp-cli disconnect
  warp-cli set-mode proxy
  warp-cli set-custom-endpoint "162.159.193.10:2408"
  warp-cli connect
  optimize_endpoint
  echo "allowed-ips 0.0.0.0/0" > /etc/wireguard/warp.conf
  warp-cli set-config /etc/wireguard/warp.conf
  setup_keepalive
  verify_warp
}

# 强制切换到 WARP 双栈
switch_to_dualstack() {
  echo -e "${GREEN}强制切换到 WARP 双栈...${NC}"
  register_warp
  warp-cli disconnect
  warp-cli set-mode proxy
  warp-cli set-custom-endpoint "162.159.193.10:2408"
  warp-cli connect
  optimize_endpoint
  echo "allowed-ips 0.0.0.0/0,::/0" > /etc/wireguard/warp.conf
  warp-cli set-config /etc/wireguard/warp.conf
  setup_keepalive
  verify_warp
}

# 更换 WARP IP
change_warp_ip() {
  echo -e "${GREEN}更换 WARP IP...${NC}"
  warp-cli disconnect
  warp-cli delete
  register_warp
  warp-cli connect
  optimize_endpoint
  setup_keepalive
  verify_warp
}

# 创建快捷命令
setup_shortcut() {
  echo -e "${GREEN}创建快捷命令 'warpctl'...${NC}"
  mv "$0" /usr/local/bin/warpctl.sh
  chmod +x /usr/local/bin/warpctl.sh
  ln -sf /usr/local/bin/warpctl.sh /usr/bin/warpctl
  echo -e "${GREEN}快捷命令已创建！再次运行可使用 'warpctl'${NC}"
}

# 主菜单
menu() {
  clear
  echo -e "${GREEN}===== WARP 一键管理脚本 =====${NC}"
  echo "1. 安装 WARP 并优化马来西亚网络"
  echo "2. 强制切换到 WARP IPv6"
  echo "3. 强制切换到 WARP IPv4"
  echo "4. 强制切换到 WARP 双栈"
  echo "5. 使用 WARP+ 账户"
  echo "6. 更换 WARP IP"
  echo "7. 一键卸载 WARP"
  echo "0. 退出"
  read -p "请选择操作 [0-7]: " choice

  case $choice in
    1)
      install_dependencies
      install_warp
      register_warp
      warp-cli connect
      optimize_endpoint
      setup_keepalive
      verify_warp
      setup_shortcut
      ;;
    2)
      install_dependencies
      install_warp
      switch_to_ipv6
      setup_shortcut
      ;;
    3)
      install_dependencies
      install_warp
      switch_to_ipv4
      setup_shortcut
      ;;
    4)
      install_dependencies
      install_warp
      switch_to_dualstack
      setup_shortcut
      ;;
    5)
      install_dependencies
      install_warp
      register_warp
      upgrade_to_warp_plus
      optimize_endpoint
      setup_keepalive
      verify_warp
      setup_shortcut
      ;;
    6)
      install_dependencies
      install_warp
      change_warp_ip
      setup_shortcut
      ;;
    7)
      uninstall_warp
      setup_shortcut
      ;;
    0)
      echo -e "${GREEN}退出脚本${NC}"
      setup_shortcut
      exit 0
      ;;
    *)
      echo -e "${RED}无效选项，请输入 0-7！${NC}"
      sleep 2
      menu
      ;;
  esac
}

# 执行主菜单
menu
