-- =====================================================
-- 数据库补丁 v2.0 (整合版)
-- 整合 v2.1-v2.5 的所有补丁，不包括 v2.8
-- 创建时间: 2026-02-27
-- 版本: v2.0
-- 说明：适用于旧系统更新代码后，执行此脚本完成所有补丁
-- =====================================================

-- =====================================================
-- 第一部分：知识库系统补丁 (YHKB)
-- =====================================================

USE `YHKB`;

-- =====================================================
-- 补丁 1.1: 扩展知识库名称字段长度 (v2.1 -> v2.2)
-- 创建时间: 2026-02-13
-- =====================================================
SELECT '补丁 1.1: 扩展 KB_Name 字段长度...' AS info;

ALTER TABLE `KB-info` 
MODIFY COLUMN `KB_Name` VARCHAR(500) NOT NULL COMMENT '知识库名称';

SELECT '补丁 1.1 完成: KB_Name 字段长度已扩展到 500' AS message;

-- =====================================================
-- 补丁 1.2: 删除 password_md5 和 real_name 字段 (v2.4 -> v2.5)
-- 创建时间: 2026-02-25
-- =====================================================
SELECT '补丁 1.2: 删除废弃字段...' AS info;

ALTER TABLE `users` DROP COLUMN IF EXISTS `password_md5`;
ALTER TABLE `users` DROP COLUMN IF EXISTS `real_name`;

SELECT '补丁 1.2 完成: 已删除 password_md5 和 real_name 字段' AS message;

-- =====================================================
-- 补丁 1.3: 添加 display_name 字段 (v2.4 -> v2.5)
-- 创建时间: 2026-02-26
-- =====================================================
SELECT '补丁 1.3: 添加 display_name 字段...' AS info;

SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_SCHEMA = 'YHKB' AND TABLE_NAME = 'users' AND COLUMN_NAME = 'display_name');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `users` ADD COLUMN `display_name` VARCHAR(100) COMMENT "显示名称" AFTER `password_hash`',
    'SELECT "Column display_name already exists" AS message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT '补丁 1.3 完成: display_name 字段已添加' AS message;

-- =====================================================
-- 补丁 1.4: 添加公司相关字段 (v2.2 -> v2.3)
-- 创建时间: 2026-02-18
-- =====================================================
SELECT '补丁 1.4: 添加公司相关字段...' AS info;

SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_SCHEMA = 'YHKB' AND TABLE_NAME = 'users' AND COLUMN_NAME = 'company_name');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `users` ADD COLUMN `company_name` VARCHAR(200) DEFAULT NULL COMMENT "公司名称" AFTER `email`',
    'SELECT "Column company_name already exists" AS message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_SCHEMA = 'YHKB' AND TABLE_NAME = 'users' AND COLUMN_NAME = 'phone');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `users` ADD COLUMN `phone` VARCHAR(20) DEFAULT NULL COMMENT "联系电话" AFTER `company_name`',
    'SELECT "Column phone already exists" AS message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @idx_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
                   WHERE TABLE_SCHEMA = 'YHKB' AND TABLE_NAME = 'users' AND INDEX_NAME = 'idx_company_name');
SET @sql = IF(@idx_exists = 0,
    'CREATE INDEX `idx_company_name` ON `users`(`company_name`)',
    'SELECT "Index idx_company_name already exists" AS message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT '补丁 1.4 完成: 已添加 company_name, phone 字段和索引' AS message;

-- =====================================================
-- 补丁 1.5: 添加 display_name 到登录日志表 (v2.4 -> v2.5, 可选)
-- 创建时间: 2026-02-26
-- =====================================================
SELECT '补丁 1.5: 添加 display_name 到登录日志表...' AS info;

SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_SCHEMA = 'YHKB' AND TABLE_NAME = 'mgmt_login_logs' AND COLUMN_NAME = 'display_name');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `mgmt_login_logs` ADD COLUMN `display_name` VARCHAR(100) COMMENT "显示名称" AFTER `username`',
    'SELECT "Column display_name already exists" AS message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT '补丁 1.5 完成: mgmt_login_logs 的 display_name 字段已添加' AS message;

-- =====================================================
-- 补丁 1.6: 添加 force_password_change 字段 (v2.9)
-- 创建时间: 2026-02-27
-- =====================================================
SELECT '补丁 1.6: 添加 force_password_change 字段...' AS info;

SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_SCHEMA = 'YHKB' AND TABLE_NAME = 'users' AND COLUMN_NAME = 'force_password_change');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `users` ADD COLUMN `force_password_change` TINYINT(1) DEFAULT 0 COMMENT "是否强制修改密码：0-否, 1-是" AFTER `password_type`',
    'SELECT "Column force_password_change already exists" AS message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @idx_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
                   WHERE TABLE_SCHEMA = 'YHKB' AND TABLE_NAME = 'users' AND INDEX_NAME = 'idx_force_password_change');
SET @sql = IF(@idx_exists = 0,
    'CREATE INDEX `idx_force_password_change` ON `users`(`force_password_change`)',
    'SELECT "Index idx_force_password_change already exists" AS message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT '补丁 1.6 完成: force_password_change 字段已添加' AS message;

-- =====================================================
-- 第二部分：工单系统补丁 (casedb)
-- =====================================================

USE `casedb`;

-- =====================================================
-- 补丁 2.1: 添加工单系统缺失字段 (v2.1 -> v2.2)
-- 创建时间: 2026-02-13
-- =====================================================
SELECT '补丁 2.1: 添加工单系统缺失字段...' AS info;

-- 添加 assignee 字段(处理人)
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_SCHEMA = 'casedb' AND TABLE_NAME = 'tickets' AND COLUMN_NAME = 'assignee');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `tickets` ADD COLUMN `assignee` VARCHAR(100) NULL COMMENT "处理人" AFTER `status`',
    'SELECT "Column assignee already exists" AS message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 添加 resolution 字段(解决方案)
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_SCHEMA = 'casedb' AND TABLE_NAME = 'tickets' AND COLUMN_NAME = 'resolution');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `tickets` ADD COLUMN `resolution` TEXT NULL COMMENT "解决方案" AFTER `content`',
    'SELECT "Column resolution already exists" AS message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 添加 idx_assignee 索引
