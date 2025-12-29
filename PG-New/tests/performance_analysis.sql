-- PostgreSQL隐含时间列功能 - 性能分析和优化
-- 分析隐含时间列对系统性能的影响并提供优化建议

\echo '开始PostgreSQL隐含时间列功能性能分析...'

-- ========================================
-- 1. 系统资源使用分析
-- ========================================
\echo '1. 系统资源使用分析'

-- 检查当前数据库统计信息
SELECT 
    datname as database_name,
    numbackends as active_connections,
    xact_commit as committed_transactions,
    xact_rollback as rolled_back_transactions,
    blks_read as blocks_read,
    blks_hit as blocks_hit,
    CASE 
        WHEN (blks_read + blks_hit) > 0 
        THEN ROUND((blks_hit::FLOAT / (blks_read + blks_hit)) * 100, 2)
        ELSE 0 
    END as cache_hit_ratio_percent
FROM pg_stat_database 
WHERE datname = current_database();

-- ========================================
-- 2. 表级性能统计
-- ========================================
\echo '2. 表级性能统计'

-- 创建测试表进行性能分析
DROP TABLE IF EXISTS perf_analysis_with_implicit;
DROP TABLE IF EXISTS perf_analysis_without_implicit;

CREATE TABLE perf_analysis_with_implicit (
    id SERIAL PRIMARY KEY,
    data VARCHAR(100),
    value INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) WITH TIME;

CREATE TABLE perf_analysis_without_implicit (
    id SERIAL PRIMARY KEY,
    data VARCHAR(100),
    value INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) WITHOUT TIME;

-- 插入测试数据
INSERT INTO perf_analysis_with_implicit (data, value)
SELECT 
    'test_data_' || i,
    i % 1000
FROM generate_series(1, 5000) i;

INSERT INTO perf_analysis_without_implicit (data, value)
SELECT 
    'test_data_' || i,
    i % 1000
FROM generate_series(1, 5000) i;

-- 分析表统计信息
SELECT 
    schemaname,
    tablename,
    n_tup_ins as inserts,
    n_tup_upd as updates,
    n_tup_del as deletes,
    n_live_tup as live_tuples,
    n_dead_tup as dead_tuples,
    seq_scan as sequential_scans,
    seq_tup_read as seq_tuples_read,
    idx_scan as index_scans,
    idx_tup_fetch as idx_tuples_fetched
FROM pg_stat_user_tables 
WHERE tablename LIKE 'perf_analysis_%'
ORDER BY tablename;

-- ========================================
-- 3. 存储空间分析
-- ========================================
\echo '3. 存储空间分析'

SELECT 
    tablename,
    pg_size_pretty(pg_total_relation_size(tablename::regclass)) as total_size,
    pg_size_pretty(pg_relation_size(tablename::regclass)) as table_size,
    pg_size_pretty(pg_indexes_size(tablename::regclass)) as index_size,
    (pg_total_relation_size(tablename::regclass))::BIGINT as total_bytes
FROM (
    SELECT 'perf_analysis_with_implicit' as tablename
    UNION ALL
    SELECT 'perf_analysis_without_implicit' as tablename
) t
ORDER BY total_bytes DESC;

-- 计算存储开销
WITH size_comparison AS (
    SELECT 
        CASE 
            WHEN tablename LIKE '%with_implicit%' THEN 'with_implicit'
            ELSE 'without_implicit'
        END as table_type,
        pg_total_relation_size(tablename::regclass) as size_bytes
    FROM (
        SELECT 'perf_analysis_with_implicit' as tablename
        UNION ALL
        SELECT 'perf_analysis_without_implicit' as tablename
    ) t
)
SELECT 
    w.size_bytes as with_implicit_bytes,
    wo.size_bytes as without_implicit_bytes,
    (w.size_bytes - wo.size_bytes) as size_difference_bytes,
    pg_size_pretty(w.size_bytes - wo.size_bytes) as size_difference,
    ROUND(((w.size_bytes::FLOAT / wo.size_bytes) - 1) * 100, 2) as size_increase_percent
