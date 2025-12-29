-- 简单的INSERT测试，避免UPDATE操作
SET log_min_messages = DEBUG1;
SET client_min_messages = DEBUG1;

-- 清理
DROP TABLE IF EXISTS simple_insert_test;

-- 创建测试表
CREATE TABLE simple_insert_test (
    id int,
    name varchar(50)
);

-- 插入数据
INSERT INTO simple_insert_test VALUES (1, 'Test');

-- 检查结果
SELECT id, name, time FROM simple_insert_test;