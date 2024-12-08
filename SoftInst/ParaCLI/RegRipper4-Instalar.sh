#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar y configurar RegRipper en Debian
#
# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/RegRipper4-Instalar.sh | sudo bash
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
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de RegRipper4 para Debian 13 (x)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 13 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "12" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de RegRipper4 para Debian 12 (Bookworm)...${cFinColor}"
    echo ""

    # Crear el menú
      # Comprobar si el paquete dialog está instalado. Si no lo está, instalarlo.
        if [[ $(dpkg-query -s dialog 2>/dev/null | grep installed) == "" ]]; then
          echo ""
          echo -e "${cColorRojo}  El paquete dialog no está instalado. Iniciando su instalación...${cFinColor}"
          echo ""
          sudo apt-get -y update
          sudo apt-get -y install dialog
          echo ""
        fi
      menu=(dialog --timeout 10 --checklist "Marca como quieres instalar la herramienta:" 22 70 16)
        opciones=(
          1 "Clonar repo e Instalar en /home/$USER/.local/bin/" off
          2 "  Agregar /home/$USER/.local/bin/ al path"         off
          3 "Clonar repo e instalar a nivel de sistema"         on
        )
      choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)

      for choice in $choices
        do
          case $choice in

            1)

              echo ""
              echo "  Clonando repo e instalando en  /home/$USER/.local/bin/..."
              echo ""

            ;;

            2)

              echo ""
              echo "  Agregando /home/$USER/.local/bin al path..."
              echo ""
              echo 'export PATH=/home/'"$USER"'/.local/bin:$PATH' >> ~/.bashrc

            ;;

            3)

              echo ""
              echo "  Clonando repo e instalando a nivel de sistema..."
              echo ""

              echo ""
              echo "    Instalando dependencias..."
              echo ""
              sudo apt-get -y update
              sudo apt-get -y install apt
              sudo apt-get -y install git
              sudo apt-get -y install libparse-win32registry-perl

              # Borrar script anterior
                sudo rm -f /usr/local/bin/rip.pl

              # Clonar el repo
                mkdir -p ~/repos/perl/
                cd ~/repos/perl/
                # Comprobar si el paquete git está instalado. Si no lo está, instalarlo.
                  if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
                    echo ""
                    echo -e "${cColorRojo}  El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
                    echo ""
                    sudo apt-get -y update
                    sudo apt-get -y install git
                    echo ""
                  fi
                git clone https://github.com/keydet89/RegRipper4.0.git

              # Copiar el repo a /usr/local/src/
                sudo rm -rf /usr/local/src/regripper
                sudo cp -r ~/repos/perl/RegRipper4.0 /usr/local/src/regripper

              #
                sudo rm -rf /usr/share/regripper
                sudo mkdir /usr/share/regripper
                sudo ln -s /usr/local/src/regripper/plugins /usr/share/regripper/plugins 2>/dev/nul
                sudo chmod 755 /usr/local/src/regripper/*
                sudo chmod 755 /usr/share/regripper/*

              # Copiar módulos de perl específicos para RegRipper
                echo ""
                echo "    Copiando módulos..."
                echo ""
                sudo cp -v /usr/local/src/regripper/File.pm /usr/share/perl5/Parse/Win32Registry/WinNT/File.pm
                sudo cp -v /usr/local/src/regripper/Key.pm  /usr/share/perl5/Parse/Win32Registry/WinNT/Key.pm
                sudo cp -v /usr/local/src/regripper/Base.pm /usr/share/perl5/Parse/Win32Registry/Base.pm
                sudo rm -v -f /usr/local/src/regripper/rip.pl.linux
                sudo cp -v -f /usr/local/src/regripper/rip.pl /usr/local/src/regripper/rip.pl.linux
                sudo sed -i '77i my \$plugindir \= \"\/usr\/share\/regripper\/plugins\/\"\;' /usr/local/src/regripper/rip.pl.linux
                sudo sed -i '/^#! c:[\]perl[\]bin[\]perl.exe/d'                              /usr/local/src/regripper/rip.pl.linux
                vUbicPerl=$(which perl) && sudo sed -i "1i #\!$vUbicPerl"                    /usr/local/src/regripper/rip.pl.linux
                sudo sed -i '2i use lib qw(/usr/lib/perl5/);'                                /usr/local/src/regripper/rip.pl.linux
              # Obtener el hash
                md5sum /usr/local/src/regripper/rip.pl.linux && echo "  El archivo rip.pl.linux ha sido creado correctamente!"
              # Copiar el archivo rip.pl.linux a /usr/local/bin/rip.pl
                sudo rm -v -f /usr/local/bin/rip.pl
                sudo cp -v -f /usr/local/src/regripper/rip.pl.linux /usr/local/bin/rip.pl
                echo "  El archivo /usr/local/src/regripper/rip.pl.linux ha sido copiado a /usr/local/bin/rip.pl"
                echo "  RegRipper debe ejecutarse siempre desde /usr/local/bin/rip.pl"
                #sudo sed -i -e '1s|^#!.*|#!/usr/bin/perl|' /usr/local/bin/rip.pl
                #echo "  El archivo rip.pl de RegRipper ha sido cambiado. El archivo original está ubicado en /usr/local/src/regripper/rip.pl."
                sudo chmod +x /usr/local/bin/rip.pl
                echo ""

              # Notificar fin de ejecución del script
                echo ""
                echo -e "${cColorVerde}    La instalación ha finalizado. Para ejecutar RegRipper:${cFinColor}"
                echo ""
                echo -e "${cColorVerde}        rip.pl [Parámetros]${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      o${cFinColor}"
                echo ""
                echo -e "${cColorVerde}       /usr/local/bin/rip.pl [Parámetros]${cFinColor}"
                echo ""

            ;;

        esac

    done


  elif [ $cVerSO == "11" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de RegRipper4 para Debian 11 (Bullseye)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 11 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "10" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de RegRipper4 para Debian 10 (Buster)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 10 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "9" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de RegRipper4 para Debian 9 (Stretch)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 9 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "8" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de RegRipper4 para Debian 8 (Jessie)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 8 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "7" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de RegRipper4 para Debian 7 (Wheezy)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 7 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  fi
