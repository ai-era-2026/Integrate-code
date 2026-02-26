# 数据库补丁 v2.4 -> v2.5

## 版本信息

- **版本号**：v2.5
- **发布日期**：2026-02-26
- **兼容版本**：v2.4

## 更新内容

### 主要变更

#### 1. 删除废弃字段

从 `users` 表中删除以下已废弃的字段：

- **`password_md5`** - 密码MD5值字段
  - 原因：统一使用 werkzeug 加密后不再需要 MD5
  - 废弃时间：v2.2 版本
  - 删除原因：简化表结构，消除冗余

- **`real_name`** - 真实姓名字段
  - 原因：统一使用 `display_name` 字段
  - 替代方案：使用 `display_name` 显示用户名
  - 删除原因：字段冗余，统一命名规范

#### 2. 添加 display_name 字段（修复补丁）

- **补丁 002**：检查并添加 `display_name` 字段到 `users` 表（如果不存在）
  - 原因：某些旧版本数据库可能缺少此字段
  - 影响：修复 "Unknown column 'display_name' in 'INSERT INTO'" 错误

#### 3. 添加 display_name 到登录日志表（可选补丁）

- **补丁 003**：为 `mgmt_login_logs` 表添加 `display_name` 字段（可选）
  - 原因：记录登录时的显示名称，便于历史查询
  - 影响：不影响现有功能，可选升级

### 表结构变化

#### 修改前的 users 表结构

```sql
CREATE TABLE `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(50) NOT NULL UNIQUE,
    `password_hash` VARCHAR(255) NOT NULL,
    `password_md5` VARCHAR(64) DEFAULT NULL,      -- 已废弃
    `display_name` VARCHAR(100),
    `real_name` VARCHAR(100),                      -- 已废弃
    `email` VARCHAR(100),
    `company_name` VARCHAR(200) DEFAULT NULL,
    `phone` VARCHAR(20) DEFAULT NULL,
    `role` VARCHAR(20) DEFAULT 'user',
    `status` VARCHAR(20) DEFAULT 'active',
    `last_login` TIMESTAMP NULL,
    `login_attempts` INT DEFAULT 0,
    `password_type` VARCHAR(10) DEFAULT 'werkzeug',
    `system` VARCHAR(20) DEFAULT 'unified',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `created_by` VARCHAR(50)
);
```

#### 修改后的 users 表结构

```sql
CREATE TABLE `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(50) NOT NULL UNIQUE,
    `password_hash` VARCHAR(255) NOT NULL,
    `display_name` VARCHAR(100),              -- 统一使用此字段显示用户名
    `email` VARCHAR(100),
    `company_name` VARCHAR(200) DEFAULT NULL,
    `phone` VARCHAR(20) DEFAULT NULL,
    `role` VARCHAR(20) DEFAULT 'user',
    `status` VARCHAR(20) DEFAULT 'active',
    `last_login` TIMESTAMP NULL,
    `login_attempts` INT DEFAULT 0,
    `password_type` VARCHAR(10) DEFAULT 'werkzeug',
    `system` VARCHAR(20) DEFAULT 'unified',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `created_by` VARCHAR(50)
);
```

### 代码变更说明

#### Python 代码变更

1. **common/unified_auth.py**
   - 删除所有 `real_name` 相关逻辑
   - 更新 SQL 查询，移除 `real_name` 字段
   - 更新 `get_current_user()` 函数，删除 `real_name` session
   - 简化用户信息返回

2. **common/validators.py**
   - 更新 `USER_SCHEMA`，删除 `real_name` 验证

3. **services/user_service.py**
   - 删除 `update_user()` 中的 `real_name` 更新逻辑
   - 更新 `get_user()` 和 `get_users()` 查询，移除 `real_name` 字段

4. **routes/unified_bp.py**
   - 删除 API 文档中的 `real_name` 参数
   - 更新 `add_user()` 路由

5. **routes/auth_bp.py**
   - 更新 `add_user()` 和 `update_user()` 路由

