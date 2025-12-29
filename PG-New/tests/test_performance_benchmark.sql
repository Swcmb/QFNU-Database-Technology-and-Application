-- PostgreSQL隐含时间列功能 - 性能基准测试
-- 对比启用和未启用隐含列的性能差异
-- 验证需求: 5.5

\echo '开始PostgreSQL隐含时间列功能性能基准测试...'

-- 设置测试参数
\set test_rows 10000
\set batch_size 1000

-- ========================================
-- 准备测试环境
-- ========================================
\echo '准备测试环境...'

-- 创建测试表：带隐含时间列
DROP TABLE IF EXISTS perf_test_with_implicit;
CREATE TABLE perf_test_with_implicit (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    age INTEGER,
    salary DECIMAL(10,2),
    department VARCHAR(50),
    hire_date DATE,
    is_active BOOLEAN DEFAULT true
) WITH TIME;

-- 创建测试表：不带隐含时间列
DROP TABLE IF EXISTS perf_test_without_implicit;
CREATE TABLE perf_test_without_implicit (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    age INTEGER,
    salary DECIMAL(10,2),
    department VARCHAR(50),
    hire_date DATE,
    is_active BOOLEAN DEFAULT true
) WITHOUT TIME;

-- 创建索引以确保公平比较
CREATE INDEX idx_perf_with_name ON perf_test_with_implicit(name);
CREATE INDEX idx_perf_with_dept ON perf_test_with_implicit(department);
CREATE INDEX idx_perf_without_name ON perf_test_without_implicit(name);
CREATE INDEX idx_perf_without_dept ON perf_test_without_implicit(department);

-- ========================================
-- 测试1: INSERT性能比较
-- ========================================
\echo '测试1: INSERT性能比较'

