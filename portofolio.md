# Portofolio Praktikum Sistem Operasi

## Identitas

- Nama: Dimah Alika Cahyani
- NIM: 2510512014
- Kelompok: 6 (Kelas A)
- Judul proyek: Rancangan dan Implementasi Sistem Otomasi Backup Data Linux Berbasis Checksum dan Pembatasan Akses Docker
- Pilihan proyek: 5A Otomasi Backup dan Pemulihan Data
- Peran: Anggota 1, Validasi Input dan Parameter

## Asal Proyek

Proyek ini dikerjakan secara berkelompok. Repository ini adalah *fork* dari repository utama kelompok:
https://github.com/likaxheri/kelompok6_5A_SistemOperasi

| Nama | NIM | Komponen |
| :---- | :---- | :---- |
| Dimah Alika Cahyani | 2510512014 | Validasi sumber dan parameter |
| Audira Syifa Amalia Rasyid | 2510512011 | [ISI] |
| Lucky Ardillah | 2510512029 | [ISI] |
| Dinda Azzahra | 2510512035 | [ISI] |
| Alya Dyah Sari | 2510512036 | [ISI] |

Proyek ini bukan karya pribadi sepenuhnya. Bagian yang saya kerjakan dijelaskan di bawah.

## Kontribusi Pribadi

**Skrip**
- `scripts/validasi.sh`: memeriksa kelengkapan parameter, keberadaan direktori sumber, dan izin tulis direktori tujuan, dengan exit status 1, 2, 3 dan log ke `evidence/validasi.log`.

**Konfigurasi dan struktur**
- Menyusun struktur direktori, skema user/group (`backupadm`, `backupop`, `backupgrp`), dan matriks hak akses (laporan bagian 2.3).
- Mengubah lokasi log dari `logs/` menjadi `evidence/` dan menyesuaikan skrip.

**Pengujian**
- Skenario Uji 1 (KU-1.1 sampai KU-1.4) beserta bukti log dan screenshot.

**Dokumentasi (laporan)**
- Bagian 1.1, 1.2, 2.1, 2.3, 3.1, 4.1, dan 5.1.

## Bukti Kontribusi

| Pekerjaan | Tautan |
| :---- | :---- |
| `scripts/validasi.sh` | [ISI: link commit] |
| Pindah log ke `evidence/` | [ISI: link commit] |
| Bukti pengujian | [ISI: link commit atau berkas] |
| Commit akhir repository pribadi | [ISI: link commit] |

Cara mengambil link commit: buka tab *Commits* di GitHub, klik commit yang dimaksud, lalu salin URL halaman.

## Skenario Individu: Validasi Sumber dan Parameter

**Tujuan.** Membuktikan bahwa `validasi.sh` menerima input yang valid dan menolak input yang salah dengan pesan jelas dan exit status non-zero sebelum backup berjalan.

**Kondisi awal.** Dijalankan sebagai `backupop` dari `scripts/`. `dataSumber/` berisi berkas dummy, `dataBackup/` dapat ditulis, `readonly/` bermode 555.

| ID | Perintah | Diharapkan | Aktual | Status |
| :---- | :---- | :---- | :---- | :---- |
| KU-1.1 | `./validasi.sh` | exit 1 | exit 1 | Lulus |
| KU-1.2 | `./validasi.sh ../apAya ../dataBackup` | exit 2 | exit 2 | Lulus |
| KU-1.3 | `./validasi.sh ../dataSumber ../readonly` | exit 3 | exit 3 | Lulus |
| KU-1.4 | `./validasi.sh ../dataSumber ../dataBackup` | exit 0 | exit 0 | Lulus |

**Verifikasi.** Exit status dibaca dengan `echo $?` tepat setelah skrip. Log diperiksa dengan `cat ../evidence/validasi.log`. Bukti ada di `evidence/`.

**Pemulihan.** Mengembalikan izin direktori dan mengosongkan log (lihat README bagian Pemulihan).

