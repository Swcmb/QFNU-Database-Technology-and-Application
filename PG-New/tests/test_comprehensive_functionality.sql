-- 综合功能测试
-- 测试已实现的隐含时间列核心功能

-- 测试1: 创建测试表
DROP TABLE IF EXISTS test_table_1;
CREATE TABLE test_table_1 (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT
);

-- 检查表结构
\d test_table_1

-- 测试2: 插入数据并检查
INSERT INTO test_table_1 (name, description) VALUES ('记录1', '第一条记录');
INSERT INTO test_table_1 (name, description) VALUES ('记录2', '第二条记录');

-- 查看插入的数据
SELECT * FROM test_table_1;

-- 测试3: 更新数据
UPDATE test_table_1 SET description = '更新后的第一条记录' WHERE id = 1;

-- 再次查看数据
SELECT * FROM test_table_1;

-- 测试4: 删除数据
DELETE FROM test_table_1 WHERE id = 2;

-- 查看剩余数据
SELECT * FROM test_table_1;

-- 测试5: 检查系统表中是否有隐含列相关信息
-- 查看pg_attribute中的列信息
SELECT attname, atttypid, attnum, attnotnull 
FROM pg_attribute 
WHERE attrelid = 'test_table_1'::regclass 
AND attnum > 0 
ORDER BY attnum;

-- 清理
DROP TABLE IF EXISTS test_table_1;

\echo '综合功能测试完成'
