#!/bin/sh
# 运行时变量检查
U=${UUID:-$(cat /proc/sys/kernel/random/uuid)}
P=${PATH_WS:-/Faibh1KZ}
B=${BACKEND_PORT:-21522}
D=${DOMAIN:-proxy.example.com}

# 生成配置
cat <<EOF > /etc/sing-box/config.json
{"inbounds":[{"type":"vless","listen":"127.0.0.1","listen_port":$B,"users":[{"uuid":"$U"}],"transport":{"type":"ws","path":"$P"}}],"outbounds":[{"type":"direct"}]}
EOF

# 打印日志
echo "================ [节点信息] ================"
echo "域名: $D"
echo "路径: $P"
echo "UUID: $U"
echo "分享链接: vless://$U@$D:443?path=$(echo "$P" | sed "s/\//%2F/g")&security=tls&type=ws&sni=$D&host=$D&fp=chrome#Claw-Node"
echo "============================================"

# 启动服务
/usr/local/bin/sing-box run -c /etc/sing-box/config.json &
exec /usr/local/bin/cloudflared tunnel --no-autoupdate run --token ${TUNNEL_TOKEN}