FROM 
    (SELECT size_bytes FROM size_comparison WHERE table_type = 'with_implicit') w,
    (SELECT size_bytes FROM size_comparison WHERE table_type = 'without_implicit') wo;

-- ========================================
-- 4. 查询性能分析
-- ========================================
\echo '4. 查询性能分析'

-- 分析SELECT查询性能
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM perf_analysis_with_implicit WHERE value < 100;

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM perf_analysis_without_implicit WHERE value < 100;

-- 分析UPDATE查询性能
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
UPDATE perf_analysis_with_implicit SET data = 'updated_' || id WHERE value < 50;

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
UPDATE perf_analysis_without_implicit SET data = 'updated_' || id WHERE value < 50;

-- ========================================
-- 5. 索引性能分析
-- ========================================
\echo '5. 索引性能分析'

-- 创建索引
CREATE INDEX idx_perf_with_value ON perf_analysis_with_implicit(value);
CREATE INDEX idx_perf_without_value ON perf_analysis_without_implicit(value);

-- 分析索引使用情况
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan as index_scans,
    idx_tup_read as tuples_read,
    idx_tup_fetch as tuples_fetched
FROM pg_stat_user_indexes 
WHERE tablename LIKE 'perf_analysis_%'
ORDER BY tablename, indexname;

-- 重新运行查询以测试索引性能
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM perf_analysis_with_implicit WHERE value = 100;

EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM perf_analysis_without_implicit WHERE value = 100;

-- ========================================
-- 6. 事务性能分析
-- ========================================
\echo '6. 事务性能分析'

-- 测试事务中的批量操作
\timing on

-- 带隐含列的批量事务
BEGIN;
INSERT INTO perf_analysis_with_implicit (data, value)
SELECT 'batch_' || i, i FROM generate_series(1, 1000) i;
UPDATE perf_analysis_with_implicit SET value = value + 1 WHERE id > 5000;
COMMIT;

-- 不带隐含列的批量事务
BEGIN;
INSERT INTO perf_analysis_without_implicit (data, value)
SELECT 'batch_' || i, i FROM generate_series(1, 1000) i;
UPDATE perf_analysis_without_implicit SET value = value + 1 WHERE id > 5000;
COMMIT;

\timing off

-- ========================================
-- 7. 内存使用分析
-- ========================================
\echo '7. 内存使用分析'

-- 检查缓冲区使用情况
SELECT 
    c.relname as table_name,
    count(*) as buffers_used,
    pg_size_pretty(count(*) * 8192) as memory_used
FROM pg_buffercache b
JOIN pg_class c ON b.relfilenode = pg_relation_filenode(c.oid)
WHERE c.relname LIKE 'perf_analysis_%'
GROUP BY c.relname
ORDER BY count(*) DESC;

-- ========================================
-- 8. 锁定和并发分析
-- ========================================
\echo '8. 锁定和并发分析'

-- 检查当前锁定情况
SELECT 
    l.locktype,
    l.database,
    l.relation::regclass as table_name,
    l.mode,
    l.granted,
    a.query
FROM pg_locks l
LEFT JOIN pg_stat_activity a ON l.pid = a.pid
WHERE l.relation::regclass::text LIKE 'perf_analysis_%'
ORDER BY l.relation, l.mode;

-- ========================================
-- 9. 性能优化建议
-- ========================================
\echo '9. 性能优化建议'

-- 生成优化建议报告
DO $$
DECLARE
    with_implicit_size BIGINT;
    without_implicit_size BIGINT;
    size_diff BIGINT;
    size_increase_pct NUMERIC;
