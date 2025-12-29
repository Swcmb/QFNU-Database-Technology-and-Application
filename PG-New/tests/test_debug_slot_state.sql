-- 调试slot状态测试
SET log_min_messages = DEBUG1;
SET client_min_messages = DEBUG1;

-- 清理
DROP TABLE IF EXISTS debug_slot_test;

-- 创建测试表
CREATE TABLE debug_slot_test (
    id int,
    name varchar(50)
);

-- 测试1：自动插入（不指定time列）
INSERT INTO debug_slot_test (id, name) VALUES (1, 'Auto');

-- 测试2：手动插入（指定time列）
INSERT INTO debug_slot_test (id, name, time) VALUES (2, 'Manual', '2024-12-29 12:00:00');

-- 检查结果
SELECT id, name, time, time IS NULL as time_is_null FROM debug_slot_test ORDER BY id;