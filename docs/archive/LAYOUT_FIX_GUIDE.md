# 工单提交页面布局问题排查指南

## 问题描述
工单提交页面的输入框在桌面端应该显示为两列布局，但实际显示为单列。

## 已完成的修复

### 1. CSS文件修改
- **文件位置**: `static/case/css/submit_ticket.css`
- **主要改动**:
  - 移除了可能导致冲突的全局重置规则 (`#submit-ticket-page *`)
  - 添加了明确的桌面端Grid布局规则
  - 使用 `!important` 确保样式优先级
  - 添加了清晰的响应式断点

### 2. 关键CSS规则
```css
/* 桌面端和平板端 (≥768px) - 两列布局 */
@media (min-width: 768px) {
    #submit-ticket-page .form-row {
        display: grid !important;
        grid-template-columns: 1fr 1fr !important;
        gap: 28px !important;
    }

    #submit-ticket-page .form-row.single {
        grid-template-columns: 1fr !important;
        gap: 0 !important;
    }
}

/* 移动端 (<768px) - 单列布局 */
@media (max-width: 767px) {
    #submit-ticket-page .form-row {
        grid-template-columns: 1fr !important;
        gap: 0 !important;
    }
}
```

### 3. HTML结构
- **文件位置**: `templates/case/submit_ticket.html`
- **结构**:
  ```html
  <div id="submit-ticket-page">
    <div class="form-section">
      <div class="section-body">
        <!-- 两列布局 -->
        <div class="form-row">
          <div class="form-col">...</div>
          <div class="form-col">...</div>
        </div>
        <!-- 单列布局 -->
        <div class="form-row single">
          <div class="form-col">...</div>
        </div>
      </div>
    </div>
  </div>
  ```

## 如何验证修复

### 方法1：使用测试页面
直接在浏览器中打开 `test_layout.html` 文件：
```
e:/Integrate-code/test_layout.html
```

这个测试页面包含了：
- 视觉化的布局展示（带边框和背景色）
- 实时显示窗口宽度和当前布局类型
- 清晰的标签指示每个输入框应该显示的位置

**预期结果**:
- **桌面端 (≥768px)**: 前两行显示为并排的两列，第三行显示为单列
- **移动端 (<768px)**: 所有行显示为单列，垂直堆叠

### 方法2：浏览器开发者工具检查

1. 打开工单提交页面: `http://localhost:5000/case/submit`
2. 按 `F12` 打开开发者工具
3. 切换到 **Elements（元素）** 标签
4. 找到一个 `.form-row` 元素
5. 检查 **Computed（计算样式）** 标签，查找以下属性:
   - `display: grid`
   - `grid-template-columns: 1fr 1fr` (桌面端) 或 `1fr` (移动端)
   - `gap: 28px` (桌面端) 或 `0px` (移动端)

6. 在 **Network（网络）** 标签中检查:
   - 找到 `submit_ticket.css` 文件
   - 检查 **Status** 是否为 `200`
   - 检查 **Size** 是否约为 16.5KB (16898 字节)
   - 如果状态不是200，说明CSS文件加载失败

### 方法3：JavaScript控制台检查

在浏览器控制台中运行以下代码：

```javascript
// 检查窗口宽度
console.log('窗口宽度:', window.innerWidth, 'px');

// 检查Grid布局
const formRows = document.querySelectorAll('#submit-ticket-page .form-row');
formRows.forEach((row, index) => {
    const computedStyle = window.getComputedStyle(row);
    console.log(`第 ${index + 1} 行:`);
    console.log('  display:', computedStyle.display);
    console.log('  grid-template-columns:', computedStyle.gridTemplateColumns);
    console.log('  gap:', computedStyle.gap);
});

// 检查CSS文件是否加载
const stylesheets = Array.from(document.stylesheets);
const submitTicketCss = stylesheets.find(sheet => sheet.href && sheet.href.includes('submit_ticket.css'));
if (submitTicketCss) {
    console.log('✓ submit_ticket.css 已加载');
    console.log('  CSS规则数量:', submitTicketCss.cssRules.length);
} else {
    console.log('✗ submit_ticket.css 未加载');
}
```

## 常见问题及解决方案

### 问题1: CSS文件未加载
**症状**: 样式完全混乱，显示默认的HTML样式

**解决方案**:
1. 检查浏览器控制台的Network标签，确认CSS文件状态
2. 确认文件路径: `/static/case/css/submit_ticket.css`
3. 清除浏览器缓存（Ctrl+Shift+Delete）
4. 使用无痕模式重新访问

### 问题2: Grid布局被覆盖
**症状**: 页面样式正常，但输入框仍然垂直堆叠

**解决方案**:
1. 在开发者工具的Elements标签中，检查 `.form-row` 元素
2. 查看应用的所有CSS规则
3. 找到覆盖 `grid-template-columns` 的规则
4. 记录该规则的来源（CSS文件名和行号）

### 问题3: 浏览器兼容性问题
**症状**: 在某些浏览器中布局不正常

**解决方案**:
1. 检查浏览器版本（建议使用最新版Chrome、Firefox、Edge或Safari）
2. 测试不同的浏览器
3. 在Can I Use网站检查Grid布局支持: https://caniuse.com/css-grid

### 问题4: 服务器缓存问题
**症状**: 即使刷新页面，更改仍未生效

**解决方案**:
1. 重启Flask服务器
2. 清除浏览器缓存
3. 在URL中添加时间戳强制刷新: `/case/submit?t=20250224`
4. 使用无痕模式

## 验证清单

- [ ] CSS文件存在且大小正常 (16.5KB)
- [ ] 在Network标签中看到CSS文件加载成功 (Status 200)
- [ ] 在开发者工具中看到 `display: grid`
- [ ] 在桌面端 (≥768px) 看到 `grid-template-columns: 1fr 1fr`
- [ ] 在移动端 (<768px) 看到 `grid-template-columns: 1fr`
- [ ] 测试页面 `test_layout.html` 显示正确布局
- [ ] 浏览器控制台没有CSS加载错误

## 如果问题仍然存在

请提供以下信息以便进一步排查：

1. **浏览器信息**:
   - 浏览器名称和版本
   - 操作系统

2. **开发者工具信息**:
   - Network标签中CSS文件的状态
   - Elements标签中 `.form-row` 的计算样式
   - 控制台中的任何错误信息

3. **截图信息**:
   - 页面当前显示的样子
   - 开发者工具中Network标签的截图
   - 开发者工具中Elements标签的截图

## 调试文件位置

- **CSS文件**: `e:/Integrate-code/static/case/css/submit_ticket.css`
- **HTML模板**: `e:/Integrate-code/templates/case/submit_ticket.html`
- **测试页面**: `e:/Integrate-code/test_layout.html`
- **Grid测试页面**: `e:/Integrate-code/static/case/css/test_grid.html`

## 快速测试命令

```bash
# 启动Flask服务器
cd e:/Integrate-code
python app.py

# 在浏览器中访问
# http://localhost:5000/case/submit
# 或直接打开测试页面: file:///e:/Integrate-code/test_layout.html
```

---

**最后更新**: 2026-02-24
**修复版本**: v2.3
