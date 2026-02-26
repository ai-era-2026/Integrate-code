@echo off
REM =====================================================
REM v2.2_to_v2.3 升级包一键执行脚本 (Windows)
REM =====================================================

setlocal enabledelayedexpansion

REM 设置数据库连接信息
set DB_HOST=%1
if "%DB_HOST%"=="" set DB_HOST=localhost

set DB_USER=%2
if "%DB_USER%"=="" set DB_USER=root

set DB_PASS=%3
if "%DB_PASS%"=="" set DB_PASS=

echo =====================================================
echo 开始执行 v2.2_to_v2.3 升级包...
echo =====================================================
echo.
echo 数据库主机: %DB_HOST%
echo 数据库用户: %DB_USER%
echo.

REM 补丁1: 添加用户公司字段
echo =====================================================
echo 补丁1: 添加用户公司字段...
echo =====================================================
mysql -h "%DB_HOST%" -u "%DB_USER%" -p"%DB_PASS%" YHKB < 001_add_user_company_fields.sql
if %errorlevel% neq 0 (
    echo.
    echo [错误] 补丁1执行失败!
    echo 请检查错误信息后重试。
    pause
    exit /b 1
)
echo 补丁1执行完成
echo.

REM 补丁2: 添加工单抄送字段
echo =====================================================
echo 补丁2: 添加工单抄送字段...
echo =====================================================
mysql -h "%DB_HOST%" -u "%DB_USER%" -p"%DB_PASS%" casedb < 002_add_cc_emails.sql
if %errorlevel% neq 0 (
    echo.
    echo [错误] 补丁2执行失败!
    echo 请检查错误信息后重试。
    pause
    exit /b 1
)
echo 补丁2执行完成
echo.

echo =====================================================
echo v2.2_to_v2.3 升级包执行完成!
echo =====================================================
echo.
echo 请验证升级结果,然后重启应用服务。
echo.
pause
