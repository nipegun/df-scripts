#!/bin/bash

# Script de NiPeGun para perfilar binarios en Debian
# Requisitos: funcionará con lo que haya instalado; sugiere apt para el resto.
# Uso: ./analizar-binario.sh /ruta/al/binario [outdir]

set -euo pipefail

# ---------------------------
# Convenciones del usuario
# ---------------------------
vScriptName="$(basename "$0")"
vBinPath="${1:-}"
vOutDir="${2:-}"
vNow="$(date +'%Y%m%d-%H%M%S')"

# ---------------------------
# Utilidades
# ---------------------------
fn_uso() {
  echo "Uso: $vScriptName /ruta/al/binario [directorio_salida]"
  exit 1
}

fn_existe() {
  command -v "$1" >/dev/null 2>&1
}

fn_encabezado() {
  echo
  echo "=============================================="
  echo "== $1"
  echo "=============================================="
}

fn_sugerencias_instalacion() {
  echo
  echo "Herramientas faltantes y cómo instalarlas en Debian:"
  for vTool in "${aHerrFaltantes[@]:-}"; do
    case "$vTool" in
      checksec) echo "  sudo apt install checksec" ;;
      radare2)  echo "  sudo apt install radare2" ;;
      binwalk)  echo "  sudo apt install binwalk" ;;
      upx)      echo "  sudo apt install upx-ucl" ;;
      exiftool) echo "  sudo apt install libimage-exiftool-perl" ;;
      gdb)      echo "  sudo apt install gdb" ;;
      strings|readelf|objdump|nm|c++filt|size|strip|ar)
                echo "  sudo apt install binutils" ;;
      file)     echo "  sudo apt install file" ;;
      ldd)      echo "  sudo apt install libc-bin" ;;
      hexdump)  echo "  sudo apt install bsdmainutils || sudo apt install util-linux" ;;
      sha256sum|sha1sum|md5sum)
                echo "  sudo apt install coreutils" ;;
      patchelf) echo "  sudo apt install patchelf" ;;
      rabin2)   echo "  sudo apt install radare2" ;;
      *)        echo "  # $vTool: busca el paquete correspondiente" ;;
    esac
  done
}

# ---------------------------
# Validaciones y salida
# ---------------------------
[[ -n "$vBinPath" ]] || fn_uso
[[ -f "$vBinPath" ]] || { echo "Error: $vBinPath no existe o no es un archivo."; exit 2; }

if [[ -z "${vOutDir}" ]]; then
  vBase="$(basename "$vBinPath")"
  vOutDir="./informe_${vBase}_${vNow}"
fi

mkdir -p "$vOutDir"
vMainReport="$vOutDir/00_informe.txt"
: > "$vMainReport"

# Array de herramientas "deseables"
declare -a aHerrDeseables=(
  file sha256sum sha1sum md5sum
  strings readelf objdump nm c++filt size strip ar
  ldd hexdump patchelf
  checksec radare2 rabin2 binwalk upx exiftool gdb
)

# Detectar faltantes
declare -a aHerrFaltantes=()
for vH in "${aHerrDeseables[@]}"; do
  fn_existe "$vH" || aHerrFaltantes+=("$vH")
done

# ---------------------------
# 1) Datos básicos y hashes
# ---------------------------
fn_encabezado "Datos básicos" | tee -a "$vMainReport"
stat -c 'Ruta: %n%nTamaño: %s bytes%nPermisos: %A (%a)%nUID:GID: %u:%g%nÚltimo cambio: %y' "$vBinPath" | tee -a "$vMainReport"
if fn_existe file; then
  echo -e "\nTipo (file):" | tee -a "$vMainReport"
  file -b "$vBinPath" | tee -a "$vMainReport"
fi

fn_encabezado "Hashes" | tee -a "$vMainReport"
fn_existe sha256sum && sha256sum "$vBinPath" | tee -a "$vMainReport" || true
fn_existe sha1sum   && sha1sum   "$vBinPath" | tee -a "$vMainReport" || true
fn_existe md5sum    && md5sum    "$vBinPath" | tee -a "$vMainReport" || true

