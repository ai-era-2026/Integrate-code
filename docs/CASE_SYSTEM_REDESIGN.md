# 工单系统重构文档

## 📋 概述

本文档描述工单系统从 v2.2 升级到 v2.3 的重构方案，主要改进包括：
1. 支持按公司管理客户
2. 支持工单抄送功能
3. 完善权限控制机制

---

## 🎯 需求说明

### 1. 角色权限

| 角色 | 说明 | 权限 |
|------|------|------|
| **管理员 (admin)** | 本公司员工 | 查看所有工单，为所有客户创建工单 |
| **普通用户 (user)** | 本公司员工 | 查看所有工单，查看自己创建的工单，为所有客户创建工单 |
| **客户 (customer)** | 客户账号 | 只能查看自己创建的工单 |

**权限说明：**
- 管理员和普通用户：
  - 可以查看**所有工单**
  - 可以筛选"我的工单"（自己创建的工单）
  - 可以为**所有客户**创建工单
- 客户：
  - **只能查看自己创建的工单**
  - 不能创建工单

### 2. 工单创建流程

**创建工单界面字段：**

| 字段 | 说明 | 填充方式 |
|------|------|----------|
| 客户公司 | 公司名称 | 自动填充客户信息中的公司名称，管理员和普通用户可以选择不同的公司 |
| 客户联系人 | 联系人姓名 | 自动填充客户信息的用户名称，管理员和普通用户可以根据公司名称来选择联系人 |
| 联系电话 | 联系电话 | 自动填充，管理员和普通用户根据选择的联系人来添加 |
| 联系邮箱 | 邮箱 | 自动填充，管理员和普通用户根据选择的联系人来添加 |
| 抄送邮箱 | 其他人的邮箱 | 可选，多个邮箱用逗号分隔，后期对接邮件系统后进行抄送 |

**工作流程：**
1. 管理员/普通用户选择客户公司
2. 系统自动加载该公司的所有客户联系人
3. 管理员/普通用户选择联系人
4. 系统自动填充联系人的电话和邮箱
5. 管理员/普通用户可以选择添加抄送邮箱（可选）

---

## 🔧 数据库变更

### 1. 用户表 (YHKB.users)

**新增字段：**

```sql
ALTER TABLE `users`
ADD COLUMN `company_name` VARCHAR(200) DEFAULT NULL COMMENT '公司名称(客户角色必填)' AFTER `email`,
ADD COLUMN `phone` VARCHAR(20) DEFAULT NULL COMMENT '联系电话' AFTER `company_name`,
ADD INDEX `idx_company_name` ON `users`(`company_name`);
```

**字段说明：**
- `company_name`: 公司名称，客户角色必填
- `phone`: 联系电话，客户角色必填

### 2. 工单表 (casedb.tickets)

**新增字段：**

```sql
ALTER TABLE `tickets`
ADD COLUMN `cc_emails` TEXT NULL COMMENT '抄送邮箱(多个邮箱用逗号分隔)' AFTER `customer_email`;
```

**字段说明：**
- `cc_emails`: 抄送邮箱，多个邮箱用逗号分隔，如：`a@example.com,b@example.com`

---

## 🚀 升级步骤

### 方式 1: 从头安装（全新部署）

直接使用更新后的 `init_database.sql` 即可，包含所有字段：

```bash
mysql -h localhost -u root -p < database/init_database.sql
```

### 方式 2: 从 v2.2 升级（已有环境）

执行 v2.2_to_v2.3 补丁脚本：

**Windows:**
```bash
cd database/patches/v2.2_to_v2.3
apply_patches_v2.2_to_v2.3.bat
```

**Linux/Mac:**
```bash
cd database/patches/v2.2_to_v2.3
chmod +x apply_patches_v2.2_to_v2.3.sh
./apply_patches_v2.2_to_v2.3.sh
```

或手动执行：
```bash
# 补丁1: 添加用户公司字段
mysql -h localhost -u root -p YHKB < database/patches/v2.2_to_v2.3/001_add_user_company_fields.sql

# 补丁2: 添加工单抄送字段
mysql -h localhost -u root -p casedb < database/patches/v2.2_to_v2.3/002_add_cc_emails.sql
```

---

## 📡 API 变更

### 1. 新增 API 接口

#### 获取客户公司列表

```http
GET /case/api/customers/companies
```

**响应示例：**
```json
{
  "success": true,
  "message": "查询成功",
  "data": [
    "北京科技有限公司",
    "上海创新集团",
    "深圳智能系统"
  ]
}
```

#### 获取客户联系人列表

```http
GET /case/api/customers?company_name=北京科技有限公司
```

**请求参数：**
- `company_name` (可选): 公司名称，用于筛选特定公司的客户

