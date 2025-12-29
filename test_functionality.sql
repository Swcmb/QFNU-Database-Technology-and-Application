-- 测试PostgreSQL隐含时间列功能
-- 测试1: 创建带隐含时间列的表
CREATE TABLE test_implicit_time (
    id int,
    name varchar(50),
    age int
) WITH TIME;

-- 查看表结构
\d test_implicit_time

-- 测试2: 插入数据
INSERT INTO test_implicit_time (id, name, age) VALUES (1, 'Alice', 25);
INSERT INTO test_implicit_time (id, name, age) VALUES (2, 'Bob', 30);

-- 测试3: 查询隐含列
SELECT time, id, name, age FROM test_implicit_time;

-- 测试4: SELECT * 不显示隐含列
SELECT * FROM test_implicit_time;

-- 测试5: 更新数据
UPDATE test_implicit_time SET age = 26 WHERE id = 1;

-- 再次查询隐含列
SELECT time, id, name, age FROM test_implicit_time;

-- 测试6: 创建不带隐含时间列的表
CREATE TABLE test_no_implicit_time (
    id int,
    name varchar(50)
) WITHOUT TIME;

-- 查看表结构
\d test_no_implicit_time

-- 测试7: 默认行为（应该创建带隐含列的表）
CREATE TABLE test_default_behavior (
    id int,
    value text
);

-- 查看表结构
\d test_default_behavior

-- 清理
DROP TABLE test_implicit_time;
DROP TABLE test_no_implicit_time;
DROP TABLE test_default_behavior;