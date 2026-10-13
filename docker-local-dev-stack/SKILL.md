---
name: docker-local-dev-stack
description: Use when setting up or repairing a local Docker development environment for a backend service — one container running nginx plus N app replicas on different ports, with all logs aggregated to the console. Covers base-image reuse, mounting the host dependency cache, trap cleanup, and the runtime-only pitfalls (multibyte $VAR, kill 0, SIGINT on background jobs, nginx round-robin skew). 适用于「本地 docker 开发环境」「容器内 nginx 负载均衡」「多副本调试」「日志汇总到控制台」这类需求。
---

# Docker 本地开发环境（单容器 + nginx + 多副本）

## Overview

**一个容器里同时跑 nginx 和 N 个应用副本，只对宿主暴露 nginx 一个端口，所有日志 `tail -f` 汇总到控制台。**

```
宿主                          容器 <project>-local
 :8080 ───────────────────►  nginx :8080
                                ├─► 副本0  127.0.0.1:8081 → /tmp/<app>1.log
                                └─► 副本1  127.0.0.1:8181 → /tmp/<app>2.log
                             项目源码 ──bind mount──► /workspace
                             编译产物 ──命名卷──────► /workspace/target
                             ~/.cargo/{registry,git} ─bind mount─► 复用宿主依赖缓存
```

**为什么用这个形态**（而不是 compose / 多容器）：

| 好处 | 说明 |
|---|---|
| 只暴露一个端口 | 端口冲突面最小；副本走 `127.0.0.1:<port>` 容器内互访 |
| 无自定义网络、无服务发现 | 不需要 DNS、不需要容器名解析，不受 nginx 启动时缓存 IP 的影响 |
| 日志天然聚合 | 副本写 `/tmp/*.log`，结尾一条 `tail -f` 就把 nginx + 全部副本汇总到控制台，不需要 `docker logs` 拼接 |
| 多副本仍是真多副本 | 两个**进程**、两个端口，足以暴露「状态留在进程内」「定时任务重复执行」「会话不共享」这类问题 |
| 基础镜像只建一次 | 首次构建后按镜像名复用，日常启动只需秒级 |

**何时不要用**：需要模拟 Pod 级隔离/崩溃、需要多机网络、需要 K8s 语义时——那属于集群验证，不是本地开发。

## 启动脚本的六个固定动作

1. **基础镜像只构建一次**：`docker image inspect "$IMAGE"` 判断，不存在才 `docker build`（Dockerfile 里装齐**全部 OS 级依赖**：nginx、curl、工具链）。
2. **清理同名容器**：`docker rm -f "$CONTAINER"`，保证脚本可反复执行。
3. **`docker run --rm`**：容器停止即销毁；**只发布 nginx 端口**，副本端口不发布。
4. **容器内一次跑完**：`编译 → 迁移 → 起 N 个副本（不同端口，日志重定向到 /tmp）→ 轮询就绪 → 起 nginx`。
5. **`tail -f` 汇总**：`tail -f /tmp/<app>*.log /var/log/nginx/access.log /var/log/nginx/error.log`，脚本因此常驻前台。
6. **`trap` 清理**：`SIGINT`/`SIGTERM`/`EXIT` 三个都挂上，退出时 `docker rm -f`。

模板：`template-docker-run.sh`、`template-nginx.conf`（本目录）。

## 坑（全部为实测踩出来的）

