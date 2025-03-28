#!/bin/bash
_0xZ1="\033[0m";_0xK2="\033[1;91m";_0xM3="\e[1;32m";_0xN4="\e[1;33m";_0xP5="\e[1;35m";_0xQ6(){ echo -e "$_0xK2$1$_0xZ1";};_0xR7(){ echo -e "$_0xM3$1$_0xZ1";};_0xS8(){ echo -e "$_0xN4$1$_0xZ1";};_0xT9(){ echo -e "$_0xP5$1$_0xZ1";};_0xU0(){ read -p "$(_0xQ6 "$1")" "$2";};export LC_ALL=C;_0xV1=$(hostname);_0xW2=$(whoami|tr '[:upper:]' '[:lower:]');export _0xX3=${_0xX3:-$(uuidgen -r)};export _0xY4=${_0xY4:-''};export _0xZ5=${_0xZ5:-''};export _0xA6=${_0xA6:-''};export _0xB7=${_0xB7:-''};export _0xC8=${_0xC8:-''};export _0xD9=${_0xD9:-'www.visa.com.sg'};export _0xE0=${_0xE0:-'443'};export _0xF1=${_0xF1:-${_0xX3:0:8}};export _0xG2=${_0xG2:-''};export _0xH3=${_0xH3:-''};export _0xI4=${_0xI4:-''};[[ "$_0xV1" =~ ct8 ]]&&_0xJ5="ct8.pl"||[[ "$_0xV1" =~ useruno ]]&&_0xJ5="useruno.com"||_0xJ5="serv00.net";_0xK6="${HOME}/domains/${_0xW2}.${_0xJ5}/logs";_0xL7="${HOME}/domains/${_0xW2}.${_0xJ5}/public_html";rm -rf "$_0xK6" "$_0xL7"&&mkdir -p "$_0xK6" "$_0xL7"&&chmod 777 "$_0xK6" "$_0xL7" >/dev/null 2>&1;bash -c 'ps aux|grep $(whoami)|grep -v "sshd\|bash\|grep"|awk "{print \$2}"|xargs -r kill -9 >/dev/null 2>&1' >/dev/null 2>&1;command -v curl &>/dev/null&&_0xM8="curl -so"||command -v wget &>/dev/null&&_0xM8="wget -qO"||{ _0xQ6 "$(echo "RXJyb3I6IG5laXRoZXIgY3VybCBub3Igd2dldCBmb3VuZA=="|base64 -d)";exit 1;}
_0xN9="$(echo "dm1lc3M=" | base64 -d)";_0xO0="$(echo "dHVubmVs" | base64 -d)";_0xP1="$(echo "cmVtb3Rl" | base64 -d)";_0xQ2="$(echo "aHlzc3RlcmlhMg==" | base64 -d)";_0xR3=$RANDOM

