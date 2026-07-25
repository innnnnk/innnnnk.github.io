---
title: "博客部署流程"
description: "deploy.sh 工作方式、备份机制、GitHub Actions 部署路径"
date: 2026-07-25T09:01:00+08:00
slug: "blog-deploy-guide"
weight: -9
draft: false
tags:
  - 工具
  - 博客
---

## 一句话

```
sh deploy.sh  →  本地校验 + 备份  →  push master  →  GitHub Actions 自动部署
```

## 部署路径

部署由 **GitHub Actions**（`.github/workflows/hugo.yml`）自动完成，不是本地构建后强推。

```
blog/content/*.md  (源文件)
    ↓ git push master
    ↓
GitHub Actions 触发
    ↓ hugo --minify
    ↓ deploy to Pages
    ↓
https://innnnnk.github.io/  (生效)
```

**不要**尝试推预构建文件到 `main` 分支——会被 Actions 的部署覆盖。

## deploy.sh 做了什么

| 步骤 | 操作 | 说明 |
|---|---|---|
| 1 | `hugo --logLevel warn` | 本地构建校验，过不了直接报错 |
| 2 | `cp -r public/ → public_backup/public-YYYYMMDD-HHMMSS/` | 保留最近 5 次构建备份 |
| 3 | `git add -A && git commit && git push origin master` | 推送源文件，触发 Actions |

## 备份

备份存在 `blog/public_backup/` 下，格式 `public-20260725-0900`。自动保留最近 5 次，旧的自动清理。

回退时：找到对应备份目录，里面是完整的静态站点，可以直接 serve 或对比差异。

## 查看部署状态

推送后去 [Actions 页面](https://github.com/innnnnk/innnnnk.github.io/actions) 看构建进度。

约 1-2 分钟后刷新站点。

## 常见问题

### 推了但网站没更新？

1. 检查 Actions 是否成功：[https://github.com/innnnnk/innnnnk.github.io/actions](https://github.com/innnnnk/innnnnk.github.io/actions)
2. 如果 Actions 失败了，看日志修问题
3. 如果 Actions 成功了但网站不变：等 1 分钟 CDN 刷新，或用无痕窗口打开

### 推错了想回退？

```sh
# 找到源仓库本地目录
cd blog
git log --oneline -5
git revert <commit_hash>
git push origin master
```

如果需要从备份恢复特定版本：

```sh
# 查看备份列表
ls public_backup/

# 恢复某次备份（会覆盖 public/）
cp -r public_backup/public-20260725-0900/* public/
```

### 新增了子文档但博客列表页不显示？

确认 frontmatter 里有 `weight` 字段（决定排序），且 `draft: false`。

`_index.md` 里的 `sortBy: 'Weight'` 会按 weight 从小到大排列文章。
