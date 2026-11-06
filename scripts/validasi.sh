
#!/bin/bash

SUMBER="$1"
TUJUAN="$2"

# Lokasi file log otomatis (disimpan di folder logs/ pada direktori utama proyek)
LOG_FILE="../logs/validasi.log"

# Pastikan folder logs/ ada, jika belum ada buat otomatis
mkdir -p ../logs

echo "=================================================="
echo "      PROSES VALIDASI PARAMETER & DIREKTORI       "
echo "=================================================="

# 1. VALIDASI PARAMETER (Uji Negatif 1)
if [ -z "$SUMBER" ] || [ -z "$TUJUAN" ]; then
    echo "[ERROR] Parameter tidak lengkap!"
    echo "Penggunaan: $0 <direktori_sumber> <direktori_tujuan>"
    
    # Catat log kegagalan
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] Validasi gagal - Parameter tidak lengkap/kosong." >> "$LOG_FILE"
    exit 1
fi

# 2. VALIDASI DIREKTORI SUMBER (Uji Negatif 2)
if [ ! -d "$SUMBER" ]; then
    echo "[ERROR] Direktori sumber '$SUMBER' tidak ditemukan atau bukan direktori!"
    
    # Catat log kegagalan
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] Validasi gagal - Sumber '$SUMBER' tidak ditemukan." >> "$LOG_FILE"
    exit 2
fi

# 3. VALIDASI HAK AKSES PENULISAN TUJUAN (Uji Negatif 3)
if [ -d "$TUJUAN" ] && [ ! -w "$TUJUAN" ]; then
    echo "[ERROR] Direktori tujuan '$TUJUAN' tidak memiliki izin akses tulis (Read-Only)!"
    
    # Catat log kegagalan
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] Validasi gagal - Tujuan '$TUJUAN' Read-Only." >> "$LOG_FILE"
    exit 3
fi

# 4. HASIL VALIDASI SUKSES (Uji Positif)
echo "[SUCCESS] Direktori sumber '$SUMBER' ditemukan."
echo "[SUCCESS] Parameter valid dan siap diproses ke direktori '$TUJUAN'."

# Catat log keberhasilan
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SUCCESS] Validasi berhasil untuk Sumber: '$SUMBER' | Tujuan: '$TUJUAN'" >> "$LOG_FILE"

exit 0
