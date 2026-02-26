-- =====================================================
-- 补丁: 为工单表添加抄送邮箱字段
-- 影响数据库: casedb
-- 创建时间: 2026-02-18
-- 版本范围: v2.2 -> v2.3
-- 功能说明: 为工单表添加抄送邮箱字段，支持邮件通知抄送功能
-- =====================================================

USE `casedb`;

-- =====================================================
-- 1. 添加 cc_emails 字段(抄送邮箱)
-- =====================================================
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = 'casedb' AND TABLE_NAME = 'tickets' AND COLUMN_NAME = 'cc_emails');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `tickets` ADD COLUMN `cc_emails` TEXT NULL COMMENT "抄送邮箱(多个邮箱用逗号分隔)" AFTER `customer_email`',
    'SELECT "Column cc_emails already exists" AS message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- =====================================================
-- 2. 验证表结构
-- =====================================================
SELECT '=================================================' AS info;
SELECT '工单表补丁验证' AS info;
SELECT '=================================================' AS info;

SHOW COLUMNS FROM `tickets`;

SELECT '=================================================' AS info;
SELECT '补丁执行完成!' AS status;
SELECT '=================================================' AS info;
