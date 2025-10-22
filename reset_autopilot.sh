#!/usr/bin/env bash
set -euo pipefail

# =========================
# Reset Zero-Command Autopilot & Git
# Usage:
#   bash reset_autopilot.sh              # 只清理并重新初始化本地 git（不推远端）
#   bash reset_autopilot.sh <REMOTE_URL> # 清理后绑定新远端并推送（如 https://github.com/you/NewRepo.git）
# =========================

REMOTE_URL="${1:-}"

TS="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="../backup_${TS}"
BACKUP_TAR="../project_backup_${TS}.tar.gz"

echo "==> 创建备份（目录与压缩包）..."
mkdir -p "$BACKUP_DIR"
# 备份整个工程（排除部分重型目录）
tar --exclude='./node_modules' \
    --exclude='./.git' \
    --exclude='./.gradle' \
    --exclude='./build' \
    --exclude='./dist' \
    -czf "$BACKUP_TAR" .
echo "    备份包: $BACKUP_TAR"

# 同时拷贝一份可还原的文件树（便于手动恢复某些文件）
rsync -a --exclude '.git' --exclude 'node_modules' --exclude '.gradle' --exclude 'build' --exclude 'dist' ./ "$BACKUP_DIR"/
echo "    备份目录: $BACKUP_DIR"

echo "==> 移除 Zero-Command Autopilot 相关文件/目录..."
# 明确列出自动化组件（只删这些，不碰业务代码）
TO_REMOVE=(
  ".codex"                 # 本地状态/当前任务/队列
  "autopilot-local"        # watcher
  "scripts/doc_lint.sh"
  "scripts/doc_dup_scan.sh"
  "scripts/code_map.py"
  "scripts/setup_labels.sh"
  "scripts/sast.sh"
  "scripts/license_check.sh"
  "scripts/size_guard.sh"
  ".github/workflows/ci-matrix.yml"
  ".github/paths.yml"
)
for p in "${TO_REMOVE[@]}"; do
  if [ -e "$p" ]; then
    echo "    删除 $p"
    rm -rf "$p"
  fi
done

# 可选：如果根目录的 package.json 是我们放进去的“autopilot 包”，自动移除
if [ -f "package.json" ]; then
  NAME="$(node -pe "try{require('./package.json').name}catch(e){''}")" || NAME=""
  if [[ "$NAME" == "codex-zerocommand-autopilot" || "$NAME" == "codex-multistack-local-autopilot" ]]; then
    echo "    检测到 autopilot 专用 package.json -> 删除 package.json 和 package-lock.json、node_modules/"
    rm -f package.json package-lock.json
    rm -rf node_modules
  fi
fi

echo "==> 处理 DCP/自动化文档（备份后移除）..."
# 仅处理自动化生成的 DCP/TASK 文档；保留你的 docs 结构
if [ -d "docs/dcp" ]; then
  mkdir -p "docs_back/dcp_${TS}"
  # 备份有特征命名的 DCP/TASK 文档
  find docs/dcp -maxdepth 1 -type f \( -name "DCP-*.md" -o -name "*TASK*.md" \) -print0 | while IFS= read -r -d '' f; do
    echo "    备份并删除 DCP: $f"
    cp "$f" "docs_back/dcp_${TS}/" && rm -f "$f"
  done
  # 若目录空了可选删除（不强制）
  rmdir docs/dcp 2>/dev/null || true
fi

# 清理 reference/adr 中明显由自动化创建的空占位（保守处理，只删空/几行的 README）
for f in docs/reference/README.md docs/adr/README.md; do
  if [ -f "$f" ]; then
    # 如果文件 < 4 行视为占位，删除
    LINES=$(wc -l < "$f" | tr -d ' ')
    if [ "$LINES" -le 4 ]; then
      echo "    删除占位文档: $f"
      rm -f "$f"
    fi
  fi
done

echo "==> 清理 Git 历史（删除 .git）..."
if [ -d ".git" ]; then
  rm -rf .git
  echo "    .git 已删除"
fi

echo "==> 重新初始化 Git 仓库..."
git init
git add -A
git commit -m "chore: fresh init (remove codex-zerocommand-autopilot & reset git)"

if [ -n "$REMOTE_URL" ]; then
  echo "==> 绑定新远端并推送 main ..."
  # 确保在 main 分支
  git checkout -B main
  git remote add origin "$REMOTE_URL" || { echo "    警告: 添加 origin 失败，可能已存在"; true; }
  git push -u origin main
fi

echo
echo "🎉 完成："
echo "  • 备份包: $BACKUP_TAR"
echo "  • 备份目录: $BACKUP_DIR"
if [ -n "$REMOTE_URL" ]; then
  echo "  • 已推送到: $REMOTE_URL (分支 main)"
else
  echo "  • 当前为本地干净仓库（未绑定远端）。若需绑定新仓库："
  echo "      git remote add origin <NEW_REMOTE_URL>"
  echo "      git push -u origin main"
fi

