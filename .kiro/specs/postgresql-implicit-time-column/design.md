# 设计文档

## 概述

本设计文档描述了在PostgreSQL数据库系统中实现隐含时间列功能的技术方案。该功能将在表级别添加一个隐藏的时间戳列，自动记录每行数据的最后修改时间，支持通过DDL语句控制启用与否。

## 架构

### 整体架构图

```mermaid
graph TB
    A[SQL解析器] --> B[语法分析器]
    B --> C[语义分析器]
    C --> D[查询规划器]
    D --> E[执行器]
    E --> F[存储管理器]
    F --> G[页面管理器]
    G --> H[磁盘存储]
    
    I[DDL处理器] --> J[表结构管理]
    J --> K[隐含列管理器]
    K --> L[时间戳生成器]
    
    M[查询处理器] --> N[列可见性控制]
    N --> O[结果集构建器]
</mermaid>

### 核心组件

1. **DDL扩展模块**: 处理WITH TIME/WITHOUT TIME语法
2. **隐含列管理器**: 管理隐含列的创建、更新和查询
3. **存储层扩展**: 处理包含隐含列的数据存储
4. **查询处理扩展**: 控制隐含列在查询结果中的可见性

## 组件和接口

### 1. DDL语法扩展

#### 语法定义
```sql
CREATE TABLE table_name (
    column_definitions
) [WITH TIME | WITHOUT TIME]
```

#### 接口设计
```c
/* 表选项结构 */
typedef struct TableOptions {
    bool has_implicit_time;  /* 是否包含隐含时间列 */
    char *time_column_name;  /* 时间列名称，默认为"time" */
} TableOptions;

/* DDL解析接口 */
TableOptions* parse_table_options(List *options);
bool validate_table_options(TableOptions *opts);
```

### 2. 隐含列管理

#### 数据结构
```c
/* 隐含列定义 */
typedef struct ImplicitColumn {
    char *column_name;       /* 列名 */
    Oid column_type;         /* 数据类型OID */
    int16 column_len;        /* 列长度 */
    bool is_visible;         /* 是否在SELECT *中可见 */
    AttrNumber attnum;       /* 属性编号 */
} ImplicitColumn;

/* 表的隐含列信息 */
typedef struct TableImplicitInfo {
    Oid table_oid;          /* 表OID */
    bool has_implicit_time;  /* 是否有隐含时间列 */
    AttrNumber time_attnum;  /* 时间列的属性编号 */
} TableImplicitInfo;
```

#### 核心接口
```c
/* 隐含列管理接口 */
void add_implicit_time_column(Relation rel);
void remove_implicit_time_column(Relation rel);
bool table_has_implicit_time(Oid table_oid);
AttrNumber get_implicit_time_attnum(Oid table_oid);
Timestamp get_current_timestamp(void);
```

### 3. 存储层修改

#### 元组结构扩展
```c
/* 扩展的元组头部信息 */
typedef struct HeapTupleHeaderData {
    /* 原有字段... */
    TransactionId t_xmin;
    TransactionId t_xmax;
    CommandId t_cid;
    ItemPointerData t_ctid;
    
    /* 新增字段 */
    bool has_implicit_cols;     /* 是否包含隐含列 */
    uint16 implicit_col_count;  /* 隐含列数量 */
} HeapTupleHeaderData;
```

#### 存储接口
```c
/* 存储层接口 */
HeapTuple heap_form_tuple_with_implicit(TupleDesc tupdesc, 
                                       Datum *values, 
                                       bool *isnull,
                                       bool include_implicit);
void heap_update_implicit_time(HeapTuple tuple, Timestamp new_time);
Datum extract_implicit_time(HeapTuple tuple, AttrNumber time_attnum);
```

### 4. 查询处理扩展

#### 查询重写
```c
/* 查询重写接口 */
typedef struct QueryRewriteContext {
    Query *query;
    List *target_tables;
    bool include_implicit_cols;
} QueryRewriteContext;

