#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para sincronizar los df-scripts
#
# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/master/DFScripts-Sincronizar-EnRoot.sh | bash
# ----------

# Definir constantes de color
  cColorAzul="\033[0;34m"
  cColorAzulClaro="\033[1;34m"
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  cFinColor='\033[0m'

# Comprobar si el paquete wget está instalado. Si no lo está, instalarlo.
  if [[ $(dpkg-query -s wget 2>/dev/null | grep installed) == "" ]]; then
    echo ""
    echo -e "${cColorRojo}  El paquete wget no está instalado. Iniciando su instalación...${cFinColor}"
    echo ""
    apt-get -y update
    apt-get -y install wget
    echo ""
  fi

# Comprobar si hay conexión a Internet antes de sincronizar los df-scripts
  wget -q --tries=10 --timeout=20 --spider https://github.com
  if [[ $? -eq 0 ]]; then
    # Sincronizar los df-scripts
      echo ""
      echo -e "${cColorAzulClaro}  Sincronizando los df-scripts con las últimas versiones y descargando nuevos df-scripts (si es que existen)...${cFinColor}"
      echo ""
      rm /root/scripts/df-scripts -R 2> /dev/null
      mkdir /root/scripts 2> /dev/null
      cd /root/scripts
      # Comprobar si el paquete git está instalado. Si no lo está, instalarlo.
        if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
          echo ""
          echo -e "${cColorRojo}    El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
          echo ""
          apt-get -y update
          apt-get -y install git
          echo ""
        fi
      git clone --depth=1 https://github.com/nipegun/df-scripts
      rm /root/scripts/df-scripts/.git -R 2> /dev/null
      find /root/scripts/df-scripts/ -type f -iname "*.sh" -exec chmod +x {} \;
      echo ""
      echo -e "${cColorVerde}    df-scripts sincronizados correctamente.${cFinColor}"
      echo ""
    # Crear los alias
      mkdir -p /root/scripts/df-scripts/Alias/
      /root/scripts/df-scripts/DFScripts-Alias-Crear.sh
      find /root/scripts/df-scripts/Alias -type f -exec chmod +x {} \;
  else
    echo ""
    echo -e "${cColorRojo}  No se pudo iniciar la sincronización de los df-scripts porque no se detectó conexión a Internet.${cFinColor}"
    echo ""
  fi

