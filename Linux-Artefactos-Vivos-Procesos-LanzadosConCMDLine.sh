#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para buscar y mostrar cadenas imprimibles específicas en todos los archivos del sistema Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Linux-Artefactos-Vivos-Procesos-LanzadosConCMDLine.sh | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Linux-Artefactos-Vivos-Procesos-LanzadosConCMDLine.sh | sed 's-sudo--g' | bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Linux-Artefactos-Vivos-Procesos-LanzadosConCMDLine.sh | nano -
# ----------

# Definir constantes de color
  cColorAzul='\033[0;34m'
  cColorAzulClaro='\033[1;34m'
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

# Recorrer todo /proc/
  echo ""
  for pid in /proc/[0-9]*; do
    pid_num=${pid##*/}
    cmd=$(tr '\0' ' ' < "$pid/cmdline" 2>/dev/null)
    
    if [[ -n "$cmd" ]]; then
        echo "El proceso $pid_num se ejecutó con: $cmd"
    fi
  done | sort -n -k1,1 | grep -v 'sort -n -k1,1'
  echo ""

