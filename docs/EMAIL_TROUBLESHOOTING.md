# 邮件发送故障排查指南

## 问题描述

在公网部署后，提交留言时邮件发送失败，出现以下错误：

```
socket.gaierror: [Errno -3] Lookup timed out
```

## 错误分析

这个错误表示 **DNS解析超时**，即服务器无法将 `smtp.exmail.qq.com` 域名解析为IP地址。

## 可能的原因

### 1. DNS服务器配置问题

服务器配置的DNS服务器无法正常解析域名。

**检查命令**：
```bash
# 检查DNS服务器配置
cat /etc/resolv.conf

# 测试DNS解析
nslookup smtp.exmail.qq.com
dig smtp.exmail.qq.com
ping smtp.exmail.qq.com
```

**解决方案**：

```bash
# 编辑DNS配置
vi /etc/resolv.conf

# 添加公共DNS服务器
nameserver 8.8.8.8
nameserver 114.114.114.114
nameserver 223.5.5.5
```

### 2. 网络连接问题

服务器无法访问外网，或者防火墙阻止了DNS查询。

**检查命令**：
```bash
# 测试外网连接
ping -c 4 8.8.8.8

# 测试邮件服务器端口
telnet smtp.exmail.qq.com 465
# 或使用 nc
nc -zv smtp.exmail.qq.com 465

# 检查防火墙规则
iptables -L
firewall-cmd --list-all
```

**解决方案**：

```bash
# 如果使用 iptables，添加规则允许DNS和SMTP端口
iptables -A INPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p tcp --dport 53 -j ACCEPT
iptables -A OUTPUT -p udp --dport 465 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 465 -j ACCEPT

# 如果使用 firewalld
firewall-cmd --add-service=dns --permanent
firewall-cmd --add-port=465/tcp --permanent
firewall-cmd --reload
```

### 3. eventlet与smtplib兼容性问题

使用eventlet时，smtplib的DNS解析可能存在问题。

**解决方案**：

已在代码中添加重试机制和更长的超时时间（60秒）。

### 4. 云服务商网络限制

某些云服务商（如腾讯云、阿里云）默认限制外网访问，或者SMTP端口被封禁。

**检查方法**：
- 登录云服务商控制台
- 查看安全组规则
- 检查是否有外网访问限制

**解决方案**：
- 开放外网访问权限
- 在安全组中添加出站规则，允许访问 `smtp.exmail.qq.com:465`

## 详细排查步骤

### 步骤1：检查DNS配置

```bash
# 1. 查看当前DNS配置
cat /etc/resolv.conf

# 2. 测试DNS解析
nslookup smtp.exmail.qq.com

# 3. 如果解析失败，修改DNS配置
vi /etc/resolv.conf

# 添加以下内容（根据实际情况选择）：
# 腾讯云推荐DNS
nameserver 119.29.29.29
nameserver 182.254.116.116

# 阿里云推荐DNS
nameserver 223.5.5.5
nameserver 223.6.6.6

# 通用公共DNS
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 114.114.114.114
```

### 步骤2：测试网络连接

```bash
# 1. 测试基础网络连通性
ping -c 4 8.8.8.8

# 2. 测试DNS解析
ping -c 4 smtp.exmail.qq.com

# 3. 测试SMTP端口连接
# 方法1：使用 telnet
telnet smtp.exmail.qq.com 465

# 方法2：使用 nc
nc -zv smtp.exmail.qq.com 465

# 方法3：使用 openssl 测试SSL连接
openssl s_client -connect smtp.exmail.qq.com:465 -crlf
```

如果以上测试都失败，说明服务器无法访问外网或邮件服务器。

### 步骤3：检查防火墙规则

```bash
# iptables
iptables -L -n -v

# firewalld
firewall-cmd --list-all

# 允许DNS查询（UDP 53）
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT

# 允许SMTP连接（TCP 465）
iptables -A OUTPUT -p tcp --dport 465 -j ACCEPT
```

### 步骤4：检查云服务商安全组

登录云服务商控制台（腾讯云/阿里云/华为云等）：

1. 找到实例的"安全组"设置
2. 查看出站规则（出方向规则）
3. 确保允许：
   - 所有协议出站，或者
   - TCP 465端口出站
   - DNS (UDP 53, TCP 53) 出站

### 步骤5：测试邮件发送

在服务器上手动测试邮件发送：

