-- 测试隐含列管理函数
\echo '=== 测试隐含列管理函数 ==='

-- 创建测试表
DROP TABLE IF EXISTS func_test;
CREATE TABLE func_test (id int, name varchar(10));

-- 检查表结构
\d func_test

-- 尝试直接调用隐含列函数（如果存在）
-- 这将帮助我们确定函数是否正确链接
\echo '测试完成'