_0xS4(){ _0xT5=$(_0xX7);_0xR7 "ArgoDomain:$_0xP5$_0xT5$_0xZ1";_0xU6=$(curl -s --max-time 2 https://speed.cloudflare.com/meta|awk -F\" '{print $26}'|sed -e 's/ /_/g'||echo "0");_0xV7(){ [[ "$_0xV1" = "s1.ct8.pl" ]]&&_0xW8="CT8"||_0xW8=$(echo "$_0xV1"|cut -d '.' -f 1);echo "$_0xW8";};_0xX9="$_0xU6-$(_0xV7)";_0xS8 "$(echo "djJyYXkgc2tpcCBjZXJ0IHZlcmlmeSB0cnVl" | base64 -d)";cat > $_0xL7/list.txt <<EOF
$_0xN9://$(echo "{ \"v\": \"2\", \"ps\": \"$_0xX9-vmss\", \"add\": \"$_0xY0\", \"port\": \"$_0xZ3\", \"id\": \"$_0xX3\", \"aid\": \"0\", \"scy\": \"none\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"\", \"path\": \"/$_0xN9-argo?ed=2048\", \"tls\": \"\", \"sni\": \"\", \"alpn\": \"\", \"fp\": \"\"}"|base64 -w0)
$_0xN9://$(echo "{ \"v\": \"2\", \"ps\": \"$_0xX9-vmss-argo\", \"add\": \"$_0xD9\", \"port\": \"$_0xE0\", \"id\": \"$_0xX3\", \"aid\": \"0\", \"scy\": \"none\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"$_0xT5\", \"path\": \"/$_0xN9-argo?ed=2048\", \"tls\": \"tls\", \"sni\": \"$_0xT5\", \"alpn\": \"\", \"fp\": \"\"}"|base64 -w0)
$_0xQ2://$_0xX3@$_0xY0:$_0xA4/?sni=www.bing.com&alpn=h3&insecure=1#$_0xX9-hy2
tuic://$_0xX3:admin123@$_0xY0:$_0xB5?sni=www.bing.com&congestion_control=bbr&udp_relay_mode=native&alpn=h3&allow_insecure=1#$_0xX9-tuic
EOF
;cat $_0xL7/list.txt;_0xC6;_0xD7;_0xS8 "Serv00|ct8 script";echo -e "${_0xM3}issues:${_0xZ1}${_0xN4}$(echo "aHR0cHM6Ly9naXRodWIuY29tL2Vvb2NlL1Npbmdib3g="|base64 -d)/issues${_0xZ1}";echo -e "${_0xM3}forum:${_0xZ1}${_0xN4}https://bbs.vps8.me${_0xZ1}";echo -e "${_0xM3}TG:${_0xZ1}${_0xN4}https://t.me/vps888${_0xZ1}";_0xT9 "Do not abuse";_0xR7 "Done!";rm -rf sb.log core boot.log config.json $_0xO0.yml $_0xO0.json fake_useragent_0.2.0.json;}

_0xE8(){ clear;_0xT9 "$(echo "c2hhbmd6YWk="|base64 -d)...";_0xF9=$(devil port list);_0xG0=$(echo "$_0xF9"|grep -c "tcp");_0xH1=$(echo "$_0xF9"|grep -c "udp");[[ $_0xG0 -ne 1 || $_0xH1 -ne 2 ]]&&{ _0xQ6 "$(echo "cG9ydCBydWxlcyBub3QgbWF0Y2g="|base64 -d)...";[[ $_0xG0 -gt 1 ]]&&{ _0xI2=$((_0xG0-1));echo "$_0xF9"|awk '/tcp/ {print $1, $2}'|head -n $_0xI2|while read _0xJ3 _0xK4;do devil port del $_0xK4 $_0xJ3;_0xR7 "Deleted TCP: $_0xJ3";done;};[[ $_0xH1 -gt 2 ]]&&{ _0xL5=$((_0xH1-2));echo "$_0xF9"|awk '/udp/ {print $1, $2}'|head -n $_0xL5|while read _0xM6 _0xN7;do devil port del $_0xN7 $_0xM6;_0xR7 "Deleted UDP: $_0xM6";done;};[[ $_0xG0 -lt 1 ]]&&{ while true;do _0xO8=$(shuf -i 10000-65535 -n 1);_0xP9=$(devil port add tcp $_0xO8 2>&1);[[ $_0xP9 == *"Ok"* ]]&&{ _0xR7 "Added TCP: $_0xO8";break;}||_0xS8 "Port $_0xO8 unavailable...";done;};[[ $_0xH1 -lt 2 ]]&&{ _0xQ0=$((2-_0xH1));_0xR1=0;while [[ $_0xR1 -lt $_0xQ0 ]];do _0xS2=$(shuf -i 10000-65535 -n 1);_0xT3=$(devil port add udp $_0xS2 2>&1);[[ $_0xT3 == *"Ok"* ]]&&{ _0xR7 "Added UDP: $_0xS2";[[ $_0xR1 -eq 0 ]]&&_0xU4=$_0xS2||_0xV5=$_0xS2;_0xR1=$((_0xR1+1));}||_0xS8 "Port $_0xS2 unavailable...";done;};_0xS8 "$(echo "cG9ydHMgYWRqdXN0ZWQsIHJlY29ubmVjdCBzc2g="|base64 -d)";_0xW6;devil binexec on >/dev/null 2>&1;kill -9 $(ps -o ppid= -p $$) >/dev/null 2>&1;}||{ _0xX7=$(echo "$_0xF9"|awk '/tcp/ {print $1}');_0xY8=$(echo "$_0xF9"|awk '/udp/ {print $1}');_0xZ9=$(echo "$_0xY8"|sed -n '1p');_0xA0=$(echo "$_0xY8"|sed -n '2p');};_0xT9 "tcp port: $_0xX7";_0xT9 "udp ports: $_0xZ9 $_0xA0";export _0xZ3=$_0xX7;export _0xB5=$_0xZ9;export _0xA4=$_0xA0;}

_0xB6(){ [[ -z $_0xC8 || -z $_0xB7 ]]&&{ _0xR7 "Using quick $_0xO0";return;};[[ $_0xC8 =~ TunnelSecret ]]&&{ echo $_0xC8 > $_0xO0.json;cat > $_0xO0.yml <<EOF
$_0xO0: $(cut -d\" -f12 <<< "$_0xC8")
credentials-file: $_0xO0.json
protocol: http2
ingress:
  - hostname: $_0xB7
    service: http://localhost:$_0xZ3
    originRequest:
      noTLSVerify: true
  - service: http_status:404
EOF
;}||_0xS8 "Use token, set $_0xO0 port to $_0xP5$_0xZ3$_0xZ1 in CF";}

_0xC6(){ echo "";rm -rf $_0xL7/.htaccess;base64 -w0 $_0xL7/list.txt > $_0xL7/v2.log;_0xD7="https://00.ssss.nyc.mn/sub.php";_0xE8="https://00.ssss.nyc.mn/qrencode";$_0xM8 "$_0xL7/$_0xF1.php" "$_0xD7";$_0xM8 "$_0xK6/qrencode" "$_0xE8"&&chmod +x "$_0xK6/qrencode";_0xF9="https://${_0xW2}.${_0xJ5}/v2.log";_0xG0="https://${_0xW2}.${_0xJ5}/$_0xF1";curl -sS "https://sublink.eooce.com/clash?config=$_0xF9" -o $_0xL7/clash.yaml;curl -sS "https://sublink.eooce.com/singbox?config=$_0xF9" -o $_0xL7/singbox.yaml;"$_0xK6/qrencode" -m 2 -t UTF8 "$_0xG0";_0xT9 "$(echo "c3ViIGxpbms6IA=="|base64 -d)$_0xG0";_0xR7 "QR and sub link for clients";cat > $_0xL7/.htaccess <<EOF
RewriteEngine On
DirectoryIndex index.html
RewriteCond %{THE_REQUEST} ^[A-Z]{3,9}\ /(\?|$)
RewriteRule ^$ /index.html [L]
<FilesMatch "^(index\.html|${_0xF1}\.php)$">
Order Allow,Deny
Allow from all
</FilesMatch>
<FilesMatch "^(clash\.yaml|singbox\.yaml|list\.txt|v2\.log|sub\.php)$">
Order Allow,Deny
Deny from all
</FilesMatch>
RewriteRule ^${_0xF1}$ ${_0xF1}.php [L]
EOF
;}

_0xD7(){ _0xT9 "$(echo "aW5zdGFsbGluZyBrZWVwYWxpdmU="|base64 -d)...";devil www del keep.${_0xW2}.${_0xJ5} >/dev/null 2>&1;devil www add keep.${_0xW2}.${_0xJ5} nodejs /usr/local/bin/node18 >/dev/null 2>&1;_0xE8="$HOME/domains/keep.${_0xW2}.${_0xJ5}/public_nodejs";[[ -d "$_0xE8" ]]||mkdir -p "$_0xE8";_0xF9="https://00.ssss.nyc.mn/sbx4.js";$_0xM8 "$_0xE8/app.js" "$_0xF9";cat > $_0xE8/.env <<EOF
UUID=$_0xX3
CFIP=$_0xD9
CFPORT=$_0xE0
SUB_TOKEN=$_0xF1
API_SUB_URL=$_0xI4
TELEGRAM_CHAT_ID=$_0xG2
TELEGRAM_BOT_TOKEN=$_0xH3
NEZHA_SERVER=$_0xY4
NEZHA_PORT=$_0xZ5
NEZHA_KEY=$_0xA6
ARGO_DOMAIN=$_0xB7
ARGO_AUTH=$([[ -z "$_0xC8" ]]&&echo ""||([[ "$_0xC8" =~ ^\{.* ]]&&echo "'$_0xC8'"||echo "$_0xC8"))
EOF
;ln -fs /usr/local/bin/node18 ~/bin/node >/dev/null 2>&1;ln -fs /usr/local/bin/npm18 ~/bin/npm >/dev/null 2>&1;mkdir -p ~/.npm-global;npm config set prefix '~/.npm-global';echo 'export PATH=~/.npm-global/bin:~/bin:$PATH' >> $HOME/.bash_profile&&source $HOME/.bash_profile;rm -rf $HOME/.npmrc >/dev/null 2>&1;cd $_0xE8&&npm install dotenv axios --silent >/dev/null 2>&1;rm $HOME/domains/keep.${_0xW2}.${_0xJ5}/public_nodejs/public/index.html >/dev/null 2>&1;devil www restart keep.${_0xW2}.${_0xJ5} >/dev/null 2>&1;curl -skL "http://keep.${_0xW2}.${_0xJ5}/${_0xW2}"|grep -q "running"&&{ _0xR7 "$(echo "a2VlcGFsaXZlIHN1Y2Nlss="|base64 -d)";_0xR7 "All services running";_0xT9 "Visit http://keep.${_0xW2}.${_0xJ5}/stop to end";_0xT9 "Visit http://keep.${_0xW2}.${_0xJ5}/list for processes";_0xS8 "Visit http://keep.${_0xW2}.${_0xJ5}/${_0xW2} to trigger";_0xT9 "Visit http://keep.${_0xW2}.${_0xJ5}/status for status";_0xT9 "For TG notify, get CHAT_ID at ${_0xN4}https://t.me/laowang_serv00_bot${_0xZ1}";_0xG0;}||{ _0xQ6 "$(echo "a2VlcGFsaXZlIGZhaWxlZA=="|base64 -d)";_0xS8 "Check http://keep.${_0xW2}.${_0xJ5}/status, reinstall with:\ndevil www del ${_0xW2}.${_0xJ5}\ndevil www del keep.${_0xW2}.${_0xJ5}\nrm -rf $HOME/domains/*\nshopt -s extglob dotglob\nrm -rf $HOME/!(domains|mail|repo|backups)";};}

_0xF8(){ openssl ecparam -genkey -name prime256v1 -out "private.key";openssl req -new -x509 -days 3650 -key "private.key" -out "cert.pem" -subj "/CN=$_0xW2.$_0xJ5";_0xS8 "Fetching IP...";_0xY0=$(_0xH9);_0xT9 "Selected IP: $_0xY0";cat > config.json <<EOF
{ "log": {"disabled": true,"level": "info","timestamp": true},
  "dns": {"servers": [{"address": "8.8.8.8","address_resolver": "local"},{"tag": "local","address": "local"}]},
  "inbounds": [
    {"tag": "hy-in","type": "$_0xQ2","listen": "$_0xY0","listen_port": $_0xA4,"users": [{"password": "$_0xX3"}],"masquerade": "https://bing.com","tls": {"enabled": true,"alpn": ["h3"],"certificate_path": "cert.pem","key_path": "private.key"}},
    {"tag": "vm-ws-in","type": "$_0xN9","listen": "::","listen_port": $_0xZ3,"users": [{"uuid": "$_0xX3"}],"transport": {"type": "ws","path": "/$_0xN9-argo","early_data_header_name": "Sec-WebSocket-Protocol"}},
    {"tag": "tu-in","type": "tuic","listen": "$_0xY0","listen_port": $_0xB5,"users": [{"uuid": "$_0xX3","password": "admin123"}],"congestion_control": "bbr","tls": {"enabled": true,"alpn": ["h3"],"certificate_path": "cert.pem","key_path": "private.key"}}
  ],
EOF
[[ "$_0xV1" =~ s14|s15 ]]&&cat >> config.json <<EOF
  "outbounds": [
    {"type": "direct","tag": "direct"},
    {"type": "block","tag": "block"},
    {"type": "wireguard","tag": "wg-out","server": "162.159.192.200","server_port": 4500,"local_address": ["172.16.0.2/32","2606:4700:110:8f77:1ca9:f086:846c:5f9e/128"],"private_key": "wIxszdR2nMdA7a2Ul3XQcniSfSZqdqjPb6w6opvf5AU=","peer_public_key": "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=","reserved": [126, 246, 173]}
  ],
  "route": {
    "rule_set": [
      {"tag": "yt","type": "$_0xP1","format": "binary","url": "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo-lite/geosite/youtube.srs","download_detour": "direct"},
      {"tag": "gg","type": "$_0xP1","format": "binary","url": "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo-lite/geosite/google.srs","download_detour": "direct"},
      {"tag": "sp","type": "$_0xP1","format": "binary","url": "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo-lite/geosite/spotify.srs","download_detour": "direct"}
    ],
    "rules": [{"rule_set": ["gg", "yt", "sp"],"outbound": "wg-out"}],"final": "direct"
  }
}
EOF
||cat >> config.json <<EOF
  "outbounds": [
    {"type": "direct","tag": "direct"},
    {"type": "block","tag": "block"}
  ]
}
EOF
;}

_0xG0(){ _0xH1="00";_0xI2="$HOME/bin/$_0xH1";mkdir -p "$HOME/bin";cat > "$_0xI2" <<EOF
#!/bin/bash
bash <(curl -Ls $(echo "aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL2Vvb2NlL3Npbmdib3gvbWFpbi9zYl9zZXJ2MDAuc2g="|base64 -d))
EOF
;chmod +x "$_0xI2";[[ ":$PATH:" != *":$HOME/bin:"* ]]&&{ echo "export PATH=\"\$HOME/bin:\$PATH\"" >> "$HOME/.bashrc" 2>/dev/null;source "$HOME/.bashrc";};_0xR7 "Shortcut $_0xH1 created";}

_0xH9(){ _0xI0=$(uname -m);_0xJ1=".";mkdir -p "$_0xJ1";_0xK2=();[[ "$_0xI0" == "arm" || "$_0xI0" == "arm64" || "$_0xI0" == "aarch64" ]]&&_0xL3=$(echo "aHR0cHM6Ly9naXRodWIuY29tL2Vvb2NlL3Rlc3Q="|base64 -d)/releases/download/freebsd-arm64||[[ "$_0xI0" == "amd64" || "$_0xI0" == "x86_64" || "$_0xI0" == "x86" ]]&&_0xL3=$(echo "aHR0cHM6Ly9naXRodWIuY29tL2Vvb2NlL3Rlc3Q="|base64 -d)/releases/download/freebsd||{ echo "Unsupported: $_0xI0";exit 1;};_0xK2=("$_0xL3/sb web" "$_0xL3/server bot");[[ -n "$_0xZ5" ]]&&_0xK2+=("$_0xL3/npm npm")||{ _0xK2+=("$_0xL3/v1 php");_0xM4=$(case "${_0xY4##*:}" in 443|8443|2096|2087|2083|2053) echo -n tls;; *) echo -n false;; esac);cat > "$_0xK6/config.yaml" <<EOF
client_secret: $_0xA6
debug: false
disable_auto_update: true
disable_command_execute: false
disable_force_update: true
disable_nat: false
disable_send_query: false
gpu: false
insecure_tls: false
ip_report_period: 1800
report_delay: 1
server: $_0xY4
skip_connection_count: false
skip_procs_count: false
temperature: false
tls: $_0xM4
use_gitee_to_upgrade: false
use_ipv6_country_code: false
uuid: $_0xX3
EOF
;};declare -A _0xN5;_0xO6(){ local _0xP7=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890;_0xQ8="";for i in {1..6};do _0xQ8="$_0xQ8${_0xP7:RANDOM%${#_0xP7}:1}";done;echo "$_0xQ8";};_0xR9(){ local _0xS0=$1;_0xT1=$2;curl -L -sS --max-time 2 -o "$_0xT1" "$_0xS0" &;_0xU2=$!;_0xV3=$(stat -c%s "$_0xT1" 2>/dev/null||echo 0);sleep 1;_0xW4=$(stat -c{snipped}
