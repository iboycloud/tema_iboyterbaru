#!/bin/bash

# Reviactyl Auto Installer / Migrator
# Based on https://reviactyl.dev/docs
# Created by Assistant

if [ "$EUID" -ne 0 ]; then
  echo "Harap jalankan script ini sebagai root (sudo su)"
  exit
fi

PANEL_DIR="/var/www/pterodactyl"
BACKUP_DIR="/var/www/pterodactyl_backup_$(date +%F_%H-%M)"

echo "================================================="
echo "       REVIACTYL THEME/PANEL INSTALLER           "
echo "        (         IboyMarketz          )             "
echo "================================================="
echo "1. Migrate/Install Reviactyl (Timpa Pterodactyl)"
echo "   -> Gunakan ini jika Anda sudah punya panel."
echo "   -> Data server aman, hanya UI yang berubah."
echo ""
echo "2. Install Fresh (Baru)"
echo "   -> Untuk VPS kosong."
echo ""
echo "3. Keluar"
echo "================================================="
read -p "Pilih menu (1-3): " MENU

if [ "$MENU" == "3" ]; then
    exit
fi

# ==========================================
# 1. MIGRATE / OVERWRITE
# ==========================================
if [ "$MENU" == "1" ]; then
    if [ ! -d "$PANEL_DIR" ]; then
        echo "Error: Folder $PANEL_DIR tidak ditemukan!"
        echo "Pastikan Pterodactyl sudah terinstall."
        exit 1
    fi

    echo ""
    echo "[!] PERINGATAN: Script ini akan mengubah file inti Panel Anda menjadi Reviactyl."
    echo "[!] Backup otomatis akan dibuat di: $BACKUP_DIR"
    read -p "Yakin ingin melanjutkan? (y/n): " CONFIRM
    if [ "$CONFIRM" != "y" ]; then exit; fi

    echo "[+] Masuk ke direktori panel..."
    cd $PANEL_DIR

    echo "[+] Mengaktifkan Maintenance Mode..."
    php artisan down

    echo "[+] Membuat Backup..."
    mkdir -p $BACKUP_DIR
    # Copy semua kecuali storage dan node_modules agar cepat, tapi kita butuh backup file core
    rsync -av --exclude 'storage' --exclude 'node_modules' $PANEL_DIR/ $BACKUP_DIR/
    echo "Backup selesai."

    echo "[+] Mengunduh Reviactyl Terbaru..."
    curl -Lo panel.tar.gz https://github.com/reviactyl/panel/releases/latest/download/panel.tar.gz

    echo "[+] Mengekstrak file..."
    tar -xzvf panel.tar.gz
    chmod -R 755 storage/* bootstrap/cache/

    echo "[+] Install Dependencies (Composer)..."
    export COMPOSER_ALLOW_SUPERUSER=1
    composer install --no-dev --optimize-autoloader

    echo "[+] Migrasi Database..."
    php artisan migrate --seed --force

    echo "[+] Clear Cache & View..."
    php artisan view:clear
    php artisan config:clear
    php artisan route:clear

    echo "[+] Set Permissions..."
    # Deteksi Webserver User
    if ps aux | grep -q "nginx"; then
        chown -R www-data:www-data $PANEL_DIR/*
    elif ps aux | grep -q "apache"; then
        chown -R www-data:www-data $PANEL_DIR/*
    else
        chown -R www-data:www-data $PANEL_DIR/*
    fi

    echo "[+] Mematikan Maintenance Mode..."
    php artisan up

    echo ""
    echo "================================================="
    echo "✅ MIGRASI SUKSES!"
    echo "Reviactyl Panel telah terinstall."
    echo "Silakan refresh browser Anda."
    echo "================================================="
fi

# ==========================================
# 2. FRESH INSTALL
# ==========================================
if [ "$MENU" == "2" ]; then
    echo ""
    echo "[!] Mode Fresh Install akan menginstall Dependencies & Panel."
    echo "Pastikan VPS Anda masih 'bersih' (Fresh OS)."
    read -p "Lanjutkan? (y/n): " CONFIRM
    if [ "$CONFIRM" != "y" ]; then exit; fi

    # Install Dependencies Dasar
    echo "[+] Update & Install Dependencies..."
    apt update -y
    apt -y install software-properties-common curl apt-transport-https ca-certificates gnupg git unzip tar

    # PHP Setup (Ubuntu Example)
    if [ -f /etc/lsb-release ]; then
        LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
        apt update -y
        apt -y install php8.3 php8.3-{common,cli,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip} mariadb-server nginx redis-server
    else
        echo "Maaf, script fresh install ini dioptimalkan untuk Ubuntu 20.04/22.04."
        echo "Silakan install dependencies manual untuk OS Anda."
        exit
    fi

    # Install Composer
    echo "[+] Install Composer..."
    curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

    # Setup Directory
    echo "[+] Setup Direktori Panel..."
    mkdir -p /var/www/pterodactyl
    cd /var/www/pterodactyl

    echo "[+] Download Reviactyl..."
    curl -Lo panel.tar.gz https://github.com/reviactyl/panel/releases/latest/download/panel.tar.gz
    tar -xzvf panel.tar.gz
    chmod -R 755 storage/* bootstrap/cache/

    # Database Setup
    echo ""
    echo "================================================="
    echo "SETUP DATABASE"
    echo "================================================="
    read -p "Masukkan Password Database Baru (untuk user 'pterodactyl'): " DB_PASS
    
    mysql -u root -e "CREATE USER 'pterodactyl'@'127.0.0.1' IDENTIFIED BY '$DB_PASS';"
    mysql -u root -e "CREATE DATABASE panel;"
    mysql -u root -e "GRANT ALL PRIVILEGES ON panel.* TO 'pterodactyl'@'127.0.0.1' WITH GRANT OPTION;"
    mysql -u root -e "FLUSH PRIVILEGES;"
    
    echo "[+] Konfigurasi .env..."
    cp .env.example .env
    COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader
    php artisan key:generate --force
    
    echo "[!] Silakan konfigurasi Database di .env secara otomatis..."
    # Menggunakan sed untuk edit .env
    sed -i "s/DB_PASSWORD=/DB_PASSWORD=$DB_PASS/" .env
    
    echo "[+] Migrasi Database..."
    php artisan migrate --seed --force

    echo "[+] Create Admin User..."
    php artisan p:user:make

    # Permission
    chown -R www-data:www-data /var/www/pterodactyl/*

    # Nginx Config (Basic)
    read -p "Masukkan Domain Panel (misal: panel.domain.com): " PANEL_DOMAIN
    cat <<EOF > /etc/nginx/sites-available/pterodactyl.conf
server {
    listen 80;
    server_name $PANEL_DOMAIN;
    root /var/www/pterodactyl/public;
    index index.php;

    access_log /var/log/nginx/pterodactyl.app-access.log;
    error_log  /var/log/nginx/pterodactyl.app-error.log error;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size = 100M";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF
    ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/
    systemctl restart nginx
    
    # Setup Queue Worker
    cat <<EOF > /etc/systemd/system/pteroq.service
[Unit]
Description=Pterodactyl Queue Worker
After=redis-server.service

[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/pterodactyl/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3
StartLimitInterval=0

[Install]
WantedBy=multi-user.target
EOF
    systemctl enable --now pteroq.service

    echo ""
    echo "================================================="
    echo "✅ INSTALASI FRESH SELESAI"
    echo "Domain: $PANEL_DOMAIN"
    echo "Silakan setup SSL (Certbot) secara manual jika perlu."
    echo "================================================="
fi
