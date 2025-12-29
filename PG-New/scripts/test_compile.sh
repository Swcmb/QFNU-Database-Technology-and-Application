#!/bin/bash

# 测试PostgreSQL编译环境脚本

echo "=== PostgreSQL隐含时间列功能开发环境测试 ==="
echo ""

# 检查编译状态
echo "1. 检查postgres可执行文件..."
if [ -f "src/backend/postgres" ]; then
    echo "✓ postgres可执行文件存在"
    echo "  版本信息: $(src/backend/postgres --version 2>/dev/null || echo '无法获取版本信息')"
else
    echo "✗ postgres可执行文件不存在"
    exit 1
fi

# 检查关键源码文件
echo ""
echo "2. 检查关键源码文件..."

key_files=(
    "src/backend/parser/gram.y"
    "src/common/keywords.c"
    "src/include/catalog/pg_class.h"
    "src/backend/catalog/heap.c"
    "src/backend/executor/execMain.c"
    "src/include/access/htup_details.h"
)

for file in "${key_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file"
    else
        echo "✗ $file (缺失)"
    fi
done

# 检查Git分支
echo ""
echo "3. 检查Git分支..."
current_branch=$(git branch --show-current 2>/dev/null)
if [ "$current_branch" = "feature/implicit-time-column" ]; then
    echo "✓ 当前在功能开发分支: $current_branch"
else
    echo "✗ 当前分支: $current_branch (应该在feature/implicit-time-column)"
fi

# 检查编译工具
echo ""
echo "4. 检查编译工具..."
if command -v gcc >/dev/null 2>&1; then
    echo "✓ GCC: $(gcc --version | head -n1)"
else
    echo "✗ GCC未找到"
fi

if command -v mingw32-make >/dev/null 2>&1; then
    echo "✓ Make: $(mingw32-make --version | head -n1)"
else
    echo "✗ Make未找到"
fi

echo ""
echo "=== 环境检查完成 ==="
echo ""
echo "开发环境已准备就绪，可以开始实施隐含时间列功能。"
echo "下一步: 执行任务2 - 扩展DDL语法解析器"