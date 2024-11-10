#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para exportar eventos de una partición de Windows y parsearlos a xml
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Eventos-Exportar-Todos.sh | sudo bash -s [PuntoDeMontajePartWindows] [CarpetaDelCaso]
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Eventos-Exportar-Todos.sh | nano -
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

# Definir la cantidad de argumentos esperados
  cCantParamEsperados=2

if [ $# -ne $cCantParamEsperados ]
  then
    echo ""
    echo -e "${cColorRojo}  Mal uso del script. El uso correcto sería: ${cFinColor}"
    echo "    $0 [PuntoDeMontajePartWindows] [CarpetaDelCaso]"
    echo ""
    echo "  Ejemplo:"
    echo "    $0 '/mnt/Windows/' '/Casos/2/Particiones/'"
    echo ""
    exit
  else
    vPuntoDeMontajePartWindows=$1
    vCarpetaDelCaso=$2

    # Copiar los eventos crudos
      mkdir -p $vCarpetaDelCaso/Eventos/Crudos/
      rm -rf $vCarpetaDelCaso/Eventos/Crudos/*
      find $vPuntoDeMontajePartWindows -name "*.evtx" -exec cp {} $vCarpetaDelCaso/Eventos/Crudos/ \;

    # Convertir los eventos a xml
      # Comprobar si el paquete libevtx-utils está instalado. Si no lo está, instalarlo.
        if [[ $(dpkg-query -s libevtx-utils 2>/dev/null | grep installed) == "" ]]; then
          echo ""
          echo -e "${cColorRojo}  El paquete libevtx-utils no está instalado. Iniciando su instalación...${cFinColor}"
          echo ""
          apt-get -y update && apt-get -y install libevtx-utils
          echo ""
        fi
      # Recorrer la carpeta e ir convirtiendo
        mkdir -p $vCarpetaDelCaso/Eventos/Parseados/XML/
        rm -rf $vCarpetaDelCaso/Eventos/Parseados/XML/*
        echo ""
        echo "  Exportando eventos a XML..."
        echo ""
        find $vCarpetaDelCaso/Eventos/Crudos/ -name "*.evtx" | while read vArchivo; do
          vArchivoDeSalida="$vCarpetaDelCaso/Eventos/Parseados/XML/$(basename "$vArchivo" .evtx).xml"
          evtxexport -f xml "$vArchivo" > "$vArchivoDeSalida" && sed -i '1d' "$vArchivoDeSalida" && sed -i 's/^<Event [^>]*>/<Event>/' "$vArchivoDeSalida"
        done
        # Borrar todos los xml que no tengan la linea <Event>
          for archivo in "$vCarpetaDelCaso/Eventos/Parseados/XML"/*; do # Recorre todos los archivos en el directorio
            if ! grep -q "<Event>" "$archivo"; then # Verifica si el archivo contiene la línea "<Event>"
              rm -f "$archivo" # Si no contiene "<Event>", lo elimina
            fi
          done

      # También convertir a texto
        mkdir -p $vCarpetaDelCaso/Eventos/Parseados/TXT/
        rm -rf $vCarpetaDelCaso/Eventos/Parseados/TXT/*
        echo ""
        echo "  Exportando eventos a TXT..."
        echo ""
        find $vCarpetaDelCaso/Eventos/Crudos/ -name "*.evtx" | while read vArchivo; do
          vArchivoDeSalida="$vCarpetaDelCaso/Eventos/Parseados/TXT/$(basename "$vArchivo" .evtx).txt"
          evtxexport "$vArchivo" > "$vArchivoDeSalida" && sed -i '1d' "$vArchivoDeSalida"
        done

    # Convertir los eventos a log2timeline
      ~/SoftInst/Plaso/plaso/bin/log2timeline $vCarpetaDelCaso/Eventos/Crudos/ --storage-file $vCarpetaDelCaso/Eventos/Parseados/TimeLine.plaso
    # Parsear
      ~/SoftInst/Plaso/plaso/bin/psort "$vCarpetaDelCaso"/Eventos/Parseados/TimeLine.plaso -o dynamic   -w "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineEventos.txt
      ~/SoftInst/Plaso/plaso/bin/psort "$vCarpetaDelCaso"/Eventos/Parseados/TimeLine.plaso -o json      -w "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineEventos.json
      #~/SoftInst/Plaso/plaso/bin/psort "$vCarpetaDelCaso"/Eventos/Parseados/TimeLine.plaso -o json_line -w "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineEventos.json_line 
      #~/SoftInst/Plaso/plaso/bin/psort "$vCarpetaDelCaso"/Eventos/Parseados/TimeLine.plaso -o l2tcsv    -w "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineEventos.l2tcsv
      #~/SoftInst/Plaso/plaso/bin/psort "$vCarpetaDelCaso"/Eventos/Parseados/TimeLine.plaso -o l2ttln    -w "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineEventos.l2ttln
      #~/SoftInst/Plaso/plaso/bin/psort "$vCarpetaDelCaso"/Eventos/Parseados/TimeLine.plaso -o rawpy     -w "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineEventos.rawpy
      #~/SoftInst/Plaso/plaso/bin/psort "$vCarpetaDelCaso"/Eventos/Parseados/TimeLine.plaso -o tln       -w "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineEventos.tln
      ~/SoftInst/Plaso/plaso/bin/psort "$vCarpetaDelCaso"/Eventos/Parseados/TimeLine.plaso -o xlsx      -w "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineEventos.xlsx

     # Pasar todo el TimeLine de eventos, de json a xml
       cat "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineEventos.json | jq | grep xml_string | sed 's-"xml_string": "--g' | sed 's/\\n/\n/g' | sed '/^"/d' | sed 's-xmlns=\"http://schemas.microsoft.com/win/2004/08/events/event\"--g' > "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineCompleto.xml


     # Exportando actividad del usuario específico desde el archivo .json
       echo ""
       echo "  Exportando actividad específica del usuario ..."
       echo ""
       vSIDDelUsuario="S-1-5-21-92896240-835188504-1963242017-1001"
       cat '/Casos/Examen/Eventos/Parseados/TimeLineEventos.json' | sed 's-/Casos/Examen/Eventos/Crudos/--g'  | jq '.[] | select(.user_sid == "'"$vSIDDelUsuario"'")' > $vCarpetaDelCaso/Eventos/Parseados/TimeLineUsuario.json

     cat /Casos/Examen/Eventos/Parseados/TimeLineEventos.txt | sed 's-/Casos/Examen/Eventos/Crudos/--g' | grep S-1-5-21 > $vCarpetaDelCaso/Eventos/Parseados/TimeLineUsuario.txt


fi

