首次安装
```
wget https://raw.githubusercontent.com/james986g/colo/refs/heads/main/warp_optimize.sh -O warp_optimize.sh
chmod +x warp_optimize.sh
./warp_optimize.sh
```
```
wget https://raw.githubusercontent.com/james986g/colo/refs/heads/main/clean_vps.sh -O clean_vps.sh
chmod +x clean_vps.sh
./clean_vps.sh
```
argo tunnel+xray 
```
wget https://raw.githubusercontent.com/james986g/colo/refs/heads/main/argo_temp.sh -O argo_temp.sh
chmod +x argo_temp.sh
./argo_temp.sh
```
自己写的tunnel可以用！！
```
wget https://raw.githubusercontent.com/james986g/colo/refs/heads/main/cloudflared_setup.sh -O cloudflared_setup.sh
chmod +x cloudflared_setup.sh
./cloudflared_setup.sh
```
手动安装cloudflared-linux-amd64
```
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /usr/local/bin/cloudflared
chmod +x /usr/local/bin/cloudflared
```
混淆s12脚本
```
bash <(curl -fsSL https://raw.githubusercontent.com/james986g/colo/main/obfuscated.sh)
```

启动本地服务
本地服务未运行是主要问题。假设你想运行一个简单的 HTTP 服务：
```
python3 -m http.server 1234 &
```
```
curl -I http://localhost:1234
```
应返回 200 OK。
解决方案
以下是几种方法来隐藏目录列表并提升安全性：

方法 1：禁用 http.server 的目录列表
默认的 python3 -m http.server 不支持直接禁用目录列表，但我们可以通过自定义 Python 脚本实现。

创建自定义服务脚本：
```
nano /root/simple_server.py
```
输入以下内容：
```
#!/usr/bin/env python3
import http.server
import socketserver

PORT = 1234
DIRECTORY = "/root/www"  # 指定服务目录，避免暴露根目录

class NoDirListingHandler(http.server.SimpleHTTPRequestHandler):
    def list_directory(self, path):
        self.send_error(403, "Directory listing is disabled")
        return None

Handler = NoDirListingHandler
with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print(f"Serving at port {PORT}")
    httpd.serve_forever()
```
创建服务目录并添加默认文件：
```
mkdir -p /root/www
echo "<html><body><h1>Welcome to xx.xxx.com</h1></body></html>" > /root/www/index.html
```
停止现有服务并启动新服务：
```
pkill -f "python3 -m http.server"
python3 /root/simple_server.py &
```
更新 cloudflared 配置： 编辑 /root/.cloudflared/config.yml，确保 service 指向正确目录：
```
tunnel: bse374632-4efc-46b7-a901-4c1f9235163
credentials-file: /root/.cloudflared/b025632-4efc-46b7-a901-4c132327163.json
ingress:
  - hostname: xx.xxx.com
    service: http://localhost:1234
  - service: http_status:404
```
重启服务：
```
systemctl restart cloudflared
```
验证：
```
curl -I http://localhost:1234
curl http://xxx.xx.com/
```
预期：返回 index.html 内容，不显示目录列表。
