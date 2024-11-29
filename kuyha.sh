#!/bin/bash

# Cek apakah expect terpasang
if ! command -v expect &> /dev/null; then
    echo "Expect tidak terpasang. Instal dengan: sudo apt install expect"
    exit 1
fi

# Variabel koneksi
HOST="192.168.234.132"  # IP perangkat Cisco
PORT="30013"            # Port Telnet

# Fungsi konfigurasi Cisco via Telnet
expect -c "
spawn telnet $HOST $PORT
expect \">\" { send \"enable\r\" }
expect \"#\" { send \"configure terminal\r\" }
expect \"(config)#\" { send \"vlan 10\r\" }
expect \"(config-vlan)#\" { send \"name VLAN10\r\" }
expect \"(config-vlan)#\" { send \"exit\r\" }
expect \"(config)#\" { send \"interface ethernet0/1\r\" }
expect \"(config-if)#\" { send \"switchport mode access\r\" }
expect \"(config-if)#\" { send \"switchport access vlan 10\r\" }
expect \"(config-if)#\" { send \"exit\r\" }
expect \"(config)#\" { send \"write memory\r\" }
expect \"#\" { send \"exit\r\" }
expect eof
"

echo "Konfigurasi selesai!"