Query* rewrite_query_for_implicit_cols(Query *query);
List* expand_star_target(List *targetlist, RangeTblEntry *rte);
bool should_include_implicit_column(RangeTblEntry *rte, char *colname);
```

## 数据模型

### 系统表扩展

#### pg_class扩展
```sql
-- 在pg_class中添加新字段
ALTER TABLE pg_class ADD COLUMN relhasimplicittime boolean DEFAULT false;
```

#### 新增系统表pg_implicit_columns
```sql
CREATE TABLE pg_implicit_columns (
    ic_relid oid NOT NULL,           -- 表OID
    ic_attname name NOT NULL,        -- 隐含列名
    ic_attnum int2 NOT NULL,         -- 属性编号
    ic_atttypid oid NOT NULL,        -- 数据类型OID
    ic_visible boolean DEFAULT false, -- 是否在SELECT *中可见
    PRIMARY KEY (ic_relid, ic_attname)
);
```

### 数据存储格式

#### 行数据布局
```
+------------------+------------------+------------------+
| 标准列数据       | 隐含列数据       | 空值位图         |
+------------------+------------------+------------------+
| user_col1        | implicit_time    | null_bitmap      |
| user_col2        |                  |                  |
| ...              |                  |                  |
+------------------+------------------+------------------+
```

#### 时间戳存储
- 类型: `timestamp without time zone`
- 格式: 8字节整数，表示自2000-01-01 00:00:00 UTC以来的微秒数
- 精度: 微秒级别（实际显示到秒）

## 正确性属性分析

让我使用prework工具来分析需求中的验收标准，以确定哪些可以转化为可测试的属性。

<function_calls>
<invoke name="prework">
<parameter name="featureName">postgresql-implicit-time-column

## 正确性属性

*属性是一个特征或行为，应该在系统的所有有效执行中保持为真——本质上是关于系统应该做什么的正式声明。属性作为人类可读规范和机器可验证正确性保证之间的桥梁。*

### 属性反思

在分析所有可测试的验收标准后，我识别出以下可以合并或优化的冗余属性：

- 属性4.1和4.2都测试时间格式，可以合并为一个综合属性
- 属性2.3和5.1都测试UPDATE操作的时间戳更新，可以合并
- 多个属性测试相同的DDL解析功能，可以合并为更全面的属性

经过反思，以下是优化后的正确性属性：

### 属性 1: DDL语法解析正确性
*对于任何* CREATE TABLE语句，当包含WITH TIME关键字时，系统应创建带有隐含时间列的表；当包含WITHOUT TIME关键字时，应创建不带隐含时间列的表；当未指定TIME关键字时，应默认创建带有隐含时间列的表
**验证需求: Requirements 1.1, 1.2, 1.3, 1.4**

### 属性 2: 隐含列存储一致性
*对于任何* 带有隐含时间列的表，系统表中应正确记录time列的定义，且该列应使用timestamp类型
**验证需求: Requirements 2.1, 2.5**

### 属性 3: 时间戳自动维护
*对于任何* 包含隐含时间列的表，插入操作应自动设置time列为当前时间戳，更新操作应自动更新time列为新的时间戳
**验证需求: Requirements 2.2, 2.3, 5.1**

### 属性 4: 查询可见性控制
*对于任何* 包含隐含时间列的表，SELECT *查询不应返回隐含列，而显式指定time列的查询应返回该列
**验证需求: Requirements 3.1, 3.2**

### 属性 5: 隐含列查询功能
*对于任何* 隐含时间列，应支持WHERE条件过滤和ORDER BY排序操作，且结果应正确
**验证需求: Requirements 3.4, 3.5**

### 属性 6: 时间格式标准化
*对于任何* 隐含时间列的显示，应使用'yyyy-mm-dd hh24:mi:ss'格式，精度支持到秒级别，且使用服务器当前时间
**验证需求: Requirements 4.1, 4.2, 4.3, 4.5**

### 属性 7: 事务内时间戳一致性
*对于任何* 在同一事务中多次修改的行，最终的时间戳应反映最后一次修改的时间
**验证需求: Requirements 4.4**

### 属性 8: 存储管理正确性
*对于任何* 包含隐含列的表，原址更新和存储重组应正确处理隐含列的存储空间
**验证需求: Requirements 5.2, 5.3**

### 属性 9: 批量操作独立性
*对于任何* 批量更新操作，每行的时间戳应独立设置，不应使用相同的时间值
**验证需求: Requirements 5.4**

### 属性 10: 向后兼容性
*对于任何* 不包含隐含列的现有表，所有操作应保持原有行为不变
**验证需求: Requirements 3.3, 6.1**

### 属性 11: 系统功能兼容性
*对于任何* 包含隐含列的表，pg_dump备份恢复、复制功能、ALTER TABLE操作以及索引、约束、触发器等特性应正常工作
**验证需求: Requirements 6.2, 6.3, 6.4, 6.5**

### 属性 12: 错误处理完整性
*对于任何* 语法错误、存储错误或系统内部错误，应返回包含具体位置、原因和上下文信息的清晰错误信息
**验证需求: Requirements 1.5, 7.1, 7.2, 7.4, 7.5**

### 属性 13: 删除操作正确性
*对于任何* 包含隐含列的表，删除操作应正常工作且不影响系统稳定性
**验证需求: Requirements 2.4**

### 属性 14: 日志记录完整性
*对于任何* 隐含列操作失败的情况，系统应记录包含足够诊断信息的详细错误日志
**验证需求: Requirements 7.3**

## 错误处理

### 错误类型和处理策略

#### 1. 语法错误
- **错误场景**: DDL语句中TIME关键字使用错误
- **处理策略**: 返回具体的语法错误位置和建议
- **错误代码**: ERRCODE_SYNTAX_ERROR
- **示例**: "语法错误：第1行第25列，期望'TIME'或'WITHOUT TIME'"

#### 2. 存储错误
- **错误场景**: 隐含列存储空间不足或存储结构损坏
- **处理策略**: 回滚事务，记录详细错误日志
- **错误代码**: ERRCODE_DISK_FULL, ERRCODE_DATA_CORRUPTED
- **示例**: "存储错误：无法为隐含时间列分配存储空间"

#### 3. 兼容性错误
- **错误场景**: 与现有功能冲突或不兼容
- **处理策略**: 提供兼容性建议和解决方案
- **错误代码**: ERRCODE_FEATURE_NOT_SUPPORTED
- **示例**: "兼容性错误：当前表结构不支持添加隐含时间列"

#### 4. 系统内部错误
- **错误场景**: 内存分配失败、系统调用失败等
- **处理策略**: 记录完整的调用栈和系统状态
- **错误代码**: ERRCODE_INTERNAL_ERROR
- **示例**: "内部错误：隐含列管理器初始化失败"

### 错误恢复机制

#### 事务级恢复
- 隐含列操作失败时自动回滚整个事务
- 保证数据一致性和完整性
- 清理已分配的资源

#### 系统级恢复
- 检测并修复损坏的隐含列元数据
- 重建隐含列索引和统计信息
- 提供数据修复工具

## 测试策略

### 双重测试方法

本功能将采用单元测试和基于属性的测试相结合的方法：

#### 单元测试
- **目标**: 验证特定示例、边界情况和错误条件
- **范围**: 
  - DDL语法解析的具体示例
  - 时间戳格式的边界值测试
  - 错误处理的特定场景
  - 与现有功能的集成点

#### 基于属性的测试
- **目标**: 验证跨所有输入的通用属性
- **配置**: 每个属性测试最少100次迭代
- **标签格式**: **Feature: postgresql-implicit-time-column, Property {number}: {property_text}**
- **覆盖范围**: 通过随机化实现全面的输入覆盖

#### 测试框架选择
- **单元测试**: PostgreSQL内置的回归测试框架
- **属性测试**: 使用C语言的QuickCheck库或自定义属性测试框架
- **集成测试**: TAP (Test Anything Protocol) 测试套件

#### 测试数据生成
- **表结构生成器**: 生成各种复杂度的随机表定义
- **SQL语句生成器**: 生成包含各种TIME关键字组合的DDL语句
- **数据操作生成器**: 生成随机的INSERT、UPDATE、DELETE操作
- **时间戳生成器**: 生成各种时间范围和格式的测试数据

#### 性能测试
- **基准测试**: 对比启用和未启用隐含列的性能差异
- **压力测试**: 大量并发操作下的系统稳定性
- **内存使用测试**: 隐含列对内存消耗的影响
- **存储空间测试**: 隐含列对磁盘空间使用的影响

### 测试环境配置
- **测试数据库**: 独立的测试实例，支持快速重置
- **并发测试**: 多线程环境下的功能验证
- **跨平台测试**: Linux、Windows、macOS等不同操作系统
- **版本兼容性**: 与不同PostgreSQL版本的兼容性测试