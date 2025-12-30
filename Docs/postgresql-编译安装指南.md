# PostgreSQL 源码编译安装指南

## 一、环境准备

### 1.1 安装依赖包

在 CentOS 7 系统上，首先需要安装编译 PostgreSQL 所需的依赖包：

```bash
sudo yum install -y readline-devel zlib-devel libicu-devel openssl-devel pam-devel libxml2-devel libxslt-devel systemd-devel
```

### 1.2 下载源码

下载 PostgreSQL 源码包并解压：

```bash
tar -xvf postgresql-15.15.tar.gz
cd postgresql-15.15/
```

---

## 二、配置编译选项

### 2.1 基础配置

```bash
./configure --prefix=/db/uxdb
```

### 2.2 带调试符号的编译

如果需要调试功能，使用 `--enable-debug` 选项：

```bash
./configure --prefix=/db/uxdb --enable-debug
```

这将包含完整的调试符号表，便于使用 gdb 等工具进行调试。

---

## 三、编译和安装

### 3.1 完整编译

```bash
sudo make
sudo make install
```

### 3.2 编译插件

如果需要编译 contrib 插件：

```bash
cd contrib/pageinspect/
sudo make
sudo make install
```

---

## 四、数据库初始化

### 4.1 创建数据目录

```bash
# 使用 UTF8 编码和 en_US.utf8 语言环境
/db/uxdb/bin/initdb -D /usr/local/pgsql/data -E UTF8 --locale=en_US.utf8

# 或者初始化到指定目录
/db/uxdb/bin/initdb -D /db/uxdb/data -E UTF8 --locale=en_US.utf8

# 带密码初始化
/db/uxdb/bin/initdb -W uxdb
```

### 4.2 创建数据库用户

```bash
sudo userdel -r uxdb
```

---

## 五、启动数据库服务

### 5.1 设置环境变量

```bash
# 将 PostgreSQL 添加到 PATH
export PATH=$PATH:/db/uxdb/bin
# 或
export PATH=/db/uxdb/bin:$PATH
```

### 5.2 启动数据库

```bash
# 启动数据库并记录日志
/db/uxdb/bin/pg_ctl -D uxdb -l logfile start

# 或使用完整路径
pg_ctl start -D /db/uxdb -U uxdb
```

### 5.3 连接数据库

```bash
psql -U uxdb
```

---

## 六、重新编译安装流程

### 6.1 停止数据库服务

首先需要停止正在运行的 PostgreSQL 实例：

```bash
# 如果 pg_ctl 命令在 PATH 中
pg_ctl -D uxdb stop

# 或者使用完整路径
/db/uxdb/bin/pg_ctl -D uxdb stop
```

### 6.2 清理编译文件（推荐）

为了确保编译干净，建议先清理之前的编译产物：

```bash
# 在源码目录下
cd /root/db/postgresql-15.15
make clean
```

### 6.3 重新编译和安装

```bash
# 完整重新编译并安装到目标目录
sudo make && sudo make install
```

### 6.4 重新安装插件（如果需要）

如果您修改了插件代码：

```bash
cd contrib/pageinspect/
sudo make clean
sudo make
sudo make install
```

### 6.5 重启数据库服务

```bash
# 切换到 uxdb 用户
sudo -i -u uxdb

# 重新启动数据库
/db/uxdb/bin/pg_ctl -D uxdb -l logfile start
```

---

## 七、优化建议

### 7.1 快速重新编译（只编译修改部分）

由于您使用了 `--enable-debug` 配置选项，编译会包含调试信息，速度较慢。对于小幅修改，可以：

```bash
# 直接重新编译和安装（不 clean）
sudo make && sudo make install
# 或者只安装
sudo make install
```

### 7.2 查看修改的文件

从 git status 可以看到您修改了：
- `src/backend/parser/analyze.c`
- `src/backend/parser/gram.y`
- `src/include/nodes/parsenodes.h`

这些都是解析器相关的文件，重新编译这些模块：

```bash
# 只重新编译 parser 模块
cd src/backend/parser
make clean
make
cd ../../../
make install
```

### 7.3 验证修改是否生效

编译安装后，可以连接数据库验证修改：

```bash
# 连接数据库
psql -d postgres

# 检查 PostgreSQL 版本
SELECT version();
```

---

## 八、常见问题处理

### 8.1 编译失败时

如果编译失败，查看错误信息后：

```bash
# 确保编译环境完整
sudo yum install -y readline-devel zlib-devel libicu-devel openssl-devel pam-devel libxml2-devel libxslt-devel systemd-devel

# 重新配置
./configure --prefix=/db/uxdb --enable-debug

# 重新编译
sudo make clean
sudo make && sudo make install
```

### 8.2 数据库无法启动时

检查日志文件：

```bash
cat ~/uxdb/logfile
```

---

## 九、完整重新编译脚本

可以将以下内容保存为 `rebuild.sh`：

```bash
#!/bin/bash

# 停止数据库
pg_ctl -D ~/uxdb stop || echo "数据库已停止"

# 清理并重新编译
make clean
make

# 安装
sudo make install

# 重新启动数据库
pg_ctl -D ~/uxdb -l ~/uxdb/logfile start

echo "重新编译安装完成！"
```

---

## 十、常用命令

### 查看表结构

```sql
\dt
```

### 查询数据

```sql
select * from employees;
```

### 输出结果文件

**连接数据库**：`psql -U your_username -d your_database`

**设置输出文件**：`\o /db/result.txt`

**执行 SQL 文件**：`\i /db/input.sql`

**重置输出到屏幕**：执行 `\o` 以结束向文件的写入。

**退出 psql**：执行 `\q`