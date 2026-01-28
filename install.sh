#!/bin/bash
# Script Auto Update, Fix Error, & Build IboyCloud

echo "--- [1/4] Menarik file terbaru dari GitHub ---"
git pull origin master

echo "--- [2/4] Memperbaiki Dependencies (Fix Cross-Env & Webpack) ---"
# Menginstall komponen yang hilang berdasarkan error di terminal
npm install -g cross-env
npm install
npm install --save-dev webpack-cli

echo "--- [3/4] Memulai Proses Build ---"
# Menghapus aset lama agar tidak bentrok
rm -rf public/assets/*.js public/assets/*.css public/assets/*.map
yarn build:production

echo "--- [4/4] Membersihkan Cache ---"
php artisan view:clear && php artisan cache:clear
php artisan optimize:clear

echo "=========================================="
echo "DONE! Tampilan sudah diperbarui."
echo "Silakan refresh panel Anda (Gunakan Incognito jika perlu)."
echo "=========================================="
