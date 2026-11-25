Penjelasan skrip singkat:

#KU 4.1 (Uji Positif: Pemulihan Arsip Valid)
if ! bash scripts/checksum.sh verify "$ARSIP"; then
    error 4 "Verifikasi checksum gagal. Restore dibatalkan."
fi
TMP_DIR=$(mktemp -d "${TUJUAN_REAL}.tmp.XXXXXX") || error 5 "Gagal membuat direktori sementara."
tar -xzf "$ARSIP" -C "$TMP_DIR"
cp -a "$TMP_DIR/." "$TUJUAN_REAL/"
#Memastikan nilai hash SHA-256 arsip cocok sebelum diekstrak. Ekstraksi dilakukan ke direktori sementara (mktemp) untuk menjaga atomisitas, lalu disalin ke tujuan akhir. Mengembalikan exit status 0 dan mencatat [SUCCESS] ke evidence/restore.log.#

#KU 4.2 (Uji Negatif: Arsip Korup / Dimodifikasi)
if ! bash scripts/checksum.sh verify "$ARSIP"; then
    error 4 "Verifikasi checksum gagal. Restore dibatalkan."
fi
#Memanggil skrip checksum.sh milik Anggota 3 untuk mencocokkan hash SHA-256 arsip saat ini dengan file .sha256. Jika ada perubahan isi meski 1 karakter, verifikasi gagal dan proses dibatalkan sebelum menyentuh direktori tujuan dengan exit status 4.#

#KU 4.3 (Uji Negatif: Tujuan Menimpa Direktori Sumber)
SUMBER_REAL=$(realpath -m dataSumber)
TUJUAN_REAL=$(realpath -m "$TUJUAN")
case "$TUJUAN_REAL/" in
    "$SUMBER_REAL/"*) error 3 "Tujuan restore berada di dalam direktori sumber." ;;
esac
#Mengubah jalur relatif menjadi jalur absolut kanonik menggunakan realpath -m agar sistem dapat mendeteksi benturan jalur. Jika tujuan berada di dalam atau mencakup dataSumber asli, skrip menolak eksekusi dengan exit status 3 demi mencegah kerusakan data sumber.#

#KU 4.4 (Uji Negatif: Direktori Tujuan Tidak Kosong)
if [ -n "$(find "$TUJUAN_REAL" -mindepth 1 -maxdepth 1 -print -quit)" ]; then
    error 3 "Direktori tujuan tidak kosong. Restore dibatalkan."
fi
#Memindai isi direktori tujuan pada kedalaman 1 tingkat menggunakan find. Jika ditemukan minimal satu berkas atau subdirektori, proses dibatalkan dengan exit status 3 untuk mencegah penimpaan berkas lama secara tidak sengaja (accidental overwrite).#


#BUKTI KASUS UJI 4.1 HINGGA 4.4

| ID Uji | Nama Skenario | Kondisi Input / Parameter | Ekspektasi Output | Ekspektasi Exit Code |
| :----: | :---- | :---- | :---- | :----: |
| KU-4.1 | Uji Positif: Pemulihan Arsip Valid | `dataBackup/tes_restore.tar.gz` dan `dataUji` (kosong) | Verifikasi SHA-256 lulus dan berkas terekstrak utuh (`[SUCCESS]`) | 0 |
| KU-4.2 | Uji Negatif: Arsip Korup/Rusak | `dataBackup/korup.tar.gz` dan `dataUji` | Verifikasi checksum gagal, ekstraksi dibatalkan (`[ERROR]`) | 4 |
| KU-4.3 | Uji Negatif: Tujuan Menimpa Sumber | `dataBackup/tes_restore.tar.gz` dan `dataSumber` | Proteksi jalur menolak penimpaan direktori sumber (`[ERROR]`) | 3 |
| KU-4.4 | Uji Negatif: Direktori Tujuan Tidak Kosong | `dataBackup/tes_restore.tar.gz` dan `dataUji` (sudah terisi) | Penolakan karena direktori tujuan tidak kosong (`[ERROR]`) | 3 |


#LOG AKTUAL EKSEKUSI (evidence/restore.log)

[2026-11-22 14:52:27] [SUCCESS] Restore arsip 'dataBackup/tes_restore.tar.gz' berhasil ke '/home/lucky/kelompok6_5A_SistemOperasi/dataUji'.
[2026-11-22 16:48:04] [ERROR] Verifikasi checksum gagal. Restore dibatalkan.
[2026-11-23 00:38:53] [ERROR] Arsip 'dataBackup/tes_restore.tar.gz' tidak ditemukan.
[2026-11-23 00:43:38] [ERROR] Tujuan restore berada di dalam direktori sumber.
[2026-11-23 00:45:45] [ERROR] Direktori tujuan tidak kosong. Restore dibatalkan.
