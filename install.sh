#!/bin/bash
# Smart Installer v3 - Force Build & Fix ERESOLVE

echo "--- [1/5] Reset & Sinkronisasi File ---"
# Mengatasi 'not a git repository'
if [ ! -d ".git" ]; then
    git init && git remote add origin https://github.com/iboycloud/tema_iboyterbaru.git
fi
git fetch --all && git reset --hard origin/master

echo "--- [2/5] Memperbaiki Dependencies (Sistem Paksa) ---"
# Mengatasi error ERESOLVE dengan legacy-peer-deps
npm install -g cross-env
npm install --production --legacy-peer-deps
npm install --save-dev webpack-cli --legacy-peer-deps

echo "--- [3/5] Pembersihan Aset ---"
# Membuat folder jika tidak ada agar tidak error 'can't cd'
mkdir -p public/assets
rm -rf public/assets/*.js public/assets/*.css

echo "--- [4/5] Memulai Build Dashboard (WAJIB TUNGGU) ---"
# Tanpa ini, dashboard utama tidak akan pernah berubah
yarn build:production

echo "--- [5/5] Membersihkan Cache Akhir ---"
php artisan view:clear && php artisan optimize:clear

echo "DONE! Jika tadi muncul 'Compiled successfully', dashboard sudah berubah."
