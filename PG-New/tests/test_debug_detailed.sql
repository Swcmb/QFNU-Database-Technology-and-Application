-- 详细调试测试，检查隐含时间列在各个阶段的状态
SET log_min_messages = DEBUG1;
SET client_min_messages = DEBUG1;

-- 清理
DROP TABLE IF EXISTS detailed_debug_test;

-- 创建测试表
CREATE TABLE detailed_debug_test (
    id int,
    name varchar(50)
);

-- 检查表结构
\d detailed_debug_test

-- 检查系统表中的隐含时间列
SELECT attname, atttypid, attnum, attisdropped 
FROM pg_attribute 
WHERE attrelid = 'detailed_debug_test'::regclass 
AND attname = 'time';

-- 插入数据
INSERT INTO detailed_debug_test VALUES (1, 'Test');

-- 检查插入后的结果
SELECT id, name, time, time IS NULL as time_is_null FROM detailed_debug_test;

-- 检查原始数据（包括隐含列）
SELECT * FROM detailed_debug_test;

-- 手动设置时间戳测试
UPDATE detailed_debug_test SET time = now() WHERE id = 1;
SELECT id, name, time, time IS NULL as time_is_null FROM detailed_debug_test;