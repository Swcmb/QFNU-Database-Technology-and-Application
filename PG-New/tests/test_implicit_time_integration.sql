-- PostgreSQL隐含时间列功能集成测试
-- 测试DDL语法和基本功能

\echo '=== PostgreSQL隐含时间列功能集成测试 ==='
\echo ''

-- 测试1: 创建带隐含时间列的表（默认行为）
\echo '测试1: 创建带隐含时间列的表（默认行为）'
DROP TABLE IF EXISTS test_table_default;
CREATE TABLE test_table_default (
    id int,
    name varchar(50),
    age int
);

-- 检查表结构
\d test_table_default

-- 测试2: 创建显式指定IMPLICIT TIME的表
\echo ''
\echo '测试2: 创建显式指定IMPLICIT TIME的表'
DROP TABLE IF EXISTS test_table_with_time;
CREATE TABLE test_table_with_time (
    id int,
    name varchar(50),
    age int
) IMPLICIT TIME;

-- 检查表结构
\d test_table_with_time

-- 测试3: 创建NO IMPLICIT TIME的表
\echo ''
\echo '测试3: 创建NO IMPLICIT TIME的表'
DROP TABLE IF EXISTS test_table_without_time;
CREATE TABLE test_table_without_time (
    id int,
    name varchar(50),
    age int
) NO IMPLICIT TIME;

-- 检查表结构
\d test_table_without_time

-- 测试4: 插入数据并验证时间戳自动维护
\echo ''
\echo '测试4: 插入数据并验证时间戳自动维护'
INSERT INTO test_table_default VALUES (1, 'Alice', 25);
SELECT pg_sleep(2);  -- 等待2秒
INSERT INTO test_table_default VALUES (2, 'Bob', 30);

-- 测试SELECT *（不应显示隐含列）
\echo ''
\echo 'SELECT * 查询结果（不应显示隐含列）:'
SELECT * FROM test_table_default;

-- 测试显式查询隐含列
\echo ''
\echo '显式查询隐含列:'
SELECT time, id, name, age FROM test_table_default;

-- 测试5: 更新数据并验证时间戳更新
\echo ''
\echo '测试5: 更新数据并验证时间戳更新'
SELECT pg_sleep(2);  -- 等待2秒
UPDATE test_table_default SET age = 26 WHERE id = 1;

\echo '更新后的数据:'
SELECT time, id, name, age FROM test_table_default ORDER BY id;

-- 测试6: 验证NO IMPLICIT TIME表的行为
\echo ''
\echo '测试6: 验证NO IMPLICIT TIME表的行为'
INSERT INTO test_table_without_time VALUES (1, 'Charlie', 35);
INSERT INTO test_table_without_time VALUES (2, 'David', 40);

\echo 'NO IMPLICIT TIME表的查询结果:'
SELECT * FROM test_table_without_time;

-- 尝试查询不存在的time列（应该报错）
\echo ''
\echo '尝试查询NO IMPLICIT TIME表的time列（应该报错）:'
SELECT time, id, name, age FROM test_table_without_time;

\echo ''
\echo '=== 集成测试完成 ==='