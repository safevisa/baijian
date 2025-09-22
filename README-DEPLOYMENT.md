# 风水摆件电商系统 - 部署指南

## 🚀 一键部署

### 快速开始

1. **下载部署脚本**
```bash
wget https://raw.githubusercontent.com/safevisa/baijian/main/final-deploy.sh
chmod +x final-deploy.sh
```

2. **执行部署**
```bash
./final-deploy.sh yourdomain.com
```

3. **等待部署完成**
- 系统会自动安装所有依赖
- 配置Nginx和SSL证书
- 启动所有服务

## 📋 部署后信息

### 默认管理员账号
- **用户名**: `admin`
- **密码**: `admin123`

### 访问地址
- **主站**: https://yourdomain.com
- **管理后台**: https://yourdomain.com/admin
- **用户工作台**: https://yourdomain.com/dashboard

## 🔧 管理命令

### 服务管理
```bash
# 启动服务
/root/baijian/manage.sh start

# 停止服务
/root/baijian/manage.sh stop

# 重启服务
/root/baijian/manage.sh restart

# 查看状态
/root/baijian/manage.sh status

# 查看日志
/root/baijian/manage.sh logs

# 更新应用
/root/baijian/manage.sh update
```

### 健康检查
```bash
/root/baijian/health-check.sh
```

### 备份
```bash
/root/baijian/backup.sh
```

## 🛠️ 功能特性

### ✅ 已修复的问题
- **会话管理**: 用户登录状态正确保存和验证
- **收款链接**: 复制和查看功能完全正常
- **移动端兼容**: 输入框和按钮在移动端正常工作
- **跨设备登录**: 支持不同设备和浏览器登录
- **HTTPS安全**: 自动SSL证书配置
- **性能优化**: 静态文件缓存和CDN优化

### 🎯 核心功能
- **用户系统**: 注册、登录、个人中心
- **管理员后台**: 用户管理、订单管理、财务报告
- **收款链接**: 创建、管理、分享支付链接
- **支付集成**: 街口支付、支付宝、微信支付
- **移动端适配**: 响应式设计，完美支持手机端
- **数据管理**: 数据备份、同步、导出

## 🔍 故障排除

### 常见问题

1. **域名无法访问**
```bash
# 检查DNS解析
nslookup yourdomain.com

# 检查Nginx状态
systemctl status nginx

# 检查应用状态
systemctl status fengshui-app
```

2. **SSL证书问题**
```bash
# 重新安装SSL证书
certbot certonly --standalone -d yourdomain.com -d www.yourdomain.com

# 重启Nginx
systemctl restart nginx
```

3. **应用无法启动**
```bash
# 查看应用日志
journalctl -u fengshui-app -f

# 检查端口占用
ss -tlnp | grep :3000

# 重启应用
systemctl restart fengshui-app
```

4. **收款链接功能异常**
```bash
# 检查浏览器控制台错误
# 按F12打开开发者工具查看Console

# 检查网络请求
# 查看Network标签页是否有失败的请求
```

### 日志位置
- **应用日志**: `journalctl -u fengshui-app -f`
- **Nginx访问日志**: `/var/log/nginx/access.log`
- **Nginx错误日志**: `/var/log/nginx/error.log`
- **应用日志文件**: `/root/baijian/app.log`

## 📊 系统监控

### 资源使用情况
```bash
# 查看系统资源
htop

# 查看磁盘使用
df -h

# 查看内存使用
free -h

# 查看网络连接
ss -tlnp
```

### 性能优化
- **静态文件缓存**: 1年
- **数据库连接池**: 已优化
- **CDN加速**: 支持配置
- **Gzip压缩**: 已启用

## 🔒 安全配置

### 已配置的安全措施
- **HTTPS强制**: 自动重定向HTTP到HTTPS
- **安全头**: X-Frame-Options, X-XSS-Protection等
- **防火墙**: 只开放必要端口
- **SSL证书**: 自动续期
- **输入验证**: 前后端双重验证

### 建议的安全措施
- 定期更新系统包
- 监控异常访问
- 定期备份数据
- 使用强密码

## 📱 移动端支持

### 已修复的移动端问题
- **输入框**: 防止iOS自动缩放
- **按钮**: 最小触摸目标44px
- **滚动**: 平滑滚动和橡皮筋效果
- **触摸**: 正确的触摸事件处理

### 测试设备
- iPhone (Safari)
- Android (Chrome)
- iPad (Safari)
- 各种屏幕尺寸

## 🚀 扩展功能

### 可添加的功能
- **多语言支持**: 国际化配置
- **主题切换**: 深色/浅色模式
- **API接口**: RESTful API
- **Webhook**: 支付回调
- **邮件通知**: 交易通知
- **短信验证**: 手机验证码

## 📞 技术支持

### 获取帮助
- **GitHub Issues**: 提交问题报告
- **文档**: 查看完整文档
- **社区**: 参与讨论

### 更新应用
```bash
cd /root/baijian
git pull
pnpm install
pnpm run build
systemctl restart fengshui-app
```

---

## 🎉 部署成功！

您的风水摆件电商系统已经成功部署并运行！

**访问地址**: https://yourdomain.com
**管理后台**: https://yourdomain.com/admin
**默认账号**: admin / admin123

祝您使用愉快！🎊
