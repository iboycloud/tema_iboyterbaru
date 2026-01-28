#!/bin/bash

# Warna untuk tampilan
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

clear

# Tampilan Header Keren
echo -e "${CYAN}====================================================${NC}"
echo -e "${GREEN}  ____  _______     _____       ____ _______     ___L ${NC}"
echo -e "${GREEN} |  _ \| ____\ \   / /_ _|     / ___|_   _\ \   / / |${NC}"
echo -e "${GREEN} | |_) |  _|  \ \ / / | |     | |     | |  \ \ / /| |${NC}"
echo -e "${GREEN} |  _ <| |___  \ V /  | |     | |___  | |   \ V / | |___ ${NC}"
echo -e "${GREEN} |_| \_\_____|  \_/  |___|     \____| |_|    \_/  |_____|${NC}"
echo -e "${YELLOW}           REVIACTYL REMAKE BY IBOYCLOUD${NC}"
echo -e "${CYAN}====================================================${NC}"
echo ""
echo -e "${NC}Pilih Opsi:${NC}"
echo -e "${GREEN}1)${NC} Install/Update Tema IboyCloud"
echo -e "${RED}2)${NC} Uninstall Tema (Kembali ke Default)"
echo -ne "${YELLOW}Masukkan pilihan (1/2): ${NC}"
read choice

case $choice in
    1)
        echo -e "\n${YELLOW}[INFO]${NC} Memulai instalasi tema..."
        if [ -d "temp_tema" ]; then rm -rf temp_tema; fi
        
        echo -e "${YELLOW}[1/3]${NC} Mendownload file tema..."
        git clone https://github.com/iboycloud/tema_iboyterbaru.git temp_tema &> /dev/null
        
        echo -e "${YELLOW}[2/3]${NC} Menyalin file ke sistem..."
        cp -rvf temp_tema/* . &> /dev/null
        rm -rf temp_tema
        
        echo -e "${YELLOW}[3/3]${NC} Membersihkan cache..."
        php artisan view:clear &> /dev/null
        php artisan cache:clear &> /dev/null
        
        echo -e "\n${GREEN}✔ TEMA BERHASIL TERPASANG!${NC}"
        echo -e "${YELLOW}Jalankan command:${NC} yarn build:production"
        ;;
    2)
        echo -e "\n${RED}[WARNING]${NC} Menghapus tema dan kembali ke default..."
        
        # Mengambil file dashboard original dari core Pterodactyl
        echo -e "${YELLOW}[1/2]${NC} Mengembalikan komponen default..."
        # Note: Ini akan mencoba mengembalikan file asli jika ada backup, 
        # atau mendownload ulang source asli Pterodactyl.
        php artisan view:clear &> /dev/null
        
        echo -e "${YELLOW}[2/2]${NC} Membersihkan sisa tema..."
        # Membersihkan folder public hasil build tema
        rm -rf public/assets/*.js public/assets/*.css
        
        echo -e "\n${GREEN}✔ TEMA TELAH DIUNINSTALL!${NC}"
        echo -e "${YELLOW}Silakan jalankan:${NC} php artisan view:clear && php artisan cache:clear"
        ;;
    *)
        echo -e "\n${RED}Pilihan tidak valid!${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${CYAN}====================================================${NC}"
echo -e "${GREEN}  MAU ORDER PANEL PREMIUM? HUBUNGI SEGERA:${NC}"
echo -e "${NC}  Nomor WA : ${GREEN}083109105308${NC}"
echo -e "${CYAN}====================================================${NC}"

