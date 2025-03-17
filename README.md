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
