# 数据库升级指南 v2.0

## 概述

本指南用于将旧版本的云户科技网站系统升级到 v2.0 版本。

**版本:** v2.0  
**创建时间:** 2026-02-27  
**适用场景:** 旧系统代码更新后执行数据库补丁

## 文件说明

- `upgrade_v2.0_integration.sql` - 数据库升级SQL脚本
- `apply_upgrade_v2.0.bat` - Windows自动化脚本
- `apply_upgrade_v2.0.sh` - Linux/macOS自动化脚本

## 升级内容

本补丁整合了 v2.1 到 v2.5 的所有数据库变更：

### 知识库系统 (YHKB)

| 序号 | 补丁名称 | 说明 |
|------|---------|------|
| 1.1 | 扩展 KB_Name 字段 | 将 KB_Name 字段长度从 VARCHAR(100) 扩展到 VARCHAR(500) |
| 1.2 | 删除废弃字段 | 删除 password_md5 和 real_name 字段 |
| 1.3 | 添加 display_name | 添加显示名称字段用于用户友好展示 |
| 1.4 | 添加公司字段 | 添加 company_name 和 phone 字段，支持客户角色 |
| 1.5 | 登录日志增强 | 在 mgmt_login_logs 表添加 display_name 字段 |
| 1.6 | 强制修改密码 | 添加 force_password_change 字段，支持新用户首次登录强制修改密码 |

### 工单系统 (casedb)

| 序号 | 补丁名称 | 说明 |
|------|---------|------|
| 2.1 | 添加处理人字段 | 添加 assignee 字段（处理人）和 resolution 字段（解决方案） |
| 2.2 | 添加提交用户字段 | 添加 submit_user 字段（提交工单的用户名） |
| 2.3 | 添加联系人字段 | 添加 customer_contact_name 字段（客户联系人姓名） |
| 2.4 | 添加抄送邮箱 | 添加 cc_emails 字段（支持多个邮箱，逗号分隔） |

## 使用方法

### Windows系统

1. 打开命令提示符(CMD)或PowerShell
2. 进入patches目录：
   ```cmd
   cd e:\Integrate-code\database\patches
   ```
3. 执行升级脚本：
   ```cmd
   apply_upgrade_v2.0.bat root
   ```
4. 按提示输入MySQL密码
5. 确认执行

### Linux/macOS系统

1. 打开终端
2. 进入patches目录：
   ```bash
   cd /path/to/Integrate-code/database/patches
   ```
3. 添加执行权限（首次运行）：
   ```bash
   chmod +x apply_upgrade_v2.0.sh
   ```
4. 执行升级脚本：
   ```bash
   ./apply_upgrade_v2.0.sh root
   ```
5. 按提示输入MySQL密码
6. 确认执行

### 手动执行

如需手动执行，可以使用以下命令：

```bash
mysql -u root -p < upgrade_v2.0_integration.sql
```

## 升级前准备

### 1. 备份数据库

**强烈建议在升级前备份数据库！**

```bash
# 备份知识库数据库
mysqldump -u root -p YHKB > YHKB_backup_$(date +%Y%m%d).sql

# 备份工单数据库
mysqldump -u root -p casedb > casedb_backup_$(date +%Y%m%d).sql

# 备份官网数据库
mysqldump -u root -p clouddoors_db > clouddoors_db_backup_$(date +%Y%m%d).sql
```

### 2. 检查当前版本

```sql
-- 检查 users 表结构
USE YHKB;
DESCRIBE users;

-- 检查 tickets 表结构
USE casedb;
DESCRIBE tickets;
```

### 3. 停止应用服务

升级期间建议停止应用服务，避免数据冲突。

## 验证升级

升级完成后，可以通过以下方式验证：

### 1. 检查新字段是否添加

```sql
-- 检查 users 表新字段
USE YHKB;
SHOW COLUMNS FROM users LIKE 'display_name';
SHOW COLUMNS FROM users LIKE 'company_name';
SHOW COLUMNS FROM users LIKE 'phone';
SHOW COLUMNS FROM users LIKE 'force_password_change';

-- 检查 tickets 表新字段
USE casedb;
SHOW COLUMNS FROM tickets LIKE 'assignee';
SHOW COLUMNS FROM tickets LIKE 'resolution';
SHOW COLUMNS FROM tickets LIKE 'submit_user';
SHOW COLUMNS FROM tickets LIKE 'customer_contact_name';
SHOW COLUMNS FROM tickets LIKE 'cc_emails';
```

### 2. 检查废弃字段是否删除

```sql
-- 检查废弃字段是否已删除
USE YHKB;
SHOW COLUMNS FROM users LIKE 'password_md5';
SHOW COLUMNS FROM users LIKE 'real_name';
-- 应该返回空结果
```

