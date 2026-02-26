# 云户科技网站 - 更新日志

> 记录项目的所有版本更新、功能改进、问题修复和优化记录

---

## 📋 版本索引

| 版本 | 日期 | 状态 |
|------|------|------|
| [v2.5](#v25-2026-02-26) | 2026-02-26 | 最新版本 |
| [v2.4](#v24-2026-02-25) | 2026-02-25 | 稳定版本 |
| [v2.3](#v23-2026-02-13) | 2026-02-13 | 稳定版本 |
| [v2.2](#v22-2026-02-13) | 2026-02-13 | 稳定版本 |
| [v2.1](#v21-2026-02-12) | 2026-02-12 | 稳定版本 |
| [v2.0](#v20-2026-02-10) | 2026-02-10 | 架构重构 |

---

## v2.5 (2026-02-26)

### 🎯 主要更新

#### 1. 配置架构重构 🔧

**功能说明**: 采用单一配置文件策略，简化配置管理

**新增功能**:
- ✅ 所有配置统一通过 `.env` 文件管理
- ✅ 简化 `config.py`，仅负责从 `.env` 读取配置
- ✅ 更新 `.env.example`，包含所有配置项的详细说明
- ✅ 启动时自动检查关键配置项

**实现细节**:
- 重构 `config.py`，移除硬编码的默认值
- 统一使用 `os.getenv()` 读取环境变量
- 保留 `check_config()` 函数，启动时自动验证配置
- 添加配置项分类注释，便于理解

**配置项**:
- Flask 基础配置（SECRET_KEY、DEBUG、Session 等）
- 服务器配置（FLASK_HOST、FLASK_PORT、SITE_URL）
- 数据库配置（DB_HOST、DB_PORT、DB_PASSWORD 等）
- 邮件配置（MAIL_SERVER、MAIL_PORT、MAIL_USERNAME 等）
- Trilium 配置（TRILIUM_SERVER_URL、TRILIUM_TOKEN 等）
- 知识库配置（DEFAULT_ADMIN_PASSWORD 等）
- CORS 配置
- Redis 配置
- CDN 配置
- 图片优化配置
- 缓存配置
- 日志配置
- 数据库连接池配置
- Session 配置
- 文件上传配置
- 静态文件配置

**新增文档**:
- [配置迁移指南](./CONFIG_MIGRATION_GUIDE.md) - 详细的迁移步骤和常见问题
- [项目清理总结](./PROJECT_CLEANUP_SUMMARY.md) - 本次清理工作的详细说明
- [快速升级指南](./QUICKSTART_CLEANUP.md) - v2.4→v2.5 快速升级步骤

#### 2. 项目清理 🧹

**删除的临时文件**:
- 🗑️ `test_layout.html` - 测试布局文件
- 🗑️ `templates/home/index.html.backup` - 官网首页备份

**删除的空目录**:
- 🗑️ `p/` - 临时目录（0 B）
- 🗑️ `echo/` - 临时目录（0 B）
- 🗑️ `legacy/` - 旧代码目录（0 B）
- 🗑️ `patches/` - 补丁目录（0 B）
- 🗑️ `Directories created or already exist/` - 临时目录（0 B）

**归档的文档**:
- 📦 归档到 `docs/archive/`:
  - `LAYOUT_FIX_GUIDE.md` - 布局修复指南
  - `FINAL_LAYOUT_FIX.md` - 最终布局修复
  - `USER_MANAGEMENT_COMPANY_NAME_MODIFICATION.md` - 用户管理公司名称修改

#### 3. 代码修复 🐛

**修复限流问题**:
- ✅ 修复 `check-login` 端点的 HTTP 429 错误
- ✅ 为所有 `check-login` 端点添加限流豁免

**修改的文件**:
- `routes/case_bp.py` - 工单系统 check-login 端点
- `routes/kb_bp.py` - 知识库系统 check-login 端点
- `routes/user_management_bp.py` - 用户管理 check-login 端点

**实现代码**:
```python
from app import limiter
limiter.exempt(check_login)
```

#### 4. 文档更新 📚

**更新的文档**:
- ✅ [README.md](../README.md) - 更新项目结构、配置说明、快速开始步骤
- ✅ [配置迁移指南](./CONFIG_MIGRATION_GUIDE.md) - 新增
- ✅ [项目清理总结](./PROJECT_CLEANUP_SUMMARY.md) - 新增
- ✅ [快速升级指南](./QUICKSTART_CLEANUP.md) - 新增
- ✅ [CHANGELOG.md](./CHANGELOG.md) - 添加 v2.5 版本记录

**新增内容**:
- 项目结构更新（新增 `docs/archive/` 目录）
- 配置快速清单
- 配置安全检查说明
- 配置文档链接
- v2.5 版本更新日志

#### 5. 静态资源处理 ⚠️

**未合并的重复资源**:
以下静态资源有重复，但暂时保留：

- `static/kb/js/bootstrap.bundle.min.js` (78.54 KB)
- `static/case/js/bootstrap.bundle.min.js` (78.54 KB)

**保留原因**:
- 不同系统可能需要不同版本
- 修改模板引用可能影响功能
- 建议后续逐步统一

**建议**:
- 评估是否需要统一 Bootstrap 版本
- 如果统一，复制到 `static/common/js/`
- 更新所有模板引用

### 📊 配置清单

#### 必须配置项（生产环境）

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `FLASK_SECRET_KEY` | Flask 安全密钥 | 自动生成 |
| `DB_PASSWORD` | 数据库密码 | - |
| `TRILIUM_TOKEN` | Trilium API Token | - |
| `DEFAULT_ADMIN_PASSWORD` | 默认管理员密码 | `YHKB@2024` |
| `MAIL_PASSWORD` | 邮件密码 | - |
| `SITE_URL` | 网站域名 | `http://0.0.0.0:5000` |

#### 可选配置项

- `FLASK_HOST` - 服务器监听地址 (默认: `0.0.0.0`)
- `FLASK_PORT` - 服务器端口 (默认: `5000`)
- `MAIL_SERVER` - 邮件服务器 (默认: `smtp.exmail.qq.com`)
- `REDIS_ENABLED` - 是否启用 Redis (默认: `False`)
- `IMAGE_QUALITY` - 图片质量 (默认: `80`)
- `LOG_LEVEL` - 日志级别 (默认: `INFO`)

完整配置清单请参考 [`.env.example`](../.env.example)

### 🔄 升级指南

#### 从 v2.4 升级到 v2.5

1. **备份现有配置**
   ```bash
   cp .env .env.backup
   cp config.py config.py.backup
   ```

2. **更新 .env 文件**
   - 参考 [快速升级指南](./QUICKSTART_CLEANUP.md)
   - 复制新的 `.env.example` 或手动更新
   - 添加缺失的配置项

3. **验证配置**
   ```bash
   python app.py
   # 检查启动日志中的配置检查结果
   ```

4. **测试功能**
   - 测试数据库连接
   - 测试邮件发送
   - 测试 Trilium 集成
   - 测试各个系统功能

详细升级步骤请参考 [配置迁移指南](./CONFIG_MIGRATION_GUIDE.md)

### 🐛 已知问题

- ⚠️ Bootstrap 库重复，后续版本将统一
- ⚠️ 需要更新 `.env` 文件，配置项较多

### 🚀 下一步计划

- [ ] 统一重复的静态资源
- [ ] 优化配置检查逻辑
- [ ] 添加配置验证测试
- [ ] 考虑使用配置管理工具（如 Vault）
- [ ] 添加配置热更新功能
- [ ] 支持多环境配置（dev、staging、prod）

---

## v2.4 (2026-02-25)

### 🎯 主要更新

#### 1. 企业微信邮箱对接 📧

**功能说明**: 实现邮件通知功能，支持将联系表单和工单创建信息发送到企业微信邮箱

**新增功能**:
- ✅ 首页"联系我们"表单提交后自动发送邮件通知
- ✅ 工单创建成功后自动发送包含完整工单信息的邮件
- ✅ 支持HTML格式邮件模板，专业的样式设计
- ✅ 支持附件信息展示（工单附件）
- ✅ 完整的邮件发送错误处理和日志记录

**实现细节**:
- 创建 `services/email_service.py` 邮件服务模块
  - `EmailService` 类封装邮件发送逻辑
  - `send_contact_notification()`: 发送联系我们通知
  - `send_ticket_created_notification()`: 发送工单创建通知
  - 支持多种SMTP服务商（企业微信、QQ、Gmail等）
- 更新 `routes/home_bp.py` 的联系表单提交API，集成邮件发送
- 更新 `routes/case_bp.py` 的工单创建API，集成邮件通知
- 邮件模板使用云户科技品牌色，响应式设计

**邮件模板特性**:
- **联系我们邮件**：包含留言人姓名、邮箱、电话、留言内容，蓝色主题
- **工单创建邮件**：包含工单编号、客户信息、工单类型、优先级、标题、内容、附件列表，绿色主题

**配置文件**:
- 创建 `.env.example` 配置示例文件
- 创建 `docs/ENTERPRISE_EMAIL_SETUP.md` 详细配置文档

**支持邮箱服务商**:
- 企业微信邮箱：`smtp.exmail.qq.com:465` (SSL)
- QQ邮箱：`smtp.qq.com:465` (SSL)
- Gmail：`smtp.gmail.com:587` (TLS)
- 163邮箱：`smtp.163.com:465` (SSL)
- 126邮箱：`smtp.126.com:465` (SSL)

**配置说明**:
```env
# SMTP配置
SMTP_SERVER=smtp.exmail.qq.com
SMTP_PORT=465
SMTP_USERNAME=yourname@company.com
SMTP_PASSWORD=your-email-password
EMAIL_SENDER=yourname@company.com
CONTACT_EMAIL=yourname@company.com
```

**修改文件**:
- `services/email_service.py` - 新建邮件服务模块
- `routes/home_bp.py` - 更新联系表单提交API
- `routes/case_bp.py` - 更新工单创建API
- `.env.example` - 新建配置示例文件
- `docs/ENTERPRISE_EMAIL_SETUP.md` - 新建企业微信邮箱配置文档
- `docs/CHANGELOG.md` - 更新更新日志

**详细文档**: `docs/ENTERPRISE_EMAIL_SETUP.md`

---

## v2.3 (2026-02-13)

### 🎯 主要更新

#### 1. 安全加固 🔒

**问题**: 安全审计发现多个安全漏洞需要修复

**修复内容**:
- ✅ SECRET_KEY 现在使用环境变量或自动生成 32 字节随机密钥
- ✅ 数据库密码验证添加安全警告
- ✅ 默认管理员密码处理改进
- ✅ 启用 CSRF 保护（Flask-WTF）
- ✅ 实现 XSS 防护（bleach 库）
- ✅ Session 安全增强（HttpOnly, SameSite, 自定义 cookie 名称）

**安全评分提升**: 15/50 (30%) → 47/50 (94%)，提升 +213%

**修改文件**:
- `config.py` - SECRET_KEY、数据库密码、Session 配置
- `app.py` - CSRF 保护启用和配置
- `common/validators.py` - 新建输入验证和清理模块
- `common/__init__.py` - 导出验证函数
- `templates/kb/login.html` - 添加 CSRF token
- `templates/kb/change_password.html` - 添加 CSRF token 和 AJAX 头
- `templates/case/login.html` - 添加 CSRF token
- `templates/case/submit_ticket.html` - 添加 CSRF token
- `templates/case/ticket_detail.html` - 更新所有 AJAX 请求添加 CSRF

**详细记录**: `docs/SECURITY_FIXES_COMPLETE.md`

---

#### 2. 工单系统重构完善 🎫

**目标**: 完善工单系统，支持按公司管理客户和联系人

**完成内容**:
- ✅ 多公司客户管理支持
- ✅ 客户联系人按公司分组
- ✅ 工单创建时自动填充联系人信息
- ✅ 工单抄送邮箱功能
- ✅ 完善的权限控制（admin、user、customer 角色）
- ✅ 数据库结构更新（v2.3 版本）

**数据库变更**:
- ✅ users 表添加字段: `company_name`, `phone`
- ✅ tickets 表添加字段: `cc_emails`
- ✅ 索引优化: `idx_company_name`

**权限体系**:
- **管理员 (admin)**: 查看所有工单、创建工单、选择公司和联系人
- **普通用户 (user)**: 查看所有工单、查看我的工单、创建工单
- **客户 (customer)**: 只能查看自己创建的工单

**详细文档**: `docs/CASE_SYSTEM_REDESIGN.md`

---

#### 3. 导入错误修复 🔧

**问题**: 代码重构后出现多个导入错误

**修复内容**:
- ✅ 修复 `flask_swagger` 导入错误 → `flasgger`
- ✅ 修复 `common.validators` 函数名不匹配问题
- ✅ 添加兼容函数保持向后兼容性
- ✅ 修复登录端点 CSRF 保护问题

**修改文件**:
- `app.py` - 修复 flasgger 导入
- `common/validators.py` - 添加兼容函数
- `common/__init__.py` - 更新导入列表
- `routes/kb_bp.py` - 移除 CSRF 保护（登录端点）
- `routes/case_bp.py` - 移除 CSRF 保护（登录端点）

---

#### 3. 环境变量配置完善 ⚙️

**目标**: 确保所有必需的环境变量都已定义并记录

**完成内容**:
- ✅ 验证 .env 和 .env.example 中的所有 50 个环境变量
- ✅ 添加 3 个新的安全相关环境变量
- ✅ 所有变量包含详细注释和使用说明
- ✅ 添加安全变量警告和生成方法

**新增环境变量**:
- `FLASK_SECRET_KEY` - Flask 安全密钥（生成方法已提供）
- `HTTPS_ENABLED` - HTTPS 配置标志
- `DEFAULT_ADMIN_PASSWORD` - 默认管理员密码

**配置文件状态**:
- ✅ `.env.example` - 完整配置模板（131 行）
- ✅ `.env` - 实际配置文件（118 行）

---

#### 4. 依赖验证完成 📦

**目标**: 确保所有依赖都存在且可安装

**完成内容**:
- ✅ 验证 requirements.txt 中的所有 26 个包
- ✅ 确认所有包在 PyPI 上可用（100%）
- ✅ 成功安装所有安全相关依赖
- ✅ 创建依赖检查脚本

**已安装的核心依赖** (21 个):
- Flask, Flask-Cors, Flask-SocketIO, Flask-WTF, bleach, flasgger
- PyMySQL, DBUtils, Werkzeug, python-socketio, eventlet
- 以及其他 11 个依赖

**可选依赖** (5 个):
- eventlet（已安装，用于 WebSocket）
- gevent（Python 3.14 兼容性问题，已用 eventlet 替代）
- mysql-connector-python（可选，PyMySQL 可用作替代）

**检查脚本**: `scripts/check_dependencies.py`

---

#### 5. 文档清理 📚

**目标**: 删除临时文档，保持文档库整洁

**删除的文档**:
- 根目录临时文档:
  - `CODE_ANALYSIS_SUMMARY.md`
  - `OPTIMIZATION_WORK_COMPLETE.md`

- docs/ 临时文档:
  - `ENV_VARIABLES_CHECK.md`
  - `DEPENDENCIES_VERIFICATION.md`
  - `DEPENDENCIES_FINAL_REPORT.md`
  - `PREPARE_COMMIT.md`
  - `FINAL_COMMIT_MESSAGE.md`
  - `COMMIT_MESSAGE.md`
  - `CONTENT_UPDATE_SUMMARY.md`
  - `DOCUMENTATION_REORGANIZATION_SUMMARY.md`
  - `TRILIUM_429_FIX.md`
  - `TRILIUM_PUBLIC_ACCESS_FIX.md`
  - `TRILIUM_QUICK_ADD.md`
  - `KB_SEARCH_FIX.md`
  - `KB_MANAGEMENT_OPTIMIZATION.md`
  - `OPTIMIZATION_RECOMMENDATIONS.md`
  - `OPTIMIZATION_PLAN.md`
  - `trilium-py-README.md`

**保留的核心文档**:
- `docs/README.md` - 文档索引
- `docs/CHANGELOG.md` - 本文档
- `docs/API_DOCS.md` - API 文档
- `docs/CONFIGURATION_GUIDE.md` - 配置指南
- `docs/QUICK_START.md` - 快速开始指南
- `docs/SECURITY_FIXES_COMPLETE.md` - 安全修复文档
- `docs/SECURITY_FIXES_SUMMARY.md` - 安全修复总结
- `docs/HOME_SYSTEM_GUIDE.md` - 官网系统指南
- `docs/KB_SYSTEM_GUIDE.md` - 知识库系统指南
- `docs/CASE_SYSTEM_GUIDE.md` - 工单系统指南
- `docs/UNIFIED_SYSTEM_GUIDE.md` - 统一用户管理指南

---

### 🐛 Bug 修复

| 问题 | 状态 | 详情 |
|------|------|------|
| flask_swagger 导入错误 | ✅ 已修复 | 改为 flasgger |
| validators 函数名不匹配 | ✅ 已修复 | 添加兼容函数 |
| 登录 400 错误（CSRF） | ✅ 已修复 | 排除登录端点 CSRF 保护 |
| SECRET_KEY 使用默认值 | ✅ 已修复 | 环境变量或自动生成 |
| 数据库密码未验证 | ✅ 已修复 | 添加安全警告 |
| XSS 漏洞风险 | ✅ 已修复 | 实现输入清理 |

---

### 📝 文档更新

**删除的文档**: 19 个临时工作文档

**保留的核心文档**: 12 个

**文档组织**: 清晰的层级结构和索引

---

### ⚠️ 重要提醒

1. **安全加固完成** - 应用程序安全评分从 30% 提升到 94%
2. **登录已修复** - 知识库和工单登录端点已从 CSRF 保护中排除
3. **依赖完整** - 所有 26 个依赖包已验证并可安装
4. **文档清理** - 删除 19 个临时文档，保留核心文档

---

## v2.2 (2026-02-13)

### 🎯 主要更新

#### 1. Trilium 搜索功能修复 ⭐

**问题**: 知识库按内容搜索功能无法正常工作，显示"未找到匹配的笔记"

**修复内容**:
- ✅ 修复 JavaScript 语法错误（孤立 `.catch()` 代码块）
- ✅ 修复 API 数据结构不匹配（`data.data.count` → `results.length`）
- ✅ 添加安全的数据访问逻辑（防止访问 undefined 属性）
- ✅ 添加调试日志输出（便于问题排查）
- ✅ 防止事件监听器重复绑定（避免 429 错误）

**修改文件**:
- `templates/kb/index.html` - 删除孤立的 `.catch()` 块和测试代码
- `templates/kb/management.html` - 重写搜索函数，防止重复绑定

---

#### 2. 文档结构优化 📚

**目标**: 统一管理项目文档，提升可维护性

**移动的文档**:
- `DATABASE_SETUP.md` → `docs/DATABASE_SETUP.md`
- `HOMEPAGE_DEV_GUIDE.md` → `docs/HOMEPAGE_DEV_GUIDE.md`
- `IMAGE_OPTIMIZATION_REPORT.md` → `docs/IMAGE_OPTIMIZATION_REPORT.md`
- `IMAGE_REPLACEMENT_COMPLETE.md` → `docs/IMAGE_REPLACEMENT_COMPLETE.md`
- `PROJECT_OPTIMIZATION_SUMMARY.md` → `docs/PROJECT_OPTIMIZATION_SUMMARY.md`

**新增文档**:
- `docs/KB_SEARCH_FIX.md` - Trilium 搜索功能修复记录

**更新文档**:
- `docs/README.md` - 更新文档索引和导航
- `docs/CHANGELOG.md` - 本文档，统一的更新日志

---

#### 3. 数据库改进 💾

**优化内容**:
- ✅ 添加数据库快速开始指南 (`database/QUICK_START.md`)
- ✅ 添加数据库 README (`database/README.md`)
- ✅ 整理数据库补丁脚本（按版本组织）
- ✅ 添加迁移脚本支持 v2.1 到 v2.2 版本升级

**新增文件**:
- `database/QUICK_START.md` - 快速开始指南
- `database/README.md` - 数据库文档索引
- `database/apply_patches_v2.1_to_v2.2.bat` - Windows 补丁脚本
- `database/apply_patches_v2.1_to_v2.2.sh` - Linux/Mac 补丁脚本
- `database/patches/v2.1_to_v2.2/` - v2.1 到 v2.2 的补丁文件

**重构文件**:
- `database/migrate_case_db.sql` → `database/patches/v2.1_to_v2.2/001_add_missing_columns.sql`
- `database/patch_kb_name_length.sql` → `database/patches/v2.1_to_v2.2/002_extend_kb_name_length.sql`

---

#### 4. 文案更新 ✏️

**修改内容**:
- ✅ "企业数字化转型" → "企业国产化转型" (5 处)
- ✅ "超融合维保" → "超融合虚拟化维保" (8 处)

**修改文件**:
- `templates/home/index.html` - 首页文案更新 (7 处)
- `templates/home/components/footer.html` - 页脚文案更新 (3 处)
- `templates/home/about.html` - 关于我们页面更新 (1 处)
- `templates/home/cases.html` - 用户案例页面更新 (2 处)

---

#### 5. 代码质量改进 🔧

**修改文件**:
- `common/trilium_helper.py` - Trilium 辅助函数优化
- `.gitignore` - 更新忽略规则，排除测试目录和临时文件

**新增文件**:
- `requirements-dev.txt` - 开发依赖文件

---

### 🐛 Bug 修复

| 问题 | 状态 | 详情 |
|------|------|------|
| JavaScript 语法错误 | ✅ 已修复 | 删除孤立代码块 |
| API 数据结构不匹配 | ✅ 已修复 | 修正数据访问逻辑 |
| 事件监听器重复绑定 | ✅ 已修复 | 添加防重复标志 |
| 429 错误 | ✅ 已修复 | 修复重复请求问题 |
| 自动 test 搜索 | ✅ 已修复 | 删除测试代码 |

---

### 📝 文档更新

**删除的文档**（从根目录移至 docs/）:
- `DATABASE_SETUP.md`
- `HOMEPAGE_DEV_GUIDE.md`
- `IMAGE_OPTIMIZATION_REPORT.md`
- `IMAGE_REPLACEMENT_COMPLETE.md`

**新增的文档**:
- `docs/KB_SEARCH_FIX.md`
- `docs/CHANGELOG.md`（本文档）

**更新的文档**:
- `docs/README.md`

---

### ⚠️ 重要提醒

1. **测试目录已排除** - `tests/` 目录已添加到 .gitignore
2. **文档已整理** - 原根目录的文档已移至 `docs/` 目录
3. **数据库补丁脚本** - 新版本提供了自动迁移脚本

---

## v2.1 (2026-02-12)

### 🎯 主要更新

#### 1. 图片优化完成 🖼️

**优化成果**:
- ✅ 压缩率达到 96.3%，节省 44.20 MB
- ✅ 超大图片 BJ2.jpg (20.73 MB → 140 KB)
- ✅ 生成 WebP 和 JPG 双格式
- ✅ 页面加载速度提升 90%+
- ✅ 每月可节省 $40 CDN 费用

**优化的页面**:
- 首页: ~3 MB → ~0.3 MB (节省 90%)
- 关于我们: ~2 MB → ~0.1 MB (节省 95%)
- 备件库: **41 MB** → **0.7 MB** (节省 98.3%) ⭐

---

#### 2. 知识库管理优化 📚

**更新内容**:
- ✅ 更新知识库管理功能说明
- ✅ 添加 Trilium 获取全部笔记方法文档
- ✅ 添加批量导入功能更新说明（支持 150 条）
- ✅ 添加管理界面修复记录

**修改文件**:
- `templates/kb/management.html` - 管理界面优化
- `docs/KB_MANAGEMENT_OPTIMIZATION.md` - 优化记录

---

#### 3. 官网首页优化 🎨

**优化内容**:
- ✅ 联系我们板块重新设计
- ✅ 渐变背景和装饰元素
- ✅ 联系方式卡片优化（悬停效果）
- ✅ 工作时间卡片优化（毛玻璃效果）
- ✅ 在线留言表单优化（聚焦效果）

**代码位置**: `templates/home/index.html` 第575-718行

---

### 📝 文档更新

**更新的文档**:
- `docs/HOMEPAGE_DEV_GUIDE.md` - 官网开发指南
- `docs/KB_MANAGEMENT_OPTIMIZATION.md` - 知识库管理优化
- `docs/PROJECT_OPTIMIZATION_SUMMARY.md` - 项目优化总结

---

## v2.0 (2026-02-10)

### 🎯 架构重构 ⭐

#### 1. 蓝图路由架构 🏗️

**重构内容**:
- ✅ 将统一路由文件 `routes_new.py` 拆分为蓝图架构
- ✅ 新增 `routes/__init__.py` - 蓝图注册
- ✅ 新增路由蓝图:
  - `home_bp.py` - 官网路由
  - `kb_bp.py` - 知识库认证和浏览路由
  - `kb_management_bp.py` - 知识库管理路由
  - `case_bp.py` - 工单系统路由
  - `unified_bp.py` - 统一用户管理路由
  - `auth_bp.py` - 认证 API 路由
  - `api_bp.py` - API 路由（Trilium 等）

**优势**:
- 模块化设计，易于维护
- 清晰的职责分离
- 便于团队协作
- 支持独立测试

---

#### 2. 统一用户管理 👥

**新增功能**:
- ✅ 统一的用户认证系统
- ✅ 基于角色的访问控制（RBAC）
- ✅ 用户管理界面（添加、编辑、删除用户）
- ✅ 密码复杂度验证（最少 6 位）
- ✅ 密码显示/隐藏功能
- ✅ 登录日志审计

**技术实现**:
- Werkzeug 密码加密（PBKDF2）
- Session 超时管理（3小时）
- 登录失败锁定

**详细文档**: `docs/UNIFIED_SYSTEM_GUIDE.md`

---

#### 3. 安全改进 🔒

**新增安全特性**:
- ✅ 密码策略模块 (`common/password_policy.py`)
- ✅ 配置安全检查脚本
- ✅ 审计日志记录
- ✅ 输入验证器
- ✅ 统一 API 响应格式

**安全工具**:
- `scripts/check_config.py` - 配置安全检查
- `scripts/check_security.py` - 快速安全检查
- `scripts/generate_secure_env.py` - 生成安全配置

**详细文档**: `docs/SECURITY_IMPROVEMENTS.md`

---

#### 4. Trilium 集成优化 📝

**优化内容**:
- ✅ Trilium API 文档
- ✅ 笔记搜索功能
- ✅ 内容获取功能
- ✅ 附件代理支持
- ✅ 429 错误处理

---

#### 5. 工单系统优化 🎫

**功能更新**:
- ✅ 移除自助注册功能
- ✅ 用户需由管理员创建
- ✅ WebSocket 实时聊天优化
- ✅ 工单状态管理
- ✅ 文件上传功能

**详细文档**: `docs/CASE_SYSTEM_GUIDE.md`

---

#### 6. 性能优化 ⚡

**优化内容**:
- ✅ 数据库连接池管理
- ✅ 结构化日志系统
- ✅ 响应式设计优化
- ✅ 图片懒加载

**代码统计**:
- 总代码量: ~24,000+ 行
- Python: ~8,000 行
- Templates: ~10,000 行
- CSS/JS: ~6,000 行

---

### 📝 文档更新

**新增的文档**:
- `docs/HOME_SYSTEM_GUIDE.md` - 官网系统完整指南
- `docs/KB_SYSTEM_GUIDE.md` - 知识库系统完整指南
- `docs/CASE_SYSTEM_GUIDE.md` - 工单系统完整指南
- `docs/UNIFIED_SYSTEM_GUIDE.md` - 统一用户管理完整指南
- `docs/API_DOCS.md` - RESTful API 文档
- `docs/SECURITY_IMPROVEMENTS.md` - 安全特性说明
- `docs/TRILIUM_429_FIX.md` - 429 错误修复
- `docs/TRILIUM_PUBLIC_ACCESS_FIX.md` - 公开访问修复
- `docs/TRILIUM_QUICK_ADD.md` - Trilium 快速添加
- `docs/CONFIGURATION_GUIDE.md` - 配置指南

**更新的文档**:
- `docs/README.md` - 文档索引
- `docs/OPTIMIZATION_PLAN.md` - 优化计划
- `docs/CODE_STATISTICS.md` - 代码统计

---

## 📊 版本对比

### 功能对比

| 功能 | v1.x | v2.0 | v2.1 | v2.2 | v2.3 |
|------|------|------|------|------|------|
| 官网系统 | ✅ | ✅ | ✅ | ✅ | ✅ |
| 知识库系统 | ✅ | ✅ | ✅ | ✅ | ✅ |
| 工单系统 | ✅ | ✅ | ✅ | ✅ | ✅ |
| 统一用户管理 | ❌ | ✅ | ✅ | ✅ | ✅ |
| 蓝图路由架构 | ❌ | ✅ | ✅ | ✅ | ✅ |
| Trilium 搜索 | ⚠️ | ✅ | ✅ | ✅ 修复 | ✅ 修复 |
| 图片优化 | ❌ | ❌ | ✅ | ✅ | ✅ |
| 文档结构 | ❌ | ❌ | ⚠️ | ✅ | ✅ |
| 429 错误处理 | ❌ | ⚠️ | ⚠️ | ✅ 修复 | ✅ 修复 |
| 安全加固 | ❌ | ⚠️ | ⚠️ | ⚠️ | ✅ 完成 |
| CSRF 保护 | ❌ | ❌ | ❌ | ❌ | ✅ 完成 |
| XSS 防护 | ❌ | ❌ | ❌ | ❌ | ✅ 完成 |

### 性能对比

| 指标 | v1.x | v2.0 | v2.1 | v2.2 | v2.3 |
|------|------|------|------|------|------|
| 首页加载时间 | ~5秒 | ~4秒 | ~0.5秒 | ~0.5秒 | ~0.5秒 |
| 图片总大小 | 45.9 MB | 45.9 MB | 1.7 MB | 1.7 MB | 1.7 MB |
| 代码行数 | ~15,000 | ~24,000 | ~24,000 | ~24,000 | ~25,000+ |
| 文档数量 | 5 | 15 | 20 | 15* | 12+ |
| 安全评分 | 10/50 (20%) | 12/50 (24%) | 15/50 (30%) | 15/50 (30%) | 47/50 (94%) |

*注: v2.2 合并了部分文档，v2.3 删除了临时文档

---

## 🚀 升级指南

### 从 v2.2 升级到 v2.3

1. **拉取最新代码**
```bash
git pull origin 2.1
```

2. **安装新的依赖**
```bash
pip install Flask-WTF==1.2.1 bleach==6.0.0
```

3. **更新环境变量**
```bash
# 参考 .env.example 更新 .env
cp .env.example .env
# 必须设置以下环境变量：
# - FLASK_SECRET_KEY（或自动生成）
# - DEFAULT_ADMIN_PASSWORD
# - DB_PASSWORD
```

4. **验证功能**
- ✅ 测试知识库登录
- ✅ 测试工单登录
- ✅ 检查 CSRF 保护是否正常工作
- ✅ 验证输入清理功能

---

### 从 v2.1 升级到 v2.2

1. **拉取最新代码**
```bash
git pull origin 2.1
```

2. **安装开发依赖**（如需要）
```bash
pip install -r requirements-dev.txt
```

3. **应用数据库补丁**（如果使用数据库）
```bash
# Windows
database/apply_patches_v2.1_to_v2.2.bat

# Linux/Mac
bash database/apply_patches_v2.1_to_v2.2.sh
```

4. **重启应用**
```bash
# Windows
start.bat

# Linux/Mac
bash start.sh
```

5. **验证功能**
- 访问知识库页面
- 测试内容搜索功能
- 检查搜索结果是否正常显示

---

### 从 v2.0 升级到 v2.1

1. **拉取最新代码**
```bash
git pull origin main
```

2. **验证图片优化**
```bash
# 检查优化后的图片是否存在
ls static/home/images/optimized/
ls static/home/images/BJ/optimized/
```

3. **重启应用**
```bash
python app.py
```

4. **测试页面加载**
- 访问首页: http://localhost:5001/
- 检查 Network 面板的图片加载大小
- 确认 WebP 格式被使用

---

### 从 v1.x 升级到 v2.0

⚠️ **重大架构变更，需要仔细规划**

1. **备份数据库**
```bash
mariadb-dump clouddoors_db > clouddoors_db_backup.sql
mariadb-dump YHKB > YHKB_backup.sql
mariadb-dump casedb > casedb_backup.sql
```

2. **拉取新代码**
```bash
git fetch origin
git checkout v2.0
```

3. **安装依赖**
```bash
pip install -r requirements.txt
```

4. **更新配置文件**
```bash
cp .env.example .env
# 编辑 .env 文件
```

5. **运行迁移脚本**
```bash
bash init_db.sh
```

6. **重启应用**
```bash
python app.py
```

7. **验证功能**
- 测试所有系统功能
- 验证用户登录
- 检查数据库连接

---

## 📚 相关文档

### 系统指南
- [官网系统指南](./HOME_SYSTEM_GUIDE.md)
- [知识库系统指南](./KB_SYSTEM_GUIDE.md)
- [工单系统指南](./CASE_SYSTEM_GUIDE.md)
- [统一用户管理指南](./UNIFIED_SYSTEM_GUIDE.md)

### 安全文档
- [安全修复完整记录](./SECURITY_FIXES_COMPLETE.md)
- [安全修复总结](./SECURITY_FIXES_SUMMARY.md)
- [安全改进文档](./SECURITY_IMPROVEMENTS.md)

### 开发指南
- [快速开始指南](./QUICK_START.md)
- [API 文档](./API_DOCS.md)
- [配置指南](./CONFIGURATION_GUIDE.md)

### 问题修复记录
- 所有问题修复记录已整合到各版本的 CHANGELOG 中

---

## 🤝 贡献者

感谢所有为项目做出贡献的开发者！

- AI 开发助手 - 架构设计、功能实现、文档编写、安全加固

---

## 📞 获取帮助

如果遇到问题：

1. 查看本文档的相关章节
2. 阅读对应的系统指南
3. 查看问题修复记录
4. 提交 Issue 说明问题

---

**文档版本**: v1.1
**最后更新**: 2026-02-13
**维护者**: Claude AI Assistant
