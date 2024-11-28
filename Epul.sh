#!/bin/bash

# Otomasi Dimulai
echo "Otomasi WaK Dimulai"

# Menambahkan Repository Kartolo
cat <<EOF | sudo tee /etc/apt/sources.list
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-updates main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-security main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-backports main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-proposed main restricted universe multiverse
EOF

# Update Paket
sudo apt update -y

# Konfigurasi Netplan
cat <<EOT | sudo tee /etc/netplan/01-netcfg.yaml
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

# Terapkan Konfigurasi Jaringan
sudo netplan apply

# Instalasi ISC DHCP Server
sudo apt install -y isc-dhcp-server

# Konfigurasi DHCP
sudo bash -c 'cat > /etc/dhcp/dhcpd.conf' << EOF
# Konfigurasi Subnet DHCP
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

# Konfigurasi ISC DHCP Server
echo 'INTERFACESv4="eth1.10"' | sudo tee /etc/default/isc-dhcp-server
sudo systemctl restart isc-dhcp-server

# Aktifkan IP Forwarding
sudo sed -i '/^#net.ipv4.ip_forward=1/s/^#//' /etc/sysctl.conf
sudo sysctl -p

# Konfigurasi Masquerade dengan iptables
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo apt install -y iptables-persistent

# Instalasi Alat Tambahan
sudo apt install -y sshpass python3 python3-pip build-essential libssl-dev libffi-dev python3-dev

# Instalasi Netmiko melalui pip
pip3 install netmiko

# Selesai
echo "Otomasi WaK Selesai"
