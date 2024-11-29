import telnetlib
import time
import logging

# Konfigurasi logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[logging.StreamHandler()]
)

# Konfigurasi koneksi
DEVICE_IP = "192.168.234.132"
PORT = 30013
USERNAME = "cisco"
PASSWORD = "cisco"

# Fungsi mengirim perintah
def send_command(tn, command, sleep_time=1):
    try:
        tn.write(command.encode("ascii") + b"\n")
        time.sleep(sleep_time)
        output = tn.read_very_eager().decode("ascii")
        logging.info(f"Perintah '{command}' dijalankan dengan keluaran:\n{output}")
        return output
    except Exception as e:
        logging.error(f"Gagal mengirim perintah '{command}': {e}")
        raise

# Fungsi utama untuk konfigurasi perangkat
def configure_device():
    try:
        logging.info(f"Membuka koneksi ke {DEVICE_IP}:{PORT}...")
        tn = telnetlib.Telnet(DEVICE_IP, PORT, timeout=10)
        logging.info("Koneksi berhasil.")

        # Login ke perangkat
        logging.info("Proses login...")
        tn.read_until(b"Username: ")
        tn.write(USERNAME.encode("ascii") + b"\n")
        tn.read_until(b"Password: ")
        tn.write(PASSWORD.encode("ascii") + b"\n")
        time.sleep(1)

        # Masuk ke mode konfigurasi
        logging.info("Masuk ke mode konfigurasi...")
        send_command(tn, "enable")
        send_command(tn, PASSWORD)  # Enable password
        send_command(tn, "configure terminal")

        # Konfigurasi VLAN dan interface
        logging.info("Konfigurasi VLAN 10...")
        send_command(tn, "vlan 10")
        send_command(tn, "name VLAN10")

        logging.info("Konfigurasi interface ethernet0/1...")
        send_command(tn, "interface ethernet0/1")
        send_command(tn, "switchport mode access")
        send_command(tn, "switchport access vlan 10")
        send_command(tn, "exit")

        # Simpan konfigurasi
        logging.info("Menyimpan konfigurasi...")
        send_command(tn, "write memory")
        logging.info("Konfigurasi selesai.")

        # Menutup koneksi
        tn.close()
        logging.info("Koneksi ditutup.")
    except telnetlib.socket.timeout as e:
        logging.error(f"Koneksi ke {DEVICE_IP}:{PORT} gagal: Timeout. Pastikan perangkat aktif dan dapat diakses.")
    except telnetlib.socket.error as e:
        logging.error(f"Koneksi ke {DEVICE_IP}:{PORT} gagal: {e}")
    except Exception as e:
        logging.error(f"Terjadi kesalahan: {e}")

# Eksekusi fungsi utama
if __name__ == "__main__":
    configure_device()
