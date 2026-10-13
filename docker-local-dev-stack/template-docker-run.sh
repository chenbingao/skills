#!/usr/bin/env bash
# 本地开发环境模板：一个容器内跑 nginx + 两个应用副本。
#
# 复制到项目根目录（如 docker-run.sh），替换所有 <尖括号> 占位符即可。
# 按 Ctrl-C 停止：容器 --rm 停止即销毁，编译产物在命名卷里保留。
#
# ⚠️ 中文脚本注意：变量后面**紧跟非 ASCII 字符时必须写 ${VAR}**。
#    写成 `$IMAGE（含 nginx）` 会让 bash 把多字节字符并进变量名，
#    报 `IMAGE\uFFFD: unbound variable`。本模板已全部使用花括号。
set -euo pipefail
cd "$(dirname "$0")"

IMAGE="<project>-base:<toolchain-version>"      # 如 myapp-base:1.94-bookworm
CONTAINER="<project>-local"
TARGET_VOL="<project>-target-cache"
HOST_PORT="${HOST_PORT:-8080}"                  # 与机器上其他项目冲突时用 HOST_PORT=xxxx ./docker-run.sh
PROJECT_DIR="$PWD"

GREEN="\033[32m"; RED="\033[31m"; YELLOW="\033[33m"; RESET="\033[0m"

cleanup() {
    local code="${1:-$?}"
    trap - EXIT SIGINT SIGTERM
    echo ""
    echo "🛑 停止服务..."
    docker rm -f "${CONTAINER}" >/dev/null 2>&1 || true
    echo -e "${GREEN}✅ 已清理${RESET}（卷 ${TARGET_VOL} 保留，编译产物不丢）"
    exit "${code}"
}
trap 'cleanup 130' SIGINT
trap 'cleanup 143' SIGTERM
trap 'cleanup $?' EXIT

echo "📋 检查环境..."
[[ -f .env ]] || { echo -e "${RED}❌ 缺少 .env${RESET}（可复制 .env.example）"; exit 1; }
docker info >/dev/null 2>&1 || { echo -e "${RED}❌ Docker 未运行${RESET}"; exit 1; }

# ── ① 基础镜像：只构建一次（全部 OS 级依赖在这里装好） ────────────────────
if docker image inspect "${IMAGE}" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ 基础镜像已存在${RESET}: ${IMAGE}"
else
    echo "🔨 构建基础镜像 ${IMAGE} ..."
    docker build -f docker/Dockerfile.dev -t "${IMAGE}" .
fi

# ── ② 编译产物卷（保留，跨容器复用，避免每次全量重编） ───────────────────
docker volume inspect "${TARGET_VOL}" >/dev/null 2>&1 || docker volume create "${TARGET_VOL}" >/dev/null

# ── ③ 挂载运行 ────────────────────────────────────────────────────────
docker rm -f "${CONTAINER}" >/dev/null 2>&1 || true
echo ""
echo "🚀 启动容器..."
docker run --rm --name "${CONTAINER}" \
    -p "${HOST_PORT}:8080" \
    -v "${PROJECT_DIR}:/workspace" \
    -v "${TARGET_VOL}:/workspace/target" \
    -v "${HOME}/.cargo/registry:/usr/local/cargo/registry" \
    -v "${HOME}/.cargo/git:/usr/local/cargo/git" \
    -v "${PROJECT_DIR}/docker/nginx.conf:/etc/nginx/nginx.conf:ro" \
    --env-file .env \
    "${IMAGE}" bash -c '
set -e
cd /workspace

echo ""
echo "=========================================="
echo "  <project> 本地开发环境"
echo "=========================================="
echo ""

echo "🚀 [1/4] 编译"
cargo build 2>&1 | tail -3

echo ""
echo "🚀 [2/4] 执行数据库迁移（独立步骤，服务启动时不迁移）"
./target/debug/<binary> migrate

echo ""
echo "🚀 [3/4] 启动两个副本（8081 / 8181）"
SERVER_PORT=8081 ./target/debug/<binary> serve > /tmp/app1.log 2>&1 &
SERVER_PORT=8181 ./target/debug/<binary> serve > /tmp/app2.log 2>&1 &

wait_ready() {
    local name="$1" port="$2" logfile="$3" waited=0
    while (( waited < 60 )); do
        if curl -fsS "http://127.0.0.1:${port}/healthz/startup" >/dev/null 2>&1; then
            echo "   ✅ ${name} 就绪 (127.0.0.1:${port})"
            return 0
        fi
        sleep 1
        (( waited += 1 ))
    done
    echo "   ❌ ${name} 在 60s 内未就绪，日志尾部："
    tail -20 "${logfile}" || true
    return 1
}
wait_ready "副本1" 8081 /tmp/app1.log
wait_ready "副本2" 8181 /tmp/app2.log

echo ""
echo "🚀 [4/4] 启动 nginx"
nginx -t
nginx
sleep 1

echo ""
echo "=========================================="
echo "  已启动"
echo "=========================================="
echo "  入口:       http://localhost:8080/healthz/live"
echo "  nginx 日志: /var/log/nginx/access.log（含 upstream=，可看请求落到哪个副本）"
echo ""
echo "  按 Ctrl-C 停止"
echo ""

# 汇总输出：两个副本 + nginx
tail -f /tmp/app1.log /tmp/app2.log /var/log/nginx/access.log /var/log/nginx/error.log
'
