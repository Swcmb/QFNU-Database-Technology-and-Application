# 曲阜师范大学 - 数据库技术与应用

## 项目简介

本项目是曲阜师范大学数据库技术与应用课程的教学资源仓库，包含PostgreSQL数据库内核分析、实验指导、课程资料及相关工具。

## 项目结构

```
QFNU-Database-Technology-and-Application/
├── README.md                 # 项目说明文档
├── LICENSE                   # 许可证文件
├── .gitignore               # Git忽略文件配置
├── .gitmodules              # Git子模块配置
├── Docs/                    # 文档资料
│   ├── 终端会话记录工具.md
│   ├── git操作指南.md
│   ├── postgresql-编译安装指南.md
│   ├── postgresql-代码更新指南.md
│   └── postgresql-开发规范.md
├── Ex-Guide/                # 实验指导文档
│   ├── 大作业.md
│   ├── 题目一.pdf
│   ├── 题目二.md
│   ├── 题目三.md
│   ├── 题目三拓展.md
│   ├── 题目四.md
│   └── 预备.pdf
├── postgresql-15.15/        # PostgreSQL 15.15源码
├── QFNU-DTA-Res/           # 实验结果与项目
│   ├── Ex1/               # 实验一结果
│   ├── Ex2/               # 实验二结果
│   ├── Ex3/               # 实验三结果
│   ├── Ex4/               # 实验四结果
│   └── Project/           # 课程项目
├── logs/                   # 日志文件
├── 课件/                   # 课程教学资料
└── VSCode-win32-x64-1.85.2/  # VSCode编辑器
```

## 环境要求

- PostgreSQL ≥ 12（推荐15.15版本）
- Linux/Windows操作系统
- 数据库superuser权限
- 基础SQL知识

## 文档说明

### Docs/ 目录
- **终端会话记录工具.md** - 终端会话记录工具使用说明
- **git操作指南.md** - Git版本控制操作指南
- **postgresql-编译安装指南.md** - PostgreSQL源码编译与安装指南
- **postgresql-代码更新指南.md** - PostgreSQL代码更新与维护指南
- **postgresql-开发规范.md** - PostgreSQL开发规范与最佳实践

### Ex-Guide/ 目录
- **大作业.md** - 课程大作业说明
- **题目一** - 实验一相关材料
- **题目二** - 实验二相关材料
- **题目三** - 实验三相关材料
- **题目三拓展.md** - 实验三拓展内容
- **题目四** - 实验四相关材料
- **预备.pdf** - 预备知识材料

## PostgreSQL源码

位于 `postgresql-15.15/` 目录，包含：
- 完整的PostgreSQL 15.15源代码
- 编译配置文件（configure, Makefile等）
- 开发文档
- 测试用例和脚本

## 学习资源

- [PostgreSQL官方文档](https://www.postgresql.org/docs/)
- 实验指导文档位于 `Ex-Guide/` 目录
- 课程资料位于 `课件/` 目录
- 实验结果参考位于 `QFNU-DTA-Res/` 目录
- 开发文档位于 `Docs/` 目录

## 许可证

本项目遵循相应的开源许可证，详见 [LICENSE](LICENSE) 文件。