```python
# 创建测试脚本 test_email.py
import smtplib
import ssl

try:
    # 配置
    smtp_server = "smtp.exmail.qq.com"
    smtp_port = 465
    sender_email = "your_email@company.com"
    sender_password = "your_password"

    # 测试连接
    context = ssl.create_default_context()
    with smtplib.SMTP_SSL(smtp_server, smtp_port, context=context, timeout=60) as server:
        print("连接成功，开始登录...")
        server.login(sender_email, sender_password)
        print("登录成功！")
        server.quit()
        print("测试通过！")

except Exception as e:
    print(f"测试失败: {e}")
```

运行测试：
```bash
python3 test_email.py
```

## 快速解决方案

### 方案1：使用公共DNS（最常见）

```bash
# 编辑DNS配置
vi /etc/resolv.conf

# 添加以下内容
nameserver 119.29.29.29
nameserver 182.254.116.116
# 或者
nameserver 8.8.8.8
nameserver 114.114.114.114

# 保存后重启网络服务（根据系统不同）
systemctl restart network
# 或
service network restart
```

### 方案2：检查云服务商安全组

1. 登录云服务商控制台
2. 找到实例的安全组
3. 添加出站规则：
   - 协议：TCP
   - 端口：465
   - 目的：0.0.0.0/0

### 方案3：禁用eventlet（如果使用）

如果使用eventlet导致DNS解析问题，可以考虑：

```python
# 在代码中暂时禁用eventlet的monkey_patch
# 或者使用标准socket而不是eventlet的socket
```

## 代码优化

已在 `services/email_service.py` 中添加以下优化：

1. **增加超时时间**：从30秒增加到60秒
2. **添加重试机制**：失败后自动重试2次
3. **更详细的错误日志**：区分DNS错误、超时错误、认证错误等
4. **配置检查**：启动时检查邮件配置是否完整

## 配置检查清单

确保 `.env` 文件中以下配置正确：

```bash
# 邮件服务器
MAIL_SERVER=smtp.exmail.qq.com
MAIL_PORT=465

# 邮件账户
MAIL_USERNAME=your_email@company.com
MAIL_PASSWORD=your_authorization_code

# 发件人和联系人
MAIL_DEFAULT_SENDER=your_email@company.com
CONTACT_EMAIL=your_email@company.com
```

**注意**：
- `MAIL_PASSWORD` 应该是邮箱的**授权码**，不是登录密码
- 需要在企业微信邮箱后台开启"客户端授权密码"

## 企业微信邮箱授权码获取方法

1. 登录企业微信邮箱后台：https://exmail.qq.com
2. 点击"设置" → "账户" → "开启服务"
3. 开启"IMAP/SMTP服务"和"POP3/SMTP服务"
4. 生成授权码（不是登录密码）
5. 将授权码配置到 `MAIL_PASSWORD`

## 日志查看

查看邮件发送的详细日志：

```bash
# 查看应用日志
tail -f logs/app.log

# 查看系统日志
journalctl -u your-service -f

# 过滤邮件相关错误
grep -i "邮件" logs/app.log
grep -i "email" logs/app.log
grep -i "smtp" logs/app.log
```

## 常见错误及解决方案

### 错误1：socket.gaierror: [Errno -3] Lookup timed out

**原因**：DNS解析失败

**解决方案**：
1. 检查DNS配置
2. 修改为公共DNS（8.8.8.8, 114.114.114.114）
3. 测试DNS解析：`nslookup smtp.exmail.qq.com`

### 错误2：socket.timeout: timed out

**原因**：连接超时，无法连接到邮件服务器

**解决方案**：
1. 测试网络连通性：`ping smtp.exmail.qq.com`
2. 测试端口连接：`telnet smtp.exmail.qq.com 465`
3. 检查防火墙和安全组规则

### 错误3：smtplib.SMTPAuthenticationError

**原因**：认证失败

**解决方案**：
1. 检查邮箱用户名是否正确
2. 检查是否使用授权码而非登录密码
3. 确认企业微信邮箱已开启SMTP服务

### 错误4：Connection refused

**原因**：连接被拒绝

**解决方案**：
1. 检查端口是否正确（465或587）
2. 检查邮件服务器地址是否正确
3. 检查是否使用SSL连接（465端口）或STARTTLS（587端口）

## 联系支持

如果以上方案都无法解决问题，请联系：

1. 云服务商技术支持
2. 企业微信邮箱客服
3. 检查服务器所在网络环境是否有特殊限制

## 预防措施

1. **定期测试邮件发送**：设置定时任务测试邮件发送功能
2. **监控DNS解析**：监控DNS服务器的响应时间
3. **配置备用DNS**：配置多个DNS服务器作为备份
4. **日志告警**：配置邮件发送失败的告警通知
