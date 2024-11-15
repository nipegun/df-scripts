#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar y configurar Volatility en Debian
#
# Ejecución remota :
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/Volatility-Instalar.sh | bash      (No debería pipearse con sudo)
#
# Ejecución remota como root:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/Volatility-Instalar.sh | bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/Volatility-Instalar.sh | nano -
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
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Volatilty para Debian 13 (x)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 13 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "12" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Volatilty para Debian 12 (Bookworm)...${cFinColor}"
    echo ""

    echo ""
    echo "  Instalando versión 3.x..."
    echo ""

    # Descargar el repo
      mkdir -p ~/SoftInst/ 2> /dev/null
      cd ~/SoftInst/
      if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
        echo ""
        echo -e "${cColorRojo}    El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
        echo ""
        sudo apt-get -y update && sudo apt-get -y install git
        echo ""
      fi
      git clone https://github.com/volatilityfoundation/volatility3.git

    # Crear el ambiente virtual
      mkdir -p ~/VEnvs/ 2> /dev/null
      cd ~/VEnvs/
      if [[ $(dpkg-query -s python3-venv 2>/dev/null | grep installed) == "" ]]; then
        echo ""
        echo -e "${cColorRojo}  El paquete python3-venv no está instalado. Iniciando su instalación...${cFinColor}"
        echo ""
        sudo apt-get -y update && sudo apt-get -y install python3-venv
        echo ""
      fi
      python3 -m venv volatility3
      source ~/VEnvs/volatility3/bin/activate
      cd ~/SoftInst/volatility3/
      pip install -r requirements.txt 
      pip install -r requirements-dev.txt 

      # Compilar
        pip install pyinstaller
        pyinstaller --onefile --collect-all=volatility3 vol.py
        pyinstaller --onefile --collect-all=volatility3 volshell.py

      # Mover el binario a la carpeta de binarios del usuario
        mkdir -p ~/bin/
        cp ~/SoftInst/volatility3/dist/vol      ~/bin/volatility3
        cp ~/SoftInst/volatility3/dist/volshell ~/bin/volatility3shell

      # Desactivar el entorno virtual
        deactivate

  # Notificar fin de ejecución del script
    echo ""
    echo "  El script ha finalizado. Los binarios se pueden encontrar en:"
    echo ""
    echo "    ~/bin/volatility3 y ~/bin/volatility3shell"
    echo ""

  elif [ $cVerSO == "11" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Volatilty para Debian 11 (Bullseye)...${cFinColor}"
    echo ""

    # Comprobar si el paquete dialog está instalado. Si no lo está, instalarlo.
      if [[ $(dpkg-query -s dialog 2>/dev/null | grep installed) == "" ]]; then
        echo ""
        echo -e "${cColorRojo}  El paquete dialog no está instalado. Iniciando su instalación...${cFinColor}"
        echo ""
        apt-get -y update && apt-get -y install dialog
        echo ""
      fi

    # Crear el menú
      #menu=(dialog --timeout 5 --checklist "Marca las opciones que quieras instalar:" 22 96 16)
      menu=(dialog --checklist "Marca las opciones que quieras instalar:" 22 96 16)
        opciones=(
          1 "Instalar version para python 2.x" off
          2 "Instalar version para python 3.x" on
        )
      choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)
      #clear

      for choice in $choices
        do
          case $choice in

            1)

              echo ""
              echo "  Instalando versión 2.x..."
              echo ""
              # Descargar el repo
                mkdir -p ~/SoftInst/ 2> /dev/null
                cd ~/SoftInst/
                rm -rf ~/SoftInst/*
                if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
                  echo ""
                  echo -e "${cColorRojo}  El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
                  echo ""
                  apt-get -y update && apt-get -y install git
                  echo ""
                fi
                git clone https://github.com/volatilityfoundation/volatility.git

              # Crear el ambiente virtual
                curl -sL https://bootstrap.pypa.io/pip/2.7/get-pip.py -o /tmp/get-pip.py
                apt-get -y install python2
                python2 /tmp/get-pip.py
                python2 -m pip install virtualenv
                mkdir -p ~/VEnvs/ 2> /dev/null
                cd ~/VEnvs/
                rm -rf ~/VEnvs/volatility2/*
                python2 -m virtualenv volatility2
                source ~/VEnvs/volatility2/bin/activate
                pip2 install pyinstaller==3.6

              # Compilar
                mv ~/SoftInst/volatility/ ~/SoftInst/volatility2/
                cd ~/SoftInst/volatility2/
                apt-get -y install python-dev
                apt-get -y install upx
                apt-get -y install binutils
                # pyinstaller --onefile vol.py --hidden-import=modulo1
                pyinstaller --onefile vol.py
                  

              # Mover el binario a la carpeta de binarios del usuario
                mkdir -p ~/bin/
                cp ~/SoftInst/volatility2/dist/vol ~/bin/volatility2

              # Desactivar el entorno virtual
                deactivate

              # Notificar fin de ejecución del script
                echo ""
                echo "  El script ha finalizado. El binario se pueden encontrar en:"
                echo ""
                echo "    ~/bin/volatility2"
                echo ""

            ;;

            2)

              echo ""
              echo "  Instalando versión 3.x..."
              echo ""

              # Descargar el repo
                mkdir -p ~/SoftInst/ 2> /dev/null
                cd ~/SoftInst/
                if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
                  echo ""
                  echo -e "${cColorRojo}  El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
                  echo ""
                  apt-get -y update && apt-get -y install git
                  echo ""
                fi
                git clone https://github.com/volatilityfoundation/volatility3.git

              # Crear el ambiente virtual
                mkdir -p ~/VEnvs/ 2> /dev/null
                cd ~/VEnvs/
                if [[ $(dpkg-query -s python3-venv 2>/dev/null | grep installed) == "" ]]; then
                  echo ""
                  echo -e "${cColorRojo}  El paquete python3-venv no está instalado. Iniciando su instalación...${cFinColor}"
                  echo ""
                  apt-get -y update && apt-get -y install python3-venv
                  echo ""
                fi
                python3 -m venv volatility3
                source ~/VEnvs/volatility3/bin/activate
                cd ~/SoftInst/volatility3/
                pip install -r requirements.txt 
                pip install -r requirements-dev.txt 
                pip install pyinstaller

              # Compilar  
                pyinstaller --onefile --collect-all=volatility3 vol.py
                pyinstaller --onefile --collect-all=volatility3 volshell.py

              # Mover el binario a la carpeta de binarios del usuario
                mkdir -p ~/bin/
                cp ~/SoftInst/volatility3/dist/vol      ~/bin/volatility3
                cp ~/SoftInst/volatility3/dist/volshell ~/bin/volatility3shell

              # Desactivar el entorno virtual
                deactivate

              # Notificar fin de ejecución del script
                echo ""
                echo "  El script ha finalizado. Los binarios se pueden encontrar en:"
                echo ""
                echo "    ~/bin/volatility3 y ~/bin/volatility3shell"
                echo ""

            ;;

        esac

    done

  elif [ $cVerSO == "10" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Volatilty para Debian 10 (Buster)...${cFinColor}"
    echo ""

    echo ""
    echo "  Instalando versión 2.x..."
    echo ""
    # Descargar el repo
      mkdir -p ~/SoftInst/ 2> /dev/null
      cd ~/SoftInst/
      rm -rf ~/SoftInst/*
      if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
        echo ""
        echo -e "${cColorRojo}  El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
        echo ""
        apt-get -y update && apt-get -y install git
        echo ""
      fi
      git clone https://github.com/volatilityfoundation/volatility.git

    # Crear el ambiente virtual
      curl -sL https://bootstrap.pypa.io/pip/2.7/get-pip.py -o /tmp/get-pip.py
      apt-get -y install python2
      python2 /tmp/get-pip.py
      python2 -m pip install virtualenv
      mkdir -p ~/VEnvs/ 2> /dev/null
      cd ~/VEnvs/
      rm -rf ~/VEnvs/volatility2/*
      python2 -m virtualenv volatility2
      source ~/VEnvs/volatility2/bin/activate
      pip2 install pyinstaller==3.6

    # Compilar
      mv ~/SoftInst/volatility/ ~/SoftInst/volatility2/
      cd ~/SoftInst/volatility2/
      apt-get -y install python-dev
      apt-get -y install upx
      apt-get -y install binutils
      # pyinstaller --onefile vol.py --hidden-import=modulo1
      pyinstaller --onefile vol.py

    # Mover el binario a la carpeta de binarios del usuario
      mkdir -p ~/bin/
      cp ~/SoftInst/volatility2/dist/vol ~/bin/volatility2

    # Desactivar el entorno virtual
      deactivate

    # Notificar fin de ejecución del script
      echo ""
      echo "  El script ha finalizado. El binario se puede encontrar en:"
      echo ""
      echo "    ~/bin/volatility2"
      echo ""

  elif [ $cVerSO == "9" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Volatilty para Debian 9 (Stretch)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 9 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "8" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Volatilty para Debian 8 (Jessie)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 8 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "7" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Volatilty para Debian 7 (Wheezy)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 7 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  fi

