#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar y configurar Plaso en Debian
#
# Ejecución remota con sudo:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/Plaso-Instalar.sh | sudo bash
#
# Ejecución remota como root:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/Plaso-Instalar.sh | sudo bash
#
# Ejecución remota sin caché:
#   curl -sL -H 'Cache-Control: no-cache, no-store' https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/Plaso-Instalar.sh | bash
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/Plaso-Instalar.sh | bash -s Parámetro1 Parámetro2
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/Plaso-Instalar.sh | nano -
# ----------

# Definir constantes de color
  cColorAzul="\033[0;34m"
  cColorAzulClaro="\033[1;34m"
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

# Comprobar si el script está corriendo como root
  #if [ $(id -u) -ne 0 ]; then     # Sólo comprueba si es root
  if [[ $EUID -ne 0 ]]; then       # Comprueba si es root o sudo
    echo ""
    echo -e "${cColorRojo}  Este script está preparado para ejecutarse con privilegios de administrador (como root o con sudo).${cFinColor}"
    echo ""
    exit
  fi

# Comprobar si el paquete curl está instalado. Si no lo está, instalarlo.
  if [[ $(dpkg-query -s curl 2>/dev/null | grep installed) == "" ]]; then
    echo ""
    echo -e "${cColorRojo}  El paquete curl no está instalado. Iniciando su instalación...${cFinColor}"
    echo ""
    apt-get -y update && apt-get -y install curl
    echo ""
  fi

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
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Plaso para Debian 13 (x)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 13 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "12" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Plaso para Debian 12 (Bookworm)...${cFinColor}"
    echo ""

    # Instalar paquetes necesarios
      echo ""
      echo "    Instalando paquetes necesarios..."
      echo ""
      sudo apt-get -y update
      sudo apt-get -y install python3-pip
      sudo apt-get -y install python3-setuptools
      sudo apt-get -y install python3-dev
      sudo apt-get -y install python3-venv
      sudo apt-get -y install build-essential
      sudo apt-get -y install liblzma-dev

    # Preparar el entorno virtual de python
      echo ""
      echo "    Preparando el entorno virtual de python..."
      echo ""
      mkdir -p ~/PythonVirtualEnvironments/ 2> /dev/null
      cd ~/PythonVirtualEnvironments/
      rm -rf ~/PythonVirtualEnvironments/plaso/
      python3 -m venv plaso

    # Ingresar en el entorno virtual e instalar plaso
      echo ""
      echo "    Ingresando en el entorno virtual e instalando plaso..."
      echo ""
      source ~/PythonVirtualEnvironments/plaso/bin/activate
      pip3 install plaso

    # Compilar los scripts
      echo ""
      echo "    Compilando los scripts..."
      echo ""
      pip install pyinstaller
      cd ~/PythonVirtualEnvironments/plaso/bin/
      echo ""
      echo "      Intentando compilar image_export..."
      echo ""
      pyinstaller --onefile image_export \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_core_location.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_mdns.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_open_directory.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/windows_nt.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/time_zone_information.yaml:plaso/preprocessors" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/mounted_devices.yaml:plaso/preprocessors"
      echo ""
      echo "      Intentando compilar log2timeline..."
      echo ""
      pyinstaller --onefile log2timeline \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_core_location.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_mdns.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_open_directory.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/windows_nt.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/time_zone_information.yaml:plaso/preprocessors" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/mounted_devices.yaml:plaso/preprocessors"
      echo ""
      echo "      Intentando compilar normalizer..."
      echo ""
      pyinstaller --onefile normalizer \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_core_location.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_mdns.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_open_directory.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/windows_nt.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/time_zone_information.yaml:plaso/preprocessors" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/mounted_devices.yaml:plaso/preprocessors"
      echo ""
      echo "      Intentando compilar psort..."
      echo ""
      vRutaALibPythonSO=$(find /usr/lib/python* -name "libpython3.11.so" 2>/dev/null)
      pyinstaller --onefile psort \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_core_location.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_mdns.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_open_directory.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/windows_nt.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/time_zone_information.yaml:plaso/preprocessors" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/mounted_devices.yaml:plaso/preprocessors" \
        --add-binary "$vRutaALibPythonSO:."
      echo ""
      echo "      Intentando compilar psteal..."
      echo ""
      vRutaALibPythonSO=$(find /usr/lib/ -name "libpython3.11.so.1.0" 2>/dev/null)
      pyinstaller --onefile psteal \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_core_location.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_mdns.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_open_directory.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/windows_nt.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/time_zone_information.yaml:plaso/preprocessors" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/mounted_devices.yaml:plaso/preprocessors" \
        --add-binary "$vRutaALibPythonSO:."
      echo ""
      echo "      Intentando compilar pinfo..."
      echo ""
      vRutaALibPythonSO=$(find /usr/lib/ -name "libpython3.11.so.1.0" 2>/dev/null)
      pyinstaller --onefile pinfo \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_core_location.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_mdns.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_open_directory.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/windows_nt.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/time_zone_information.yaml:plaso/preprocessors" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/mounted_devices.yaml:plaso/preprocessors" \
        --add-binary "$vRutaALibPythonSO:."
      echo ""
      echo "      Intentando compilar stats..."
      echo ""
      pyinstaller --onefile stats \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_core_location.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_mdns.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_open_directory.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/windows_nt.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/time_zone_information.yaml:plaso/preprocessors" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/mounted_devices.yaml:plaso/preprocessors"
      echo ""
      echo "      Intentando compilar validator..."
      echo ""
      pyinstaller --onefile validator \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_core_location.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_mdns.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_open_directory.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/windows_nt.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/time_zone_information.yaml:plaso/preprocessors" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/mounted_devices.yaml:plaso/preprocessors"
      echo ""
      echo "      Intentando compilar xattr..."
      echo ""
      pyinstaller --onefile xattr \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_core_location.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_mdns.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_open_directory.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/windows_nt.yaml:plaso/parsers" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/time_zone_information.yaml:plaso/preprocessors" \
        --add-data ~/"PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/mounted_devices.yaml:plaso/preprocessors" \
        --hidden-import=_cffi_backend

    # Copiar los binarios compilados a la carpeta de binarios del usuario
      echo ""
      echo "    Copiando los binarios a la carpeta ~/bin/"
      echo ""
      mkdir -p ~/bin/
      cp ~/PythonVirtualEnvironments/plaso/bin/dist/image_export ~/bin/plaso-image_export
      cp ~/PythonVirtualEnvironments/plaso/bin/dist/log2timeline ~/bin/plaso-log2timeline
      cp ~/PythonVirtualEnvironments/plaso/bin/dist/normalizer   ~/bin/plaso-normalizer
      cp ~/PythonVirtualEnvironments/plaso/bin/dist/psort        ~/bin/plaso-psort
      cp ~/PythonVirtualEnvironments/plaso/bin/dist/psteal       ~/bin/plaso-psteal
      cp ~/PythonVirtualEnvironments/plaso/bin/dist/pinfo        ~/bin/plaso-pinfo
      cp ~/PythonVirtualEnvironments/plaso/bin/dist/stats        ~/bin/plaso-stats
      cp ~/PythonVirtualEnvironments/plaso/bin/dist/validator    ~/bin/plaso-validator
      cp ~/PythonVirtualEnvironments/plaso/bin/dist/xattr        ~/bin/plaso-xattr

    # Desactivar el entorno virtual
      echo ""
      echo "    Desactivando el entorno virtual..."
      echo ""
      deactivate

  elif [ $cVerSO == "11" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Plaso para Debian 11 (Bullseye)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 11 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "10" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Plaso para Debian 10 (Buster)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 10 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "9" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Plaso para Debian 9 (Stretch)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 9 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "8" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Plaso para Debian 8 (Jessie)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 8 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "7" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Plaso para Debian 7 (Wheezy)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 7 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  fi

