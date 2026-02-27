# 快速行动清单

> 生成日期：2026-02-26
> 状态：待办事项

---

## 📋 目录

- [立即行动（本周完成）](#立即行动本周完成)
- [短期计划（2-4周）](#短期计划2-4周)
- [中期计划（1-2个月）](#中期计划1-2个月)
- [长期规划（3-6个月）](#长期规划3-6个月)

---

## 立即行动（本周完成）

### 1. 安全性问题修复 ⚠️

#### 1.1 更换所有敏感信息
- [ ] 更换数据库密码
  ```bash
  # 生成新密码
  python3 -c "import secrets; print(secrets.token_urlsafe(32))"
  ```
- [ ] 更换邮件密码/授权码
  ```bash
  # 在企业微信邮箱后台生成新的授权码
  ```
- [ ] 更换 Trilium Token
- [ ] 更换 Flask Secret Key
  ```bash
  python3 -c "import secrets; print(secrets.token_hex(32))"
  ```
- [ ] 确保 `.env` 在 `.gitignore` 中
- [ ] 检查 Git 历史是否包含敏感信息

#### 1.2 配置安全修复
- [ ] 设置 `FLASK_DEBUG=False`（生产环境）
- [ ] 修改默认管理员密码
- [ ] 限制 CORS 允许的来源
  ```bash
  # .env
  ALLOWED_ORIGINS=https://www.yunhukeji.com,https://yunhukeji.com
  ```
- [ ] 为敏感接口启用 CSRF 保护

### 2. 代码质量改进

#### 2.1 移除调试代码
- [ ] 移除所有 `console.log`（生产环境）
- [ ] 移除所有 `print()` 语句
- [ ] 使用 `logger` 统一日志记录

#### 2.2 统一异常处理
- [ ] 创建 `common/exceptions.py` 文件
- [ ] 定义业务异常类
- [ ] 添加全局异常处理器

---

## 短期计划（2-4周）

### 3. 性能优化

#### 3.1 数据库优化
- [ ] 添加工单系统索引
  ```sql
  ALTER TABLE tickets ADD INDEX idx_submit_user_status (submit_user, status);
  ALTER TABLE messages ADD INDEX idx_ticket_send_time (ticket_id, send_time);
  ```
- [ ] 添加知识库系统索引
  ```sql
  ALTER TABLE `KB-info` ADD INDEX idx_category_update (KB_Category, KB_UpdateTime);
  ALTER TABLE `KB-info` ADD INDEX idx_name (KB_Name);
  ```
- [ ] 优化 N+1 查询
  ```python
  # 使用 JOIN 一次获取数据
  SELECT t.*, COUNT(m.id) as message_count
  FROM tickets t
  LEFT JOIN messages m ON t.ticket_id = m.ticket_id
  GROUP BY t.id
  ```
- [ ] 使用游标分页
  ```python
  # 避免 OFFSET 大量数据
  SELECT * FROM tickets WHERE id > ? ORDER BY id LIMIT ?
  ```

#### 3.2 前端优化
- [ ] 统一 jQuery 加载（在 base.html 中）
- [ ] 移除重复的 CSS 和 JS 文件
- [ ] 添加图片懒加载
- [ ] 压缩静态资源

### 4. 代码重构

#### 4.1 拆分路由文件
- [ ] 创建 `routes/case/` 目录
  - [ ] `routes/case/auth_routes.py`
  - [ ] `routes/case/ticket_routes.py`
  - [ ] `routes/case/message_routes.py`
  - [ ] `routes/case/admin_routes.py`
- [ ] 更新导入语句
- [ ] 测试所有路由功能

#### 4.2 统一登录检查
- [ ] 创建 `static/js/modules/auth-checker.js`
  ```javascript
  // 统一的登录检查类
  class AuthChecker { ... }
  ```
- [ ] 更新所有页面使用统一模块
- [ ] 移除重复的登录检查文件

#### 4.3 统一限流豁免
- [ ] 创建 `common/decorators.py`
  ```python
  # 限流豁免装饰器
  def exempt_rate_limit(f): ...
  ```
- [ ] 更新所有路由使用统一装饰器

### 5. 测试完善

#### 5.1 添加单元测试
- [ ] 创建 `tests/test_auth.py`
- [ ] 创建 `tests/test_case.py`
- [ ] 创建 `tests/test_kb.py`
- [ ] 测试核心功能覆盖率达到 60%

#### 5.2 添加集成测试
- [ ] 测试完整的工作流
- [ ] 测试 API 接口
- [ ] 测试数据库操作

---

## 中期计划（1-2个月）

### 6. 缓存系统

#### 6.1 启用 Redis
- [ ] 安装 Redis 服务器
- [ ] 配置 Redis 连接
  ```bash
  # .env
  REDIS_ENABLED=True
  REDIS_HOST=127.0.0.1
  REDIS_PORT=6379
  ```
- [ ] 创建缓存装饰器
  ```python
  # common/decorators.py
  def cached_result(timeout=300): ...
  ```
- [ ] 对常用查询添加缓存

#### 6.2 实现多层缓存
- [ ] 内存缓存（单进程）
- [ ] Redis 缓存（分布式）
- [ ] 数据库查询结果缓存
- [ ] 添加缓存失效策略

### 7. 监控系统

#### 7.1 添加性能监控
- [ ] 集成 Prometheus
  ```python
  from prometheus_flask_exporter import PrometheusMetrics
  metrics = PrometheusMetrics(app)
  ```
- [ ] 添加请求耗时指标
- [ ] 添加数据库连接指标
- [ ] 添加缓存命中率指标

#### 7.2 添加日志分析
- [ ] 使用 ELK Stack（Elasticsearch, Logstash, Kibana）
- [ ] 或使用 Grafana + Loki
- [ ] 添加错误告警
- [ ] 添加性能告警

### 8. 开发流程改进

#### 8.1 CI/CD 流程
- [ ] 创建 `.github/workflows/ci.yml`
- [ ] 添加代码检查（pylint, bandit）
- [ ] 添加单元测试
- [ ] 添加安全扫描

#### 8.2 代码审查
- [ ] 建立代码审查流程
- [ ] 每次提交代码审查
- [ ] 使用 Pull Request 流程

---

## 长期规划（3-6个月）

### 9. 技术栈升级

#### 9.1 前端现代化
- [ ] 评估 Vue 3 或 React
- [ ] 创建前端原型
- [ ] 逐步迁移页面
- [ ] 完全迁移到现代框架

#### 9.2 样式系统优化
- [ ] 评估 Tailwind CSS
- [ ] 安装和配置 Tailwind
- [ ] 逐步迁移现有样式
- [ ] 移除旧的 CSS 文件

#### 9.3 后端框架升级
- [ ] 评估 Flask 升级（如到 3.1.x）
- [ ] 评估异步框架（如 FastAPI）
- [ ] 创建技术选型文档

### 10. 功能增强

#### 10.1 API 文档
- [ ] 完善 Swagger 注解
- [ ] 添加 API 示例
- [ ] 添加错误码说明
- [ ] 集成 Swagger UI

#### 10.2 开发者工具
- [ ] 创建 API 测试工具
- [ ] 创建数据库管理工具
- [ ] 创建日志查看工具

---

## 进度跟踪

### 本周进度

| 任务 | 状态 | 完成日期 | 负责人 |
|------|------|----------|--------|
| 更换敏感信息 | 待办 | - | - |
| 配置安全修复 | 待办 | - | - |
| 移除调试代码 | 待办 | - | - |

### 月度进度

| 月份 | 完成任务 | 待办任务 | 完成率 |
|------|----------|----------|--------|
| 2026-02 | 0/10 | 10 | 0% |

---

## 注意事项

### 优先级说明

- 🔴 **高优先级**：影响安全性或核心功能，立即处理
- 🟡 **中优先级**：影响性能或用户体验，近期完成
- 🟢 **低优先级**：代码质量提升，长期规划

### 依赖关系

某些任务有依赖关系，需要按顺序完成：

```
1. 创建异常类 → 统一异常处理
2. 拆分路由文件 → 统一限流豁免
3. 启用 Redis → 添加缓存装饰器
4. CI/CD 流程 → 代码审查
```

---

**文档版本**: v1.0
**最后更新**: 2026-02-26
**下次审查**: 每周一次
