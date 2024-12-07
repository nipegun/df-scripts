#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar browser-history en Debian
#
# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/BrowserHistory-Instalar.sh | bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/BrowserHistory-Instalar.sh | nano -
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
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de browser-history para Debian 13 (x)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 13 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "12" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de browser-history para Debian 12 (Bookworm)...${cFinColor}"
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
      menu=(dialog --checklist "Marca como quieres instalar la herramienta:" 22 70 16)
        opciones=(
          1 "Clonar el repo de browser-history"                               on
          2 "  Crear el entorno virtual de python e instalar dentro"          on
          3 "    Compilar e instalar en /home/$USER/bin/"                     off
          4 "  Instalar en /home/$USER/.local/bin/"                           off
          5 "    Agregar /home/$USER/.local/bin/ al path"                     off
          6 "Clonar repo, crear venv, compilar e instalar a nivel de sistema" off
          7 "Otro tipo de instalación"                                        off
        )
      choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)

      for choice in $choices
        do
          case $choice in

            1)

              echo ""
              echo "  Clonando el repo..."
              echo ""

              # Clonar el repo
                mkdir -p ~/repos/python/
                cd ~/repos/python/
                rm -rf ~/repos/python/browser-history/
                # Comprobar si el paquete git está instalado. Si no lo está, instalarlo.
                  if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
                    echo ""
                    echo -e "${cColorRojo}  El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
                    echo ""
                    sudo apt-get -y update && sudo apt-get -y install git
                    echo ""
                  fi
                git clone https://github.com/browser-history/browser-history.git

            ;;

            2)

              echo ""
              echo "    Creando el entorno virtual de python e instalando dentro..."
              echo ""

              cd ~/repos/python/browser-history/
              # Comprobar si el paquete python3-venv está instalado. Si no lo está, instalarlo.
                if [[ $(dpkg-query -s python3-venv 2>/dev/null | grep installed) == "" ]]; then
                  echo ""
                  echo -e "${cColorRojo}  El paquete python3-venv no está instalado. Iniciando su instalación...${cFinColor}"
                  echo ""
                  sudo apt-get -y update && sudo apt-get -y install python3-venv
                  echo ""
                fi
              python3 -m venv venv
              # Crear el mensaje para mostrar cuando se entra al entorno virtual
                echo 'echo -e "\n  Activando el entorno virtual de browser-history... \n"' >> ~/repos/python/browser-history/venv/bin/activate
              # Entrar al entorno virtual
                source ~/repos/python/browser-history/venv/bin/activate
              # Instalar requerimientos
                python3 -m pip install .
              # Salir del entorno virtual
                deactivate
              # Notificar fin de instalación en el entorno virtual
                echo ""
                echo -e "${cColorVerde}    Entorno virtual preparado. browser-history se puede ejecutar desde el venv de la siguiente forma:${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      source ~/repos/python/browser-history/venv/bin/activate${cFinColor}"
                echo ""
                echo -e "${cColorVerde}        browser-history [Parámetros]${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      deactivate${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      PARÁMETROS: ${cFinColor}"
                echo ""
                echo -e "${cColorVerde}        --help            (show this help message and exit) ${cFinColor}"
                echo -e "${cColorVerde}        --type TYPE       (argument to decide whether to retrieve history or bookmarks. Should be one of history, bookmarks. Default is history). ${cFinColor}"
                echo -e "${cColorVerde}        --browser BROWSER (browser to retrieve history or bookmarks from. Should be one of all, default, Chromium, Chrome, Edge, Opera, OperaGX, Brave, Vivaldi, Epic, Firefox, LibreWolf, Safari. Default is all (gets history or bookmarks from all browsers). ${cFinColor}"
                echo -e "${cColorVerde}        --format FORMAT   (Format to be used in output. Should be one of csv, json, jsonl. Default is infer (format is inferred from the output file's extension. If no output file (-o) is specified, it defaults to csv). ${cFinColor}"
                echo -e "${cColorVerde}        --output OUTPUT   (File where history output or bookmark output is to be written. If not provided, standard output is used). ${cFinColor}"
                echo -e "${cColorVerde}        --profile PROFILE  (Specify the profile from which to fetch history or bookmarks. If not provided all profiles are fetched). ${cFinColor}"
                echo -e "${cColorVerde}        --show-profiles BROWSER (List all available profiles for a given browser where browser can be one of default, Chromium, Chrome, Edge, Opera, OperaGX, Brave, Vivaldi, Epic, Firefox, LibreWolf, Safari. The browser must always be provided).${cFinColor}"
                echo ""

            ;;

            3)

              echo ""
              echo "      Compilando y guardando en /home/$USER/bin/..."
              echo ""

              sudo apt-get -y update
              sudo apt-get -y install python3-pip
              sudo apt-get -y install python3-venv
              sudo apt-get -y install python3-wheel
              sudo apt-get -y install python3-setuptools

              # Entrar al entorno virtual
                source ~/repos/python/browser-history/venv/bin/activate
                cd ~/repos/python/browser-history/

              # Instalar el instalador
                python3 -m pip install pyinstaller

              # Compilar
                pyinstaller --onefile --collect-all=browser-history browser-history.py

              # Copiar el binario a /usr/bin
                mkdir ~/bin/
                cp -f ~/repos/python/browser-history/dist/browser-history ~/bin/

              # Desactivar el entorno virtual
                deactivate

              # Notificar fin de ejecución del script
                echo ""
                echo "  El script ha finalizado. browser-history se ha descargado, compilado e instalado."
                echo ""
                echo "    Puedes encontrar el binario en ~/bin/browser-history"
                echo ""
                echo "  El binario debe ser usado con precaución. Es mejor correr el script directamente con python, de la siguiente manera:"
                echo ""
                echo "    source ~/scripts/python/browser-history/venv/bin/activate"
                echo "    python3 ~/scripts/python/browser-history/browser-history.py [Argumentos]"
                echo "    deactivate"
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
                  sudo apt-get -y update && sudo apt-get -y install python3-setuptools
                  echo ""
                fi
              cd ~/repos/python/browser-history/
              python3 setup.py install --user
              cd ~

              # Notificar fin de ejecución del script
                echo ""
                echo -e "${cColorVerde}    Para ejecutar browser-history instalado en /home/$USER/.local/bin/:${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      Si al instalar has marcado 'Agregar /home/$USER/.local/bin/ al path', simplemente ejecuta:${cFinColor}"
                echo ""
                echo -e "${cColorVerde}        browser-history [Parámetros]${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      Si al instalar NO has marcado 'Agregar /home/$USER/.local/bin/ al path', ejecuta:${cFinColor}"
                echo ""
                echo -e "${cColorVerde}       ~/.local/bin/browser-history [Parámetros]${cFinColor}"
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
                mkdir -p /tmp/PythonVirtualEnvironments/ 2> /dev/null
                cd /tmp/PythonVirtualEnvironments/
                rm -rf /tmp/PythonVirtualEnvironments/browser-history/
                python3 -m venv browser-history

              # Ingresar en el entorno virtual e instalar plaso
                echo ""
                echo "    Ingresando en el entorno virtual e instalando plaso..."
                echo ""
                source /tmp/PythonVirtualEnvironments/browser-history/bin/activate

              # Clonar el repo
                echo ""
                echo "  Clonando el repo..."
                echo ""
                cd /tmp/PythonVirtualEnvironments/browser-history/
                git clone https://github.com/browser-history/browser-history.git
                mv browser-history code

              # Compilar
                echo ""
                echo "    Compilando..."
                echo ""
                cd code
                python3 -m pip install -r requirements.txt
                python3 -m pip install -r requirements-dev.txt
                python3 -m pip install wheel
                python3 -m pip install setuptools
                python3 -m pip install pyinstaller
                pyinstaller --onefile --hidden-import=importlib.metadata --collect-all=browser-history browser-history.py

              # Desactivar el entorno virtual
                echo ""
                echo "    Desactivando el entorno virtual..."
                echo ""
                deactivate

              # Copiar los binarios compilados a la carpeta de binarios del usuario
                echo ""
                echo "    Copiando los binarios a la carpeta /usr/bin/"
                echo ""
                sudo rm -f /usr/bin/browser-history
                sudo cp -vf /tmp/PythonVirtualEnvironments/browser-history/code/dist/browser-history /usr/bin/browser-history
                cd ~

              # Notificar fin de ejecución del script
                echo ""
                echo -e "${cColorVerde}    La instalación ha finalizado. Se han copiado las herramientas de plaso a /usr/bin/ ${cFinColor}"
                echo -e "${cColorVerde}    Puedes ejecutarlas de la siguiente forma: ${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      browser-history [Parámetros]${cFinColor}"
                echo ""

            ;;

            7)

              echo ""
              echo "  Otro tipo de instalación (Pruebas)..."
              echo ""

            ;;


        esac

    done

  elif [ $cVerSO == "11" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de browser-history para Debian 11 (Bullseye)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 11 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "10" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de browser-history para Debian 10 (Buster)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 10 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "9" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de browser-history para Debian 9 (Stretch)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 9 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "8" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de browser-history para Debian 8 (Jessie)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 8 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "7" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de browser-history para Debian 7 (Wheezy)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 7 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  fi
