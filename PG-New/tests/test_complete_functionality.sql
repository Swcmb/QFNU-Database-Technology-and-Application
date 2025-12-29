-- 完整功能测试
SET log_min_messages = DEBUG1;
SET client_min_messages = DEBUG1;

-- 清理
DROP TABLE IF EXISTS complete_test;

-- 测试1：创建带隐含时间列的表（默认行为）
CREATE TABLE complete_test (
    id int,
    name varchar(50)
);

-- 验证表结构
\d complete_test

-- 测试2：INSERT操作（自动设置时间戳）
INSERT INTO complete_test (id, name) VALUES (1, 'First Record');

-- 等待1秒
SELECT pg_sleep(1);

-- 测试3：INSERT操作（手动指定时间戳）
INSERT INTO complete_test (id, name, time) VALUES (2, 'Manual Time', '2024-01-01 12:00:00');

-- 等待1秒
SELECT pg_sleep(1);

-- 测试4：UPDATE操作（应该更新时间戳）
UPDATE complete_test SET name = 'Updated First' WHERE id = 1;

-- 测试5：查看结果
-- SELECT * 应该隐藏隐含时间列
SELECT * FROM complete_test ORDER BY id;

-- 显式查询时间列应该显示时间戳
SELECT id, name, to_char(time, 'YYYY-MM-DD HH24:MI:SS') as formatted_time 
FROM complete_test 
ORDER BY id;

-- 测试6：创建不带隐含时间列的表
DROP TABLE IF EXISTS no_time_test;
CREATE TABLE no_time_test (
    id int,
    name varchar(50)
) NO IMPLICIT TIME;

-- 验证表结构（不应该有time列）
\d no_time_test

-- 测试7：在不带隐含时间列的表中插入数据
INSERT INTO no_time_test (id, name) VALUES (1, 'No Time Record');
SELECT * FROM no_time_test;