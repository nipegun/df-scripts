#!/bin/bash


para el 3 (Hacer lo mismo que volatility 2 para debian 11)
sudo apt install -y build-essential git libdistorm3-dev yara libraw1394-11 libcapstone-dev capstone-tool tzdata
sudo apt install -y python3 python3-dev libpython3-dev python3-pip python3-setuptools python3-wheel
python3 -m pip install -U distorm3 yara pycrypto pillow openpyxl ujson pytz ipython capstone
python3 -m pip install -U git+https://github.com/volatilityfoundation/volatility3.git
echo 'export PATH=/home/username/.local/bin:$PATH' >> ~/.bashrc

volshell launches an interactive shell for Volatility 3. Allows you to run commands and explore memory images interactively.
volshell -f <path_to_memory_image> (Opens a specific memory image file in the Volatility 3 shell for analysis.)

Additional useful commands:

    volshell
    Launches an interactive shell for Volatility 3.
    Allows you to run commands and explore memory images interactively.
    volshell -f <path_to_memory_image>
    Opens a specific memory image file in the Volatility 3 shell for analysis.
    volshell -h
    Displays help information for the volshell command, including available options.

Core Commands

    imageinfo
    Retrieves basic information about the memory image.
    Provides details such as profile, operating system version, and architecture.
    pslist
    Lists all running processes extracted from the memory image.
    Shows process identifiers (PIDs), parent process IDs (PPIDs), session IDs, and other process details.
    pstree
    Displays processes in a tree-like hierarchical structure.
    Shows parent-child relationships between processes.
    psscan
    Scans for and lists processes that may not be visible in the standard process lists (pslist).
    Useful for finding hidden or terminated processes.
    dlllist
    Lists loaded DLLs (Dynamic Link Libraries) for each process.
    Shows memory addresses, base addresses, and path to the DLL files.
    handles
    Lists open handles for each process.
    Includes file handles, registry key handles, and other types of handles.
    netscan
    Scans for network artifacts such as sockets and connections.
    Provides details about established network connections.
    filescan
    Scans for and lists file-related artifacts extracted from memory.
    Includes file handles, file mappings, and other file-related structures.

Advanced Analysis Commands

    malfind
    Identifies potential injected code or malicious artifacts within memory regions.
    Useful for detecting malware presence in memory.
    vadinfo
    Displays information about Virtual Address Descriptors (VADs) and memory mappings.
    Helps in analyzing memory regions and memory allocation patterns.
    modscan
    Scans for loaded kernel modules within the memory image.
    Lists information about loaded drivers and kernel modules.
    driverirp
    Analyzes IRP (I/O Request Packet) structures for loaded drivers.
    Useful for investigating driver behavior and I/O operations.

Plugin Management

    plugin_list
    Lists all available plugins in the Volatility 3 framework.
    Shows plugin names and descriptions.
    plugin_load <plugin_name>
    Loads a specific plugin into the Volatility 3 environment.
    Enables additional analysis capabilities provided by the plugin.

Additional Utilities

    apihooks
    Detects API hooking techniques used by malware within memory.
    Identifies hooked functions and their addresses.
    dumpfiles
    Extracts and saves files found within memory, such as executables or documents.
    Enables forensic analysis of extracted files.



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

    # Crear el menú
      # Comprobar si el paquete dialog está instalado. Si no lo está, instalarlo.
        if [[ $(dpkg-query -s dialog 2>/dev/null | grep installed) == "" ]]; then
          echo ""
          echo -e "${cColorRojo}  El paquete dialog no está instalado. Iniciando su instalación...${cFinColor}"
          echo ""
          apt-get -y update && apt-get -y install dialog
          echo ""
        fi
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

python2.7 -m ensurepip   --default-pip --user
python2.7 -m pip install --upgrade pip --user 
python2.7 -m pip install virtualenv --user 
/usr/local/bin/virtualenv -p /usr/local/bin/python2.7 volatility2
source ~/PythonVirtualEnvironments/volatility2/bin/activate
python2 -m pip install -U distorm3 yara pycrypto pillow openpyxl ujson pytz ipython capstone



pip install distorm3
pip install pycrypto
pip install yara-python

python2.7 setup.py install


mkdir -p ~/scripts/python/
cd ~/scripts/python/
git clone https://github.com/volatilityfoundation/volatility.git
~/scripts/python/volatility/volatility
pip install pyinstaller==3.6
                  
