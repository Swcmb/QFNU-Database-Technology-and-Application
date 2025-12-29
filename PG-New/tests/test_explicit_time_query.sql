-- 显式查询时间列
SET client_min_messages = DEBUG1;
DROP TABLE IF EXISTS explicit_test;
CREATE TABLE explicit_test (id int, name varchar(10));
INSERT INTO explicit_test VALUES (1, 'test');

-- 显式查询时间列
SELECT id, name, time FROM explicit_test;

-- 检查时间列是否为NULL
SELECT id, name, time IS NULL as time_is_null FROM explicit_test;

-- 尝试查询时间列的原始值
SELECT id, name, time::text as time_text FROM explicit_test;