-- 验证隐含时间列语法的SQL脚本
-- 这些语句应该能够被正确解析（即使不能执行）

-- 基本WITH TIME语法
CREATE TABLE test_with_time (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT
) WITH TIME;

-- 基本WITHOUT TIME语法
CREATE TABLE test_without_time (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT
) WITHOUT TIME;

-- 默认行为（应该等同于WITH TIME）
CREATE TABLE test_default (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT
);

-- IF NOT EXISTS + WITH TIME
CREATE TABLE IF NOT EXISTS test_if_not_exists_with_time (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
) WITH TIME;

-- IF NOT EXISTS + WITHOUT TIME
CREATE TABLE IF NOT EXISTS test_if_not_exists_without_time (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
) WITHOUT TIME;

-- 带继承的表
CREATE TABLE test_inherit (
    extra_field INTEGER
) INHERITS (test_with_time) WITH TIME;

-- 带分区的表
CREATE TABLE test_partition (
    id INTEGER,
    created_date DATE
) PARTITION BY RANGE (created_date) WITHOUT TIME;

-- 临时表
CREATE TEMP TABLE test_temp (
    id INTEGER,
    data TEXT
) WITH TIME;

-- 带表空间的表
CREATE TABLE test_tablespace (
    id INTEGER,
    data TEXT
) WITH TIME TABLESPACE pg_default;

-- 带存储参数的表
CREATE TABLE test_with_options (
    id INTEGER,
    data TEXT
) WITH (fillfactor=80) WITH TIME;

-- 测试错误语法（这些应该产生语法错误）
-- CREATE TABLE test_error1 (id INTEGER) TIME WITH;  -- 错误的关键字顺序
-- CREATE TABLE test_error2 (id INTEGER) WITH WITHOUT TIME;  -- 冲突的选项