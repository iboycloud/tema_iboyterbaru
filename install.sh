#!/bin/bash
echo "Memulai instalasi tema iboyterbaru..."
cd /var/www/pterodactyl || exit
# Backup resources asli
tar -czf resources_backup.tar.gz resources/
# Ambil file baru
git clone https://github.com/iboycloud/tema_iboyterbaru.git temp_tema
cp -rf temp_tema/* .
rm -rf temp_tema
# Perbaiki Izin & Cache
chown -R www-data:www-data /var/www/pterodactyl/*
php artisan view:clear
php artisan cache:clear
echo "Selesai! Tema sudah terpasang."

