/*
 * 测试隐含时间列错误处理功能
 */

#include "postgres.h"
#include "utils/implicit_time_error.h"

int main()
{
    printf("测试隐含时间列错误处理功能...\n");
    
    /* 测试调试日志 */
    implicit_time_debug_log("test_function", "这是一个测试调试消息");
    
    /* 测试警告日志 */
    implicit_time_warning_log("test_function", "这是一个测试警告消息");
    
    /* 测试错误上下文 */
    implicit_time_error_context_push("测试上下文1");
    implicit_time_error_context_push("测试上下文2");
    
    implicit_time_error_context_pop();
    implicit_time_error_context_pop();
    
    printf("错误处理功能测试完成！\n");
    
    return 0;
}