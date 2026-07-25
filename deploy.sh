#!/bin/bash
# deploy.sh — 博客部署脚本
# 用法: sh deploy.sh
# 效果:
#   1. 本地 Hugo 构建（校验 + 备份）
#   2. 备份 public/ 到 public_backup/（保留最近 5 次）
#   3. 推送源文件到 master → GitHub Actions 自动部署
#
# GitHub Actions 是正式部署路径，本地构建仅用于校验和备份。

set -e

BLOG_DIR="$(cd "$(dirname "$0")" && pwd)"
HUGO_BIN="$BLOG_DIR/../hugo/hugo"
BACKUP_DIR="$BLOG_DIR/public_backup"
KEEP_BACKUPS=5

echo "🔨 1/3 本地构建校验..."
cd "$BLOG_DIR"
"$HUGO_BIN" --logLevel warn
echo "✅ 构建通过"

echo ""
echo "📦 2/3 备份 public/ ..."
mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
BACKUP_NAME="public-$TIMESTAMP"
cp -r "$BLOG_DIR/public" "$BACKUP_DIR/$BACKUP_NAME"
echo "✅ 备份至 $BACKUP_DIR/$BACKUP_NAME"

# 清理旧备份，只保留最近 KEEP_BACKUPS 次
BACKUP_COUNT=$(ls -1 "$BACKUP_DIR" 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt "$KEEP_BACKUPS" ]; then
    ls -1t "$BACKUP_DIR" | tail -n +$((KEEP_BACKUPS + 1)) | while read old; do
        rm -rf "$BACKUP_DIR/$old"
        echo "🗑  清理旧备份: $old"
    done
fi

echo ""
echo "📤 3/3 推送源文件至 master（触发 GitHub Actions 部署）..."
cd "$BLOG_DIR"

# 检查是否有改动
if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
    echo "✅ 没有需要推送的改动，跳过。"
    exit 0
fi

echo "📋 待推送内容："
git status --short

git add -A
git commit -m "deploy: $(date '+%Y-%m-%d %H:%M:%S UTC')" --allow-empty
git push origin master

echo ""
echo "🎉 完成！GitHub Actions 正在构建部署..."
echo "   部署状态: https://github.com/innnnnk/innnnnk.github.io/actions"
echo "   本地备份: $BACKUP_DIR/$BACKUP_NAME"
echo "   约 1-2 分钟后刷新 https://innnnnk.github.io/"
