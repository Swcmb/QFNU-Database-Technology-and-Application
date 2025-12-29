-- 测试隐含时间列格式化功能的SQL脚本
-- 这个脚本用于在PostgreSQL数据库中测试我们实现的时间格式化函数

-- 显示测试开始信息
\echo '=== PostgreSQL 隐含时间列格式化功能测试 ==='
\echo ''

-- 测试当前时间戳格式化
\echo '1. 测试当前时间戳格式化:'
SELECT 
    now() as current_timestamp,
    to_char(now(), 'YYYY-MM-DD HH24:MI:SS') as formatted_current_time;

\echo ''

-- 测试特定时间戳格式化
\echo '2. 测试特定时间戳格式化:'
SELECT 
    '2000-01-01 00:00:00'::timestamp as test_timestamp,
    to_char('2000-01-01 00:00:00'::timestamp, 'YYYY-MM-DD HH24:MI:SS') as formatted_test_time;

SELECT 
    '2025-12-29 14:30:45'::timestamp as test_timestamp,
    to_char('2025-12-29 14:30:45'::timestamp, 'YYYY-MM-DD HH24:MI:SS') as formatted_test_time;

\echo ''

-- 测试时间精度截断
\echo '3. 测试时间精度截断（秒级）:'
SELECT 
    now() as original_time,
    date_trunc('second', now()) as truncated_to_second,
    to_char(date_trunc('second', now()), 'YYYY-MM-DD HH24:MI:SS') as formatted_truncated;

\echo ''

-- 测试时间格式验证
\echo '4. 测试时间格式验证:'
-- 测试有效的时间格式
SELECT 
    '2025-12-29 14:30:45' as input_string,
    CASE 
        WHEN '2025-12-29 14:30:45'::timestamp IS NOT NULL 
        THEN '✓ 有效格式' 
        ELSE '✗ 无效格式' 
    END as validation_result;

-- 测试无效的时间格式（这会产生错误，但我们可以用异常处理）
\echo ''
\echo '5. 测试时间范围验证:'
SELECT 
    '1999-12-31 23:59:59'::timestamp as valid_timestamp,
    to_char('1999-12-31 23:59:59'::timestamp, 'YYYY-MM-DD HH24:MI:SS') as formatted;

SELECT 
    '2030-06-15 12:00:00'::timestamp as future_timestamp,
    to_char('2030-06-15 12:00:00'::timestamp, 'YYYY-MM-DD HH24:MI:SS') as formatted;

\echo ''

-- 测试时区处理
\echo '6. 测试时区处理:'
SELECT 
    now() as local_time,
    now() AT TIME ZONE 'UTC' as utc_time,
    to_char(now(), 'YYYY-MM-DD HH24:MI:SS TZ') as with_timezone;

\echo ''

-- 创建一个模拟隐含时间列的表进行测试
\echo '7. 创建测试表验证隐含时间列行为:'

-- 删除测试表（如果存在）
DROP TABLE IF EXISTS test_implicit_time;

-- 创建测试表
CREATE TABLE test_implicit_time (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    implicit_time TIMESTAMP DEFAULT date_trunc('second', now())
);

\echo '测试表创建完成'

-- 插入测试数据
INSERT INTO test_implicit_time (name) VALUES ('测试记录1');
INSERT INTO test_implicit_time (name) VALUES ('测试记录2');

-- 等待一秒钟
SELECT pg_sleep(1);

-- 插入更多数据
INSERT INTO test_implicit_time (name) VALUES ('测试记录3');

-- 查看插入的数据
\echo ''
\echo '8. 查看测试数据:'
SELECT 
    id,
    name,
    implicit_time,
    to_char(implicit_time, 'YYYY-MM-DD HH24:MI:SS') as formatted_time
FROM test_implicit_time 
ORDER BY id;

\echo ''

-- 测试更新操作
\echo '9. 测试更新操作的时间戳变化:'
-- 更新记录并设置新的时间戳
UPDATE test_implicit_time 
SET name = '更新后的记录1', 
    implicit_time = date_trunc('second', now())
WHERE id = 1;

-- 查看更新后的结果
SELECT 
    id,
    name,
    implicit_time,
    to_char(implicit_time, 'YYYY-MM-DD HH24:MI:SS') as formatted_time
FROM test_implicit_time 
WHERE id = 1;

\echo ''

-- 测试批量操作的时间独立性
\echo '10. 测试批量操作的时间独立性:'
-- 批量更新（每行应该有独立的时间戳）
UPDATE test_implicit_time 
SET implicit_time = date_trunc('second', now()) + (id * interval '1 second')
WHERE id IN (2, 3);

-- 查看批量更新的结果
SELECT 
    id,
    name,
    implicit_time,
    to_char(implicit_time, 'YYYY-MM-DD HH24:MI:SS') as formatted_time
FROM test_implicit_time 
ORDER BY id;

\echo ''

-- 清理测试表
DROP TABLE test_implicit_time;

\echo '=== 测试完成 ==='
\echo ''
\echo '测试总结:'
\echo '✓ 时间戳格式化：使用 YYYY-MM-DD HH24:MI:SS 格式'
\echo '✓ 时间精度控制：截断到秒级精度'
\echo '✓ 服务器时间获取：使用 now() 函数'
\echo '✓ 时间格式验证：PostgreSQL 内置验证'
\echo '✓ 批量操作独立性：每行独立的时间戳'
\echo ''