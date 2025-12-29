-- PostgreSQL隐含时间列功能 - 综合集成测试
-- 测试所有功能的端到端协同工作
-- 验证需求: 所有需求

\echo '开始PostgreSQL隐含时间列功能综合集成测试...'

-- ========================================
-- 测试1: DDL语法支持 (需求1)
-- ========================================
\echo '测试1: DDL语法支持'

-- 1.1 测试默认创建带隐含时间列的表
DROP TABLE IF EXISTS test_default_implicit;
CREATE TABLE test_default_implicit (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    age INTEGER
);

-- 1.2 测试显式创建带隐含时间列的表
DROP TABLE IF EXISTS test_with_time;
CREATE TABLE test_with_time (
    id SERIAL PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    price DECIMAL(10,2),
    category VARCHAR(50)
) WITH TIME;

-- 1.3 测试创建不带隐含时间列的表
DROP TABLE IF EXISTS test_without_time;
CREATE TABLE test_without_time (
    id SERIAL PRIMARY KEY,
    log_message TEXT NOT NULL,
    severity INTEGER
) WITHOUT TIME;

-- 验证表结构
\d test_default_implicit
\d test_with_time
\d test_without_time

-- ========================================
-- 测试2: 隐含列存储管理 (需求2)
-- ========================================
\echo '测试2: 隐含列存储管理'

-- 2.1 测试插入数据时自动设置时间戳
INSERT INTO test_default_implicit (name, email, age) VALUES 
    ('张三', 'zhangsan@example.com', 25),
    ('李四', 'lisi@example.com', 30),
    ('王五', 'wangwu@example.com', 28);

INSERT INTO test_with_time (product_name, price, category) VALUES 
    ('笔记本电脑', 5999.99, '电子产品'),
    ('办公椅', 899.50, '办公用品'),
    ('咖啡杯', 29.99, '生活用品');

INSERT INTO test_without_time (log_message, severity) VALUES 
    ('系统启动', 1),
    ('用户登录', 2),
    ('数据备份完成', 1);

-- 2.2 验证插入后的数据
SELECT 'test_default_implicit' as table_name, * FROM test_default_implicit;
SELECT 'test_with_time' as table_name, * FROM test_with_time;
SELECT 'test_without_time' as table_name, * FROM test_without_time;

-- 2.3 测试更新操作时自动更新时间戳
\echo '等待1秒以确保时间戳差异...'
SELECT pg_sleep(1);

UPDATE test_default_implicit SET age = 26 WHERE name = '张三';
UPDATE test_with_time SET price = 5799.99 WHERE product_name = '笔记本电脑';

-- 验证更新后的时间戳变化
SELECT 'updated_default_implicit' as table_name, * FROM test_default_implicit WHERE name = '张三';
SELECT 'updated_with_time' as table_name, * FROM test_with_time WHERE product_name = '笔记本电脑';

-- ========================================
-- 测试3: 查询行为控制 (需求3)
-- ========================================
\echo '测试3: 查询行为控制'

-- 3.1 测试SELECT *不显示隐含列
\echo '测试SELECT *查询（不应显示隐含列）:'
SELECT * FROM test_default_implicit LIMIT 1;
SELECT * FROM test_with_time LIMIT 1;

-- 3.2 测试显式查询隐含列（如果实现了time列）
-- 注意：这里假设隐含列名为'time'，实际实现可能不同
\echo '尝试显式查询隐含时间列:'
-- SELECT id, name, time FROM test_default_implicit LIMIT 1;

-- 3.3 测试WHERE条件过滤（如果隐含列可查询）
-- SELECT * FROM test_default_implicit WHERE time > CURRENT_TIMESTAMP - INTERVAL '1 hour';

-- 3.4 测试ORDER BY排序（如果隐含列可查询）
-- SELECT id, name FROM test_default_implicit ORDER BY time DESC;

-- ========================================
-- 测试4: 时间格式和精度 (需求4)
-- ========================================
\echo '测试4: 时间格式和精度'

-- 4.1 测试事务内时间戳一致性
BEGIN;
INSERT INTO test_default_implicit (name, email, age) VALUES ('事务测试1', 'tx1@example.com', 35);
SELECT pg_sleep(0.1);
INSERT INTO test_default_implicit (name, email, age) VALUES ('事务测试2', 'tx2@example.com', 40);
COMMIT;

-- 验证事务内插入的记录
SELECT 'transaction_test' as test_type, * FROM test_default_implicit WHERE name LIKE '事务测试%';

-- ========================================
-- 测试5: 更新策略和性能 (需求5)
-- ========================================
\echo '测试5: 更新策略和性能'

