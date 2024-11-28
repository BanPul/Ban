import telnetlib
import time

# Informasi koneksi
pnet_ip = "192.168.234.132"
port = 30013
username = "cisco"  # Ubah sesuai dengan username perangkat Cisco
password = "cisco"  # Ubah sesuai dengan password perangkat Cisco

# Fungsi untuk mengirim perintah ke perangkat Cisco
def send_command(tn, command, sleep_time=1):
    tn.write(command.encode('ascii') + b"\n")
    time.sleep(sleep_time)
    output = tn.read_very_eager().decode('ascii')
    print(output)
    return output

# Fungsi utama
def configure_device():
    try:
        # Membuka koneksi Telnet
        tn = telnetlib.Telnet(pnet_ip, port, timeout=10)
        print(f"Koneksi berhasil ke {pnet_ip}:{port}")

        # Login ke perangkat
        tn.read_until(b"Username: ")
        tn.write(username.encode('ascii') + b"\n")
        tn.read_until(b"Password: ")
        tn.write(password.encode('ascii') + b"\n")
        time.sleep(1)
        
        # Masuk ke mode konfigurasi
        send_command(tn, "enable")
        send_command(tn, password)  # Password enable jika diminta
        send_command(tn, "configure terminal")
        
        # Konfigurasi VLAN 10
        send_command(tn, "vlan 10")
        send_command(tn, "name VLAN10")
        
        # Konfigurasi interface e0/1
        send_command(tn, "interface ethernet0/1")
        send_command(tn, "switchport mode access")
        send_command(tn, "switchport access vlan 10")
        send_command(tn, "exit")
        
        # Simpan konfigurasi
        send_command(tn, "write memory")
        
        print("Konfigurasi selesai.")
        
        # Menutup koneksi
        tn.close()
    except Exception as e:
        print(f"Terjadi kesalahan: {e}")

# Menjalankan fungsi
if __name__ == "__main__":
    configure_device()
