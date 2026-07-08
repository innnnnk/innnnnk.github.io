#!/bin/bash
# deploy.sh — Hugo 博客自动构建与部署脚本
# 用法: sh deploy.sh
# 效果: 编译静态文件 -> 强推至远程仓库 main 分支

set -e

BLOG_DIR="$(cd "$(dirname "$0")" && pwd)"
HUGO_BIN="$BLOG_DIR/../hugo/hugo"
PUBLIC_DIR="$BLOG_DIR/public"
REMOTE="git@github.com:innnnnk/innnnnk.github.io.git"
BRANCH="main"

echo "🔨 开始构建博客..."
cd "$BLOG_DIR"
"$HUGO_BIN" --logLevel warn

echo "✅ 构建完成，准备部署..."

cd "$PUBLIC_DIR"

# 如果 public 还不是 git 仓库，初始化
if [ ! -d ".git" ]; then
    echo "📦 初始化 Git 仓库..."
    git init
    git checkout -b "$BRANCH"
    git remote add origin "$REMOTE"
fi

# 确保 remote 指向正确的仓库
CURRENT_REMOTE=$(git remote get-url origin 2>/dev/null || echo "")
if [ "$CURRENT_REMOTE" != "$REMOTE" ]; then
    git remote set-url origin "$REMOTE" 2>/dev/null || git remote add origin "$REMOTE"
fi

echo "📤 推送至远程仓库 ($REMOTE $BRANCH)..."
git add -A
git commit -m "deploy: $(date '+%Y-%m-%d %H:%M:%S UTC')" --allow-empty
git push -f origin "$BRANCH"

echo "🎉 部署成功！"
