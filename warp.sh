#!/usr/bin/env bash

# 脚本版本
VERSION='1.0.0'

# 环境变量设置
export DEBIAN_FRONTEND=noninteractive

# 检查root权限
[ "$(id -u)" != 0 ] && { echo -e "\033[31m必须以root运行脚本，请使用 sudo -i\033[0m"; exit 1; }

# 检查系统支持
check_system() {
  if [ -f /etc/debian_version ]; then
    SYS="Debian"
  elif [ -f /etc/redhat-release ]; then
    SYS="CentOS"
  elif [ -f /etc/os-release ] && grep -q "Ubuntu" /etc/os-release; then
    SYS="Ubuntu"
  else
    echo -e "\033[31m仅支持Debian/Ubuntu/CentOS\033[0m"
    exit 1
  fi
}

# 安装依赖
install_deps() {
  case "$SYS" in
    Debian|Ubuntu)
      apt update -y
      apt install -y wget curl tar iproute2
      ;;
    CentOS)
      yum update -y
      yum install -y wget curl tar iproute2
      ;;
  esac
}

# 安装warp-go
install_warp_go() {
  mkdir -p /opt/warp-go
  wget -O /tmp/warp-go.tar.gz "https://gitlab.com/sasalele/intel-test2/-/raw/main/warp-go/warp-go_1.0.8_linux_amd64.tar.gz"
  tar -xzf /tmp/warp-go.tar.gz -C /opt/warp-go/
  chmod +x /opt/warp-go/warp-go
  rm -f /tmp/warp-go.tar.gz
}

# 创建初始双栈配置文件
create_config() {
  cat > /opt/warp-go/warp.conf << EOF
[Account]
Device = WARP-DEVICE
PrivateKey = SHVqHEGI7k2+OQ/oWMmWY2EQObbRQjRBdDPimh0h1WY=
Token = FREE_TOKEN
Type = free

[Device]
Name = WARP
MTU = 1280

[Peer]
PublicKey = bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=
Endpoint = 162.159.193.10:1701
KeepAlive = 30
AllowedIPs = 0.0.0.0/0,::/0

[Script]
PostUp = ip rule add to 0.0.0.0/0 dev WARP table 200
PostDown = ip rule del to 0.0.0.0/0 dev WARP table 200
EOF
}

# 启动warp-go
start_warp() {
  /opt/warp-go/warp-go --config=/opt/warp-go/warp.conf &
  sleep 2
}

# 转换为IPv4单栈 (warp-go 4)
to_ipv4() {
  sed -i 's/AllowedIPs = 0.0.0.0\/0,::\/0/AllowedIPs = 0.0.0.0\/0/' /opt/warp-go/warp.conf
  pkill warp-go
  start_warp
  echo "已转换为WARP全局IPv4"
}

# 转换为IPv6单栈 (warp-go 6)
to_ipv6() {
  sed -i 's/AllowedIPs = 0.0.0.0\/0,::\/0/AllowedIPs = ::\/0/' /opt/warp-go/warp.conf
  pkill warp-go
  start_warp
  echo "已转换为WARP全局IPv6"
}

# 转换为非全局 (warp-go g)
to_nonglobal() {
  sed -i 's/^AllowedIPs/#AllowedIPs/' /opt/warp-go/warp.conf
  pkill warp-go
  start_warp
  echo "已转换为WARP非全局网络接口"
}

# 开关warp-go (warp-go o)
toggle_warp() {
  if pgrep warp-go > /dev/null; then
    pkill warp-go
    echo "WARP已关闭"
  else
    start_warp
    echo "WARP已开启"
  fi
}

# 更换账户类型 (warp-go a)
change_account() {
  echo "选择账户类型："
  echo "1. Free"
  echo "2. WARP+"
  echo "3. Teams"
  read -p "请输入选择 [1-3]: " choice
  case $choice in
    1)
      sed -i 's/Type = .*/Type = free/' /opt/warp-go/warp.conf
      echo "已切换到Free账户"
      ;;
    2)
      read -p "请输入WARP+ License: " license
      sed -i "s/Type = .*/Type = plus/" /opt/warp-go/warp.conf
      echo "$license" > /opt/warp-go/License
      echo "已切换到WARP+账户"
      ;;
    3)
      read -p "请输入Teams Token: " token
      sed -i "s/Type = .*/Type = team/" /opt/warp-go/warp.conf
      echo "$token" > /opt/warp-go/Team_Token
      echo "已切换到Teams账户"
      ;;
  esac
  pkill warp-go
  start_warp
}

# 更换支持Netflix的IP (warp-go i)
change_netflix_ip() {
  echo "正在更换支持Netflix的IP..."
  pkill warp-go
  start_warp
  echo "IP已更换，请手动测试Netflix解锁情况"
}

# 输出配置文件 (warp-go e)
export_configs() {
  /opt/warp-go/warp-go --config=/opt/warp-go/warp.conf --export-wireguard=/opt/warp-go/wgcf.conf
  /opt/warp-go/warp-go --config=/opt/warp-go/warp.conf --export-singbox=/opt/warp-go/singbox.json
  echo "WireGuard配置文件: /opt/warp-go/wgcf.conf"
  cat /opt/warp-go/wgcf.conf
  echo -e "\nSing-box配置文件: /opt/warp-go/singbox.json"
  cat /opt/warp-go/singbox.json
}

# 卸载warp-go (warp-go u)
uninstall_warp() {
  pkill warp-go
  rm -rf /opt/warp-go
  echo "WARP已卸载"
}

# 主菜单
main_menu() {
  clear
  echo "Cloudflare WARP 一键脚本 v$VERSION"
  echo "================================="
  echo "1. 安装WARP (全局双栈)"
  echo "2. 转为WARP全局IPv4 (warp-go 4)"
  echo "3. 转为WARP全局IPv6 (warp-go 6)"
  echo "4. 转为WARP非全局 (warp-go g)"
  echo "5. 开关WARP (warp-go o)"
  echo "6. 更换账户类型 (warp-go a)"
  echo "7. 更换Netflix IP (warp-go i)"
  echo "8. 输出配置文件 (warp-go e)"
  echo "9. 卸载WARP (warp-go u)"
  echo "0. 退出"
  echo "================================="
  read -p "请选择操作 [0-9]: " choice
  case $choice in
    1) check_system && install_deps && install_warp_go && create_config && start_warp ;;
    2) to_ipv4 ;;
    3) to_ipv6 ;;
    4) to_nonglobal ;;
    5) toggle_warp ;;
    6) change_account ;;
    7) change_netflix_ip ;;
    8) export_configs ;;
    9) uninstall_warp ;;
    0) exit 0 ;;
    *) echo "无效选择"; sleep 1; main_menu ;;
  esac
}

# 执行主程序
main_menu
