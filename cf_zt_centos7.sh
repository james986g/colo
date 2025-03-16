#!/bin/bash

# 一键脚本：配置或卸载 Cloudflare Zero Trust (CentOS 7)

# 定义颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 检查是否以 root 权限运行
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}请以 root 权限运行此脚本！${NC}"
  exit 1
fi

# 提供安装或卸载选项
echo -e "${GREEN}请选择操作：${NC}"
echo "1. 安装 Cloudflare Zero Trust"
echo "2. 卸载 Cloudflare Zero Trust"
read -p "输入选项 (1 或 2): " CHOICE

if [ "$CHOICE" == "1" ]; then
  # 安装功能
  echo -e "${GREEN}开始安装 Cloudflare Zero Trust...${NC}"

  # 获取用户输入
  echo -e "${GREEN}请输入你的 Cloudflare Zero Trust 隧道令牌 (Tunnel Token):${NC}"
  read -p "Tunnel Token: " TUNNEL_TOKEN
  echo -e "${GREEN}请输入你的 VPS 私有 IP 范围 (例如 192.168.1.0/24):${NC}"
  read -p "私有 IP 范围: " PRIVATE_IP_RANGE

  # 更新系统并安装必要工具
  echo -e "${GREEN}正在更新系统并安装依赖...${NC}"
  yum update -y
  yum install -y wget curl

  # 下载并安装 cloudflared
  echo -e "${GREEN}正在安装 Cloudflare cloudflared...${NC}"
  wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /usr/local/bin/cloudflared
  chmod +x /usr/local/bin/cloudflared

  # 验证安装
  if ! command -v cloudflared &> /dev/null; then
      echo -e "${RED}cloudflared 安装失败，请检查网络或手动安装！${NC}"
      exit 1
  fi

  # 创建 cloudflared 配置文件目录
  mkdir -p /etc/cloudflared

  # 创建配置文件
  cat << EOF > /etc/cloudflared/config.yml
tunnel: vps-tunnel
credentials-file: /etc/cloudflared/credentials.json
ingress:
  - service: http://localhost:80
    hostname: vps.example.com # 请替换为你的域名
  - service: http_status:404
EOF

  # 保存隧道令牌
  echo "{\"TunnelID\":\"vps-tunnel\",\"AccountTag\":\"YOUR_ACCOUNT_TAG\",\"TunnelSecret\":\"$TUNNEL_TOKEN\"}" > /etc/cloudflared/credentials.json
  chmod 600 /etc/cloudflared/credentials.json

  # 创建 systemd 服务文件
  cat << EOF > /etc/systemd/system/cloudflared.service
[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
ExecStart=/usr/local/bin/cloudflared --config /etc/cloudflared/config.yml tunnel run
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target
EOF

  # 重新加载 systemd 并启动服务
  echo -e "${GREEN}正在启动 Cloudflare Tunnel...${NC}"
  systemctl daemon-reload
  systemctl start cloudflared
  systemctl enable cloudflared

  # 检查服务状态
  if systemctl is-active cloudflared &> /dev/null; then
      echo -e "${GREEN}Cloudflare Tunnel 已成功启动！${NC}"
  else
      echo -e "${RED}Cloudflare Tunnel 启动失败，请检查配置！${NC}"
      exit 1
  fi

  # 配置 Zero Trust 私有网络（需要在 Cloudflare 仪表板手动完成的部分）
  echo -e "${GREEN}脚本已完成 VPS 端的配置！${NC}"
  echo -e "${GREEN}请登录 Cloudflare Zero Trust 仪表板完成以下步骤：${NC}"
  echo "1. 在 'Networks > Tunnels' 中找到你的隧道 'vps-tunnel'"
  echo "2. 在 'Private Networks' 标签中添加私有 IP 范围: $PRIVATE_IP_RANGE"
  echo "3. 在 'Settings > WARP Client > Split Tunnels' 中配置，确保 $PRIVATE_IP_RANGE 通过 WARP 路由"
  echo "4. 下载并安装 WARP 客户端，使用你的 Team Name 登录"

  echo -e "${GREEN}完成后，你的 VPS 将通过 Cloudflare 落地 IP 提供服务！${NC}"

elif [ "$CHOICE" == "2" ]; then
  # 卸载功能
  echo -e "${GREEN}开始卸载 Cloudflare Zero Trust...${NC}"

  # 停止并禁用服务
  echo -e "${GREEN}正在停止并禁用 cloudflared 服务...${NC}"
  systemctl stop cloudflared 2>/dev/null
  systemctl disable cloudflared 2>/dev/null

  # 删除服务文件
  rm -f /etc/systemd/system/cloudflared.service
  systemctl daemon-reload

  # 删除配置文件和二进制文件
  echo -e "${GREEN}正在删除配置文件和 cloudflared...${NC}"
  rm -rf /etc/cloudflared
  rm -f /usr/local/bin/cloudflared

  # 检查卸载是否成功
  if [ ! -f /usr/local/bin/cloudflared ] && [ ! -d /etc/cloudflared ]; then
      echo -e "${GREEN}Cloudflare Zero Trust 已成功卸载！${NC}"
  else
      echo -e "${RED}卸载失败，请手动检查残留文件！${NC}"
      exit 1
  fi

else
  echo -e "${RED}无效选项，请输入 1 或 2！${NC}"
  exit 1
fi
