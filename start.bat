@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo 🚀 启动 OpenAI兼容API代理 for Z.ai GLM-4.5

REM 检查环境变量文件
set ENV_FILE=
if exist ".env.local" (
    set ENV_FILE=.env.local
    echo 📁 使用环境变量文件: .env.local
) else if exist ".env" (
    set ENV_FILE=.env
    echo 📁 使用环境变量文件: .env
) else if exist "config.env" (
    set ENV_FILE=config.env
    echo 📁 使用环境变量文件: config.env
) else (
    echo ⚠️  未找到环境变量文件，使用默认配置
)

REM 加载环境变量
if defined ENV_FILE (
    echo 📋 加载环境变量...
    for /f "tokens=1,2 delims==" %%a in ('type %ENV_FILE% ^| findstr /v "^#"') do (
        set %%a=%%b
    )
)

REM 确定要使用的端口
if defined PORT (
    set TARGET_PORT=%PORT%
) else (
    set TARGET_PORT=9090
)
echo 🔍 检查端口 !TARGET_PORT! 是否被占用...

REM 检查端口是否被占用
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":!TARGET_PORT! .*LISTENING"') do (
    set PID=%%a
)

if defined PID (
    echo ⚠️  端口 !TARGET_PORT! 已被进程 !PID! 占用
    echo 🔌 尝试终止占用进程...
    taskkill /F /PID !PID! >nul 2>&1
    if !errorlevel! equ 0 (
        echo ✅ 成功终止进程 !PID!
        REM 等待一会儿确保进程已完全终止
        timeout /t 2 /nobreak >nul
    ) else (
        echo ❌ 无法终止进程 !PID!，请手动检查并终止
        pause
        exit /b 1
    )
) else (
    echo ✅ 端口 !TARGET_PORT! 未被占用
)

REM 显示关键配置
if defined DEFAULT_KEY (
    echo 🔑 API Key: %DEFAULT_KEY%
) else (
    echo 🔑 API Key: sk-your-key
)

if defined MODEL_NAME (
    echo 🤖 模型名称: %MODEL_NAME%
) else (
    echo 🤖 模型名称: GLM-4.5
)

echo 🌐 端口: !TARGET_PORT!

if defined DEBUG_MODE (
    echo 🐛 调试模式: %DEBUG_MODE%
) else (
    echo 🐛 调试模式: true
)

if defined DEFAULT_STREAM (
    echo 🌊 默认流式: %DEFAULT_STREAM%
) else (
    echo 🌊 默认流式: true
)

if defined ZAI_TOKEN (
    if not "%ZAI_TOKEN%"=="your_z_ai_token_here" (
        echo ✅ Z.ai Token: 已配置
    ) else (
        echo ⚠️  Z.ai Token: 未配置或使用默认值
    )
) else (
    echo ⚠️  Z.ai Token: 未配置或使用默认值
)

echo.
echo 🎯 启动服务...
echo 📍 服务地址: http://localhost:!TARGET_PORT!
echo 📍 Roo CDOE 基础URL: http://localhost:!TARGET_PORT!/v1
echo 📖 API文档: http://localhost:!TARGET_PORT!/docs
echo 📊 Dashboard: http://localhost:!TARGET_PORT!/dashboard
echo.

REM 启动服务
go run main.go
pause
