# 快速修复指南 - v2.5 数据库补丁

## 问题说明

如果您遇到以下错误：
```
ERROR in database_context: 数据库操作异常 [kb]: (1054, "Unknown column 'display_name' in 'INSERT INTO'")
ERROR in user_management_bp: 记录登录日志失败: (1054, "Unknown column 'display_name' in 'INSERT INTO'")
```

这表示数据库中缺少必要的字段，需要应用数据库补丁。

---

## 快速修复步骤

### Windows 用户

```cmd
# 方法1：一键应用所有补丁（推荐）
database\patches\v2.4_to_v2.5\apply_all_patches_v2.4_to_v2.5.bat

# 方法2：手动应用单个补丁
mysql -u root -p YHKB < database\patches\v2.4_to_v2.5\001_remove_password_md5_and_real_name.sql
mysql -u root -p YHKB < database\patches\v2.4_to_v2.5\002_add_display_name_if_missing.sql
```

### Linux/Mac 用户

```bash
# 方法1：一键应用所有补丁（推荐）
chmod +x database/patches/v2.4_to_v2.5/apply_all_patches_v2.4_to_v2.5.sh
./database/patches/v2.4_to_v2.5/apply_all_patches_v2.4_to_v2.5.sh

# 方法2：手动应用单个补丁
mysql -u root -p YHKB < database/patches/v2.4_to_v2.5/001_remove_password_md5_and_real_name.sql
mysql -u root -p YHKB < database/patches/v2.4_to_v2.5/002_add_display_name_if_missing.sql
```

---

## 补丁说明

### 补丁 001：删除已废弃字段
- 删除 `password_md5` 字段（已废弃）
- 删除 `real_name` 字段（统一使用 display_name）

### 补丁 002：添加 display_name 字段
- 检查 `users` 表中是否存在 `display_name` 字段
- 如果不存在，自动添加该字段
- **此补丁是修复错误的关键**

### 补丁 003：登录日志表添加 display_name（可选）
- 为 `mgmt_login_logs` 表添加 `display_name` 字段
- 这是可选补丁，不影响现有功能

---

## 验证修复

### 方法1：查看表结构

```sql
USE YHKB;

-- 查看 users 表结构
DESCRIBE users;

-- 应该看到 display_name 字段
-- Field: display_name
-- Type: varchar(100)
-- Null: YES
-- Key:
-- Default: NULL
-- Extra:
```

### 方法2：测试系统功能

1. 重启 Flask 应用
2. 尝试用户登录
3. 提交一个工单
4. 查看应用日志，确认没有错误

---

## 常见问题

### Q1: 补丁应用失败怎么办？

**检查数据库连接**：
```bash
# 测试 MySQL 连接
mysql -u root -p -h 127.0.0.1

# 使用 .env 文件中的配置
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=root
DB_PASSWORD=你的密码
```

### Q2: 提示字段已存在？

这是正常的，补丁会自动检查字段是否存在，不会重复添加。

### Q3: 应用补丁后仍然报错？

1. 重启 Flask 应用
2. 清理浏览器缓存
3. 重新登录测试

---

## 代码已自动修复

以下代码文件已经更新，无需手动修改：

- `routes/user_management_bp.py` - 移除了登录日志中的 display_name 字段
- `routes/home_bp.py` - 添加了姓名到用户名的转换逻辑

---

## 技术支持

如仍有问题，请查看：

- 详细文档：`README.md`
- 应用日志：`logs/app.log`
- 错误日志：`logs/error.log`
