#!/bin/sh
# 1. 强制目录
mkdir -p /etc/sing-box

# 2. 运行时变量检查
U=${UUID:-$(cat /proc/sys/kernel/random/uuid)}
P=${PATH_WS:-/Faibh1KZ}
B=${BACKEND_PORT:-21522}
D=${DOMAIN:-proxy.example.com}

# 3. 生成配置
cat <<EOF > /etc/sing-box/config.json
{"inbounds":[{"type":"vless","listen":"127.0.0.1","listen_port":$B,"users":[{"uuid":"$U"}],"transport":{"type":"ws","path":"$P"}}],"outbounds":[{"type":"direct"}]}
EOF

# 4. 重点：将信息输出到 STDERR (在很多日志系统中，stderr 比 stdout 优先级更高)
echo -e "\n\n\n\n\n\n\033[32m================ [节点信息 (请在此截屏)] ================\033[0m" >&2
echo -e "\033[33m域名: $D\033[0m" >&2
echo -e "\033[33m路径: $P\033[0m" >&2
echo -e "\033[33mUUID: $U\033[0m" >&2
echo -e "\033[36m客户端分享链接: vless://$U@$D:443?path=$(echo "$P" | sed "s/\//%2F/g")&security=tls&type=ws&sni=$D&host=$D&fp=chrome#Claw-Node\033[0m" >&2
echo -e "\033[32m========================================================\033[0m\n\n\n\n\n\n" >&2

# 5. 启动服务 (Sing-box 日志定向到 /dev/null，避免干扰)
/usr/local/bin/sing-box run -c /etc/sing-box/config.json > /dev/null 2>&1 &

# 启动 tunnel，cloudflared 的信息也是必要的，我们让它正常输出
exec /usr/local/bin/cloudflared tunnel --no-autoupdate run --token ${TUNNEL_TOKEN}
