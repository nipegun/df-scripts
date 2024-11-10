#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para parsear los eventos recolectados de una partición de Windows
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Evidencia-Windows-Eventos-Recolectados-Parsear.sh | sudo bash -s [CarpetaConEventosRecolectados] [CarpetaDelCaso]
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Evidencia-Windows-Eventos-Recolectados-Parsear.sh | nano -
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
    echo "    $0 [CarpetaConEventosRecolectados] [CarpetaDelCaso]"
    echo ""
    echo "  Ejemplo:"
    echo "    $0 '/mnt/Windows/' '/Casos/2/Particiones/'"
    echo ""
    exit
  else
    vCarpetaConEventosRecolectados="$1"
    vCarpetaDelCaso="$2"


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
          1 "Parsear cada archivo .evtx original a .xml" on
          2 "Parsear cada archivo .evtx original a .txt" on
          3 "Unificando en un único archivo todos los archivos XML parseados" on
          4 "  Crear un único archivo con todos los eventos ordenados por fecha" off
          5 "  Crear un único archivo con todos los eventos del usuario ordenados por fecha" on
        )
      choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)
      #clear

      for choice in $choices
        do
          case $choice in

            1)

              echo ""
              echo "  Parseando cada archivo .evtx original a .xml..."
              echo ""
              # Comprobar si el paquete libevtx-utils está instalado. Si no lo está, instalarlo.
                if [[ $(dpkg-query -s libevtx-utils 2>/dev/null | grep installed) == "" ]]; then
                  echo ""
                  echo -e "${cColorRojo}  El paquete libevtx-utils no está instalado. Iniciando su instalación...${cFinColor}"
                  echo ""
                  apt-get -y update && apt-get -y install libevtx-utils
                  echo ""
                fi
              # Recorrer la carpeta e ir convirtiendo
                mkdir -p "$vCarpetaDelCaso"/Eventos/Parseados/OriginalesEnXML/
                rm -rf "$vCarpetaDelCaso"/Eventos/Parseados/OriginalesEnXML/*
                find "$vCarpetaConEventosRecolectados"/ -name "*.evtx" | while read vArchivo; do
                  vArchivoDeSalida=""$vCarpetaDelCaso"/Eventos/Parseados/OriginalesEnXML/$(basename "$vArchivo" .evtx).xml"
                  evtxexport -f xml "$vArchivo" > "$vArchivoDeSalida" && sed -i '1d' "$vArchivoDeSalida" && sed -i 's/^<Event [^>]*>/<Event>/' "$vArchivoDeSalida"
                  #sed -i '1i\<root>' "$vArchivoDeSalida"
                  #echo '</root>' >> "$vArchivoDeSalida"
                done
              # Borrar todos los xml que no tengan la linea <Event>
                for archivo in ""$vCarpetaDelCaso"/Eventos/Parseados/OriginalesEnXML"/*; do # Recorre todos los archivos en el directorio
                  if ! grep -q "<Event>" "$archivo"; then # Verifica si el archivo contiene la línea "<Event>"
                    rm -f "$archivo" # Si no contiene "<Event>", lo elimina
                  fi
                done

            ;;

            2)

              echo ""
              echo "  Parseando cada archivo .evtx original a .xml..."
              echo ""
              # También convertir a texto
                mkdir -p "$vCarpetaDelCaso"/Eventos/Parseados/OriginalesEnTXT/
                rm -rf "$vCarpetaDelCaso"/Eventos/Parseados/OriginalesEnTXT/*
                find "$vCarpetaDelCaso"/Eventos/Originales/ -name "*.evtx" | while read vArchivo; do
                  vArchivoDeSalida=""$vCarpetaDelCaso"/Eventos/Parseados/OriginalesEnTXT/$(basename "$vArchivo" .evtx).txt"
                  evtxexport "$vArchivo" > "$vArchivoDeSalida" && sed -i '1d' "$vArchivoDeSalida"
                done
              # Borrar todos los txt que no tengan el texto "Event number"
                for archivo in ""$vCarpetaDelCaso"/Eventos/Parseados/OriginalesEnTXT"/*; do # Recorre todos los archivos en el directorio
                  if ! grep -q "Event number" "$archivo"; then                            # Verifica si el archivo contiene la cadena "Even number" y
                    rm -f "$archivo"                                                      # si no contiene "Event number", lo elimina
                  fi
                done

            ;;

            3)

              echo ""
              echo "  Unificando en un único archivo todos los archivos XML parseados..."
              echo ""
              for archivo in ""$vCarpetaDelCaso"/Eventos/Parseados/OriginalesEnXML"/*; do # Recorre todos los archivos en el directorio
                cat "$archivo" >> "$vCarpetaDelCaso"/Eventos/Parseados/TodosLosEventos.xml
              done
              # Agregar una etiqueta raíz para poder trabajar con el xml
                sed -i '1i\<Events>' "$vCarpetaDelCaso"/Eventos/Parseados/TodosLosEventos.xml # Agrega la apertura de la etiqueta raiz en la primera linea
                echo '</Events>' >>  "$vCarpetaDelCaso"/Eventos/Parseados/TodosLosEventos.xml # Agrega el cierre de la etiqueta raíz en una nueva linea al final del archivo
              # Agregar una etiqueta raíz para poder trabajar con los xml a posteriori
                for vArchivo in "$vCarpetaDelCaso/Eventos/Parseados/OriginalesEnXML"/*; do # Recorre todos los archivos en el directorio
                  sed -i '1i\<Events>' "$vArchivo"                                         # Agrega la apertura de la etiqueta raiz en la primera linea
                  echo '</Events>' >> "$vArchivo"                                          # Agrega el cierre de la etiqueta raíz en una nueva linea al final del archivo
                done

            ;;

            4)

              echo ""
              echo "  Intentando crear un único archivo XML con todos los eventos ordenados por fecha..."
              echo ""
              # Crear una carpeta para almacenar los archivos de vEventos
                vNombreCarpetaDeEventosIndividuales="EventosIndividuales"
                mkdir -p "$vCarpetaDelCaso"/Eventos/Parseados/$vNombreCarpetaDeEventosIndividuales/
              # Contador de vEventos
                vContador=1
              # Variable para almacenar un vEvento temporalmente
                vEvento=""
              echo ""
              echo "    Guardando cada evento en un archivo .xml único..."
              echo ""
              # Leer el archivo línea por línea
                while IFS= read -r line; do
                  if [[ "$line" == *"<Event>"* ]]; then
                    # Iniciar un nuevo bloque de vEvento
                      vEvento="$line"
                  elif [[ "$line" == *"</Event>"* ]]; then
                    # Agregar la línea de cierre del vEvento
                      vEvento+=$'\n'"$line"
                    # Guardar el bloque en un archivo
                      echo "$vEvento" > "$vCarpetaDelCaso"/Eventos/Parseados/$vNombreCarpetaDeEventosIndividuales/$vEvento_${vContador}.xml
                    # Incrementar el vContador y limpiar la variable del vEvento
                      vContador=$((vContador + 1))
                    vEvento=""
                  else
                    # Agregar la línea al bloque de vEvento en curso
                      vEvento+=$'\n'"$line"
                  fi
                done < "$vCarpetaDelCaso"/Eventos/Parseados/TodosLosEventos.xml
              # Renombrar cada archivo con el valor del campo SystemTime
                echo ""
                echo "    Renombrando cada archivo .xml creado con el valor del campo SystemTime..."
                echo ""
                mkdir -p "$vCarpetaDelCaso"/Eventos/Parseados/EventosIndividualesOrdenadosPorFecha/
                # Recorrer cada archivo XML en la carpeta
                  for file in "$vCarpetaDelCaso"/Eventos/Parseados/EventosIndividuales/* ; do
                    # Extraer el valor de SystemTime usando xmlstarlet
                      system_time=$(xmlstarlet sel -t -v "//TimeCreated/@SystemTime" "$file" 2>/dev/null)
                    # Renombrar el archivo
                      cp "$file" "$vCarpetaDelCaso"/Eventos/Parseados/EventosIndividualesOrdenadosPorFecha/"${system_time}".xml
                  done
                rm -f "$vCarpetaDelCaso"/Eventos/Parseados/EventosIndividualesOrdenadosPorFecha/.xml
              # Crear un nuevo archivo xml con todos los eventos
                echo ""
                echo "    Agrupando todos los archivos creados en un único archivo final..."
                echo ""
                cat $(ls "$vCarpetaDelCaso"/Eventos/Parseados/EventosIndividualesOrdenadosPorFecha/* | sort) > "$vCarpetaDelCaso"/Eventos/Parseados/TodosLosEventosOrdenadosPorFecha.xml
                sed -i -e 's-</Event>-</Event>\n-g' "$vCarpetaDelCaso"/Eventos/Parseados/TodosLosEventosOrdenadosPorFecha.xml
                sed -i '1i\<Events>' "$vCarpetaDelCaso"/Eventos/Parseados/TodosLosEventosOrdenadosPorFecha.xml # Agrega la apertura de la etiqueta raiz en la primera linea
                echo '</Events>' >>  "$vCarpetaDelCaso"/Eventos/Parseados/TodosLosEventosOrdenadosPorFecha.xml # Agrega el cierre de la etiqueta raíz en una nueva linea al final del archivo

            ;;

            5)

              echo ""
              echo "  Creando un único archivo con todos los eventos del usuario ordenados por fecha..."
              echo ""
              vSIDvSIDDelUsuario="$1"
              vSIDDelUsuario="S-1-5-21-92896240-835188504-1963242017-1001"
              xmllint --xpath '//*[Data[@Name="SubjectUserSid" and text()='"'$vSIDDelUsuario'"']]/parent::*' /Casos/Examen/Eventos/Parseados/OriginalesEnXML/*  > "$vCarpetaDelCaso"/Eventos/Parseados/TodosLosEventosDelUsuario.xml 2> /dev/null
              xmllint --xpath '//*[Security[@UserID='"'$vSIDDelUsuario'"']]/parent::*'                       /Casos/Examen/Eventos/Parseados/OriginalesEnXML/* >> "$vCarpetaDelCaso"/Eventos/Parseados/TodosLosEventosDelUsuario.xml 2> /dev/null
              sed -i '1i\<root>' "$vCarpetaDelCaso"/Eventos/Parseados/TodosLosEventosDelUsuario.xml # Agrega la apertura de la etiqueta raiz en la primera linea
              echo '</root>' >>  "$vCarpetaDelCaso"/Eventos/Parseados/TodosLosEventosDelUsuario.xml # Agrega el cierre de la etiqueta raíz en una nueva linea al final del archivo
              # Generar un archivo por cada evento dentro del xml
                # Crear una carpeta para almacenar los archivos de vEventos
                  vNombreNuevaCarpeta="EventosIndividualesDeUsuario"
                  mkdir -p "$vCarpetaDelCaso"/Eventos/Parseados/$vNombreNuevaCarpeta/
                # Contador de vEventos
                  vContador=1
                # Variable para almacenar un vEvento temporalmente
                  vEvento=""
                echo ""
                echo "    Guardando cada evento en un archivo .xml único..."
                echo ""
                # Leer el archivo línea por línea
                  while IFS= read -r line; do
                    if [[ "$line" == *"<Event>"* ]]; then
                      # Iniciar un nuevo bloque de vEvento
                        vEvento="$line"
                    elif [[ "$line" == *"</Event>"* ]]; then
                      # Agregar la línea de cierre del vEvento
                        vEvento+=$'\n'"$line"
                      # Guardar el bloque en un archivo
                        echo "$vEvento" > /Casos/Examen/Eventos/Parseados/$vNombreNuevaCarpeta/$vEvento_${vContador}.xml
                      # Incrementar el vContador y limpiar la variable del vEvento
                        vContador=$((vContador + 1))
                      vEvento=""
                    else
                      # Agregar la línea al bloque de vEvento en curso
                        vEvento+=$'\n'"$line"
                    fi
                  done < "/Casos/Examen/Eventos/Parseados/TodosLosEventosDelUsuario.xml"
                # Renombrar cada archivo con el valor del campo SystemTime
                  echo ""
                  echo "    Asignando el valor del campor SystemTime al nombre de cada archivo .xml único..."
                  echo ""
                  mkdir -p "$vCarpetaDelCaso"/Eventos/Parseados/EventosIndividualesDeUsuarioOrdenadosPorFecha/
                  # Recorrer cada archivo XML en la carpeta
                    for file in "$vCarpetaDelCaso"/Eventos/Parseados/EventosIndividualesDeUsuario/* ; do
                      # Extraer el valor de SystemTime usando xmlstarlet
                        system_time=$(xmlstarlet sel -t -v "//TimeCreated/@SystemTime" "$file" 2>/dev/null)
                      # Renombrar el archivo
                        cp "$file" "$vCarpetaDelCaso"/Eventos/Parseados/EventosIndividualesDeUsuarioOrdenadosPorFecha/"${system_time}".xml
                    done
                  rm -f "$vCarpetaDelCaso"/Eventos/Parseados/EventosIndividualesDeUsuarioOrdenadosPorFecha/.xml
                # Crear un nuevo archivo xml con todos los eventos
                  echo ""
                  echo "    Finalmente, agrupando todos los archivos .xml únicos en archivo unificado final..."
                  echo ""
                  cat $(ls "$vCarpetaDelCaso"/Eventos/Parseados/EventosIndividualesDeUsuarioOrdenadosPorFecha/* | sort) > "$vCarpetaDelCaso"/Eventos/Parseados/TodosLosEventosDelUsuarioOrdenadosPorFecha.xml
                  sed -i -e 's-</Event>-</Event>\n-g' "$vCarpetaDelCaso"/Eventos/Parseados/TodosLosEventosDelUsuarioOrdenadosPorFecha.xml
                  sed -i '1i\<Events>' "$vCarpetaDelCaso"/Eventos/Parseados/TodosLosEventosDelUsuarioOrdenadosPorFecha.xml # Agrega la apertura de la etiqueta raiz en la primera linea
                  echo '</Events>' >>  "$vCarpetaDelCaso"/Eventos/Parseados/TodosLosEventosDelUsuarioOrdenadosPorFecha.xml # Agrega el cierre de la etiqueta raíz en una nueva linea al final del archivo

            ;;

        esac

    done

fi
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
