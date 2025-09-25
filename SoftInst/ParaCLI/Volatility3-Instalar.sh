#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar y configurar Volatility en Debian
#
# Ejecución remota  (No debería pipearse con sudo, aunque luego pida permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/Volatility3-Instalar.sh | bash
#
# Ejecución remota como root:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/Volatility3-Instalar.sh | bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/Volatility3-Instalar.sh | nano -
#
# Instalación rápida de volatility3
#   sudo apt -y install python3-pip
#   pip3 install volatility3 --user --break-system-packages
#  
#   export VOLATILITY_SYMBOL_PATH=~/.local/lib/python3.11/site-packages/volatility3/symbols/
#   source ~/.bashrc
# ----------

# Definir constantes de color
  cColorAzul="\033[0;34m"
  cColorAzulClaro="\033[1;34m"
  cColorVerde="\033[1;32m"
  cColorRojo="\033[1;31m"
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor="\033[0m"

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

    # Crear el menú
      # Comprobar si el paquete dialog está instalado. Si no lo está, instalarlo.
        if [[ $(dpkg-query -s dialog 2>/dev/null | grep installed) == "" ]]; then
          echo ""
          echo -e "${cColorRojo}  El paquete dialog no está instalado. Iniciando su instalación...${cFinColor}"
          echo ""
          sudo apt-get -y update && sudo apt-get -y install dialog
          echo ""
        fi
      menu=(dialog --checklist "Marca las opciones que quieras instalar:" 22 96 16)
        opciones=(
          1 "Clonar el repo de volatility3 para python 3.x"                   on
          2 "  Crear el entorno virtual de python e instalar dentro"          on
          3 "    Compilar y guardar en /home/$USER/bin/"                      off
          4 "  Instalar en /home/$USER/.local/bin/"                           off
          5 "    Agregar /home/$USER/.local/bin/ al path"                     off
          6 "Clonar repo, crear venv, compilar e instalar a nivel de sistema" off
        )
      choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)

      for choice in $choices
        do
          case $choice in

            1)

              echo ""
              echo "  Clonar el repo de volatility3 para python 3.x..."
              echo ""

              mkdir -p ~/repos/python/
              cd ~/repos/python/
              rm -rf ~/repos/python/volatility3/
              # Comprobar si el paquete git está instalado. Si no lo está, instalarlo.
                if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
                  echo ""
                  echo -e "${cColorRojo}  El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
                  echo ""
                  sudo apt-get -y update
                  sudo apt-get -y install git
                  echo ""
                fi
              git clone https://github.com/volatilityfoundation/volatility3.git

            ;;

            2)

              echo ""
              echo "  Creando el entorno virtual de python e instalando dentro..."
              echo ""
              cd ~/repos/python/volatility3/
              # Comprobar si el paquete python3-venv está instalado. Si no lo está, instalarlo.
                if [[ $(dpkg-query -s python3-venv 2>/dev/null | grep installed) == "" ]]; then
                  echo ""
                  echo -e "${cColorRojo}  El paquete python3-venv no está instalado. Iniciando su instalación...${cFinColor}"
                  echo ""
                  sudo apt-get -y update
                  sudo apt-get -y install python3-venv
                  echo ""
                fi
              python3 -m venv venv
              # Crear el mensaje para mostrar cuando se entra al entorno virtual
                echo ''                                                                                                                >> ~/repos/python/volatility3/venv/bin/activate
                echo 'echo -e "\n  Activando el entorno virtual de volatility3... \n"'                                                 >> ~/repos/python/volatility3/venv/bin/activate
                echo 'echo -e "    Forma de uso:\n"'                                                                                   >> ~/repos/python/volatility3/venv/bin/activate
                echo 'echo -e "      $HOME/repos/python/volatility3/vol.py -f [RutaAlArchivoDeDump] [Plugin]\n"'                       >> ~/repos/python/volatility3/venv/bin/activate
                echo 'echo -e "    Forma de uso en modo super verbose (Para ver posibles errores):\n"'                                 >> ~/repos/python/volatility3/venv/bin/activate
                echo 'echo -e "      $HOME/repos/python/volatility3/vol.py -vvv -f [RutaAlArchivoDeDump] [Plugin]\n"'                  >> ~/repos/python/volatility3/venv/bin/activate
                echo 'echo -e "    Forma de uso en modo silencioso:\n"'                                                                >> ~/repos/python/volatility3/venv/bin/activate
                echo 'echo -e "      $HOME/repos/python/volatility3/vol.py -q -f [RutaAlArchivoDeDump] [Plugin]\n"'                    >> ~/repos/python/volatility3/venv/bin/activate
                echo 'echo -e "    Comandos rápidos:\n"'                                                                               >> ~/repos/python/volatility3/venv/bin/activate
                echo 'echo -e "      Obtener info de windows:\n"'                                                                      >> ~/repos/python/volatility3/venv/bin/activate
                echo 'echo -e "        $HOME/repos/python/volatility3/vol.py -q -f $HOME/Descargas/Evidencia.raw windows.info.Info\n"' >> ~/repos/python/volatility3/venv/bin/activate
                echo 'echo -e "      Obtener info de linux:\n"'                                                                        >> ~/repos/python/volatility3/venv/bin/activate
                echo 'echo -e "        $HOME/repos/python/volatility3/vol.py -q -f $HOME/Descargas/Evidencia.raw banners.Banners\n"'   >> ~/repos/python/volatility3/venv/bin/activate

              # Instalar symbols
                echo ""
                echo "  Descargando símbolos..."
                echo ""
                # Comprobar si el paquete unzip está instalado. Si no lo está, instalarlo.
                  if [[ $(dpkg-query -s unzip 2>/dev/null | grep installed) == "" ]]; then
                    echo ""
                    echo -e "${cColorRojo}    El paquete unzip no está instalado. Iniciando su instalación...${cFinColor}"
                    echo ""
                    sudo apt-get -y update
                    sudo apt-get -y install unzip
                    echo ""
                  fi
                curl -L https://downloads.volatilityfoundation.org/volatility3/symbols/windows.zip -o /tmp/vol3-windows-symbols.zip
                unzip /tmp/vol3-windows-symbols.zip -d ~/repos/python/volatility3/volatility3/symbols/
                curl -L https://downloads.volatilityfoundation.org/volatility3/symbols/linux.zip   -o /tmp/vol3-linux-symbols.zip
                unzip /tmp/vol3-linux-symbols.zip   -d ~/repos/python/volatility3/volatility3/symbols/
                curl -L https://downloads.volatilityfoundation.org/volatility3/symbols/mac.zip     -o /tmp/vol3-mac-symbols.zip
                mkdir -p ~/repos/python/volatility3/volatility3/symbols/mac/
                unzip /tmp/vol3-mac-symbols.zip -d ~/repos/python/volatility3/volatility3/symbols/mac/
              # Entrar al entorno virtual
                source ~/repos/python/volatility3/venv/bin/activate
              # Instalar requerimientos
                python3 -m pip install wheel
                python3 -m pip install distorm3
                python3 -m pip install pycryptodome
                python3 -m pip install pillow
                python3 -m pip install openpyxl
                python3 -m pip install ujson
                python3 -m pip install pytz
                python3 -m pip install ipython
                python3 -m pip install capstone
                python3 -m pip install yara-python
              # Salir del entorno virtual
                deactivate
              # Copiar símbolos a la carpeta donde Volatility3 los va a buscar
                vCarpetaPython=$(ls ~/repos/python/volatility3/venv/lib/)
                mkdir -p ~/repos/python/volatility3/venv/lib/"$vCarpetaPython"/site-packages/volatility3/symbols/
                cp -rfv ~/repos/python/volatility3/volatility3/symbols/* ~/repos/python/volatility3/venv/lib/"$vCarpetaPython"/site-packages/volatility3/symbols/
                cd ~
              # Notificar fin de instalación en el entorno virtual
                echo ""
                echo -e "${cColorVerde}    Entorno virtual preparado. volatility3 se puede ejecutar desde el venv de la siguiente forma:${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      source ~/repos/python/volatility3/venv/bin/activate${cFinColor}"
                echo ""
                echo -e "${cColorVerde}        $HOME/repos/python/volatility3/vol.py -f [RutaAlArchivo] [Plugin]${cFinColor}"
                echo -e "${cColorVerde}        $HOME/repos/python/volatility3/volshell.py [Parámetros]${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      deactivate${cFinColor}"
                echo ""

            ;;

            3)

              echo ""
              echo "  Compilando y guardando en /home/$USER/bin/..."
              echo ""

              # Instalar paquetes necesarios
                sudo apt-get -y install build-essential
                sudo apt-get -y install git
                sudo apt-get -y install libraw1394-11
                sudo apt-get -y install libcapstone-dev
                sudo apt-get -y install capstone-tool
                sudo apt-get -y install tzdata
                sudo apt-get -y install python3
                sudo apt-get -y install python3-dev
                sudo apt-get -y install libpython3-dev
                sudo apt-get -y install python3-pip
                sudo apt-get -y install python3-setuptools
                sudo apt-get -y install python3-wheel
                sudo apt-get -y install python3-distorm3
                sudo apt-get -y install python3-yara
                sudo apt-get -y install python3-pillow
                sudo apt-get -y install python3-openpyxl
                sudo apt-get -y install python3-ujson
                sudo apt-get -y install python3-ipython
                sudo apt-get -y install python3-capstone
                sudo apt-get -y install python3-pycryptodome          # Anterior pycrypto
                sudo apt-get -y install python3-pytz-deprecation-shim # Anterior python3-pytz
                # python3 -m pip install -U pycrypto pytz

              # Entrar en el entorno virtual
                source ~/repos/python/volatility3/venv/bin/activate
                cd ~/repos/python/volatility3/

              # Compilar
                # Comprobar si el paquete python3-pip está instalado. Si no lo está, instalarlo.
                  if [[ $(dpkg-query -s python3-pip 2>/dev/null | grep installed) == "" ]]; then
                    echo ""
                    echo -e "${cColorRojo}  El paquete python3-pip no está instalado. Iniciando su instalación...${cFinColor}"
                    echo ""
                    sudo apt-get -y update
                    sudo apt-get -y install python3-pip
                    echo ""
                  fi
                python3 -m pip install pyinstaller
                
                pyinstaller --onefile --collect-all=volatility3 vol.py
                #pyinstaller --onefile vol.spec
                pyinstaller --onefile --collect-all=volatility3 volshell.py

             # Desactivar el entorno virtual
                deactivate

              # Mover el binario a la carpeta de binarios del usuario
                mkdir -p ~/bin/
                cp -vf ~/repos/python/volatility3/dist/vol      ~/bin/volatility3
                cp -vf ~/repos/python/volatility3/dist/volshell ~/bin/volatility3shell

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
                echo "    ~/scripts/python/volatility3/vol.py [Argumentos]"
                echo ""
                echo ""
                echo "    O, si se quiere ejecutar dentro del entorno virtual:"
                echo ""
                echo "      source ~/PythonVirtualEnvironments/volatility3/bin/activate"
                echo "      ~/scripts/python/volatility3/vol.py [Argumentos]"
                echo "      deactivate"
                echo ""

            ;;

            4)

              echo ""
              echo "  Instalando en /home/$USER/.local/bin/..."
              echo ""

              # Comprobar si el paquete python3-setuptools está instalado. Si no lo está, instalarlo.
                if [[ $(dpkg-query -s python3-setuptools 2>/dev/null | grep installed) == "" ]]; then
                  echo ""
                  echo -e "${cColorRojo}  El paquete python3-setuptools no está instalado. Iniciando su instalación...${cFinColor}"
                  echo ""
                  sudo apt-get -y update
                  sudo apt-get -y install python3-setuptools
                  echo ""
                fi
              cd ~/repos/python/volatility3/
              python3 setup.py install --user
              cd ~

              # Notificar fin de ejecución del script
                echo ""
                echo -e "${cColorVerde}    Para ejecutar volatility3 instalado en /home/$USER/.local/bin/:${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      Si al instalar has marcado 'Agregar /home/$USER/.local/bin/ al path', simplemente ejecuta:${cFinColor}"
                echo ""
                echo -e "${cColorVerde}        vol -vvv -f [RutaAlArchivo] [Plugins] ${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      Si al instalar NO has marcado 'Agregar /home/$USER/.local/bin/ al path', ejecuta:${cFinColor}"
                echo ""
                echo -e "${cColorVerde}       ~/.local/bin/vol -vvv -f [RutaAlArchivo] [Plugins] ${cFinColor}"
                echo ""

            ;;

            5)

              echo ""
              echo "  Agregando /home/$USER/.local/bin al path..."
              echo ""
              echo 'export PATH=/home/'"$USER"'/.local/bin:$PATH' >> ~/.bashrc

            ;;

            6)

              echo ""
              echo "  Clonando repo, creando venv, compilando e instalando a nivel de sistema..."
              echo ""

              # Preparar el entorno virtual de python
                echo ""
                echo "    Preparando el entorno virtual de python..."
                echo ""
                mkdir -p /tmp/PythonVirtualEnvironments/ 2> /dev/null
                rm -rf /tmp/PythonVirtualEnvironments/volatility3/
                cd /tmp/PythonVirtualEnvironments/
              # Comprobar si el paquete python3-venv está instalado. Si no lo está, instalarlo.
                if [[ $(dpkg-query -s python3-venv 2>/dev/null | grep installed) == "" ]]; then
                  echo ""
                  echo -e "${cColorRojo}  El paquete python3-venv no está instalado. Iniciando su instalación...${cFinColor}"
                  echo ""
                  sudo apt-get -y update
                  sudo apt-get -y install python3-venv
                  echo ""
                fi
                python3 -m venv volatility3

              # Ingresar en el entorno virtual e instalar
                echo ""
                echo "    Ingresando en el entorno virtual e instalando..."
                echo ""
                source /tmp/PythonVirtualEnvironments/volatility3/bin/activate

              # Clonar el repo
                echo ""
                echo "  Clonando el repo..."
                echo ""
                cd /tmp/PythonVirtualEnvironments/volatility3/
                # Comprobar si el paquete git está instalado. Si no lo está, instalarlo.
                  if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
                    echo ""
                    echo -e "${cColorRojo}  El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
                    echo ""
                    sudo apt-get -y update
                    sudo apt-get -y install git
                    echo ""
                  fi
                git clone https://github.com/volatilityfoundation/volatility3.git
                mv volatility3 code
                cd code

              # Compilar
                echo ""
                echo "    Compilando..."
                echo ""
                
                sudo apt-get -y install build-essential
                sudo apt-get -y install python3-dev

                python3 -m pip install wheel
                python3 -m pip install setuptools
                python3 -m pip install pyinstaller
                
                python3 -m pip install distorm3
                python3 -m pip install pycryptodome
                python3 -m pip install pillow
                python3 -m pip install openpyxl
                python3 -m pip install ujson
                python3 -m pip install pytz
                python3 -m pip install ipython
                python3 -m pip install capstone
                python3 -m pip install yara-python
                
                python3 -m pip install .

                pyinstaller --onefile --collect-all=vol.py vol.py
                pyinstaller --onefile --collect-all=volshell.py volshell.py

                #pyinstaller --onefile --hidden-import=importlib.metadata --collect-all=volatility3 volatility3.py

              # Instalar paquetes necesarios
                #echo ""
                #echo "    Instalando paquetes necesarios..."
                #echo ""
                #sudo apt-get -y update
                #sudo apt-get -y install python3
                #sudo apt-get -y install python3-pip
                #sudo apt-get -y install python3-setuptools
                #sudo apt-get -y install python3-dev
                #sudo apt-get -y install python3-venv
                #sudo apt-get -y install python3-wheel
                #sudo apt-get -y install python3-distorm3
                #sudo apt-get -y install python3-yara
                #sudo apt-get -y install python3-pillow
                #sudo apt-get -y install python3-openpyxl
                #sudo apt-get -y install python3-ujson
                #sudo apt-get -y install python3-ipython
                #sudo apt-get -y install python3-capstone
                #sudo apt-get -y install python3-pycryptodome          # Anterior pycrypto
                #sudo apt-get -y install python3-pytz-deprecation-shim # Anterior python3-pytz                sudo apt-get -y install build-essential

                
                #sudo apt-get -y install liblzma-dev

                #sudo apt-get -y install git
                #sudo apt-get -y install libraw1394-11
                #sudo apt-get -y install libcapstone-dev
                #sudo apt-get -y install capstone-tool
                #sudo apt-get -y install tzdata


                #sudo apt-get -y install libpython3-dev

              # Desactivar el entorno virtual
                echo ""
                echo "    Desactivando el entorno virtual..."
                echo ""
                deactivate

              # Copiar los binarios compilados a la carpeta de binarios del usuario
                echo ""
                echo "    Copiando los binarios a la carpeta /usr/bin/"
                echo ""
                sudo rm -f /usr/bin/volatility3
                sudo cp -vf /tmp/PythonVirtualEnvironments/volatility3/code/dist/vol      /usr/bin/volatility3
                sudo rm -f /usr/bin/volatility3shell
                sudo cp -vf /tmp/PythonVirtualEnvironments/volatility3/code/dist/volshell /usr/bin/volatility3shell
                cd ~

              # Notificar fin de ejecución del script
                echo ""
                echo -e "${cColorVerde}    La instalación ha finalizado. Se han copiado las herramientas a /usr/bin/ ${cFinColor}"
                echo -e "${cColorVerde}    Puedes ejecutarlas de la siguiente forma: ${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      volatility3 -vvv -f [RutaAlArchivo] [Plugins] ${cFinColor}"
                echo ""

            ;;

        esac

    done

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
          sudo apt-get -y update && sudo apt-get -y install dialog
          echo ""
        fi
      menu=(dialog --checklist "Marca las opciones que quieras instalar:" 22 96 16)
        opciones=(
          1 "Clonar el repo de volatility3 para python 3.x"                   on
          2 "  Crear el entorno virtual de python e instalar dentro"          on
          3 "    Compilar y guardar en /home/$USER/bin/"                      off
          4 "  Instalar en /home/$USER/.local/bin/"                           off
          5 "    Agregar /home/$USER/.local/bin/ al path"                     off
          6 "Clonar repo, crear venv, compilar e instalar a nivel de sistema" off
        )
      choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)

      for choice in $choices
        do
          case $choice in

            1)

              echo ""
              echo "  Clonar el repo de volatility3 para python 3.x..."
              echo ""

              mkdir -p ~/repos/python/
              cd ~/repos/python/
              rm -rf ~/repos/python/volatility3/
              # Comprobar si el paquete git está instalado. Si no lo está, instalarlo.
                if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
                  echo ""
                  echo -e "${cColorRojo}  El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
                  echo ""
                  sudo apt-get -y update
                  sudo apt-get -y install git
                  echo ""
                fi
              git clone https://github.com/volatilityfoundation/volatility3.git

            ;;

            2)

              echo ""
              echo "  Creando el entorno virtual de python e instalando dentro..."
              echo ""
              cd ~/repos/python/volatility3/
              # Comprobar si el paquete python3-venv está instalado. Si no lo está, instalarlo.
                if [[ $(dpkg-query -s python3-venv 2>/dev/null | grep installed) == "" ]]; then
                  echo ""
                  echo -e "${cColorRojo}  El paquete python3-venv no está instalado. Iniciando su instalación...${cFinColor}"
                  echo ""
                  sudo apt-get -y update
                  sudo apt-get -y install python3-venv
                  echo ""
                fi
              python3 -m venv venv
              # Crear el mensaje para mostrar cuando se entra al entorno virtual
                echo ''                                                                           >> ~/repos/python/volatility3/venv/bin/activate
                echo 'echo -e "\n  Activando el entorno virtual de volatility3... \n"'            >> ~/repos/python/volatility3/venv/bin/activate
                echo 'echo -e "    Forma de uso:\n"'                                              >> ~/repos/python/volatility3/venv/bin/activate
                echo 'echo -e "      vol -vvv -f [RutaAlArchivoDeDump] [Plugin]\n"'               >> ~/repos/python/volatility3/venv/bin/activate
                echo 'echo -e "    Comandos rápidos:\n"'                                          >> ~/repos/python/volatility3/venv/bin/activate
                echo 'echo -e "      Obtener info de windows:\n"'                                 >> ~/repos/python/volatility3/venv/bin/activate
                echo 'echo -e "        vol -vvv -f $HOME/Descargas/Evidencia.raw windows.info\n"' >> ~/repos/python/volatility3/venv/bin/activate
                echo 'echo -e "      Obtener info de linux:\n"'                                   >> ~/repos/python/volatility3/venv/bin/activate
                echo 'echo -e "        vol -vvv -f $HOME/Descargas/Evidencia.raw linux.banner\n"'   >> ~/repos/python/volatility3/venv/bin/activate
              # Instalar symbols
                # Comprobar si el paquete unzip está instalado. Si no lo está, instalarlo.
                  if [[ $(dpkg-query -s unzip 2>/dev/null | grep installed) == "" ]]; then
                    echo ""
                    echo -e "${cColorRojo}  El paquete unzip no está instalado. Iniciando su instalación...${cFinColor}"
                    echo ""
                    sudo apt-get -y update
                    sudo apt-get -y install unzip
                    echo ""
                  fi
                curl -L https://downloads.volatilityfoundation.org/volatility3/symbols/windows.zip -o /tmp/vol3-windows-symbols.zip
                unzip /tmp/vol3-windows-symbols.zip -d ~/repos/python/volatility3/volatility3/symbols/
                curl -L https://downloads.volatilityfoundation.org/volatility3/symbols/linux.zip   -o /tmp/vol3-linux-symbols.zip
                unzip /tmp/vol3-linux-symbols.zip   -d ~/repos/python/volatility3/volatility3/symbols/
                curl -L https://downloads.volatilityfoundation.org/volatility3/symbols/mac.zip     -o /tmp/vol3-mac-symbols.zip
                mkdir -p ~/repos/python/volatility3/volatility3/symbols/mac/
                unzip /tmp/vol3-mac-symbols.zip -d ~/repos/python/volatility3/volatility3/symbols/mac/
              # Entrar al entorno virtual
                source ~/repos/python/volatility3/venv/bin/activate
              # Instalar requerimientos
                python3 -m pip install wheel
                python3 -m pip install distorm3
                python3 -m pip install pycryptodome
                python3 -m pip install pillow
                python3 -m pip install openpyxl
                python3 -m pip install ujson
                python3 -m pip install pytz
                python3 -m pip install ipython
                python3 -m pip install capstone
                python3 -m pip install yara-python
                python3 -m pip install .
              # Salir del entorno virtual
                deactivate
              # Instalar símbolos
                vCarpetaPython=$(ls ~/repos/python/volatility3/venv/lib/)
                cp -rfv ~/repos/python/volatility3/volatility3/symbols/* ~/repos/python/volatility3/venv/lib/"$vCarpetaPython"/site-packages/volatility3/symbols/
              # Notificar fin de instalación en el entorno virtual
                echo ""
                echo -e "${cColorVerde}    Entorno virtual preparado. volatility3 se puede ejecutar desde el venv de la siguiente forma:${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      source ~/repos/python/volatility3/venv/bin/activate${cFinColor}"
                echo ""
                echo -e "${cColorVerde}        vol -vvv -f [RutaAlArchivo] [Plugin]${cFinColor}"
                echo -e "${cColorVerde}        volshell [Parámetros]${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      deactivate${cFinColor}"
                echo ""

            ;;

            3)

              echo ""
              echo "  Compilando y guardando en /home/$USER/bin/..."
              echo ""

              # Instalar paquetes necesarios
                sudo apt install -y build-essential
                sudo apt install -y git
                sudo apt install -y libraw1394-11
                sudo apt install -y libcapstone-dev
                sudo apt install -y capstone-tool
                sudo apt install -y tzdata
                sudo apt install -y python3
                sudo apt install -y python3-dev
                sudo apt install -y libpython3-dev
                sudo apt install -y python3-pip
                sudo apt install -y python3-setuptools
                sudo apt install -y python3-wheel
                sudo apt install -y python3-distorm3
                sudo apt install -y python3-yara
                sudo apt install -y python3-pillow
                sudo apt install -y python3-openpyxl
                sudo apt install -y python3-ujson
                sudo apt install -y python3-ipython
                sudo apt install -y python3-capstone
                sudo apt install -y python3-pycryptodome          # Anterior pycrypto
                sudo apt install -y python3-pytz-deprecation-shim # Anterior python3-pytz
                # python3 -m pip install -U pycrypto pytz

              # Entrar en el entorno virtual
                source ~/repos/python/volatility3/venv/bin/activate
                cd ~/repos/python/volatility3/

              # Compilar
                # Comprobar si el paquete python3-pip está instalado. Si no lo está, instalarlo.
                  if [[ $(dpkg-query -s python3-pip 2>/dev/null | grep installed) == "" ]]; then
                    echo ""
                    echo -e "${cColorRojo}  El paquete python3-pip no está instalado. Iniciando su instalación...${cFinColor}"
                    echo ""
                    sudo apt-get -y update
                    sudo apt-get -y install python3-pip
                    echo ""
                  fi
                python3 -m pip install pyinstaller
                
                pyinstaller --onefile --collect-all=volatility3 vol.py
                pyinstaller --onefile --collect-all=volatility3 volshell.py

             # Desactivar el entorno virtual
                deactivate

              # Mover el binario a la carpeta de binarios del usuario
                mkdir -p ~/bin/
                cp ~/repos/python/volatility3/dist/vol      ~/bin/volatility3
                cp ~/repos/python/volatility3/dist/volshell ~/bin/volatility3shell

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
                echo "    ~/scripts/python/volatility3/vol.py [Argumentos]"
                echo ""
                echo ""
                echo "    O, si se quiere ejecutar dentro del entorno virtual:"
                echo ""
                echo "      source ~/PythonVirtualEnvironments/volatility3/bin/activate"
                echo "      ~/scripts/python/volatility3/vol.py [Argumentos]"
                echo "      deactivate"
                echo ""

            ;;

            4)

              echo ""
              echo "  Instalando en /home/$USER/.local/bin/..."
              echo ""

              # Comprobar si el paquete python3-setuptools está instalado. Si no lo está, instalarlo.
                if [[ $(dpkg-query -s python3-setuptools 2>/dev/null | grep installed) == "" ]]; then
                  echo ""
                  echo -e "${cColorRojo}  El paquete python3-setuptools no está instalado. Iniciando su instalación...${cFinColor}"
                  echo ""
                  sudo apt-get -y update
                  sudo apt-get -y install python3-setuptools
                  echo ""
                fi
              cd ~/repos/python/volatility3/
              python3 setup.py install --user
              cd ~

              # Notificar fin de ejecución del script
                echo ""
                echo -e "${cColorVerde}    Para ejecutar volatility3 instalado en /home/$USER/.local/bin/:${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      Si al instalar has marcado 'Agregar /home/$USER/.local/bin/ al path', simplemente ejecuta:${cFinColor}"
                echo ""
                echo -e "${cColorVerde}        vol -vvv -f [RutaAlArchivo] [Plugins] ${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      Si al instalar NO has marcado 'Agregar /home/$USER/.local/bin/ al path', ejecuta:${cFinColor}"
                echo ""
                echo -e "${cColorVerde}       ~/.local/bin/vol -vvv -f [RutaAlArchivo] [Plugins] ${cFinColor}"
                echo ""

            ;;

            5)

              echo ""
              echo "  Agregando /home/$USER/.local/bin al path..."
              echo ""
              echo 'export PATH=/home/'"$USER"'/.local/bin:$PATH' >> ~/.bashrc

            ;;

            6)

              echo ""
              echo "  Clonando repo, creando venv, compilando e instalando a nivel de sistema..."
              echo ""

              # Preparar el entorno virtual de python
                echo ""
                echo "    Preparando el entorno virtual de python..."
                echo ""
                mkdir -p /tmp/PythonVirtualEnvironments/ 2> /dev/null
                rm -rf /tmp/PythonVirtualEnvironments/volatility3/
                cd /tmp/PythonVirtualEnvironments/
              # Comprobar si el paquete python3-venv está instalado. Si no lo está, instalarlo.
                if [[ $(dpkg-query -s python3-venv 2>/dev/null | grep installed) == "" ]]; then
                  echo ""
                  echo -e "${cColorRojo}  El paquete python3-venv no está instalado. Iniciando su instalación...${cFinColor}"
                  echo ""
                  sudo apt-get -y update
                  sudo apt-get -y install python3-venv
                  echo ""
                fi
                python3 -m venv volatility3

              # Ingresar en el entorno virtual e instalar
                echo ""
                echo "    Ingresando en el entorno virtual e instalando..."
                echo ""
                source /tmp/PythonVirtualEnvironments/volatility3/bin/activate

              # Clonar el repo
                echo ""
                echo "  Clonando el repo..."
                echo ""
                cd /tmp/PythonVirtualEnvironments/volatility3/
                # Comprobar si el paquete git está instalado. Si no lo está, instalarlo.
                  if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
                    echo ""
                    echo -e "${cColorRojo}  El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
                    echo ""
                    sudo apt-get -y update
                    sudo apt-get -y install git
                    echo ""
                  fi
                git clone https://github.com/volatilityfoundation/volatility3.git
                mv volatility3 code
                cd code

              # Compilar
                echo ""
                echo "    Compilando..."
                echo ""
                
                sudo apt-get -y install build-essential
                sudo apt-get -y install python3-dev

                python3 -m pip install wheel
                python3 -m pip install setuptools
                python3 -m pip install pyinstaller
                
                python3 -m pip install distorm3
                python3 -m pip install pycryptodome
                python3 -m pip install pillow
                python3 -m pip install openpyxl
                python3 -m pip install ujson
                python3 -m pip install pytz
                python3 -m pip install ipython
                python3 -m pip install capstone
                python3 -m pip install yara-python
                
                python3 -m pip install .

                pyinstaller --onefile --collect-all=vol.py vol.py
                pyinstaller --onefile --collect-all=volshell.py volshell.py

                #pyinstaller --onefile --hidden-import=importlib.metadata --collect-all=volatility3 volatility3.py

              # Instalar paquetes necesarios
                #echo ""
                #echo "    Instalando paquetes necesarios..."
                #echo ""
                #sudo apt-get -y update
                #sudo apt-get -y install python3
                #sudo apt-get -y install python3-pip
                #sudo apt-get -y install python3-setuptools
                #sudo apt-get -y install python3-dev
                #sudo apt-get -y install python3-venv
                #sudo apt-get -y install python3-wheel
                #sudo apt-get -y install python3-distorm3
                #sudo apt-get -y install python3-yara
                #sudo apt-get -y install python3-pillow
                #sudo apt-get -y install python3-openpyxl
                #sudo apt-get -y install python3-ujson
                #sudo apt-get -y install python3-ipython
                #sudo apt-get -y install python3-capstone
                #sudo apt-get -y install python3-pycryptodome          # Anterior pycrypto
                #sudo apt-get -y install python3-pytz-deprecation-shim # Anterior python3-pytz                sudo apt-get -y install build-essential

                
                #sudo apt-get -y install liblzma-dev

                #sudo apt-get -y install git
                #sudo apt-get -y install libraw1394-11
                #sudo apt-get -y install libcapstone-dev
                #sudo apt-get -y install capstone-tool
                #sudo apt-get -y install tzdata


                #sudo apt-get -y install libpython3-dev

              # Desactivar el entorno virtual
                echo ""
                echo "    Desactivando el entorno virtual..."
                echo ""
                deactivate

              # Copiar los binarios compilados a la carpeta de binarios del usuario
                echo ""
                echo "    Copiando los binarios a la carpeta /usr/bin/"
                echo ""
                sudo rm -f /usr/bin/volatility3
                sudo cp -vf /tmp/PythonVirtualEnvironments/volatility3/code/dist/vol      /usr/bin/volatility3
                sudo rm -f /usr/bin/volatility3shell
                sudo cp -vf /tmp/PythonVirtualEnvironments/volatility3/code/dist/volshell /usr/bin/volatility3shell
                cd ~

              # Notificar fin de ejecución del script
                echo ""
                echo -e "${cColorVerde}    La instalación ha finalizado. Se han copiado las herramientas a /usr/bin/ ${cFinColor}"
                echo -e "${cColorVerde}    Puedes ejecutarlas de la siguiente forma: ${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      volatility3 -vvv -f [RutaAlArchivo] [Plugins] ${cFinColor}"
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
        sudo apt-get -y update
        sudo apt-get -y install dialog
        echo ""
      fi

    # Crear el menú
      #menu=(dialog --timeout 5 --checklist "Marca las opciones que quieras instalar:" 22 96 16)
      menu=(dialog --checklist "Marca las opciones que quieras instalar:" 22 96 16)
        opciones=(
          1 "Instalar version para python 3.x" on
        )
      choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)
      #clear

      for choice in $choices
        do
          case $choice in

            1)

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
                  apt-get -y update
                  apt-get -y install git
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
                  apt-get -y update
                  apt-get -y install python3-venv
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
                    sudo apt-get -y update
                    sudo apt-get -y install python3-pip
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
                echo "    ~/scripts/python/volatility3/vol.py  -vvv -f [RutaAlArchivo] [Plugins] "
                echo ""
                echo "    O, si se quiere ejecutar dentro del entorno virtual:"
                echo ""
                echo "      source ~/PythonVirtualEnvironments/volatility3/bin/activate"
                echo "      ~/scripts/python/volatility3/vol.py  -vvv -f [RutaAlArchivo] [Plugins] "
                echo "      deactivate"
                echo ""

            ;;

        esac

    done

  elif [ $cVerSO == "10" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Volatilty para Debian 10 (Buster)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 10 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
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

