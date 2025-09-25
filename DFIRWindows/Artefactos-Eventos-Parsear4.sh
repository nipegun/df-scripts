#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para parsear los eventos .evtx que se encuentren en una carpeta dada
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/DFIRWindows/Artefactos-Eventos-Parsear.sh | bash -s [CarpetaConEventosRecolectados] [CarpetaDelCaso]  (Ambas sin barra / final)
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/DFIRWindows/Artefactos-Eventos-Parsear.sh | nano -
# ----------

# Definir constantes de color
  cColorAzul="\033[0;34m"
  cColorAzulClaro="\033[1;34m"
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

# Definir la cantidad de argumentos esperados
  cCantParamEsperados=2

if [ $# -ne $cCantParamEsperados ]
  then
    echo ""
    echo -e "${cColorRojo}  Mal uso del script. El uso correcto sería: ${cFinColor}"
    echo "    $0 [CarpetaConEventosRecolectados] [CarpetaDondeGuardar]  (Ambas sin barra final)"
    echo ""
    echo "  Ejemplo:"
    echo "    $0 '/Casos/a2024m11d29/Artefactos/Originales/Eventos' '/Casos/a2024m11d29/Artefactos/Parseados/Eventos'"
    echo ""
    exit
  else
    vCarpetaConEventosRecolectados="$1" # Debe ser una carpeta sin barra final
    vCarpetaDelCaso="$2"           # Debe ser una carpeta sin barra final
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
          1 "Parsear cada archivo .evtx original a .xml"                                     on
          2 "Parsear cada archivo .evtx original a .txt"                                     off
          3 "Unificar en un único archivo todos los archivos XML parseados"                  on
          4 "  Crear un único archivo con todos los eventos ordenados por fecha"             on
          5 "  Crear un único archivo con todos los eventos del usuario ordenados por fecha" off
          6 "Convertir el archivo con todos los eventos a formato plaso"                     on
          7 "  Reordenar cronológicamente el .plaso y convertir a dynamic"                   off
          8 "  Reordenar cronológicamente el .plaso y convertir a json"                      off
          9 "  Reordenar cronológicamente el .plaso y convertir a json_line"                 off
         10 "  Reordenar cronológicamente el .plaso y convertir a l2tcsv"                    off
         11 "  Reordenar cronológicamente el .plaso y convertir a l2ttln"                    off
         12 "  Reordenar cronológicamente el .plaso y convertir a rawpy"                     on
         13 "  Reordenar cronológicamente el .plaso y convertir a tln"                       off
         14 "  Reordenar cronológicamente el .plaso y convertir a xlsx"                      off
         15 "  Otros..."                                                                     off
        )
      choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)

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
                  sudo apt-get -y update
                  sudo apt-get -y install libevtx-utils
                  echo ""
                fi
              # Recorrer la carpeta e ir convirtiendo
                sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Eventos/Parseados/DeEVTXaXML/
                sudo rm -rf "$vCarpetaDelCaso"/Artefactos/Eventos/Parseados/DeEVTXaXML/*
                sudo chown $USER:$USER "$vCarpetaDelCaso" -R
                sudo find "$vCarpetaConEventosRecolectados"/ -name "*.evtx" | while read vArchivo; do
                  vArchivoDeSalida=""$vCarpetaDelCaso"/Artefactos/Eventos/Parseados/DeEVTXaXML/$(basename "$vArchivo" .evtx).xml"
                  sudo evtxexport -f xml "$vArchivo" > "$vArchivoDeSalida" && sed -i '1d' "$vArchivoDeSalida" && sed -i 's/^<Event [^>]*>/<Event>/' "$vArchivoDeSalida"
                  #sudo sed -i '1i\<root>' "$vArchivoDeSalida"
                  #echo '</root>' >> "$vArchivoDeSalida"
                done
              # Borrar todos los xml que no tengan la linea <Event>
                for archivo in "$vCarpetaDelCaso"/Artefactos/Eventos/Parseados/DeEVTXaXML/*; do # Recorre todos los archivos en el directorio
                  if ! grep -q "<Event>" "$archivo"; then                    # Verifica si el archivo contiene la línea "<Event>"
                    sudo rm -f "$archivo"                                    # Si no contiene "<Event>", lo elimina
                  fi
                done

            ;;

            2)

              echo ""
              echo "  Parseando cada archivo .evtx original a .txt..."
              echo ""
              # También convertir a texto
                sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Eventos/Parseados/DeEVTXaTXT/
                sudo rm -rf "$vCarpetaDelCaso"/Artefactos/Eventos/Parseados/DeEVTXaTXT/*
                sudo chown $USER:$USER "$vCarpetaDelCaso" -R
                find "$vCarpetaConEventosRecolectados"/ -name "*.evtx" | while read vArchivo; do
                  vArchivoDeSalida=""$vCarpetaDelCaso"/Artefactos/Eventos/Parseados/DeEVTXaTXT/$(basename "$vArchivo" .evtx).txt"
                  sudo evtxexport "$vArchivo" > "$vArchivoDeSalida" && sed -i '1d' "$vArchivoDeSalida"
                done
              # Borrar todos los txt que no tengan el texto "Event number"
                for archivo in "$vCarpetaDelCaso"/Artefactos/Eventos/Parseados/DeEVTXaTXT/*; do # Recorre todos los archivos en el directorio
                  if ! grep -q "Event number" "$archivo"; then               # Verifica si el archivo contiene la cadena "Even number" y
                    sudo rm -f "$archivo"                                    # si no contiene "Event number", lo elimina
                  fi
                done

            ;;

            3)

              echo ""
              echo "  Unificando en un único archivo todos los archivos XML parseados..."
              echo ""
              for archivo in "$vCarpetaDelCaso"/Artefactos/Eventos/Parseados/DeEVTXaXML/*; do # Recorre todos los archivos en el directorio
                cat "$archivo" >> "$vCarpetaDelCaso"/Artefactos/Eventos/Parseados/TodosLosEventosAgrupados.xml
              done
              # Agregar una etiqueta raíz para poder trabajar con el xml
                sudo sed -i '1i\<Events>' "$vCarpetaDelCaso"/Artefactos/Eventos/Parseados/TodosLosEventosAgrupados.xml # Agrega la apertura de la etiqueta raiz en la primera linea
                echo '</Events>' >>  "$vCarpetaDelCaso"/Artefactos/Eventos/Parseados/TodosLosEventosAgrupados.xml # Agrega el cierre de la etiqueta raíz en una nueva linea al final del archivo
              # Agregar una etiqueta raíz para poder trabajar con los xml a posteriori
                for vArchivo in "$vCarpetaDelCaso"/Artefactos/Eventos/Parseados/DeEVTXaXML/*; do # Recorre todos los archivos en el directorio
                  sudo sed -i '1i\<Events>' "$vArchivo"                            # Agrega la apertura de la etiqueta raiz en la primera linea
                  sudo echo '</Events>' >> "$vArchivo"                             # Agrega el cierre de la etiqueta raíz en una nueva linea al final del archivo
                done
              # Notificar el nombre del archivo
                echo ""
                echo "    El archivo con todos los eventos juntos, pero sin ordenar por fecha es:"
                echo ""
                echo "      "$vCarpetaDelCaso"/Artefactos/Eventos/Parseados/TodosLosEventosAgrupados.xml"
                echo ""

            ;;

            4)

              echo ""
              echo "  Intentando crear un único archivo XML con todos los eventos ordenados por fecha..."
              echo ""
              #sed -i '1i\<root>' "$vCarpetaDelCaso"/Artefactos/Eventos/Parseados/TodosLosEventosAgrupados.xml # Agrega la apertura de la etiqueta raiz en la primera linea
              #echo '</root>' >>  "$vCarpetaDelCaso"/Artefactos/Eventos/Parseados/TodosLosEventosAgrupados.xml # Agrega el cierre de la etiqueta raíz en una nueva linea al final del archivo
              # Generar un archivo por cada evento dentro del xml
                # Crear una carpeta para almacenar los archivos de vEventos
                  sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Eventos/Parseados/EventosIndividuales/
                  sudo chown $USER:$USER "$vCarpetaDelCaso" -R
                # Contador de vEventos
                  vContador=1
                # Variable para almacenar un vEvento temporalmente
                  vEvento=""
                echo ""
                echo "    Guardando primero cada evento en un archivo .xml único..."
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
                        sudo echo "$vEvento" > "$vCarpetaDelCaso"/Artefactos/Eventos/Parseados/EventosIndividuales/$vEvento_${vContador}.xml
                      # Incrementar el vContador y limpiar la variable del vEvento
                        vContador=$((vContador + 1))
                      vEvento=""
                    else
                      # Agregar la línea al bloque de vEvento en curso
                        vEvento+=$'\n'"$line"
                    fi
                  done < "$vCarpetaDelCaso"/Artefactos/Eventos/Parseados/TodosLosEventosAgrupados.xml
                # Renombrar cada archivo con el valor del campo SystemTime
                  echo ""
                  echo "    Renombrando cada archivo .xml con el valor su etiqueta SystemTime..."
                  echo ""
                  sudo mkdir -p "$vCarpetaDelCaso"/EventosIndividualesOrdenadosPorFecha/
                  sudo chown $USER:$USER "$vCarpetaDelCaso" -R
                  # Recorrer cada archivo XML en la carpeta
                    for file in "$vCarpetaDelCaso"/Artefactos/Eventos/Parseados/EventosIndividuales/*.xml ; do
                      # Extraer el valor de SystemTime usando xmlstarlet
                        # Comprobar si el paquete xmlstarlet está instalado. Si no lo está, instalarlo.
                          if [[ $(dpkg-query -s xmlstarlet 2>/dev/null | grep installed) == "" ]]; then
                            echo ""
                            echo -e "${cColorRojo}    El paquete xmlstarlet no está instalado. Iniciando su instalación...${cFinColor}"
                            echo ""
                            sudo apt-get -y update
                            sudo apt-get -y install xmlstarlet
                            echo ""
                          fi
                        system_time=$(xmlstarlet sel -t -v "//TimeCreated/@SystemTime" "$file" 2>/dev/null)
                      # Renombrar el archivo
                        sudo cp "$file" "$vCarpetaDelCaso"/EventosIndividualesOrdenadosPorFecha/"${system_time}".xml
                    done
                  rm -f "$vCarpetaDelCaso"/EventosIndividualesOrdenadosPorFecha/.xml
                # Agregar los mensajes a los eventos
                  echo ""
                  echo "    Agregando los mensajes de evento a cada archivo .xml..."
                  echo ""
                  # Descargar el CSV con los eventos:
                    curl -sL https://raw.githubusercontent.com/nipegun/dicts/refs/heads/main/windows/eventos-en-es.csv -o /tmp/eventos-en-es.csv
                    cp ~/scripts/df-scripts/EventosWindows/eventos-en-es.csv /tmp/eventos-en-es.csv
                  # Declarar arrays para guardar los mensajes
                    declare -A aMensajesEng
                    declare -A aMensajesEsp
                  # Popular los arrays
                    while IFS=';' read -r campoIdDelEvento campoMensajeEng campoMensajeEsp; do
                      aMensajesEng["$campoIdDelEvento"]="$campoMensajeEng"
                      aMensajesEsp["$campoIdDelEvento"]="$campoMensajeEsp"
                    done < /tmp/eventos-en-es.csv
                  # Procesar cada archivo .xml
                    for vArchivoXML in "$vCarpetaDelCaso/EventosIndividualesOrdenadosPorFecha/"*.xml; do
                      # Crear un archivo temporal para el nuevo contenido
                        vArchivoTemporal=$(mktemp)
                      # Leer el archivo línea por línea
                        while IFS= read -r vLinea; do
                          echo "$vLinea" >> "$vArchivoTemporal"
                          # Buscar la etiqueta <EventID>
                            if [[ "$vLinea" =~ \<EventID\>([0-9]+)\</EventID\> ]]; then
                              vIdDelEvento="${BASH_REMATCH[1]}"
                              # Verificar si el vIdDelEvento existe en los arrays asociativos
                                if [[ -n "${aMensajesEng[$vIdDelEvento]}" ]]; then
                                  # Generar las etiquetas nuevas
                                    vNuevaEtiquetaEng="<EventMessageEN>${aMensajesEng[$vIdDelEvento]}</EventMessageEN>"
                                    vNuevaEtiquetaEsp="<EventMessageES>${aMensajesEsp[$vIdDelEvento]}</EventMessageES>"
                                  # Añadir las nuevas etiquetas al archivo temporal
                                    sudo echo "    $vNuevaEtiquetaEng" >> "$vArchivoTemporal"
                                    sudo echo "    $vNuevaEtiquetaEsp" >> "$vArchivoTemporal"
                                else
                                  echo "  No se encontró el evento $vIdDelEvento en el CSV."
                                fi
                            fi
                        done < "$vArchivoXML"
                        # Reemplazar el archivo original con el contenido actualizado
                          sudo mv "$vArchivoTemporal" "$vArchivoXML"
                    done
                    # Notificar
                      echo ""
                      echo "    Se ha creado la carpeta "$vCarpetaDelCaso"/EventosIndividualesOrdenadosPorFecha/"
                      echo "    y se han guardado dentro todos los archivos de eventos individuales con su correspondiente fecha en el nombre."
                      echo ""
                      echo "    Para buscar una cadena específica entre el texto de todos esos archivos, puedes hacer:"
                      echo ""
                      echo "      find "$vCarpetaDelCaso"/EventosIndividualesOrdenadosPorFecha/ -type f -name '*.xml' -exec grep -i cadena {} +"
                      echo ""
                # Crear un nuevo archivo xml con todos los eventos
                  echo ""
                  echo "    Agrupando todos los archivos .xml únicos en un archivo unificado final..."
                  echo ""head 
                  # Probar con un bucle
                    find "$vCarpetaDelCaso/EventosIndividualesOrdenadosPorFecha" -type f | sort | while read -r vArchivo; do
                      cat "$vArchivo" >> "$vCarpetaDelCaso/TodosLosEventosOrdenadosPorFecha.xml"
                    done
                  sudo sed -i -e 's-</Event>-</Event>\n-g' "$vCarpetaDelCaso"/TodosLosEventosOrdenadosPorFecha.xml
                  sudo sed -i '1i\<Events>' "$vCarpetaDelCaso"/TodosLosEventosOrdenadosPorFecha.xml # Agrega la apertura de la etiqueta raiz en la primera linea
                  sudo echo '</Events>' >>  "$vCarpetaDelCaso"/TodosLosEventosOrdenadosPorFecha.xml # Agrega el cierre de la etiqueta raíz en una nueva linea al final del archivo
                # Notificar el nombre del archivo
                  echo ""
                  echo "    El archivo con todos los eventos juntos, ordenado por fecha es:"
                  echo ""
                  echo "      "$vCarpetaDelCaso"/TodosLosEventosOrdenadosPorFecha.xml"
                  echo ""

            ;;

            5)

              echo ""
              echo "  Intentando crear un único archivo con todos los eventos del usuario ordenados por fecha..."
              echo ""
              vSIDvSIDDelUsuario="$1"
              vSIDDelUsuario="S-1-5-21-92896240-835188504-1963242017-1001"
              # Comprobar si el paquete libxml2-utils está instalado. Si no lo está, instalarlo.
                if [[ $(dpkg-query -s libxml2-utils 2>/dev/null | grep installed) == "" ]]; then
                  echo ""
                  echo -e "${cColorRojo}  El paquete libxml2-utils no está instalado. Iniciando su instalación...${cFinColor}"
                  echo ""
                  sudo apt-get -y update
                  sudo apt-get -y install libxml2-utils
                  echo ""
                fi
              sudo xmllint --xpath '//*[Data[@Name="SubjectUserSid" and text()='"'$vSIDDelUsuario'"']]/parent::*' "$vCarpetaDelCaso"/Artefactos/Eventos/Parseados/DeEVTXaXML/*  > "$vCarpetaDelCaso"/TodosLosEventosDelUsuario.xml 2> /dev/null
              sudo xmllint --xpath '//*[Security[@UserID='"'$vSIDDelUsuario'"']]/parent::*'                       "$vCarpetaDelCaso"/Artefactos/Eventos/Parseados/DeEVTXaXML/* >> "$vCarpetaDelCaso"/TodosLosEventosDelUsuario.xml 2> /dev/null
              sed -i '1i\<root>' "$vCarpetaDelCaso"/TodosLosEventosDelUsuario.xml # Agrega la apertura de la etiqueta raiz en la primera linea
              sudo echo '</root>' >>  "$vCarpetaDelCaso"/TodosLosEventosDelUsuario.xml # Agrega el cierre de la etiqueta raíz en una nueva linea al final del archivo
              # Generar un archivo por cada evento dentro del xml
                # Crear una carpeta para almacenar los archivos de vEventos
                  sudo mkdir -p "$vCarpetaDelCaso"/EventosIndividualesDeUsuario/
                  sudo chown $USER:$USER "$vCarpetaDelCaso" -R
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
                        sudo echo "$vEvento" > "$vCarpetaDelCaso"/EventosIndividualesDeUsuario/$vEvento_${vContador}.xml
                      # Incrementar el vContador y limpiar la variable del vEvento
                        vContador=$((vContador + 1))
                      vEvento=""
                    else
                      # Agregar la línea al bloque de vEvento en curso
                        vEvento+=$'\n'"$line"
                    fi
                  done < "$vCarpetaDelCaso"/TodosLosEventosDelUsuario.xml
                # Renombrar cada archivo con el valor del campo SystemTime
                  echo ""
                  echo "    Renombrando cada archivo .xml con el valor su etiqueta SystemTime..."
                  echo ""
                  sudo mkdir -p "$vCarpetaDelCaso"/EventosIndividualesDeUsuarioOrdenadosPorFecha/
                  sudo chown $USER:$USER "$vCarpetaDelCaso" -R
                  # Recorrer cada archivo XML en la carpeta
                    for file in "$vCarpetaDelCaso"/EventosIndividualesDeUsuario/* ; do
                      # Extraer el valor de SystemTime usando xmlstarlet
                        # Comprobar si el paquete xmlstarlet está instalado. Si no lo está, instalarlo.
                          if [[ $(dpkg-query -s xmlstarlet 2>/dev/null | grep installed) == "" ]]; then
                            echo ""
                            echo -e "${cColorRojo}    El paquete xmlstarlet no está instalado. Iniciando su instalación...${cFinColor}"
                            echo ""
                            sudo apt-get -y update
                            sudo apt-get -y install xmlstarlet
                            echo ""
                          fi
                        system_time=$(xmlstarlet sel -t -v "//TimeCreated/@SystemTime" "$file" 2>/dev/null)
                      # Renombrar el archivo
                        cp "$file" "$vCarpetaDelCaso"/EventosIndividualesDeUsuarioOrdenadosPorFecha/"${system_time}".xml
                    done
                  sudo rm -f "$vCarpetaDelCaso"/EventosIndividualesDeUsuarioOrdenadosPorFecha/.xml
                # Agregar los mensajes a los eventos
                  echo ""
                  echo "    Agregando los mensajes de evento a cada archivo .xml..."
                  echo ""
                  # Descargar el CSV con los eventos:
                    curl -sL https://raw.githubusercontent.com/nipegun/dicts/refs/heads/main/windows/eventos-en-es.csv -o /tmp/eventos-en-es.csv
                    cp ~/scripts/df-scripts/EventosWindows/eventos-en-es.csv /tmp/eventos-en-es.csv
                  # Declarar arrays para guardar los mensajes
                    declare -A aMensajesEng
                    declare -A aMensajesEsp
                  # Popular los arrays
                    while IFS=';' read -r campoIdDelEvento campoMensajeEng campoMensajeEsp; do
                      aMensajesEng["$campoIdDelEvento"]="$campoMensajeEng"
                      aMensajesEsp["$campoIdDelEvento"]="$campoMensajeEsp"
                    done < /tmp/eventos-en-es.csv
                  # Procesar cada archivo .xml
                    for vArchivoXML in "$vCarpetaDelCaso"/EventosIndividualesDeUsuarioOrdenadosPorFecha/*.xml; do
                      # Crear un archivo temporal para el nuevo contenido
                        vArchivoTemporal=$(mktemp)
                      # Leer el archivo línea por línea
                        while IFS= read -r vLinea; do
                          sudo echo "$vLinea" >> "$vArchivoTemporal"
                          # Buscar la etiqueta <EventID>
                            if [[ "$vLinea" =~ \<EventID\>([0-9]+)\</EventID\> ]]; then
                              vIdDelEvento="${BASH_REMATCH[1]}"
                              # Verificar si el vIdDelEvento existe en los arrays asociativos
                                if [[ -n "${aMensajesEng[$vIdDelEvento]}" ]]; then
                                  # Generar las etiquetas nuevas
                                    vNuevaEtiquetaEng="<EventMessageEN>${aMensajesEng[$vIdDelEvento]}</EventMessageEN>"
                                    vNuevaEtiquetaEsp="<EventMessageES>${aMensajesEsp[$vIdDelEvento]}</EventMessageES>"
                                  # Añadir las nuevas etiquetas al archivo temporal
                                    sudo echo "    $vNuevaEtiquetaEng" >> "$vArchivoTemporal"
                                    sudo echo "    $vNuevaEtiquetaEsp" >> "$vArchivoTemporal"
                                else
                                  echo "  No se encontró el evento $vIdDelEvento en el CSV."
                                fi
                            fi
                        done < "$vArchivoXML"
                        # Reemplazar el archivo original con el contenido actualizado
                          sudo mv "$vArchivoTemporal" "$vArchivoXML"
                    done
                # Crear un nuevo archivo xml con todos los eventos
                  echo ""
                  echo "    Agrupando todos los archivos .xml únicos en un archivo unificado final..."
                  echo ""
                  sudo cat $(ls "$vCarpetaDelCaso"/EventosIndividualesDeUsuarioOrdenadosPorFecha/* | sort) > "$vCarpetaDelCaso"/TodosLosEventosDelUsuarioOrdenadosPorFecha.xml
                  sudo sed -i -e 's-</Event>-</Event>\n-g' "$vCarpetaDelCaso"/TodosLosEventosDelUsuarioOrdenadosPorFecha.xml
                  sudo sed -i '1i\<Events>' "$vCarpetaDelCaso"/TodosLosEventosDelUsuarioOrdenadosPorFecha.xml # Agrega la apertura de la etiqueta raiz en la primera linea
                  sudo echo '</Events>' >>  "$vCarpetaDelCaso"/TodosLosEventosDelUsuarioOrdenadosPorFecha.xml # Agrega el cierre de la etiqueta raíz en una nueva linea al final del archivo
                # Notificar el nombre del archivo
                  echo ""
                  echo "    El archivo con todos los eventos de usuario juntos, ordenado por fecha es:"
                  echo ""
                  echo "      "$vCarpetaDelCaso"/TodosLosEventosDelUsuarioOrdenadosPorFecha.xml"
                  echo ""

            ;;

            6)

              echo ""
              echo "  Convirtiendo los eventos al formato plaso..."
              echo ""
              # Borrar primero el archivo anterior
                rm -f "$vCarpetaDelCaso"/TodosLosEventosJuntos.plaso 2> /dev/null
              # Tratar de ejecutar con el binario
                if [ -f ~/bin/plaso-log2timeline ]; then
                  sudo ~/bin/plaso-log2timeline "$vCarpetaConEventosRecolectados"/ --storage-file "$vCarpetaDelCaso"/TodosLosEventosJuntos.plaso
                else
                  echo ""
                  echo -e "${cColorRojo}    El binario ~/bin/plaso-log2timeline no existe. Intentando ejecutar desde el entorno virtual...${cFinColor}"
                  echo ""
                  source ~/repos/python/plaso/venv/bin/activate
                    log2timeline "$vCarpetaConEventosRecolectados"/ --storage-file "$vCarpetaDelCaso"/TodosLosEventosJuntos.plaso
                  deactivate
                fi

            ;;

            7)

              echo ""
              echo "    Parseando el plaso a formato dynamic..."
              echo ""
              # Borrar primero el archivo anterior
                rm -f "$vCarpetaDelCaso"/TimeLineDeTodosLosEventos.txt 2> /dev/null
              # Tratar de ejecutar con el binario
                if [ -f ~/bin/plaso-psort ]; then
                  sudo ~/bin/plaso-psort "$vCarpetaDelCaso"/TodosLosEventosJuntos.plaso -o dynamic -w "$vCarpetaDelCaso"/TimeLineDeTodosLosEventos.txt
                else
                  echo ""
                  echo -e "${cColorRojo}      El binario ~/bin/plaso-psort no existe. Intentando ejecutar desde el entorno virtual...${cFinColor}"
                  echo ""
                  source ~/repos/python/plaso/venv/bin/activate
                    psort "$vCarpetaDelCaso"/TodosLosEventosJuntos.plaso -o dynamic -w "$vCarpetaDelCaso"/TimeLineDeTodosLosEventos.txt
                  deactivate
                fi

            ;;

            8)

              echo ""
              echo "    Parseando el plaso a formato json..."
              echo ""
              # Borrar primero el archivo anterior
                rm -f "$vCarpetaDelCaso"/TimeLineDeTodosLosEventos.json 2> /dev/null
              # Tratar de ejecutar con el binario
                if [ -f ~/bin/plaso-psort ]; then
                  sudo ~/bin/plaso-psort "$vCarpetaDelCaso"/TodosLosEventosJuntos.plaso -o json -w "$vCarpetaDelCaso"/TimeLineDeTodosLosEventos.json
                else
                  echo ""
                  echo -e "${cColorRojo}      El binario ~/bin/plaso-psort no existe. Intentando ejecutar desde el entorno virtual...${cFinColor}"
                  echo ""
                  source ~/repos/python/plaso/venv/bin/activate
                    psort "$vCarpetaDelCaso"/TodosLosEventosJuntos.plaso -o json -w "$vCarpetaDelCaso"/TimeLineDeTodosLosEventos.json
                  deactivate
                fi

            ;;

            9)

              echo ""
              echo "    Parseando el plaso a formato json_line..."
              echo ""
              # Borrar primero el archivo anterior
                rm -f "$vCarpetaDelCaso"/TimeLineDeTodosLosEventos.json_line 2> /dev/null
              # Tratar de ejecutar con el binario
                if [ -f ~/bin/plaso-psort ]; then
                  sudo ~/bin/plaso-psort "$vCarpetaDelCaso"/TodosLosEventosJuntos.plaso -o json_line -w "$vCarpetaDelCaso"/TimeLineDeTodosLosEventos.json_line
                else
                  echo ""
                  echo -e "${cColorRojo}      El binario ~/bin/plaso-psort no existe. Intentando ejecutar desde el entorno virtual...${cFinColor}"
                  echo ""
                  source ~/repos/python/plaso/venv/bin/activate
                    psort "$vCarpetaDelCaso"/TodosLosEventosJuntos.plaso -o json_line -w "$vCarpetaDelCaso"/TimeLineDeTodosLosEventos.json_line
                  deactivate
                fi

            ;;

           10)

              echo ""
              echo "    Parseando el plaso a formato l2tcsv..."
              echo ""
              # Borrar primero el archivo anterior
                rm -f "$vCarpetaDelCaso"/TimeLineDeTodosLosEventos.l2tcsv 2> /dev/null
              # Tratar de ejecutar con el binario
                if [ -f ~/bin/plaso-psort ]; then
                  sudo ~/bin/plaso-psort "$vCarpetaDelCaso"/TodosLosEventosJuntos.plaso -o l2tcsv -w "$vCarpetaDelCaso"/TimeLineDeTodosLosEventos.l2tcsv
                else
                  echo ""
                  echo -e "${cColorRojo}      El binario ~/bin/plaso-psort no existe. Intentando ejecutar desde el entorno virtual...${cFinColor}"
                  echo ""
                  source ~/repos/python/plaso/venv/bin/activate
                    psort "$vCarpetaDelCaso"/TodosLosEventosJuntos.plaso -o l2tcsv -w "$vCarpetaDelCaso"/TimeLineDeTodosLosEventos.l2tcsv
                  deactivate
                fi

            ;;

           11)

              echo ""
              echo "    Parseando el plaso a formato l2ttln..."
              echo ""
              # Borrar primero el archivo anterior
                rm -f "$vCarpetaDelCaso"/TimeLineDeTodosLosEventos.l2ttln 2> /dev/null
              # Tratar de ejecutar con el binario
                if [ -f ~/bin/plaso-psort ]; then
                  sudo ~/bin/plaso-psort "$vCarpetaDelCaso"/TodosLosEventosJuntos.plaso -o l2ttln -w "$vCarpetaDelCaso"/TimeLineDeTodosLosEventos.l2ttln
                else
                  echo ""
                  echo -e "${cColorRojo}      El binario ~/bin/plaso-psort no existe. Intentando ejecutar desde el entorno virtual...${cFinColor}"
                  echo ""
                  source ~/repos/python/plaso/venv/bin/activate
                    psort "$vCarpetaDelCaso"/TodosLosEventosJuntos.plaso -o l2ttln -w "$vCarpetaDelCaso"/TimeLineDeTodosLosEventos.l2ttln
                  deactivate
                fi

            ;;

           12)

              echo ""
              echo "    Parseando el plaso a formato rawpy..."
              echo ""
              # Borrar primero el archivo anterior
                rm -f "$vCarpetaDelCaso"/TimeLineDeTodosLosEventos.rawpy 2> /dev/null
              # Tratar de ejecutar con el binario
                if [ -f ~/bin/plaso-psort ]; then
                  sudo ~/bin/plaso-psort "$vCarpetaDelCaso"/TodosLosEventosJuntos.plaso -o rawpy -w "$vCarpetaDelCaso"/TimeLineDeTodosLosEventos.rawpy
                else
                  echo ""
                  echo -e "${cColorRojo}      El binario ~/bin/plaso-psort no existe. Intentando ejecutar desde el entorno virtual...${cFinColor}"
                  echo ""
                  source ~/repos/python/plaso/venv/bin/activate
                    psort "$vCarpetaDelCaso"/TodosLosEventosJuntos.plaso -o rawpy -w "$vCarpetaDelCaso"/TimeLineDeTodosLosEventos.rawpy
                  deactivate
                fi
              # Extraer los bloques desde {xml_string} hasta </Event>
                awk '
                  /{xml_string}/ {capture=1; sub(/.*{xml_string} /,""); print $0; next}
                  capture {print}
                  /<\/Event>/ {capture=0}
                ' "$vCarpetaDelCaso"/TimeLineDeTodosLosEventos.rawpy > "$vCarpetaDelCaso"/TimeLineDeTodosLosEventosAgrupados.xml
              # Agregar etiqueta raíz
                sed -i '1i\<Events>' "$vCarpetaDelCaso"/TimeLineDeTodosLosEventosAgrupados.xml # Agrega la apertura de la etiqueta raiz en la primera linea
                echo '</Events>' >>  "$vCarpetaDelCaso"/TimeLineDeTodosLosEventosAgrupados.xml # Agrega el cierre de la etiqueta raíz en una nueva linea al final del archivo
              # Vaciar los atributos de la etiqueta Event
                sed -i 's/<Event .*>/<Event>/g' "$vCarpetaDelCaso"/TimeLineDeTodosLosEventosAgrupados.xml
              # Vaciar los atributos de la etiqueta EventXML
                sed -i 's/<EventXML .*>/<EventXML>/g' "$vCarpetaDelCaso"/TimeLineDeTodosLosEventosAgrupados.xml
              # Vaciar los atributos de la etiqueta EventData
                sed -i 's/<EventData .*>/<EventData>/g' "$vCarpetaDelCaso"/TimeLineDeTodosLosEventosAgrupados.xml
              # Extraer sólo las lineas que contengan commandline y cmd y powershell
                cat "$vCarpetaDelCaso"/TimeLineDeTodosLosEventosAgrupados.xml | grep -v 'CommandLine=</Data>' | grep -v '<Data Name="CommandLine"/>' | grep -iE "commandline|cmd|powershell" > "$vCarpetaDelCaso"/CommandLine.txt

            ;;

           13)

              echo ""
              echo "    Parseando el plaso a formato tln..."
              echo ""
              # Borrar primero el archivo anterior
                rm -f "$vCarpetaDelCaso"/TimeLineDeTodosLosEventos.tln 2> /dev/null
              # Tratar de ejecutar con el binario
                if [ -f ~/bin/plaso-psort ]; then
                  sudo ~/bin/plaso-psort "$vCarpetaDelCaso"/TodosLosEventosJuntos.plaso -o tln -w "$vCarpetaDelCaso"/TimeLineDeTodosLosEventos.tln
                else
                  echo ""
                  echo -e "${cColorRojo}      El binario ~/bin/plaso-psort no existe. Intentando ejecutar desde el entorno virtual...${cFinColor}"
                  echo ""
                  source ~/repos/python/plaso/venv/bin/activate
                    psort "$vCarpetaDelCaso"/TodosLosEventosJuntos.plaso -o tln -w "$vCarpetaDelCaso"/TimeLineDeTodosLosEventos.tln
                  deactivate
                fi

            ;;

           14)

              echo ""
              echo "    Parseando el plaso a formato xlsx..."
              echo ""
              # Borrar primero el archivo anterior
                rm -f "$vCarpetaDelCaso"/TimeLineDeTodosLosEventos.xlsx 2> /dev/null
              # Tratar de ejecutar con el binario
                if [ -f ~/bin/plaso-psort ]; then
                  sudo ~/bin/plaso-psort "$vCarpetaDelCaso"/TodosLosEventosJuntos.plaso -o xlsx -w "$vCarpetaDelCaso"/TimeLineDeTodosLosEventos.xlsx
                else
                  echo ""
                  echo -e "${cColorRojo}      El binario ~/bin/plaso-psort no existe. Intentando ejecutar desde el entorno virtual...${cFinColor}"
                  echo ""
                  source ~/repos/python/plaso/venv/bin/activate
                    psort "$vCarpetaDelCaso"/TodosLosEventosJuntos.plaso -o xlsx -w "$vCarpetaDelCaso"/TimeLineDeTodosLosEventos.xlsx
                  deactivate
                fi

            ;;

           15)

              echo ""
              echo "    Otros..."
              echo ""

              # Pasar todo el TimeLine de eventos, de json a xml
                # cat "$vCarpetaDelCaso"/Artefactos/Eventos/Parseados/TimeLineEventos.json | jq | grep xml_string | sed 's-"xml_string": "--g' | sed 's/\\n/\n/g' | sed '/^"/d' | sed 's-xmlns=\"http://schemas.microsoft.com/win/2004/08/events/event\"--g' > "$vCarpetaDelCaso"/Artefactos/Eventos/Parseados/TimeLineCompleto.xml

              # Exportando actividad del usuario específico desde el archivo .json
                #  echo ""
                #  echo "  Exportando actividad específica del usuario ..."
                #  echo ""
                #  vSIDDelUsuario="S-1-5-21-92896240-835188504-1963242017-1001"
                #  cat '/Casos/Examen/Eventos/Parseados/TimeLineEventos.json' | sed 's-/Casos/Examen/Eventos/Originales/--g'  | jq '.[] | select(.user_sid == "'"$vSIDDelUsuario"'")' > $vCarpetaDelCaso/Eventos/Parseados/TimeLineUsuario.json

              #     cat /Casos/Examen/Eventos/Parseados/TimeLineEventos.txt | sed 's-/Casos/Examen/Eventos/Originales/--g' | grep S-1-5-21 > $vCarpetaDelCaso/Eventos/Parseados/TimeLineUsuario.txt

            ;;

        esac

    done

fi