# ---------------------------
# 2) Strings (ASCII y UTF-16LE)
# ---------------------------
if fn_existe strings; then
  fn_encabezado "Strings (ASCII, min 6)" | tee -a "$vMainReport"
  strings -n 6 "$vBinPath" | sed -n '1,200p' | tee "$vOutDir/strings_ascii.txt" >/dev/null
  echo "Guardado: $vOutDir/strings_ascii.txt (primeras 200 líneas arriba)" | tee -a "$vMainReport"

  fn_encabezado "Strings (UTF-16LE, min 6)" | tee -a "$vMainReport"
  # -el = little-endian 16-bit
  strings -n 6 -el "$vBinPath" | sed -n '1,200p' | tee "$vOutDir/strings_utf16le.txt" >/dev/null
  echo "Guardado: $vOutDir/strings_utf16le.txt" | tee -a "$vMainReport"
fi

# ---------------------------
# 3) Cabeceras y secciones (ELF/otros)
# ---------------------------
if fn_existe readelf; then
  fn_encabezado "readelf -h (cabecera ELF)" | tee -a "$vMainReport"
  readelf -h "$vBinPath" | tee "$vOutDir/readelf-h.txt" | sed -n '1,80p' >> "$vMainReport"

  fn_encabezado "readelf -l (program headers)" | tee -a "$vMainReport"
  readelf -l "$vBinPath" | tee "$vOutDir/readelf-l.txt" | sed -n '1,120p' >> "$vMainReport"

  fn_encabezado "readelf -S (secciones)" | tee -a "$vMainReport"
  readelf -S "$vBinPath" | tee "$vOutDir/readelf-S.txt" | sed -n '1,120p' >> "$vMainReport"

  fn_encabezado "readelf -d (dynamic)" | tee -a "$vMainReport"
  readelf -d "$vBinPath" | tee "$vOutDir/readelf-d.txt" | sed -n '1,120p' >> "$vMainReport"
fi

# ---------------------------
# 4) Símbolos y tablas
# ---------------------------
if fn_existe nm; then
  fn_encabezado "Símbolos exportados (nm -D --defined-only)" | tee -a "$vMainReport"
  nm -D --defined-only "$vBinPath" 2>/dev/null | tee "$vOutDir/nm-defined.txt" | sed -n '1,200p' >> "$vMainReport" || true
  if fn_existe c++filt; then
    c++filt < "$vOutDir/nm-defined.txt" > "$vOutDir/nm-defined-demangled.txt" || true
    echo "Guardado (demangled): $vOutDir/nm-defined-demangled.txt" | tee -a "$vMainReport"
  fi
fi

if fn_existe objdump; then
  fn_encabezado "objdump -x (headers completos)" | tee -a "$vMainReport"
  objdump -x "$vBinPath" | tee "$vOutDir/objdump-x.txt" | sed -n '1,200p' >> "$vMainReport"
fi

# ---------------------------
# 5) Dependencias y path de carga
# ---------------------------
if fn_existe ldd; then
  fn_encabezado "ldd (librerías dinámicas)" | tee -a "$vMainReport"
  ldd -v "$vBinPath" 2>&1 | tee "$vOutDir/ldd.txt" | sed -n '1,200p' >> "$vMainReport" || true
fi

if fn_existe patchelf; then
  fn_encabezado "RPATH / RUNPATH (patchelf)" | tee -a "$vMainReport"
  echo "RPATH:   $(patchelf --print-rpath "$vBinPath" 2>/dev/null || echo "(no definido)")" | tee -a "$vMainReport"
  echo "RUNPATH: $(patchelf --print-runpath "$vBinPath" 2>/dev/null || echo "(no definido)")" | tee -a "$vMainReport"
fi

# ---------------------------
# 6) Seguridad binaria (checksec)
# ---------------------------
if fn_existe checksec; then
  fn_encabezado "checksec" | tee -a "$vMainReport"
  checksec --file="$vBinPath" | tee "$vOutDir/checksec.txt" >> "$vMainReport" || true
