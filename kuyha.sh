#!/bin/bash

# Warna Hijau untuk pemberitahuan
GREEN='\033[0;32m'
NC='\033[0m' # Reset warna

# Fungsi untuk menampilkan pesan jika perintah berhasil
function success_message {
    echo -e "${GREEN}$1 berhasil!${NC}"
}

# Fungsi untuk menampilkan pesan jika perintah gagal
function error_message {
    echo "$1 gagal! Periksa log untuk detail kesalahan."
    exit 1
}

# Menentukan IP dan Port
CISCO_IP="192.168.234.132"
CISCO_PORT="30013"

# Mengecek apakah `expect` terinstal
if ! command -v expect &> /dev/null; then
    echo "Expect tidak terpasang. Instal dengan: sudo apt install expect"
    exit 1
fi

# Koneksi menggunakan Telnet dengan `expect`
echo "Menghubungkan ke Cisco Device melalui Telnet..."

expect <<EOF
set timeout 20
spawn telnet $CISCO_IP $CISCO_PORT

# Tunggu sampai prompt muncul
expect ">" {
    send "enable\r"
}

# Tunggu prompt enable
expect "#" {
    send "configure terminal\r"
}

# Tunggu prompt konfigurasi terminal
expect "(config)#" {
    send "interface eth0\r"
}

# Mengubah konfigurasi (contoh: mengaktifkan interface)
expect "(config-if)#" {
    send "no shutdown\r"
}

# Tunggu prompt konfigurasi interface
expect "(config-if)#" {
    send "exit\r"
}

# Keluar dari konfigurasi
expect "(config)#" {
    send "exit\r"
}

# Keluar dari session
expect "#" {
    send "exit\r"
}

EOF

# Jika koneksi berhasil, tampilkan pesan sukses
if [ $? -eq 0 ]; then
    success_message "Konfigurasi Cisco berhasil diterapkan"
else
    error_message "Koneksi ke Cisco gagal"
fi
