-- 调试隐含时间列功能
\echo '=== 调试隐含时间列功能 ==='

-- 创建测试表
DROP TABLE IF EXISTS debug_table;
CREATE TABLE debug_table (
    id int,
    name varchar(50)
);

-- 检查表结构
\echo '表结构:'
\d debug_table

-- 检查隐含列函数
\echo '检查隐含列函数:'
SELECT table_has_implicit_time(oid) as has_implicit_time, 
       get_implicit_time_attnum(oid) as time_attnum
FROM pg_class 
WHERE relname = 'debug_table';

-- 插入数据
\echo '插入数据:'
INSERT INTO debug_table VALUES (1, 'Test');

-- 查询所有列（包括隐含列）
\echo '查询所有列（包括隐含列）:'
SELECT *, time FROM debug_table;

-- 检查pg_attribute中的隐含列
\echo '检查pg_attribute中的隐含列:'
SELECT attname, atttypid, attnum, attisdropped 
FROM pg_attribute 
WHERE attrelid = (SELECT oid FROM pg_class WHERE relname = 'debug_table')
  AND attname = 'time';