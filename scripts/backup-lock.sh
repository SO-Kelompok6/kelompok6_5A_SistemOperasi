#!/bin/bash

# ==========================================
# BACKUP LOCKING - ANGGOTA 5
# Mencegah proses backup berjalan bersamaan
# ==========================================

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

LOCK_FILE="$PROJECT_DIR/evidence/backup.lock"
LOG_FILE="$PROJECT_DIR/evidence/locking.log"

# Pastikan direktori evidence tersedia
mkdir -p "$PROJECT_DIR/evidence" || exit 1

# Pindah ke folder scripts agar path backup.sh tetap sesuai
cd "$SCRIPT_DIR" || exit 1

# Membuat file lock menggunakan file descriptor 9
exec 9>"$LOCK_FILE"

# Meminta lock tanpa menunggu
if ! flock -n 9; then
    PESAN="[$(date '+%Y-%m-%d %H:%M:%S')] [LOCKED] Backup ditolak karena proses lain sedang berjalan."
    echo "$PESAN" | tee -a "$LOG_FILE"
    exit 6
fi

# Mencatat bahwa proses berhasil memperoleh lock 
PESAN="[$(date '+%Y-%m-%d %H:%M:%S')] [LOCK ACQUIRED] Proses backup dimulai."
echo "$PESAN" | tee -a "$LOG_FILE"

# Menjalankan skrip backup milik anggota sebelumnya
./backup.sh "$@"
STATUS=$?

# Mencatat hasil proses backup
if [ "$STATUS" -eq 0 ]; then
    PESAN="[$(date '+%Y-%m-%d %H:%M:%S')] [SUCCESS] Backup selesai dengan sukses."
else
    PESAN="[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] Backup gagal dengan exit code $STATUS."
fi

echo "$PESAN" | tee -a "$LOG_FILE"

exit "$STATUS"
