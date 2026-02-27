@echo off
REM =====================================================
REM 数据库补丁 v2.0 应用脚本 (Windows)
REM 用于旧系统升级到 v2.0 版本
REM 整合 v2.1-v2.5 的所有补丁
REM 版本: v2.0
REM 创建时间: 2026-02-27
REM =====================================================

echo ====================================================
echo 数据库补丁 v2.0 应用脚本
echo ====================================================
echo.

REM 检查参数
if "%~1"=="" (
    echo 用法: apply_upgrade_v2.0.bat [MySQL用户名]
    echo 示例: apply_upgrade_v2.0.bat root
    echo.
    echo 注意:
    echo 1. 本脚本用于旧系统升级，新系统请使用 init_database.sql
    echo 2. 本脚本不包含 v2.8 满意度评价表补丁
    echo 3. 首次运行会提示输入MySQL密码
    echo.
    echo 按任意键继续，或按 Ctrl+C 取消...
    pause > nul
)

set MYSQL_USER=%~1
set MYSQL_HOST=localhost
set MYSQL_PORT=3306

echo 配置信息:
echo   MySQL用户: %MYSQL_USER%
echo   MySQL主机: %MYSQL_HOST%
echo   MySQL端口: %MYSQL_PORT%
echo.

REM 检查SQL文件是否存在
if not exist "upgrade_v2.0_integration.sql" (
    echo 错误: 找不到 upgrade_v2.0_integration.sql 文件
    pause
    exit /b 1
)

echo 警告: 即将对现有数据库应用 v2.0 补丁！
echo.
echo 补丁内容:
echo   知识库系统 (YHKB):
echo     - 扩展 KB_Name 字段长度到 500
echo     - 删除 password_md5 和 real_name 废弃字段
echo     - 添加 display_name 字段
echo     - 添加 company_name 和 phone 字段
echo     - 添加 display_name 到 mgmt_login_logs 表
echo     - 添加 force_password_change 字段
echo.
echo   工单系统 (casedb):
echo     - 添加 assignee 字段(处理人)
echo     - 添加 resolution 字段(解决方案)
echo     - 添加 submit_user 字段(提交用户)
echo     - 添加 customer_contact_name 字段(联系人姓名)
echo     - 添加 cc_emails 字段(抄送邮箱)
echo.
echo 建议在执行前备份数据库！
echo.
set /p confirm=确认执行? (Y/N): 

if /i not "%confirm%"=="Y" (
    echo 已取消操作
    pause
    exit /b 0
)

echo.
echo 正在应用 v2.0 补丁...
echo 请输入MySQL密码:
echo.

REM 执行升级脚本
mysql -h %MYSQL_HOST% -P %MYSQL_PORT% -u %MYSQL_USER% -p < upgrade_v2.0_integration.sql

if %errorlevel% equ 0 (
    echo.
    echo ====================================================
    echo v2.0 补丁应用成功!
    echo ====================================================
    echo.
    echo 注意事项:
    echo 1. 请验证所有功能是否正常
    echo 2. v2.8 工单满意度评价表需要单独执行
    echo 3. 新用户首次登录将强制修改密码
    echo ====================================================
) else (
    echo.
    echo ====================================================
    echo v2.0 补丁应用失败!
    echo 请检查:
    echo 1. MySQL服务是否启动
    echo 2. 用户名和密码是否正确
    echo 3. 用户是否有足够的权限
    echo 4. 数据库表结构是否正确
    echo ====================================================
)

echo.
pause
