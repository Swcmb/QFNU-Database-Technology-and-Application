-- 测试UPDATE操作的隐含时间列更新
SET log_min_messages = DEBUG1;
SET client_min_messages = DEBUG1;

-- 等待1秒以确保时间戳不同
SELECT pg_sleep(1);

-- 更新第一行
UPDATE debug_slot_test SET name = 'Updated Auto' WHERE id = 1;

-- 查看结果
SELECT id, name, to_char(time, 'YYYY-MM-DD HH24:MI:SS') as formatted_time 
FROM debug_slot_test 
ORDER BY id;