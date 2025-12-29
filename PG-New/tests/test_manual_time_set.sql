-- 手动设置时间戳测试
SET log_min_messages = DEBUG1;
SET client_min_messages = DEBUG1;

-- 清理
DROP TABLE IF EXISTS manual_time_test;

-- 创建测试表
CREATE TABLE manual_time_test (
    id int,
    name varchar(50)
);

-- 插入数据
INSERT INTO manual_time_test VALUES (1, 'Test');

-- 手动更新时间戳
UPDATE manual_time_test SET time = '2024-12-29 12:00:00' WHERE id = 1;

-- 检查结果
SELECT id, name, time, time IS NULL as time_is_null FROM manual_time_test;