#!/usr/bin/env bash

# 当前脚本版本号
VERSION='1.6.6 (2024.12.24)'

# 各变量默认值
WS_PATH_DEFAULT='argox'
WORK_DIR='/etc/argox'
TEMP_DIR='/tmp/argox'
TLS_SERVER=addons.mozilla.org
METRICS_PORT='3333'
CDN_DOMAIN=("8cc.free.hr" "cm.yutian.us.kg" "fan.yutian.us.kg" "xn--b6gac.eu.org" "dash.cloudflare.com" "skk.moe" "visa.com")

export DEBIAN_FRONTEND=noninteractive

trap "rm -rf $TEMP_DIR; echo -e '\n' ;exit 1" INT QUIT TERM EXIT

mkdir -p $TEMP_DIR

E[0]="Language:\n 1. English (default) \n 2. 简体中文"
C[0]="${E[0]}"
E[1]="Refactored the chatGPT detection method based on lmc999's detection and unlocking script."
C[1]="根据 lmc999 的检测解锁脚本，重构了检测 chatGPT 方法"
E[2]="Project to create Argo tunnels and Xray specifically for VPS, detailed:[https://github.com/fscarmen/argox]\n Features:\n\t • Allows the creation of Argo tunnels via Token, Json and ad hoc methods. User can easily obtain the json at https://fscarmen.cloudflare.now.cc .\n\t • Extremely fast installation method, saving users time.\n\t • Support system: Ubuntu, Debian, CentOS, Alpine and Arch Linux 3.\n\t • Support architecture: AMD,ARM and s390x\n"
C[2]="本项目专为 VPS 添加 Argo 隧道及 Xray,详细说明: [https://github.com/fscarmen/argox]\n 脚本特点:\n\t • 允许通过 Token, Json 及 临时方式来创建 Argo 隧道,用户通过以下网站轻松获取 json: https://fscarmen.cloudflare.now.cc\n\t • 极速安装方式,大大节省用户时间\n\t • 智能判断操作系统: Ubuntu 、Debian 、CentOS 、Alpine 和 Arch Linux,请务必选择 LTS 系统\n\t • 支持硬件结构类型: AMD 和 ARM\n"
E[3]="Input errors up to 5 times.The script is aborted."
C[3]="输入错误达5次,脚本退出"
E[4]="UUID should be 36 characters, please re-enter \(\${a} times remaining\)"
C[4]="UUID 应为36位字符,请重新输入 \(剩余\${a}次\)"
E[5]="The script supports Debian, Ubuntu, CentOS, Alpine or Arch systems only. Feedback: [https://github.com/fscarmen/argox/issues]"
C[5]="本脚本只支持 Debian、Ubuntu、CentOS、Alpine 或 Arch 系统,问题反馈:[https://github.com/fscarmen/argox/issues]"
E[6]="Curren operating system is \$SYS.\\\n The system lower than \$SYSTEM \${MAJOR[int]} is not supported. Feedback: [https://github.com/fscarmen/argox/issues]"
C[6]="当前操作是 \$SYS\\\n 不支持 \$SYSTEM \${MAJOR[int]} 以下系统,问题反馈:[https://github.com/fscarmen/argox/issues]"
E[7]="Install dependence-list:"
C[7]="安装依赖列表:"
E[8]="All dependencies already exist and do not need to be installed additionally."
C[8]="所有依赖已存在，不需要额外安装"
E[9]="To upgrade, press [y]. No upgrade by default:"
C[9]="升级请按 [y]，默认不升级:"
E[10]="(3/8) Please enter Argo Domain (Default is temporary domain if left blank):"
C[10]="(3/8) 请输入 Argo 域名 (如果没有，可以跳过以使用 Argo 临时域名):"
E[11]="Please enter Argo Token or Json ( User can easily obtain the json at https://fscarmen.cloudflare.now.cc ):"
C[11]="请输入 Argo Token 或者 Json ( 用户通过以下网站轻松获取 json: https://fscarmen.cloudflare.now.cc ):"
E[12]="\(6/8\) Please enter Xray UUID \(Default is \$UUID_DEFAULT\):"
C[12]="\(6/8\) 请输入 Xray UUID \(默认为 \$UUID_DEFAULT\):"
E[13]="\(7/8\) Please enter Xray WS Path \(Default is \$WS_PATH_DEFAULT\):"
C[13]="\(7/8\) 请输入 Xray WS 路径 \(默认为 \$WS_PATH_DEFAULT\):"
E[14]="Xray WS Path only allow uppercase and lowercase letters and numeric characters, please re-enter \(\${a} times remaining\):"
C[14]="Xray WS 路径只允许英文大小写及数字字符，请重新输入 \(剩余\${a}次\):"
E[15]="ArgoX script has not been installed yet."
C[15]="ArgoX 脚本还没有安装"
E[16]="ArgoX is completely uninstalled."
C[16]="ArgoX 已彻底卸载"
E[17]="Version"
C[17]="脚本版本"
E[18]="New features"
C[18]="功能新增"
E[19]="System infomation"
C[19]="系统信息"
E[20]="Operating System"
C[20]="当前操作系统"
E[21]="Kernel"
C[21]="内核"
E[22]="Architecture"
C[22]="处理器架构"
E[23]="Virtualization"
C[23]="虚拟化"
E[24]="Choose:"
C[24]="请选择:"
E[25]="Curren architecture \$(uname -m) is not supported. Feedback: [https://github.com/fscarmen/argox/issues]"
C[25]="当前架构 \$(uname -m) 暂不支持,问题反馈:[https://github.com/fscarmen/argox/issues]"
E[26]="Not install"
C[26]="未安装"
E[27]="close"
C[27]="关闭"
E[28]="open"
C[28]="开启"
E[29]="View links (argox -n)"
C[29]="查看节点信息 (argox -n)"
E[30]="Change the Argo tunnel (argox -t)"
C[30]="更换 Argo 隧道 (argox -t)"
E[31]="Sync Argo and Xray to the latest version (argox -v)"
C[31]="同步 Argo 和 Xray 至最新版本 (argox -v)"
E[32]="Upgrade kernel, turn on BBR, change Linux system (argox -b)"
C[32]="升级内核、安装BBR、DD脚本 (argox -b)"
E[33]="Uninstall (argox -u)"
C[33]="卸载 (argox -u)"
E[34]="Install ArgoX script (argo + xray)"
C[34]="安装 ArgoX 脚本 (argo + xray)"
E[35]="Exit"
C[35]="退出"
E[36]="Please enter the correct number"
C[36]="请输入正确数字"
E[37]="successful"
C[37]="成功"
E[38]="failed"
C[38]="失败"
E[39]="ArgoX is not installed."
C[39]="ArgoX 未安装"
E[40]="Argo tunnel is: \$ARGO_TYPE\\\n The domain is: \$ARGO_DOMAIN"
C[40]="Argo 隧道类型为: \$ARGO_TYPE\\\n 域名是: \$ARGO_DOMAIN"
E[41]="Argo tunnel type:\n 1. Try\n 2. Token or Json"
C[41]="Argo 隧道类型:\n 1. Try\n 2. Token 或者 Json"
E[42]="\(5/8\) Please select or enter the preferred domain, the default is \${CDN_DOMAIN[0]}:"
C[42]="\(5/8\) 请选择或者填入优选域名，默认为 \${CDN_DOMAIN[0]}:"
E[43]="\$APP local verion: \$LOCAL.\\\t The newest verion: \$ONLINE"
C[43]="\$APP 本地版本: \$LOCAL.\\\t 最新版本: \$ONLINE"
E[44]="No upgrade required."
C[44]="不需要升级"
E[45]="Argo authentication message does not match the rules, neither Token nor Json, script exits. Feedback:[https://github.com/fscarmen/argox/issues]"
C[45]="Argo 认证信息不符合规则，既不是 Token，也是不是 Json，脚本退出，问题反馈:[https://github.com/fscarmen/argox/issues]"
E[46]="Connect"
C[46]="连接"
E[47]="The script must be run as root, you can enter sudo -i and then download and run again. Feedback:[https://github.com/fscarmen/argox/issues]"
C[47]="必须以root方式运行脚本，可以输入 sudo -i 后重新下载运行，问题反馈:[https://github.com/fscarmen/argox/issues]"
E[48]="Downloading the latest version \$APP failed, script exits. Feedback:[https://github.com/fscarmen/argox/issues]"
C[48]="下载最新版本 \$APP 失败，脚本退出，问题反馈:[https://github.com/fscarmen/argox/issues]"
E[49]="\(8/8\) Please enter the node name. \(Default is \${NODE_NAME_DEFAULT}\):"
C[49]="\(8/8\) 请输入节点名称 \(默认为 \${NODE_NAME_DEFAULT}\):"
E[50]="\${APP[@]} services are not enabled, node information cannot be output. Press [y] if you want to open."
C[50]="\${APP[@]} 服务未开启，不能输出节点信息。如需打开请按 [y]: "
E[52]="Memory Usage"
C[52]="内存占用"
E[53]="The xray service is detected to be installed. Script exits."
C[53]="检测到已安装 xray 服务，脚本退出!"
E[54]="Warp / warp-go was detected to be running. Please enter the correct server IP:"
C[54]="检测到 warp / warp-go 正在运行，请输入确认的服务器 IP:"
E[56]="\(4/8\) Please enter the Reality port \(Default is \${REALITY_PORT_DEFAULT}\):"
C[56]="\(4/8\) 请输入 Reality 的端口号 \(默认为 \${REALITY_PORT_DEFAULT}\):"
E[58]="No server ip, script exits. Feedback:[https://github.com/fscarmen/sing-box/issues]"
C[58]="没有 server ip，脚本退出，问题反馈:[https://github.com/fscarmen/sing-box/issues]"
E[59]="\(2/8\) Please enter VPS IP \(Default is: \${SERVER_IP_DEFAULT}\):"
C[59]="\(2/8\) 请输入 VPS IP \(默认为: \${SERVER_IP_DEFAULT}\):"
E[60]="Quicktunnel domain can be obtained from: http://\${SERVER_IP_1}:\${METRICS_PORT}/quicktunnel"
C[60]="临时隧道域名可以从以下网站获取: http://\${SERVER_IP_1}:\${METRICS_PORT}/quicktunnel"
E[61]="Ports are in used: \$REALITY_PORT"
C[61]="正在使用中的端口: \$REALITY_PORT"
E[62]="Create shortcut [ argox ] successfully."
C[62]="创建快捷 [ argox ] 指令成功!"

