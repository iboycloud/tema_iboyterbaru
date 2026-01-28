#!/bin/bash
# Smart Installer - Auto Fix & Theme Reset

echo "--- [1/5] Sinkronisasi File Tema ---"
# Cek apakah folder adalah repository git
if [ ! -d ".git" ]; then
    echo "Mendeteksi folder bukan repo git. Menghubungkan ke GitHub..."
    git init
    git remote add origin https://github.com/USERNAME_ABANG/NAMA_REPO.git
fi

# Paksa ganti semua file lama dengan yang baru dari GitHub
git fetch --all
git reset --hard origin/master

echo "--- [2/5] Perbaikan System (Fix Error 127/ENOENT) ---"
# Pastikan npm & cross-env tersedia
npm install -g cross-env
npm install --production
npm install --save-dev webpack-cli
npm link cross-env

echo "--- [3/5] Pembersihan Aset Lama ---"
# Menghapus aset lama agar tidak bentrok
rm -rf public/assets/*.js public/assets/*.css public/assets/*.map

echo "--- [4/5] Memulai Build Tampilan (Wajib Tunggu) ---"
# Proses pembuatan tampilan baru
yarn build:production

echo "--- [5/5] Membersihkan Cache Laravel ---"
# Perintah PHP clear agar tampilan langsung berubah
php artisan view:clear
php artisan cache:clear
php artisan optimize:clear

echo "DONE! Panel sudah bersih dan menggunakan tema baru."
