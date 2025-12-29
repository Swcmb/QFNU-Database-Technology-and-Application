-- 简单调试测试，启用DEBUG日志
SET log_min_messages = DEBUG1;
SET client_min_messages = DEBUG1;

-- 清理
DROP TABLE IF EXISTS simple_debug_test;

-- 创建测试表
CREATE TABLE simple_debug_test (
    id int,
    name varchar(50)
);

-- 插入数据
INSERT INTO simple_debug_test VALUES (1, 'Test');

-- 检查结果
SELECT id, name, time, time IS NULL as time_is_null FROM simple_debug_test;