| # | 现象 | 原因 | 对策 |
|---|---|---|---|
| 1 | `./run.sh: line N: IMAGE\uFFFD: unbound variable` | **`$VAR` 后面紧跟中文字符**（如 `$IMAGE（含...）`）时，bash 把多字节字符并进变量名。中文脚本必踩 | 紧跟非 ASCII 时一律写 `${VAR}` |
| 2 | 脚本退出时把自己的父 shell 也杀了 | `trap 'kill 0'` 杀的是**整个进程组** | 不要用 `kill 0`；只清理自己的子进程 |
| 3 | `trap ... SIGINT` 不触发，后台 `docker logs` 残留 | **POSIX：非交互 shell 启动的后台作业，SIGINT/SIGQUIT 被设为忽略**，被忽略的信号不执行 trap | 用 `SIGTERM`/`EXIT` 验证清理逻辑；交互式 Ctrl-C 本身会整组收到信号 |
| 4 | 只用 `kill $(jobs -p)` 清不干净 | 在 `cmd1 \| cmd2 &` 管道里，`jobs -p` 只给出**末端**进程 | 用 `pkill -P $$` 清理全部直接子进程 |
| 5 | 请求几乎全落同一个副本（实测 9:1） | **nginx 的 round-robin 计数器是每个 worker 各自维护、都从第一个 peer 开始**；`worker_processes auto` 下并发连接被不同 worker 接受 | `worker_processes 1;` → 实测逐请求严格交替 |
| 6 | 停掉一个副本后请求卡 3 秒（`rt=3.007`）反复出现 | 容器/端口停掉后是**连接超时**而非「连接被拒」；默认 `max_fails=3` + `connect_timeout 3s` | `max_fails=1 fail_timeout=10s` + `proxy_connect_timeout 1s` → 只有首个请求付 1s |
| 7 | 每次启动都全量重编译 | macOS 宿主（Mach-O）与 Linux 容器（ELF）**共用同一个 target 目录**，cargo 认为产物全部失效 | 二选一：target 挂**命名卷**隔离；或用 aixlink 那招 `cargo build --target ${RUST_TARGET}`（按三元组分目录，宿主/容器天然错开） |
| 8 | 容器起不来，端口被占 | 机器上其他项目已占用该端口（先 `docker ps` 看） | 宿主端口做成可覆盖变量 `HOST_PORT`，冲突时换 |
| 9 | 单独重建某个副本后 nginx 仍打旧地址 | nginx **启动时解析 upstream 主机名并缓存 IP** | 本形态下 upstream 写 `127.0.0.1:<port>`，地址恒定，天然规避 |

## nginx 开发配置要点

```nginx
worker_processes 1;                    # 坑 #5：多 worker 会导致分布倾斜
http {
    log_format dev '$remote_addr -> $upstream_addr "$request" $status rt=$request_time';
    access_log /var/log/nginx/access.log dev;   # 带 $upstream_addr 才能确认落到哪个副本
    upstream backend {
        server 127.0.0.1:8081 max_fails=1 fail_timeout=10s;   # 坑 #6
        server 127.0.0.1:8181 max_fails=1 fail_timeout=10s;
    }
    server {
        listen 8080;
        location / { proxy_pass http://backend; proxy_connect_timeout 1s; }
    }
}
```

`$upstream_addr` 是排查的关键：**默认 `combined` 格式里没有它**，没有它就无法判断请求落到了哪个副本。

## 验证清单

- [ ] `docker ps` 只有一个本项目容器，且只映射了 nginx 那一个端口
- [ ] 连打 N 次 `curl`，`access.log` 里 `$upstream_addr` **交替出现**（不交替 → 查坑 #5）
- [ ] 停掉一个副本，客户端**不报错**（日志出现 `addr1, addr2` 即发生故障转移）
- [ ] 控制台能同时看到三类输出：副本日志、nginx access、nginx error
- [ ] `Ctrl-C` 后容器消失，但**卷仍在**（编译产物可复用）

## 速查表

| 需求 | 做法 |
|---|---|
| 复用宿主依赖缓存 | `-v "$HOME/.cargo/registry:/usr/local/cargo/registry"` + `git` 同理（平台无关，可安全共享） |
| 隔离编译产物 | target 挂命名卷（`<project>-target-cache`），或按三元组分目录 |
| 等副本就绪再起 nginx | 容器内轮询 `curl -fsS http://127.0.0.1:<port>/healthz`，超时打印该副本日志尾部 |
| 迁移与启动分离 | 启动脚本里先跑一次 `migrate`，服务进程**只断言版本、不迁移**（多副本并发迁移会互相等锁） |
| 基础镜像复用 | `docker image inspect` 判断存在性；镜像名带工具链版本，如 `<project>-base:1.94-bookworm` |
