Proyek akhir Sistem Operasi dan Praktikum Sistem Operasi 
(Pilihan 5A: Otomasi Backup dan Pemulihan Data).

Program Studi S1 Sistem Informasi, FIK UPN "Veteran" Jakarta, Semester Ganjil 2026/2027.
Dosen pengampu: Boby Suryo Prakoso S.T., M.Kom

Proyek ini dikerjakan secara berkelompok (Kelompok 6 - beranggotakan 5 orang). Setiap anggota bertanggung jawab atas satu komponen, lihat tabel anggota di bawah.

## Deskripsi

Kumpulan skrip Bash untuk mencadangkan direktori pada Linux dengan alur: validasi sumber dan parameter, pembuatan arsip `tar.gz` bertimestamp, verifikasi integritas dengan SHA256, restore ke direktori uji, locking dengan `flock`, serta pencatatan log dan laporan. Container Docker digunakan hanya untuk membaca laporan melalui bind mount read-only.

## Anggota

| Anggota | Nama | NIM | Komponen | Skrip |
| :---- | :---- | :---- | :---- | :---- |
| 1 | Dimah Alika Cahyani | 2510512014 | Validasi sumber dan parameter | `validasi.sh` |
| 2 | Audira Syifa Amalia Rasyid | 2510512011 | Pembuatan arsip dan kompresi data | `backup.sh` |
| 3 | Alya Dyah Sari | 2510512036 | Verifikasi integritas data dan checksum | `checksum.sh` |
| 4 | Lucky Ardillah | 2510512029 | Pemulihan data (restore) | `restore.sh` |
| 5 | Dinda Azzahra | 2510512035 | Locking, logging, dan aktivitas Docker | [ISI] |

Sesuaikan pembagian komponen dengan matriks kontribusi di laporan (bagian 7.2).

## Lingkungan

| Komponen | Versi |
| :---- | :---- |
| OS | Debian GNU/Linux 13 (trixie), VirtualBox |
| CPU / RAM | 1 vCPU / 2048 MB |
| Sistem berkas | ext4 |
| Bash | 5.2.37 |
| tar | 1.35 |
| sha256sum | coreutils 9.7 |
| flock | util-linux 2.41.5 |
| Docker | 26.1.5+dfsg1 |
| Image Docker | `alpine:` **[ISI: tag yang dipakai]** |

## Struktur Repository

```
scripts/     # skrip Bash proyek
dataSumber/  # data dummy yang dicadangkan (dibuat saat instalasi)
dataBackup/  # arsip .tar.gz dan .sha256 (tidak di-commit)
dataUji/     # tujuan restore (tidak di-commit)
evidence/    # log dan bukti pengujian
output/      # laporan.txt untuk dibaca Docker
readonly/    # direktori uji negatif (dibuat saat instalasi)
tests/       # langkah uji positif/negatif dan data dummy
docs/        # laporan akhir
```

## Instalasi

Jalankan pada Debian/Ubuntu dengan akun yang memiliki `sudo`.

```bash
sudo groupadd backupgrp
sudo useradd -m -s /bin/bash -G backupgrp backupadm
sudo useradd -m -s /bin/bash -G backupgrp backupop
sudo passwd backupadm
sudo passwd backupop

sudo git clone https://github.com/SO-Kelompok6/kelompok6_5A_SistemOperasi.git
cd /opt/backup-sistem
sudo mkdir -p dataSumber dataBackup dataUji evidence output readonly

sudo chown -R backupadm:backupgrp .
sudo chown backupop:backupgrp dataBackup dataUji evidence output readonly
sudo chmod 750 . scripts dataSumber output
sudo chmod 770 dataBackup dataUji evidence
sudo chmod 555 readonly
```

## Pengujian

Seluruh kasus uji dijalankan sebagai `backupop` dari `scripts/`. Detail perintah, langkah, dan bukti tiap kasus ada di `tests/` dan `evidence/`. Log validasi tersimpan di `evidence/validasi.log`.

