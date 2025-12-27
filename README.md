# 曲阜师范大学 - 数据库技术与应用

## 项目简介

本项目是曲阜师范大学数据库技术与应用课程的教学资源仓库，包含PostgreSQL数据库内核分析、实验指导、课程资料及相关工具。

## 项目结构

```
QFNU-Database-Technology-and-Application/
├── README.md                 # 项目说明文档
├── .gitignore               # Git忽略文件配置
├── .gitmodules              # Git子模块配置
├── Docs/                    # 文档资料
│   ├── else.md             # 其他文档
│   ├── Patch指南.md        # 补丁应用指南
│   └── AgentRule.txt       # 代理规则说明
├── Tools/                   # 工具软件
│   └── VSCode-win32-x64-1.85.2/  # VSCode编辑器
├── 课件/                    # 课程教学资料
├── Ex-Guide/                # 实验指导文档
│   ├── 题目一.pdf          # 实验一题目
│   ├── 题目二.md          # 实验二：PostgreSQL物理存储结构分析
│   └── 预备.pdf            # 预备知识
├── postgresql-15.15/        # PostgreSQL 15.15源码
├── QFNU-DTA-Res/           # 实验结果与项目
│   ├── Ex1/               # 实验一结果
│   ├── Ex2/               # 实验二结果
│   ├── Ex3/               # 实验三结果
│   ├── Ex4/               # 实验四结果
│   └── Project/           # 课程项目
└── .git/                  # Git版本控制
```


## 环境要求

- PostgreSQL ≥ 12（推荐15.15版本）
- Linux操作系统（CentOS/Ubuntu）
- 数据库superuser权限
- 基础SQL知识

## 工具使用

### VSCode编辑器
位于 `Tools/VSCode-win32-x64-1.85.2/` 目录，提供：
- 代码编辑与高亮
- SQL语法支持
- Git集成
- 扩展插件支持

### PostgreSQL源码
位于 `postgresql-15.15/` 目录，包含：
- 完整的PostgreSQL 15.15源代码
- 编译配置文件
- 开发文档
- 测试用例


## 学习资源

- [PostgreSQL官方文档](https://www.postgresql.org/docs/)
- 实验指导文档位于 `Ex-Guide/` 目录
- 课程资料位于 `课件/` 目录
- 实验结果参考位于 `QFNU-DTA-Res/` 目录