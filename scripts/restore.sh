#!/bin/bash
# restore.sh - Pemulihan data dari arsip backup
# Pemakaian: ./restore.sh <arsip> [direktori_tujuan]

ARSIP="$1"
TUJUAN="${2:-../dataUji}"
LOG_FILE="../evidence/restore.log"

# Fungsi pencatatan aktivitas
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$1] $2" >> "$LOG_FILE"
}

error() {
    echo "[ERROR] $2"
    log ERROR "$2"
    exit "$1"
}

# 1. Validasi parameter
if [ -z "$ARSIP" ]; then
    echo "Penggunaan: $0 <arsip> [direktori_tujuan]"
    exit 1
fi

# 2. Validasi keberadaan arsip dan script checksum
if [ ! -f "$ARSIP" ]; then
    error 2 "Arsip '$ARSIP' tidak ditemukan."
fi

if [ ! -f "./checksum.sh" ]; then
    error 2 "checksum.sh tidak ditemukan. Jalankan dari folder scripts/."
fi

mkdir -p ../evidence || exit 3

# 3. Verifikasi checksum sebelum ekstraksi
if ! bash ./checksum.sh verify "$ARSIP"; then
    error 4 "Verifikasi checksum gagal. Restore dibatalkan."
fi

# 4. Periksa struktur arsip
if ! tar -tzf "$ARSIP" > /dev/null 2>&1; then
    error 5 "Arsip rusak atau tidak dapat dibaca."
fi

# Tolak path absolut dan path yang mengandung traversal (..)
if ! tar -tzf "$ARSIP" | awk '
{
    if ($0 ~ /^\//) exit 1
    n = split($0, bagian, "/")
    for (i = 1; i <= n; i++) {
        if (bagian[i] == "..") exit 1
    }
}
'; then
    error 5 "Arsip mengandung path yang tidak aman."
fi

# 5. Pastikan tujuan tidak sama dengan atau mencakup sumber
SUMBER_REAL=$(realpath -m ../dataSumber)
TUJUAN_REAL=$(realpath -m "$TUJUAN")

case "$TUJUAN_REAL/" in
    "$SUMBER_REAL/"*)
        error 3 "Tujuan restore berada di dalam direktori sumber."
        ;;
esac

case "$SUMBER_REAL/" in
    "$TUJUAN_REAL/"*)
        error 3 "Tujuan restore mencakup direktori sumber."
        ;;
esac

# 6. Siapkan direktori tujuan
mkdir -p "$TUJUAN_REAL" || error 3 "Gagal membuat direktori tujuan."

if [ ! -w "$TUJUAN_REAL" ]; then
    error 3 "Direktori tujuan tidak memiliki izin tulis."
fi

if [ -n "$(find "$TUJUAN_REAL" -mindepth 1 -maxdepth 1 -print -quit)" ]; then
    error 3 "Direktori tujuan tidak kosong. Restore dibatalkan."
fi

# 7. Ekstraksi ke direktori sementara
TMP_DIR=$(mktemp -d "${TUJUAN_REAL}.tmp.XXXXXX") ||
    error 5 "Gagal membuat direktori sementara."

trap 'rm -rf "$TMP_DIR"' EXIT

if ! tar -xzf "$ARSIP" -C "$TMP_DIR"; then
    error 5 "Ekstraksi gagal."
fi

# 8. Pindahkan hasil ekstraksi ke tujuan
if ! cp -a "$TMP_DIR/." "$TUJUAN_REAL/"; then
    error 5 "Gagal menyalin hasil pemulihan."
fi

echo "[SUCCESS] Restore berhasil ke: $TUJUAN_REAL"
log SUCCESS "Restore arsip '$ARSIP' berhasil ke '$TUJUAN_REAL'."

exit 0
