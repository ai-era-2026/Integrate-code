# v2.2_to_v2.3 升级包说明

## 概述

此升级包包含从 v2.2 版本升级到 v2.3 版本所需的所有数据库补丁。

## 版本信息

- **起始版本**: v2.2
- **目标版本**: v2.3
- **发布日期**: 2026-02-18
- **兼容数据库**: MariaDB/MySQL 5.7+

## 补丁列表

### 1. 001_add_user_company_fields.sql

**描述**: 为用户表添加公司相关字段

**影响范围**:
- 数据库: `YHKB`
- 表: `users`
- 新增字段:
  - `company_name` - 公司名称(VARCHAR(200))
  - `phone` - 联系电话(VARCHAR(20))
- 新增索引:
  - `idx_company_name`

**预计耗时**: < 1秒

**数据影响**: 仅修改表结构,不影响现有数据

**详细说明**: 见脚本文件注释

---

### 2. 002_add_cc_emails.sql

**描述**: 为工单表添加抄送邮箱字段

**影响范围**:
- 数据库: `casedb`
- 表: `tickets`
- 新增字段:
  - `cc_emails` - 抄送邮箱(TEXT, 多个邮箱用逗号分隔)

**预计耗时**: < 1秒

**数据影响**: 仅修改表结构,不影响现有数据

**详细说明**: 见脚本文件注释

---

## 升级步骤

### 1. 升级前准备

#### 1.1 备份数据库(必须!)

```bash
# 备份所有数据库
mysqldump -h localhost -u root -p \
  --databases clouddoors_db YHKB casedb \
  --single-transaction \
  --routines \
  --triggers \
  > backup_pre_v2.3_$(date +%Y%m%d_%H%M%S).sql

# 验证备份文件
ls -lh backup_pre_v2.3_*.sql
```

#### 1.2 检查当前版本

查看数据库表结构,确认是否已应用过相关补丁:

```sql
-- 检查 YHKB.users 表
USE YHKB;
SHOW COLUMNS FROM users;

-- 检查 casedb.tickets 表
USE casedb;
SHOW COLUMNS FROM tickets;
```

#### 1.3 停止应用服务(推荐)

```bash
# 停止 Flask 应用
# 根据实际部署方式停止服务
# 例如: systemctl stop clouddoors
```

### 2. 执行升级

#### 2.1 方式1: 依次执行补丁

```bash
# 补丁1: 添加用户公司字段
mysql -h localhost -u root -p YHKB < 001_add_user_company_fields.sql

# 补丁2: 添加工单抄送字段
mysql -h localhost -u root -p casedb < 002_add_cc_emails.sql
```

#### 2.2 方式2: 使用 MySQL 客户端

```bash
# 登录 MySQL
mysql -h localhost -u root -p

# 在 MySQL 客户端中执行:
mysql> SOURCE /path/to/001_add_user_company_fields.sql
mysql> USE casedb;
mysql> SOURCE /path/to/002_add_cc_emails.sql
```

#### 2.3 方式3: 一键执行所有补丁

```bash
# Windows
apply_patches_v2.2_to_v2.3.bat

# Linux/Mac
chmod +x apply_patches_v2.2_to_v2.3.sh
./apply_patches_v2.2_to_v2.3.sh
```

### 3. 验证升级结果

#### 3.1 验证用户表(YHKB)

```sql
USE YHKB;

-- 检查新增字段
SHOW COLUMNS FROM users;

-- 验证字段存在
SELECT COUNT(*) AS company_name_exists 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA='YHKB' AND TABLE_NAME='users' AND COLUMN_NAME='company_name';

SELECT COUNT(*) AS phone_exists 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA='YHKB' AND TABLE_NAME='users' AND COLUMN_NAME='phone';

-- 验证索引存在
SHOW INDEX FROM users WHERE Key_name LIKE 'idx_%';
```

预期结果: 所有字段和索引都应存在(查询结果为 1)。

