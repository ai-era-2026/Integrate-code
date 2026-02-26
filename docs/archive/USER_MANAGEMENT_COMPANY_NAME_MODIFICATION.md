# 用户管理界面修改 - 密码类型改为公司名称

## 修改概述
将用户管理界面中的"密码类型"字段修改为"公司名称"字段，并在添加用户和编辑用户界面中同步修改。

## 修改的文件列表

### 1. 前端文件

#### `templates/kb/user_management.html`
**修改内容**:
- 用户列表表格：将表头"密码类型"改为"公司名称"
- 用户列表表格：将显示逻辑从 `{{ user.password_type|upper }}` 改为 `{{ user.company_name or '-' }}`
- 添加用户模态框：添加"公司名称"输入框（必填字段）
- 编辑用户模态框：添加"公司名称"输入框
- 添加用户按钮：修改 `data-company-name` 属性
- JavaScript：在添加用户时包含 `company_name` 字段
- JavaScript：在编辑用户时加载和保存 `company_name` 字段
- JavaScript：添加公司名称必填验证

**具体修改**:
```html
<!-- 表头修改 -->
<th>公司名称</th>  <!-- 原密码类型 -->

<!-- 表格单元格修改 -->
<td>{{ user.company_name or '-' }}</td>  <!-- 原密码类型显示 -->

<!-- 添加用户表单 -->
<div class="mb-3">
    <label for="newCompanyName" class="form-label">公司名称 *</label>
    <input type="text" class="form-control" id="newCompanyName"
           name="company_name" required placeholder="请输入公司名称">
    <div class="form-text">公司名称将作为密码类型使用</div>
</div>

<!-- 编辑用户表单 -->
<div class="mb-3">
    <label for="editCompanyName" class="form-label">公司名称</label>
    <input type="text" class="form-control" id="editCompanyName"
           name="company_name" placeholder="请输入公司名称">
    <div class="form-text">公司名称将作为密码类型使用</div>
</div>
```

**JavaScript修改**:
```javascript
// 添加用户验证
if (!formData.company_name) {
    showMessage('公司名称不能为空', 'warning');
    return;
}

// 编辑用户时加载公司名称
$('#editCompanyName').val($(this).data('company-name'));

// 保存时包含公司名称
const formData = {
    // ...其他字段
    company_name: $('#editCompanyName').val(),
    // ...
};
```

### 2. 后端文件

#### `services/user_service.py`
**修改内容**:
- `get_users()` 方法：在SELECT查询中添加 `company_name` 字段
- `get_user()` 方法：在SELECT查询中添加 `company_name` 字段
- `update_user()` 方法：添加对 `company_name` 字段的更新支持

**具体修改**:
```python
# get_users 方法
list_sql = """
SELECT id, username, display_name, real_name, email, phone, role, status, created_at, last_login, company_name
FROM `users`
...
"""
columns = ['id', 'username', 'display_name', 'real_name', 'email', 'phone', 'role', 'status', 'created_at', 'last_login', 'company_name']

# get_user 方法
cursor.execute(
    "SELECT id, username, display_name, real_name, email, phone, role, status, created_at, last_login, company_name FROM `users` WHERE id = %s",
    (user_id,)
)

# update_user 方法
if 'company_name' in data:
    update_fields.append('company_name = %s')
    update_values.append(data['company_name'])
```

#### `common/unified_auth.py`
**修改内容**:
- `create_user()` 函数：添加 `company_name` 参数
- `create_user()` 函数：在INSERT SQL中添加 `company_name` 字段

**具体修改**:
```python
def create_user(username, password, display_name=None, real_name=None, email=None, company_name=None, role='user', created_by='admin'):
    """
    创建新用户（统一接口）
    统一使用 werkzeug 密码加密
    """
    # ...
    insert_sql = """
    INSERT INTO `users` (username, password_hash, password_type, display_name, real_name, email, role, status, system, created_by, company_name)
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    cursor.execute(insert_sql, (
        username,
        password_hash,
        'werkzeug',
        display_name,
        real_name,
        email,
        role,
        'active',
        'unified',
        created_by,
        company_name  # 新增
    ))
    # ...
```

#### `routes/unified_bp.py`
**修改内容**:
- `add_user()` 路由：添加 `company_name` 字段的验证
- `add_user()` 路由：在调用 `create_user()` 时传递 `company_name` 参数