SET @idx_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
                   WHERE TABLE_SCHEMA = 'casedb' AND TABLE_NAME = 'tickets' AND INDEX_NAME = 'idx_assignee');
SET @sql = IF(@idx_exists = 0,
    'CREATE INDEX `idx_assignee` ON `tickets`(`assignee`)',
    'SELECT "Index idx_assignee already exists" AS message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 添加 submit_user 字段(提交工单的用户名)
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_SCHEMA = 'casedb' AND TABLE_NAME = 'tickets' AND COLUMN_NAME = 'submit_user');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `tickets` ADD COLUMN `submit_user` VARCHAR(100) NOT NULL DEFAULT "" COMMENT "提交工单的用户名(来自统一用户表)" AFTER `customer_email`',
    'SELECT "Column submit_user already exists" AS message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 添加 idx_submit_user 索引
SET @idx_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
                   WHERE TABLE_SCHEMA = 'casedb' AND TABLE_NAME = 'tickets' AND INDEX_NAME = 'idx_submit_user');
SET @sql = IF(@idx_exists = 0,
    'CREATE INDEX `idx_submit_user` ON `tickets`(`submit_user`)',
    'SELECT "Index idx_submit_user already exists" AS message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 添加 customer_contact_name 字段(客户联系人姓名)
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_SCHEMA = 'casedb' AND TABLE_NAME = 'tickets' AND COLUMN_NAME = 'customer_contact_name');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `tickets` ADD COLUMN `customer_contact_name` VARCHAR(100) NOT NULL DEFAULT "" COMMENT "客户联系人姓名(当前登录用户)" AFTER `customer_name`',
    'SELECT "Column customer_contact_name already exists" AS message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 添加 idx_customer_contact_name 索引
SET @idx_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
                   WHERE TABLE_SCHEMA = 'casedb' AND TABLE_NAME = 'tickets' AND INDEX_NAME = 'idx_customer_contact_name');
SET @sql = IF(@idx_exists = 0,
    'CREATE INDEX `idx_customer_contact_name` ON `tickets`(`customer_contact_name`)',
    'SELECT "Index idx_customer_contact_name already exists" AS message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT '补丁 2.1 完成: 已添加工单系统缺失字段' AS message;

-- =====================================================
-- 补丁 2.2: 添加抄送邮箱字段 (v2.2 -> v2.3)
-- 创建时间: 2026-02-18
-- =====================================================
SELECT '补丁 2.2: 添加抄送邮箱字段...' AS info;

SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_SCHEMA = 'casedb' AND TABLE_NAME = 'tickets' AND COLUMN_NAME = 'cc_emails');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `tickets` ADD COLUMN `cc_emails` TEXT NULL COMMENT "抄送邮箱(多个邮箱用逗号分隔)" AFTER `customer_email`',
    'SELECT "Column cc_emails already exists" AS message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SELECT '补丁 2.2 完成: 已添加 cc_emails 字段' AS message;

-- =====================================================
-- 第三部分：验证升级结果
-- =====================================================

SELECT '=====================================================' AS info;
SELECT 'v2.0 整合补丁升级完成！' AS message;
SELECT '=====================================================' AS info;
SELECT '' AS message;

-- 验证知识库系统
USE `YHKB`;
SELECT '当前 users 表结构 (YHKB):' AS info;
DESCRIBE `users`;
SELECT '' AS message;

SELECT '当前 KB-info 表结构 (YHKB):' AS info;
DESCRIBE `KB-info`;
SELECT '' AS message;

SELECT '当前 mgmt_login_logs 表结构 (YHKB):' AS info;
DESCRIBE `mgmt_login_logs`;
SELECT '' AS message;

-- 验证工单系统
USE `casedb`;
SELECT '当前 tickets 表结构 (casedb):' AS info;
DESCRIBE `tickets`;
SELECT '' AS message;

SELECT '=====================================================' AS info;
SELECT '补丁汇总：' AS info;
SELECT '=====================================================' AS info;
SELECT '1. 知识库系统 (YHKB):' AS info;
SELECT '   - 扩展 KB_Name 字段长度到 500' AS info;
SELECT '   - 删除 password_md5 和 real_name 废弃字段' AS info;
SELECT '   - 添加 display_name 字段' AS info;
SELECT '   - 添加 company_name 和 phone 字段' AS info;
SELECT '   - 添加 display_name 到 mgmt_login_logs 表' AS info;
SELECT '   - 添加 force_password_change 字段' AS info;
SELECT '' AS message;
SELECT '2. 工单系统 (casedb):' AS info;
SELECT '   - 添加 assignee 字段(处理人)' AS info;
SELECT '   - 添加 resolution 字段(解决方案)' AS info;
SELECT '   - 添加 submit_user 字段(提交用户)' AS info;
SELECT '   - 添加 customer_contact_name 字段(联系人姓名)' AS info;
SELECT '   - 添加 cc_emails 字段(抄送邮箱)' AS info;
SELECT '' AS message;
SELECT '=====================================================' AS info;
SELECT '注意事项：' AS info;
SELECT '- v2.8 工单满意度评价表需要单独执行 upgrade_case_v2.8.sql' AS info;
SELECT '- 请验证所有功能是否正常' AS info;
SELECT '=====================================================' AS info;