#### 3.2 验证工单表(casedb)

```sql
USE casedb;

-- 检查新增字段
SHOW COLUMNS FROM tickets;

-- 验证字段存在
SELECT COUNT(*) AS cc_emails_exists 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA='casedb' AND TABLE_NAME='tickets' AND COLUMN_NAME='cc_emails';
```

预期结果: `cc_emails` 字段应存在(查询结果为 1)。

### 4. 重启应用服务

```bash
# 启动 Flask 应用
# 根据实际部署方式启动服务
# 例如: systemctl start clouddoors

# 检查日志确认服务正常启动
tail -f logs/app.log
```

### 5. 功能测试

#### 5.1 用户表功能测试

1. 创建客户账号时，填写公司名称和联系电话
2. 验证公司名称和联系电话正确保存
3. 验证按公司名称可以查询到对应的客户用户

#### 5.2 工单创建测试

1. 管理员/普通用户创建工单时，可以选择不同公司
2. 选择公司后，可以自动填充该公司的客户联系人
3. 选择联系人后，可以自动填充联系电话和邮箱
4. 可以添加抄送邮箱，多个邮箱用逗号分隔
5. 验证抄送邮箱正确保存到工单中

#### 5.3 工单查询测试

1. 客户角色登录后，只能看到自己创建的工单
2. 管理员/普通用户登录后，可以看到所有工单
3. 管理员/普通用户可以筛选"我的工单"(自己创建的工单)
4. 管理员/普通用户可以查看公司其他账户创建的工单

## 回滚方案

如果升级后出现问题,请按以下步骤回滚:

### 1. 停止应用服务

```bash
# 停止服务
systemctl stop clouddoors
```

### 2. 恢复数据库

```bash
# 从备份恢复
mysql -h localhost -u root -p < backup_pre_v2.3_YYYYMMDD_HHMMSS.sql
```

### 3. 验证恢复结果

```sql
-- 检查 YHKB.users 表结构
USE YHKB;
SHOW COLUMNS FROM users;

-- 检查 casedb.tickets 表结构
USE casedb;
SHOW COLUMNS FROM tickets;
```

### 4. 重启应用服务

```bash
# 启动服务
systemctl start clouddoors
```

## 常见问题

### Q1: 补丁执行时报错 "Duplicate column name"

**A**: 这是正常的提示,说明字段已存在。补丁已设计为幂等,可忽略此提示。

### Q2: 升级后发现应用功能异常

**A**: 请立即停止应用,按回滚步骤恢复数据库,然后联系技术支持。

### Q3: 某个补丁执行失败

**A**: 
1. 检查数据库连接是否正常
2. 确认数据库用户权限
3. 查看错误日志获取详细信息
4. 补丁可重复执行,修复问题后重试

### Q4: 客户用户没有填写公司名称怎么办

**A**: 公司名称字段可以为 NULL。建议在创建客户账号时要求填写公司名称。

### Q5: 抄送邮箱功能如何使用

**A**: 
1. 在创建工单时,可以填写抄送邮箱
2. 多个邮箱用逗号分隔,如: a@example.com,b@example.com,c@example.com
3. 抄送邮箱会保存在工单的 `cc_emails` 字段
4. 后期对接邮件系统后,会根据此字段进行邮件抄送

## 注意事项

1. **必须备份**: 升级前必须备份数据库
2. **顺序执行**: 按补丁编号顺序依次执行
3. **验证结果**: 每个补丁执行后都要验证
4. **测试环境**: 建议先在测试环境验证,再在生产环境执行
5. **停机时间**: 升级期间建议暂停服务,避免数据不一致
6. **客户数据**: 建议为所有客户用户补充公司名称和联系电话信息

## 技术支持

如有问题,请联系技术支持团队。

---

**版本**: 1.0
**发布日期**: 2026-02-18
**维护人员**: 云户科技技术团队
