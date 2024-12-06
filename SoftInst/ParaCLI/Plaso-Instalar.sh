#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar y configurar Plaso en Debian
#
# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/Plaso-Instalar.sh | bash  (No debe curlearse con sudo, aunque luego pida sudo)
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

    # Crear el menú
      # Comprobar si el paquete dialog está instalado. Si no lo está, instalarlo.
        if [[ $(dpkg-query -s dialog 2>/dev/null | grep installed) == "" ]]; then
          echo ""
          echo -e "${cColorRojo}  El paquete dialog no está instalado. Iniciando su instalación...${cFinColor}"
          echo ""
          sudo apt-get -y update && sudo apt-get -y install dialog
          echo ""
        fi
      menu=(dialog --timeout 10 --checklist "Marca como quieres instalar la herramienta:" 22 70 16)
        opciones=(
          1 "Clonar el repo de plaso "                                        on
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
              echo "  Clonando repo..."
              echo ""

              mkdir -p ~/repos/python/
              cd ~/repos/python/
              rm -rf ~/repos/python/plaso/
              # Comprobar si el paquete git está instalado. Si no lo está, instalarlo.
                if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
                  echo ""
                  echo -e "${cColorRojo}  El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
                  echo ""
                  sudo apt-get -y update && sudo apt-get -y install git
                  echo ""
                fi
              git clone https://github.com/log2timeline/plaso.git

            ;;

            2)

              echo ""
              echo "  Creando el entorno virtual de python e instalando dentro..."
              echo ""

              cd ~/repos/python/plaso/
              # Comprobar si el paquete python3-venv está instalado. Si no lo está, instalarlo.
                if [[ $(dpkg-query -s python3-venv 2>/dev/null | grep installed) == "" ]]; then
                  echo ""
                  echo -e "${cColorRojo}  El paquete python3-venv no está instalado. Iniciando su instalación...${cFinColor}"
                  echo ""
                  sudo apt-get -y update && sudo apt-get -y install python3-venv
                  echo ""
                fi
              python3 -m venv venv
              # Entrar al entorno virtual
                source ~/repos/python/plaso/venv/bin/activate
              # Instalar requerimientos
                python3 -m pip install -r requirements.txt
                python3 -m pip install -r test_requirements.txt
                python3 -m pip install .
              # Salir del entorno virtual
                deactivate

              # Notificar fin de ejecución del script
                echo ""
                echo -e "${cColorVerde}    Entorno virtual preparado. Las herramientas de plaso se pueden ejecutar desde el venv de la siguiente forma:${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      source ~/repos/python/plaso/venv/bin/activate${cFinColor}"
                echo ""
                echo -e "${cColorVerde}        image_export [Parámetros]${cFinColor}"
                echo -e "${cColorVerde}        log2timeline [Parámetros]${cFinColor}"
                echo -e "${cColorVerde}        normalizer   [Parámetros]${cFinColor}"
                echo -e "${cColorVerde}        psort        [Parámetros]${cFinColor}"
                echo -e "${cColorVerde}        psteal       [Parámetros]${cFinColor}"
                echo -e "${cColorVerde}        pinfo        [Parámetros]${cFinColor}"
                echo -e "${cColorVerde}        stats        [Parámetros]${cFinColor}"
                echo -e "${cColorVerde}        validator    [Parámetros]${cFinColor}"
                echo -e "${cColorVerde}        xattr        [Parámetros]${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      deactivate${cFinColor}"
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
                source ~/repos/python/plaso/venv/bin/activate
                cd ~/repos/python/plaso/

              # Instalar el instalador
                python3 -m pip install pyinstaller

              # Compilar
                echo ""
                echo "      Intentando compilar image_export..."
                echo ""

                cd ~/repos/python/plaso/plaso/scripts/
                pyinstaller --onefile --collect-all=image_export.py image_export.py
                pyinstaller --onefile --collect-all=log2timeline.py log2timeline.py
                pyinstaller --onefile --collect-all=pinfo.py        pinfo.py
                pyinstaller --onefile --collect-all=psort.py        psort.py
                pyinstaller --onefile --collect-all=psteal.py       psteal.py

              # Desactivar el entorno virtual
                deactivate

              # Copiar el binario a /usr/bin
                mkdir ~/bin/
                cp -f ~/repos/python/plaso/plaso/scripts/dist/image_export ~/bin/
                cp -f ~/repos/python/plaso/plaso/scripts/dist/log2timeline ~/bin/
                cp -f ~/repos/python/plaso/plaso/scripts/dist/pinfo        ~/bin/
                cp -f ~/repos/python/plaso/plaso/scripts/dist/psort        ~/bin/
                cp -f ~/repos/python/plaso/plaso/scripts/dist/psteal       ~/bin/

              # Notificar fin de ejecución del script
                echo ""
                echo "  El script ha finalizado. plaso se ha descargado, compilado e instalado."
                echo ""
                echo "    Puedes encontrar el binario en ~/bin/plaso"
                echo ""
                echo "  El binario debe ser usado con precaución. Es mejor correr el script directamente con python, de la siguiente manera:"
                echo ""
                echo "    source ~/PythonVirtualEnvironments/plaso/bin/activate"
                echo "    python3 ~/scripts/python/analyzeMFT/plaso.py [Argumentos]"
                echo "    deactivate"
                echo ""

            ;;

            4)

              echo ""
              echo "    Instalando en /home/$USER/.local/bin/..."
              echo ""

              # Comprobar si el paquete python3-setuptools está instalado. Si no lo está, instalarlo.
                if [[ $(dpkg-query -s python3-setuptools 2>/dev/null | grep installed) == "" ]]; then
                  echo ""
                  echo -e "${cColorRojo}  El paquete python3-setuptools no está instalado. Iniciando su instalación...${cFinColor}"
                  echo ""
                  sudo apt-get -y update && sudo apt-get -y install python3-setuptools
                  echo ""
                fi
              cd ~/repos/python/plaso/
              python3 setup.py install --user
              cd ~

              # Notificar fin de ejecución del script
                echo ""
                echo -e "${cColorVerde}    La instalación ha finalizado. Para ejecutar plaso:${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      Si al instalar has marcado 'Agregar /home/$USER/.local/bin/ al path', simplemente ejecuta:${cFinColor}"
                echo ""
                echo -e "${cColorVerde}        image_export [Parámetros]${cFinColor}"
                echo -e "${cColorVerde}        log2timeline [Parámetros]${cFinColor}"
                echo -e "${cColorVerde}        pinfo [Parámetros]${cFinColor}"
                echo -e "${cColorVerde}        psort [Parámetros]${cFinColor}"
                echo -e "${cColorVerde}        psteal [Parámetros]${cFinColor}"
                echo -e "${cColorVerde}        xattr [Parámetros]${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      Si al instalar NO has marcado 'Agregar /home/$USER/.local/bin/ al path', ejecuta:${cFinColor}"
                echo ""
                echo -e "${cColorVerde}       ~/.local/bin/image_export [Parámetros]${cFinColor}"
                echo -e "${cColorVerde}       ~/.local/bin/log2timeline [Parámetros]${cFinColor}"
                echo -e "${cColorVerde}       ~/.local/bin/pinfo [Parámetros]${cFinColor}"
                echo -e "${cColorVerde}       ~/.local/bin/psort [Parámetros]${cFinColor}"
                echo -e "${cColorVerde}       ~/.local/bin/psteal [Parámetros]${cFinColor}"
                echo -e "${cColorVerde}       ~/.local/bin/xattr [Parámetros]${cFinColor}"
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
              rm -rf /tmp/PythonVirtualEnvironments/plaso/
              python3 -m venv plaso

              # Ingresar en el entorno virtual e instalar plaso
              echo ""
              echo "    Ingresando en el entorno virtual e instalando plaso..."
              echo ""
              source /tmp/PythonVirtualEnvironments/plaso/bin/activate
              python3 -m pip install plaso

              # Compilar los scripts
              echo ""
              echo "    Compilando los scripts..."
              echo ""
              python3 -m pip install pyinstaller
              cd /tmp/PythonVirtualEnvironments/plaso/bin/
              echo ""
              echo "      Intentando compilar image_export..."
              echo ""
              pyinstaller --onefile image_export \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_core_location.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_mdns.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_open_directory.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/windows_nt.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/time_zone_information.yaml:plaso/preprocessors \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/mounted_devices.yaml:plaso/preprocessors
              echo ""
              echo "      Intentando compilar log2timeline..."
              echo ""
              pyinstaller --onefile log2timeline \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_core_location.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_mdns.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_open_directory.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/windows_nt.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/time_zone_information.yaml:plaso/preprocessors \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/mounted_devices.yaml:plaso/preprocessors
              echo ""
              echo "      Intentando compilar normalizer..."
              echo ""
              pyinstaller --onefile normalizer \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_core_location.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_mdns.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_open_directory.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/windows_nt.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/time_zone_information.yaml:plaso/preprocessors \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/mounted_devices.yaml:plaso/preprocessors
              echo ""
              echo "      Intentando compilar pinfo..."
              echo ""
              vRutaALibPythonSO=$(find /usr/lib/ -name "libpython3.11.so.1.0" 2>/dev/null)
              pyinstaller --onefile pinfo \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_core_location.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_mdns.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_open_directory.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/windows_nt.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/time_zone_information.yaml:plaso/preprocessors \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/mounted_devices.yaml:plaso/preprocessors \
              --add-binary "$vRutaALibPythonSO:."
              echo ""
              echo "      Intentando compilar psort..."
              echo ""
              vRutaALibPythonSO=$(find /usr/lib/python* -name "libpython3.11.so" 2>/dev/null)
              pyinstaller --onefile psort \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_core_location.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_mdns.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_open_directory.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/windows_nt.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/time_zone_information.yaml:plaso/preprocessors \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/mounted_devices.yaml:plaso/preprocessors \
              --add-binary "$vRutaALibPythonSO:."
              echo ""
              echo "      Intentando compilar psteal..."
              echo ""
              vRutaALibPythonSO=$(find /usr/lib/ -name "libpython3.11.so.1.0" 2>/dev/null)
              pyinstaller --onefile psteal \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_core_location.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_mdns.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_open_directory.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/windows_nt.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/time_zone_information.yaml:plaso/preprocessors \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/mounted_devices.yaml:plaso/preprocessors \
              --add-binary "$vRutaALibPythonSO:."
              echo ""
              echo "      Intentando compilar stats..."
              echo ""
              pyinstaller --onefile stats \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_core_location.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_mdns.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_open_directory.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/windows_nt.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/time_zone_information.yaml:plaso/preprocessors \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/mounted_devices.yaml:plaso/preprocessors
              echo ""
              echo "      Intentando compilar validator..."
              echo ""
              pyinstaller --onefile validator \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_core_location.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_mdns.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_open_directory.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/windows_nt.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/time_zone_information.yaml:plaso/preprocessors \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/mounted_devices.yaml:plaso/preprocessors
              echo ""
              echo "      Intentando compilar xattr..."
              echo ""
              pyinstaller --onefile xattr \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_core_location.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_mdns.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/macos_open_directory.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/parsers/windows_nt.yaml:plaso/parsers \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/time_zone_information.yaml:plaso/preprocessors \
              --add-data /tmp/PythonVirtualEnvironments/plaso/lib/python3.11/site-packages/plaso/preprocessors/mounted_devices.yaml:plaso/preprocessors \
              --hidden-import=_cffi_backend

              # Desactivar el entorno virtual
                echo ""
                echo "    Desactivando el entorno virtual..."
                echo ""
                deactivate

              # Copiar los binarios compilados a la carpeta de binarios del usuario
                echo ""
                echo "    Copiando los binarios a la carpeta /usr/bin/"
                echo ""
                sudo rm -f /usr/bin/plaso-image_export
                sudo rm -f /usr/bin/plaso-log2timeline
                sudo rm -f /usr/bin/plaso-normalizer
                sudo rm -f /usr/bin/plaso-psort
                sudo rm -f /usr/bin/plaso-psteal
                sudo rm -f /usr/bin/plaso-pinfo
                sudo rm -f /usr/bin/plaso-stats
                sudo rm -f /usr/bin/plaso-validator
                sudo rm -f /usr/bin/plaso-xattr
                sudo cp -vf /tmp/PythonVirtualEnvironments/plaso/bin/dist/image_export /usr/bin/plaso-image_export
                sudo cp -vf /tmp/PythonVirtualEnvironments/plaso/bin/dist/log2timeline /usr/bin/plaso-log2timeline
                sudo cp -vf /tmp/PythonVirtualEnvironments/plaso/bin/dist/normalizer   /usr/bin/plaso-normalizer
                sudo cp -vf /tmp/PythonVirtualEnvironments/plaso/bin/dist/psort        /usr/bin/plaso-psort
                sudo cp -vf /tmp/PythonVirtualEnvironments/plaso/bin/dist/psteal       /usr/bin/plaso-psteal
                sudo cp -vf /tmp/PythonVirtualEnvironments/plaso/bin/dist/pinfo        /usr/bin/plaso-pinfo
                sudo cp -vf /tmp/PythonVirtualEnvironments/plaso/bin/dist/stats        /usr/bin/plaso-stats
                sudo cp -vf /tmp/PythonVirtualEnvironments/plaso/bin/dist/validator    /usr/bin/plaso-validator
                sudo cp -vf /tmp/PythonVirtualEnvironments/plaso/bin/dist/xattr        /usr/bin/plaso-xattr

              # Notificar fin de ejecución del script
                echo ""
                echo -e "${cColorVerde}    La instalación ha finalizado. Se han copiado las herramientas de plaso a /usr/bin/ ${cFinColor}"
                echo -e "${cColorVerde}    Puedes ejecutarlas de la siguiente forma: ${cFinColor}"
                echo ""
                echo -e "${cColorVerde}      plaso-image_export [Parámetros]${cFinColor}"
                echo -e "${cColorVerde}      plaso-log2timeline [Parámetros]${cFinColor}"
                echo -e "${cColorVerde}      plaso-normalizer   [Parámetros]${cFinColor}"
                echo -e "${cColorVerde}      plaso-psort        [Parámetros]${cFinColor}"
                echo -e "${cColorVerde}      plaso-psteal       [Parámetros]${cFinColor}"
                echo -e "${cColorVerde}      plaso-pinfo        [Parámetros]${cFinColor}"
                echo -e "${cColorVerde}      plaso-stats        [Parámetros]${cFinColor}"
                echo -e "${cColorVerde}      plaso-validator    [Parámetros]${cFinColor}"
                echo -e "${cColorVerde}      plaso-xattr        [Parámetros]${cFinColor}"
                echo ""

            ;;

            7)

              echo ""
              echo "  Otro tipo de instalación (Pruebas)..."
              echo ""

              # Instalar dependencias
                sudo apt-get -y update
                sudo apt-get -y install python3-dfdatetime
                sudo python3 -m pip install dfvfs   --break-system-packages
                sudo python3 -m pip install acstore --break-system-packages
                sudo apt-get -y install python3-xlsxwriter
                sudo apt-get -y install python3-defusedxml
                sudo python3 -m pip install bencode --break-system-packages
                sudo python3 -m pip install BTL --break-system-packages

              # Clonar el repo

              # Instalar
                # Comprobar si el paquete python3-setuptools está instalado. Si no lo está, instalarlo.
                  if [[ $(dpkg-query -s python3-setuptools 2>/dev/null | grep installed) == "" ]]; then
                    echo ""
                    echo -e "${cColorRojo}  El paquete python3-setuptools no está instalado. Iniciando su instalación...${cFinColor}"
                    echo ""
                    sudo apt-get -y update && sudo apt-get -y install python3-setuptools
                    echo ""
                  fi
                cd ~/repos/python/plaso/
                python3 setup.py install --user
                cd ~





              sudo apt-get -y update
              sudo apt-get -y install python3-pip
              sudo apt-get -y install python3-venv
              sudo apt-get -y install python3-wheel
              sudo apt-get -y install python3-setuptools
              sudo apt-get -y install python3-dev
              sudo apt-get -y install build-essential
              sudo apt-get -y install liblzma-dev

              # Entrar al entorno virtual
                source ~/repos/python/plaso/venv/bin/activate
                cd ~/repos/python/plaso/

              python3 setup.py install
              # Instalar el instalador
                python3 -m pip install pyinstaller


              # Compilar
                cd ~/repos/python/plaso/venv/bin/
           echo ""
              echo "      Intentando compilar image_export..."
              echo ""
              pyinstaller --onefile image_export \
              --add-data ~/"repos/python/plaso/venv/lib/python3.11/site-packages/plaso/parsers/macos_core_location.yaml:plaso/parsers" \
              --add-data ~/"repos/python/plaso/venv/lib/python3.11/site-packages/plaso/parsers/macos_mdns.yaml:plaso/parsers" \
              --add-data ~/"repos/python/plaso/venv/lib/python3.11/site-packages/plaso/parsers/macos_open_directory.yaml:plaso/parsers" \
              --add-data ~/"repos/python/plaso/venv/lib/python3.11/site-packages/plaso/parsers/windows_nt.yaml:plaso/parsers" \
              --add-data ~/"repos/python/plaso/venv/lib/python3.11/site-packages/plaso/preprocessors/time_zone_information.yaml:plaso/preprocessors" \
              --add-data ~/"repos/python/plaso/venv/lib/python3.11/site-packages/plaso/preprocessors/mounted_devices.yaml:plaso/preprocessors"
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





              # Copiar el binario a /usr/bin
                mkdir ~/bin/
                cp -f ~/repos/python/plaso/dist/plaso ~/bin/

              # Desactivar el entorno virtual
                deactivate

              # Notificar fin de ejecución del script
                echo ""
                echo "  El script ha finalizado. analyzeMFT se ha descargado, compilado e instalado."
                echo ""
                echo "    Puedes encontrar el binario en ~/bin/analyzeMFT"
                echo ""
                echo "  El binario debe ser usado con precaución. Es mejor correr el script directamente con python, de la siguiente manera:"
                echo ""
                echo "    source ~/PythonVirtualEnvironments/analyzeMFT/bin/activate"
                echo "    python3 ~/scripts/python/analyzeMFT/analyzeMFT.py [Argumentos]"
                echo "    deactivate"
                echo ""

            ;;

        esac

    done

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

