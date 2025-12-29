-- 最终语法验证测试
-- 这些语句测试我们实现的隐含时间列语法

-- 测试1: 基本WITH TIME语法
-- 期望: 解析成功，has_implicit_time = true
CREATE TABLE syntax_test_1 (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    description TEXT
) WITH TIME;

-- 测试2: 基本WITHOUT TIME语法  
-- 期望: 解析成功，has_implicit_time = false
CREATE TABLE syntax_test_2 (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    description TEXT
) WITHOUT TIME;

-- 测试3: 默认行为
-- 期望: 解析成功，has_implicit_time = true (默认值)
CREATE TABLE syntax_test_3 (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    description TEXT
);

-- 测试4: IF NOT EXISTS + WITH TIME
-- 期望: 解析成功，has_implicit_time = true, if_not_exists = true
CREATE TABLE IF NOT EXISTS syntax_test_4 (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100)
) WITH TIME;

-- 测试5: IF NOT EXISTS + WITHOUT TIME
-- 期望: 解析成功，has_implicit_time = false, if_not_exists = true
CREATE TABLE IF NOT EXISTS syntax_test_5 (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100)
) WITHOUT TIME;

-- 测试6: 临时表 + WITH TIME
-- 期望: 解析成功，has_implicit_time = true, relpersistence = TEMP
CREATE TEMP TABLE syntax_test_6 (
    id INTEGER,
    data TEXT
) WITH TIME;

-- 测试7: 与存储参数组合
-- 期望: 解析成功，has_implicit_time = true，options不为空
CREATE TABLE syntax_test_7 (
    id INTEGER,
    data TEXT
) WITH (fillfactor=80) WITH TIME;

-- 测试8: 与表空间组合
-- 期望: 解析成功，has_implicit_time = false，tablespacename设置
CREATE TABLE syntax_test_8 (
    id INTEGER,
    data TEXT
) WITHOUT TIME TABLESPACE pg_default;

-- 测试9: 分区表（应该产生警告但解析成功）
-- 期望: 解析成功，has_implicit_time = true，产生性能警告
CREATE TABLE syntax_test_9 (
    id INTEGER,
    created_date DATE
) PARTITION BY RANGE (created_date) WITH TIME;

-- 测试10: 继承表
-- 期望: 解析成功，has_implicit_time = false
CREATE TABLE syntax_test_10 (
    extra_field INTEGER
) INHERITS (syntax_test_2) WITHOUT TIME;

-- 以下是错误语法测试（应该产生语法错误）
-- 这些语句被注释掉，因为它们应该导致解析失败

-- 错误测试1: 关键字顺序错误
-- CREATE TABLE error_test_1 (id INTEGER) TIME WITH;

-- 错误测试2: 冲突的选项
-- CREATE TABLE error_test_2 (id INTEGER) WITH WITHOUT TIME;

-- 错误测试3: 重复的TIME关键字
-- CREATE TABLE error_test_3 (id INTEGER) WITH TIME WITH TIME;

-- 错误测试4: 缺少TIME关键字
-- CREATE TABLE error_test_4 (id INTEGER) WITH;

-- 错误测试5: 缺少WITH/WITHOUT关键字
-- CREATE TABLE error_test_5 (id INTEGER) TIME;