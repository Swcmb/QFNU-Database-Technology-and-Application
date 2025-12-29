-- 简单调试测试
DROP TABLE IF EXISTS test_debug;
CREATE TABLE test_debug (id int, name varchar(50));

INSERT INTO test_debug VALUES (1, 'Test');

SELECT * FROM test_debug;
SELECT time FROM test_debug;