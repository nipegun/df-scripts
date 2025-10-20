#!/usr/bin/env bash
# Renombra y sube archivos un nivel, limpia archivos 0B y directorios vacíos,
# y finalmente mueve duplicados por SHA1 a ./repetidos.
# Uso:
#   organizar_y_limpiar.sh [/ruta/dir]
#   organizar_y_limpiar.sh --dry-run [/ruta/dir]

set -euo pipefail
IFS=$'\n\t'

vDryRun=0
vDir=""
vSep="_"  # separador entre nombre de carpeta y nombre original

# ---------- utilidades ----------
v_log() { printf '%s\n' "$*" >&2; }

v_abs() { readlink -f -- "$1"; }

v_err() { v_log "Error: $*"; exit 1; }

# genera un nombre único en un directorio insertando _N antes de la extensión
# Uso: v_unique_in_dir <dir> <baseName>
v_unique_in_dir() {
  local vTargetDir="$1" vBaseName="$2"
  local vStem vExt vDotExt
  if [[ "$vBaseName" == .* && "$vBaseName" != *.* ]]; then
    vStem="$vBaseName"; vDotExt=""
  else
    vStem="${vBaseName%.*}"; vExt="${vBaseName##*.}"
    if [[ "$vStem" == "$vBaseName" ]]; then vDotExt=""; else vDotExt=".$vExt"; fi
  fi
  local vCandidate="$vBaseName" vN=1
  while [[ -e "$vTargetDir/$vCandidate" ]]; do
    vCandidate="${vStem}_${vN}${vDotExt}"
    ((vN++))
  done
  printf '%s' "$vCandidate"
}

# ---------- argumentos ----------
if [[ "${1:-}" == "--dry-run" ]]; then
  vDryRun=1; shift
fi
[[ "${1:-}" != "" ]] || v_err "Uso: $0 [--dry-run] /ruta/al/directorio"

vDir="$(v_abs "$1")"
[[ -d "$vDir" ]] || v_err "'$vDir' no es un directorio"
[[ "$vDir" != "/" ]] || v_err "No se permite operar sobre '/'"

v_log "[*] Directorio objetivo: $vDir"
(( vDryRun )) && v_log "[*] Modo simulación (no se escribe nada)."

# ---------- 1) Renombrar con prefijo y 2) Subir un nivel ----------
v_log "[*] Renombrando y moviendo archivos (prefijo 'carpeta${vSep}nombre')..."
while IFS= read -r -d '' vFile; do
  vParentDir="$(dirname "$vFile")"
  vParentName="$(basename "$vParentDir")"
  vBase="$(basename "$vFile")"
  vPrefix="${vParentName}${vSep}"

  if [[ "$vBase" == "$vPrefix"* ]]; then
    vNewBase="$vBase"
  else
    vNewBase="${vPrefix}${vBase}"
  fi

  vRenamedBase="$(v_unique_in_dir "$vParentDir" "$vNewBase")"
  vRenamedPath="${vParentDir}/${vRenamedBase}"

  vTargetDir="$(dirname "$vParentDir")"
  vFinalBase="$(v_unique_in_dir "$vTargetDir" "$vRenamedBase")"
  vFinalPath="${vTargetDir}/${vFinalBase}"

  if (( vDryRun )); then
    if [[ "$vFile" != "$vRenamedPath" ]]; then
      echo "RENOMBRAR: $vFile -> $vRenamedPath"
    else
      echo "RENOMBRAR: (omitido, ya tiene prefijo) $vFile"
    fi
    echo "MOVER: $vRenamedPath -> $vFinalPath"
  else
    if [[ "$vFile" != "$vRenamedPath" ]]; then
      mv -- "$vFile" "$vRenamedPath"
    fi
    mv -- "$vRenamedPath" "$vFinalPath"
  fi
done < <(find "$vDir" -mindepth 2 -type f -print0)

# ---------- 3) Borrar archivos de 0 bytes ----------
v_log "[*] Borrando archivos de 0 bytes..."
if (( vDryRun )); then
  find "$vDir" -type f -size 0 -print
else
  find "$vDir" -type f -size 0 -print -delete
fi

# ---------- 4) Borrar directorios vacíos ----------
v_log "[*] Borrando directorios vacíos..."
if (( vDryRun )); then
  find "$vDir" -mindepth 1 -depth -type d -empty -print
else
  find "$vDir" -mindepth 1 -depth -type d -empty -print -delete
fi

# ---------- 5) Duplicados por SHA1 -> ./repetidos ----------
v_log "[*] Buscando duplicados por SHA1..."
vDupDir="$vDir/repetidos"
mkdir -p "$vDupDir"

declare -A aHashKeeper=()
declare -a aDupFiles=()

# Recolectar hashes (excluye ./repetidos) y decidir keeper/dups
while IFS= read -r -d '' vFile; do
  # sha1sum devuelve 'hash  ruta'; extraer los primeros 40 chars (hex)
  vOut="$(sha1sum -- "$vFile")" || continue
  vHash="${vOut:0:40}"
  if [[ -z "${aHashKeeper[$vHash]+x}" ]]; then
    aHashKeeper[$vHash]="$vFile"
  else
    aDupFiles+=("$vFile")
  fi
done < <(find "$vDir" \( -path "$vDupDir" -o -path "$vDupDir/*" \) -prune -o -type f -print0)

# Mover duplicados a ./repetidos conservando nombre (si colisiona, añade _N)
for vFile in "${aDupFiles[@]}"; do
  vBase="$(basename "$vFile")"
  vTargetBase="$(v_unique_in_dir "$vDupDir" "$vBase")"
  vTarget="$vDupDir/$vTargetBase"
  if (( vDryRun )); then
    echo "DUPLICADO: $vFile -> $vTarget"
  else
    mv -- "$vFile" "$vTarget"
  fi
done

v_log "[*] Duplicados movidos: ${#aDupFiles[@]}"
v_log "[*] Hecho."
