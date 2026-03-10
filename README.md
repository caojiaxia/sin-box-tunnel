### Tunnel-Pro Serverless 节点方案
本项目提供了一套轻量化、容器化、基于 Cloudflare Tunnel 和 Sing-box 的高效节点部署方案。它专为像 [Claw Cloud Run] (https://run.claw.cloud) 这样的 Serverless 平台设计，支持自动化的部署流程，并能通过日志输出节点配置信息。

### 特性 
- 极致轻量：基于 Alpine Linux 构建，镜像体积小，启动速度快。
- 双核并行：内置 Sing-box 核心（支持 VLESS+WS）与 Cloudflare Tunnel。
- Serverless 适配：无需维护 VPS，无需担心 IP 被封，自动处理进程信号。
- 日志即节点：自动在容器启动时生成节点信息和分享链接。
- 完全解耦：代码 100% 开源且不含任何个人信息，通过环境变量注入配置

### 环境变量

| 变量名      |   作用                    | 示例    |
|-------------|---------------------------------------|-------------|
| TUNNEL_TOKEN  |（必填）你的CF隧道Token    | eyJh...   |
| DOMAIN        |（必填）你的隧道域名     |  www.abc.com   |
| UUID          |（选填）你的UUID        |   6913e1f1...   |
| PATH_WS       |（选填）自定义WS路径     |   /Faibh1KZkji   |
| BACKEND_PORT    |（选填）内部服务端口    |   21522        |

### 验证与获取链接
- 1.在平台的容器运行面板找到 Logs（日志）。
- 2.查看日志输出，当看到以下内容时，即表示部署成功：
```
================ [节点信息] ================
域名: proxy.example.com
路径: /Faibh1KZ
UUID: 6913e1f1-...
分享链接: vless://...#Claw-Node
============================================
```

### 注意事项
- 私有镜像授权：由于 GHCR 镜像默认为私有，如果在 Claw Run 等平台拉取镜像失败，请确保已在平台配置了 GitHub 的 `Access Token`作为 Registry Auth。
- Cloudflare 设置：在 CF Zero Trust 后台，请确保将 Public Hostname 的 Destination 指向 `http://127.0.0.1:21522` (需与 `BACKEND_PORT` 一致)。

### 许可协议
**本项目基于 MIT 协议开源。**
