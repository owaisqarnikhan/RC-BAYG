module.exports = {
  apps: [{
    name: 'ratecard-app',
    script: 'dist/index.js',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 5000
    },
    env_production: {
      NODE_ENV: 'production',
      PORT: 5000
    },
    log_file: '/var/www/ratecard/logs/combined.log',
    out_file: '/var/www/ratecard/logs/out.log',
    error_file: '/var/www/ratecard/logs/error.log',
    log_date_format: 'YYYY-MM-DD HH:mm Z'
  }]
};
