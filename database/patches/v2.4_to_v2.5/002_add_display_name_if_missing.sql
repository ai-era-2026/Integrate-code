-- =====================================================
-- 数据库补丁 v2.4 -> v2.5
-- 功能：检查并添加 display_name 字段（如果不存在）
-- 创建时间：2026-02-26
-- =====================================================

USE `YHKB`;

-- 检查 display_name 字段是否存在，如果不存在则添加
SET @dbname = DATABASE();
SET @tablename = 'users';
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
  CONCAT('ALTER TABLE `', @tablename, '` ADD COLUMN `', @columnname, '` VARCHAR(100) COMMENT ''显示名称'' AFTER `password_hash`;')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- 显示修改后的表结构
DESCRIBE `users`;

SELECT '补丁应用完成：display_name 字段检查并添加成功' AS message;
