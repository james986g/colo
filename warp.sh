#!/usr/bin/env bash

# 脚本版本 - 专为 [您的名字/昵称] 定制
VERSION='1.0.0'
AUTHOR="YourName"  # 请替换为您喜欢的名称

# 颜色定义
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
NC='\033[0m'

# 环境变量
export DEBIAN_FRONTEND=noninteractive

# 检查root权限
[ "$(id -u)" != 0 ] && { echo -e "${RED}请以root身份运行脚本，使用 'sudo -i'${NC}"; exit 1; }

# 检查系统支持
check_system() {
  if [ -f /etc/debian_version ]; then
    SYS="Debian"
    PKG_UPDATE="apt update -y"
    PKG_INSTALL="apt install -y"
  elif [ -f /etc/redhat-release ]; then
    SYS="CentOS"
    PKG_UPDATE="yum update -y"
    PKG_INSTALL="yum install -y"
  elif [ -f /etc/os-release ] && grep -q "Ubuntu" /etc/os-release; then
    SYS="Ubuntu"
    PKG_UPDATE="apt update -y"
    PKG_INSTALL="apt install -y"
  else
    echo -e "${RED}仅支持Debian/Ubuntu/CentOS${NC}"
    exit 1
  fi
}

# 安装依赖
install_deps() {
  echo -e "${GREEN}[$AUTHOR] 安装依赖...${NC}"
  $PKG_UPDATE
  $PKG_INSTALL wget curl tar iproute2 python3 || { echo -e "${RED}依赖安装失败${NC}"; exit 1; }
}

# 安装warp-go
install_warp_go() {
  if [ ! -f /opt/warp-go/warp-go ]; then
    echo -e "${GREEN}[$AUTHOR] 下载并安装warp-go...${NC}"
    mkdir -p /opt/warp-go
    wget -O /tmp/warp-go.tar.gz "https://gitlab.com/sasalele/intel-test2/-/raw/main/warp-go/warp-go_1.0.8_linux_amd64.tar.gz" || { echo -e "${RED}下载失败${NC}"; exit 1; }
    tar -xzf /tmp/warp-go.tar.gz -C /opt/warp-go/ || { echo -e "${RED}解压失败${NC}"; exit 1; }
    chmod +x /opt/warp-go/warp-go
    rm -f /tmp/warp-go.tar.gz
    create_config
    start_warp
  fi
}

# 创建初始双栈配置文件
create_config() {
  echo -e "${GREEN}[$AUTHOR] 创建初始双栈配置文件...${NC}"
  cat > /opt/warp-go/warp.conf << EOF
[Account]
Device = $AUTHOR-WARP
PrivateKey = SHVqHEGI7k2+OQ/oWMmWY2EQObbRQjRBdDPimh0h1WY=
Token = FREE_TOKEN
Type = free

[Device]
Name = $AUTHOR-WARP
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
  pkill warp-go 2>/dev/null
  /opt/warp-go/warp-go --config=/opt/warp-go/warp.conf &
  sleep 2
  if pgrep warp-go > /dev/null; then
    echo -e "${GREEN}[$AUTHOR] WARP已启动${NC}"
  else
    echo -e "${RED}[$AUTHOR] WARP启动失败${NC}"
    exit 1
  fi
}

# 转换为IPv4单栈 (warp-go 4)
to_ipv4() {
  install_warp_go
  sed -i 's/AllowedIPs = .*/AllowedIPs = 0.0.0.0\/0/' /opt/warp-go/warp.conf
  start_warp
  echo -e "${GREEN}[$AUTHOR] 已转换为WARP全局IPv4${NC}"
}

# 转换为IPv6单栈 (warp-go 6)
to_ipv6() {
  install_warp_go
  sed -i 's/AllowedIPs = .*/AllowedIPs = ::\/0/' /opt/warp-go/warp.conf
  start_warp
  echo -e "${GREEN}[$AUTHOR] 已转换为WARP全局IPv6${NC}"
}

# 转换为非全局 (warp-go g)
to_nonglobal() {
  install_warp_go
  sed -i 's/^AllowedIPs/#AllowedIPs/' /opt/warp-go/warp.conf
  start_warp
  echo -e "${GREEN}[$AUTHOR] 已转换为WARP非全局网络接口${NC}"
}

# 开关warp-go (warp-go o)
toggle_warp() {
  install_warp_go
  if pgrep warp-go > /dev/null; then
    pkill warp-go
    echo -e "${GREEN}[$AUTHOR] WARP已关闭${NC}"
  else
    start_warp
    echo -e "${GREEN}[$AUTHOR] WARP已开启${NC}"
  fi
}

