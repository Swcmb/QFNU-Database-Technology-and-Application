/*
 * 测试隐含时间列语法解析的简单程序
 */

#include "postgres.h"
#include "nodes/parsenodes.h"
#include "parser/parser.h"
#include "parser/gramparse.h"

int main()
{
    const char *test_queries[] = {
        "CREATE TABLE test1 (id int, name text) WITH TIME;",
        "CREATE TABLE test2 (id int, name text) WITHOUT TIME;", 
        "CREATE TABLE test3 (id int, name text);",
        "CREATE TABLE IF NOT EXISTS test4 (id int) WITH TIME;",
        NULL
    };
    
    int i;
    List *parse_tree;
    RawStmt *raw_stmt;
    CreateStmt *create_stmt;
    
    printf("测试隐含时间列语法解析...\n");
    
    for (i = 0; test_queries[i] != NULL; i++) {
        printf("\n测试查询 %d: %s\n", i+1, test_queries[i]);
        
        /* 解析SQL语句 */
        parse_tree = raw_parser(test_queries[i]);
        
        if (parse_tree == NIL) {
            printf("  解析失败\n");
            continue;
        }
        
        raw_stmt = (RawStmt *) linitial(parse_tree);
        if (raw_stmt->type != T_RawStmt) {
            printf("  不是RawStmt类型\n");
            continue;
        }
        
        if (nodeTag(raw_stmt->stmt) != T_CreateStmt) {
            printf("  不是CreateStmt类型\n");
            continue;
        }
        
        create_stmt = (CreateStmt *) raw_stmt->stmt;
        printf("  解析成功！\n");
        printf("  表名: %s\n", create_stmt->relation->relname);
        printf("  隐含时间列: %s\n", create_stmt->has_implicit_time ? "是" : "否");
    }
    
    printf("\n测试完成。\n");
    return 0;
}