-- 准备测试数据生成函数
CREATE OR REPLACE FUNCTION generate_test_data(start_id INTEGER, end_id INTEGER)
RETURNS TABLE(
    name VARCHAR(100),
    email VARCHAR(255),
    age INTEGER,
    salary DECIMAL(10,2),
    department VARCHAR(50),
    hire_date DATE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ('用户' || i::TEXT)::VARCHAR(100),
        ('user' || i::TEXT || '@example.com')::VARCHAR(255),
        (20 + (i % 40))::INTEGER,
        (30000 + (i % 50000))::DECIMAL(10,2),
        (CASE (i % 5) 
            WHEN 0 THEN '技术部'
            WHEN 1 THEN '销售部'
            WHEN 2 THEN '市场部'
            WHEN 3 THEN '人事部'
            ELSE '财务部'
        END)::VARCHAR(50),
        ('2020-01-01'::DATE + (i % 1000)::INTEGER)::DATE
    FROM generate_series(start_id, end_id) AS i;
END;
$$ LANGUAGE plpgsql;

-- 测试带隐含列的表INSERT性能
\echo '测试带隐含时间列的INSERT性能...'
\timing on

INSERT INTO perf_test_with_implicit (name, email, age, salary, department, hire_date)
SELECT * FROM generate_test_data(1, :test_rows);

\timing off

-- 测试不带隐含列的表INSERT性能
\echo '测试不带隐含时间列的INSERT性能...'
\timing on

INSERT INTO perf_test_without_implicit (name, email, age, salary, department, hire_date)
SELECT * FROM generate_test_data(1, :test_rows);

\timing off

-- ========================================
-- 测试2: SELECT性能比较
-- ========================================
\echo '测试2: SELECT性能比较'

-- 测试带隐含列的表SELECT性能
\echo '测试带隐含时间列的SELECT性能...'
\timing on

SELECT COUNT(*) FROM perf_test_with_implicit WHERE department = '技术部';
SELECT * FROM perf_test_with_implicit WHERE age > 30 LIMIT 100;
SELECT department, AVG(salary) FROM perf_test_with_implicit GROUP BY department;

\timing off

-- 测试不带隐含列的表SELECT性能
\echo '测试不带隐含时间列的SELECT性能...'
\timing on

SELECT COUNT(*) FROM perf_test_without_implicit WHERE department = '技术部';
SELECT * FROM perf_test_without_implicit WHERE age > 30 LIMIT 100;
SELECT department, AVG(salary) FROM perf_test_without_implicit GROUP BY department;

\timing off

-- ========================================
-- 测试3: UPDATE性能比较
-- ========================================
\echo '测试3: UPDATE性能比较'

-- 测试带隐含列的表UPDATE性能
\echo '测试带隐含时间列的UPDATE性能...'
\timing on

UPDATE perf_test_with_implicit SET salary = salary * 1.1 WHERE department = '技术部';
UPDATE perf_test_with_implicit SET is_active = false WHERE age > 55;

\timing off

-- 测试不带隐含列的表UPDATE性能
\echo '测试不带隐含时间列的UPDATE性能...'
\timing on

UPDATE perf_test_without_implicit SET salary = salary * 1.1 WHERE department = '技术部';
UPDATE perf_test_without_implicit SET is_active = false WHERE age > 55;

\timing off

-- ========================================
-- 测试4: DELETE性能比较
-- ========================================
\echo '测试4: DELETE性能比较'

-- 测试带隐含列的表DELETE性能
\echo '测试带隐含时间列的DELETE性能...'
\timing on

DELETE FROM perf_test_with_implicit WHERE is_active = false;

\timing off

-- 测试不带隐含列的表DELETE性能
\echo '测试不带隐含时间列的DELETE性能...'
\timing on

DELETE FROM perf_test_without_implicit WHERE is_active = false;

\timing off

-- ========================================
-- 测试5: 批量操作性能比较
-- ========================================
\echo '测试5: 批量操作性能比较'

-- 重新插入一些数据用于批量测试
INSERT INTO perf_test_with_implicit (name, email, age, salary, department, hire_date)
SELECT * FROM generate_test_data(1, 1000);

INSERT INTO perf_test_without_implicit (name, email, age, salary, department, hire_date)
SELECT * FROM generate_test_data(1, 1000);

-- 测试批量更新
\echo '测试批量UPDATE性能...'

\timing on
UPDATE perf_test_with_implicit SET email = CONCAT(name, '@newdomain.com');
\timing off

\timing on
UPDATE perf_test_without_implicit SET email = CONCAT(name, '@newdomain.com');
\timing off

-- ========================================
-- 测试6: 存储空间使用比较
-- ========================================
\echo '测试6: 存储空间使用比较'

-- 检查表大小
SELECT 
    'perf_test_with_implicit' as table_name,
    pg_size_pretty(pg_total_relation_size('perf_test_with_implicit')) as total_size,
    pg_size_pretty(pg_relation_size('perf_test_with_implicit')) as table_size,
    pg_size_pretty(pg_indexes_size('perf_test_with_implicit')) as index_size
UNION ALL
SELECT 
    'perf_test_without_implicit' as table_name,
    pg_size_pretty(pg_total_relation_size('perf_test_without_implicit')) as total_size,
    pg_size_pretty(pg_relation_size('perf_test_without_implicit')) as table_size,
    pg_size_pretty(pg_indexes_size('perf_test_without_implicit')) as index_size;

-- 检查行数
SELECT 
    'perf_test_with_implicit' as table_name,
    COUNT(*) as row_count
FROM perf_test_with_implicit
UNION ALL
SELECT 
    'perf_test_without_implicit' as table_name,
    COUNT(*) as row_count
FROM perf_test_without_implicit;

-- ========================================
-- 测试7: 事务性能比较
-- ========================================
\echo '测试7: 事务性能比较'

-- 测试事务中的操作性能
\echo '测试事务中的操作性能...'

-- 带隐含列的事务测试
\timing on
BEGIN;
INSERT INTO perf_test_with_implicit (name, email, age, salary, department, hire_date)
VALUES ('事务测试1', 'tx1@example.com', 30, 50000, '技术部', '2023-01-01');
UPDATE perf_test_with_implicit SET salary = 55000 WHERE name = '事务测试1';
COMMIT;
\timing off

-- 不带隐含列的事务测试
\timing on
BEGIN;
INSERT INTO perf_test_without_implicit (name, email, age, salary, department, hire_date)
VALUES ('事务测试1', 'tx1@example.com', 30, 50000, '技术部', '2023-01-01');
UPDATE perf_test_without_implicit SET salary = 55000 WHERE name = '事务测试1';
COMMIT;
\timing off

-- ========================================
-- 测试8: 并发性能测试准备
-- ========================================
\echo '测试8: 并发性能测试准备'

-- 创建并发测试脚本（需要在多个会话中运行）
\echo '创建并发测试数据...'

-- 为并发测试准备更多数据
INSERT INTO perf_test_with_implicit (name, email, age, salary, department, hire_date)
SELECT * FROM generate_test_data(20001, 25000);

INSERT INTO perf_test_without_implicit (name, email, age, salary, department, hire_date)
SELECT * FROM generate_test_data(20001, 25000);

-- ========================================
-- 性能统计和分析
-- ========================================
\echo '性能统计和分析'

-- 检查查询计划差异
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM perf_test_with_implicit WHERE department = '技术部' LIMIT 10;

EXPLAIN (ANALYZE, BUFFERS) 
SELECT * FROM perf_test_without_implicit WHERE department = '技术部' LIMIT 10;

-- 检查统计信息
SELECT 
    schemaname,
    tablename,
    n_tup_ins as inserts,
    n_tup_upd as updates,
    n_tup_del as deletes,
    n_live_tup as live_tuples,
    n_dead_tup as dead_tuples
FROM pg_stat_user_tables 
WHERE tablename LIKE 'perf_test_%'
ORDER BY tablename;

-- ========================================
-- 清理测试数据
-- ========================================
\echo '清理性能测试数据...'

DROP FUNCTION IF EXISTS generate_test_data(INTEGER, INTEGER);
DROP TABLE IF EXISTS perf_test_with_implicit;
DROP TABLE IF EXISTS perf_test_without_implicit;

\echo '性能基准测试完成！'
\echo '请比较上述测试中的执行时间，分析隐含时间列对性能的影响。'
\echo '关键指标：'
\echo '1. INSERT操作的时间差异'
\echo '2. UPDATE操作的时间差异'
\echo '3. SELECT查询的性能影响'
\echo '4. 存储空间使用差异'
\echo '5. 事务处理性能差异'