-- 简单的UPDATE测试
SET log_min_messages = DEBUG1;
SET client_min_messages = DEBUG1;

-- 清理
DROP TABLE IF EXISTS simple_update_test;

-- 创建测试表
CREATE TABLE simple_update_test (
    id int,
    name varchar(50)
);

-- 插入数据
INSERT INTO simple_update_test VALUES (1, 'Test');

-- 更新数据（不涉及time列）
UPDATE simple_update_test SET name = 'Updated' WHERE id = 1;

-- 检查结果
SELECT id, name, time, time IS NULL as time_is_null FROM simple_update_test;