6. **routes/case_bp.py**
   - 更新登录成功后的 session 设置
   - 更新所有 SQL 查询，移除 `real_name` 字段
   - 更新消息发送逻辑

7. **services/socketio_service.py**
   - 检查并更新相关代码（如需要）

#### 模板文件变更

1. **templates/case/base.html**
   - 更新 session 显示，将 `real_name` 改为 `display_name`

2. **templates/case/submit_ticket.html**
   - 更新 session 显示
   - 更新表单字段值绑定
   - 更新 JavaScript 中的 `user.real_name` 为 `user.display_name`

3. **templates/case/ticket_list.html**
   - 更新 session 显示

4. **templates/case/ticket_detail.html**
   - 更新 session 显示

5. **templates/kb/user_management.html**
   - 删除表单中的 `real_name` 输入字段
   - 更新用户数据显示，移除 `real_name` 引用
   - 更新 JavaScript，删除 `real_name` 相关代码
   - 更新按钮 data 属性

## 应用步骤

### 1. 备份数据库（强烈推荐）

```bash
# 备份 YHKB 数据库
mysqldump -u root -p YHKB > backup_YHKB_v2.4_$(date +%Y%m%d_%H%M%S).sql

# 或使用图形工具（如 Navicat、DBeaver）
```

### 2. 停止应用服务

```bash
# 停止 Flask 应用
# Windows: Ctrl+C 或关闭命令窗口
# Linux: systemctl stop your-service-name
```

### 3. 应用补丁

#### 方式一：使用 MySQL 命令行

```bash
# 进入 MySQL
mysql -u root -p

# 选择数据库
USE YHKB;

# 执行补丁脚本
SOURCE database/patches/v2.4_to_v2.5/001_remove_password_md5_and_real_name.sql;

# 验证修改
DESCRIBE users;

# 退出 MySQL
EXIT;
```

#### 方式二：使用单个 SQL 文件

```bash
# 方式2A：Windows 命令行
mysql -u root -p YHKB < database/patches/v2.4_to_v2.5/001_remove_password_md5_and_real_name.sql

# 方式2B：Linux/Mac
mysql -u root -p YHKB < database/patches/v2.4_to_v2.5/001_remove_password_md5_and_real_name.sql
```

#### 方式三：使用数据库管理工具

1. 打开 Navicat、DBeaver、phpMyAdmin 等工具
2. 连接到 YHKB 数据库
3. 打开并执行 SQL 文件：
   `database/patches/v2.4_to_v2.5/001_remove_password_md5_and_real_name.sql`
4. 验证表结构是否正确

### 4. 验证修改

```sql
-- 检查表结构
DESCRIBE users;

-- 检查字段是否已删除
SHOW COLUMNS FROM users WHERE Field IN ('password_md5', 'real_name');
-- 应该返回 Empty set

-- 检查索引
SHOW INDEX FROM users;
```

### 5. 重启应用

```bash
# 重启 Flask 应用
python app.py

# 或使用启动脚本
./start.sh       # Linux/Mac
start.bat       # Windows
```

### 6. 测试功能

登录后测试以下功能：

- [ ] 用户登录
- [ ] 创建新用户
- [ ] 编辑用户信息
- [ ] 修改用户密码
- [ ] 提交工单
- [ ] 查看工单列表
- [ ] 查看工单详情
- [ ] 用户管理页面
- [ ] 知识库登录

### 7. 检查日志

查看应用日志，确保没有错误：

```bash
# 查看应用日志
tail -f logs/app.log

# 或使用 IDE 查看日志文件
```

## 回滚方案

如果升级后出现问题，可以按以下步骤回滚：

### 回滚 SQL 脚本

```sql
-- =====================================================
-- 回滚 v2.5 -> v2.4
-- 恢复已删除的字段
-- =====================================================

USE `YHKB`;

-- 恢复 real_name 字段
ALTER TABLE `users` ADD COLUMN `real_name` VARCHAR(100) COMMENT '真实姓名' AFTER `display_name`;

-- 恢复 password_md5 字段
ALTER TABLE `users` ADD COLUMN `password_md5` VARCHAR(64) DEFAULT NULL COMMENT '密码MD5值（已废弃）' AFTER `password_hash`;

-- 验证恢复结果
DESCRIBE `users`;

SELECT '回滚完成：real_name 和 password_md5 字段已恢复' AS message;
```

