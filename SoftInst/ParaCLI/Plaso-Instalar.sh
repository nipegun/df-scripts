#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar y configurar Plaso en Debian
#
# Ejecución remota con sudo:
#   curl -sL x | sudo bash
#
# Ejecución remota como root:
#   curl -sL x | sudo bash
#
# Ejecución remota sin caché:
#   curl -sL -H 'Cache-Control: no-cache, no-store' x | bash
#
# Ejecución remota con parámetros:
#   curl -sL x | bash -s Parámetro1 Parámetro2
#
# Bajar y editar directamente el archivo en nano
#   curl -sL x | nano -
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
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Plaso para Debian 13 (x)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 13 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "12" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de instalación de Plaso para Debian 12 (Bookworm)...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 12 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

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



# Actualizar lista de paquetes disponibles en los repositorios
  echo ""
  echo "    Actualizando la lista de paquetes disponibles en los repositorios..."
  echo ""
  sudo apt -y update && apt -y install python3-pip python3-setuptools python3-dev python3-venv build-essential liblzma-dev

# Instalar plaso
  echo ""
  echo "    Creando la carpeta para guardar el código fuente..."
  echo ""
  mkdir -p ~/SoftInst/Plaso/
  rm -rf ~/SoftInst/Plaso/*
  cd ~/SoftInst/Plaso/
  echo ""
  echo "    Creando el ambiente virtual..."
  echo ""
  python3 -m venv plaso
  echo ""
  echo "    Entrando al ambiente virtual"
  echo ""
  source plaso/bin/activate
  echo ""
  echo "    Instalando plaso..."
  echo ""
  pip3 install plaso
  # Verificando que log2timeline se haya descargado
    echo ""
    echo "    Verificando la ejecución del script log2timeline.py..."
    echo ""
    ~/SoftInst/Plaso/plaso/bin/log2timeline --version && echo "      log2timeline es ejecutable desde ~/SoftInst/Plaso/plaso/bin/log2timeline "
  # Compilar
    echo ""
    echo "    Compilando log2timeline..."
    echo ""
    pip install pyinstaller
    pyinstaller --onefile \
      --add-data ~/"SoftInst/Plaso/plaso/lib/python3.11/site-packages/plaso/parsers/macos_core_location.yaml:plaso/parsers" \
      --add-data ~/"SoftInst/Plaso/plaso/lib/python3.11/site-packages/plaso/parsers/macos_mdns.yaml:plaso/parsers" \
      --add-data ~/"SoftInst/Plaso/plaso/lib/python3.11/site-packages/plaso/parsers/macos_open_directory.yaml:plaso/parsers" \
      --add-data ~/"SoftInst/Plaso/plaso/lib/python3.11/site-packages/plaso/parsers/windows_nt.yaml:plaso/parsers" \
      --add-data ~/"SoftInst/Plaso/plaso/lib/python3.11/site-packages/plaso/preprocessors/time_zone_information.yaml:plaso/preprocessors" \
      --add-data ~/"SoftInst/Plaso/plaso/lib/python3.11/site-packages/plaso/preprocessors/mounted_devices.yaml:plaso/preprocessors" \
      ~/SoftInst/Plaso/plaso/bin/log2timeline
   # Desactivar el entorno virtual
     deactivate
  # Copiar el binario a /usr/bin
    cp -f ~/SoftInst/Plaso/dist/log2timeline /usr/bin/






    # Convertir los eventos a log2timeline
      #~/SoftInst/Plaso/plaso/bin/log2timeline $vCarpetaDelCaso/Eventos/Originales/ --storage-file $vCarpetaDelCaso/Eventos/Parseados/TimeLine.plaso
    # Parsear
      #~/SoftInst/Plaso/plaso/bin/psort "$vCarpetaDelCaso"/Eventos/Parseados/TimeLine.plaso -o dynamic   -w "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineEventos.txt
      #~/SoftInst/Plaso/plaso/bin/psort "$vCarpetaDelCaso"/Eventos/Parseados/TimeLine.plaso -o json      -w "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineEventos.json
      #~/SoftInst/Plaso/plaso/bin/psort "$vCarpetaDelCaso"/Eventos/Parseados/TimeLine.plaso -o json_line -w "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineEventos.json_line 
      #~/SoftInst/Plaso/plaso/bin/psort "$vCarpetaDelCaso"/Eventos/Parseados/TimeLine.plaso -o l2tcsv    -w "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineEventos.l2tcsv
      #~/SoftInst/Plaso/plaso/bin/psort "$vCarpetaDelCaso"/Eventos/Parseados/TimeLine.plaso -o l2ttln    -w "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineEventos.l2ttln
      #~/SoftInst/Plaso/plaso/bin/psort "$vCarpetaDelCaso"/Eventos/Parseados/TimeLine.plaso -o rawpy     -w "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineEventos.rawpy
      #~/SoftInst/Plaso/plaso/bin/psort "$vCarpetaDelCaso"/Eventos/Parseados/TimeLine.plaso -o tln       -w "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineEventos.tln
      #~/SoftInst/Plaso/plaso/bin/psort "$vCarpetaDelCaso"/Eventos/Parseados/TimeLine.plaso -o xlsx      -w "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineEventos.xlsx

     # Pasar todo el TimeLine de eventos, de json a xml
      # cat "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineEventos.json | jq | grep xml_string | sed 's-"xml_string": "--g' | sed 's/\\n/\n/g' | sed '/^"/d' | sed 's-xmlns=\"http://schemas.microsoft.com/win/2004/08/events/event\"--g' > "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineCompleto.xml




     # Exportando actividad del usuario específico desde el archivo .json
     #  echo ""
     #  echo "  Exportando actividad específica del usuario ..."
     #  echo ""
     #  vSIDDelUsuario="S-1-5-21-92896240-835188504-1963242017-1001"
     #  cat '/Casos/Examen/Eventos/Parseados/TimeLineEventos.json' | sed 's-/Casos/Examen/Eventos/Originales/--g'  | jq '.[] | select(.user_sid == "'"$vSIDDelUsuario"'")' > $vCarpetaDelCaso/Eventos/Parseados/TimeLineUsuario.json

#     cat /Casos/Examen/Eventos/Parseados/TimeLineEventos.txt | sed 's-/Casos/Examen/Eventos/Originales/--g' | grep S-1-5-21 > $vCarpetaDelCaso/Eventos/Parseados/TimeLineUsuario.txt


