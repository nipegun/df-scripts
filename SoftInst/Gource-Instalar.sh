#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar Gource en Debian
#
# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/Gource-Instalar.sh | bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/Gource-Instalar.sh | nano -
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
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Gource para Debian 13 (x)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 13 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "12" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Gource para Debian 12 (Bookworm)...${cFinColor}"
    echo ""

    # Definir fecha de ejecución del script
      cFechaDeEjec=$(date +a%Ym%md%d@%T)

    # Comprobar si el paquete dialog está instalado. Si no lo está, instalarlo.
      if [[ $(dpkg-query -s dialog 2>/dev/null | grep installed) == "" ]]; then
        echo ""
        echo -e "${cColorRojo}  El paquete dialog no está instalado. Iniciando su instalación...${cFinColor}"
        echo ""
        apt-get -y update
        apt-get -y install dialog
        echo ""
      fi

    # Crear el menú
      menu=(dialog --checklist "Marca las opciones que quieras instalar:" 22 96 16)
        opciones=(
          1 "Bajar código fuente, compilar e instalar 1" on
          2 "Opción 2" off
        )
      choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)

      for choice in $choices
        do
          case $choice in

            1)

              echo ""
              echo "  Bajando código fuente, compilando e instalando..."
              echo ""

              echo ""
              echo "    Determinando última versión del código fuente..."
              echo ""
              # Comprobar si el paquete curl está instalado. Si no lo está, instalarlo.
                if [[ $(dpkg-query -s curl 2>/dev/null | grep installed) == "" ]]; then
                  echo ""
                  echo -e "${cColorRojo}  El paquete curl no está instalado. Iniciando su instalación...${cFinColor}"
                  echo ""
                  apt-get -y update
                  apt-get -y install curl
                  echo ""
                fi
              vUltVersCodFuente=$(curl -sL https://github.com/acaudwell/Gource/releases/latest/ | sed 's/gource-/\n/g' | grep ^[0..9] | head -n1 | cut -d' ' -f1)
              echo ""
              echo "      La última versión es la $vUltVersCodFuente"
              echo ""

              echo ""
              echo "    Descargando el código fuente de la última versión..."
              echo ""
              mkdir -p /root/SoftInt/Gource/
              cd /root/SoftInt/Gource/
              curl -L https://github.com/acaudwell/Gource/releases/download/gource-$vUltVersCodFuente/gource-$vUltVersCodFuente.tar.gz -o /root/SoftInt/Gource/gource.tar.gz
              echo ""

              echo ""
              echo "    Descomprimiento el archivo .tar..."
              echo ""
              cd /root/SoftInt/Gource/
              tar -xvf gource.tar.gz
              echo ""

              echo ""
              echo "    Instalando paquetes necesarios para compilar..."
              echo ""
              apt-get update
              apt-get -y install libsdl2-dev
              apt-get -y install libsdl2-image-dev
              apt-get -y install libpcre2-dev
              apt-get -y install libfreetype6-dev
              apt-get -y install libglew-dev
              apt-get -y install libglm-dev
              apt-get -y install libboost-filesystem-dev
              apt-get -y install libpng-dev
              apt-get -y install libtinyxml-dev
              echo ""

              echo ""
              echo "    Compilando..."
              echo ""
              cd /root/SoftInt/Gource/gource-$vUltVersCodFuente/
              ./configure
              make
              echo ""

              echo ""
              echo "    Instalando..."
              echo ""
              cd /root/SoftInt/Gource/gource-$vUltVersCodFuente/
              make install
              vUbicGource=$(whereis gource | cut -d' ' -f2)
              echo ""
              echo "      Ejecutable de gource instalado en $vUbicGource"
              echo ""

            ;;

            2)

              echo ""
              echo "  Opción 2..."
              echo ""

            ;;

        esac

    done

  elif [ $cVerSO == "11" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Gource para Debian 11 (Bullseye)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 11 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "10" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Gource para Debian 10 (Buster)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 10 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "9" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Gource para Debian 9 (Stretch)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 9 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "8" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Gource para Debian 8 (Jessie)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 8 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "7" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Gource para Debian 7 (Wheezy)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 7 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  fi