### 3. 检查索引是否创建

```sql
-- 检查索引
USE YHKB;
SHOW INDEX FROM users WHERE Key_name = 'idx_company_name';
SHOW INDEX FROM users WHERE Key_name = 'idx_force_password_change';

USE casedb;
SHOW INDEX FROM tickets WHERE Key_name = 'idx_assignee';
SHOW INDEX FROM tickets WHERE Key_name = 'idx_submit_user';
SHOW INDEX FROM tickets WHERE Key_name = 'idx_customer_contact_name';
```

## 新功能说明

### 强制修改密码功能

升级后，系统支持强制新用户首次登录修改密码：

1. **原理**: 通过 `users.force_password_change` 字段控制
   - `0` - 不强制修改（默认）
   - `1` - 强制修改

2. **触发条件**:
   - 管理员创建用户时，可设置 `force_password_change=1`
   - 用户首次登录后，系统会检测该字段
   - 如果为1，将强制跳转到修改密码页面

3. **使用场景**:
   - 新用户通过邮件获取随机密码后，首次登录必须修改密码
   - 提高账户安全性

4. **示例SQL**:
   ```sql
   -- 创建新用户并强制修改密码
   INSERT INTO users (username, password_hash, display_name, role, force_password_change)
   VALUES ('newuser', 'password_hash_here', '新用户', 'user', 1);
   ```

## 可选补丁

本升级脚本**不包含**以下补丁，需要单独执行：

### v2.8 工单满意度评价表

如果需要工单满意度评价功能，请单独执行：

```bash
cd /path/to/database
mysql -u root -p < upgrade_case_v2.8.sql
```

该补丁将在 `casedb` 数据库中创建 `satisfaction` 表。

## 回滚方案

如果升级后出现问题，可以：

1. **回滚到备份**：
   ```bash
   mysql -u root -p YHKB < YHKB_backup_YYYYMMDD.sql
   mysql -u root -p casedb < casedb_backup_YYYYMMDD.sql
   ```

2. **手动删除新字段**：
   ```sql
   -- 删除新增的字段（谨慎操作！）
   ALTER TABLE YHKB.users DROP COLUMN display_name;
   ALTER TABLE YHKB.users DROP COLUMN company_name;
   ALTER TABLE YHKB.users DROP COLUMN phone;
   ALTER TABLE YHKB.users DROP COLUMN force_password_change;
   
   ALTER TABLE casedb.tickets DROP COLUMN assignee;
   ALTER TABLE casedb.tickets DROP COLUMN resolution;
   ALTER TABLE casedb.tickets DROP COLUMN submit_user;
   ALTER TABLE casedb.tickets DROP COLUMN customer_contact_name;
   ALTER TABLE casedb.tickets DROP COLUMN cc_emails;
   ```

## 常见问题

### Q1: 升级脚本报错 "Column already exists"

**原因**: 字段已经存在，可能已经执行过升级

**解决方案**: 
- 脚本已使用条件检查，重复执行不会报错
- 如果报错，检查字段是否已存在，可以忽略

### Q2: 升级后部分功能异常

**原因**: 可能是代码版本与数据库版本不匹配

**解决方案**:
- 确保代码已更新到最新版本
- 检查 `config.py` 中的数据库配置
- 查看应用日志

### Q3: 升级过程中断

**原因**: MySQL连接中断或其他异常

**解决方案**:
- 重新执行升级脚本，脚本是幂等的，可以重复执行
- 检查MySQL服务状态
- 查看MySQL错误日志

### Q4: 需要恢复旧字段吗？

**原因**: `password_md5` 和 `real_name` 字段被删除

**解决方案**:
- `password_md5` 是废弃字段，不再使用
- `real_name` 已被 `display_name` 替代，不需要恢复
- 如果确实需要，可以从备份中手动添加

## 注意事项

1. **备份**: 升级前务必备份数据库
2. **停服**: 建议升级期间停止应用服务
3. **测试**: 建议在测试环境先验证升级流程
4. **权限**: 确保MySQL用户有ALTER TABLE权限
5. **时间**: 升级过程通常需要几分钟，取决于数据量
6. **验证**: 升级后务必验证所有功能

## 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v2.0 | 2026-02-27 | 整合v2.1-v2.5所有补丁 |

## 技术支持

如遇到问题，请检查：
1. 数据库备份是否正确
2. MySQL/MariaDB版本是否符合要求（5.7+/10.2+）
3. 升级日志中的错误信息
4. 应用日志（logs/目录）

---

**文档版本:** v1.0  
**最后更新:** 2026-02-27
