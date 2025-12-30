# CentOS 7 使用 patch 文件进行代码更新完整指南

## 一、准备阶段

### 1.1 检查系统环境

首先确保 CentOS 7 系统已安装必要的工具：

```bash
# 检查 patch 命令是否已安装
which patch

# 如果未安装，使用 yum 安装
sudo yum install -y patch

# 验证安装
patch --version
```

### 1.2 准备工作目录

```bash
# 创建工作目录
mkdir -p ~/postgres-patch-work
cd ~/postgres-patch-work

# 确保在 PostgreSQL 源码目录中
cd /root/db/postgresql-15.15
```

---

## 二、创建 Patch 文件

### 2.1 使用 git diff 创建统一格式 patch

```bash
# 查看当前修改状态
git status

# 创建包含二进制文件和权限变化的完整 patch
git diff --binary > delete_all_complete.patch
```

### 2.2 查看生成的 patch 文件内容

```bash
# 查看 patch 文件内容
cat delete_all_feature.patch

# 或者使用 less 分页查看
less delete_all_feature.patch
```

---

## 三、应用 Patch 文件

### 3.1 应用前的准备工作

```bash
# 1. 备份当前源码（重要！）
tar -czf postgresql-15.15-backup-$(date +%Y%m%d-%H%M%S).tar.gz postgresql-15.15/

# 2. 或者使用 git stash 保存当前修改
cd /root/db/postgresql-15.15
git stash save "backup before applying patch"

# 3. 检查目标目录状态
cd /root/db/postgresql-15.15
git status
# 查看未跟踪的文件（不删除，仅查看）
git clean -nd
```

### 3.2 应用 patch 的基本命令

```bash
# 方法1: 应用完整的 patch 文件
patch -p1 < delete_all_feature.patch

# 方法2: 指定 patch 文件路径
patch -p1 < ~/postgres-patch-work/delete_all_feature.patch

# 方法3: 从标准输入应用
cat delete_all_feature.patch | patch -p1
```

### 3.3 Patch 命令参数说明

| 参数        | 说明                       | 示例                                                        |
| ----------- | -------------------------- | ----------------------------------------------------------- |
| `-p0`       | 不删除路径前缀             | 适用于完全匹配的路径                                        |
| `-p1`       | 删除一级路径前缀（推荐）   | `a/src/backend/parser/gram.y` → `src/backend/parser/gram.y` |
| `-p2`       | 删除两级路径前缀           | 适用于嵌套更深的路径                                        |
| `--dry-run` | 测试运行，不实际应用       | 先测试 patch 是否能成功应用                                 |
| `--check`   | 检查 patch 是否能应用      | 类似 --dry-run，但输出更详细                                |
| `-R`        | 反向应用 patch（撤销修改） | 回退已应用的 patch                                          |
| `-b`        | 创建备份文件               | 自动创建 `.orig` 备份                                       |
| `--verbose` | 显示详细信息               | 查看详细的 patch 应用过程                                   |

### 3.4 安全应用 patch 的推荐步骤

```bash
# 步骤1: 测试 patch 是否能成功应用（不实际修改文件）
patch -p1 --dry-run --check < delete_all_feature.patch

# 步骤2: 如果测试通过，应用 patch 并创建备份
patch -p1 -b < delete_all_feature.patch

# 步骤3: 查看应用结果
echo $?
# 0 表示成功，非 0 表示失败

# 步骤4: 检查修改的文件
git status
git diff
```

### 3.5 应用单个文件的 patch

```bash
# 应用 gram.y 的 patch
patch -p1 < gram_y.patch

# 应用 parsenodes.h 的 patch
patch -p1 < parsenodes_h.patch

# 应用 analyze.c 的 patch
patch -p1 < analyze_c.patch
```

---

## 四、验证 Patch 是否成功应用

### 4.1 检查 patch 应用状态

```bash
# 方法1: 检查 git 状态
cd /root/db/postgresql-15.15
git status
# 应该显示已修改的文件
```

### 4.2 查看修改的具体内容

```bash
# 查看具体的修改内容
git diff src/backend/parser/gram.y
git diff src/include/nodes/parsenodes.h
git diff src/backend/parser/analyze.c

# 或者查看所有修改
git diff
```

### 4.3 检查代码修改是否正确

```bash
# 检查 gram.y 中的 DeleteStmt 规则
grep -A 25 "^DeleteStmt:" src/backend/parser/gram.y

# 检查 parsenodes.h 中的 DeleteStmt 结构
grep -A 10 "^typedef struct DeleteStmt" src/include/nodes/parsenodes.h

# 检查 analyze.c 中的 DELETE ALL 处理逻辑
grep -A 15 "DELETE ALL" src/backend/parser/analyze.c
```

