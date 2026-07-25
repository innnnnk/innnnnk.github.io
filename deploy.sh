#!/bin/bash
# deploy.sh — 博客部署脚本
# 用法: sh deploy.sh
# 效果:
#   1. 本地 Hugo 构建（校验）
#   2. 备份 public/ 到 public_backup/（保留最近 5 次）
#   3. 推送静态文件到 main 分支 → GitHub Pages 自动 serve
#
# GitHub Pages 配置: Source = Deploy from branch, Branch = main, / (root)
# 静态文件直推，无需等 Actions 构建。

set -e

BLOG_DIR="$(cd "$(dirname "$0")" && pwd)"
HUGO_BIN="$BLOG_DIR/../hugo/hugo"
PUBLIC_DIR="$BLOG_DIR/public"
BACKUP_DIR="$BLOG_DIR/public_backup"
KEEP_BACKUPS=5
REMOTE="origin"
BRANCH="main"

echo "🔨 1/3 本地构建校验..."
cd "$BLOG_DIR"
"$HUGO_BIN" --logLevel warn
echo "✅ 构建通过"

echo ""
echo "📦 2/3 备份 public/ ..."
mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
BACKUP_NAME="public-$TIMESTAMP"
cp -r "$PUBLIC_DIR" "$BACKUP_DIR/$BACKUP_NAME"
echo "✅ 备份至 $BACKUP_DIR/$BACKUP_NAME"

# 清理旧备份
BACKUP_COUNT=$(ls -1 "$BACKUP_DIR" 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt "$KEEP_BACKUPS" ]; then
    ls -1t "$BACKUP_DIR" | tail -n +$((KEEP_BACKUPS + 1)) | while read old; do
        rm -rf "$BACKUP_DIR/$old"
        echo "🗑  清理旧备份: $old"
    done
fi

echo ""
echo "📤 3/3 推送静态文件至 $BRANCH 分支..."
cd "$PUBLIC_DIR"

# 初始化 public/ 下的 Git（如果还没初始化）
if [ ! -d ".git" ]; then
    echo "📦 初始化 Git 仓库..."
    git init
    git checkout -b "$BRANCH"
    git remote add origin "git@github.com:innnnnk/innnnnk.github.io.git"
fi

# 确保 remote 正确
CURRENT_REMOTE=$(git remote get-url origin 2>/dev/null || echo "")
if [ "$CURRENT_REMOTE" != "git@github.com:innnnnk/innnnnk.github.io.git" ]; then
    git remote set-url origin "git@github.com:innnnnk/innnnnk.github.io.git"
fi

git config user.name "innnnnk"
git config user.email "innnnnk@users.noreply.github.com"

git add -A
git commit -m "deploy: $(date '+%Y-%m-%d %H:%M:%S UTC')" --allow-empty
git push -f origin "$BRANCH"

echo ""
echo "🎉 部署完成！"
echo "   约 30 秒后刷新 https://innnnnk.github.io/"
echo "   如遇缓存，Ctrl+Shift+R 或等 1-2 分钟"
