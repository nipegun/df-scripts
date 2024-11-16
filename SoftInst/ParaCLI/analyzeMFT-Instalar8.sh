#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar analyzeMFT en Debian
#
# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/analyzeMFT-Instalar.sh | bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/analyzeMFT-Instalar.sh | nano -
# ----------

# Definir constantes de color
  cColorAzul="\033[0;34m"
  cColorAzulClaro="\033[1;34m"
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

# Determinar la versión de Debian
  if [ -f /etc/os-release ]; then             # Para systemd y freedesktop.org.
    . /etc/os-release
    cNomSO=$NAME
    cVerSO=$VERSION_ID
  elif type lsb_release >/dev/null 2>&1; then # Para linuxbase.org.
    cNomSO=$(lsb_release -si)
    cVerSO=$(lsb_release -sr)
  elif [ -f /etc/lsb-release ]; then          # Para algunas versiones de Debian sin el comando lsb_release.
    . /etc/lsb-release
    cNomSO=$DISTRIB_ID
    cVerSO=$DISTRIB_RELEASE
  elif [ -f /etc/debian_version ]; then       # Para versiones viejas de Debian.
    cNomSO=Debian
    cVerSO=$(cat /etc/debian_version)
  else                                        # Para el viejo uname (También funciona para BSD).
    cNomSO=$(uname -s)
    cVerSO=$(uname -r)
  fi

# Ejecutar comandos dependiendo de la versión de Debian detectada

  if [ $cVerSO == "13" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de analyzeMFT para Debian 13 (x)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 13 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "12" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de analyzeMFT para Debian 12 (Bookworm)...${cFinColor}"
    echo ""
    # Determinar la última versión de AnalyzeMFT
      # Comprobar si el paquete curl está instalado. Si no lo está, instalarlo.
        if [[ $(dpkg-query -s curl 2>/dev/null | grep installed) == "" ]]; then
          echo ""
          echo -e "${cColorRojo}    El paquete curl no está instalado. Iniciando su instalación...${cFinColor}"
          echo ""
          sudo apt-get -y update && sudo apt-get -y install curl
          echo ""
        fi
      vUltVers=$(curl -sL https://github.com/rowingdude/analyzeMFT/releases/latest/ | sed 's|/tag/|\n|g' | grep ^v[0-9] | head -n1 | cut -d'"' -f1 | cut -d'v' -f2)
      echo ""
      echo "    La última versión de analyzemft disponible para instalar es la $vUltVers"
      echo ""
    rm -rf ~/SoftInst/analyzeMFT/*  2> /dev/null
    mkdir -p ~/SoftInst/analyzeMFT/ 2> /dev/null
    # Decargar
      echo ""
      echo "    Descargando ..."
      echo ""
      curl -L https://github.com/rowingdude/analyzeMFT/archive/refs/tags/v$vUltVers.tar.gz -o ~/SoftInst/analyzeMFT/analyzeMFT.tar.gz
    # Descomprimir
      echo ""
      echo "    Descomprimiendo..."
      echo ""
      tar -xzf ~/SoftInst/analyzeMFT/analyzeMFT.tar.gz -C ~/SoftInst/analyzeMFT/
      #mv ~/SoftInst/analyzeMFT/analyzeMFT-$vUltVers/* ~/SoftInst/analyzeMFT/
      #rm -rf ~/SoftInst/analyzeMFT/analyzeMFT-$vUltVers/
      #rm -f  ~/SoftInst/analyzeMFT/analyzeMFT.tar.gz
      chmod 755 ~/SoftInst/analyzeMFT/analyzeMFT-$vUltVers/
    # Crear el virtual environment
      echo ""
      echo "    Creando el virtual environment de python..."
      echo ""
      mkdir ~/PythonVirtualEnvironments/ 2> /dev/null
      cd ~/PythonVirtualEnvironments/
      # Comprobar si el paquete python3 está instalado. Si no lo está, instalarlo.
        if [[ $(dpkg-query -s python3 2>/dev/null | grep installed) == "" ]]; then
          echo ""
          echo -e "${cColorRojo}  El paquete python3 no está instalado. Iniciando su instalación...${cFinColor}"
          echo ""
          sudo apt-get -y update && sudo apt-get -y install python3
          echo ""
        fi
      # Comprobar si el paquete python3-venv está instalado. Si no lo está, instalarlo.
        if [[ $(dpkg-query -s python3-venv 2>/dev/null | grep installed) == "" ]]; then
          echo ""
          echo -e "${cColorRojo}  El paquete python3-venv no está instalado. Iniciando su instalación...${cFinColor}"
          echo ""
          sudo apt-get -y update && sudo apt-get -y install python3-venv
          echo ""
        fi
      python3 -m venv analyzemft
      source analyzemft/bin/activate

    # Compilar el script
      cd ~/SoftInst/analyzeMFT/analyzeMFT-$vUltVers/
      # Comprobar si el paquete python3-pip está instalado. Si no lo está, instalarlo.
        if [[ $(dpkg-query -s python3-pip 2>/dev/null | grep installed) == "" ]]; then
          echo ""
          echo -e "${cColorRojo}  El paquete python3-pip no está instalado. Iniciando su instalación...${cFinColor}"
          echo ""
          sudo apt-get -y update && sudo apt-get -y install python3-pip
          echo ""
        fi
      pip install .
      pip install pyinstaller

      echo ""
      echo "    Compilando el script"
      echo ""
      pyinstaller --onefile analyzemft

    # Copiar el binario a /usr/bin
      sudo cp -f ~/SoftInst/analyzeMFT/analyzeMFT-$vUltVers/dist/analyzemft /usr/bin/

    # Desactivar el entorno virtual
      deactivate

    # Notificar fin de ejecución del script
      echo ""
      echo "  analyzeMFT se ha descargado, compilado e instalado."
      echo "    Puedes encontrar el binario en /usr/bin/analyzemft."  
      echo ""
  
  elif [ $cVerSO == "11" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de analyzeMFT para Debian 11 (Bullseye)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 11 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "10" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de analyzeMFT para Debian 10 (Buster)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 10 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "9" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de analyzeMFT para Debian 9 (Stretch)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 9 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "8" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de analyzeMFT para Debian 8 (Jessie)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 8 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "7" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de analyzeMFT para Debian 7 (Wheezy)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 7 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  fi
