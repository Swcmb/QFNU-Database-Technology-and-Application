-- 调试隐含时间列功能
\echo '=== 调试隐含时间列功能 ==='

-- 创建一个新的测试表
DROP TABLE IF EXISTS debug_table;
CREATE TABLE debug_table (id int, name varchar(20)) IMPLICIT TIME;

-- 查看表结构
\d debug_table

-- 插入一行数据
INSERT INTO debug_table (id, name) VALUES (1, 'test');

-- 查看所有数据（包括隐含列）
SELECT * FROM debug_table;

-- 显式查询隐含列
SELECT time, id, name FROM debug_table;

-- 检查time列的值
SELECT time IS NULL as time_is_null, id, name FROM debug_table;