### 回滚代码

如需回滚代码更改：

```bash
# 使用 git 回滚
git checkout v2.4

# 或恢复备份文件
cp .backup/*.py ./
```

## 注意事项

### ⚠️ 重要提醒

1. **数据备份**
   - 升级前务必备份数据库
   - 保留备份至少 30 天
   - 测试备份文件的可恢复性

2. **停机时间**
   - 升级过程需要短暂停止服务
   - 建议选择低峰期进行升级
   - 预计停机时间：< 5 分钟

3. **兼容性**
   - 此补丁只影响 v2.4 版本
   - 升级后无法回滚到 v2.4 的数据库结构
   - 代码已完全适配新结构

4. **性能影响**
   - 删除字段后表结构更简洁
   - 查询性能可能略有提升
   - 存储空间减少

### 测试检查清单

升级完成后，请逐一测试以下项目：

#### 用户认证
- [ ] 用户名密码登录正常
- [ ] 邮箱登录正常
- [ ] 密码错误提示正确
- [ ] 账户锁定功能正常
- [ ] Session 保持正常

#### 用户管理
- [ ] 创建用户成功
- [ ] 编辑用户成功
- [ ] 删除用户成功
- [ ] 修改密码成功
- [ ] 用户列表显示正确
- [ ] 显示名称显示正确

#### 工单系统
- [ ] 提交工单成功
- [ ] 工单列表显示正常
- [ ] 工单详情显示正常
- [ ] 客户公司选择正常
- [ ] 联系人填充正常

#### 知识库系统
- [ ] 用户管理页面正常
- [ ] 登录日志显示正常
- [ ] 权限控制正常

## 问题排查

### 常见问题

#### Q1: 升级后用户无法登录

**可能原因**：
- Session 中还包含旧的 `real_name` 字段
- 缓存未清理

**解决方法**：
```bash
# 1. 清理浏览器缓存和 Cookie
# 2. 重新登录
# 3. 如果仍有问题，清除 Session 表中的相关数据
```

#### Q2: 部分页面显示异常

**可能原因**：
- 模板缓存未更新
- 旧代码仍在运行

**解决方法**：
```bash
# 1. 重启应用
# 2. 清理 Python 缓存（如有）
# 3. 检查模板文件是否已更新
```

#### Q3: SQL 执行失败

**可能原因**：
- 数据库连接问题
- 权限不足
- 字段已被删除

**解决方法**：
```sql
-- 检查字段是否存在
SHOW COLUMNS FROM users WHERE Field = 'real_name';
SHOW COLUMNS FROM users WHERE Field = 'password_md5';

-- 如果字段不存在，说明已删除，无需再执行
-- 使用 IF EXISTS 子句避免重复删除
```

#### Q4: 编码错误

**可能原因**：
- SQL 文件编码问题
- 数据库字符集不匹配

**解决方法**：
```bash
# 确保使用 UTF-8 编码
# MySQL 命令行添加编码参数
mysql -u root -p --default-character-set=utf8mb4 YHKB < patch.sql
```

## 技术支持

### 获取帮助

如遇到问题：

1. **查看详细文档**：`docs/REMOVE_LEGACY_FIELDS_SUMMARY.md`
2. **检查应用日志**：`logs/app.log`
3. **检查错误日志**：`logs/error.log`
4. **联系技术支持**：tech@yunhukeji.com

### 相关资源

- 官方文档：`docs/README.md`
- 更新日志：`docs/CHANGELOG.md`
- API 文档：访问 `http://localhost:5000/api/docs`

## 版本历史

- v2.5 (当前) - 删除 password_md5 和 real_name 字段
- v2.4 - 添加公司名称字段
- v2.3 - 统一用户认证
- v2.2 - 集成邮件服务
- v2.1 - 初始版本

---

**升级完成后，请更新版本号到 v2.5**