**响应示例：**
```json
{
  "success": true,
  "message": "查询成功",
  "data": [
    {
      "id": 1,
      "username": "customer1",
      "name": "张三",
      "email": "zhangsan@example.com",
      "phone": "13800138000",
      "company_name": "北京科技有限公司"
    },
    {
      "id": 2,
      "username": "customer2",
      "name": "李四",
      "email": "lisi@example.com",
      "phone": "13800138001",
      "company_name": "北京科技有限公司"
    }
  ]
}
```

### 2. 修改的 API 接口

#### 创建工单

**新增字段：**
- `cc_emails`: 抄送邮箱（可选）

**请求示例：**
```json
{
  "customer_name": "北京科技有限公司",
  "customer_contact_name": "张三",
  "customer_contact_phone": "13800138000",
  "customer_email": "zhangsan@example.com",
  "cc_emails": "cc1@example.com,cc2@example.com",
  "product": "智能系统",
  "issue_type": "technical",
  "priority": "high",
  "title": "系统无法启动",
  "content": "系统启动时报错，请协助排查"
}
```

#### 获取工单列表

**权限控制：**
- **客户角色**: 只能看到自己创建的工单
- **管理员/普通用户**:
  - 不筛选: 查看所有工单
  - `my_only=true`: 查看自己创建的工单
  - `status=pending`: 查看指定状态的工单

**请求示例：**
```http
# 查看所有工单（管理员/普通用户）
GET /case/api/tickets

# 查看我的工单（管理员/普通用户）
GET /case/api/tickets?my_only=true

# 查看待处理工单
GET /case/api/tickets?status=pending

# 查看我的待处理工单
GET /case/api/tickets?status=pending&my_only=true
```

---

## 🎨 前端实现建议

### 1. 工单创建页面

**HTML 结构：**
```html
<div class="form-section">
  <h3>客户信息</h3>

  <!-- 客户公司选择 -->
  <div class="form-group">
    <label>客户公司 *</label>
    <select id="customerCompany" required>
      <option value="">请选择客户公司</option>
    </select>
  </div>

  <!-- 客户联系人选择 -->
  <div class="form-group">
    <label>客户联系人 *</label>
    <select id="customerContact" required>
      <option value="">请先选择客户公司</option>
    </select>
  </div>

  <!-- 联系电话（自动填充，只读） -->
  <div class="form-group">
    <label>联系电话 *</label>
    <input type="text" id="customerPhone" readonly>
  </div>

  <!-- 联系邮箱（自动填充，只读） -->
  <div class="form-group">
    <label>联系邮箱 *</label>
    <input type="email" id="customerEmail" readonly>
  </div>

  <!-- 抄送邮箱（可选） -->
  <div class="form-group">
    <label>抄送邮箱（可选）</label>
    <input type="text" id="ccEmails" placeholder="多个邮箱用逗号分隔">
    <small class="form-text">多个邮箱用逗号分隔，如：a@example.com,b@example.com</small>
  </div>
</div>
```

**JavaScript 逻辑：**
```javascript
// 1. 加载客户公司列表
function loadCustomerCompanies() {
  fetch('/case/api/customers/companies')
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        const select = document.getElementById('customerCompany');
        select.innerHTML = '<option value="">请选择客户公司</option>';
        data.data.forEach(company => {
          select.innerHTML += `<option value="${company}">${company}</option>`;
        });
      }
    });
}

// 2. 客户公司变化时加载联系人
document.getElementById('customerCompany').addEventListener('change', function() {
  const companyName = this.value;
  if (!companyName) return;

  // 清空联系人选择
  const contactSelect = document.getElementById('customerContact');
  contactSelect.innerHTML = '<option value="">请选择联系人</option>';

  // 加载联系人列表
  fetch(`/case/api/customers?company_name=${encodeURIComponent(companyName)}`)
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        data.data.forEach(customer => {
          contactSelect.innerHTML += `<option value="${customer.username}"
                                       data-name="${customer.name}"
                                       data-phone="${customer.phone}"
                                       data-email="${customer.email}">${customer.name}</option>`;
        });
      }
    });
});

// 3. 客户联系人变化时自动填充信息
document.getElementById('customerContact').addEventListener('change', function() {
  const selectedOption = this.options[this.selectedIndex];
  if (!selectedOption.value) return;

  // 自动填充姓名、电话、邮箱
  const name = selectedOption.getAttribute('data-name');
  const phone = selectedOption.getAttribute('data-phone');
  const email = selectedOption.getAttribute('data-email');

  document.getElementById('customerName').value = name;
  document.getElementById('customerPhone').value = phone;
  document.getElementById('customerEmail').value = email;
});

// 4. 初始化
loadCustomerCompanies();
```

