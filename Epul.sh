#!/bin/bash

# Menyembunyikan semua output yang mengganggu
exec > /dev/null 2>&1

# Fungsi untuk menampilkan pesan jika perintah berhasil
function success_message {
    echo "$1 berhasil!"
}

# Fungsi untuk menampilkan pesan jika perintah gagal
function error_message {
    echo "$1 gagal! Periksa log untuk detail kesalahan."
    exit 1
}

# Otomasi Dimulai
echo "Otomasi Dimulai"

# Menambahkan Repository Kartolo
REPO="http://kartolo.sby.datautama.net.id/ubuntu/"
if ! grep -q "$REPO" /etc/apt/sources.list; then
    echo "Menambahkan repository Kartolo..."
    cat <<EOF | sudo tee /etc/apt/sources.list > /dev/null
deb ${REPO} focal main restricted universe multiverse
deb ${REPO} focal-updates main restricted universe multiverse
deb ${REPO} focal-security main restricted universe multiverse
deb ${REPO} focal-backports main restricted universe multiverse
deb ${REPO} focal-proposed main restricted universe multiverse
EOF
    success_message "Repository Kartolo ditambahkan"
else
    echo "Repository Kartolo sudah ada, melewatkan."
fi

# Update Paket
echo "Melakukan update paket..."
sudo apt update -y
if [ $? -eq 0 ]; then
    success_message "Update paket"
else
    error_message "Update paket"
fi

# Konfigurasi Netplan
echo "Mengonfigurasi netplan..."
cat <<EOT | sudo tee /etc/netplan/01-netcfg.yaml > /dev/null
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: yes
    eth1:
      dhcp4: no
  vlans:
    eth1.10:
      id: 10
      link: eth1
      addresses:
        - 192.168.20.1/24
EOT

sudo netplan apply
if [ $? -eq 0 ]; then
    success_message "Terapkan konfigurasi netplan"
else
    error_message "Terapkan konfigurasi netplan"
fi

# Instalasi ISC DHCP Server
echo "Menginstal DHCP server..."
sudo apt install -y isc-dhcp-server
if [ $? -eq 0 ]; then
    success_message "Instalasi DHCP server"
else
    error_message " Gagal Instalasi DHCP server"
fi

# Konfigurasi DHCP
echo "Mengonfigurasi DHCP server..."
sudo bash -c 'cat > /etc/dhcp/dhcpd.conf' << EOF
subnet 192.168.20.0 netmask 255.255.255.0 {
  range 192.168.20.2 192.168.20.254;
  option domain-name-servers 8.8.8.8;
  option subnet-mask 255.255.255.0;
  option routers 192.168.20.1;
  option broadcast-address 192.168.20.255;
  default-lease-time 600;
  max-lease-time 7200;
}
EOF

echo 'INTERFACESv4="eth1.10"' | sudo tee /etc/default/isc-dhcp-server > /dev/null
sudo systemctl restart isc-dhcp-server
if [ $? -eq 0 ]; then
    success_message "Restart DHCP server"
else
    error_message "Gagal Restart DHCP server"
fi

# Aktifkan IP Forwarding
echo "Mengaktifkan IP Forwarding..."
sudo sed -i '/^#net.ipv4.ip_forward=1/s/^#//' /etc/sysctl.conf
sudo sysctl -p
if [ $? -eq 0 ]; then
    success_message "Aktifkan IP Forwarding"
else
    error_message "Aktifkan IP Forwarding"
fi

# Konfigurasi Masquerade dengan iptables
echo "Mengonfigurasi masquerade dengan iptables..."
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
if [ $? -eq 0 ]; then
    success_message "Konfigurasi Masquerade"
else
    error_message "Konfigurasi Masquerade"
fi

# Instalasi iptables-persistent
echo "Menginstal iptables-persistent..."
sudo apt install -y iptables-persistent
if [ $? -eq 0 ]; then
    success_message "Instalasi iptables-persistent"
else
    error_message "Instalasi iptables-persistent"
fi

# Menyimpan Konfigurasi iptables
echo "Menyimpan konfigurasi iptables..."
sudo sh -c "iptables-save > /etc/iptables/rules.v4"
sudo sh -c "ip6tables-save > /etc/iptables/rules.v6"
if [ $? -eq 0 ]; then
    success_message "Menyimpan konfigurasi iptables"
else
    error_message "Menyimpan konfigurasi iptables"
fi

# Restart iptables-persistent
echo "Restarting iptables-persistent..."
sudo systemctl restart netfilter-persistent
if [ $? -eq 0 ]; then
    success_message "Restart netfilter-persistent"
else
    error_message "Restart netfilter-persistent"
fi

# Instalasi Netmiko
echo "Menginstal Netmiko..."
sudo apt install -y python3 python3-pip
pip3 install netmiko
if [ $? -eq 0 ]; then
    success_message "Instalasi Netmiko"
else
    error_message "Instalasi Netmiko"
fi

# Selesai
echo "Otomasi Selesai"
