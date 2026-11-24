#!/bin/bash
# Membuat direktori uji negatif tanpa izin tulis
mkdir -p readonly
chmod 555 readonly
ls -ld readonly
