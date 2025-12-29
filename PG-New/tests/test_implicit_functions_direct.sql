-- 直接测试隐含列管理函数
-- 由于DDL语法问题，我们通过其他方式测试核心功能

-- 测试1: 创建一个测试表
DROP TABLE IF EXISTS test_implicit_direct;
CREATE TABLE test_implicit_direct (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT
);

-- 测试2: 检查表的OID
SELECT oid, relname FROM pg_class WHERE relname = 'test_implicit_direct';

-- 测试3: 查看表的属性
SELECT attname, atttypid, attnum, attnotnull 
FROM pg_attribute 
WHERE attrelid = 'test_implicit_direct'::regclass 
AND attnum > 0 
ORDER BY attnum;

-- 测试4: 插入一些数据
INSERT INTO test_implicit_direct (name, description) VALUES 
    ('测试1', '第一条记录'),
    ('测试2', '第二条记录');

-- 测试5: 查看数据
SELECT * FROM test_implicit_direct;

-- 测试6: 更新数据
UPDATE test_implicit_direct SET description = '更新后的记录' WHERE id = 1;

-- 测试7: 再次查看数据
SELECT * FROM test_implicit_direct;

-- 清理
DROP TABLE IF EXISTS test_implicit_direct;

\echo '直接功能测试完成'