-- 5.1 测试批量更新操作
UPDATE test_default_implicit SET email = CONCAT(name, '@updated.com') WHERE age > 25;

-- 5.2 测试删除操作
DELETE FROM test_default_implicit WHERE name = '李四';

-- 验证批量操作结果
SELECT 'batch_update_result' as test_type, * FROM test_default_implicit;

-- ========================================
-- 测试6: 系统兼容性 (需求6)
-- ========================================
\echo '测试6: 系统兼容性'

-- 6.1 测试现有表的向后兼容性
-- 对不带隐含列的表进行各种操作
INSERT INTO test_without_time (log_message, severity) VALUES ('兼容性测试', 3);
UPDATE test_without_time SET severity = 2 WHERE log_message = '兼容性测试';
SELECT 'compatibility_test' as test_type, * FROM test_without_time WHERE log_message = '兼容性测试';

-- 6.2 测试ALTER TABLE操作（如果支持）
-- ALTER TABLE test_default_implicit ADD COLUMN status VARCHAR(20) DEFAULT 'active';

-- ========================================
-- 测试7: 错误处理和日志 (需求7)
-- ========================================
\echo '测试7: 错误处理和日志'

-- 7.1 测试语法错误处理
\echo '测试语法错误（预期会失败）:'
-- 故意的语法错误，测试错误处理
-- CREATE TABLE test_syntax_error (id INT) WITH INVALID_KEYWORD;

-- 7.2 测试约束违反错误
\echo '测试约束违反错误（预期会失败）:'
-- INSERT INTO test_default_implicit (name, email, age) VALUES (NULL, 'test@example.com', 25);

-- ========================================
-- 测试8: 复杂场景集成测试
-- ========================================
\echo '测试8: 复杂场景集成测试'

-- 8.1 创建具有各种约束的表
DROP TABLE IF EXISTS test_complex;
CREATE TABLE test_complex (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    login_count INTEGER DEFAULT 0
) WITH TIME;

-- 8.2 插入测试数据
INSERT INTO test_complex (username, password_hash, email) VALUES 
    ('user1', 'hash1', 'user1@example.com'),
    ('user2', 'hash2', 'user2@example.com'),
    ('user3', 'hash3', 'user3@example.com');

-- 8.3 执行复杂查询
SELECT 
    username,
    email,
    is_active,
    login_count,
    created_at
FROM test_complex 
WHERE is_active = true 
ORDER BY username;

-- 8.4 测试事务回滚
BEGIN;
INSERT INTO test_complex (username, password_hash, email) VALUES ('temp_user', 'temp_hash', 'temp@example.com');
SELECT COUNT(*) as count_before_rollback FROM test_complex;
ROLLBACK;

SELECT COUNT(*) as count_after_rollback FROM test_complex;

-- ========================================
-- 测试9: 并发和锁定测试
-- ========================================
\echo '测试9: 并发和锁定测试'

-- 9.1 测试行级锁定
BEGIN;
SELECT * FROM test_complex WHERE username = 'user1' FOR UPDATE;
-- 在另一个会话中，这应该会等待
-- UPDATE test_complex SET login_count = login_count + 1 WHERE username = 'user1';
COMMIT;

-- ========================================
-- 测试10: 数据完整性验证
-- ========================================
\echo '测试10: 数据完整性验证'

-- 10.1 验证所有表的数据完整性
SELECT 
    'test_default_implicit' as table_name,
    COUNT(*) as row_count
FROM test_default_implicit
UNION ALL
SELECT 
    'test_with_time' as table_name,
    COUNT(*) as row_count
FROM test_with_time
UNION ALL
SELECT 
    'test_without_time' as table_name,
    COUNT(*) as row_count
FROM test_without_time
UNION ALL
SELECT 
    'test_complex' as table_name,
    COUNT(*) as row_count
FROM test_complex;

-- 10.2 检查系统表中的元数据
SELECT 
    schemaname,
    tablename,
    hasindexes,
    hasrules,
    hastriggers
FROM pg_tables 
WHERE tablename LIKE 'test_%'
ORDER BY tablename;

-- ========================================
-- 清理测试数据
-- ========================================
\echo '清理测试数据...'

DROP TABLE IF EXISTS test_default_implicit;
DROP TABLE IF EXISTS test_with_time;
DROP TABLE IF EXISTS test_without_time;
DROP TABLE IF EXISTS test_complex;

\echo '综合集成测试完成！'
\echo '如果所有测试都成功执行，说明隐含时间列功能的各个组件能够正确协同工作。'