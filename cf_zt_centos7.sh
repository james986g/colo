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

  # 检查是否已安装 cloudflared
  if [ -f /usr/local/bin/cloudflared ] && [ -x /usr/local/bin/cloudflared ]; then
    echo -e "${GREEN}检测到已安装 cloudflared，跳过安装步骤...${NC}"
  else
    echo -e "${GREEN}正在安装 Cloudflare cloudflared...${NC}"
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /usr/local/bin/cloudflared
    chmod +x /usr/local/bin/cloudflared
  fi

  # 验证 cloudflared 是否可用
  if ! /usr/local/bin/cloudflared --version &> /dev/null; then
    echo -e "${RED}cloudflared 安装失败或不可用，请检查网络或手动安装！${NC}"
    echo "手动安装命令：wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /usr/local/bin/cloudflared"
    echo "赋予权限：chmod +x /usr/local/bin/cloudflared"
    exit 1
  else
    echo -e "${GREEN}cloudflared 已成功安装或验证通过，版本：$(/usr/local/bin/cloudflared --version)${NC}"
  fi

  # 检查或生成 cert.pem
  if [ ! -f /etc/cloudflared/cert.pem ]; then
    echo -e "${GREEN}未找到 cert.pem，正在生成...${NC}"
    echo "请在浏览器中完成 Cloudflare 登录授权，完成后将 cert.pem 上传至 /etc/cloudflared/cert.pem"
    /usr/local/bin/cloudflared login
    echo -e "${GREEN}请将生成的 cert.pem 移动到 /etc/cloudflared/cert.pem（或手动上传），然后按 Enter 继续...${NC}"
    read -p "按 Enter 继续..."
    if [ ! -f /etc/cloudflared/cert.pem ]; then
      echo -e "${RED}未找到 /etc/cloudflared/cert.pem，请手动上传后重新运行脚本！${NC}"
      exit 1
    fi
  else
    echo -e "${GREEN}检测到 /etc/cloudflared/cert.pem，已存在，跳过生成步骤...${NC}"
  fi

  # 获取用户输入
  echo -e "${GREEN}请输入你的 Cloudflare 账户 ID (Account Tag):${NC}"
  read -p "Account Tag: " ACCOUNT_TAG
  echo -e "${GREEN}请输入你的隧道 ID (Tunnel ID，在 Zero Trust 的 Tunnels 页面查看):${NC}"
  read -p "Tunnel ID: " TUNNEL_ID
  echo -e "${GREEN}请输入你的 Cloudflare Zero Trust 隧道令牌 (Tunnel Token):${NC}"
  read -p "Tunnel Token: " TUNNEL_TOKEN
  echo -e "${GREEN}请输入你的 VPS 域名 (例如 vps.example.com):${NC}"
  read -p "Hostname: " HOSTNAME
  echo -e "${GREEN}请输入你的 VPS 私有 IP 范围 (例如 192.168.1.0/24):${NC}"
  read -p "私有 IP 范围: " PRIVATE_IP_RANGE

  # 创建 cloudflared 配置文件目录
  mkdir -p /etc/cloudflared

  # 创建配置文件
  cat << EOF > /etc/cloudflared/config.yml
tunnel: $TUNNEL_ID
credentials-file: /etc/cloudflared/credentials.json
origincert: /etc/cloudflared/cert.pem
ingress:
  - service: http://localhost:80
    hostname: $HOSTNAME
  - service: http_status:404
EOF

  # 保存隧道令牌
  echo "{\"TunnelID\":\"$TUNNEL_ID\",\"AccountTag\":\"$ACCOUNT_TAG\",\"TunnelSecret\":\"$TUNNEL_TOKEN\"}" > /etc/cloudflared/credentials.json
  chmod 600 /etc/cloudflared/credentials.json

  # 检查配置文件是否存在
  if [ ! -f /etc/cloudflared/config.yml ] || [ ! -f /etc/cloudflared/credentials.json ]; then
    echo -e "${RED}配置文件生成失败，请检查脚本权限或磁盘空间！${NC}"
    exit 1
  fi

  # 显示配置文件内容供用户检查
  echo -e "${GREEN}以下是生成的配置文件内容，请确认无误：${NC}"
  echo "---- /etc/cloudflared/config.yml ----"
  cat /etc/cloudflared/config.yml
  echo "---- /etc/cloudflared/credentials.json ----"
  cat /etc/cloudflared/credentials.json
  echo -e "${GREEN}如果以上内容有误，请按 Ctrl+C 退出并重新运行脚本！${NC}"
  read -p "按 Enter 继续..."

  # 测试隧道连接
  echo -e "${GREEN}测试隧道连接...${NC}"
  /usr/local/bin/cloudflared tunnel --config /etc/cloudflared/config.yml run --loglevel debug --logfile /tmp/cloudflared_test.log &
  TEST_PID=$!
  sleep 5  # 等待几秒观察输出
  kill $TEST_PID
  cat /tmp/cloudflared_test.log
  echo -e "${GREEN}请检查以上输出是否有错误（如 Invalid token 或 Connection refused），如果有问题请修正配置后重试！${NC}"
  read -p "按 Enter 继续..."
  rm -f /tmp/cloudflared_test.log

  # 创建 systemd 服务文件
  cat << EOF > /etc/systemd/system/cloudflared.service
[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
ExecStart=/usr/local/bin/cloudflared tunnel run --config /etc/cloudflared/config.yml --loglevel debug --logfile /var/log/cloudflared.log
Restart=always
RestartSec=5
User=root
StandardOutput=file:/var/log/cloudflared.log
StandardError=file:/var/log/cloudflared.log

[Install]
WantedBy=multi-user.target
EOF

  # 创建日志目录
  mkdir -p /var/log
  touch /var/log/cloudflared.log
  chmod 644 /var/log/cloudflared.log

  # 重新加载 systemd 并启动服务
  echo -e "${GREEN}正在启动 Cloudflare Tunnel...${NC}"
  systemctl daemon-reload
  systemctl start cloudflared
  systemctl enable cloudflared

  # 检查服务状态
  if systemctl is-active cloudflared &> /dev/null; then
    echo -e "${GREEN}Cloudflare Tunnel 已成功启动！${NC}"
    echo "验证隧道状态：/usr/local/bin/cloudflared tunnel info $TUNNEL_ID"
    echo "查看日志：cat /var/log/cloudflared.log"
  else
    echo -e "${RED}Cloudflare Tunnel 启动失败，请检查以下内容：${NC}"
    echo "1. 查看详细服务状态：systemctl status cloudflared"
    echo "2. 查看日志：cat /var/log/cloudflared.log"
    echo "3. 手动运行检查错误：/usr/local/bin/cloudflared tunnel --config /etc/cloudflared/config.yml run --loglevel debug"
    echo "4. 确认 /etc/cloudflared/config.yml 和 credentials.json 中的配置无误"
    echo "5. 确认 /etc/cloudflared/cert.pem 是否存在且有效"
    echo "6. 检查网络连接：ping 162.159.192.1 或 curl -I https://cloudflare.com"
    exit 1
  fi

  # 配置 Zero Trust 私有网络（需要在 Cloudflare 仪表板手动完成的部分）
  echo -e "${GREEN}脚本已完成 VPS 端的配置！${NC}"
  echo -e "${GREEN}请登录 Cloudflare Zero Trust 仪表板完成以下步骤：${NC}"
  echo "1. 在 'Networks > Tunnels' 中找到你的隧道 '$TUNNEL_ID'"
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
