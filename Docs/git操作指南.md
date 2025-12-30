# Git 操作指南

## 一、Git 配置

### 1.1 配置用户信息

```bash
# 配置全局用户名
git config --global user.name "Swcmb"

# 配置全局邮箱
git config --global user.email "3216243013@qq.com"
```

### 1.2 查看配置

```bash
# 查看所有配置
git config --list

# 查看用户名
git config user.name

# 查看邮箱
git config user.email
```

---

## 二、Git 状态查看

### 2.1 查看工作区状态

```bash
# 查看当前工作区状态
git status

# 查看简洁状态
git status -s

# 查看未跟踪的文件（不删除，仅查看）
git clean -nd
```

### 2.2 查看修改内容

```bash
# 查看工作区与暂存区的差异
git diff

# 查看暂存区与本地仓库的差异
git diff --staged

# 查看工作区与本地仓库的差异
git diff HEAD

# 查看特定文件的修改
git diff src/backend/parser/gram.y
```

---

## 三、Git 日志查看

### 3.1 查看提交历史

```bash
# 查看提交历史
git log

# 查看简洁的提交历史
git log --oneline

# 查看最近3条提交
git log -n 3

# 查看图形化提交历史
git log --graph --oneline --all
```

### 3.2 导出 Git 日志

```bash
# 导出详细的提交日志
git log --all --pretty=format:"%H %an <%ae> %ad %s" --date=iso > git.log
```

格式说明：
- `%H` - 提交哈希
- `%an` - 作者名
- `%ae` - 作者邮箱
- `%ad` - 作者日期
- `%s` - 提交信息

---

## 四、Git diff 生成 Patch

### 4.1 创建基本 Patch

```bash
# 创建当前工作区的 patch
git diff > my_changes.patch

# 创建包含二进制文件和权限变化的完整 patch
git diff --binary > delete_all_complete.patch
```

### 4.2 创建基于提交的 Patch

```bash
# 基于两个提交之间的差异创建 patch
git diff commit1 commit2 > changes.patch

# 基于分支差异创建 patch
git diff origin/main...your-feature-branch --no-color > delete_all_feature.patch
```

### 4.3 查看生成的 Patch

```bash
# 查看 patch 文件内容
cat my_changes.patch

# 使用 less 分页查看
less my_changes.patch
```

---

## 五、Git Stash 操作

### 5.1 保存当前修改

```bash
# 保存当前修改到 stash
git stash save "backup before applying patch"

# 保存当前修改（不指定消息）
git stash
```

### 5.2 查看 Stash

```bash
# 查看所有 stash
git stash list

# 查看特定 stash 的内容
git stash show stash@{0}
```

### 5.3 恢复 Stash

```bash
# 恢复最新的 stash
git stash pop

# 恢复指定的 stash
git stash pop stash@{0}

# 恢复 stash 但不删除
git stash apply
```

### 5.4 删除 Stash

```bash
# 删除最新的 stash
git stash drop

# 删除所有 stash
git stash clear
```

---

## 六、Git Clean 操作

### 6.1 查看未跟踪的文件

```bash
# 查看未跟踪的文件（不删除）
git clean -nd

# 查看未跟踪的文件和目录
git clean -nd

# 查看将被删除的文件（包括被忽略的文件）
git clean -ndX
```

### 6.2 删除未跟踪的文件

```bash
# 删除未跟踪的文件
git clean -f

# 删除未跟踪的文件和目录
git clean -fd

# 删除被忽略的文件
git clean -fX

# 删除所有未跟踪的文件（包括被忽略的）
git clean -fx
```

---

## 七、常用 Git 工作流程

### 7.1 提交代码

```bash
# 查看修改状态
git status

# 添加文件到暂存区
git add file1 file2

# 提交修改
git commit -m "提交信息"

# 添加并提交所有修改
git add .
git commit -m "提交信息"
```

### 7.2 推送到远程仓库

```bash
# 推送到当前分支
git push

# 推送到指定分支
git push origin main

# 设置上游分支
git push -u origin main
```

### 7.3 拉取远程更新

```bash
# 拉取并合并
git pull

# 拉取但不合并
git fetch

# 拉取并变基
git pull --rebase
```