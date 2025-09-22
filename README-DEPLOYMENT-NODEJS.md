# 风水摆件电商网站 - Node.js 生产环境部署指南

## 🚀 一键部署方案

基于您的服务器配置（新加坡，1 vCPU，4GB RAM，30GB NVMe），我们提供了三种部署方案：

### 方案一：快速部署（推荐新手）
```bash
# 在服务器上执行
wget https://raw.githubusercontent.com/safevisa/baijian/main/quick-deploy.sh
chmod +x quick-deploy.sh
./quick-deploy.sh
```

### 方案二：完整部署（推荐生产环境）
```bash
# 在服务器上执行
wget https://raw.githubusercontent.com/safevisa/baijian/main/deploy-nodejs-production.sh
chmod +x deploy-nodejs-production.sh
./deploy-nodejs-production.sh
```

### 方案三：优化部署（推荐高性能需求）
```bash
# 在服务器上执行
wget https://raw.githubusercontent.com/safevisa/baijian/main/server-optimized.sh
chmod +x server-optimized.sh
./server-optimized.sh
```

## 📋 部署前准备

### 1. 服务器要求
- **操作系统**: Ubuntu 22.04 LTS
- **CPU**: 1 vCPU 或更高
- **内存**: 4GB RAM 或更高
- **存储**: 30GB NVMe 或更高
- **网络**: 公网IP，开放80、443端口

### 2. 域名配置
确保域名 `jinshiying.com` 已解析到服务器IP `45.77.248.70`

### 3. 服务器访问
```bash
# 使用SSH连接到服务器
ssh root@45.77.248.70
# 密码: b{R4$ih5jxe-Lzxx
```

## 🔧 部署步骤

### 步骤1：连接服务器
```bash
ssh root@45.77.248.70
```

### 步骤2：选择部署方案
根据您的需求选择上述三种方案之一

### 步骤3：等待部署完成
部署过程大约需要5-10分钟，请耐心等待

### 步骤4：配置SSL证书
```bash
# 安装SSL证书
certbot --nginx -d jinshiying.com -d www.jinshiying.com
```

### 步骤5：测试功能
访问 https://jinshiying.com 测试所有功能

## 🎯 功能测试

### 测试账号
- **管理员**: `admin@jinshiying.com` / `admin123`
- **测试用户**: `test@jinshiying.com` / `test123`

### 测试项目
1. **用户注册和登录**
   - 注册新用户
   - 管理员登录
   - 跨设备登录测试

2. **支付功能**
   - 创建收款链接
   - 支付流程测试
   - 支付回调测试

3. **管理后台**
   - 用户管理
   - 订单管理
   - 数据统计

## 📊 管理命令

### 应用管理
```bash
# 查看应用状态
systemctl status fengshui-app

# 重启应用
systemctl restart fengshui-app

# 停止应用
systemctl stop fengshui-app

# 启动应用
systemctl start fengshui-app
```

### 日志查看
```bash
# 查看应用日志
journalctl -u fengshui-app -f

# 查看Nginx日志
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

### 监控脚本
```bash
# 运行监控脚本
/opt/fengshui-ecommerce/monitor.sh

# 查看日志
/opt/fengshui-ecommerce/logs.sh

# 更新应用
/opt/fengshui-ecommerce/update.sh

# 备份数据
/opt/fengshui-ecommerce/backup.sh
```

## 🔍 故障排除

### 常见问题

#### 1. 应用无法启动
```bash
# 查看详细错误信息
journalctl -u fengshui-app -n 50

# 检查端口占用
ss -tlnp | grep 3000

# 重启应用
systemctl restart fengshui-app
```

#### 2. Nginx配置错误
```bash
# 测试Nginx配置
nginx -t

# 重新加载配置
systemctl reload nginx
```

#### 3. 域名无法访问
```bash
# 检查DNS解析
nslookup jinshiying.com

# 检查防火墙
ufw status

# 检查端口监听
ss -tlnp | grep -E ':(80|443)'
```

#### 4. 支付功能异常
```bash
# 检查环境变量
cat /opt/fengshui-ecommerce/fengshui-ecommerce/.env.production

# 检查支付API配置
curl -I https://gateway.suntone.com/payment/api/gotoPayment
```

## 📈 性能优化

### 系统优化
- 已配置内核参数优化
- 已设置文件描述符限制
- 已优化内存使用

### 应用优化
- 使用pnpm提升安装速度
- 配置静态文件缓存
- 启用gzip压缩

### 监控建议
- 定期检查系统资源使用
- 监控应用日志
- 定期备份数据

## 🔒 安全配置

### 已配置的安全措施
- 防火墙规则
- SSL/TLS加密
- 安全头设置
- 用户权限控制

### 建议的安全措施
- 定期更新系统
- 监控异常访问
- 备份重要数据
- 使用强密码

## 📞 技术支持

如遇到问题，请提供以下信息：
1. 服务器配置信息
2. 错误日志
3. 操作步骤
4. 预期结果

联系方式：
- 邮箱: service@crf.hk
- 电话: +852 61588111

## 📝 更新日志

### v1.0.0 (2025-01-22)
- 初始版本发布
- 支持Node.js 18 LTS
- 集成JKOPAY支付
- 完整的用户管理系统
- 响应式设计支持

---

**香港京世盈有限公司** - 專業風水擺件供應商
