#!/bin/bash

# ==============================================================================
# 		Langkah 1: Validasi Input dan Parameter Backup
# Deskripsi: Memeriksa kelengkapan parameter, keberadaan direktori sumber,
#            serta izin penulisan pada direktori tujuan.
# ==============================================================================

SUMBER="$1"
TUJUAN="$2"

echo "=================================================="
echo "      PROSES VALIDASI PARAMETER & DIREKTORI       "
echo "=================================================="

# 1. VALIDASI PARAMETER (Uji Negatif 1)
# Memeriksa apakah pengguna memberikan 2 argumen (sumber dan tujuan)
if [ -z "$SUMBER" ] || [ -z "$TUJUAN" ]; then
    echo "[ERROR] Parameter tidak lengkap!"
    echo "Penggunaan: $0 <direktori_sumber> <direktori_tujuan>"
    echo "[LOG] Validasi gagal pada $(date) - Parameter kosong." >> ../logs/validasi.log 2>/dev/null
    exit 1 # Exit status status non-zero (gagal)
fi

# 2. VALIDASI DIREKTORI SUMBER (Uji Negatif 2)
# Memeriksa apakah direktori sumber benar-benar ada di sistem berkas
if [ ! -d "$SUMBER" ]; then
    echo "[ERROR] Direktori sumber '$SUMBER' tidak ditemukan atau bukan direktori!"
    echo "[LOG] Validasi gagal pada $(date) - Sumber '$SUMBER' tidak ada." >> ../logs/validasi.log 2>/dev/null
    exit 2 # Exit status non-zero (gagal)
fi

# 3. VALIDASI HAK AKSES PENULISAN TUJUAN
# Memeriksa apakah direktori tujuan bisa ditulis (write permission)
if [ -d "$TUJUAN" ] && [ ! -w "$TUJUAN" ]; then
    echo "[ERROR] Direktori tujuan '$TUJUAN' tidak memiliki izin akses tulis (Read-Only)!"
    echo "[LOG] Validasi gagal pada $(date) - Tujuan '$TUJUAN' read-only." >> ../logs/validasi.log 2>/dev/null
    exit 3 # Exit status non-zero (gagal)
fi

# 4. HASIL VALIDASI SUKSES (Uji Positif)
echo "[SUCCESS] Direktori sumber '$SUMBER' ditemukan."
echo "[SUCCESS] Parameter valid dan siap diproses ke direktori '$TUJUAN'."
echo "[LOG] Validasi berhasil pada $(date) untuk sumber: $SUMBER" >> ../logs/validasi.log 2>/dev/null

exit 0 # Exit status 0 (sukses)
