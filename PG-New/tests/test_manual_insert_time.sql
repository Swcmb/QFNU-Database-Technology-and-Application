-- 手动插入时间戳测试
SET log_min_messages = DEBUG1;
SET client_min_messages = DEBUG1;

-- 清理
DROP TABLE IF EXISTS manual_insert_test;

-- 创建测试表
CREATE TABLE manual_insert_test (
    id int,
    name varchar(50)
);

-- 手动插入包含时间戳的数据
INSERT INTO manual_insert_test (id, name, time) VALUES (1, 'Test', '2024-12-29 12:00:00');

-- 检查结果
SELECT id, name, time, time IS NULL as time_is_null FROM manual_insert_test;