-- 测试查询功能（WHERE和ORDER BY支持）
-- 注意：由于语法问题，我们先测试基本的查询功能

-- 测试1: 创建测试表
DROP TABLE IF EXISTS test_query_table;
CREATE TABLE test_query_table (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    value INTEGER,
    description TEXT
);

-- 插入测试数据
INSERT INTO test_query_table (name, value, description) VALUES 
    ('记录A', 100, '第一条记录'),
    ('记录B', 200, '第二条记录'),
    ('记录C', 150, '第三条记录'),
    ('记录D', 300, '第四条记录');

-- 测试2: 基本SELECT查询
SELECT * FROM test_query_table;

-- 测试3: WHERE条件查询
SELECT * FROM test_query_table WHERE value > 150;

-- 测试4: ORDER BY查询
SELECT * FROM test_query_table ORDER BY value;

-- 测试5: 组合WHERE和ORDER BY
SELECT * FROM test_query_table WHERE value >= 150 ORDER BY name;

-- 测试6: 检查列信息
SELECT attname, atttypid, attnum 
FROM pg_attribute 
WHERE attrelid = 'test_query_table'::regclass 
AND attnum > 0 
ORDER BY attnum;

-- 清理
DROP TABLE IF EXISTS test_query_table;

\echo '查询功能测试完成'
