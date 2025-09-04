#!/bin/bash

# OpenAI兼容API代理启动脚本
# 支持从环境变量文件加载配置，添加了端口占用检测功能

echo "🚀 启动 OpenAI兼容API代理 for Z.ai GLM-4.5"

# 检查环境变量文件
ENV_FILE=""
if [ -f ".env.local" ]; then
    ENV_FILE=".env.local"
    echo "📁 使用环境变量文件: .env.local"
elif [ -f ".env" ]; then
    ENV_FILE=".env"
    echo "📁 使用环境变量文件: .env"
elif [ -f "config.env" ]; then
    ENV_FILE="config.env"
    echo "📁 使用环境变量文件: config.env"
else
    echo "⚠️  未找到环境变量文件，使用默认配置"
fi

# 加载环境变量
if [ -n "$ENV_FILE" ]; then
    echo "📋 加载环境变量..."
    export $(grep -v '^#' $ENV_FILE | xargs)
fi

# 确定要使用的端口
TARGET_PORT=${PORT:-9090}
echo "🔍 检查端口 $TARGET_PORT 是否被占用..."

# # 检查端口是否被占用并获取进程ID
PID=$(lsof -t -i:$TARGET_PORT)

if [ -n "$PID" ]; then
    echo "⚠️  端口 $TARGET_PORT 已被进程 $PID 占用"
    echo "🔌 尝试终止占用进程..."
    if kill $PID; then
        echo "✅ 成功终止进程 $PID"
        # 等待一会儿确保进程已完全终止
        sleep 2
    else
        echo "❌ 无法终止进程 $PID，请手动检查并终止"
        exit 1
    fi
else
    echo "✅ 端口 $TARGET_PORT 未被占用"
fi

# 显示关键配置
echo "🔑 API Key: ${DEFAULT_KEY:-sk-your-key}"
echo "🤖 模型名称: ${MODEL_NAME:-GLM-4.5}"
echo "🌐 端口: $TARGET_PORT"
echo "🐛 调试模式: ${DEBUG_MODE:-true}"
echo "🌊 默认流式: ${DEFAULT_STREAM:-true}"
echo "🧠 思考功能: ${ENABLE_THINKING:-false}"

if [ -n "$ZAI_TOKEN" ] && [ "$ZAI_TOKEN" != "your_z_ai_token_here" ]; then
    echo "✅ Z.ai Token: 已配置"
else
    echo "⚠️  Z.ai Token: 未配置或使用默认值"
fi

echo ""
echo "🎯 启动服务..."
echo "📍 服务地址: http://localhost:$TARGET_PORT"
echo "📍 Roo CDOE 基础URL: http://localhost:$TARGET_PORT/v1"
echo "📖 API文档: http://localhost:$TARGET_PORT/docs"
echo "📊 Dashboard: http://localhost:$TARGET_PORT/dashboard"
echo ""

# 启动服务
go run main.go