# 自定义字体彩色，read 函数
warning() { echo -e "\033[31m\033[01m$*\033[0m"; }  # 红色
error() { echo -e "\033[31m\033[01m$*\033[0m" && exit 1; } # 红色
info() { echo -e "\033[32m\033[01m$*\033[0m"; }   # 绿色
hint() { echo -e "\033[33m\033[01m$*\033[0m"; }   # 黄色
reading() { read -rp "$(info "$1")" "$2"; }
text() { grep -q '\$' <<< "${E[$*]}" && eval echo "\$(eval echo "\${${L}[$*]}")" || eval echo "\${${L}[$*]}"; }

# 选择中英语言
select_language() {
  if [ -z "$L" ]; then
    case $(cat $WORK_DIR/language 2>&1) in
      E ) L=E ;;
      C ) L=C ;;
      * ) [ -z "$L" ] && L=E && hint "\n $(text 0) \n" && reading " $(text 24) " LANGUAGE
      [ "$LANGUAGE" = 2 ] && L=C ;;
    esac
  fi
}

# 只允许 root 用户安装脚本
check_root() {
  [ "$(id -u)" != 0 ] && error "\n $(text 47) \n"
}

# 判断处理器架构
check_arch() {
  case $(uname -m) in
    aarch64|arm64 )
      ARGO_ARCH=arm64; XRAY_ARCH=arm64-v8a
      ;;
    x86_64|amd64 )
      ARGO_ARCH=amd64; XRAY_ARCH=64
      ;;
    armv7l )
      ARGO_ARCH=arm; XRAY_ARCH=arm32-v7a
      ;;
    * )
      error " $(text 25) "
  esac
}

# 查安装及运行状态，下标0: argo，下标1: xray；状态码: 26 未安装， 27 已安装未运行， 28 运行中
check_install() {
  STATUS[0]=$(text 26) && [[ -s /etc/systemd/system/argo.service ]] && grep -q "^ExecStart=$WORK_DIR" /etc/systemd/system/argo.service && STATUS[0]=$(text 27) && [ "$(systemctl is-active argo)" = 'active' ] && STATUS[0]=$(text 28)
  STATUS[1]=$(text 26)
  # xray systemd 文件存在的话，检测一下是否本脚本安装的，如果不是则提示并提出
  if [ -s /etc/systemd/system/xray.service ]; then
    ! grep -q "$WORK_DIR" /etc/systemd/system/xray.service && error " $(text 53)\n $(grep 'ExecStart=' /etc/systemd/system/xray.service) "
    STATUS[1]=$(text 27) && [ "$(systemctl is-active xray)" = 'active' ] && STATUS[1]=$(text 28)
  fi
  [[ ${STATUS[0]} = "$(text 26)" ]] && [ ! -s $WORK_DIR/cloudflared ] && { wget --no-check-certificate -qO $TEMP_DIR/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$ARGO_ARCH >/dev/null 2>&1 && chmod +x $TEMP_DIR/cloudflared >/dev/null 2>&1; }&
  [[ ${STATUS[1]} = "$(text 26)" ]] && [ ! -s $WORK_DIR/xray ] && { wget --no-check-certificate -qO $TEMP_DIR/Xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-$XRAY_ARCH.zip >/dev/null 2>&1; unzip -qo $TEMP_DIR/Xray.zip xray *.dat -d $TEMP_DIR >/dev/null 2>&1; }&
}

