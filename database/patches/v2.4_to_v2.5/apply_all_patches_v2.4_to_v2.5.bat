@echo off
chcp 65001 >nul
echo =====================================================
echo 应用数据库补丁 v2.4 -> v2.5
echo =====================================================
echo.

REM 检查 MySQL 是否可用
mysql --version >nul 2>&1
if errorlevel 1 (
    echo 错误：未找到 MySQL 命令行工具
    echo 请确保 MySQL 已安装并添加到系统 PATH
    pause
    exit /b 1
)

echo 正在应用补丁 001：删除已废弃字段...
mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASSWORD% YHKB < "database\patches\v2.4_to_v2.5\001_remove_password_md5_and_real_name.sql"
if errorlevel 1 (
    echo 补丁 001 应用失败！
    pause
    exit /b 1
)
echo 补丁 001 应用成功
echo.

echo 正在应用补丁 002：添加 display_name 字段（如果不存在）...
mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASSWORD% YHKB < "database\patches\v2.4_to_v2.5\002_add_display_name_if_missing.sql"
if errorlevel 1 (
    echo 补丁 002 应用失败！
    pause
    exit /b 1
)
echo 补丁 002 应用成功
echo.

echo 正在应用补丁 003：为登录日志表添加 display_name 字段（可选）...
mysql -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASSWORD% YHKB < "database\patches\v2.4_to_v2.5\003_add_display_name_to_login_logs.sql"
if errorlevel 1 (
    echo 补丁 003 应用失败！
    echo 注意：此补丁是可选的，不影响系统运行
    echo.
) else (
    echo 补丁 003 应用成功
    echo.
)

echo =====================================================
echo 所有补丁应用完成！
echo =====================================================
echo.
echo 数据库已更新到 v2.5 版本
echo.
pause
