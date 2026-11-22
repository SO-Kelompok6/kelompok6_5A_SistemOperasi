#!/bin/bash
A="$2"
S="$A.sha256"
[ -f "$A" ] || { echo "Arsip tidak ada: $A"; exit 2; }
case "$1" in
generate)
  sha256sum "$A" > "$S" || exit 2
  echo "Checksum dibuat: $S"; exit 0 ;;
verify)
  [ -f "$S" ] || { echo "File checksum tidak ada"; exit 2; }
  if sha256sum -c "$S"; then echo "HASIL: LULUS"; exit 0
  else echo "HASIL: GAGAL"; exit 1; fi ;;
*) echo "Pakai: $0 generate|verify arsip"; exit 2 ;;
esac