# 更换账户类型 (warp-go a)
change_account() {
  install_warp_go
  echo -e "${YELLOW}[$AUTHOR] 选择账户类型：${NC}"
  echo "1. Free"
  echo "2. WARP+"
  echo "3. Teams (默认)"
  read -p "请输入选择 [1-3，默认3]: " choice
  choice=${choice:-3}
  case $choice in
    1)
      sed -i 's/Type = .*/Type = free/' /opt/warp-go/warp.conf
      rm -f /opt/warp-go/License /opt/warp-go/Team_Token
      echo -e "${GREEN}[$AUTHOR] 已切换到Free账户${NC}"
      ;;
    2)
      read -p "请输入WARP+ License (26位): " license
      if [[ "$license" =~ ^[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}$ ]]; then
        sed -i 's/Type = .*/Type = plus/' /opt/warp-go/warp.conf
        echo "$license" > /opt/warp-go/License
        echo -e "${GREEN}[$AUTHOR] 已切换到WARP+账户${NC}"
      else
        echo -e "${RED}[$AUTHOR] License格式错误，应为26位${NC}"
        return 1
      fi
      ;;
    3)
      read -p "请输入组织名: " org
      read -p "请输入邮箱: " email
      read -p "请输入验证码: " code
      token_response=$(curl -s -X POST "https://api.cloudflareclient.com/v0a745/team/auth" \
        -H "Content-Type: application/json" \
        -d "{\"organization\":\"$org\",\"email\":\"$email\",\"code\":\"$code\"}")
      token=$(echo "$token_response" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
      if [ -n "$token" ]; then
        sed -i 's/Type = .*/Type = team/' /opt/warp-go/warp.conf
        echo "$token" > /opt/warp-go/Team_Token
        sed -i "s/Token = .*/Token = $token/" /opt/warp-go/warp.conf
        echo -e "${GREEN}[$AUTHOR] 已切换到Teams账户${NC}"
      else
        echo -e "${RED}[$AUTHOR] Teams Token获取失败，请检查输入${NC}"
        return 1
      fi
      ;;
    *)
      echo -e "${RED}[$AUTHOR] 无效选择${NC}"
      return 1
      ;;
  esac
  start_warp
}

# 更换支持Netflix的IP (warp-go i)
change_netflix_ip() {
  install_warp_go
  echo -e "${GREEN}[$AUTHOR] 正在更换支持Netflix的IP...${NC}"
  max_attempts=5
  attempt=1
  while [ $attempt -le $max_attempts ]; do
    pkill warp-go
    start_warp
    ip=$(curl -s https://api.ip.sb/ip)
    if curl -s "https://www.netflix.com/title/70143836" -H "User-Agent: Mozilla/5.0" | grep -q "Available"; then
      echo -e "${GREEN}[$AUTHOR] 当前IP: $ip 支持Netflix${NC}"
      break
    else
      echo -e "${YELLOW}[$AUTHOR] 尝试 $attempt/$max_attempts: 当前IP: $ip 不支持Netflix${NC}"
      ((attempt++))
      sleep 2
    fi
  done
  if [ $attempt -gt $max_attempts ]; then
    echo -e "${RED}[$AUTHOR] 未找到支持Netflix的IP，请稍后重试${NC}"
  fi
}

# 输出配置文件 (warp-go e)
export_configs() {
  install_warp_go
  /opt/warp-go/warp-go --config=/opt/warp-go/warp.conf --export-wireguard=/opt/warp-go/wgcf.conf
  /opt/warp-go/warp-go --config=/opt/warp-go/warp.conf --export-singbox=/opt/warp-go/singbox.json
  echo -e "${GREEN}[$AUTHOR] WireGuard配置文件: /opt/warp-go/wgcf.conf${NC}"
  cat /opt/warp-go/wgcf.conf
  echo -e "\n${GREEN}[$AUTHOR] Sing-box配置文件: /opt/warp-go/singbox.json${NC}"
  cat /opt/warp-go/singbox.json
}

# 卸载warp-go (warp-go u)
uninstall_warp() {
  pkill warp-go 2>/dev/null
  rm -rf /opt/warp-go
  echo -e "${GREEN}[$AUTHOR] WARP已卸载${NC}"
}

# 主菜单
main_menu() {
  clear
  echo -e "${YELLOW}=================================${NC}"
  echo -e "${GREEN}[$AUTHOR] 的私人定制 WARP 脚本 v$VERSION${NC}"
  echo -e "${YELLOW}=================================${NC}"
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
  echo -e "${YELLOW}=================================${NC}"
  read -p "请选择操作 [0-9]: " choice
  case $choice in
    1) check_system && install_deps && install_warp_go ;;
    2) to_ipv4 ;;
    3) to_ipv6 ;;
    4) to_nonglobal ;;
    5) toggle_warp ;;
    6) change_account ;;
    7) change_netflix_ip ;;
    8) export_configs ;;
    9) uninstall_warp ;;
    0) exit 0 ;;
    *) echo -e "${RED}[$AUTHOR] 无效选择${NC}"; sleep 1; main_menu ;;
  esac
}

# 执行主程序
main_menu
