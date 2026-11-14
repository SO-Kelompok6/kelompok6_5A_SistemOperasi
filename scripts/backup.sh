#!/bin/bash
# backup.sh - Pembuatan arsip tar.gz berbasis timestamp
# Pemakaian: ./backup.sh <direktori_sumber> <direktori_tujuan>

SUMBER="$1"
TUJUAN="$2"
LOG_FILE="../evidence/backup.log"
mkdir -p ../evidence

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$1] $2" >> "$LOG_FILE"
}

# 1. Validasi dulu lewat validasi.sh (exit code diteruskan)
./validasi.sh "$SUMBER" "$TUJUAN"
RC=$?
if [ $RC -ne 0 ]; then
    echo "[ERROR] Validasi gagal (exit $RC), backup dibatalkan."
    log ERROR "Backup dibatalkan, validasi gagal dengan exit $RC."
    exit $RC
fi

# 2. Pastikan direktori tujuan ada
mkdir -p "$TUJUAN" || {
    echo "[ERROR] Tidak bisa membuat direktori tujuan."
    log ERROR "Gagal membuat direktori tujuan '$TUJUAN'."
    exit 4
}

# 3. Nama arsip berbasis timestamp
TS=$(date '+%Y-%m-%d_%H%M%S')
ARSIP="$TUJUAN/backup_${TS}.tar.gz"

# 4. Buat arsip
if ! tar -czf "$ARSIP" -C "$(dirname "$SUMBER")" "$(basename "$SUMBER")" 2>>"$LOG_FILE"; then
    rm -f "$ARSIP"
    echo "[ERROR] Pembuatan arsip gagal."
    log ERROR "tar gagal membuat '$ARSIP'. Arsip parsial dihapus."
    exit 4
fi

# 5. Cek arsip bisa dibaca
if ! tar -tzf "$ARSIP" > /dev/null 2>&1; then
    rm -f "$ARSIP"
    echo "[ERROR] Arsip tidak bisa dibaca, dihapus."
    log ERROR "Arsip '$ARSIP' gagal diperiksa dan dihapus."
    exit 5
fi

# 6. Atur izin arsip
chmod 640 "$ARSIP"

UKURAN=$(du -h "$ARSIP" | cut -f1)
echo "[SUCCESS] Arsip dibuat: $ARSIP ($UKURAN)"
log SUCCESS "Arsip '$ARSIP' dibuat dari '$SUMBER' ($UKURAN)."
exit 0
