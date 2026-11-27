
# Proyek Akhir Sistem Operasi dan Praktikum Sistem Operasi
## Pilihan 5A – Otomasi Backup dan Pemulihan Data Linux Berbasis Checksum dan Pembatasan Akses Docker

**Program Studi S1 Sistem Informasi**  
**Fakultas Ilmu Komputer**  
**Universitas Pembangunan Nasional "Veteran" Jakarta**  
**Tahun 2026**

**Dosen Pengampu:** Boby Suryo Prakoso, S.T., M.Kom.
---

## 1. Deskripsi Proyek

Proyek ini merancang dan mengimplementasikan sistem otomasi pencadangan (*backup*) dan pemulihan (*restore*) data pada sistem operasi Linux Debian menggunakan skrip Bash.

Sistem dirancang untuk membantu proses pencadangan data agar lebih terstruktur, aman, dan dapat diverifikasi. Proses backup dilengkapi validasi parameter dan direktori sumber, pembuatan arsip terkompresi dengan penamaan berdasarkan timestamp, serta pemeriksaan integritas menggunakan SHA-256.

Selain itu, sistem menerapkan mekanisme pemulihan data ke direktori pengujian, pencegahan eksekusi backup secara bersamaan menggunakan `flock`, pencatatan aktivitas melalui log, dan pembatasan akses laporan menggunakan Docker dengan *read-only bind mount*.

### Tujuan Proyek

1. Melakukan validasi direktori sumber, parameter, dan izin tulis direktori tujuan sebelum backup.
2. Membuat arsip data berformat `.tar.gz` dengan nama berdasarkan timestamp.
3. Memverifikasi integritas arsip menggunakan checksum SHA-256.
4. Memulihkan data secara aman ke direktori pengujian tanpa menimpa direktori sumber.
5. Mencegah proses backup berjalan bersamaan menggunakan mekanisme file locking.
6. Membatasi akses container Docker agar hanya dapat membaca laporan sistem.

---

## 2. Anggota Kelompok dan Kontribusi

| No. | Nama | NIM | Komponen dan Tanggung Jawab |
|---|---|---|---|
| 1 | Dimah Alika Cahyani | 2510512014 | Validasi sumber dan parameter, `validasi.sh` |
| 2 | Audira Syifa Amalia Rasyid | 2510512011 | Pembuatan arsip dan kompresi, `backup.sh` |
| 3 | Alya Dyah Sari | 2510512036 | Verifikasi integritas data, `checksum.sh` |
| 4 | Lucky Ardillah | 2510512029 | Pemulihan data, `restore.sh` |
| 5 | Dinda Azzahra | 2510512035 | Locking, logging, laporan, dan Docker, `backup-lock.sh` |

Seluruh anggota berkontribusi melalui commit dan pull request pada repository utama menggunakan akun GitHub masing-masing.