fi

# ---------------------------
# 7) Radare2 (si está)
# ---------------------------
if fn_existe rabin2; then
  fn_encabezado "rabin2 -I (info general)" | tee -a "$vMainReport"
  rabin2 -I "$vBinPath" | tee "$vOutDir/rabin2-I.txt" >> "$vMainReport" || true

  fn_encabezado "rabin2 -z (strings con offsets)" | tee -a "$vMainReport"
  rabin2 -z "$vBinPath" | tee "$vOutDir/rabin2-z.txt" | sed -n '1,200p' >> "$vMainReport" || true
fi

# ---------------------------
# 8) Binwalk (firmware/embebido)
# ---------------------------
if fn_existe binwalk; then
  fn_encabezado "binwalk (firmware/firmas)" | tee -a "$vMainReport"
  binwalk "$vBinPath" | tee "$vOutDir/binwalk.txt" >> "$vMainReport" || true
fi

# ---------------------------
# 9) UPX (detección/ratio)
# ---------------------------
if fn_existe upx; then
  fn_encabezado "UPX (detección de empaquetado)" | tee -a "$vMainReport"
  if upx -t "$vBinPath" >/dev/null 2>&1; then
    echo "Parece un binario UPX. Informe de test:" | tee -a "$vMainReport"
    upx -t "$vBinPath" 2>&1 | tee -a "$vMainReport"
  else
    echo "No parece empaquetado con UPX (o no se pudo probar)." | tee -a "$vMainReport"
  fi
fi

# ---------------------------
# 10) Exiftool (metadatos genéricos)
# ---------------------------
if fn_existe exiftool; then
  fn_encabezado "exiftool (metadatos)" | tee -a "$vMainReport"
  exiftool "$vBinPath" | tee "$vOutDir/exiftool.txt" | sed -n '1,200p' >> "$vMainReport" || true
fi

# ---------------------------
# 11) Muestra hex inicial
# ---------------------------
if fn_existe hexdump; then
  fn_encabezado "Hexdump (primeros 512 bytes)" | tee -a "$vMainReport"
  hexdump -C -n 512 "$vBinPath" | tee "$vOutDir/hexdump_head.txt" >> "$vMainReport"
fi

# ---------------------------
# 12) Tamaño, secciones y stripping
# ---------------------------
if fn_existe size; then
  fn_encabezado "size (tamaños de secciones)" | tee -a "$vMainReport"
  size "$vBinPath" | tee "$vOutDir/size.txt" >> "$vMainReport" || true
fi

if fn_existe strip; then
  fn_encabezado "¿Está strippeado?" | tee -a "$vMainReport"
  if nm -D "$vBinPath" >/dev/null 2>&1; then
    vSymCount="$(nm -D "$vBinPath" 2>/dev/null | wc -l || echo 0)"
    echo "Símbolos dinámicos visibles: $vSymCount (si es 0 probablemente esté strippeado)" | tee -a "$vMainReport"
  else
    echo "No se pudo determinar con nm." | tee -a "$vMainReport"
  fi
fi

# ---------------------------
# 13) GDB (sin ejecutar, info de archivo)
# ---------------------------
if fn_existe gdb; then
  fn_encabezado "GDB (info files, sin ejecutar)" | tee -a "$vMainReport"
  gdb -q -nx -batch -ex "set pagination off" -ex "info files" --args "$vBinPath" 2>&1 | tee "$vOutDir/gdb-info-files.txt" | sed -n '1,200p' >> "$vMainReport" || true
fi

# ---------------------------
# 14) Resumen final
# ---------------------------
fn_encabezado "Resumen y artefactos" | tee -a "$vMainReport"
echo "Directorio de salida: $vOutDir" | tee -a "$vMainReport"

if ((${#aHerrFaltantes[@]:-0} > 0)); then
  fn_sugerencias_instalacion | tee -a "$vMainReport"
fi

echo
echo "Análisis completado."
