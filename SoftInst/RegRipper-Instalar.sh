#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar y configurar RegRipper en Debian
#
# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/main/SoftInst/RegRipper-Instalar.sh | bash
#
# Más info: https://dfir-scripts.medium.com/installing-regripper-v2-8-on-ubuntu-26dc8bc8a2d3
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
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de RegRipper para Debian 13 (x)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 13 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "12" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de RegRipper para Debian 12 (Bookworm)...${cFinColor}"
    echo ""

    echo ""
    apt-get -y update
    apt-get -y install apt
    apt-get -y install git
    apt-get -y install libparse-win32registry-perl
    # Downloads RegRipper3.0 and moves file into /usr/local/src/regripper and "chmods" files in regripper directory to allow execution
      rm -r /usr/local/src/regripper/ 2>/dev/null
      rm -r /usr/share/regripper/plugins 2>/dev/null
    # Clonar repositorio
      cd /usr/local/src/
      git clone https://github.com/keydet89/RegRipper3.0.git
      mv RegRipper3.0 regripper
    #
      mkdir /usr/share/regripper
      ln -s  /usr/local/src/regripper/plugins /usr/share/regripper/plugins 2>/dev/nul
      chmod 755 regripper/*
    # Copiar módulos de perl específicos para RegRipper
      cp regripper/File.pm /usr/share/perl5/Parse/Win32Registry/WinNT/File.pm
      cp regripper/Key.pm  /usr/share/perl5/Parse/Win32Registry/WinNT/Key.pm
      cp regripper/Base.pm /usr/share/perl5/Parse/Win32Registry/Base.pm
    # Crear archivo rip.pl.linux a partir del archivo rip.pl original
      #[ -f regripper/rip.pl ] && echo "rip.pl found!" || echo "rip.pl not found!"
      #[ -f regripper/rip.pl ] && cp regripper/rip.pl rip.pl.linux || exit
      cp -f regripper/rip.pl regripper/rip.pl.linux
      sed -i '77i my \$plugindir \= \"\/usr\/share\/regripper\/plugins\/\"\;' /usr/local/src/regripper/rip.pl.linux 
      sed -i '/^#! c:[\]perl[\]bin[\]perl.exe/d'                              /usr/local/src/regripper/rip.pl.linux
      vUbicPerl=$(which perl) && sed -i "1i #\!$vUbicPerl"                    /usr/local/src/regripper/rip.pl.linux
      sed -i '2i use lib qw(/usr/lib/perl5/);'                                /usr/local/src/regripper/rip.pl.linux
    # Obtener el hash
      md5sum /usr/local/src/regripper/rip.pl.linux && echo "  El archivo rip.pl.linux ha sido creado correctamente!"
    # Copiar el archivo rip.pl.linux a /usr/local/bin/rip.pl
      cp -f regripper/rip.pl.linux /usr/local/bin/rip.pl
      echo "  El archivo /usr/local/src/regripper/rip.pl.linux ha sido copiado a /usr/local/bin/rip.pl"
      /usr/local/bin/rip.pl
      echo "  El archivo rip.pl de RegRipper ha sido cambiado. El archivo original está ubicado en /usr/local/src/regripper/rip.pl."
    echo ""

  elif [ $cVerSO == "11" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de RegRipper para Debian 11 (Bullseye)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 11 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "10" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de RegRipper para Debian 10 (Buster)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 10 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "9" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de RegRipper para Debian 9 (Stretch)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 9 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "8" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de RegRipper para Debian 8 (Jessie)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 8 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "7" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de RegRipper para Debian 7 (Wheezy)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 7 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  fi

