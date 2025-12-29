-- 测试隐含时间列核心功能
-- 这个测试验证已实现的功能是否正常工作

-- 测试1: 创建带有隐含时间列的表（默认行为）
DROP TABLE IF EXISTS test_implicit_default;
CREATE TABLE test_implicit_default (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT
);

-- 测试2: 显式创建带有隐含时间列的表
DROP TABLE IF EXISTS test_implicit_with_time;
CREATE TABLE test_implicit_with_time (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT
) WITH TIME;

-- 测试3: 创建不带隐含时间列的表
DROP TABLE IF EXISTS test_implicit_without_time;
CREATE TABLE test_implicit_without_time (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT
) WITHOUT TIME;

-- 显示创建的表结构
\d test_implicit_default
\d test_implicit_with_time
\d test_implicit_without_time

-- 测试插入数据
INSERT INTO test_implicit_default (name, description) VALUES ('测试1', '默认隐含时间列');
INSERT INTO test_implicit_with_time (name, description) VALUES ('测试2', '显式隐含时间列');
INSERT INTO test_implicit_without_time (name, description) VALUES ('测试3', '无隐含时间列');

-- 查看数据
SELECT * FROM test_implicit_default;
SELECT * FROM test_implicit_with_time;
SELECT * FROM test_implicit_without_time;

-- 测试更新操作
UPDATE test_implicit_default SET description = '更新后的描述' WHERE id = 1;
UPDATE test_implicit_with_time SET description = '更新后的描述' WHERE id = 1;

-- 再次查看数据
SELECT * FROM test_implicit_default;
SELECT * FROM test_implicit_with_time;

-- 清理测试表
DROP TABLE IF EXISTS test_implicit_default;
DROP TABLE IF EXISTS test_implicit_with_time;
DROP TABLE IF EXISTS test_implicit_without_time;

\echo '核心功能测试完成'