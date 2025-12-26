### 查看ip

```
hostname -I
```

### 安装依赖

```
sudo yum install -y readline-devel zlib-devel libicu-devel openssl-devel pam-devel libxml2-devel libxslt-devel systemd-devel
```

![image-20251226102440229](C:/Users/Swcmb/AppData/Roaming/Typora/typora-user-images/image-20251226102440229.png)

### 解压源码包并切换到目录

```
tar -xvf postgresql-15.15.tar.gz
cd postgresql-15.15/
```

![image-20251226103022243](C:/Users/Swcmb/AppData/Roaming/Typora/typora-user-images/image-20251226103022243.png)

### 配置编译选项

```
./configure --prefix=/db/uxdb --enable-debug
```

![image-20251226103546509](C:/Users/Swcmb/AppData/Roaming/Typora/typora-user-images/image-20251226103546509.png)

### 编译与安装

```
sudo make && sudo make install
```

![image-20251226104112504](C:/Users/Swcmb/AppData/Roaming/Typora/typora-user-images/image-20251226104112504.png)

![image-20251226104150987](C:/Users/Swcmb/AppData/Roaming/Typora/typora-user-images/image-20251226104150987.png)

### 安装插件

```
cd contrib/pageinspect/
sudo make && sudo make install
```

![image-20251226104428272](C:/Users/Swcmb/AppData/Roaming/Typora/typora-user-images/image-20251226104428272.png)

### 添加用户

```
sudo adduser uxdb
```

### 使用 `visudo`命令编辑配置文件

```
visudo
```

### 授予 uxdb用户完整的 sudo 权限且无需输入密码

```
uxdb ALL=(ALL) NOPASSWD: ALL
```

![image-20251226163534967](C:/Users/Swcmb/AppData/Roaming/Typora/typora-user-images/image-20251226163534967.png)

### 切换到uxdb用户

```
sudo -i -u uxdb
```

![image-20251226164639903](C:/Users/Swcmb/AppData/Roaming/Typora/typora-user-images/image-20251226164639903.png)

### 初始化数据库实例和启动数据库实例

```
/db/uxdb/bin/initdb -W uxdb
/db/uxdb/bin/pg_ctl -D uxdb -l logfile start
```

![image-20251226165429994](C:/Users/Swcmb/AppData/Roaming/Typora/typora-user-images/image-20251226165429994.png)

### 修改环境变量

```
sudo vi /etc/profile
```

在文件的末尾添加以下行:
```
export PATH=/db/uxdb/bin:$PATH
```
保存并生效：保存文件后，使用 source命令使配置立即在当前终端生效，或者注销后重新登录。

```
source /etc/profile
```

### 在postgresql-15.15/src/backend/tcop/postgres.c中的PostgresMain 中的Switch(firstchar) 处设置断点

![image-20251226191017211](C:/Users/Swcmb/AppData/Roaming/Typora/typora-user-images/image-20251226191017211.png)

### 创建launch.json

```json
{
    "version": "0.2.0",
    "configurations": [
      {
        "name": "retome attach debug",
        "request": "attach",
        "type": "cppdbg",
        "program": "/db/uxdb/bin/psql",  
        "processId": "${command:pickProcess}",
        "MIMode": "gdb",
        "miDebuggerPath": "/usr/bin/gdb"
      }
    ]
}
```

### 创建uxdb数据库

```
psql -U uxdb -d postgres
CREATE DATABASE uxdb;
\q
```

### 连接数据库

```
psql -U uxdb
```

![image-20251226172415312](C:/Users/Swcmb/AppData/Roaming/Typora/typora-user-images/image-20251226172415312.png)

### 获取当前数据库会话所对应的服务器端后台进程的ID

```
Select * from pg_backend_pid();
```

![image-20251226191620538](C:/Users/Swcmb/AppData/Roaming/Typora/typora-user-images/image-20251226191620538.png)

### 附加到进程

#### 运行--启动调试：

![image-20251226173239363](C:/Users/Swcmb/AppData/Roaming/Typora/typora-user-images/image-20251226173239363.png)

#### 出现窗口：

![image-20251226180651049](C:/Users/Swcmb/AppData/Roaming/Typora/typora-user-images/image-20251226180651049.png)

#### 出现：

![image-20251226180912925](C:/Users/Swcmb/AppData/Roaming/Typora/typora-user-images/image-20251226180912925.png)