## Analisis Konsep Sistem Operasi

- **Sistem berkas.** Pemeriksaan `-d` membuat kernel membaca metadata (inode) untuk memastikan jalur ada dan bertipe direktori.
- **Perizinan.** Pemeriksaan `-w` mencocokkan UID dan GID proses dengan pemilik, grup, dan mode pada inode. Pada `readonly/` (mode 555), bit tulis tidak tersedia sehingga skrip menolak. Uji ini harus dijalankan dengan akun biasa karena root melewati pemeriksaan izin.
- **Proses dan exit status.** Proses mengembalikan nilai ke proses induknya (shell), dibaca lewat `$?`. Konvensi 0 untuk sukses dan non-nol untuk gagal memungkinkan skrip backup mengambil keputusan tanpa membaca pesan.
- **Proteksi.** Skema `backupadm` dan `backupop` menerapkan *least privilege*: operator hanya membaca sumber dan menulis ke direktori backup, uji, log, dan output.

Keterbatasan yang saya sadari: skrip belum memeriksa izin baca sumber, sumber kosong, tujuan yang belum ada, dan tujuan di dalam sumber. [ISI: tambahkan pendapatmu soal perbaikannya]

## Kendala dan Penyelesaian

| Kendala | Penyelesaian |
| :---- | :---- |
| Folder `logs/` diubah menjadi `evidence/` dengan `git mv`, tetapi `evidence/` sudah ada sehingga berkas masuk ke `evidence/logs/`. | Memindahkan berkas satu tingkat ke atas dengan `git mv evidence/logs/validasi.log evidence/validasi.log`. |
| Skrip menulis log ke `../logs`, sehingga folder `logs/` terbuat lagi setelah diganti nama. | Mengubah `LOG_FILE` dan `mkdir -p` dengan `sed`, lalu memeriksa dengan `grep`. |
| Kode di laporan rusak setelah ditempel ke Google Docs (huruf kapital, spasi hilang, baris terpotong). | Menempel ulang dari berkas di repository ke blok monospace dan mematikan autokoreksi. |
| `git status` menampilkan `dataBackup/` dan log yang berubah setiap skrip dijalankan. | Menambahkan `dataBackup/` ke `.gitignore` dan hanya meng-commit log hasil uji final. |
| Penggunaan jalur relatif (seperti ../dataSumber atau ../logs/validasi.log) menyebabkan pesan error "File/Directory Not Found" jika skrip dieksekusi dari luar folder scripts/. | Memastikan standar prosedur operasional (SOP) pengujian dijalankan konsisten dari dalam direktori scripts/ (cd ~/kelompok6_5A_SistemOperasi/scripts), atau memanipulasi pathing relatif secara konsisten pada parameter uji. |
| Saat akan mengunggah berkas bukti pengujian log ke repositori GitHub, perintah git add logs/validasi.log mengalami penolakan| |Menggunakan opsi pemaksaan force add pada Git dengan Perintah git add -f logs/validasi.log. Opsi -f membuat Git secara khusus melacak berkas log tersebut tanpa perlu mengubah konfigurasi global .gitignore kelompok.|

## Refleksi

**Yang sudah saya kuasai.** [cara kerja `[ -d ]` dan `[ -w ]`, exit status, dan Git]

**Yang masih perlu saya pelajari.** [Konsep Hak Aksek POSIX dan Perizinan Linux seperti: Mekanisme Opsi Perintah chmod 555 & chown root:root, arti angka 755 (rwxr-xr-x), 664 (rw-rw-r--), dan 555 (r-xr-xr-x) pada matriks perizinan.]

## Sumber dan Atribusi

Proyek dikerjakan berkelompok. Referensi: manual Linux (`man bash`, `man test`, `man chmod`) dan materi kuliah Sistem Operasi. Menggunakan bantuan AI Claude dan Gemini untuk bantuan Koreksi kode perintah dan pencarian teori
