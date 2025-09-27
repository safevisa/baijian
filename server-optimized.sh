#!/bin/bash

# 风水摆件电商网站 - 服务器优化部署脚本
# 专门针对: 45.77.248.70 (新加坡, 1 vCPU, 4GB RAM, 30GB NVMe)

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 检查root权限
if [ "$EUID" -ne 0 ]; then
    echo "请使用root用户运行此脚本"
    exit 1
fi

log "🚀 开始优化部署风水摆件电商网站..."

# 1. 系统优化
log "⚙️ 优化系统配置..."
# 增加文件描述符限制
echo "* soft nofile 65535" >> /etc/security/limits.conf
echo "* hard nofile 65535" >> /etc/security/limits.conf

# 优化内核参数
cat >> /etc/sysctl.conf << EOF
# 网络优化
net.core.somaxconn = 65535
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_keepalive_intvl = 15
net.ipv4.tcp_keepalive_probes = 5

# 内存优化
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
EOF

sysctl -p

# 2. 安装必要软件
log "📦 安装必要软件..."
apt update && apt upgrade -y
apt install -y curl wget git nginx certbot python3-certbot-nginx ufw htop iotop nethogs

# 3. 安装Node.js 18 LTS
log "📦 安装Node.js 18 LTS..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs
fi

# 4. 安装pnpm
log "📦 安装pnpm..."
if ! command -v pnpm &> /dev/null; then
    npm install -g pnpm
fi

# 5. 创建应用目录
log "📁 创建应用目录..."
APP_DIR="/opt/fengshui-ecommerce"
mkdir -p $APP_DIR
cd $APP_DIR

# 6. 克隆代码
log "📥 克隆代码..."
if [ ! -d "fengshui-ecommerce" ]; then
    git clone https://github.com/safevisa/baijian.git fengshui-ecommerce
fi

cd fengshui-ecommerce

# 7. 安装依赖
log "📦 安装项目依赖..."
pnpm install --frozen-lockfile

# 8. 配置环境变量
log "⚙️ 配置环境变量..."
cat > .env.production << EOF
NODE_ENV=production
NEXT_PUBLIC_BASE_URL=https://jinshiying.com
NEXTAUTH_URL=https://jinshiying.com
NEXTAUTH_SECRET=$(openssl rand -base64 32)
JKOPAY_API_URL=https://gateway.suntone.com/payment/api/gotoPayment
JKOPAY_MERCHANT_ID=1888
JKOPAY_TERMINAL_ID=888506
JKOPAY_SECRET_KEY=fe5b2c5ea084426bb1f6269acbac902f
JKOPAY_RETURN_URL=https://jinshiying.com/payment/return
JKOPAY_NOTIFY_URL=https://jinshiying.com/api/payment/notify
PORT=3000
EOF

# 9. 构建应用
log "🏗️ 构建应用..."
pnpm run build

# 10. 创建数据目录
log "📁 创建数据目录..."
mkdir -p data uploads logs

# 11. 创建systemd服务
log "⚙️ 创建systemd服务..."
cat > /etc/systemd/system/fengshui-app.service << EOF
[Unit]
Description=Fengshui E-commerce Application
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$APP_DIR/fengshui-ecommerce
ExecStart=/usr/bin/pnpm start
Restart=always
RestartSec=10
Environment=NODE_ENV=production
EnvironmentFile=$APP_DIR/fengshui-ecommerce/.env.production
StandardOutput=journal
StandardError=journal

# 资源限制
LimitNOFILE=65535
LimitNPROC=32768

[Install]
WantedBy=multi-user.target
EOF

# 12. 启动应用服务
log "🚀 启动应用服务..."
systemctl daemon-reload
systemctl enable fengshui-app
systemctl start fengshui-app

# 等待应用启动
sleep 15

# 13. 检查应用状态
log "🔍 检查应用状态..."
if systemctl is-active --quiet fengshui-app; then
    success "应用服务运行正常"
else
    warning "应用服务启动失败，查看日志："
    systemctl status fengshui-app --no-pager -l
    exit 1
fi

# 14. 配置Nginx
log "🌐 配置Nginx..."
cat > /etc/nginx/sites-available/jinshiying.com << 'EOF'
# HTTP重定向到HTTPS
server {
    listen 80;
    server_name jinshiying.com www.jinshiying.com 45.77.248.70;
    return 301 https://$server_name$request_uri;
}

# HTTPS配置
server {
    listen 443 ssl http2;
    server_name jinshiying.com www.jinshiying.com 45.77.248.70;

    # SSL证书配置（稍后安装）
    # ssl_certificate /etc/letsencrypt/live/jinshiying.com/fullchain.pem;
    # ssl_certificate_key /etc/letsencrypt/live/jinshiying.com/privkey.pem;

    # 临时自签名证书
    ssl_certificate /etc/ssl/certs/ssl-cert-snakeoil.pem;
    ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;

    # SSL安全配置
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # 安全头
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # 代理到应用
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # 超时设置
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # 静态文件缓存
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        proxy_pass http://127.0.0.1:3000;
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header X-Content-Type-Options nosniff;
    }
    
    # 健康检查
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
EOF

