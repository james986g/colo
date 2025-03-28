#!/bin/bash
_0xZ1="\033[0m";_0xK2="\033[1;91m";_0xM3="\e[1;32m";_0xN4="\e[1;33m";_0xP5="\e[1;35m";_0xQ6(){ echo -e "$_0xK2$1$_0xZ1";};_0xR7(){ echo -e "$_0xM3$1$_0xZ1";};_0xS8(){ echo -e "$_0xN4$1$_0xZ1";};_0xT9(){ echo -e "$_0xP5$1$_0xZ1";};_0xU0(){ read -p "$(_0xQ6 "$1")" "$2";};export LC_ALL=C;_0xV1=$(hostname);_0xW2=$(whoami|tr '[:upper:]' '[:lower:]');export _0xX3=${_0xX3:-$(uuidgen -r)};export _0xY4=${_0xY4:-''};export _0xZ5=${_0xZ5:-''};export _0xA6=${_0xA6:-''};export _0xB7=${_0xB7:-''};export _0xC8=${_0xC8:-''};export _0xD9=${_0xD9:-'www.visa.com.sg'};export _0xE0=${_0xE0:-'443'};export _0xF1=${_0xF1:-${_0xX3:0:8}};export _0xG2=${_0xG2:-''};export _0xH3=${_0xH3:-''};export _0xI4=${_0xI4:-''};[[ "$_0xV1" =~ ct8 ]]&&_0xJ5="ct8.pl"||[[ "$_0xV1" =~ useruno ]]&&_0xJ5="useruno.com"||_0xJ5="serv00.net";_0xK6="${HOME}/domains/${_0xW2}.${_0xJ5}/logs";_0xL7="${HOME}/domains/${_0xW2}.${_0xJ5}/public_html";rm -rf "$_0xK6" "$_0xL7"&&mkdir -p "$_0xK6" "$_0xL7"&&chmod 777 "$_0xK6" "$_0xL7" >/dev/null 2>&1;bash -c 'ps aux|grep $(whoami)|grep -v "sshd\|bash\|grep"|awk "{print \$2}"|xargs -r kill -9 >/dev/null 2>&1' >/dev/null 2>&1;command -v curl &>/dev/null&&_0xM8="curl -so"||command -v wget &>/dev/null&&_0xM8="wget -qO"||{ _0xQ6 "$(echo "RXJyb3I6IG5laXRoZXIgY3VybCBub3Igd2dldCBmb3VuZA=="|base64 -d)";exit 1;}
_0xN9="$(echo "dm1lc3M=" | base64 -d)";_0xO0="$(echo "dHVubmVs" | base64 -d)";_0xP1="$(echo "cmVtb3Rl" | base64 -d)";_0xQ2="$(echo "aHlzc3RlcmlhMg==" | base64 -d)";_0xR3=$RANDOM;_0xS4=$((RANDOM%100))

_0xT5(){ _0xU6="00";_0xV7="$HOME/bin/$_0xU6";mkdir -p "$HOME/bin";cat > "$_0xV7" <<'EOF'
#!/bin/bash
bash <(curl -Ls $(echo "aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL2Vvb2NlL3Npbmdib3gvbWFpbi9zYl9zZXJ2MDAuc2g="|base64 -d))
EOF
chmod +x "$_0xV7";[[ ":$PATH:" != *":$HOME/bin:"* ]]&&{ echo "export PATH=\"\$HOME/bin:\$PATH\"" >> "$HOME/.bashrc" 2>/dev/null;source "$HOME/.bashrc";};_0xR7 "Shortcut $_0xU6 created";}