### 2. 工单列表页面

**筛选控件：**
```html
<div class="filter-controls">
  <!-- 状态筛选 -->
  <select id="statusFilter">
    <option value="">全部状态</option>
    <option value="pending">待处理</option>
    <option value="processing">处理中</option>
    <option value="completed">已完成</option>
    <option value="closed">已关闭</option>
  </select>

  <!-- 我的工单筛选（仅管理员/普通用户显示） -->
  <label class="checkbox-inline" id="myOnlyFilter" style="display: none;">
    <input type="checkbox" id="myOnly"> 只看我的工单
  </label>

  <button onclick="loadTickets()">查询</button>
</div>
```

**JavaScript 逻辑：**
```javascript
// 根据角色显示不同的筛选选项
function initFilters() {
  fetch('/case/api/user/info')
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        const userRole = data.data.role;
        // 管理员和普通用户可以查看所有工单
        if (userRole === 'admin' || userRole === 'user') {
          document.getElementById('myOnlyFilter').style.display = 'inline-block';
        }
      }
    });
}

// 加载工单列表
function loadTickets() {
  const status = document.getElementById('statusFilter').value;
  const myOnly = document.getElementById('myOnly').checked;

  let url = '/case/api/tickets?';
  if (status) url += `status=${status}&`;
  if (myOnly) url += `my_only=true`;

  fetch(url)
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        renderTickets(data.data);
      }
    });
}
```

---

## 📝 数据迁移建议

### 1. 为现有客户用户补充公司信息

```sql
-- 查看所有客户用户
SELECT id, username, real_name, email, role
FROM `users`
WHERE role = 'customer' AND status = 'active';

-- 更新客户用户的公司信息（需要手动填写）
UPDATE `users`
SET company_name = '公司名称', phone = '联系电话'
WHERE id = ?;
```

### 2. 为现有客户用户创建示例数据

```sql
-- 创建示例客户用户
INSERT INTO `users` (username, password_hash, password_type, display_name, real_name, email, company_name, phone, role, status, system, created_by)
VALUES
('customer_demo1', 'scrypt:32768:8:1$demo1$...', 'werkzeug', '张三', '张三', 'zhangsan@example.com', '北京科技有限公司', '13800138000', 'customer', 'active', 'unified', 'admin'),
('customer_demo2', 'scrypt:32768:8:1$demo2$...', 'werkzeug', '李四', '李四', 'lisi@example.com', '北京科技有限公司', '13800138001', 'customer', 'active', 'unified', 'admin'),
('customer_demo3', 'scrypt:32768:8:1$demo3$...', 'werkzeug', '王五', '王五', 'wangwu@example.com', '上海创新集团', '13800138002', 'customer', 'active', 'unified', 'admin');
```

---

## 🧪 测试建议

### 1. 功能测试

#### 测试用例 1: 管理员创建工单
1. 使用管理员账号登录
2. 进入工单创建页面
3. 选择客户公司
4. 选择客户联系人
5. 验证联系电话和邮箱自动填充
6. 添加抄送邮箱
7. 提交工单
8. 验证工单创建成功，包含抄送邮箱

#### 测试用例 2: 客户查看工单
1. 使用客户账号登录
2. 进入工单列表页面
3. 验证只能看到自己创建的工单
4. 尝试访问其他工单详情
5. 验证无权限访问

#### 测试用例 3: 普通用户查看工单
1. 使用普通用户账号登录
2. 进入工单列表页面
3. 验证可以看到所有工单
4. 筛选"我的工单"
5. 验证只显示自己创建的工单

### 2. 权限测试

| 角色 | 查看所有工单 | 查看我的工单 | 创建工单 | 选择公司 | 选择联系人 |
|------|-------------|-------------|---------|---------|-----------|
| 管理员 | ✅ | ✅ | ✅ | ✅ | ✅ |
| 普通用户 | ✅ | ✅ | ✅ | ✅ | ✅ |
| 客户 | ❌ | ✅ | ❌ | ❌ | ❌ |

---

## 🔒 安全注意事项

1. **权限验证**: 所有 API 接口都必须验证用户角色
2. **数据隔离**: 客户角色只能查看自己的数据
3. **输入验证**: 对所有用户输入进行验证（邮箱格式、字段长度等）
4. **SQL 注入防护**: 使用参数化查询
5. **XSS 防护**: 对用户输入进行转义

---

## 📚 相关文档

- [数据库升级说明](../database/patches/v2.2_to_v2.3/README.md)
- [API 文档](API_DOCS.md)
- [工单系统使用指南](CASE_SYSTEM_GUIDE.md)

---

**版本**: v2.3
**创建日期**: 2026-02-18
**维护人员**: 云户科技技术团队
