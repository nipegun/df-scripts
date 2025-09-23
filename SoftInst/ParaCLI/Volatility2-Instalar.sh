#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar y configurar Volatility2 en Debian
#
# Ejecución remota  (No debería pipearse con sudo, aunque luego pida permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/Volatility2-Instalar.sh | bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/Volatility2-Instalar.sh | nano -
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
      menu=(dialog --checklist "Marca las opciones que quieras instalar:" 22 96 16)
        opciones=(
          1 "Clonar el repo de volatility2 para python 2.x"                   on
          2 "  Crear el entorno virtual de python e instalar dentro"          on
          3 "    Compilar y guardar en /home/$USER/bin/"                      off
          4 "  Instalar en /home/$USER/.local/bin/"                           off
          5 "    Agregar /home/$USER/.local/bin/ al path"                     off
          6 "Clonar repo, crear venv, compilar e instalar a nivel de sistema" off
          7 "Instalación rápida (Beta)"                                       off
        )
      choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)

      for choice in $choices
        do
          case $choice in

            1)

              echo ""
              echo "  Clonando el repo de volatility2 para python 2.x..."
              echo ""

              mkdir -p ~/repos/python/
              cd ~/repos/python/
              rm -rf ~/repos/python/volatility2/
              # Comprobar si el paquete git está instalado. Si no lo está, instalarlo.
                if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
                  echo ""
                  echo -e "${cColorRojo}  El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
                  echo ""
                  sudo apt-get -y update
                  sudo apt-get -y install git
                  echo ""
                fi
              git clone https://github.com/volatilityfoundation/volatility.git
              mv ~/repos/python/volatility/ ~/repos/python/volatility2/

            ;;

            2)

              echo ""
              echo "  Creando el entorno virtual de python e instalando dentro..."
              echo ""

              # Comprobar si python 2.7 está instalado y, si no lo está, instalarlo
                if [ ! -f /usr/local/bin/python2.7 ]; then
                  # Comprobar si el paquete git está instalado. Si no lo está, instalarlo.
                    if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
                      echo ""
                      echo -e "${cColorRojo}  El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
                      echo ""
                      sudo apt-get -y update
                      sudo apt-get -y install git
                      echo ""
                    fi
                  curl -sL https://raw.githubusercontent.com/nipegun/d-scripts/refs/heads/master/InstDeSoftware/ParaCLI/Python2-Instalar.sh | sudo bash
                fi
              cd ~/repos/python/volatility2/
              # Eliminar el virtualenv actualmente instalado
                sudo apt-get -y autoremove virtualenv
              # Instalar el virtualenv de python2
                curl https://bootstrap.pypa.io/pip/2.7/get-pip.py | sudo python2.7
                sudo pip2 install virtualenv
              # Crear el entorno virtual
                /usr/local/bin/virtualenv -p /usr/local/bin/python2.7 venv
              # Crear el mensaje para mostrar cuando se entra al entorno virtual
                echo ''                                                                                        >> ~/repos/python/volatility2/venv/bin/activate
                echo 'echo -e "\n  Activando el entorno virtual de Volatility2... \n"'                         >> ~/repos/python/volatility2/venv/bin/activate
                echo 'echo -e "    Forma de uso:\n"'                                                           >> ~/repos/python/volatility2/venv/bin/activate
                echo 'echo -e "      vol.py -f [RutaAlArchivoDeDump] [Plugin]\n"'                              >> ~/repos/python/volatility2/venv/bin/activate
                echo 'echo -e "    Comandos rápidos:\n"'                                                       >> ~/repos/python/volatility2/venv/bin/activate
                echo 'echo -e "      Obtener info de la imagen:\n"'                                            >> ~/repos/python/volatility2/venv/bin/activate
                echo 'echo -e "        vol.py -f $HOME/Descargas/Evidencia.raw imageinfo\n"'                   >> ~/repos/python/volatility2/venv/bin/activate
                echo 'echo -e "      Aplicar un perfil y un plugin:\n"'                                        >> ~/repos/python/volatility2/venv/bin/activate
                echo 'echo -e "        vol.py -f $HOME/Descargas/Evidencia.raw --profile=Win7SP1x86 pslist\n"' >> ~/repos/python/volatility2/venv/bin/activate

              # Entrar al entorno virtual
                source ~/repos/python/volatility2/venv/bin/activate

              # Instalar dependencias
                pip2 install -U wheel
                pip2 install -U setuptools
                pip2 install -U distorm3
                pip2 install -U pycrypto
                pip2 install -U pillow
                pip2 install -U openpyxl
                pip2 install -U ujson
                pip2 install -U pytz
                pip2 install -U ipython
                pip2 install -U capstone
                pip2 install -U yara-python
                cd ~/repos/python/volatility2/
                pip2 install .
                #sudo ln -s /usr/local/lib/python2.7/dist-packages/usr/lib/libyara.so /usr/lib/libyara.so
                #sudo ln -s /usr/local/lib/python2.7/dist-packages/usr/lib/libyara.so /usr/local/lib/libyara.so

              # Desactivar el entorno virtual
                deactivate

              # Notificar fin de instalación en el entorno virtual
                echo ""
                echo -e "${cColorVerde}    Entorno virtual preparado. volatility2 se puede ejecutar desde el venv de la siguiente forma:${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      source ~/repos/python/volatility2/venv/bin/activate${cFinColor}"
                echo ""
                echo -e "${cColorVerde}        vol.py [Parámetros]${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      deactivate${cFinColor}"
                echo ""

            ;;

            3)

              echo ""
              echo "  Compilando y guardando en /home/$USER/bin/..."
              echo ""

              # Entrar en el entorno virtual
                source ~/repos/python/volatility2/venv/bin/activate
                cd ~/repos/python/volatility2/

              # Compilar
                pip2 install -U pyinstaller==3.6
                pyinstaller --onefile vol.py

             # Desactivar el entorno virtual
                deactivate

              # Mover el binario a la carpeta de binarios del usuario
                mkdir -p ~/bin/
                cp ~/repos/python/volatility2/dist/vol      ~/bin/volatility2

              # Notificar fin de ejecución del script
                echo ""
                echo -e "${cColorVerde}    El script compilado se ha copiado a:${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      ~/bin/volatility2${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      El binario debe ser ejecutado con precaución. Es mejor correr el script dentro del entorno virtual:${cFinColor}"
                echo ""
                echo -e "${cColorVerde}        source ~/repos/python/volatility2/venv/bin/activate${cFinColor}"
                echo ""
                echo -e "${cColorVerde}          vol.py [Parámetros]${cFinColor}"
                echo ""
                echo -e "${cColorVerde}        deactivate${cFinColor}"
                echo ""

            ;;

            4)

              echo ""
              echo "    Instalando en /home/$USER/.local/bin/..."
              echo ""

              # Comprobar si python 2.7 está instalado y, si no lo está, instalarlo
                if [ ! -f /usr/local/bin/python2.7 ]; then
                  # Comprobar si el paquete git está instalado. Si no lo está, instalarlo.
                    if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
                      echo ""
                      echo -e "${cColorRojo}  El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
                      echo ""
                      sudo apt-get -y update
                      sudo apt-get -y install git
                      echo ""
                    fi
                  curl -sL https://raw.githubusercontent.com/nipegun/d-scripts/refs/heads/master/SoftInst/ParaCLI/Python2-Instalar.sh | sudo bash
                fi

              # x
                cd ~
                /usr/local/bin/python2.7 -m ensurepip --default-pip         --user
                /usr/local/bin/python2.7 -m pip install -U pip              --user
                /usr/local/bin/python2.7 -m pip install -U wheel            --user
                /usr/local/bin/python2.7 -m pip install -U virtualenv       --user
                /usr/local/bin/python2.7 -m pip install -U setuptools       --user
                /usr/local/bin/python2.7 -m pip install -U distorm3         --user
                /usr/local/bin/python2.7 -m pip install -U pycrypto         --user
                /usr/local/bin/python2.7 -m pip install -U pillow           --user
                /usr/local/bin/python2.7 -m pip install -U openpyxl         --user
                /usr/local/bin/python2.7 -m pip install -U ujson            --user
                /usr/local/bin/python2.7 -m pip install -U pytz             --user
                /usr/local/bin/python2.7 -m pip install -U ipython          --user
                /usr/local/bin/python2.7 -m pip install -U capstone         --user
                /usr/local/bin/python2.7 -m pip install -U yara-python      --user
                /usr/local/bin/python2.7 -m pip install -U pyinstaller==3.6 --user
                /usr/local/bin/python2.7 -m pip install -U git+https://github.com/volatilityfoundation/volatility.git --user
                mv ~/.local/bin/vol.py ~/.local/bin/volatility2
                # Falta relacionar correctamente los plugins

            ;;

            5)

              echo ""
              echo "    Agregando /home/$USER/.local/bin al path..."
              echo ""
              echo 'export PATH=/home/'"$USER"'/.local/bin:$PATH' >> ~/.bashrc

            ;;

            6)

              echo ""
              echo "    Clonando repo, creando venv, compilando e instalando a nivel de sistema..."
              echo ""

              echo ""
              echo "      Comprobando si python2 está instalado..."
              echo ""
              # Comprobar si python 2.7 está instalado y, si no lo está, instalarlo
                if [ ! -f /usr/local/bin/python2.7 ]; then
                  # Comprobar si el paquete git está instalado. Si no lo está, instalarlo.
                    if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
                      echo ""
                      echo -e "${cColorRojo}  El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
                      echo ""
                      sudo apt-get -y update
                      sudo apt-get -y install git
                      echo ""
                    fi
                  curl -sL https://raw.githubusercontent.com/nipegun/d-scripts/refs/heads/master/SoftInst/ParaCLI/Python2-Instalar.sh | sudo bash
                fi

              # Preparar el entorno virtual de python
                echo ""
                echo "      Preparando el entorno virtual de python..."
                echo ""
                # Eliminar el virtualenv actualmente instalado
                  sudo apt-get -y autoremove virtualenv
                # Instalar el virtualenv de python2
                  curl https://bootstrap.pypa.io/pip/2.7/get-pip.py | sudo python2.7
                  sudo pip2 install virtualenv
                # Crear el entorno virtual
                  mkdir -p /tmp/PythonVirtualEnvironments/ 2> /dev/null
                  rm -rf /tmp/PythonVirtualEnvironments/volatility2/
                  cd /tmp/PythonVirtualEnvironments/
                  /usr/local/bin/virtualenv -p /usr/local/bin/python2.7 volatility2

              # Ingresar en el entorno virtual e instalar
                echo ""
                echo "      Ingresando en el entorno virtual..."
                echo ""
                source /tmp/PythonVirtualEnvironments/volatility2/bin/activate

              # Clonar el repo
                echo ""
                echo "      Clonando el repo..."
                echo ""
                cd /tmp/PythonVirtualEnvironments/volatility2/
                # Comprobar si el paquete git está instalado. Si no lo está, instalarlo.
                  if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
                    echo ""
                    echo -e "${cColorRojo}  El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
                    echo ""
                    sudo apt-get -y update
                    sudo apt-get -y install git
                    echo ""
                  fi
                git clone https://github.com/volatilityfoundation/volatility.git
                mv volatility code
                cd code

              # Compilar
                echo ""
                echo "    Compilando..."
                echo ""
                sudo apt-get -y install build-essential
                sudo apt-get -y install upx
                sudo apt-get -y install binutils
                sudo apt-get -y install libc-bin
                pip2 install -U wheel
                pip2 install -U setuptools
                pip2 install -U distorm3
                pip2 install -U pycrypto
                pip2 install -U pillow
                pip2 install -U openpyxl
                pip2 install -U ujson
                pip2 install -U pytz
                pip2 install -U ipython
                pip2 install -U capstone
                pip2 install -U yara-python
                pip2 install -U .
                pip2 install -U pyinstaller==3.6
                # Descargar el binario de UPX
                  vArchivoUltVers=$(curl -sL https://github.com/upx/upx/releases/latest/ | sed 's->\n->-g' | grep href | grep amd64 | grep "tar.xz" | cut -d'"' -f2 | grep -v src)
                  curl -L "$vArchivoUltVers" -o /tmp/upx.tar.xz
                  cd /tmp/
                  tar -xf upx.tar.xz
                  find /tmp -type d -name "upx-*" -exec mv {} /tmp/upx/ \;
                  sudo cp /tmp/upx/upx /usr/local/bin/
                  cd /tmp/PythonVirtualEnvironments/volatility2/code/
                sed -i -e 's|path = m.groups()[-1]|path = m.groups()[-1] if m else None\nif not path:\n\tcontinue|g' /tmp/PythonVirtualEnvironments/volatility2/lib/python2.7/site-packages/PyInstaller/depend/utils.py
                pyinstaller --onefile vol.py

              # Desactivar el entorno virtual
                echo ""
                echo "    Desactivando el entorno virtual..."
                echo ""
                deactivate

              # Copiar los binarios compilados a la carpeta de binarios del usuario
                echo ""
                echo "    Copiando los binarios a la carpeta /usr/bin/"
                echo ""
                sudo rm -f /usr/bin/volatility2
                sudo cp -vf /tmp/PythonVirtualEnvironments/volatility2/code/dist/vol      /usr/bin/volatility2
                cd ~

              # Notificar fin de ejecución del script
                echo ""
                echo -e "${cColorVerde}    La instalación ha finalizado. Se han copiado las herramientas a /usr/bin/ ${cFinColor}"
                echo -e "${cColorVerde}    Puedes ejecutarlas de la siguiente forma: ${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      volatility2 [Parámetros]${cFinColor}"
                echo ""

            ;;

            7)

              echo ""
              echo "  Instalación rápida, beta..."
              echo ""

              mkdir -p ~/VirtualEnvs/
              cd ~/VirtualEnvs/
              rm -rf ~/VirtualEnvs/volatility2/
              # Comprobar si el paquete git está instalado. Si no lo está, instalarlo.
                if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
                  echo ""
                  echo -e "${cColorRojo}  El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
                  echo ""
                  sudo apt-get -y update
                  sudo apt-get -y install git
                  echo ""
                fi
              git clone https://github.com/volatilityfoundation/volatility.git
              mv ~/VirtualEnvs/volatility/ ~/VirtualEnvs/volatility2/
              /usr/local/bin/virtualenv -p /usr/local/bin/python2.7 volatility2
              # Crear el mensaje para mostrar cuando se entra al entorno virtual
                echo ''                                                                                        >> ~/VirtualEnvs/volatility2/bin/activate
                echo 'echo -e "\n  Activando el entorno virtual de Volatility2... \n"'                         >> ~/VirtualEnvs/volatility2/bin/activate
                echo 'echo -e "    Forma de uso:\n"'                                                           >> ~/VirtualEnvs/volatility2/bin/activate
                echo 'echo -e "      vol.py -f [RutaAlArchivoDeDump] [Plugin]\n"'                              >> ~/VirtualEnvs/volatility2/bin/activate
                echo 'echo -e "    Comandos rápidos:\n"'                                                       >> ~/VirtualEnvs/volatility2/bin/activate
                echo 'echo -e "      Obtener info de la imagen:\n"'                                            >> ~/VirtualEnvs/volatility2/bin/activate
                echo 'echo -e "        vol.py -f $HOME/Descargas/Evidencia.raw imageinfo\n"'                   >> ~/VirtualEnvs/volatility2/bin/activate
                echo 'echo -e "      Aplicar un perfil y un plugin:\n"'                                        >> ~/VirtualEnvs/volatility2/bin/activate
                echo 'echo -e "        vol.py -f $HOME/Descargas/Evidencia.raw --profile=Win7SP1x86 pslist\n"' >> ~/VirtualEnvs/volatility2/bin/activate

              # Entrar al entorno virtual
                source ~/VirtualEnvs/volatility2/bin/activate

              # Instalar dependencias
                cd ~/VirtualEnvs/volatility2
                pip2 install -U wheel
                pip2 install -U setuptools
                pip2 install -U distorm3
                pip2 install -U pycrypto
                pip2 install -U pillow
                pip2 install -U openpyxl
                pip2 install -U ujson
                pip2 install -U pytz
                pip2 install -U ipython
                pip2 install -U capstone
                pip2 install -U yara-python
                
                python2 setup.py install
                #sudo ln -s /usr/local/lib/python2.7/dist-packages/usr/lib/libyara.so /usr/lib/libyara.so
                #sudo ln -s /usr/local/lib/python2.7/dist-packages/usr/lib/libyara.so /usr/local/lib/libyara.so

              # Desactivar el entorno virtual
                deactivate

              # Notificar fin de instalación en el entorno virtual
                echo ""
                echo -e "${cColorVerde}    Entorno virtual preparado. volatility2 se puede ejecutar desde el entorno virtual de la siguiente forma:${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      source ~/VirtualEnvs/volatility2/bin/activate ${cFinColor}"
                echo ""
                echo -e "${cColorVerde}        vol.py [Parámetros]${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      deactivate${cFinColor}"
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
          sudo apt-get -y update
          sudo apt-get -y install dialog
          echo ""
        fi
      menu=(dialog --checklist "Marca las opciones que quieras instalar:" 22 96 16)
        opciones=(
          1 "Clonar el repo de volatility2 para python 2.x"                   on
          2 "  Crear el entorno virtual de python e instalar dentro"          on
          3 "    Compilar y guardar en /home/$USER/bin/"                      off
          4 "  Instalar en /home/$USER/.local/bin/"                           off
          5 "    Agregar /home/$USER/.local/bin/ al path"                     off
          6 "Clonar repo, crear venv, compilar e instalar a nivel de sistema" off
          7 "Instalación rápida (Beta)"                                       off
        )
      choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)

      for choice in $choices
        do
          case $choice in

            1)

              echo ""
              echo "  Clonando el repo de volatility2 para python 2.x..."
              echo ""

              mkdir -p ~/repos/python/
              cd ~/repos/python/
              rm -rf ~/repos/python/volatility2/
              # Comprobar si el paquete git está instalado. Si no lo está, instalarlo.
                if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
                  echo ""
                  echo -e "${cColorRojo}  El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
                  echo ""
                  sudo apt-get -y update
                  sudo apt-get -y install git
                  echo ""
                fi
              git clone https://github.com/volatilityfoundation/volatility.git
              mv ~/repos/python/volatility/ ~/repos/python/volatility2/

            ;;

            2)

              echo ""
              echo "  Creando el entorno virtual de python e instalando dentro..."
              echo ""

              # Comprobar si python 2.7 está instalado y, si no lo está, instalarlo
                if [ ! -f /usr/local/bin/python2.7 ]; then
                  # Comprobar si el paquete git está instalado. Si no lo está, instalarlo.
                    if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
                      echo ""
                      echo -e "${cColorRojo}  El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
                      echo ""
                      sudo apt-get -y update
                      sudo apt-get -y install git
                      echo ""
                    fi
                  curl -sL https://raw.githubusercontent.com/nipegun/d-scripts/refs/heads/master/SoftInst/ParaCLI/Python2-Instalar.sh | sudo bash
                fi
              cd ~/repos/python/volatility2/
              # Eliminar el virtualenv actualmente instalado
                sudo apt-get -y autoremove virtualenv
              # Instalar el virtualenv de python2
                curl https://bootstrap.pypa.io/pip/2.7/get-pip.py | sudo python2.7
                sudo pip2 install virtualenv
              # Crear el entorno virtual
                /usr/local/bin/virtualenv -p /usr/local/bin/python2.7 venv
              # Crear el mensaje para mostrar cuando se entra al entorno virtual
                echo ''                                                                                        >> ~/repos/python/volatility2/venv/bin/activate
                echo 'echo -e "\n  Activando el entorno virtual de Volatility2... \n"'                         >> ~/repos/python/volatility2/venv/bin/activate
                echo 'echo -e "    Forma de uso:\n"'                                                           >> ~/repos/python/volatility2/venv/bin/activate
                echo 'echo -e "      vol.py -f [RutaAlArchivoDeDump] [Plugin]\n"'                              >> ~/repos/python/volatility2/venv/bin/activate
                echo 'echo -e "    Comandos rápidos:\n"'                                                       >> ~/repos/python/volatility2/venv/bin/activate
                echo 'echo -e "      Obtener info de la imagen:\n"'                                            >> ~/repos/python/volatility2/venv/bin/activate
                echo 'echo -e "        vol.py -f $HOME/Descargas/Evidencia.raw imageinfo\n"'                   >> ~/repos/python/volatility2/venv/bin/activate
                echo 'echo -e "      Aplicar un perfil y un plugin:\n"'                                        >> ~/repos/python/volatility2/venv/bin/activate
                echo 'echo -e "        vol.py -f $HOME/Descargas/Evidencia.raw --profile=Win7SP1x86 pslist\n"' >> ~/repos/python/volatility2/venv/bin/activate

              # Entrar al entorno virtual
                source ~/repos/python/volatility2/venv/bin/activate

              # Instalar dependencias
                pip2 install -U wheel
                pip2 install -U setuptools
                pip2 install -U distorm3
                pip2 install -U pycrypto
                pip2 install -U pillow
                pip2 install -U openpyxl
                pip2 install -U ujson
                pip2 install -U pytz
                pip2 install -U ipython
                pip2 install -U capstone
                pip2 install -U yara-python
                cd ~/repos/python/volatility2/
                pip2 install .
                #sudo ln -s /usr/local/lib/python2.7/dist-packages/usr/lib/libyara.so /usr/lib/libyara.so
                #sudo ln -s /usr/local/lib/python2.7/dist-packages/usr/lib/libyara.so /usr/local/lib/libyara.so

              # Desactivar el entorno virtual
                deactivate

              # Notificar fin de instalación en el entorno virtual
                echo ""
                echo -e "${cColorVerde}    Entorno virtual preparado. volatility2 se puede ejecutar desde el venv de la siguiente forma:${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      source ~/repos/python/volatility2/venv/bin/activate${cFinColor}"
                echo ""
                echo -e "${cColorVerde}        vol.py [Parámetros]${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      deactivate${cFinColor}"
                echo ""

            ;;

            3)

              echo ""
              echo "  Compilando y guardando en /home/$USER/bin/..."
              echo ""

              # Entrar en el entorno virtual
                source ~/repos/python/volatility2/venv/bin/activate
                cd ~/repos/python/volatility2/

              # Compilar
                pip2 install -U pyinstaller==3.6
                pyinstaller --onefile vol.py

             # Desactivar el entorno virtual
                deactivate

              # Mover el binario a la carpeta de binarios del usuario
                mkdir -p ~/bin/
                cp ~/repos/python/volatility2/dist/vol      ~/bin/volatility2

              # Notificar fin de ejecución del script
                echo ""
                echo -e "${cColorVerde}    El script compilado se ha copiado a:${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      ~/bin/volatility2${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      El binario debe ser ejecutado con precaución. Es mejor correr el script dentro del entorno virtual:${cFinColor}"
                echo ""
                echo -e "${cColorVerde}        source ~/repos/python/volatility2/venv/bin/activate${cFinColor}"
                echo ""
                echo -e "${cColorVerde}          vol.py [Parámetros]${cFinColor}"
                echo ""
                echo -e "${cColorVerde}        deactivate${cFinColor}"
                echo ""

            ;;

            4)

              echo ""
              echo "    Instalando en /home/$USER/.local/bin/..."
              echo ""

              # Comprobar si python 2.7 está instalado y, si no lo está, instalarlo
                if [ ! -f /usr/local/bin/python2.7 ]; then
                  # Comprobar si el paquete git está instalado. Si no lo está, instalarlo.
                    if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
                      echo ""
                      echo -e "${cColorRojo}  El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
                      echo ""
                      sudo apt-get -y update
                      sudo apt-get -y install git
                      echo ""
                    fi
                  curl -sL https://raw.githubusercontent.com/nipegun/d-scripts/refs/heads/master/SoftInst/ParaCLI/Python2-Instalar.sh | sudo bash
                fi

              # x
                cd ~
                /usr/local/bin/python2.7 -m ensurepip --default-pip         --user
                /usr/local/bin/python2.7 -m pip install -U pip              --user
                /usr/local/bin/python2.7 -m pip install -U wheel            --user
                /usr/local/bin/python2.7 -m pip install -U virtualenv       --user
                /usr/local/bin/python2.7 -m pip install -U setuptools       --user
                /usr/local/bin/python2.7 -m pip install -U distorm3         --user
                /usr/local/bin/python2.7 -m pip install -U pycrypto         --user
                /usr/local/bin/python2.7 -m pip install -U pillow           --user
                /usr/local/bin/python2.7 -m pip install -U openpyxl         --user
                /usr/local/bin/python2.7 -m pip install -U ujson            --user
                /usr/local/bin/python2.7 -m pip install -U pytz             --user
                /usr/local/bin/python2.7 -m pip install -U ipython          --user
                /usr/local/bin/python2.7 -m pip install -U capstone         --user
                /usr/local/bin/python2.7 -m pip install -U yara-python      --user
                /usr/local/bin/python2.7 -m pip install -U pyinstaller==3.6 --user
                /usr/local/bin/python2.7 -m pip install -U git+https://github.com/volatilityfoundation/volatility.git --user
                mv ~/.local/bin/vol.py ~/.local/bin/volatility2
                # Falta relacionar correctamente los plugins

            ;;

            5)

              echo ""
              echo "    Agregando /home/$USER/.local/bin al path..."
              echo ""
              echo 'export PATH=/home/'"$USER"'/.local/bin:$PATH' >> ~/.bashrc

            ;;

            6)

              echo ""
              echo "    Clonando repo, creando venv, compilando e instalando a nivel de sistema..."
              echo ""

              echo ""
              echo "      Comprobando si python2 está instalado..."
              echo ""
              # Comprobar si python 2.7 está instalado y, si no lo está, instalarlo
                if [ ! -f /usr/local/bin/python2.7 ]; then
                  # Comprobar si el paquete git está instalado. Si no lo está, instalarlo.
                    if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
                      echo ""
                      echo -e "${cColorRojo}  El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
                      echo ""
                      sudo apt-get -y update
                      sudo apt-get -y install git
                      echo ""
                    fi
                  curl -sL https://raw.githubusercontent.com/nipegun/d-scripts/refs/heads/master/SoftInst/ParaCLI/Python2-Instalar.sh | sudo bash
                fi

              # Preparar el entorno virtual de python
                echo ""
                echo "      Preparando el entorno virtual de python..."
                echo ""
                # Eliminar el virtualenv actualmente instalado
                  sudo apt-get -y autoremove virtualenv
                # Instalar el virtualenv de python2
                  curl https://bootstrap.pypa.io/pip/2.7/get-pip.py | sudo python2.7
                  sudo pip2 install virtualenv
                # Crear el entorno virtual
                  mkdir -p /tmp/PythonVirtualEnvironments/ 2> /dev/null
                  rm -rf /tmp/PythonVirtualEnvironments/volatility2/
                  cd /tmp/PythonVirtualEnvironments/
                  /usr/local/bin/virtualenv -p /usr/local/bin/python2.7 volatility2

              # Ingresar en el entorno virtual e instalar
                echo ""
                echo "      Ingresando en el entorno virtual..."
                echo ""
                source /tmp/PythonVirtualEnvironments/volatility2/bin/activate

              # Clonar el repo
                echo ""
                echo "      Clonando el repo..."
                echo ""
                cd /tmp/PythonVirtualEnvironments/volatility2/
                # Comprobar si el paquete git está instalado. Si no lo está, instalarlo.
                  if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
                    echo ""
                    echo -e "${cColorRojo}  El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
                    echo ""
                    sudo apt-get -y update
                    sudo apt-get -y install git
                    echo ""
                  fi
                git clone https://github.com/volatilityfoundation/volatility.git
                mv volatility code
                cd code

              # Compilar
                echo ""
                echo "    Compilando..."
                echo ""
                sudo apt-get -y install build-essential
                sudo apt-get -y install upx
                sudo apt-get -y install binutils
                sudo apt-get -y install libc-bin
                pip2 install -U wheel
                pip2 install -U setuptools
                pip2 install -U distorm3
                pip2 install -U pycrypto
                pip2 install -U pillow
                pip2 install -U openpyxl
                pip2 install -U ujson
                pip2 install -U pytz
                pip2 install -U ipython
                pip2 install -U capstone
                pip2 install -U yara-python
                pip2 install -U .
                pip2 install -U pyinstaller==3.6
                # Descargar el binario de UPX
                  vArchivoUltVers=$(curl -sL https://github.com/upx/upx/releases/latest/ | sed 's->\n->-g' | grep href | grep amd64 | grep "tar.xz" | cut -d'"' -f2 | grep -v src)
                  curl -L "$vArchivoUltVers" -o /tmp/upx.tar.xz
                  cd /tmp/
                  tar -xf upx.tar.xz
                  find /tmp -type d -name "upx-*" -exec mv {} /tmp/upx/ \;
                  sudo cp /tmp/upx/upx /usr/local/bin/
                  cd /tmp/PythonVirtualEnvironments/volatility2/code/
                sed -i -e 's|path = m.groups()[-1]|path = m.groups()[-1] if m else None\nif not path:\n\tcontinue|g' /tmp/PythonVirtualEnvironments/volatility2/lib/python2.7/site-packages/PyInstaller/depend/utils.py
                pyinstaller --onefile vol.py

              # Desactivar el entorno virtual
                echo ""
                echo "    Desactivando el entorno virtual..."
                echo ""
                deactivate

              # Copiar los binarios compilados a la carpeta de binarios del usuario
                echo ""
                echo "    Copiando los binarios a la carpeta /usr/bin/"
                echo ""
                sudo rm -f /usr/bin/volatility2
                sudo cp -vf /tmp/PythonVirtualEnvironments/volatility2/code/dist/vol      /usr/bin/volatility2
                cd ~

              # Notificar fin de ejecución del script
                echo ""
                echo -e "${cColorVerde}    La instalación ha finalizado. Se han copiado las herramientas a /usr/bin/ ${cFinColor}"
                echo -e "${cColorVerde}    Puedes ejecutarlas de la siguiente forma: ${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      volatility2 [Parámetros]${cFinColor}"
                echo ""

            ;;

            7)

              echo ""
              echo "  Instalación rápida, beta..."
              echo ""

              mkdir -p ~/VirtualEnvs/
              cd ~/VirtualEnvs/
              rm -rf ~/VirtualEnvs/volatility2/
              # Comprobar si el paquete git está instalado. Si no lo está, instalarlo.
                if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
                  echo ""
                  echo -e "${cColorRojo}  El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
                  echo ""
                  sudo apt-get -y update
                  sudo apt-get -y install git
                  echo ""
                fi
              git clone https://github.com/volatilityfoundation/volatility.git
              mv ~/VirtualEnvs/volatility/ ~/VirtualEnvs/volatility2/
              /usr/local/bin/virtualenv -p /usr/local/bin/python2.7 volatility2
              # Crear el mensaje para mostrar cuando se entra al entorno virtual
                echo ''                                                                                        >> ~/VirtualEnvs/volatility2/bin/activate
                echo 'echo -e "\n  Activando el entorno virtual de Volatility2... \n"'                         >> ~/VirtualEnvs/volatility2/bin/activate
                echo 'echo -e "    Forma de uso:\n"'                                                           >> ~/VirtualEnvs/volatility2/bin/activate
                echo 'echo -e "      vol.py -f [RutaAlArchivoDeDump] [Plugin]\n"'                              >> ~/VirtualEnvs/volatility2/bin/activate
                echo 'echo -e "    Comandos rápidos:\n"'                                                       >> ~/VirtualEnvs/volatility2/bin/activate
                echo 'echo -e "      Obtener info de la imagen:\n"'                                            >> ~/VirtualEnvs/volatility2/bin/activate
                echo 'echo -e "        vol.py -f $HOME/Descargas/Evidencia.raw imageinfo\n"'                   >> ~/VirtualEnvs/volatility2/bin/activate
                echo 'echo -e "      Aplicar un perfil y un plugin:\n"'                                        >> ~/VirtualEnvs/volatility2/bin/activate
                echo 'echo -e "        vol.py -f $HOME/Descargas/Evidencia.raw --profile=Win7SP1x86 pslist\n"' >> ~/VirtualEnvs/volatility2/bin/activate

              # Entrar al entorno virtual
                source ~/VirtualEnvs/volatility2/bin/activate

              # Instalar dependencias
                cd ~/VirtualEnvs/volatility2
                pip2 install -U wheel
                pip2 install -U setuptools
                pip2 install -U distorm3
                pip2 install -U pycrypto
                pip2 install -U pillow
                pip2 install -U openpyxl
                pip2 install -U ujson
                pip2 install -U pytz
                pip2 install -U ipython
                pip2 install -U capstone
                pip2 install -U yara-python
                
                python2 setup.py install
                #sudo ln -s /usr/local/lib/python2.7/dist-packages/usr/lib/libyara.so /usr/lib/libyara.so
                #sudo ln -s /usr/local/lib/python2.7/dist-packages/usr/lib/libyara.so /usr/local/lib/libyara.so

              # Desactivar el entorno virtual
                deactivate

              # Notificar fin de instalación en el entorno virtual
                echo ""
                echo -e "${cColorVerde}    Entorno virtual preparado. volatility2 se puede ejecutar desde el entorno virtual de la siguiente forma:${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      source ~/VirtualEnvs/volatility2/bin/activate ${cFinColor}"
                echo ""
                echo -e "${cColorVerde}        vol.py [Parámetros]${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      deactivate${cFinColor}"
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
                sudo apt-get -y install upx
                sudo apt-get -y install binutils
                sudo apt-get -y install curl
              curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
              sudo python2 get-pip.py
              sudo python2 -m pip install -U setuptools wheel
              python2 -m pip install -U distorm3 yara pycrypto pillow openpyxl ujson pytz ipython capstone yara-python
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
                    apt-get -y update
                    apt-get -y install git
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
        apt-get -y update
        apt-get -y install git
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