# 为了适配 alpine，定义 cmd_systemctl 的函数
cmd_systemctl() {
  local ENABLE_DISABLE=$1
  local APP=$2
  if [ "$ENABLE_DISABLE" = 'enable' ]; then
    if [ "$SYSTEM" = 'Alpine' ]; then
      systemctl start $APP
      cat > /etc/local.d/$APP.start << EOF
#!/usr/bin/env bash

systemctl start $APP
EOF
      chmod +x /etc/local.d/$APP.start
      rc-update add local >/dev/null 2>&1
    else
      systemctl enable --now $APP
    fi
  elif [ "$ENABLE_DISABLE" = 'disable' ]; then
    if [ "$SYSTEM" = 'Alpine' ]; then
      systemctl stop $APP
      rm -f /etc/local.d/$APP.start
    else
      systemctl disable --now $APP
    fi
  fi
}

check_system_info() {
  # 判断虚拟化
  if [ -x "$(type -p systemd-detect-virt)" ]; then
    VIRT=$(systemd-detect-virt)
  elif [ -x "$(type -p hostnamectl)" ]; then
    VIRT=$(hostnamectl | awk '/Virtualization/{print $NF}')
  elif [ -x "$(type -p virt-what)" ]; then
    VIRT=$(virt-what)
  fi

  [ -s /etc/os-release ] && SYS="$(awk -F '"' 'tolower($0) ~ /pretty_name/{print $2}' /etc/os-release)"
  [[ -z "$SYS" && -x "$(type -p hostnamectl)" ]] && SYS="$(hostnamectl | awk -F ': ' 'tolower($0) ~ /operating system/{print $2}')"
  [[ -z "$SYS" && -x "$(type -p lsb_release)" ]] && SYS="$(lsb_release -sd)"
  [[ -z "$SYS" && -s /etc/lsb-release ]] && SYS="$(awk -F '"' 'tolower($0) ~ /distrib_description/{print $2}' /etc/lsb-release)"
  [[ -z "$SYS" && -s /etc/redhat-release ]] && SYS="$(cat /etc/redhat-release)"
  [[ -z "$SYS" && -s /etc/issue ]] && SYS="$(sed -E '/^$|^\\/d' /etc/issue | awk -F '\\' '{print $1}' | sed 's/[ ]*$//g')"

  REGEX=("debian" "ubuntu" "centos|red hat|kernel|alma|rocky" "arch linux" "alpine" "fedora")
  RELEASE=("Debian" "Ubuntu" "CentOS" "Arch" "Alpine" "Fedora")
  EXCLUDE=("---")
  MAJOR=("9" "16" "7" "" "" "37")
  PACKAGE_UPDATE=("apt -y update" "apt -y update" "yum -y update" "pacman -Sy" "apk update -f" "dnf -y update")
  PACKAGE_INSTALL=("apt -y install" "apt -y install" "yum -y install" "pacman -S --noconfirm" "apk add --no-cache" "dnf -y install")
  PACKAGE_UNINSTALL=("apt -y autoremove" "apt -y autoremove" "yum -y autoremove" "pacman -Rcnsu --noconfirm" "apk del -f" "dnf -y autoremove")

  for int in "${!REGEX[@]}"; do
    [[ "${SYS,,}" =~ ${REGEX[int]} ]] && SYSTEM="${RELEASE[int]}" && break
  done
  [ -z "$SYSTEM" ] && error " $(text 5) "

  # 针对各厂商的订制系统
  if [ -z "$SYSTEM" ]; then
    [ -x "$(type -p yum)" ] && int=2 && SYSTEM='CentOS' || error " $(text 5) "
  fi

  # 先排除 EXCLUDE 里包括的特定系统，其他系统需要作大发行版本的比较
  for ex in "${EXCLUDE[@]}"; do [[ ! "{$SYS,,}" =~ $ex ]]; done &&
  [[ "$(echo "$SYS" | sed "s/[^0-9.]//g" | cut -d. -f1)" -lt "${MAJOR[int]}" ]] && error " $(text 6) "

  # 针对部分系统作特殊处理
  [ "$SYSTEM" = 'CentOS' ] && IS_CENTOS="CentOS$(echo "$SYS" | sed "s/[^0-9.]//g" | cut -d. -f1)"
}

# 检测 IPv4 IPv6 信息
check_system_ip() {
  [ "$L" = 'C' ] && local IS_CHINESE='?lang=zh-CN'
  local DEFAULT_LOCAL_INTERFACE4=$(ip -4 route show default | awk '/default/ {for (i=0; i<NF; i++) if ($i=="dev") {print $(i+1); exit}}')
  local DEFAULT_LOCAL_INTERFACE6=$(ip -6 route show default | awk '/default/ {for (i=0; i<NF; i++) if ($i=="dev") {print $(i+1); exit}}')
  if [ -n "${DEFAULT_LOCAL_INTERFACE4}${DEFAULT_LOCAL_INTERFACE6}" ]; then
    local DEFAULT_LOCAL_IP4=$(ip -4 addr show $DEFAULT_LOCAL_INTERFACE4 | sed -n 's#.*inet \([^/]\+\)/[0-9]\+.*global.*#\1#gp')
    local DEFAULT_LOCAL_IP6=$(ip -6 addr show $DEFAULT_LOCAL_INTERFACE6 | sed -n 's#.*inet6 \([^/]\+\)/[0-9]\+.*global.*#\1#gp')
    [ -n "$DEFAULT_LOCAL_IP4" ] && local BIND_ADDRESS4="--bind-address=$DEFAULT_LOCAL_IP4"
    [ -n "$DEFAULT_LOCAL_IP6" ] && local BIND_ADDRESS6="--bind-address=$DEFAULT_LOCAL_IP6"
  fi

  WAN4=$(wget $BIND_ADDRESS4 -qO- --no-check-certificate --tries=2 --timeout=2 http://api-ipv4.ip.sb)
  [ -n "$WAN4" ] && local IP4_JSON=$(wget -qO- --no-check-certificate --tries=2 --timeout=2 https://ip.forvps.gq/${WAN4}${IS_CHINESE}) &&
  COUNTRY4=$(sed -En 's/.*"country":[ ]*"([^"]+)".*/\1/p' <<< "$IP4_JSON") &&
  ASNORG4=$(sed -En 's/.*"(isp|asn_org)":[ ]*"([^"]+)".*/\2/p' <<< "$IP4_JSON")

  WAN6=$(wget $BIND_ADDRESS6 -qO- --no-check-certificate --tries=2 --timeout=2 http://api-ipv6.ip.sb)
  [ -n "$WAN6" ] && local IP6_JSON=$(wget -qO- --no-check-certificate --tries=2 --timeout=2 https://ip.forvps.gq/${WAN6}${IS_CHINESE}) &&
  COUNTRY6=$(sed -En 's/.*"country":[ ]*"([^"]+)".*/\1/p' <<< "$IP6_JSON") &&
  ASNORG6=$(sed -En 's/.*"(isp|asn_org)":[ ]*"([^"]+)".*/\2/p' <<< "$IP6_JSON")
}

# 定义 Argo 变量
argo_variable() {
  if grep -qi 'cloudflare' <<< "$ASNORG4$ASNORG6"; then
    local a=6
    until [ -n "$SERVER_IP" ]; do
      ((a--)) || true
      [ "$a" = 0 ] && error "\n $(text 3) \n"
      reading "\n $(text 54) " SERVER_IP
    done
  elif [ -n "$WAN4" ]; then
    SERVER_IP_DEFAULT=$WAN4
  elif [ -n "$WAN6" ]; then
    SERVER_IP_DEFAULT=$WAN6
  fi

  # 输入服务器 IP,默认为检测到的服务器 IP，如果全部为空，则提示并退出脚本
  [ -z "$SERVER_IP" ] && reading "\n $(text 59) " SERVER_IP
  SERVER_IP=${SERVER_IP:-"$SERVER_IP_DEFAULT"}
  [ -z "$SERVER_IP" ] && error " $(text 58) "

  # 处理可能输入的错误，去掉开头和结尾的空格，去掉最后的 :
  [ -z "$ARGO_DOMAIN" ] && reading "\n $(text 10) " ARGO_DOMAIN
  ARGO_DOMAIN=$(sed 's/[ ]*//g; s/:[ ]*//' <<< "$ARGO_DOMAIN")

  if [[ -n "$ARGO_DOMAIN" && -z "$ARGO_AUTH" ]]; then
    local a=5
    until [[ "$ARGO_AUTH" =~ TunnelSecret || "${ARGO_AUTH,,}" =~ ^[a-z0-9=]{120,250}$ || "${ARGO_AUTH,,}" =~ .*cloudflared.*service[[:space:]]+install[[:space:]]+[a-z0-9=]{1,100} ]]; do
      [ "$a" = 0 ] && error "\n $(text 3) \n" || reading "\n $(text 11) " ARGO_AUTH
      if [[ "$ARGO_AUTH" =~ TunnelSecret ]]; then
        ARGO_JSON=${ARGO_AUTH//[ ]/}
      elif [[ "${ARGO_AUTH,,}" =~ ^[a-z0-9=]{120,250}$ ]]; then
        ARGO_TOKEN=$ARGO_AUTH
      elif [[ "{$ARGO_AUTH,,}" =~ .*cloudflared.*service[[:space:]]+install[[:space:]]+[a-z0-9=]{1,100} ]]; then
        ARGO_TOKEN=$(awk -F ' ' '{print $NF}' <<< "$ARGO_AUTH")
      else
        warning "\n $(text 45) \n"
      fi
      ((a--)) || true
    done
  fi
}

# 定义 Xray 变量
xray_variable() {
  local a=6
  until [ -n "$REALITY_PORT" ]; do
    ((a--)) || true
    [ "$a" = 0 ] && error "\n $(text 3) \n"
    REALITY_PORT_DEFAULT=$(shuf -i 1000-65535 -n 1)
    reading "\n $(text 56) " REALITY_PORT
    REALITY_PORT=${REALITY_PORT:-"$REALITY_PORT_DEFAULT"}
    ss -nltup | grep -q ":$REALITY_PORT" && warning "\n $(text 61) \n" && unset REALITY_PORT
  done

  # 提供网上热心网友的anycast域名
  if [ -z "$SERVER" ]; then
    echo ""
    for c in "${!CDN_DOMAIN[@]}"; do
      hint " $[c+1]. ${CDN_DOMAIN[c]} "
    done

    reading "\n $(text 42) " CUSTOM_CDN
    case "$CUSTOM_CDN" in
      [1-${#CDN_DOMAIN[@]}] )
        SERVER="${CDN_DOMAIN[$((CUSTOM_CDN-1))]}"
      ;;
      ?????* )
        SERVER="$CUSTOM_CDN"
      ;;
      * )
        SERVER="${CDN_DOMAIN[0]}"
    esac
  fi

  local a=6
  until [[ "${UUID,,}" =~ ^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$ ]]; do
    (( a-- )) || true
    [ "$a" = 0 ] && error "\n $(text 3) \n"
    UUID_DEFAULT=$(cat /proc/sys/kernel/random/uuid)
    reading "\n $(text 12) " UUID
    UUID=${UUID:-"$UUID_DEFAULT"}
    [[ ! "${UUID,,}" =~ ^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$ ]] && warning "\n $(text 4) "
  done

  [ -z "$WS_PATH" ] && reading "\n $(text 13) " WS_PATH
  local a=5
  until [[ -z "$WS_PATH" || "${WS_PATH,,}" =~ ^[a-z0-9]+$ ]]; do
    (( a-- )) || true
    [ "$a" = 0 ] && error " $(text 3) " || reading " $(text 14) " WS_PATH
  done
  WS_PATH=${WS_PATH:-"$WS_PATH_DEFAULT"}

  # 输入节点名，以系统的 hostname 作为默认
  if [ -z "$NODE_NAME" ]; then
    if [ -x "$(type -p hostname)" ]; then
      NODE_NAME_DEFAULT="$(hostname)"
    elif [ -s /etc/hostname ]; then
      NODE_NAME_DEFAULT="$(cat /etc/hostname)"
    else
      NODE_NAME_DEFAULT="ArgoX"
    fi
    reading "\n $(text 49) " NODE_NAME
    NODE_NAME="${NODE_NAME:-"$NODE_NAME_DEFAULT"}"
  fi
}

check_dependencies() {
  # 如果是 Alpine，先升级 wget ，安装 systemctl-py 版
  if [ "$SYSTEM" = 'Alpine' ]; then
    local CHECK_WGET=$(wget 2>&1 | head -n 1)
    grep -qi 'busybox' <<< "$CHECK_WGET" && ${PACKAGE_INSTALL[int]} wget >/dev/null 2>&1

    local DEPS_CHECK=("bash" "rc-update" "virt-what" "python3")
    local DEPS_INSTALL=("bash" "openrc" "virt-what" "python3")
    for g in "${!DEPS_CHECK[@]}"; do
      [ ! -x "$(type -p ${DEPS_CHECK[g]})" ] && DEPS_ALPINE+=(${DEPS_INSTALL[g]})
    done
    if [ "${#DEPS_ALPINE[@]}" -ge 1 ]; then
      info "\n $(text 7) $(sed "s/ /,&/g" <<< ${DEPS_ALPINE[@]}) \n"
      ${PACKAGE_UPDATE[int]} >/dev/null 2>&1
      ${PACKAGE_INSTALL[int]} ${DEPS_ALPINE[@]} >/dev/null 2>&1
      [[ -z "$VIRT" && "${DEPS_ALPINE[@]}" =~ 'virt-what' ]] && VIRT=$(virt-what | tr '\n' ' ')
    fi

    [ ! -x "$(type -p systemctl)" ] && wget --no-check-certificate --quiet https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py -O /bin/systemctl && chmod a+x /bin/systemctl
  fi

  # 检测 Linux 系统的依赖，升级库并重新安装依赖
  local DEPS_CHECK=("wget" "systemctl" "ss" "unzip" "bash")
  local DEPS_INSTALL=("wget" "systemctl" "iproute2" "unzip" "bash")
  for g in "${!DEPS_CHECK[@]}"; do
    [ ! -x "$(type -p ${DEPS_CHECK[g]})" ] && DEPS+=(${DEPS_INSTALL[g]})
  done
  if [ "${#DEPS[@]}" -ge 1 ]; then
    info "\n $(text 7) $(sed "s/ /,&/g" <<< ${DEPS[@]}) \n"
    [ "$SYSTEM" != 'CentOS' ] && ${PACKAGE_UPDATE[int]} >/dev/null 2>&1
    ${PACKAGE_INSTALL[int]} ${DEPS[@]} >/dev/null 2>&1
  else
    info "\n $(text 8) \n"
  fi
}

install_argox() {
  argo_variable
  xray_variable
  wait

  # 生成 reality 的公私钥
  [[ -z "$REALITY_PRIVATE" || -z "$REALITY_PUBLIC" ]] && REALITY_KEYPAIR=$($TEMP_DIR/xray x25519)
  [ -z "$REALITY_PRIVATE" ] && REALITY_PRIVATE=$(awk '/Private/{print $NF}' <<< "$REALITY_KEYPAIR")
  [ -z "$REALITY_PUBLIC" ] && REALITY_PUBLIC=$(awk '/Public/{print $NF}' <<< "$REALITY_KEYPAIR")

  [ ! -d /etc/systemd/system ] && mkdir -p /etc/systemd/system
  mkdir -p $WORK_DIR && echo "$L" > $WORK_DIR/language
  [ -s "$VARIABLE_FILE" ] && cp $VARIABLE_FILE $WORK_DIR/

  wait
  [[ ! -s $WORK_DIR/cloudflared && -x $TEMP_DIR/cloudflared ]] && mv $TEMP_DIR/cloudflared $WORK_DIR
  if [[ -n "${ARGO_JSON}" && -n "${ARGO_DOMAIN}" ]]; then
    ARGO_RUNS="$WORK_DIR/cloudflared tunnel --edge-ip-version auto --config $WORK_DIR/tunnel.yml run"
    json_argo
  elif [[ -n "${ARGO_TOKEN}" && -n "${ARGO_DOMAIN}" ]]; then
    ARGO_RUNS="$WORK_DIR/cloudflared tunnel --edge-ip-version auto run --token ${ARGO_TOKEN}"
  else
    ARGO_RUNS="$WORK_DIR/cloudflared tunnel --edge-ip-version auto --no-autoupdate --metrics 0.0.0.0:${METRICS_PORT} --url http://localhost:8080"
  fi

  # Argo 生成守护进程文件
  local ARGO_SERVER="[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
Type=simple
NoNewPrivileges=yes
TimeoutStartSec=0
ExecStart=$ARGO_RUNS
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target"

  echo "$ARGO_SERVER" > /etc/systemd/system/argo.service

  # 生成配置文件及守护进程文件
  local i=1
  [ ! -s $WORK_DIR/xray ] && wait && while [ "$i" -le 20 ]; do [[ -s $TEMP_DIR/xray && -s $TEMP_DIR/geoip.dat && -s $TEMP_DIR/geosite.dat ]] && mv $TEMP_DIR/xray $TEMP_DIR/geo*.dat $WORK_DIR && break; ((i++)); sleep 2; done
  [ "$i" -ge 20 ] && local APP=Xray && error "\n $(text 48) "
  cat > $WORK_DIR/inbound.json << EOF
//  "SERVER_IP":"${SERVER_IP}"
//  "REALITY_PUBLIC":"${REALITY_PUBLIC}"
//  "SERVER":"${SERVER}"
{
    "log":{
        "access":"/dev/null",
        "error":"/dev/null",
        "loglevel":"none"
    },
    "inbounds":[
      {
            "tag":"${NODE_NAME} reality-vision",
            "protocol":"vless",
            "port":${REALITY_PORT},
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "flow":"xtls-rprx-vision"
                    }
                ],
                "decryption":"none",
                "fallbacks":[
                    {
                        "dest":"3001",
                        "xver":1
                    }
                ]
            },
            "streamSettings":{
                "network":"tcp",
                "security":"reality",
                "realitySettings":{
                    "show":true,
                    "dest":"${TLS_SERVER}:443",
                    "xver":0,
                    "serverNames":[
                        "${TLS_SERVER}"
                    ],
                    "privateKey":"${REALITY_PRIVATE}",
                    "publicKey":"${REALITY_PUBLIC}",
                    "maxTimeDiff":70000,
                    "shortIds":[
                        ""
                    ]
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls"
                ]
            }
        },
        {
            "port":3001,
            "listen":"127.0.0.1",
            "protocol":"vless",
            "tag":"${NODE_NAME} reality-grpc",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "flow":""
                    }
                ],
                "decryption":"none"
            },
            "streamSettings":{
                "network":"grpc",
                "grpcSettings":{
                    "serviceName":"grpc",
                    "multiMode":true
                },
                "sockopt":{
                    "acceptProxyProtocol":true
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls"
                ]
            }
        },
        {
            "listen":"127.0.0.1",
            "port":8080,
            "protocol":"vless",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "flow":"xtls-rprx-vision"
                    }
                ],
                "decryption":"none",
                "fallbacks":[
                    {
                        "path":"/${WS_PATH}-vl",
                        "dest":3002
                    },
                    {
                        "path":"/${WS_PATH}-vm",
                        "dest":3003
                    },
                    {
                        "path":"/${WS_PATH}-tr",
                        "dest":3004
                    },
                    {
                        "path":"/${WS_PATH}-sh",
                        "dest":3005
                    }
                ]
            },
            "streamSettings":{
                "network":"tcp"
            }
        },
        {
            "port":3002,
            "listen":"127.0.0.1",
            "protocol":"vless",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "level":0
                    }
                ],
                "decryption":"none"
            },
            "streamSettings":{
                "network":"ws",
                "security":"none",
                "wsSettings":{
                    "path":"/${WS_PATH}-vl"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":3003,
            "listen":"127.0.0.1",
            "protocol":"vmess",
            "settings":{
                "clients":[
                    {
                        "id":"${UUID}",
                        "alterId":0
                    }
                ]
            },
            "streamSettings":{
                "network":"ws",
                "wsSettings":{
                    "path":"/${WS_PATH}-vm"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":3004,
            "listen":"127.0.0.1",
            "protocol":"trojan",
            "settings":{
                "clients":[
                    {
                        "password":"${UUID}"
                    }
                ]
            },
            "streamSettings":{
                "network":"ws",
                "security":"none",
                "wsSettings":{
                    "path":"/${WS_PATH}-tr"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        },
        {
            "port":3005,
            "listen":"127.0.0.1",
            "protocol":"shadowsocks",
            "settings":{
                "clients":[
                    {
                        "method":"chacha20-ietf-poly1305",
                        "password":"${UUID}"
                    }
                ],
                "decryption":"none"
            },
            "streamSettings":{
                "network":"ws",
                "wsSettings":{
                    "path":"/${WS_PATH}-sh"
                }
            },
            "sniffing":{
                "enabled":true,
                "destOverride":[
                    "http",
                    "tls",
                    "quic"
                ],
                "metadataOnly":false
            }
        }
    ],
    "dns":{
        "servers":[
            "https+local://8.8.8.8/dns-query"
        ]
    }
}
EOF
  cat > $WORK_DIR/outbound.json << EOF
{
    "outbounds":[
        {
            "protocol":"freedom",
            "tag":"direct"
        },
        {
            "protocol":"blackhole",
            "settings":{

            },
            "tag":"block"
        }
    ],
    "routing":{
        "domainStrategy":"AsIs"
    }
}
EOF

  cat > /etc/systemd/system/xray.service << EOF
[Unit]
Description=Xray Service
Documentation=https://github.com/XTLS/Xray-core
After=network.target nss-lookup.target
Wants=network-online.target

[Service]
Type=simple
NoNewPrivileges=yes
ExecStart=$WORK_DIR/xray run -confdir $WORK_DIR/
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
EOF

  # 再次检测状态，运行 Argo 和 Xray
  check_install
  case "${STATUS[0]}" in
    "$(text 26)" )
      warning "\n Argo $(text 28) $(text 38) \n"
      ;;
    "$(text 27)" )
      cmd_systemctl enable argo && info "\n Argo $(text 28) $(text 37) \n"
      ;;
    "$(text 28)" )
      info "\n Argo $(text 28) $(text 37) \n"
  esac

  case "${STATUS[1]}" in
    "$(text 26)" )
      warning "\n Xray $(text 28) $(text 38) \n"
      ;;
    "$(text 27)" )
      cmd_systemctl enable xray && info "\n Xray $(text 28) $(text 37) \n"
      ;;
    "$(text 28)" )
      info "\n Xray $(text 28) $(text 37) \n"
  esac
}

