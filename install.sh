#!/bash
# Script Auto Install & Build Tema IboyCloud

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}=====================================${NC}"
echo -e "${CYAN}   AUTO INSTALL & BUILD IBOYCLOUD   ${NC}"
echo -e "${CYAN}=====================================${NC}"

echo -e "${YELLOW}[1/3] Menarik file terbaru dari GitHub...${NC}"
# Masukkan perintah git pull atau download file di sini
# git pull origin master

echo -e "${YELLOW}[2/3] Memulai Proses Build (yarn build:production)...${NC}"
echo -e "${CYAN}Mohon tunggu, ini butuh waktu 1-2 menit...${NC}"
yarn build:production

echo -e "${YELLOW}[3/3] Membersihkan Cache Sistem...${NC}"
php artisan view:clear
php artisan cache:clear
php artisan config:clear
php artisan optimize:clear

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}  PROSES SELESAI! PANEL SUDAH SIAP  ${NC}"
echo -e "${GREEN}=====================================${NC}"
