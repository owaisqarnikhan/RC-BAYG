#!/bin/bash

# Deployment script for RATECARD-FINAL on AWS EC2 Ubuntu
set -e

echo "🚀 Starting RATECARD deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as ubuntu user
if [ "$USER" != "ubuntu" ]; then
    print_error "Please run this script as the ubuntu user"
    exit 1
fi

# Navigate to project directory
cd /var/www/ratecard

print_status "Installing dependencies..."
npm ci

print_status "Building application..."
npm run build

print_status "Setting up database..."
npm run db:push

print_status "Creating necessary directories..."
mkdir -p logs uploads
chmod 755 uploads

print_status "Copying environment file..."
if [ -f ".env.production" ]; then
    cp .env.production .env
else
    print_warning ".env.production not found, using development .env"
fi

print_status "Stopping existing application..."
pm2 delete ratecard-app 2>/dev/null || true

print_status "Starting application with PM2..."
pm2 start ecosystem.config.js --env production

print_status "Saving PM2 configuration..."
pm2 save

print_status "Setting up log rotation..."
sudo bash -c 'cat > /etc/logrotate.d/pm2-ratecard << EOF
/var/www/ratecard/logs/*.log {
    daily
    missingok
    rotate 52
    compress
    notifempty
    create 644 ubuntu ubuntu
    postrotate
        pm2 reload ratecard-app
    endscript
}
EOF'

print_status "Deployment completed successfully! ✅"
print_status "Application is running on: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):5000"
print_status "Check status with: pm2 status"
print_status "View logs with: pm2 logs ratecard-app"

echo ""
echo "🔧 Post-deployment checklist:"
echo "1. Update security group to allow traffic on port 5000"
echo "2. Configure SSL certificate (recommended)"
echo "3. Set up a domain name and DNS"
echo "4. Configure email settings in the admin panel"
echo "5. Update session secret in .env file"
echo ""