virtualenv -p /usr/bin/python2.7 volatility2
              # Mover el binario a la carpeta de binarios del usuario
                mkdir -p ~/bin/
                cp ~/scripts/python/volatility2/dist/vol ~/bin/volatility2

              # Desactivar el entorno virtual
                deactivate

              # Notificar fin de ejecución del script
                echo ""
                echo "  El script ha finalizado. El script compilado se ha copiado a:"
                echo ""
                echo "    ~/bin/volatility2"
                echo ""
                echo "  El binario debe ser usado con precaución. Es mejor correr el script directamente con python, de la siguiente manera:"
                echo ""
                echo "    source ~/PythonVirtualEnvironments/volatility2/bin/activate"
                echo "    python2.7 ~/scripts/python/volatility2/vol.py [Argumentos]"
                echo "    deactivate"
                echo ""

            ;;

            2)

              echo ""
              echo "  Instalando versión 3.x..."
              echo ""

              # Descargar el repo
                mkdir -p ~/scripts/python/ 2> /dev/null
                cd ~/scripts/python/
                if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
                  echo ""
                  echo -e "${cColorRojo}    El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
                  echo ""
                  sudo apt-get -y update && sudo apt-get -y install git
                  echo ""
                fi
                rm -rf ~/scripts/python/volatility3/
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
                cd ~/scripts/python/volatility3/
                # Comprobar si el paquete python3-pip está instalado. Si no lo está, instalarlo.
                  if [[ $(dpkg-query -s python3-pip 2>/dev/null | grep installed) == "" ]]; then
                    echo ""
                    echo -e "${cColorRojo}  El paquete python3-pip no está instalado. Iniciando su instalación...${cFinColor}"
                    echo ""
                    sudo apt-get -y update && sudo apt-get -y install python3-pip
                    echo ""
                  fi
                pip install -r requirements.txt 
                pip install -r requirements-dev.txt 

              # Compilar
                pip install pyinstaller
                pyinstaller --onefile --collect-all=volatility3 vol.py
                pyinstaller --onefile --collect-all=volatility3 volshell.py

              # Mover el binario a la carpeta de binarios del usuario
                mkdir -p ~/bin/
                cp ~/scripts/python/volatility3/dist/vol      ~/bin/volatility3
                cp ~/scripts/python/volatility3/dist/volshell ~/bin/volatility3shell

              # Desactivar el entorno virtual
                deactivate

              # Notificar fin de ejecución del script
                echo ""
                echo "  El script ha finalizado. Los scripts compilados se han copiado a:"
                echo ""
                echo "    ~/bin/volatility3"
                echo ""
                echo "      y"
                echo ""
                echo "    ~/bin/volatility3shell"
                echo ""
                echo "  Los binarios deben ser ejecutados con precaución. Es mejor correr los scripts directamente con python, de la siguiente manera:"
                echo ""
                echo "    source ~/PythonVirtualEnvironments/volatility3/bin/activate"
                echo "    ~/scripts/python/volatility3/vol.py [Argumentos]"
                echo "    deactivate"
                echo ""

            ;;

        esac

    done

  elif [ $cVerSO == "11" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Volatilty para Debian 11 (Bullseye)...${cFinColor}"
    echo ""

    # Comprobar si el paquete dialog está instalado. Si no lo está, instalarlo.
      if [[ $(dpkg-query -s dialog 2>/dev/null | grep installed) == "" ]]; then
        echo ""
        echo -e "${cColorRojo}  El paquete dialog no está instalado. Iniciando su instalación...${cFinColor}"
        echo ""
        sudo apt-get -y update && sudo apt-get -y install dialog
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

              # Instalar paquetes necesarios
                sudo apt install -y build-essential
                sudo apt install -y git
                sudo apt install -y libdistorm3-dev
                sudo apt install -y yara
                sudo apt install -y libraw1394-11
                sudo apt install -y libcapstone-dev
                sudo apt install -y capstone-tool
                sudo apt install -y tzdata
                sudo apt install -y python2
                sudo apt install -y python2.7-dev
                sudo apt install -y libpython2-dev
                sudo apt-get -y install upx
                sudo apt-get -y install binutils
                sudo apt-get -y install curl
              curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
              sudo python2 get-pip.py
              sudo python2 -m pip install -U setuptools wheel
              python2 -m pip install -U distorm3 yara pycrypto pillow openpyxl ujson pytz ipython capstone
              sudo python2 -m pip install yara
              sudo ln -s /usr/local/lib/python2.7/dist-packages/usr/lib/libyara.so /usr/lib/libyara.so
              python2 -m pip install -U git+https://github.com/volatilityfoundation/volatility.git
              echo 'export PATH=/home/nipegun/.local/bin:$PATH' >> ~/.bashrc
              echo ""
              echo "  Volatility2 instalado. Cierra la sesión de terminal, vuélvela a abrir y, para usarlo, simplemente ejecuta:"
              echo "    vol.py -f [ArchivoDump] [Script]"
              echo ""

              # Preparando el ambiente para compilarlo
                python2 -m pip install virtualenv
                mkdir -p ~/PythonVirtualEnvironments/ 2> /dev/null
                cd ~/PythonVirtualEnvironments/
                rm -rf ~/PythonVirtualEnvironments/volatility/*
                python2 -m virtualenv volatility2
                source ~/PythonVirtualEnvironments/volatility2/bin/activate
                pip2 install pyinstaller==3.6

                # Descargar el repo
                  mkdir -p ~/scripts/python/ 2> /dev/null
                  cd ~/scripts/python/
                  rm -rf ~/scripts/python/volatility/
                  if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
                    echo ""
                    echo -e "${cColorRojo}  El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
                    echo ""
                    apt-get -y update && apt-get -y install git
                    echo ""
                  fi
                  git clone https://github.com/volatilityfoundation/volatility.git
                  mv ~/scripts/python/volatility/ ~/scripts/python/volatility2/

              # Compilar
                cd ~/scripts/python/volatility2/
                # pyinstaller --onefile vol.py --hidden-import=modulo1
                pyinstaller --onefile vol.py
                  

              # Mover el binario a la carpeta de binarios del usuario
                mkdir -p ~/bin/
                cp ~/scripts/python/volatility2/dist/vol ~/bin/volatility2

              # Desactivar el entorno virtual
                deactivate

              # Notificar fin de ejecución del script
                echo ""
                echo "  El script ha finalizado. El script compilado se ha copiado a:"
                echo ""
                echo "    ~/bin/volatility2"
                echo ""
                echo "  El binario debe ser usado con precaución. Es mejor correr directamente el script, como se indicó arriba:"
                echo ""
                echo "    Simplemente ejecutando vol.py. Pero recuerda, primero debes cerrar la sesión de terminal y volverla a abrir."
                echo ""

            ;;

            2)

              echo ""
              echo "  Instalando versión 3.x..."
              echo ""

              # Descargar el repo
                mkdir -p ~/scripts/python/ 2> /dev/null
                cd ~/scripts/python/
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
                cd ~/scripts/python/volatility3/
                # Comprobar si el paquete python3-pip está instalado. Si no lo está, instalarlo.
                  if [[ $(dpkg-query -s python3-pip 2>/dev/null | grep installed) == "" ]]; then
                    echo ""
                    echo -e "${cColorRojo}  El paquete python3-pip no está instalado. Iniciando su instalación...${cFinColor}"
                    echo ""
                    sudo apt-get -y update && sudo apt-get -y install python3-pip
                    echo ""
                  fi
                pip install -r requirements.txt 
                pip install -r requirements-dev.txt 
                pip install pyinstaller

              # Compilar  
                pyinstaller --onefile --collect-all=volatility3 vol.py
                pyinstaller --onefile --collect-all=volatility3 volshell.py

              # Mover el binario a la carpeta de binarios del usuario
                mkdir -p ~/bin/
                cp ~/scripts/python/volatility3/dist/vol      ~/bin/volatility3
                cp ~/scripts/python/volatility3/dist/volshell ~/bin/volatility3shell

              # Desactivar el entorno virtual
                deactivate

              # Notificar fin de ejecución del script
                echo ""
                echo "  El script ha finalizado. Los scripts compilados se han copiado a:"
                echo ""
                echo "    ~/bin/volatility3"
                echo ""
                echo "      y"
                echo ""
                echo "    ~/bin/volatility3shell"
                echo ""
                echo "  Los binarios deben ser ejecutados con precaución. Es mejor correr los scripts directamente con python, de la siguiente manera:"
                echo ""
                echo "    source ~/PythonVirtualEnvironments/volatility3/bin/activate"
                echo "    python3 ~/scripts/python/volatility3/vol.py [Argumentos]"
                echo "    deactivate"
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
      mkdir -p ~/scripts/python/ 2> /dev/null
      cd ~/scripts/python/
      rm -rf ~/scripts/python/*
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
      mv ~/scripts/python/volatility/ ~/scripts/python/volatility2/
      cd ~/scripts/python/volatility2/
      apt-get -y install python-dev
      apt-get -y install upx
      apt-get -y install binutils
      # pyinstaller --onefile vol.py --hidden-import=modulo1
      pyinstaller --onefile vol.py

    # Mover el binario a la carpeta de binarios del usuario
      mkdir -p ~/bin/
      cp ~/scripts/python/volatility2/dist/vol ~/bin/volatility2

    # Desactivar el entorno virtual
      deactivate

    # Notificar fin de ejecución del script
      echo ""
      echo "  El script ha finalizado. El script compilado se ha copiado a:"
      echo ""
      echo "    ~/bin/volatility2"
      echo ""
      echo "  El binario debe ser usado con precaución. Es mejor correr el script directamente con python, de la siguiente manera:"
      echo ""
      echo "    source ~/PythonVirtualEnvironments/volatility2/bin/activate"
      echo "    python2.7 ~/scripts/python/volatility2/vol.py [Argumentos]"
      echo "    deactivate"
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

