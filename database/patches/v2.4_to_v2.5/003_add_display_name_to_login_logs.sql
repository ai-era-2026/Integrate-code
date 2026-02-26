-- =====================================================
-- 数据库补丁 v2.4 -> v2.5
-- 功能：为 mgmt_login_logs 表添加 display_name 字段（可选，用于历史记录）
-- 创建时间：2026-02-26
-- 说明：这是一个可选补丁，不影响现有功能
-- =====================================================

USE `YHKB`;

-- 检查 display_name 字段是否存在，如果不存在则添加
SET @dbname = DATABASE();
SET @tablename = 'mgmt_login_logs';
SET @columnname = 'display_name';
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (table_schema = @dbname)
      AND (table_name = @tablename)
      AND (column_name = @columnname)
  ) > 0,
  'SELECT 1',
  CONCAT('ALTER TABLE `', @tablename, '` ADD COLUMN `', @columnname, '` VARCHAR(100) COMMENT ''显示名称'' AFTER `username`;')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- 显示修改后的表结构
DESCRIBE `mgmt_login_logs`;

SELECT '补丁应用完成：mgmt_login_logs 表的 display_name 字段已添加（可选）' AS message;
