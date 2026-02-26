-- =====================================================
-- 数据库补丁 v2.4 -> v2.5
-- 功能：删除已废弃的 password_md5 和 real_name 字段
-- 创建时间：2026-02-25
-- =====================================================

USE `YHKB`;

-- 删除已废弃的 password_md5 字段
ALTER TABLE `users` DROP COLUMN IF EXISTS `password_md5`;

-- 删除已废弃的 real_name 字段（统一使用 display_name）
ALTER TABLE `users` DROP COLUMN IF EXISTS `real_name`;

-- 显示修改后的表结构
DESCRIBE `users`;

SELECT '补丁应用成功：password_md5 和 real_name 字段已删除' AS message;
