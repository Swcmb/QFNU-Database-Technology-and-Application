-- 测试核心功能（不依赖新语法）
-- 这个测试验证已实现的核心函数是否工作

-- 测试1: 创建普通表（应该工作）
DROP TABLE IF EXISTS test_basic_table;
CREATE TABLE test_basic_table (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT
);

-- 显示表结构
\d test_basic_table

-- 测试插入数据
INSERT INTO test_basic_table (name, description) VALUES ('测试1', '基本功能测试');

-- 查看数据
SELECT * FROM test_basic_table;

-- 测试更新操作
UPDATE test_basic_table SET description = '更新后的描述' WHERE id = 1;

-- 再次查看数据
SELECT * FROM test_basic_table;

-- 清理
DROP TABLE IF EXISTS test_basic_table;

\echo '基本功能测试完成'
