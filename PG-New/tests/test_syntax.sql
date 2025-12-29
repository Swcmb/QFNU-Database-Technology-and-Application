-- 测试隐含时间列语法的SQL语句

-- 测试WITH TIME语法
CREATE TABLE test_with_time (
    id INTEGER,
    name VARCHAR(50)
) WITH TIME;

-- 测试WITHOUT TIME语法  
CREATE TABLE test_without_time (
    id INTEGER,
    name VARCHAR(50)
) WITHOUT TIME;

-- 测试默认行为（应该等同于WITH TIME）
CREATE TABLE test_default (
    id INTEGER,
    name VARCHAR(50)
);

-- 测试IF NOT EXISTS版本
CREATE TABLE IF NOT EXISTS test_if_not_exists (
    id INTEGER,
    name VARCHAR(50)
) WITH TIME;

-- 测试OF typename版本
CREATE TABLE test_of_type OF some_type WITH TIME;

-- 测试PARTITION OF版本
CREATE TABLE test_partition PARTITION OF parent_table (
    CHECK (id > 100)
) FOR VALUES FROM (100) TO (200) WITHOUT TIME;