#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para buscar y comparar procesos activos en Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Linux-Artefactos-Vivos-Procesos-Comparar-EnSistema.sh | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Linux-Artefactos-Vivos-Procesos-Comparar-EnSistema.sh | sed 's-sudo--g' | bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Linux-Artefactos-Vivos-Procesos-Comparar-EnSistema.sh | nano -
# ----------

# Definir constantes de color
  cColorAzul='\033[0;34m'
  cColorAzulClaro='\033[1;34m'
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

# ps
  ps aux --forest | tr -s ' ' | cut -d ' ' -f2 | sort -n > /tmp/procesos_ps_aux_forest.txt

# ls /proc/
  sudo ls /proc/ | grep -E '^[0-9]+$' | sort -n > /tmp/procesos_ls_proc.txt

# Comparar
  sdiff /tmp/procesos_ps_aux_forest.txt /tmp/procesos_ls_proc.txt
