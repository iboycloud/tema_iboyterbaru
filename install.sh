#!/bin/bash
# Script Gabungan: Fix Error, Build, & Clear Cache PHP

echo "--- [1/4] Menarik Update Terbaru dari GitHub ---"
# Jika di VPS bukan git repo, script akan tetap lanjut
git pull origin master || echo "Bukan git repository, melewati pull..."

echo "--- [2/4] Memperbaiki Komponen (Fix Cross-Env & Webpack) ---"
# Mengatasi error 'cross-env: not found'
npm install -g cross-env
# Mengatasi error 'spawn ENOENT' dengan paksa
npm install --production --force
npm link cross-env

echo "--- [3/4] Memulai Proses Build Tampilan (Wajib Tunggu) ---"
# Menghapus aset lama agar build baru bersih
rm -rf public/assets/*.js public/assets/*.css public/assets/*.map
yarn build:production

echo "--- [4/4] Membersihkan Cache PHP (Artisan Clear) ---"
# Ini adalah daftar perintah clear PHP yang tadi Anda tanyakan
php artisan view:clear
php artisan cache:clear
php artisan config:clear
php artisan optimize:clear

echo "=========================================="
echo "   DONE! PROSES SELESAI SECARA TOTAL    "
echo "=========================================="