# Json 生成 Argo 配置文件
json_argo() {
  [ ! -s $WORK_DIR/tunnel.json ] && echo $ARGO_JSON > $WORK_DIR/tunnel.json
  [ ! -s $WORK_DIR/tunnel.yml ] && cat > $WORK_DIR/tunnel.yml << EOF
tunnel: $(cut -d\" -f12 <<< $ARGO_JSON)
credentials-file: $WORK_DIR/tunnel.json

ingress:
  - hostname: ${ARGO_DOMAIN}
    service: http://localhost:8080
  - service: http_status:404
EOF
}

# 创建快捷方式
create_shortcut() {
  cat > $WORK_DIR/ax.sh << EOF
#!/usr/bin/env bash

bash <(wget --no-check-certificate -qO- https://raw.githubusercontent.com/fscarmen/argox/main/argox.sh) \$1
EOF
  chmod +x $WORK_DIR/ax.sh
  ln -sf $WORK_DIR/ax.sh /usr/bin/argox
  [ -s /usr/bin/argox ] && hint "\n $(text 62) "
}

export_list() {
  check_install

  # 没有开启 Argo 和 Xray 服务，将不输出节点信息
  local APP
  [ "${STATUS[0]}" != "$(text 28)" ] && APP+=(Argo)
  [ "${STATUS[1]}" != "$(text 28)" ] && APP+=(Xray)
  if [ "${#APP[@]}" -gt 0 ]; then
    reading "\n $(text 50) " OPEN_APP
    if [ "${OPEN_APP,,}" = 'y' ]; then
      [ "${STATUS[0]}" != "$(text 28)" ] && cmd_systemctl enable argo
      [ "${STATUS[1]}" != "$(text 28)" ] && cmd_systemctl enable xray
    else
      exit
    fi
  fi

  if grep -q "^ExecStart=.*8080$" /etc/systemd/system/argo.service; then
    local a=5
    until [[ -n "$ARGO_DOMAIN" || "$a" = 0 ]]; do
      sleep 2
      ARGO_DOMAIN=$(wget -qO- http://localhost:$(ps -ef | awk -F '0.0.0.0:' '/cloudflared.*:8080/{print $2}' | awk 'NR==1 {print $1}')/quicktunnel | awk -F '"' '{print $4}')
      ((a--)) || true
    done
  else
    ARGO_DOMAIN=${ARGO_DOMAIN:-"$(grep -m1 '^vless.*host=.*' $WORK_DIR/list | sed "s@.*host=\(.*\)&.*@\1@g")"}
  fi
  JSON=$(cat $WORK_DIR/*inbound*.json)
  SERVER_IP=${SERVER_IP:-"$(awk -F '"' '/"SERVER_IP"/{print $4; exit}' <<< "$JSON")"}
  REALITY_PORT=${REALITY_PORT:-"$(awk -F '[:,]' '/"port"/{print $2; exit}' <<< "$JSON")"}
  REALITY_PUBLIC=${REALITY_PUBLIC:-"$(awk -F '"' '/"publicKey"/{print $4; exit}' <<< "$JSON")"}
  SERVER=${SERVER:-"$(awk -F '"' '/"SERVER"/{print $4; exit}' <<< "$JSON")"}
  UUID=${UUID:-"$(awk -F '"' '/"password"/{print $4; exit}' <<< "$JSON")"}
  WS_PATH=${WS_PATH:-"$(expr "$JSON" : '.*path":"/\(.*\)-vl.*')"}
  NODE_NAME=${NODE_NAME:-"$(sed -n 's/.*tag":"\(.*\) reality-vision.*/\1/gp' <<< "$JSON")"}

  # IPv6 时的 IP 处理
  if [[ "$SERVER_IP" =~ : ]]; then
    SERVER_IP_1="[$SERVER_IP]"
  else
    SERVER_IP_1="$SERVER_IP"
  fi

  # 若为临时隧道，处理查询方法
  grep -q 'metrics.*url' /etc/systemd/system/argo.service && QUICK_TUNNEL_URL=$(text 60)

  # 生成 vmess 文件
  VMESS="{ \"v\": \"2\", \"ps\": \"${NODE_NAME}-Vm\", \"add\": \"${SERVER}\", \"port\": \"443\", \"id\": \"${UUID}\", \"aid\": \"0\", \"scy\": \"none\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"${ARGO_DOMAIN}\", \"path\": \"/${WS_PATH}-vm?ed=2048\", \"tls\": \"tls\", \"sni\": \"${ARGO_DOMAIN}\", \"alpn\": \"\" }"

  # 生成客户端配置文件
  EXPORT_LIST_FILE="*******************************************
┌────────────────┐  ┌────────────────┐
│                │  │                │
│     $(warning "V2rayN")     │  │    $(warning "NekoBox")     │
│                │  │                │
└────────────────┘  └────────────────┘
----------------------------
$(info "vless://${UUID}@${SERVER_IP_1}:${REALITY_PORT}?encryption=none&flow=xtls-rprx-vision&security=reality&sni=${TLS_SERVER}&fp=chrome&pbk=${REALITY_PUBLIC}&type=tcp&headerType=none#${NODE_NAME} reality-vision
vless://${UUID}@${SERVER_IP_1}:${REALITY_PORT}?security=reality&sni=${TLS_SERVER}&fp=chrome&pbk=${REALITY_PUBLIC}&type=grpc&serviceName=grpc&encryption=none#${NODE_NAME} reality-grpc
vless://${UUID}@${SERVER}:443?encryption=none&security=tls&sni=${ARGO_DOMAIN}&type=ws&host=${ARGO_DOMAIN}&path=%2F${WS_PATH}-vl%3Fed%3D2048#${NODE_NAME}-Vl
vmess://$(echo -n "$VMESS" | base64 -w0)
trojan://${UUID}@${SERVER}:443?security=tls&sni=${ARGO_DOMAIN}&type=ws&host=${ARGO_DOMAIN}&path=/${WS_PATH}-tr?ed%3D2048#${NODE_NAME}-Tr
ss://$(echo -n "chacha20-ietf-poly1305:${UUID}" | base64 -w0)@${SERVER}:443#${NODE_NAME}-Sh
由于该软件导出的链接不全，请自行处理如下: 传输协议: WS , 伪装域名: ${ARGO_DOMAIN} , 路径: /${WS_PATH}-sh?ed=2048 , 传输层安全: tls , sni: ${ARGO_DOMAIN}")
*******************************************
$(info "\n ${QUICK_TUNNEL_URL} ")
"
  # 生成并显示节点信息
  echo "$EXPORT_LIST_FILE" > $WORK_DIR/list
  cat $WORK_DIR/list
}

# 更换 Argo 隧道类型
change_argo() {
  check_install
  [[ ${STATUS[0]} = "$(text 26)" ]] && error " $(text 39) "

  case $(grep "ExecStart=" /etc/systemd/system/argo.service) in
    *--config* )
      ARGO_TYPE='Json'; ARGO_DOMAIN="$(grep -m1 '^vless' $WORK_DIR/list | sed "s@.*host=\(.*\)&.*@\1@g")" ;;
    *--token* )
      ARGO_TYPE='Token'; ARGO_DOMAIN="$(grep -m1 '^vless' $WORK_DIR/list | sed "s@.*host=\(.*\)&.*@\1@g")" ;;
    * )
      ARGO_TYPE='Try'; ARGO_DOMAIN=$(wget -qO- http://localhost:$(ps -ef | awk -F '0.0.0.0:' '/cloudflared.*:8080/{print $2}' | awk 'NR==1 {print $1}')/quicktunnel | awk -F '"' '{print $4}')
  esac

  hint "\n $(text 40) \n"
  unset ARGO_DOMAIN
  hint " $(text 41) \n" && reading " $(text 24) " CHANGE_TO
    case "$CHANGE_TO" in
      1 )
        cmd_systemctl disable argo
        [ -s $WORK_DIR/tunnel.json ] && rm -f $WORK_DIR/tunnel.{json,yml}
        sed -i "s@ExecStart=.*@ExecStart=$WORK_DIR/cloudflared tunnel --edge-ip-version auto --no-autoupdate --metrics 0.0.0.0:${METRICS_PORT} --url http://localhost:8080@g" /etc/systemd/system/argo.service
        ;;
      2 )
        SERVER_IP=$(awk -F '"' '/"SERVER_IP"/{print $4}' $WORK_DIR/*inbound*.json)
        argo_variable
        cmd_systemctl disable argo
        if [ -n "$ARGO_TOKEN" ]; then
          [ -s $WORK_DIR/tunnel.json ] && rm -f $WORK_DIR/tunnel.{json,yml}
          sed -i "s@ExecStart=.*@ExecStart=$WORK_DIR/cloudflared tunnel --edge-ip-version auto run --token ${ARGO_TOKEN}@g" /etc/systemd/system/argo.service
        elif [ -n "$ARGO_JSON" ]; then
          [ -s $WORK_DIR/tunnel.json ] && rm -f $WORK_DIR/tunnel.{json,yml}
          json_argo
          sed -i "s@ExecStart=.*@ExecStart=$WORK_DIR/cloudflared tunnel --edge-ip-version auto --config $WORK_DIR/tunnel.yml run@g" /etc/systemd/system/argo.service
        fi
        ;;
      * )
        exit 0
    esac

    cmd_systemctl enable argo
    export_list
}

# 卸载 ArgoX
uninstall() {
  if [ -d $WORK_DIR ]; then
    cmd_systemctl disable argo
    cmd_systemctl disable xray
    rm -rf $WORK_DIR $TEMP_DIR /etc/systemd/system/{xray,argo}.service /usr/bin/argox
    info "\n $(text 16) \n"
  else
    error "\n $(text 15) \n"
  fi

  # 如果 Alpine 系统，删除开机自启动和python3版systemd
  if [ "$SYSTEM" = 'Alpine' ]; then
    rm -f /etc/local.d/argo.start /etc/local.d/xray.start
    rc-update add local >/dev/null 2>&1
    [ ! -s /etc/systemd/system/*.service ] && rm -f /bin/systemctl
  fi
}

# Argo 与 Xray 的最新版本
version() {
  # Argo 版本
  local ONLINE=$(wget --no-check-certificate -qO- "https://api.github.com/repos/cloudflare/cloudflared/releases/latest" | grep "tag_name" | cut -d \" -f4)
  local LOCAL=$($WORK_DIR/cloudflared -v | awk '{for (i=0; i<NF; i++) if ($i=="version") {print $(i+1)}}')
  local APP=ARGO && info "\n $(text 43) "
  [[ -n "$ONLINE" && "$ONLINE" != "$LOCAL" ]] && reading "\n $(text 9) " UPDATE[0] || info " $(text 44) "
  local ONLINE=$(wget --no-check-certificate -qO- "https://api.github.com/repos/XTLS/Xray-core/releases/latest" | grep "tag_name" | sed "s@.*\"v\(.*\)\",@\1@g")
  local LOCAL=$($WORK_DIR/xray version | awk '{for (i=0; i<NF; i++) if ($i=="Xray") {print $(i+1)}}')
  local APP=Xray && info "\n $(text 43) "
  [[ -n "$ONLINE" && "$ONLINE" != "$LOCAL" ]] && reading "\n $(text 9) " UPDATE[1] || info " $(text 44) "

  [[ "${UPDATE[*],,}" =~ y ]] && check_system_info
  if [ "${UPDATE[0],,}" = 'y' ]; then
    wget --no-check-certificate -O $TEMP_DIR/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$ARGO_ARCH
    if [ -s $TEMP_DIR/cloudflared ]; then
      cmd_systemctl disable argo
      chmod +x $TEMP_DIR/cloudflared && mv $TEMP_DIR/cloudflared $WORK_DIR/cloudflared
      cmd_systemctl enable argo && [ "$(systemctl is-active argo)" = 'active' ] && info " Argo $(text 28) $(text 37)" || error " Argo $(text 28) $(text 38) "
    else
      local APP=ARGO && error "\n $(text 48) "
    fi
  fi
  if [ "${UPDATE[1],,}" = 'y' ]; then
    wget --no-check-certificate -O $TEMP_DIR/Xray-linux-$XRAY_ARCH.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-$XRAY_ARCH.zip
    if [ -s $TEMP_DIR/Xray-linux-$XRAY_ARCH.zip ]; then
      cmd_systemctl disable xray
      unzip -qo $TEMP_DIR/Xray-linux-$XRAY_ARCH.zip xray *.dat -d $WORK_DIR; rm -f $TEMP_DIR/Xray*.zip
      cmd_systemctl enable xray && [ "$(systemctl is-active xray)" = 'active' ] && info " Xray $(text 28) $(text 37)" || error " Xray $(text 28) $(text 38) "
    else
      local APP=Xray && error "\n $(text 48) "
    fi
  fi
}

# 判断当前 Argo-X 的运行状态，并对应的给菜单和动作赋值
menu_setting() {
  if [[ "${STATUS[*]}" =~ $(text 27)|$(text 28) ]]; then
    if [ -s $WORK_DIR/cloudflared ]; then
      ARGO_VERSION=$($WORK_DIR/cloudflared -v | awk '{print $3}' | sed "s@^@Version: &@g")
      ss -nltp | grep -q '127\.0\.0\.1:.*"cloudflared"' && ARGO_CHECKHEALTH="$(text 46): $(wget -qO- http://localhost:$(ss -nltp | grep "pid=$(ps -ef | awk '/cloudflared.*:8080/{print $2}' | awk 'NR==1 {print $1}')," | awk '{print $4}' | sed "s/.*://")/healthcheck | sed "s/OK/$(text 37)/")"
    fi
    [ -s $WORK_DIR/xray ] && XRAY_VERSION=$($WORK_DIR/xray version | awk 'NR==1 {print $2}' | sed "s@^@Version: &@g")
    [ "$SYSTEM" = 'Alpine' ] && PS_LIST=$(ps -ef) || PS_LIST=$(ps -ef | awk '{ $1=""; sub(/^ */, ""); print $0 }')

    OPTION[1]="1.  $(text 29)"
    if [ ${STATUS[0]} = "$(text 28)" ]; then
      AEGO_MEMORY="$(text 52): $(awk '/VmRSS/{printf "%.1f\n", $2/1024}' /proc/$(awk '/\/etc\/argox\/cloudflared/{print $1}' <<< "$PS_LIST")/status) MB"
      OPTION[2]="2.  $(text 27) Argo (argox -a)"
    else
      OPTION[2]="2.  $(text 28) Argo (argox -a)"
    fi
    [ ${STATUS[1]} = "$(text 28)" ] && XRAY_MEMORY="$(text 52): $(awk '/VmRSS/{printf "%.1f\n", $2/1024}' /proc/$(awk '/\/etc\/argox\/xray.*\/etc\/argox/{print $1}' <<< "$PS_LIST")/status) MB" && OPTION[3]="3.  $(text 27) Xray (argox -x)" || OPTION[3]="3.  $(text 28) Xray (argox -x)"
    OPTION[4]="4.  $(text 30)"
    OPTION[5]="5.  $(text 31)"
    OPTION[6]="6.  $(text 32)"
    OPTION[7]="7.  $(text 33)"

    ACTION[1]() { export_list; exit 0; }
    [[ ${STATUS[0]} = "$(text 28)" ]] && ACTION[2]() { cmd_systemctl disable argo; [[ "$(systemctl is-active argo)" =~ 'inactive'|'unknown' ]] && info "\n Argo $(text 27) $(text 37)" || error " Argo $(text 27) $(text 38) "; } || ACTION[2]() { cmd_systemctl enable argo && [ "$(systemctl is-active argo)" = 'active' ] && info "\n Argo $(text 28) $(text 37)" || error " Argo $(text 28) $(text 38) "; }
    [[ ${STATUS[1]} = "$(text 28)" ]] && ACTION[3]() { cmd_systemctl disable xray; [[ "$(systemctl is-active xray)" =~ 'inactive'|'unknown' ]] && info "\n Xray $(text 27) $(text 37)" || error " Xray $(text 27) $(text 38) "; } || ACTION[3]() { cmd_systemctl enable xray && [ "$(systemctl is-active xray)" = 'active' ] && info "\n Xray $(text 28) $(text 37)" || error " Xray $(text 28) $(text 38) "; }
    ACTION[4]() { change_argo; exit; }
    ACTION[5]() { version; exit; }
    ACTION[6]() { bash <(wget --no-check-certificate -qO- https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh); exit; }
    ACTION[7]() { uninstall; exit; }

  else
    OPTION[1]="1.  $(text 34)"
    OPTION[2]="2.  $(text 32)"

    ACTION[1]() { install_argox; export_list; create_shortcut; exit; }
    ACTION[2]() { bash <(wget --no-check-certificate -qO- https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh); exit; }
  fi

  [ "${#OPTION[@]}" -ge '10' ] && OPTION[0]="0 .  $(text 35)" || OPTION[0]="0.  $(text 35)"
  ACTION[0]() { exit; }
}

