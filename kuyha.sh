#!/bin/bash

# Warna untuk output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # Reset warna

# Fungsi untuk menampilkan pesan sukses
function success_message {
    echo -e "${GREEN}$1 berhasil!${NC}"
}

# Fungsi untuk menampilkan pesan gagal
function error_message {
    echo -e "${RED}$1 gagal!${NC}"
    exit 1
}

# Menentukan IP dan Port
CISCO_IP="192.168.234.132"
CISCO_PORT="30013"

# Mengecek apakah `expect` terinstal
if ! command -v expect &> /dev/null; then
    error_message "Expect tidak terpasang. Instal dengan: sudo apt install expect"
fi

# Menghubungkan ke Cisco Device melalui Telnet menggunakan expect
echo "Menghubungkan ke Cisco Device melalui Telnet..."

expect <<EOF
# Mengatur timeout untuk seluruh operasi expect
set timeout 20

# Memulai koneksi Telnet
spawn telnet $CISCO_IP $CISCO_PORT

# Menunggu prompt ">"
expect ">" {
    send "enable\r"
} timeout {
    puts "Gagal terhubung ke perangkat. Periksa IP dan Port."
    exit 1
}

# Masuk ke mode enable, tunggu prompt "#"
expect "#" {
    send "configure terminal\r"
} timeout {
    puts "Gagal masuk ke mode enable. Periksa kredensial atau otorisasi."
    exit 1
}

# Masuk ke mode konfigurasi, tunggu prompt "(config)#"
expect "(config)#" {
    send "interface eth0\r"
} timeout {
    puts "Gagal masuk ke mode konfigurasi interface. Periksa koneksi."
    exit 1
}

# Mengaktifkan interface eth0, tunggu prompt "(config-if)#"
expect "(config-if)#" {
    send "no shutdown\r"
} timeout {
    puts "Gagal mengaktifkan interface. Periksa konfigurasi."
    exit 1
}

# Keluar dari konfigurasi interface
expect "(config-if)#" {
    send "exit\r"
} timeout {
    puts "Gagal keluar dari konfigurasi interface."
    exit 1
}

# Keluar dari konfigurasi terminal
expect "(config)#" {
    send "exit\r"
} timeout {
    puts "Gagal keluar dari mode konfigurasi terminal."
    exit 1
}

# Keluar dari sesi Telnet
expect "#" {
    send "exit\r"
}

# Menutup koneksi setelah selesai
expect eof
EOF

# Periksa status eksekusi expect
if [ $? -eq 0 ]; then
    success_message "Konfigurasi Cisco berhasil diterapkan"
else
    error_message "Proses konfigurasi Cisco gagal"
fi