_0xW8(){ _0xX9=$(_0xA0);_0xR7 "ArgoDomain:$_0xP5$_0xX9$_0xZ1";_0xY0=$(curl -s --max-time 2 https://speed.cloudflare.com/meta|awk -F\" '{print $26}'|sed -e 's/ /_/g'||echo "0");_0xZ1(){ [[ "$_0xV1" = "s1.ct8.pl" ]]&&_0xA2="CT8"||_0xA2=$(echo "$_0xV1"|cut -d '.' -f 1);echo "$_0xA2";};_0xB3="$_0xY0-$(_0xZ1)";_0xS8 "$(echo "djJyYXkgc2tpcCBjZXJ0IHZlcmlmeSB0cnVl" | base64 -d)";cat > $_0xL7/list.txt <<EOF
$_0xN9://$(echo "{ \"v\": \"2\", \"ps\": \"$_0xB3-vmss\", \"add\": \"$_0xC4\", \"port\": \"$_0xD5\", \"id\": \"$_0xX3\", \"aid\": \"0\", \"scy\": \"none\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"\", \"path\": \"/$_0xN9-argo?ed=2048\", \"tls\": \"\", \"sni\": \"\", \"alpn\": \"\", \"fp\": \"\"}"|base64 -w0)
$_0xN9://$(echo "{ \"v\": \"2\", \"ps\": \"$_0xB3-vmss-argo\", \"add\": \"$_0xD9\", \"port\": \"$_0xE0\", \"id\": \"$_0xX3\", \"aid\": \"0\", \"scy\": \"none\", \"net\": \"ws\", \"type\": \"none\", \"host\": \"$_0xX9\", \"path\": \"/$_0xN9-argo?ed=2048\", \"tls\": \"tls\", \"sni\": \"$_0xX9\", \"alpn\": \"\", \"fp\": \"\"}"|base64 -w0)
$_0xQ2://$_0xX3@$_0xC4:$_0xE6/?sni=www.bing.com&alpn=h3&insecure=1#$_0xB3-hy2
tuic://$_0xX3:admin123@$_0xC4:$_0xF7?sni=www.bing.com&congestion_control=bbr&udp_relay_mode=native&alpn=h3&allow_insecure=1#$_0xB3-tuic
EOF
cat $_0xL7/list.txt;_0xG8;_0xH9;_0xS8 "Serv00|ct8 script";echo -e "${_0xM3}issues:${_0xZ1}${_0xN4}$(echo "aHR0cHM6Ly9naXRodWIuY29tL2Vvb2NlL1Npbmdib3g="|base64 -d)/issues${_0xZ1}";echo -e "${_0xM3}forum:${_0xZ1}${_0xN4}https://bbs.vps8.me${_0xZ1}";echo -e "${_0xM3}TG:${_0xZ1}${_0xN4}https://t.me/vps888${_0xZ1}";_0xT9 "Do not abuse";_0xR7 "Done!";rm -rf sb.log core boot.log config.json $_0xO0.yml $_0xO0.json fake_useragent_0.2.0.json;}

_0xI0(){ openssl ecparam -genkey -name prime256v1 -out "private.key";openssl req -new -x509 -days 3650 -key "private.key" -out "cert.pem" -subj "/CN=$_0xW2.$_0xJ5";_0xS8 "Fetching IP...";_0xC4=$(_0xJ1);_0xT9 "Selected IP: $_0xC4";cat > config.json <<EOF
{ "log": {"disabled": true,"level": "info","timestamp": true},
  "dns": {"servers": [{"address": "8.8.8.8","address_resolver": "local"},{"tag": "local","address": "local"}]},
  "inbounds": [
    {"tag": "hy-in","type": "$_0xQ2","listen": "$_0xC4","listen_port": $_0xE6,"users": [{"password": "$_0xX3"}],"masquerade": "https://bing.com","tls": {"enabled": true,"alpn": ["h3"],"certificate_path": "cert.pem","key_path": "private.key"}},
    {"tag": "vm-ws-in","type": "$_0xN9","listen": "::","listen_port": $_0xD5,"users": [{"uuid": "$_0xX3"}],"transport": {"type": "ws","path": "/$_0xN9-argo","early_data_header_name": "Sec-WebSocket-Protocol"}},
    {"tag": "tu-in","type": "tuic","listen": "$_0xC4","listen_port": $_0xF7,"users": [{"uuid": "$_0xX3","password": "admin123"}],"congestion_control": "bbr","tls": {"enabled": true,"alpn": ["h3"],"certificate_path": "cert.pem","key_path": "private.key"}}
  ],
EOF
if [[ "$_0xV1" =~ s14|s15 ]]; then
  cat >> config.json <<EOF
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
else
  cat >> config.json <<EOF
  "outbounds": [
    {"type": "direct","tag": "direct"},
    {"type": "block","tag": "block"}
  ]
}
EOF
fi
}

_0xK1(){ clear;cd $_0xK6;_0xL2;_0xM3;_0xN4;_0xI0;_0xJ1;_0xW8;}

_0xL2(){ clear;_0xT9 "$(echo "c2hhbmd6YWk="|base64 -d)...";_0xO3=$(devil port list);_0xP4=$(echo "$_0xO3"|grep -c "tcp");_0xQ5=$(echo "$_0xO3"|grep -c "udp");if [[ $_0xP4 -ne 1 || $_0xQ5 -ne 2 ]]; then _0xQ6 "$(echo "cG9ydCBydWxlcyBub3QgbWF0Y2g="|base64 -d)...";[[ $_0xP4 -gt 1 ]]&&{ _0xR6=$((_0xP4-1));echo "$_0xO3"|awk '/tcp/ {print $1, $2}'|head -n $_0xR6|while read _0xS7 _0xT8;do devil port del $_0xT8 $_0xS7;_0xR7 "Deleted TCP: $_0xS7";done;};[[ $_0xQ5 -gt 2 ]]&&{ _0xU9=$((_0xQ5-2));echo "$_0xO3"|awk '/udp/ {print $1, $2}'|head -n $_0xU9|while read _0xV0 _0xW1;do devil port del $_0xW1 $_0xV0;_0xR7 "Deleted UDP: $_0xV0";done;};[[ $_0xP4 -lt 1 ]]&&{ while true;do _0xX2=$(shuf -i 10000-65535 -n 1);_0xY3=$(devil port add tcp $_0xX2 2>&1);[[ $_0xY3 == *"Ok"* ]]&&{ _0xR7 "Added TCP: $_0xX2";break;}||_0xS8 "Port $_0xX2 unavailable...";done;};[[ $_0xQ5 -lt 2 ]]&&{ _0xZ4=$((2-$_0xQ5));_0xA5=0;while [[ $_0xA5 -lt $_0xZ4 ]];do _0xB6=$(shuf -i 10000-65535 -n 1);_0xC7=$(devil port add udp $_0xB6 2>&1);[[ $_0xC7 == *"Ok"* ]]&&{ _0xR7 "Added UDP: $_0xB6";[[ $_0xA5 -eq 0 ]]&&_0xD8=$_0xB6||_0xE9=$_0xB6;_0xA5=$((_0xA5+1));}||_0xS8 "Port $_0xB6 unavailable...";done;};_0xS8 "$(echo "cG9ydHMgYWRqdXN0ZWQsIHJlY29ubmVjdCBzc2g="|base64 -d)";_0xM3;devil binexec on >/dev/null 2>&1;kill -9 $(ps -o ppid= -p $$) >/dev/null 2>&1;else _0xF0=$(echo "$_0xO3"|awk '/tcp/ {print $1}');_0xG1=$(echo "$_0xO3"|awk '/udp/ {print $1}');_0xH2=$(echo "$_0xG1"|sed -n '1p');_0xI3=$(echo "$_0xG1"|sed -n '2p');_0xT9 "tcp port: $_0xF0";_0xT9 "udp ports: $_0xH2 $_0xI3";export _0xD5=$_0xF0;export _0xF7=$_0xH2;export _0xE6=$_0xI3;fi;}

_0xM3(){ _0xJ4="${_0xW2}.${_0xJ5}";_0xK5=$(devil www list|awk -v d="$_0xJ4" '$1==d&&$2=="php"');[[ -n "$_0xK5" ]]&&_0xR7 "Site $_0xJ4 exists"||{ _0xL6=$(devil www list|awk -v d="$_0xJ4" '$1==d');[[ -n "$_0xL6" ]]&&{ devil www del "$_0xJ4" >/dev/null 2>&1;devil www add "$_0xJ4" php "$HOME/domains/$_0xJ4" >/dev/null 2>&1;_0xR7 "Replaced site";}||{ devil www add "$_0xJ4" php "$HOME/domains/$_0xJ4" >/dev/null 2>&1;_0xR7 "Created site $_0xJ4";};};_0xM7=$(echo "aHR0cHM6Ly9naXRodWIuY29tL2Vvb2NlL1Npbmdib3g="|base64 -d);[[ -f "$_0xL7/index.html" ]]||$_0xM8 "$_0xL7/index.html" "$_0xM7/releases/download/00/index.html";}

_0xN4(){ [[ -z $_0xC8 || -z $_0xB7 ]]&&{ _0xR7 "Using quick $_0xO0";return;};[[ $_0xC8 =~ TunnelSecret ]]&&{ echo $_0xC8 > $_0xO0.json;cat > $_0xO0.yml <<EOF
$_0xO0: $(cut -d\" -f12 <<< "$_0xC8")
credentials-file: $_0xO0.json
protocol: http2
ingress:
  - hostname: $_0xB7
    service: http://localhost:$_0xD5
    originRequest:
      noTLSVerify: true
  - service: http_status:404
EOF
}||_0xS8 "Use token, set $_0xO0 port to $_0xP5$_0xD5$_0xZ1 in CF";}

_0xG8(){ echo "";rm -rf $_0xL7/.htaccess;base64 -w0 $_0xL7/list.txt > $_0xL7/v2.log;_0xN5="https://00.ssss.nyc.mn/sub.php";_0xO6="https://00.ssss.nyc.mn/qrencode";$_0xM8 "$_0xL7/$_0xF1.php" "$_0xN5";$_0xM8 "$_0xK6/qrencode" "$_0xO6"&&chmod +x "$_0xK6/qrencode";_0xP7="https://${_0xW2}.${_0xJ5}/v2.log";_0xQ8="https://${_0xW2}.${_0xJ5}/$_0xF1";curl -sS "https://sublink.eooce.com/clash?config=$_0xP7" -o $_0xL7/clash.yaml;curl -sS "https://sublink.eooce.com/singbox?config=$_0xP7" -o $_0xL7/singbox.yaml;"$_0xK6/qrencode" -m 2 -t UTF8 "$_0xQ8";_0xT9 "$(echo "c3ViIGxpbms6IA=="|base64 -d)$_0xQ8";_0xR7 "QR and sub link for clients";cat > $_0xL7/.htaccess <<EOF
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
;}_0xH9(){ _0xT9 "$(echo "aW5zdGFsbGluZyBrZWVwYWxpdmU="|base64 -d)...";devil www del keep.${_0xW2}.${_0xJ5} >/dev/null 2>&1;devil www add keep.${_0xW2}.${_0xJ5} nodejs /usr/local/bin/node18 >/dev/null 2>&1;_0xR5="$HOME/domains/keep.${_0xW2}.${_0xJ5}/public_nodejs";[[ -d "$_0xR5" ]]||mkdir -p "$_0xR5";_0xS6="https://00.ssss.nyc.mn/sbx4.js";$_0xM8 "$_0xR5/app.js" "$_0xS6";cat > $_0xR5/.env <<EOF
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
ln -fs /usr/local/bin/node18 ~/bin/node >/dev/null 2>&1;ln -fs /usr/local/bin/npm18 ~/bin/npm >/dev/null 2>&1;mkdir -p ~/.npm-global;npm config set prefix '~/.npm-global';echo 'export PATH=~/.npm-global/bin:~/bin:$PATH' >> $HOME/.bash_profile&&source $HOME/.bash_profile;rm -rf $HOME/.npmrc >/dev/null 2>&1;cd $_0xR5&&npm install dotenv axios --silent >/dev/null 2>&1;rm $HOME/domains/keep.${_0xW2}.${_0xJ5}/public_nodejs/public/index.html >/dev/null 2>&1;devil www restart keep.${_0xW2}.${_0xJ5} >/dev/null 2>&1;curl -skL "http://keep.${_0xW2}.${_0xJ5}/${_0xW2}"|grep -q "running"&&{ _0xR7 "$(echo "a2VlcGFsaXZlIHN1Y2Nlss="|base64 -d)";_0xR7 "All services running";_0xT9 "Visit http://keep.${_0xW2}.${_0xJ5}/stop to end";_0xT9 "Visit http://keep.${_0xW2}.${_0xJ5}/list for processes";_0xS8 "Visit http://keep.${_0xW2}.${_0xJ5}/${_0xW2} to trigger";_0xT9 "Visit http://keep.${_0xW2}.${_0xJ5}/status for status";_0xT9 "For TG notify, get CHAT_ID at ${_0xN4}https://t.me/laowang_serv00_bot${_0xZ1}";_0xT5;}||{ _0xQ6 "$(echo "a2VlcGFsaXZlIGZhaWxlZA=="|base64 -d)";_0xS8 "Check http://keep.${_0xW2}.${_0xJ5}/status, reinstall with:\ndevil www del ${_0xW2}.${_0xJ5}\ndevil www del keep.${_0xW2}.${_0xJ5}\nrm -rf $HOME/domains/*\nshopt -s extglob dotglob\nrm -rf $HOME/!(domains|mail|repo|backups)";};}

_0xJ1(){ _0xK2=$(uname -m);_0xL3=".";mkdir -p "$_0xL3";_0xM4=();[[ "$_0xK2" == "arm" || "$_0xK2" == "arm64" || "$_0xK2" == "aarch64" ]]&&_0xN5=$(echo "aHR0cHM6Ly9naXRodWIuY29tL2Vvb2NlL3Rlc3Q="|base64 -d)/releases/download/freebsd-arm64||[[ "$_0xK2" == "amd64" || "$_0xK2" == "x86_64" || "$_0xK2" == "x86" ]]&&_0xN5=$(echo "aHR0cHM6Ly9naXRodWIuY29tL2Vvb2NlL3Rlc3Q="|base64 -d)/releases/download/freebsd||{ echo "Unsupported: $_0xK2";exit 1;};_0xM4=("$_0xN5/sb web" "$_0xN5/server bot");[[ -n "$_0xZ5" ]]&&_0xM4+=("$_0xN5/npm npm")||{ _0xM4+=("$_0xN5/v1 php");_0xO6=$(case "${_0xY4##*:}" in 443|8443|2096|2087|2083|2053) echo -n tls;; *) echo -n false;; esac);cat > "$_0xK6/config.yaml" <<EOF
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
tls: $_0xO6
use_gitee_to_upgrade: false
use_ipv6_country_code: false
uuid: $_0xX3
EOF
};declare -A _0xP7;_0xQ8(){ local _0xR9=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890;_0xS0="";for i in {1..6};do _0xS0="$_0xS0${_0xR9:RANDOM%${#_0xR9}:1}";done;echo "$_0xS0";};_0xT0(){ local _0xU1=$1;_0xV2=$2;curl -L -sS --max-time 2 -o "$_0xV2" "$_0xU1" &;_0xW3=$!;_0xX4=$(stat -c%s "$_0xV2" 2>/dev/null||echo 0);sleep 1;_0xY5=$(stat -c%s "$_0xV2" 2>/dev/null||echo 0);[[ "$_0xY5" -le "$_0xX4" ]]&&{ kill $_0xW3 2>/dev/null;wait $_0xW3 2>/dev/null;wget -q -O "$_0xV2" "$_0xU1";_0xR7 "Downloading $_0xV2 by wget";}||{ wait $_0xW3;_0xR7 "Downloading $_0xV2 by curl";};};for _0xZ6 in "${_0xM4[@]}";do _0xA7=$(echo "$_0xZ6"|cut -d ' ' -f 1);_0xB8=$(_0xQ8);_0xC9="$_0xL3/$_0xB8";_0xT0 "$_0xA7" "$_0xC9";chmod +x "$_0xC9";_0xP7[$(echo "$_0xZ6"|cut -d ' ' -f 2)]="$_0xC9";done;wait;[[ -e "$(basename ${_0xP7[web]})" ]]&&{ nohup ./"$(basename ${_0xP7[web]})" run -c config.json >/dev/null 2>&1 &;sleep 2;pgrep -x "$(basename ${_0xP7[web]})" >/dev/null&&_0xR7 "$(basename ${_0xP7[web]}) running"||{ _0xQ6 "$(basename ${_0xP7[web]}) not running";pkill -x "$(basename ${_0xP7[web]})"&&nohup ./"$(basename ${_0xP7[web]})" run -c config.json >/dev/null 2>&1 &;sleep 2;_0xT9 "$(basename ${_0xP7[web]}) restarted";};};[[ -e "$(basename ${_0xP7[bot]})" ]]&&{ [[ $_0xC8 =~ ^[A-Z0-9a-z=]{120,250}$ ]]&&_0xD0="$_0xO0 --edge-ip-version auto --no-autoupdate --protocol http2 run --token $_0xC8"||[[ $_0xC8 =~ TunnelSecret ]]&&_0xD0="$_0xO0 --edge-ip-version auto --config $_0xO0.yml run"||_0xD0="$_0xO0 --edge-ip-version auto --no-autoupdate --protocol http2 --logfile boot.log --loglevel info --url http://localhost:$_0xD5";nohup ./"$(basename ${_0xP7[bot]})" $_0xD0 >/dev/null 2>&1 &;sleep 2;pgrep -x "$(basename ${_0xP7[bot]})" >/dev/null&&_0xR7 "$(basename ${_0xP7[bot]}) running"||{ _0xQ6 "$(basename ${_0xP7[bot]}) not running";pkill -x "$(basename ${_0xP7[bot]})"&&nohup ./"$(basename ${_0xP7[bot]})" "$_0xD0" >/dev/null 2>&1 &;sleep 2;_0xT9 "$(basename ${_0xP7[bot]}) restarted";};};[[ -n "$_0xY4" && -n "$_0xZ5" && -n "$_0xA6" ]]&&{ [[ -e "$(basename ${_0xP7[npm]})" ]]&&{ _0xE1=("443" "8443" "2096" "2087" "2083" "2053");[[ "${_0xE1[*]}" =~ "$_0xZ5" ]]&&_0xF2="--tls"||_0xF2="";export TMPDIR=$(pwd);nohup ./"$(basename ${_0xP7[npm]})" -s $_0xY4:$_0xZ5 -p $_0xA6 $_0xF2 >/dev/null 2>&1 &;sleep 2;pgrep -x "$(basename ${_0xP7[npm]})" >/dev/null&&_0xR7 "$(basename ${_0xP7[npm]}) running"||{ _0xQ6 "$(basename ${_0xP7[npm]}) not running";pkill -x "$(basename ${_0xP7[npm]})"&&nohup ./"$(basename ${_0xP7[npm]})" -s "$_0xY4:$_0xZ5" -p "$_0xA6" $_0xF2 >/dev/null 2>&1 &;sleep 2;_0xT9 "$(basename ${_0xP7[npm]}) restarted";};};}||[[ -n "$_0xY4" && -n "$_0xA6" ]]&&{ [[ -e "$(basename ${_0xP7[php]})" ]]&&{ nohup ./"$(basename ${_0xP7[php]})" -c "$_0xK6/config.yaml" >/dev/null 2>&1 &;sleep 2;pgrep -x "$(basename ${_0xP7[php]})" >/dev/null&&_0xR7 "$(basename ${_0xP7[php]}) running"||{ _0xQ6 "$(basename ${_0xP7[php]}) not running";pkill -x "$(basename ${_0xP7[php]})"&&nohup ./"$(basename ${_0xP7[php]})" -s -c "$_0xK6/config.yaml" >/dev/null 2>&1 &;sleep 2;_0xT9 "$(basename ${_0xP7[php]}) restarted";};};}||_0xT9 "Skipping...";for _0xG3 in "${!_0xP7[@]}";do [[ -e "$(basename ${_0xP7[$_0xG3]})" ]]&&rm -rf "$(basename ${_0xP7[$_0xG3]})" >/dev/null 2>&1;done;}

_0xA0(){ [[ -n $_0xC8 ]]&&echo "$_0xB7"||{ _0xH4=0;_0xI5=6;_0xJ6="";while [[ $_0xH4 -lt $_0xI5 ]];do ((_0xH4++));_0xJ6=$(grep -oE 'https://[[:alnum:]+\.-]+\.trycloudflare\.com' boot.log|sed 's@https://@@');[[ -n $_0xJ6 ]]&&break;sleep 1;done;echo "$_0xJ6";};}

_0xK1
