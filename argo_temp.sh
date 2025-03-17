#!/usr/bin/env bash

# 默认工作目录和临时目录
WORK_DIR='/etc/argox'
TEMP_DIR='/tmp/argox'
METRICS_PORT='80'

# 创建必要的目录
mkdir -p $WORK_DIR $TEMP_DIR

# 自定义字体彩色
warning() { echo -e "\033[31m\033[01m$*\033[0m"; }
info() { echo -e "\033[32m\033[01m$*\033[0m"; }
hint() { echo -e "\033[33m\033[01m$*\033[0m"; }
reading() { read -rp "$(info "$1")" "$2"; }

# 判断处理器架构
check_arch() {
  case $(uname -m) in
    aarch64|arm64 ) ARGO_ARCH=arm64 ;;
    x86_64|amd64 ) ARGO_ARCH=amd64 ;;
    armv7l ) ARGO_ARCH=arm ;;
    * ) echo "不支持的架构: $(uname -m)" && exit 1 ;;
  esac
}

# 下载 Cloudflared 二进制文件
download_cloudflared() {
  if [ ! -s $WORK_DIR/cloudflared ]; then
    wget -qO $TEMP_DIR/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-$ARGO_ARCH
    chmod +x $TEMP_DIR/cloudflared
    mv $TEMP_DIR/cloudflared $WORK_DIR/cloudflared
  fi
}

# 设置临时 Argo Tunnel 的服务
setup_argo_service() {
  cat > /etc/systemd/system/argo.service << EOF
[Unit]
Description=Cloudflare Temporary Argo Tunnel
After=network.target

[Service]
Type=simple
NoNewPrivileges=yes
TimeoutStartSec=0
ExecStart=$WORK_DIR/cloudflared tunnel --edge-ip-version auto --no-autoupdate --metrics 0.0.0.0:${METRICS_PORT} --url http://localhost:8080
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable --now argo
  [ "$(systemctl is-active argo)" = 'active' ] && info "临时 Argo Tunnel 启动成功" || warning "临时 Argo Tunnel 启动失败"
}

# 获取临时隧道域名
get_tunnel_domain() {
  local a=5
  until [[ -n "$ARGO_DOMAIN" || "$a" = 0 ]]; do
    sleep 2
    ARGO_DOMAIN=$(wget -qO- http://localhost:${METRICS_PORT}/quicktunnel | awk -F '"' '{print $4}')
    ((a--)) || true
  done
  if [ -n "$ARGO_DOMAIN" ]; then
    info "临时隧道域名: $ARGO_DOMAIN"
  else
    warning "无法获取临时隧道域名，请检查服务状态"
  fi
}

# 主函数
main() {
  check_arch
  download_cloudflared
  setup_argo_service
  get_tunnel_domain
}

main