**具体修改**:
```python
# 添加必填字段验证
if not data.get('company_name'):
    return error_response('公司名称不能为空', 400)

# 使用统一用户创建接口
success, message = create_user(
    username=data['username'],
    password=data['password'],
    display_name=data.get('display_name'),
    real_name=data.get('real_name'),
    email=data.get('email', ''),
    company_name=data.get('company_name', ''),  # 新增
    role=data.get('role', 'user'),
    created_by=session.get('username', 'admin')
)
```

## 数据库字段说明

### users 表结构
确保 `users` 表包含以下字段：
- `id`: 主键
- `username`: 用户名
- `password_hash`: 密码哈希
- `password_type`: 密码类型（保留，用于历史兼容）
- `display_name`: 显示名称
- `real_name`: 真实姓名
- `email`: 邮箱
- `phone`: 电话
- `role`: 角色（admin, user, customer）
- `status`: 状态（active, inactive, locked）
- `company_name`: 公司名称（新增字段）
- `created_at`: 创建时间
- `last_login`: 最后登录时间
- `system`: 系统标识
- `created_by`: 创建者

### 数据库迁移脚本（如需要）

如果数据库中没有 `company_name` 字段，执行以下SQL：

```sql
ALTER TABLE `users` ADD COLUMN `company_name` VARCHAR(100) NULL COMMENT '公司名称' AFTER `created_by`;
```

## 功能说明

### 用户列表页面
- 表格列标题：用户名 | 显示名称 | 邮箱 | 角色 | 状态 | **公司名称** | 最后登录 | 创建时间 | 操作
- 公司名称列显示用户所属的公司名称，如果未填写则显示"-"

### 添加用户页面
- 表单字段：
  - 用户名 * (必填)
  - 密码 * (必填)
  - 公司名称 * (必填)
  - 显示名称 (可选)
  - 邮箱 (可选)
  - 角色 (默认：普通用户)
  - 状态 (默认：正常)
- 验证：公司名称为必填字段

### 编辑用户页面
- 表单字段：
  - 用户名 (禁用，不可修改)
  - 显示名称
  - 真实姓名
  - 邮箱
  - **公司名称** (新增)
  - 角色
  - 状态
  - 修改密码 (可选勾选)
- 数据加载：从用户数据中读取并显示公司名称

## API接口说明

### 添加用户接口
**路由**: `POST /unified/api/users`

**请求体**:
```json
{
  "username": "testuser",
  "password": "password123",
  "display_name": "测试用户",
  "real_name": "张三",
  "email": "test@example.com",
  "company_name": "测试公司",  // 新增必填字段
  "role": "user",
  "status": "active"
}
```

**响应**:
```json
{
  "success": true,
  "message": "用户创建成功"
}
```

### 更新用户接口
**路由**: `PUT /unified/api/users/<user_id>`

**请求体**:
```json
{
  "display_name": "测试用户",
  "real_name": "张三",
  "email": "test@example.com",
  "company_name": "新公司名称",  // 新增字段
  "role": "user",
  "status": "active",
  "password": "newpassword"  // 可选
}
```

**响应**:
```json
{
  "success": true,
  "message": "用户更新成功"
}
```

## 测试步骤

### 1. 重启服务器
```bash
cd e:/Integrate-code
python app.py
```

### 2. 访问用户管理页面
URL: `http://localhost:5000/unified/users`

### 3. 测试添加用户
1. 点击"添加用户"按钮
2. 填写表单：
   - 用户名: testuser
   - 密码: password123
   - 公司名称: 测试公司
   - 显示名称: 测试用户
   - 邮箱: test@example.com
   - 角色: 普通用户
   - 状态: 正常
3. 点击"添加用户"
4. 验证：用户添加成功，公司名称正确显示

### 4. 测试编辑用户
1. 在用户列表中找到刚才添加的用户
2. 点击编辑按钮
3. 修改公司名称为其他值
4. 点击"保存更改"
5. 验证：公司名称更新成功

### 5. 测试验证
1. 尝试添加用户时不填写公司名称
2. 应该显示错误提示："公司名称不能为空"

## 注意事项

1. **向后兼容性**: 保留了 `password_type` 字段，现有数据不受影响
2. **必填字段**: 公司名称在添加用户时为必填字段
3. **数据库字段**: 确保 `users` 表中有 `company_name` 字段
4. **数据完整性**: 所有涉及用户查询和更新的地方都已包含 `company_name` 字段

## 修改日期
2026-02-24

## 修改版本
v2.3
