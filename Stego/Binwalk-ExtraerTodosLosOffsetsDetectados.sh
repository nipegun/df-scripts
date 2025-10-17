#!/bin/bash

# Ejecución remota
#  curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Stego/Binwalk-ExtraerTodosLosOffsetsDetectados.sh | bash -s [Archivo] [CarpetaDeSalida]


vArchivo='/home/nipegun/Descargas/04-ThreatIntel/dollyreturns.png'
vDirSalida='/home/nipegun/Descargas/04-ThreatIntel/extraidos'

mkdir -p "$vDirSalida"

# Obtener offsets
aOffsets=($(binwalk "$vArchivo" | awk 'NR>3 && $1 ~ /^[0-9]+$/ {print $1}'))

# Calcular cantidad de dígitos del último offset
vUltimo=${aOffsets[-1]}
vDigitos=${#vUltimo}

# Agregar tamaño total del archivo como último límite
vTamanoTotal=$(stat -c '%s' "$vArchivo")
aOffsets+=("$vTamanoTotal")

# Extraer bloques
for ((i=0; i<${#aOffsets[@]}-1; i++)); do
  vInicio=${aOffsets[$i]}
  vFin=$(( ${aOffsets[$i+1]} - 1 ))
  vCount=$(( vFin - vInicio + 1 ))
  vInicioFmt=$(printf "%0${vDigitos}d" "$vInicio")
  vFinFmt=$(printf "%0${vDigitos}d" "$vFin")
  vSalida="$vDirSalida/${vInicioFmt}-${vFinFmt}.bin"

  echo "Extrayendo $vSalida ($vCount bytes)"
  dd if="$vArchivo" of="$vSalida" bs=1 skip="$vInicio" count="$vCount" status=none
done

echo
echo "=== Tipos detectados ==="
for vFichero in "$vDirSalida"/*.bin; do
  printf "%-30s → %s\n" "$(basename "$vFichero")" "$(file -b "$vFichero")"
done
echo
echo "Extracción y análisis completados en: $vDirSalida"