BEGIN
    -- 获取表大小
    SELECT pg_total_relation_size('perf_analysis_with_implicit') INTO with_implicit_size;
    SELECT pg_total_relation_size('perf_analysis_without_implicit') INTO without_implicit_size;
    
    size_diff := with_implicit_size - without_implicit_size;
    size_increase_pct := ((with_implicit_size::FLOAT / without_implicit_size) - 1) * 100;
    
    RAISE NOTICE '=== 性能优化建议报告 ===';
    RAISE NOTICE '';
    RAISE NOTICE '1. 存储开销分析:';
    RAISE NOTICE '   - 带隐含列表大小: %', pg_size_pretty(with_implicit_size);
    RAISE NOTICE '   - 不带隐含列表大小: %', pg_size_pretty(without_implicit_size);
    RAISE NOTICE '   - 额外存储开销: % (%.2f%%)', pg_size_pretty(size_diff), size_increase_pct;
    RAISE NOTICE '';
    
    IF size_increase_pct > 10 THEN
        RAISE NOTICE '2. 存储优化建议:';
        RAISE NOTICE '   - 存储开销较高，建议仅在必要时启用隐含时间列';
        RAISE NOTICE '   - 考虑使用分区表来减少单表大小';
        RAISE NOTICE '   - 定期执行VACUUM和ANALYZE维护操作';
    ELSE
        RAISE NOTICE '2. 存储优化建议:';
        RAISE NOTICE '   - 存储开销在可接受范围内';
        RAISE NOTICE '   - 可以安全地使用隐含时间列功能';
    END IF;
    
    RAISE NOTICE '';
    RAISE NOTICE '3. 查询优化建议:';
    RAISE NOTICE '   - 为经常查询的列创建适当的索引';
    RAISE NOTICE '   - 避免在SELECT *查询中包含不必要的隐含列';
    RAISE NOTICE '   - 使用EXPLAIN ANALYZE分析查询计划';
    RAISE NOTICE '';
    RAISE NOTICE '4. 维护建议:';
    RAISE NOTICE '   - 定期监控表统计信息';
    RAISE NOTICE '   - 根据数据增长情况调整autovacuum设置';
    RAISE NOTICE '   - 监控锁定情况，避免长时间的表锁定';
END $$;

-- ========================================
-- 10. 性能监控查询
-- ========================================
\echo '10. 性能监控查询'

-- 创建性能监控视图
CREATE OR REPLACE VIEW v_implicit_time_performance AS
SELECT 
    t.schemaname,
    t.tablename,
    t.n_tup_ins as inserts,
    t.n_tup_upd as updates,
    t.n_tup_del as deletes,
    t.n_live_tup as live_tuples,
    t.n_dead_tup as dead_tuples,
    pg_size_pretty(pg_total_relation_size(t.tablename::regclass)) as total_size,
    CASE 
        WHEN (t.seq_scan + COALESCE(i.idx_scan, 0)) > 0 
        THEN ROUND((COALESCE(i.idx_scan, 0)::FLOAT / (t.seq_scan + COALESCE(i.idx_scan, 0))) * 100, 2)
        ELSE 0 
    END as index_usage_percent
FROM pg_stat_user_tables t
LEFT JOIN (
    SELECT 
        tablename,
        SUM(idx_scan) as idx_scan
    FROM pg_stat_user_indexes 
    GROUP BY tablename
) i ON t.tablename = i.tablename
WHERE t.tablename LIKE '%implicit%'
ORDER BY t.tablename;

-- 显示监控视图
SELECT * FROM v_implicit_time_performance;

-- ========================================
-- 清理测试数据
-- ========================================
\echo '清理性能分析测试数据...'

DROP VIEW IF EXISTS v_implicit_time_performance;
DROP TABLE IF EXISTS perf_analysis_with_implicit;
DROP TABLE IF EXISTS perf_analysis_without_implicit;

\echo '性能分析完成！'
\echo '请查看上述分析结果，根据建议优化隐含时间列功能的性能。'