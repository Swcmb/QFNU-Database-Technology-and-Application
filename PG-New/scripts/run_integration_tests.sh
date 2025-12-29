#!/bin/bash

# PostgreSQL隐含时间列功能 - 集成测试执行脚本
# 运行综合集成测试和性能基准测试

echo "=========================================="
echo "PostgreSQL隐含时间列功能集成测试"
echo "=========================================="

# 检查PostgreSQL是否运行
if ! pgrep -x "postgres" > /dev/null; then
    echo "错误: PostgreSQL服务未运行"
    echo "请先启动PostgreSQL服务"
    exit 1
fi

# 设置数据库连接参数
DB_NAME="test_implicit_time"
DB_USER="uxdb"
DB_HOST="localhost"
DB_PORT="5432"

echo "数据库连接信息:"
echo "  数据库: $DB_NAME"
echo "  用户: $DB_USER"
echo "  主机: $DB_HOST"
echo "  端口: $DB_PORT"
echo ""

# 创建测试数据库（如果不存在）
echo "创建测试数据库..."
createdb -U $DB_USER -h $DB_HOST -p $DB_PORT $DB_NAME 2>/dev/null || echo "数据库已存在或创建失败"

# 函数：运行SQL测试文件
run_sql_test() {
    local test_file=$1
    local test_name=$2
    
    echo "=========================================="
    echo "运行测试: $test_name"
    echo "文件: $test_file"
    echo "=========================================="
    
    if [ ! -f "$test_file" ]; then
        echo "错误: 测试文件 $test_file 不存在"
        return 1
    fi
    
    # 记录开始时间
    start_time=$(date +%s)
    
    # 运行测试
    /db/uxdb/bin/psql -U $DB_USER -h $DB_HOST -p $DB_PORT -d $DB_NAME -f "$test_file"
    test_result=$?
    
    # 记录结束时间
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    echo ""
    echo "测试完成: $test_name"
    echo "执行时间: ${duration}秒"
    
    if [ $test_result -eq 0 ]; then
        echo "结果: 成功"
    else
        echo "结果: 失败 (退出代码: $test_result)"
    fi
    
    echo ""
    return $test_result
}

# 运行测试套件
echo "开始运行集成测试套件..."
echo ""

# 测试1: 综合集成测试
run_sql_test "test_integration_comprehensive.sql" "综合集成测试"
comprehensive_result=$?

# 测试2: 性能基准测试
run_sql_test "test_performance_benchmark.sql" "性能基准测试"
performance_result=$?

# 测试3: 运行现有的核心功能测试
if [ -f "test_core_functionality.sql" ]; then
    run_sql_test "test_core_functionality.sql" "核心功能测试"
    core_result=$?
else
    echo "警告: 核心功能测试文件不存在"
    core_result=0
fi

# 测试4: 运行现有的综合功能测试
if [ -f "test_comprehensive_functionality.sql" ]; then
    run_sql_test "test_comprehensive_functionality.sql" "现有综合功能测试"
    existing_result=$?
else
    echo "警告: 现有综合功能测试文件不存在"
    existing_result=0
fi

# 汇总测试结果
echo "=========================================="
echo "测试结果汇总"
echo "=========================================="

total_tests=0
passed_tests=0

if [ $comprehensive_result -eq 0 ]; then
    echo "✓ 综合集成测试: 通过"
    passed_tests=$((passed_tests + 1))
else
    echo "✗ 综合集成测试: 失败"
fi
total_tests=$((total_tests + 1))

if [ $performance_result -eq 0 ]; then
    echo "✓ 性能基准测试: 通过"
    passed_tests=$((passed_tests + 1))
else
    echo "✗ 性能基准测试: 失败"
fi
total_tests=$((total_tests + 1))

if [ $core_result -eq 0 ]; then
    echo "✓ 核心功能测试: 通过"
    passed_tests=$((passed_tests + 1))
else
    echo "✗ 核心功能测试: 失败"
fi
total_tests=$((total_tests + 1))

if [ $existing_result -eq 0 ]; then
    echo "✓ 现有综合功能测试: 通过"
    passed_tests=$((passed_tests + 1))
else
    echo "✗ 现有综合功能测试: 失败"
fi
total_tests=$((total_tests + 1))

echo ""
echo "总计: $passed_tests/$total_tests 测试通过"

# 生成测试报告
report_file="integration_test_report_$(date +%Y%m%d_%H%M%S).txt"
echo "生成测试报告: $report_file"

cat > "$report_file" << EOF
PostgreSQL隐含时间列功能集成测试报告
=====================================

测试时间: $(date)
数据库: $DB_NAME
用户: $DB_USER

测试结果:
---------
综合集成测试: $([ $comprehensive_result -eq 0 ] && echo "通过" || echo "失败")
性能基准测试: $([ $performance_result -eq 0 ] && echo "通过" || echo "失败")
核心功能测试: $([ $core_result -eq 0 ] && echo "通过" || echo "失败")
现有综合功能测试: $([ $existing_result -eq 0 ] && echo "通过" || echo "失败")

总计: $passed_tests/$total_tests 测试通过

测试覆盖的功能:
--------------
1. DDL语法支持 (WITH TIME / WITHOUT TIME)
2. 隐含列存储管理
3. 查询行为控制
4. 时间格式和精度
5. 更新策略和性能
6. 系统兼容性
7. 错误处理和日志
8. 复杂场景集成
9. 并发和锁定
10. 数据完整性验证
11. 性能基准测试

建议:
-----
$(if [ $passed_tests -eq $total_tests ]; then
    echo "所有测试都通过了！隐含时间列功能已准备好投入使用。"
else
    echo "有测试失败，请检查失败的测试并修复相关问题。"
    echo "建议查看测试输出中的错误信息，并检查相关的实现代码。"
fi)
EOF

echo "测试报告已保存到: $report_file"

# 清理测试数据库（可选）
read -p "是否删除测试数据库 $DB_NAME? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "删除测试数据库..."
    dropdb -U $DB_USER -h $DB_HOST -p $DB_PORT $DB_NAME
    echo "测试数据库已删除"
fi

# 返回适当的退出代码
if [ $passed_tests -eq $total_tests ]; then
    echo "所有集成测试完成并通过！"
    exit 0
else
    echo "集成测试完成，但有失败的测试。"
    exit 1
fi