# 启用站点
ln -sf /etc/nginx/sites-available/jinshiying.com /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# 测试Nginx配置
nginx -t

# 重启Nginx
systemctl restart nginx
systemctl enable nginx

# 15. 配置防火墙
log "🔥 配置防火墙..."
ufw --force enable
ufw allow 22
ufw allow 80
ufw allow 443
ufw allow 3000

# 16. 创建管理脚本
log "📊 创建管理脚本..."

# 监控脚本
cat > $APP_DIR/monitor.sh << 'EOF'
#!/bin/bash

echo "=== 风水摆件电商网站状态检查 ==="
echo "时间: $(date)"
echo

echo "=== 应用服务状态 ==="
systemctl status fengshui-app --no-pager -l

echo
echo "=== 应用健康检查 ==="
curl -f http://localhost:3000/api/health || echo "健康检查失败"

echo
echo "=== Nginx状态 ==="
systemctl status nginx --no-pager -l

echo
echo "=== 端口监听 ==="
ss -tlnp | grep -E ':(80|443|3000)'

echo
echo "=== 系统资源 ==="
echo "CPU使用率:"
top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}'

echo "内存使用情况:"
free -h

echo "磁盘使用情况:"
df -h

echo
echo "=== 应用日志（最近10行）==="
journalctl -u fengshui-app -n 10 --no-pager
EOF

# 更新脚本
cat > $APP_DIR/update.sh << 'EOF'
#!/bin/bash

cd /opt/fengshui-ecommerce/fengshui-ecommerce

echo "开始更新应用..."

# 停止服务
systemctl stop fengshui-app

# 拉取最新代码
git pull origin main

# 安装依赖
pnpm install --frozen-lockfile

# 构建应用
pnpm run build

# 启动服务
systemctl start fengshui-app

echo "更新完成！"
EOF

# 备份脚本
cat > $APP_DIR/backup.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="/opt/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

echo "开始备份..."

# 备份应用数据
tar -czf $BACKUP_DIR/app_data_$DATE.tar.gz -C /opt/fengshui-ecommerce/fengshui-ecommerce data uploads

# 备份配置文件
tar -czf $BACKUP_DIR/config_$DATE.tar.gz -C /opt/fengshui-ecommerce/fengshui-ecommerce .env.production

echo "备份完成: $BACKUP_DIR"
ls -la $BACKUP_DIR
EOF

# 日志查看脚本
cat > $APP_DIR/logs.sh << 'EOF'
#!/bin/bash

echo "=== 应用日志 ==="
journalctl -u fengshui-app -f --no-pager
EOF

chmod +x $APP_DIR/*.sh

# 17. 最终检查
log "🔍 最终检查..."
sleep 5

# 检查应用是否运行
if curl -f http://localhost:3000/api/health > /dev/null 2>&1; then
    success "✅ 应用运行正常"
else
    warning "❌ 应用运行异常"
    systemctl status fengshui-app --no-pager -l
fi

# 检查Nginx是否运行
if systemctl is-active --quiet nginx; then
    success "✅ Nginx运行正常"
else
    warning "❌ Nginx运行异常"
fi

# 18. 显示部署信息
echo
success "🎉 部署完成！"
echo
echo "=== 访问信息 ==="
echo "应用地址: https://jinshiying.com"
echo "IP地址: https://45.77.248.70"
echo "健康检查: https://jinshiying.com/api/health"
echo
echo "=== 管理命令 ==="
echo "查看状态: $APP_DIR/monitor.sh"
echo "查看日志: $APP_DIR/logs.sh"
echo "更新应用: $APP_DIR/update.sh"
echo "备份数据: $APP_DIR/backup.sh"
echo "重启应用: systemctl restart fengshui-app"
echo "停止应用: systemctl stop fengshui-app"
echo "启动应用: systemctl start fengshui-app"
echo
echo "=== 测试账号 ==="
echo "管理员: admin@jinshiying.com / admin123"
echo "测试用户: test@jinshiying.com / test123"
echo
echo "=== 下一步 ==="
echo "1. 确保域名 jinshiying.com 解析到 45.77.248.70"
echo "2. 运行: certbot --nginx -d jinshiying.com -d www.jinshiying.com"
echo "3. 测试所有功能：登录、注册、支付、收款链接"
echo
echo "=== 系统资源使用 ==="
echo "CPU: $(nproc) 核心"
echo "内存: $(free -h | grep '^Mem:' | awk '{print $2}')"
echo "磁盘: $(df -h / | tail -1 | awk '{print $2}')"
echo
success "部署脚本执行完成！"