| Anggota | Komponen | ID Uji | Skenario yang Diuji | Ekspektasi Output | Exit Code | Status |
| :---- | :---- | :----: | :---- | :---- | :----: | :----: |
| Dimah Alika Cahyani (2510512014) | Validasi sumber dan parameter | KU-1.1 s.d. KU-1.4 | Parameter kosong, sumber tidak ada, tujuan read-only (negatif), dan parameter valid (positif) | Pesan error yang jelas untuk tiga uji negatif, pesan sukses untuk uji positif | 1, 2, 3, 0 | Lulus |
| Audira Syifa Amalia Rasyid (2510512011) | Pembuatan arsip | KU-2.1 s.d. KU-2.4 | Arsip terbentuk dan utuh (positif), tujuan read-only dan sumber tidak ada (negatif) | Arsip `.tar.gz` bernama `YYYY-MM-DD_HHMMSS` dengan isi sama seperti sumber, dan penolakan tanpa arsip pada uji negatif | 0, non-zero | Lulus |
| Alya Dyah Sari (2510512036) | Verifikasi integritas checksum | KU-3.1 s.d. KU-3.5 | Arsip asli lolos, salinan yang diubah terdeteksi, arsip asli tetap utuh, akun berhak (`backupop`) dan tidak berhak ditolak | HASIL: LULUS untuk arsip asli, HASIL: GAGAL untuk salinan yang diubah, *Permission denied* untuk akun tidak berhak | 0, 1, non-zero | Lulus |
| Lucky Ardillah (2510512029) | Pemulihan data (restore) | KU-4.1 s.d. KU-4.4 | Restore sukses ke `dataUji` (positif), arsip rusak ditolak dan tujuan sumber asli ditolak (negatif) | Berkas terekstrak sama dengan sumber, dan penolakan tanpa ekstraksi pada uji negatif | 0, 4, 3 | Lulus |
| Dinda Azzahra (2510512035) | Locking, logging, dan Docker | KU-5.1 s.d. KU-5.4 | Docker membaca laporan (positif), Docker menulis ditolak, dua backup bersamaan ditolak `flock`, checksum host tidak berubah | `laporan.txt` terbaca, *Read-only file system* saat menulis, proses kedua ditolak, checksum sebelum dan sesudah sama | 0, non-zero | [ISI] |

Exit status `validasi.sh`: `0` valid, `1` parameter tidak lengkap, `2` sumber tidak ditemukan atau bukan direktori, `3` direktori tujuan tidak dapat ditulis.

## Aktivitas Docker

Container hanya membaca laporan melalui bind mount read-only. Image harus sudah diunduh sebelum demonstrasi.

```bash
docker pull alpine:<tag>

# Positif: membaca laporan, exit status 0
docker run --rm \
  --mount type=bind,src="$(pwd)/output",dst=/data,readonly \
  alpine:<tag> cat /data/laporan.txt

# Negatif: menulis ke mount read-only ditolak, exit status bukan nol
docker run --rm \
  --mount type=bind,src="$(pwd)/output",dst=/data,readonly \
  alpine:<tag> sh -c 'echo "uji perubahan" >> /data/laporan.txt'
echo $?
```

Jalankan dari `/opt/backup-sistem`. Bandingkan checksum `output/laporan.txt` sebelum dan sesudah pengujian untuk membuktikan berkas host tidak berubah.

## Pemulihan dan Pembersihan

Kembalikan kondisi awal setelah pengujian:

```bash
sudo chmod 555 /opt/backup-sistem/readonly
sudo chmod 770 /opt/backup-sistem/dataBackup
: > /opt/backup-sistem/evidence/validasi.log
sudo rm -f /opt/backup-sistem/dataBackup/*.tar.gz /opt/backup-sistem/dataBackup/*.sha256
rm -rf /opt/backup-sistem/dataUji/*
```

Kalau `Permission denied`, periksa keanggotaan grup dengan `id backupop` dan mode direktori dengan `ls -ld`.

## Dokumentasi

Laporan akhir: `docs/` (PDF). Portofolio individu ada di repository pribadi masing-masing anggota (`PORTOFOLIO.md`).

## Catatan

- Seluruh data adalah data dummy. Tidak ada password, token, atau kunci pribadi dalam repository.
- Proyek dikerjakan berkelompok. Kontribusi tiap anggota tercatat pada riwayat commit dan matriks kontribusi di laporan.
