# v2.4 -> v2.5 数据库补丁索引

## 📋 快速导航

### 遇到问题？从这里开始

| 问题 | 解决方案 | 文档 |
|------|----------|------|
| **看到 display_name 相关错误** | 快速修复指南 | → [QUICKSTART.md](QUICKSTART.md) |
| **需要完整升级流程** | 详细升级文档 | → [README.md](README.md) |
| **想了解目录结构** | 目录结构说明 | → [STRUCTURE.md](STRUCTURE.md) |
| **不知道选择哪个补丁** | 补丁选择指南 | → 查看下方补丁对比 |

---

## 🔧 补丁选择指南

### 必需补丁（必须执行）

| 编号 | 文件 | 作用 | 何时使用 |
|:----:|------|------|----------|
| 001 | [001_remove_password_md5_and_real_name.sql](001_remove_password_md5_and_real_name.sql) | 删除废弃字段 | 所有 v2.4 数据库 |
| 002 | [002_add_display_name_if_missing.sql](002_add_display_name_if_missing.sql) | 添加 display_name 字段 | 遇到 display_name 错误 |

### 可选补丁（根据需要执行）

| 编号 | 文件 | 作用 | 何时使用 |
|:----:|------|------|----------|
| 003 | [003_add_display_name_to_login_logs.sql](003_add_display_name_to_login_logs.sql) | 登录日志增强 | 希望登录日志显示名称 |

---

## 🚀 快速开始

### 推荐方式：一键应用所有补丁

**Windows 用户：**
```cmd
database\patches\v2.4_to_v2.5\apply_all_patches_v2.4_to_v2.5.bat
```

**Linux/Mac 用户：**
```bash
chmod +x database/patches/v2.4_to_v2.5/apply_all_patches_v2.4_to_v2.5.sh
./database/patches/v2.4_to_v2.5/apply_all_patches_v2.4_to_v2.5.sh
```

---

## 📚 文档结构

```
v2.4_to_v2.5/
│
├── INDEX.md           # 本文件：快速索引和导航
├── README.md          # 详细文档：完整升级流程、回滚方案
├── QUICKSTART.md      # 快速指南：紧急问题排查和修复
├── STRUCTURE.md       # 结构说明：目录结构和文件说明
│
├── 001_*.sql          # 补丁1：删除废弃字段
├── 002_*.sql          # 补丁2：修复 display_name 字段
├── 003_*.sql          # 补丁3：登录日志增强（可选）
│
├── apply_all_patches_v2.4_to_v2.5.bat   # Windows 一键应用脚本
└── apply_all_patches_v2.4_to_v2.5.sh   # Linux/Mac 一键应用脚本
```

---

## 📖 使用场景

### 场景1：遇到数据库错误

```
ERROR: Unknown column 'display_name' in 'INSERT INTO'
```

**解决步骤：**
1. 阅读 [QUICKSTART.md](QUICKSTART.md)
2. 应用补丁 002（或一键应用所有补丁）
3. 重启应用

### 场景2：全新升级

**解决步骤：**
1. 阅读 [README.md](README.md)
2. 备份数据库
3. 一键应用所有补丁
4. 验证升级结果

### 场景3：只应用特定补丁

**解决步骤：**
1. 阅读 [STRUCTURE.md](STRUCTURE.md)
2. 选择需要的补丁文件
3. 手动执行补丁

---

## 🎯 常见问题速查

| 问题 | 查看文档 |
|------|----------|
| 补丁应用失败 | [QUICKSTART.md - 常见问题](QUICKSTART.md#常见问题) |
| 如何回滚 | [README.md - 回滚方案](README.md#回滚方案) |
| 补丁执行顺序 | [STRUCTURE.md - 使用方式](STRUCTURE.md#使用方式) |
| 如何验证升级 | [STRUCTURE.md - 验证步骤](STRUCTURE.md#验证步骤) |

---

## 📞 技术支持

如需更多帮助：

- **详细文档**：[README.md](README.md)
- **快速修复**：[QUICKSTART.md](QUICKSTART.md)
- **结构说明**：[STRUCTURE.md](STRUCTURE.md)
- **应用日志**：`../../logs/app.log`
- **错误日志**：`../../logs/error.log`

---

## 📝 版本信息

- **补丁版本**：v2.5
- **发布日期**：2026-02-26
- **兼容版本**：v2.4

---

**开始使用**：根据您的需求，选择上方的快速导航链接。

**推荐**：首次使用请先阅读 [STRUCTURE.md](STRUCTURE.md) 了解整体结构。
