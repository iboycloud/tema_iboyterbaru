#!/bin/bash

# Warna tampilan
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}==============================================${NC}"
echo -e "${CYAN}   CLEAN SWEEP INSTALLER - IBOYCLOUD v2      ${NC}"
echo -e "${CYAN}==============================================${NC}"

# 1. Hapus sisa-sisa tema lama & Tarik yang baru
echo -e "${YELLOW}[1/5] Menghapus jejak tema lama & tarik update...${NC}"
# Paksa reset file ke kondisi repo agar tidak ada kode tema lama yang nyangkut
git fetch --all
git reset --hard origin/master || { echo -e "${RED}Gagal reset file!${NC}"; exit 1; }

# 2. Deteksi dan Perbaikan Error (Smart Detection)
echo -e "${YELLOW}[2/5] Mengecek kesehatan sistem (Auto-Fix)...${NC}"

# Fix error 'cross-env: not found'
if ! command -v cross-env &> /dev/null; then
    echo -e "${RED}Error: cross-env hilang. Menginstall...${NC}"
    npm install -g cross-env
fi

# Fix error 'webpack ENOENT'
if [ ! -d "node_modules" ] || [ ! -f "./node_modules/.bin/webpack" ]; then
    echo -e "${RED}Error: node_modules rusak. Membangun ulang library...${NC}"
    npm install --production
    npm install --save-dev webpack-cli
    npm link cross-env
fi

# 3. Hapus Aset Terkompilasi (Force Clean)
echo -e "${YELLOW}[3/5] Membersihkan file tampilan lama di public/assets...${NC}"
# Menghindari error 'cd: can't cd to public/assets' dengan cek folder dulu
if [ -d "public/assets" ]; then
    rm -rf public/assets/*.js public/assets/*.css public/assets/*.map
fi

# 4. Memulai Build Tampilan Baru
echo -e "${YELLOW}[4/5] Memulai Build Tampilan Baru (Tunggu 1-2 menit)...${NC}"
yarn build:production

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Build BERHASIL!${NC}"
else
    echo -e "${RED}Build GAGAL! Mencoba instalasi penuh...${NC}"
    npm install && yarn build:production
fi

# 5. Membersihkan Cache PHP
echo -e "${YELLOW}[5/5] Membersihkan Cache Sistem...${NC}"
php artisan view:clear
php artisan cache:clear
php artisan optimize:clear

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}      TEMA LAMA DIHAPUS, TEMA BARU AKTIF!     ${NC}"
echo -e "${GREEN}==============================================${NC}"
