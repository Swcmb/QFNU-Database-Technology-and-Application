-- 简单调试测试
DROP TABLE IF EXISTS simple_test;
CREATE TABLE simple_test (id int, name varchar(10));
INSERT INTO simple_test VALUES (1, 'test');
SELECT * FROM simple_test;
SELECT time, id, name FROM simple_test;