menu() {
  clear
  echo -e "======================================================================================================================\n"
  info " $(text 17):$VERSION\n $(text 18):$(text 1)\n $(text 19):\n\t $(text 20):$SYS\n\t $(text 21):$(uname -r)\n\t $(text 22):$ARGO_ARCH\n\t $(text 23):$VIRT "
  info "\t IPv4: $WAN4 $COUNTRY4  $ASNORG4 "
  info "\t IPv6: $WAN6 $COUNTRY6  $ASNORG6 "
  info "\t Argo: ${STATUS[0]}\t $ARGO_VERSION\t $AEGO_MEMORY\t $ARGO_CHECKHEALTH\n\t Xray: ${STATUS[1]}\t $XRAY_VERSION\t\t $XRAY_MEMORY "
  echo -e "\n======================================================================================================================\n"
  for ((b=1;b<${#OPTION[*]};b++)); do hint " ${OPTION[b]} "; done
  hint " ${OPTION[0]} "
  reading "\n $(text 24) " CHOOSE

  # 输入必须是数字且少于等于最大可选项
  if grep -qE "^[0-9]$" <<< "$CHOOSE" && [ "$CHOOSE" -lt "${#OPTION[*]}" ]; then
    ACTION[$CHOOSE]
  else
    warning " $(text 36) [0-$((${#OPTION[*]}-1))] " && sleep 1 && menu
  fi
}

while getopts ":AaXxTtUuNnVvBbF:f:" OPTNAME; do
  case "${OPTNAME,,}" in
    a ) select_language; check_system_info; check_install; [ "${STATUS[0]}" = "$(text 28)" ] && { cmd_systemctl disable argo; [[ "$(systemctl is-active argo)" =~ 'inactive'|'unknown' ]] && info "\n Argo $(text 27) $(text 37)" || error " Argo $(text 27) $(text 38) "; } || { cmd_systemctl enable argo; [ "$(systemctl is-active argo)" = 'active' ] && info "\n Argo $(text 28) $(text 37)" || error " Argo $(text 28) $(text 38) "; } ; exit 0 ;;
    x ) select_language; check_system_info; check_install; [ "${STATUS[1]}" = "$(text 28)" ] && { cmd_systemctl disable xray; [[ "$(systemctl is-active xray)" =~ 'inactive'|'unknown' ]] && info "\n Xray $(text 27) $(text 37)" || error " Xray $(text 27) $(text 38) "; } || { cmd_systemctl enable xray; [ "$(systemctl is-active xray)" = 'active' ] && info "\n Xray $(text 28) $(text 37)" || error " Xray $(text 28) $(text 38) "; } ; exit 0 ;;
    t ) select_language; change_argo; exit 0 ;;
    u ) select_language; check_system_info; uninstall; exit 0;;
    n ) select_language; check_system_info; export_list; exit 0 ;;
    v ) select_language; check_arch; version; exit 0;;
    b ) select_language; bash <(wget --no-check-certificate -qO- "https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh"); exit ;;
    f ) VARIABLE_FILE=$OPTARG; . $VARIABLE_FILE ;;
  esac
done

select_language
check_root
check_arch
check_system_info
check_dependencies
check_system_ip
check_install
menu_setting
[ -z "$VARIABLE_FILE" ] && menu || ACTION[1]