### 4.4 验证特定修改点

```bash
# 验证 gram.y 中是否添加了 deleteAll 字段初始化
grep "deleteAll" src/backend/parser/gram.y
# 应该看到两行：deleteAll = false 和 deleteAll = true

# 验证 parsenodes.h 中是否添加了 deleteAll 字段
grep "deleteAll" src/include/nodes/parsenodes.h
# 应该看到一行：bool deleteAll;

# 验证 analyze.c 中是否添加了 DELETE ALL 处理逻辑
grep -B 5 -A 10 "stmt->deleteAll" src/backend/parser/analyze.c
# 应该看到 if-else 条件判断
```

---

## 五、遇到冲突时的解决方案

### 5.1 识别冲突

当应用 patch 时遇到冲突，patch 命令会输出类似以下信息：

```
patching file src/backend/parser/gram.y
Hunk #1 succeeded at 12043 with fuzz 2.
Hunk #2 FAILED at 12056.
1 out of 2 hunks FAILED -- saving rejects to file src/backend/parser/gram.y.rej
```

### 5.2 查看冲突文件

```bash
# 查看生成的拒绝文件（.rej）
cat src/backend/parser/gram.y.rej

# 查看原始文件（带有冲突标记）
cat src/backend/parser/gram.y
```

### 5.3 解决冲突的三种方法

#### 方法1: 手动合并（推荐）

```bash
# 1. 备份当前文件
cp src/backend/parser/gram.y src/backend/parser/gram.y.backup

# 2. 使用文本编辑器打开文件
vim src/backend/parser/gram.y
# 或
nano src/backend/parser/gram.y

# 3. 查找冲突标记（通常以 <<<<<<<, =======, >>>>>>> 标记）
# 4. 手动合并代码，保留正确的修改

# 5. 保存文件
```

#### 方法2: 使用三路合并工具

```bash
# 使用 meld 工具（可视化合并）
sudo yum install -y meld
meld src/backend/parser/gram.y.rej src/backend/parser/gram.y

# 或使用 vimdiff
vimdiff src/backend/parser/gram.y.rej src/backend/parser/gram.y
```

#### 方法3: 重新生成 patch

```bash
# 如果目标代码已经变化，需要重新生成 patch
# 1. 获取目标代码的最新版本
git fetch origin
git checkout origin/main

# 2. 基于最新版本重新生成 patch
git diff origin/main...your-feature-branch --no-color > delete_all_feature.patch

# 3. 应用新的 patch
patch -p1 < delete_all_feature.patch
```

### 5.4 使用 patch 的合并选项

```bash
# 尝试应用带有冲突的 patch（会创建 .orig 和 .rej 文件）
patch -p1 --merge < delete_all_feature.patch

# 查看拒绝文件
cat src/backend/parser/gram.y.rej

# 手动编辑文件解决冲突后，删除 .rej 文件
rm src/backend/parser/gram.y.rej

# 验证修改
git diff src/backend/parser/gram.y
```

### 5.5 常见冲突场景及解决方案

#### 场景1: 目标文件已修改

```bash
# 问题描述：目标文件已有其他修改，导致 patch 失败
# 解决方案：
# 1. 备份当前修改
git stash

# 2. 应用 patch
patch -p1 < delete_all_feature.patch

# 3. 重新应用之前的修改
git stash pop

# 4. 手动解决合并冲突
```

#### 场景2: 行号偏移

```bash
# 问题描述：代码行号发生变化，导致 patch 找不到目标位置
# 解决方案：使用 --fuzz 选项允许行号偏移
patch -p1 --fuzz=3 < delete_all_feature.patch
```

#### 场景3: 空格或缩进差异

```bash
# 问题描述：空格或缩进格式不同导致匹配失败
# 解决方案：使用 --ignore-whitespace 选项
patch -p1 --ignore-whitespace < delete_all_feature.patch
```

#### 场景4: 完全无法应用

```bash
# 问题描述：目标文件变化太大，无法自动应用
# 解决方案：手动应用修改
# 1. 查看 .rej 文件了解需要修改的内容
cat src/backend/parser/gram.y.rej

# 2. 手动在目标文件中添加相应修改
vim src/backend/parser/gram.y

# 3. 删除 .rej 文件
rm src/backend/parser/gram.y.rej

# 4. 验证修改
git diff src/backend/parser/gram.y
```