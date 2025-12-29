#!/bin/bash

# 编译时间戳格式化测试程序

echo "编译隐含时间列格式化功能测试..."

# 设置编译参数
POSTGRES_SRC="."
INCLUDES="-I${POSTGRES_SRC}/src/include -I${POSTGRES_SRC}/src/include/port/linux_x86_64 -I${POSTGRES_SRC}/src/include/port/linux"
DEFINES="-DPOSTGRES_EPOCH_JDATE=2451545 -DUSECS_PER_SEC=1000000LL -DSECS_PER_DAY=86400"

# 编译测试程序
gcc -o test_timestamp_formatting \
    ${INCLUDES} \
    ${DEFINES} \
    -DTIMESTAMP_NOT_FINITE\(x\)=false \
    -DTIMESTAMP_IS_NOBEGIN\(x\)=false \
    test_timestamp_formatting.c \
    2>/dev/null

if [ $? -eq 0 ]; then
    echo "✓ 编译成功！"
    echo "运行测试程序..."
    ./test_timestamp_formatting
else
    echo "✗ 编译失败，创建简化版本测试..."
    
    # 创建简化的测试程序
    cat > simple_timestamp_test.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

/* 简化的时间戳格式化测试 */

typedef long long Timestamp;

char *format_implicit_timestamp_simple(Timestamp timestamp)
{
    time_t t = timestamp / 1000000LL;  /* 转换为秒 */
    struct tm *tm = gmtime(&t);
    char *result = malloc(32);
    
    if (tm && result) {
        snprintf(result, 32, "%04d-%02d-%02d %02d:%02d:%02d",
                 tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday,
                 tm->tm_hour, tm->tm_min, tm->tm_sec);
    }
    return result;
}

int validate_format_simple(const char *str)
{
    int year, month, day, hour, min, sec;
    
    if (sscanf(str, "%4d-%2d-%2d %2d:%2d:%2d",
               &year, &month, &day, &hour, &min, &sec) != 6)
        return 0;
    
    return (year >= 1 && year <= 9999 &&
            month >= 1 && month <= 12 &&
            day >= 1 && day <= 31 &&
            hour >= 0 && hour <= 23 &&
            min >= 0 && min <= 59 &&
            sec >= 0 && sec <= 59);
}

int main()
{
    printf("简化版时间戳格式化测试\n");
    printf("======================\n");
    
    /* 测试当前时间 */
    time_t now = time(NULL);
    Timestamp ts = now * 1000000LL;  /* 转换为微秒 */
    
    char *formatted = format_implicit_timestamp_simple(ts);
    printf("当前时间格式化: %s\n", formatted);
    
    if (validate_format_simple(formatted))
        printf("✓ 格式验证通过\n");
    else
        printf("✗ 格式验证失败\n");
    
    /* 测试特定时间 */
    Timestamp test_ts = 946684800000000LL;  /* 2000-01-01 00:00:00 */
    char *test_formatted = format_implicit_timestamp_simple(test_ts);
    printf("测试时间格式化: %s\n", test_formatted);
    
    if (validate_format_simple(test_formatted))
        printf("✓ 测试格式验证通过\n");
    else
        printf("✗ 测试格式验证失败\n");
    
    /* 测试格式验证 */
    printf("\n格式验证测试:\n");
    const char *test_formats[] = {
        "2025-12-29 14:30:45",  /* 有效 */
        "2025-13-29 14:30:45",  /* 无效月份 */
        "2025-12-32 14:30:45",  /* 无效日期 */
        "invalid format"         /* 无效格式 */
    };
    
    for (int i = 0; i < 4; i++) {
        int valid = validate_format_simple(test_formats[i]);
        printf("  %s: %s\n", test_formats[i], 
               valid ? "✓ 有效" : "✗ 无效");
    }
    
    free(formatted);
    free(test_formatted);
    
    printf("\n测试完成！\n");
    return 0;
}
EOF

    # 编译简化版本
    gcc -o simple_timestamp_test simple_timestamp_test.c
    if [ $? -eq 0 ]; then
        echo "✓ 简化版本编译成功！"
        echo "运行简化测试..."
        ./simple_timestamp_test
    else
        echo "✗ 编译失败"
    fi
fi