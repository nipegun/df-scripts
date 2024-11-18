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
      mkdir -p ~/PythonVirtualEnvironments/ 2> /dev/null
      cd ~/PythonVirtualEnvironments/
      rm -rf ~/PythonVirtualEnvironments/volatility3
      if [[ $(dpkg-query -s python3-venv 2>/dev/null | grep installed) == "" ]]; then
        echo ""
        echo -e "${cColorRojo}  El paquete python3-venv no está instalado. Iniciando su instalación...${cFinColor}"
        echo ""
        sudo apt-get -y update && sudo apt-get -y install python3-venv
        echo ""
      fi
      python3 -m venv volatility3
      source ~/PythonVirtualEnvironments/volatility3/bin/activate
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
    echo "  También es posible ejecutar volatility3 directamente desde python (sin compilar), ejecutando:"
    echo ""
    echo "    python3 vol.py ..."
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

              # Instalar dependencias
                sudo apt-get -y update
                sudo apt-get -y install build-essential
                sudo apt-get -y install git
                sudo apt-get -y install libdistorm3-dev
                sudo apt-get -y install yara
                sudo apt-get -y install libraw1394-11
                sudo apt-get -y install libcapstone-dev
                sudo apt-get -y install capstone-tool
                sudo apt-get -y install tzdata
                sudo apt-get -y install python2
                sudo apt-get -y install python2.7-dev
                sudo apt-get -y install libpython2-dev
                sudo apt-get -y install curl
                sudo apt-get -y install python-dev
                sudo apt-get -y install upx
                sudo apt-get -y install binutils

              # Crear el ambiente virtual
                curl -sL https://bootstrap.pypa.io/pip/2.7/get-pip.py -o /tmp/get-pip.py
                apt-get -y install python2
                python2 /tmp/get-pip.py
                python2 -m pip install virtualenv
                mkdir -p ~/PythonVirtualEnvironments/ 2> /dev/null
                cd ~/PythonVirtualEnvironments/
                rm -rf ~/PythonVirtualEnvironments/volatility2/*
                python2 -m virtualenv volatility2
                source ~/PythonVirtualEnvironments/volatility2/bin/activate
                pip2 install pyinstaller==3.6

              # Compilar
                mv ~/SoftInst/volatility/ ~/SoftInst/volatility2/
                cd ~/SoftInst/volatility2/
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
                echo "  También es posible ejecutar volatility3 directamente desde python (sin compilar), ejecutando:"
                echo ""
                echo "    python2.7 vol.py ..."
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
                echo "  También es posible ejecutar volatility3 directamente desde python (sin compilar), ejecutando:"
                echo ""
                echo "    python3 vol.py ..."
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
      mkdir -p ~/PythonVirtualEnvironments/ 2> /dev/null
      cd ~/PythonVirtualEnvironments/
      rm -rf ~/PythonVirtualEnvironments/volatility2/*
      python2 -m virtualenv volatility2
      source ~/PythonVirtualEnvironments/volatility2/bin/activate
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
      echo "  También es posible ejecutar volatility3 directamente desde python (sin compilar), ejecutando:"
      echo ""
      echo "    python2.7 vol.py ..."
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


# Información del sistema operativo

  # ImageInfo
    vol.py -f “/path/to/file” windows.info

# Procesos

  # PSList
    vol.py -f “/path/to/file” windows.pslist
    vol.py -f “/path/to/file” windows.psscan
    vol.py -f “/path/to/file” windows.pstree

  # ProcDump (Dumpea .exes y DLLs asociadas)
    vol.py -f “/path/to/file” -o “/path/to/dir” windows.dumpfiles ‑‑pid <PID> 

  # MemDumo
    vol.py -f “/path/to/file” -o “/path/to/dir” windows.memmap ‑‑dump ‑‑pid <PID>

  # Handles (Dumpea PID, process, offset, handlevalue, type, grantedaccess, name)
    vol.py -f “/path/to/file” windows.handles ‑‑pid <PID>

  # DLLs (PID, process, base, size, name, path, loadtime, file output)
    vol.py -f “/path/to/file” windows.dlllist ‑‑pid <PID>

  # CMDLine (PID, process name, args)
    vol.py -f “/path/to/file” windows.cmdline

# Red
  vol.py -f “/path/to/file” windows.netscan
  vol.py -f “/path/to/file” windows.netstat

# Registro

  # HiveList
    vol.py -f “/path/to/file” windows.registry.hivescan
    vol.py -f “/path/to/file” windows.registry.hivelist

  # Registry printkey
    vol.py -f “/path/to/file” windows.registry.printkey
    vol.py -f “/path/to/file” windows.registry.printkey ‑‑key “Software\Microsoft\Windows\CurrentVersion”

# Archivos

  # FileScan
    vol.py -f “/path/to/file” windows.filescan

  # FileDump
    vol.py -f “/path/to/file” -o “/path/to/dir” windows.dumpfiles
    vol.py -f “/path/to/file” -o “/path/to/dir” windows.dumpfiles ‑‑virtaddr <offset>
    vol.py -f “/path/to/file” -o “/path/to/dir” windows.dumpfiles ‑‑physaddr <offset>

# Misceláneo

  # MalFind (Dumpea PID, process name, process start, protection, commit charge, privatememory, file output, hexdump disassembly)
    vol.py -f “/path/to/file” windows.malfind

  # Yarascan
    vol.py -f “/path/to/file” windows.vadyarascan ‑‑yara-rules <string>
    vol.py -f “/path/to/file” windows.vadyarascan ‑‑yara-file “/path/to/file.yar”
    vol.py -f “/path/to/file” yarascan.yarascan   ‑‑yara-file “/path/to/file.yar”

