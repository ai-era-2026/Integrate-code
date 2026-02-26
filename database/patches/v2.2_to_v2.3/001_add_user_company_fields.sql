-- =====================================================
-- 补丁: 为用户表添加公司相关字段
-- 影响数据库: YHKB
-- 创建时间: 2026-02-18
-- 版本范围: v2.2 -> v2.3
-- 功能说明: 为用户表添加公司名称、联系电话字段，支持工单系统按公司管理客户
-- =====================================================

USE `YHKB`;

-- =====================================================
-- 1. 添加 company_name 字段(公司名称)
-- =====================================================
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = 'YHKB' AND TABLE_NAME = 'users' AND COLUMN_NAME = 'company_name');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `users` ADD COLUMN `company_name` VARCHAR(200) DEFAULT NULL COMMENT "公司名称" AFTER `email`',
    'SELECT "Column company_name already exists" AS message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- =====================================================
-- 2. 添加 phone 字段(联系电话)
-- =====================================================
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
     WHERE TABLE_SCHEMA = 'YHKB' AND TABLE_NAME = 'users' AND COLUMN_NAME = 'phone');
SET @sql = IF(@col_exists = 0,
    'ALTER TABLE `users` ADD COLUMN `phone` VARCHAR(20) DEFAULT NULL COMMENT "联系电话" AFTER `company_name`',
    'SELECT "Column phone already exists" AS message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- =====================================================
-- 3. 添加 idx_company_name 索引
-- =====================================================
SET @idx_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
     WHERE TABLE_SCHEMA = 'YHKB' AND TABLE_NAME = 'users' AND INDEX_NAME = 'idx_company_name');
SET @sql = IF(@idx_exists = 0,
    'CREATE INDEX `idx_company_name` ON `users`(`company_name`)',
    'SELECT "Index idx_company_name already exists" AS message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- =====================================================
-- 4. 验证表结构
-- =====================================================
SELECT '=================================================' AS info;
SELECT '用户表补丁验证' AS info;
SELECT '=================================================' AS info;

SHOW COLUMNS FROM `users`;

-- 查询客户角色的用户信息
SELECT '=================================================' AS info;
SELECT '客户用户列表(按公司分组)' AS info;
SELECT '=================================================' AS info;

SELECT 
    company_name AS '公司名称',
    COUNT(*) AS '用户数量',
    GROUP_CONCAT(CONCAT(username, '(', real_name, ')') SEPARATOR '; ') AS '用户列表'
FROM `users`
WHERE role = 'customer' AND status = 'active'
GROUP BY company_name
ORDER BY company_name;

SELECT '=================================================' AS info;
SELECT '补丁执行完成!' AS status;
SELECT '=================================================' AS info;
