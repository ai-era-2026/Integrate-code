# v2.4 -> v2.5 数据库补丁目录结构

## 目录说明

```
v2.4_to_v2.5/
├── README.md                                    # 详细文档（升级指南、回滚方案等）
├── QUICKSTART.md                                # 快速修复指南（紧急问题排查）
├── STRUCTURE.md                                 # 本文件：目录结构说明
│
├── 001_remove_password_md5_and_real_name.sql   # 补丁1：删除废弃字段
├── 002_add_display_name_if_missing.sql         # 补丁2：修复 display_name 字段缺失问题
├── 003_add_display_name_to_login_logs.sql      # 补丁3：为登录日志表添加 display_name（可选）
│
├── apply_all_patches_v2.4_to_v2.5.bat         # Windows 一键应用所有补丁
└── apply_all_patches_v2.4_to_v2.5.sh           # Linux/Mac 一键应用所有补丁
```

## 文件说明

### 文档文件

| 文件名 | 用途 | 何时阅读 |
|--------|------|----------|
| **STRUCTURE.md** | 目录结构说明（本文档） | 了解目录结构 |
| **QUICKSTART.md** | 快速修复指南 | 遇到错误时快速排查 |
| **README.md** | 详细升级文档 | 完整升级流程、回滚方案 |

### 补丁文件

| 文件名 | 编号 | 功能 | 是否必需 | 执行顺序 |
|--------|------|------|----------|----------|
| **001_remove_password_md5_and_real_name.sql** | 001 | 删除已废弃的 password_md5 和 real_name 字段 | 必需 | 1 |
| **002_add_display_name_if_missing.sql** | 002 | 添加 display_name 字段到 users 表（如果不存在） | 必需 | 2 |
| **003_add_display_name_to_login_logs.sql** | 003 | 为登录日志表添加 display_name 字段 | 可选 | 3 |

### 应用脚本

| 文件名 | 平台 | 功能 |
|--------|------|------|
| **apply_all_patches_v2.4_to_v2.5.bat** | Windows | 一键应用所有补丁 |
| **apply_all_patches_v2.4_to_v2.5.sh** | Linux/Mac | 一键应用所有补丁 |

---

## 快速导航

### 我遇到了错误，如何快速修复？

→ 阅读 **[QUICKSTART.md](QUICKSTART.md)**

### 我需要完整升级流程

→ 阅读 **[README.md](README.md)**

### 我需要了解每个补丁的作用

→ 查看下文的补丁详细说明

---

## 补丁详细说明

### 补丁 001：删除废弃字段

**文件**：`001_remove_password_md5_and_real_name.sql`

**功能**：
- 删除 `users` 表中的 `password_md5` 字段（已废弃）
- 删除 `users` 表中的 `real_name` 字段（统一使用 display_name）

**影响**：
- 简化表结构
- 统一使用 `display_name` 显示用户名

**适用场景**：所有 v2.4 版本数据库

---

### 补丁 002：修复 display_name 字段缺失

**文件**：`002_add_display_name_if_missing.sql`

**功能**：
- 检查 `users` 表中是否存在 `display_name` 字段
- 如果不存在，自动添加该字段

**影响**：
- 修复 "Unknown column 'display_name' in 'INSERT INTO'" 错误
- 确保数据库结构符合代码要求

**适用场景**：遇到 display_name 相关错误时

**特点**：
- 可重复执行（已存在字段时会跳过）
- 不影响现有数据

---

### 补丁 003：登录日志表增强（可选）

**文件**：`003_add_display_name_to_login_logs.sql`

**功能**：
- 为 `mgmt_login_logs` 表添加 `display_name` 字段
- 用于记录登录时的显示名称，便于历史查询

**影响**：
- 不影响现有功能（可选补丁）
- 增强登录日志的可读性

**适用场景**：希望登录日志中记录显示名称

**注意**：代码已适配，即使不应用此补丁也能正常运行

---

## 使用方式

### 方式1：一键应用（推荐）

**Windows:**
```cmd
database\patches\v2.4_to_v2.5\apply_all_patches_v2.4_to_v2.5.bat
```

**Linux/Mac:**
```bash
chmod +x database/patches/v2.4_to_v2.5/apply_all_patches_v2.4_to_v2.5.sh
./database/patches/v2.4_to_v2.5/apply_all_patches_v2.4_to_v2.5.sh
```

### 方式2：手动应用单个补丁

**Windows:**
```cmd
mysql -u root -p YHKB < database\patches\v2.4_to_v2.5\001_remove_password_md5_and_real_name.sql
mysql -u root -p YHKB < database\patches\v2.4_to_v2.5\002_add_display_name_if_missing.sql
mysql -u root -p YHKB < database\patches\v2.4_to_v2.5\003_add_display_name_to_login_logs.sql
```

**Linux/Mac:**
```bash
mysql -u root -p YHKB < database/patches/v2.4_to_v2.5/001_remove_password_md5_and_real_name.sql
mysql -u root -p YHKB < database/patches/v2.4_to_v2.5/002_add_display_name_if_missing.sql
mysql -u root -p YHKB < database/patches/v2.4_to_v2.5/003_add_display_name_to_login_logs.sql
```

### 方式3：使用 MySQL 命令行

```bash
mysql -u root -p

# 在 MySQL 命令行中
USE YHKB;
SOURCE database/patches/v2.4_to_v2.5/001_remove_password_md5_and_real_name.sql;
SOURCE database/patches/v2.4_to_v2.5/002_add_display_name_if_missing.sql;
SOURCE database/patches/v2.4_to_v2.5/003_add_display_name_to_login_logs.sql;
```

---

## 验证步骤

### 1. 检查表结构

```sql
USE YHKB;

-- 查看 users 表结构
DESCRIBE users;

-- 应该包含 display_name 字段，不包含 password_md5 和 real_name 字段

-- 查看 mgmt_login_logs 表结构（如果应用了补丁3）
DESCRIBE mgmt_login_logs;
```

### 2. 测试系统功能

1. 重启 Flask 应用
2. 用户登录测试
3. 提交在线留言
4. 查看应用日志，确认无错误

---

## 注意事项

### ⚠️ 重要

1. **备份数据库**：应用补丁前务必备份数据库
2. **停止服务**：应用补丁时建议停止应用服务
3. **执行顺序**：补丁按编号顺序执行（001 -> 002 -> 003）
4. **补丁002必需**：必须执行补丁002，否则会出现 display_name 错误
5. **补丁003可选**：补丁003是可选的，不影响系统运行

### 💡 提示

- 补丁002可重复执行，不会重复添加字段
- 如果补丁提示字段已存在，说明已成功添加，可忽略
- 应用补丁后需要重启应用才能生效

---

## 相关链接

- 项目根目录：`../../../`
- 数据库初始化脚本：`../../../database/init_database.sql`
- 应用日志：`../../../logs/app.log`
- 错误日志：`../../../logs/error.log`

---

## 版本信息

- **补丁版本**：v2.5
- **发布日期**：2026-02-26
- **兼容版本**：v2.4
- **维护者**：云户科技技术团队

---

**文档最后更新**：2026-02-26
