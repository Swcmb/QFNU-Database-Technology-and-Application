-- 测试隐含时间列的显示
SELECT id, name, to_char(time, 'YYYY-MM-DD HH24:MI:SS') as formatted_time 
FROM debug_slot_test 
ORDER BY id;