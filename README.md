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
| 2 | Audira Syifa Amalia Rasyid | 2510512011 | Pembuatan arsip dan kompresi data | [ISI] |
| 3 | Alya Dyah Sari | 2510512036 | Verifikasi integritas data dan checksum | [ISI] |
| 4 | Lucky Ardillah | 2510512029 | Pemulihan data (restore) | [ISI] |
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

sudo git clone https://github.com/likaxheri/kelompok6_5A_SistemOperasi.git /opt/backup-sistem
cd /opt/backup-sistem
sudo mkdir -p dataSumber dataBackup dataUji evidence output readonly

sudo chown -R backupadm:backupgrp .
sudo chown backupop:backupgrp dataBackup dataUji evidence output readonly
sudo chmod 750 . scripts dataSumber output
sudo chmod 770 dataBackup dataUji evidence
sudo chmod 555 readonly
```

Isi `dataSumber/` dengan data dummy:

```bash
echo "isi uji 1" | sudo tee dataSumber/file1.txt
echo "isi uji 2" | sudo tee dataSumber/file2.txt
sudo chown backupadm:backupgrp dataSumber/*
```

Matriks hak akses lengkap ada di laporan bagian 2.3.

## Menjalankan

Semua skrip dijalankan sebagai operator dari dalam `scripts/`, karena jalur antardirektori bersifat relatif.

```bash
sudo -u backupop -i
cd /opt/backup-sistem/scripts

./validasi.sh ../dataSumber ../dataBackup
echo $?
```

Exit status `validasi.sh`: `0` valid, `1` parameter tidak lengkap, `2` sumber tidak ditemukan atau bukan direktori, `3` direktori tujuan tidak dapat ditulis.

**[ISI oleh anggota lain: cara menjalankan backup, verifikasi, restore, dan locking]**

## Pengujian

Kasus uji validasi (Anggota 1), dijalankan sebagai `backupop` dari `scripts/`:

| ID | Perintah | Hasil diharapkan |
| :---- | :---- | :---- |
| KU-1.1 | `./validasi.sh` | Pesan parameter tidak lengkap, exit 1 |
| KU-1.2 | `./validasi.sh ../apAya ../dataBackup` | Sumber tidak ditemukan, exit 2 |
| KU-1.3 | `./validasi.sh ../dataSumber ../readonly` | Tujuan read-only ditolak, exit 3 |
| KU-1.4 | `./validasi.sh ../dataSumber ../dataBackup` | Validasi berhasil, exit 0 |

Log tersimpan di `evidence/validasi.log`. Langkah dan bukti kasus uji lain ada di `tests/` dan `evidence/`.

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
