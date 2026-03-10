FROM alpine:latest AS builder
RUN apk add --no-cache curl tar jq

# 下载 Sing-box 核心
RUN curl -L https://github.com/SagerNet/sing-box/releases/latest/download/$(curl -s https://api.github.com/repos/SagerNet/sing-box/releases/latest | jq -r '.assets[] | select(.name | contains("linux-amd64.tar.gz")).name') -o sing-box.tar.gz && \
    tar -xzvf sing-box.tar.gz && \
    mv sing-box-*/sing-box /usr/local/bin/

# 下载 Cloudflared
RUN curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

FROM alpine:latest
RUN apk add --no-cache ca-certificates libc6-compat coreutils && \
    mkdir -p /etc/sing-box

COPY --from=builder /usr/local/bin/sing-box /usr/local/bin/
COPY --from=builder /usr/local/bin/cloudflared /usr/local/bin/

# 入口脚本：直接从环境变量获取配置
RUN echo '#!/bin/sh\n\
# 运行时变量检查\n\
U=${UUID:-$(cat /proc/sys/kernel/random/uuid)}\n\
P=${PATH_WS:-/Faibh1KZ}\n\
B=${BACKEND_PORT:-21522}\n\
D=${DOMAIN:-proxy.example.com}\n\
\n\
cat <<EOF > /etc/sing-box/config.json\n\
{"inbounds":[{"type":"vless","listen":"127.0.0.1","listen_port":$B,"users":[{"uuid":"$U"}],"transport":{"type":"ws","path":"$P"}}],"outbounds":[{"type":"direct"}]}\n\
EOF\n\
\n\
# 打印日志\n\
echo "================ [节点信息] ================"\n\
echo "域名: $D"\n\
echo "路径: $P"\n\
echo "UUID: $U"\n\
echo "分享链接: vless://$U@$D:443?path=$(echo "$P" | sed "s/\//%2F/g")&security=tls&type=ws&sni=$D&host=$D&fp=chrome#Claw-Node"\n\
echo "============================================"\n\
\n\
/usr/local/bin/sing-box run -c /etc/sing-box/config.json &\n\
exec /usr/local/bin/cloudflared tunnel --no-autoupdate run --token ${TUNNEL_TOKEN}' > /entrypoint.sh && \
    chmod +x /entrypoint.sh

ENV TUNNEL_TOKEN="" \
    DOMAIN="" \
    UUID="" \
    PATH_WS="/Faibh1KZ" \
    BACKEND_PORT="21522"

ENTRYPOINT ["/entrypoint.sh"]

# ... (前面的 builder 和阶段保持不变) ...

# 最终阶段拷贝脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# ... (其他的 ENV 和 ENTRYPOINT) ...
ENTRYPOINT ["/entrypoint.sh"]
