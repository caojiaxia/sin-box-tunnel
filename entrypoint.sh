#!/bin/sh

# 1. 强制目录
mkdir -p /etc/sing-box

# 2. 运行时变量检查 - 确保变量不为空
U=${UUID:-$(cat /proc/sys/kernel/random/uuid)}
B=${BACKEND_PORT:-21522}
D=${DOMAIN:-proxy.example.com}

# 路径防御性处理：确保以 / 开头，且去除结尾斜杠
RAW_P=${PATH_WS:-/Faibh1KZ}
P="/$(echo "$RAW_P" | sed 's|^/||;s|/$||')"

# 3. 生成配置 (使用单引号 'EOF' 可以防止 cat 内部的二次转义问题，
# 但这里我们需要变量替换，所以保持 EOF 并对变量加双引号)
cat <<EOF > /etc/sing-box/config.json
{
  "inbounds": [{
    "type": "vless",
    "listen": "127.0.0.1",
    "listen_port": $B,
    "users": [{"uuid": "$U"}],
    "transport": {
      "type": "ws",
      "path": "$P"
    }
  }],
  "outbounds": [{"type": "direct"}]
}
EOF

# 4. 节点信息输出优化
# 对路径进行 URL 编码处理，避免链接被截断
ENCODED_P=$(echo "$P" | sed 's/\//%2F/g')

echo -e "\n\033[32m================ [节点信息] ================\033[0m" >&2
echo -e "\033[33m域名 (Address): $D\033[0m" >&2
echo -e "\033[33m路径 (Path):    $P\033[0m" >&2
echo -e "\033[33mUUID:           $U\033[0m" >&2
echo -e "\033[36m分享链接: vless://$U@$D:443?path=$ENCODED_P&security=tls&type=ws&sni=$D&host=$D&fp=chrome#Claw-Node\033[0m" >&2
echo -e "\033[32m============================================\033[0m\n" >&2

# 5. 启动服务
/usr/local/bin/sing-box run -c /etc/sing-box/config.json > /dev/null 2>&1 &
exec /usr/local/bin/cloudflared tunnel --no-autoupdate run --token "${TUNNEL_TOKEN}"