Riwayat kontribusi dapat dilihat melalui:
[Riwayat Commit Repository Kelompok](https://github.com/SO-Kelompok6/kelompok6_5A_SistemOperasi/commits/main/)

---

## 3. Lingkungan Implementasi

Implementasi dan pengujian sistem dilakukan pada lingkungan berikut.

| Komponen | Spesifikasi |
|---|---|
| Sistem Operasi | Debian GNU/Linux 13 (trixie) |
| Virtualisasi | Oracle VirtualBox |
| Prosesor dan RAM | 1 vCPU, 2048 MB |
| Penyimpanan | 20 GB, sistem berkas ext4 |
| Shell | GNU Bash 5.2.37 |
| Utilitas | tar 1.35 |
| Checksum | sha256sum (coreutils 9.7) |
| File Locking | flock (util-linux 2.41.5) |
| Container | Docker 26.1.5+dfsg1 |
| Docker Image | debian:trixie-slim |

---

## 4. Struktur Direktori

Seluruh sistem ditempatkan pada direktori `/opt/backup-sistem`.

```text
/opt/backup-sistem/
├── scripts/
│   ├── validasi.sh
│   ├── backup.sh
│   ├── checksum.sh
│   ├── restore.sh
│   └── backup-lock.sh
│
├── dataSumber/
│   └── file sumber yang akan dicadangkan(dummy)
│
├── dataBackup/
│   └── isi data tidak dicommit
│
├── evidence/
│   ├── validasi.log
│   ├── backup.log
│   ├── restore.log
│   ├── locking.log
│   ├── KasusUji1.log
│   ├── KasusUji2.log
│   └── KasusUji3.txt
│
├── output/
│   └── laporan.txt
│
└── readonly/
    └── direktori pengujian tanpa izin tulis(dummy)
```

### Fungsi Direktori

| Direktori | Fungsi |
|---|---|
| `scripts/` | Menyimpan seluruh skrip Bash proyek |
| `dataSumber/` | Menyimpan data asli yang akan dicadangkan |
| `dataBackup/` | Menyimpan arsip backup dan berkas checksum |
| `dataUji/` | Menjadi tujuan pemulihan data |
| `evidence/` | Menyimpan log aktivitas dan bukti pengujian |
| `output/` | Menyimpan laporan sistem yang dibaca container Docker |
| `readonly/` | Menjadi direktori pengujian tanpa izin tulis |

---

## 5. Pengguna, Grup, dan Hak Akses

Sistem menggunakan satu grup bernama `backupgrp` dengan dua akun utama.

| Akun | Peran | Tugas |
|---|---|---|
| `backupadm` | Admin | Mengelola konfigurasi, user, group, perizinan, dan direktori sistem |
| `backupop` | Operator | Menjalankan skrip backup, verifikasi checksum, dan restore |
| Container Docker | Pembaca | Membaca laporan melalui bind mount read-only |

### Konfigurasi Hak Akses

| Direktori | Pemilik:Grup | Mode | Admin | Operator |
|---|---|---|---|---|
| `/opt/backup-sistem` | backupadm:backupgrp | 750 | rwx | r-x |
| `scripts/` | backupadm:backupgrp | 750 | rwx | r-x |
| `dataSumber/` | backupadm:backupgrp | 750 | rwx | r-x |
| `dataBackup/` | backupop:backupgrp | 770 | rwx | rwx |
| `dataUji/` | backupop:backupgrp | 770 | rwx | rwx |
| `evidence/` | backupop:backupgrp | 770 | rwx | rwx |
| `output/` | backupop:backupgrp | 750 | r-x | rwx |
| `readonly/` | backupop:backupgrp | 555 | r-x | r-x |

Arsip hasil backup diatur menggunakan mode `640`, sehingga pemilik dapat membaca dan menulis, anggota grup hanya dapat membaca, dan pihak lain tidak memiliki akses.

---

## 6. Komponen dan Fungsi Skrip

Sistem terdiri dari lima skrip Bash yang saling terhubung melalui exit status.

| Skrip | Fungsi | Exit Status |
|---|---|---|
| `validasi.sh` | Memeriksa parameter, direktori sumber, dan izin tulis tujuan. Hasil validasi dicatat ke `validasi.log`. | 0, 1, 2, 3 |
| `backup.sh` | Memanggil validasi, membuat arsip `.tar.gz` bertimestamp, menguji keterbacaan arsip, dan mengatur izin menjadi 640. | 0, 4, 5, atau status validasi |
| `checksum.sh` | Membuat checksum SHA-256 melalui mode `generate` dan memeriksa integritas melalui mode `verify`. | 0, 1, 2 |
| `restore.sh` | Memverifikasi checksum, memeriksa keamanan path, dan memulihkan data secara atomik ke `dataUji/`. | 0 sampai 5 |
| `backup-lock.sh` | Menggunakan `flock -n` untuk mencegah backup berjalan bersamaan, memanggil `backup.sh`, dan mencatat aktivitas ke `locking.log`. | 6 jika lock digunakan, selain itu mengikuti status `backup.sh` |

### Penjelasan Exit Status

**validasi.sh**
- `0` – Validasi berhasil.
- `1` – Parameter kosong atau tidak lengkap.
- `2` – Direktori sumber tidak ditemukan atau bukan direktori.
- `3` – Direktori tujuan tidak memiliki izin tulis.

**backup.sh**
- `0` – Backup berhasil.
- `1`, `2`, `3` – Meneruskan exit status dari `validasi.sh`.
- `4` – Gagal membuat direktori tujuan atau proses `tar` gagal.
- `5` – Arsip gagal dalam pemeriksaan keterbacaan.

**checksum.sh**
- `0` – Proses checksum berhasil atau hash sesuai.
- `1` – Hasil verifikasi checksum tidak sesuai.
- `2` – Terjadi kesalahan penggunaan atau berkas yang diperlukan tidak ditemukan.

**restore.sh**
- `0` – Pemulihan berhasil.
- `1` – Parameter arsip tidak diisi.
- `2` – Arsip atau skrip checksum tidak ditemukan.
- `3` – Tujuan tidak kosong, tidak dapat ditulis, atau berada di dalam direktori sumber.
- `4` – Verifikasi integritas gagal.
- `5` – Arsip tidak terbaca, terdapat path traversal, atau ekstraksi gagal.

**backup-lock.sh**
- `0` – Backup berhasil.
- `6` – Backup ditolak karena proses lain sedang memegang lock.
- Status selain itu mengikuti hasil eksekusi `backup.sh`.

---

## 7. Cara Instalasi dan Konfigurasi

Instalasi dilakukan pada Debian menggunakan akun yang memiliki hak `sudo`.

### 7.1 Membuat Grup dan Pengguna

```bash
sudo groupadd backupgrp

sudo useradd -m -s /bin/bash -G backupgrp backupadm
sudo useradd -m -s /bin/bash -G backupgrp backupop

sudo passwd backupadm
sudo passwd backupop
```

### 7.2 Mengunduh Repository

```bash
sudo git clone https://github.com/SO-Kelompok6/kelompok6_5A_SistemOperasi.git /opt/backup-sistem

cd /opt/backup-sistem
```

### 7.3 Membuat Direktori Sistem

```bash
sudo mkdir -p dataSumber dataBackup dataUji evidence output readonly
```

### 7.4 Mengatur Kepemilikan dan Perizinan

```bash
sudo chown -R backupadm:backupgrp .

sudo chown backupop:backupgrp dataBackup dataUji evidence output readonly

sudo chmod 750 . scripts dataSumber output
sudo chmod 770 dataBackup dataUji evidence
sudo chmod 555 readonly
```

### 7.5 Membuat Data Sumber

```bash
echo 'isi uji 1' | sudo tee dataSumber/file1.txt
echo 'isi uji 2' | sudo tee dataSumber/file2.txt

sudo chown backupadm:backupgrp dataSumber/*
```

Data yang digunakan dalam pengujian merupakan data dummy.

---

## 8. Cara Menjalankan Sistem

Seluruh perintah operasional pada bagian ini dijalankan menggunakan akun `backupop`.

Masuk ke akun operator:

```bash
sudo -u backupop -i
```

### 8.1 Menjalankan Validasi

Masuk ke direktori skrip:

```bash
cd /opt/backup-sistem/scripts
```

Jalankan validasi:

```bash
./validasi.sh ../dataSumber ../dataBackup
echo $?
```

### 8.2 Menjalankan Backup

```bash
./backup-lock.sh ../dataSumber ../dataBackup
```

Sistem akan melakukan validasi terlebih dahulu, kemudian membuat arsip backup apabila seluruh pemeriksaan berhasil.

Format nama arsip:

```text
backup_YYYY-MM-DD_HHMMSS.tar.gz
```

Arsip disimpan di direktori `dataBackup/` dan diatur dengan mode izin `640`.

### 8.3 Membuat dan Memverifikasi Checksum

Kembali ke direktori utama proyek:

```bash
cd /opt/backup-sistem
```

Membuat checksum:

```bash
scripts/checksum.sh generate dataBackup/<nama_arsip>.tar.gz
```

Memverifikasi checksum:

```bash
scripts/checksum.sh verify dataBackup/<nama_arsip>.tar.gz
```

Ganti `<nama_arsip>` dengan nama arsip yang dihasilkan oleh proses backup.

### 8.4 Melakukan Restore

Pastikan direktori `dataUji/` kosong sebelum melakukan pemulihan.

```bash
scripts/restore.sh dataBackup/<nama_arsip>.tar.gz dataUji
```

Sistem akan memverifikasi checksum sebelum melakukan ekstraksi. Data dipulihkan ke direktori `dataUji/`, bukan ke direktori sumber.

---

## 9. Logging dan Laporan Sistem

Sistem menggunakan empat berkas log utama yang disimpan di direktori `evidence/`.

| Berkas Log | Fungsi |
|---|---|
| `validasi.log` | Mencatat hasil validasi parameter, sumber, dan tujuan |
| `backup.log` | Mencatat keberhasilan dan kegagalan proses backup |
| `restore.log` | Mencatat aktivitas pemulihan data |
| `locking.log` | Mencatat aktivitas penguncian proses backup |

Setiap aktivitas dicatat menggunakan timestamp untuk memudahkan pemeriksaan dan penelusuran proses.

### Laporan Sistem

Laporan sistem disimpan dalam:

```text
output/laporan.txt
```

Laporan berisi:
- Tanggal pembuatan laporan.
- Status locking.
- Status backup.
- Lima baris terakhir dari log locking.
- Lima baris terakhir dari log backup.

Laporan dibuat menggunakan pengelompokan perintah Bash dan operator `>` sehingga laporan sebelumnya akan ditimpa oleh laporan terbaru.

---

## 10. Implementasi Docker Read-Only

Docker digunakan untuk membuktikan bahwa container hanya dapat membaca laporan sistem tanpa mengubah berkas pada host.

Image yang digunakan:

```text
debian:trixie-slim
```

### 10.1 Pengujian Membaca Laporan

```bash
docker run --rm \
-v /opt/backup-sistem/output:/report:ro \
debian:trixie-slim cat /report/laporan.txt
```

Hasil yang diharapkan:
- Isi laporan berhasil ditampilkan.
- Container memperoleh exit status `0`.

### 10.2 Pengujian Penulisan pada Mount Read-Only

Periksa checksum laporan pada host:

```bash
sha256sum output/laporan.txt
```

Lakukan percobaan menulis dari container:

```bash
docker run --rm \
-v /opt/backup-sistem/output:/report:ro \
debian:trixie-slim \
sh -c 'echo uji perubahan >> /report/laporan.txt'

echo $?
```

Periksa kembali checksum laporan:

```bash
sha256sum output/laporan.txt
```

Hasil yang diharapkan:
- Penulisan ditolak dengan pesan `Read-only file system`.
- Container menghasilkan exit status bukan nol.
- Nilai checksum laporan sebelum dan sesudah pengujian tetap identik.

Penolakan penulisan merupakan keberhasilan pengujian negatif karena container tidak dapat mengubah laporan pada host.

---

## 11. Skenario Pengujian

Pengujian sistem terdiri dari lima skenario dengan total 26 kasus uji positif dan negatif.

| Skenario | Penanggung Jawab | Kasus Uji | Fokus Pengujian |
|---|---|---|---|
| KU-1: Validasi Sumber dan Parameter | Dimah Alika Cahyani | KU-1.1 s.d. KU-1.4 | Parameter kosong, sumber tidak ditemukan, tujuan read-only, dan validasi berhasil |
| KU-2: Pembuatan Arsip Data | Audira Syifa Amalia Rasyid | KU-2.1 s.d. KU-2.4 | Pembuatan arsip, kesesuaian isi, tujuan read-only, dan kegagalan membaca sumber |
| KU-3: Verifikasi Integritas Data | Alya Dyah Sari | KU-3.1 s.d. KU-3.5 | Verifikasi arsip asli, perubahan checksum, arsip asli tetap valid, dan pembatasan akses pengguna |
| KU-4: Pemulihan Data (Restore) | Lucky Ardillah | KU-4.1 s.d. KU-4.4 | Restore berhasil, arsip korup, pencegahan overwrite sumber, dan tujuan tidak kosong |
| KU-5: Locking, Log, Laporan, dan Docker Read-Only | Dinda Azzahra | KU-5.1 s.d. KU-5.9 | Pemeriksaan locking, proses bersamaan, logging, pembuatan laporan, dan pembatasan akses Docker |

### Lokasi Bukti Pengujian

| Skenario | Lokasi Bukti | Isi Bukti |
|---|---|---|
| KU-1 | `evidence/KasusUji1.log` | Hasil validasi dan exit status setiap percobaan |
| KU-2 | `evidence/KasusUji2.log` | Keberhasilan dan kegagalan pembuatan arsip |
| KU-3 | `evidence/KasusUji3.txt` | Hasil verifikasi arsip asli dan salinan |
| KU-4 | `evidence/restore.log` | Catatan keberhasilan dan kegagalan restore |
| KU-5 | `evidence/locking.log`, `evidence/backup.log`, `output/laporan.txt` | Aktivitas locking, backup, dan laporan sistem |

Seluruh pengujian menggunakan data dummy. Penolakan yang sesuai dengan hasil yang diharapkan pada pengujian negatif dinyatakan sebagai pengujian berhasil.

---

## 12. Pembersihan dan Pengembalian Kondisi Awal

Setelah pengujian selesai, kondisi sistem dapat dikembalikan menggunakan perintah berikut:

```bash
sudo chmod 555 /opt/backup-sistem/readonly
sudo chmod 770 /opt/backup-sistem/dataBackup

: > /opt/backup-sistem/evidence/validasi.log

sudo rm -f /opt/backup-sistem/dataBackup/*.tar.gz
sudo rm -f /opt/backup-sistem/dataBackup/*.sha256

sudo rm -rf /opt/backup-sistem/dataUji/*
```

Apabila muncul pesan `Permission denied`, periksa keanggotaan grup menggunakan:

```bash
id backupop
```

Periksa juga kepemilikan dan mode direktori:

```bash
ls -ld /opt/backup-sistem
ls -ld /opt/backup-sistem/dataBackup
```

---

## 13. Keterbatasan Sistem

Sistem masih memiliki beberapa keterbatasan, yaitu:

1. Backup hanya dilakukan secara lokal pada satu server Linux.
2. Sistem menggunakan full backup dan belum mendukung backup inkremental atau diferensial.
3. Arsip belum dilengkapi enkripsi.
4. Validasi belum memeriksa apakah direktori sumber dapat dibaca atau tidak kosong.
5. Mekanisme lock hanya melindungi proses backup melalui `backup-lock.sh`.
6. `restore.sh` dan `checksum.sh generate` belum menggunakan mekanisme lock.
7. Penggunaan jalur relatif menyebabkan skrip harus dijalankan dari direktori kerja yang sesuai.
8. Restore hanya dilakukan ke direktori tujuan yang kosong dan belum mendukung pemulihan satu berkas secara selektif.
9. Docker hanya digunakan untuk membuktikan pembatasan akses baca pada mount laporan.
10. Sistem belum memiliki penjadwalan otomatis dan backup ke server jarak jauh.

Pengembangan selanjutnya dapat mencakup penjadwalan menggunakan cron atau systemd timer, penyimpanan backup di lokasi berbeda, tanda tangan digital, serta fitur restore selektif.

---

## 14. Repository dan Dokumentasi

Repository utama proyek:

[GitHub – SO-Kelompok6/kelompok6_5A_SistemOperasi](https://github.com/SO-Kelompok6/kelompok6_5A_SistemOperasi)

Riwayat perubahan kode:

[Commit Repository](https://github.com/SO-Kelompok6/kelompok6_5A_SistemOperasi/commits/main/)

Dokumentasi lebih lengkap mengenai rancangan, implementasi, analisis konsep sistem operasi, pengujian, dan hasil proyek terdapat pada laporan akhir kelompok.

---

**Proyek Akhir Praktikum Sistem Operasi – Kelompok 6**  
**Program Studi S1 Sistem Informasi**  
**Fakultas Ilmu Komputer – UPN "Veteran" Jakarta**  
**2026**
