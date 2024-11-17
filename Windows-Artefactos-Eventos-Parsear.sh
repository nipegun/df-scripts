#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para parsear los eventos .evtx que se encuentren en una carpeta dada
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Windows-Artefactos-Eventos-Parsear.sh | sudo bash -s [CarpetaConEventosRecolectados] [CarpetaDondeGuardar]  (Ambas sin barra final)
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Windows-Artefactos-Eventos-Parsear.sh | nano -
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
    echo "    $0 [CarpetaConEventosRecolectados] [CarpetaDondeGuardar]  (Ambas sin barra final)"
    echo ""
    echo "  Ejemplo:"
    echo "    $0 '/mnt/Windows/' '/Casos/2/Particiones/'"
    echo ""
    exit
  else
    vCarpetaConEventosRecolectados="$1" # Debe ser una carpeta sin barra final
    vCarpetaDondeGuardar="$2"           # Debe ser una carpeta sin barra final
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
          1 "Parsear cada archivo .evtx original a .xml" on
          2 "Parsear cada archivo .evtx original a .txt" on
          3 "Unificando en un único archivo todos los archivos XML parseados" on
          4 "  Crear un único archivo con todos los eventos ordenados por fecha" off
          5 "  Crear un único archivo con todos los eventos del usuario ordenados por fecha" on
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
                  apt-get -y update && apt-get -y install libevtx-utils
                  echo ""
                fi
              # Recorrer la carpeta e ir convirtiendo
                mkdir -p "$vCarpetaDondeGuardar"/OriginalesEnXML/
                rm -rf "$vCarpetaDondeGuardar"/OriginalesEnXML/*
                find "$vCarpetaConEventosRecolectados"/ -name "*.evtx" | while read vArchivo; do
                  vArchivoDeSalida=""$vCarpetaDondeGuardar"/OriginalesEnXML/$(basename "$vArchivo" .evtx).xml"
                  evtxexport -f xml "$vArchivo" > "$vArchivoDeSalida" && sed -i '1d' "$vArchivoDeSalida" && sed -i 's/^<Event [^>]*>/<Event>/' "$vArchivoDeSalida"
                  #sed -i '1i\<root>' "$vArchivoDeSalida"
                  #echo '</root>' >> "$vArchivoDeSalida"
                done
              # Borrar todos los xml que no tengan la linea <Event>
                for archivo in "$vCarpetaDondeGuardar"/OriginalesEnXML/*; do # Recorre todos los archivos en el directorio
                  if ! grep -q "<Event>" "$archivo"; then # Verifica si el archivo contiene la línea "<Event>"
                    rm -f "$archivo" # Si no contiene "<Event>", lo elimina
                  fi
                done

            ;;

            2)

              echo ""
              echo "  Parseando cada archivo .evtx original a .txt..."
              echo ""
              # También convertir a texto
                mkdir -p "$vCarpetaDondeGuardar"/OriginalesEnTXT/
                rm -rf "$vCarpetaDondeGuardar"/OriginalesEnTXT/*
                find "$vCarpetaConEventosRecolectados"/ -name "*.evtx" | while read vArchivo; do
                  vArchivoDeSalida=""$vCarpetaDondeGuardar"/OriginalesEnTXT/$(basename "$vArchivo" .evtx).txt"
                  evtxexport "$vArchivo" > "$vArchivoDeSalida" && sed -i '1d' "$vArchivoDeSalida"
                done
              # Borrar todos los txt que no tengan el texto "Event number"
                for archivo in "$vCarpetaDondeGuardar"/OriginalesEnTXT/*; do # Recorre todos los archivos en el directorio
                  if ! grep -q "Event number" "$archivo"; then                            # Verifica si el archivo contiene la cadena "Even number" y
                    rm -f "$archivo"                                                      # si no contiene "Event number", lo elimina
                  fi
                done

            ;;

            3)

              echo ""
              echo "  Unificando en un único archivo todos los archivos XML parseados..."
              echo ""
              for archivo in "$vCarpetaDondeGuardar"/OriginalesEnXML/*; do # Recorre todos los archivos en el directorio
                cat "$archivo" >> "$vCarpetaDondeGuardar"/TodosLosEventos.xml
              done
              # Agregar una etiqueta raíz para poder trabajar con el xml
                sed -i '1i\<Events>' "$vCarpetaDondeGuardar"/TodosLosEventos.xml # Agrega la apertura de la etiqueta raiz en la primera linea
                echo '</Events>' >>  "$vCarpetaDondeGuardar"/TodosLosEventos.xml # Agrega el cierre de la etiqueta raíz en una nueva linea al final del archivo
              # Agregar una etiqueta raíz para poder trabajar con los xml a posteriori
                for vArchivo in "$vCarpetaDondeGuardar"/OriginalesEnXML/*; do # Recorre todos los archivos en el directorio
                  sed -i '1i\<Events>' "$vArchivo"                            # Agrega la apertura de la etiqueta raiz en la primera linea
                  echo '</Events>' >> "$vArchivo"                             # Agrega el cierre de la etiqueta raíz en una nueva linea al final del archivo
                done
              # Notificar el nombre del archivo
                echo ""
                echo "    El archivo con todos los eventos juntos, pero sin ordenar por fecha es:"
                echo ""
                echo "      "$vCarpetaDondeGuardar"/TodosLosEventos.xml"
                echo ""

            ;;

            4)

              echo ""
              echo "  Intentando crear un único archivo XML con todos los eventos ordenados por fecha..."
              echo ""
              #sed -i '1i\<root>' "$vCarpetaDondeGuardar"/TodosLosEventos.xml # Agrega la apertura de la etiqueta raiz en la primera linea
              #echo '</root>' >>  "$vCarpetaDondeGuardar"/TodosLosEventos.xml # Agrega el cierre de la etiqueta raíz en una nueva linea al final del archivo
              # Generar un archivo por cada evento dentro del xml
                # Crear una carpeta para almacenar los archivos de vEventos
                  mkdir -p "$vCarpetaDondeGuardar"/EventosIndividuales/
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
                        echo "$vEvento" > "$vCarpetaDondeGuardar"/EventosIndividuales/$vEvento_${vContador}.xml
                      # Incrementar el vContador y limpiar la variable del vEvento
                        vContador=$((vContador + 1))
                      vEvento=""
                    else
                      # Agregar la línea al bloque de vEvento en curso
                        vEvento+=$'\n'"$line"
                    fi
                  done < "$vCarpetaDondeGuardar"/TodosLosEventos.xml
                # Renombrar cada archivo con el valor del campo SystemTime
                  echo ""
                  echo "    Renombrando cada archivo .xml con el valor su etiqueta SystemTime..."
                  echo ""
                  mkdir -p "$vCarpetaDondeGuardar"/EventosIndividualesOrdenadosPorFecha/
                  # Recorrer cada archivo XML en la carpeta
                    for file in "$vCarpetaDondeGuardar"/EventosIndividuales/* ; do
                      # Extraer el valor de SystemTime usando xmlstarlet
                        system_time=$(xmlstarlet sel -t -v "//TimeCreated/@SystemTime" "$file" 2>/dev/null)
                      # Renombrar el archivo
                        cp "$file" "$vCarpetaDondeGuardar"/EventosIndividualesOrdenadosPorFecha/"${system_time}".xml
                    done
                  rm -f "$vCarpetaDondeGuardar"/EventosIndividualesOrdenadosPorFecha/.xml
                # Agregar los mensajes a los eventos
                  echo ""
                  echo "    Agregando los mensajes de evento a cada archivo .xml..."
                  echo ""
                  # Descargar el CSV con los eventos:
                    curl -sL https://raw.githubusercontent.com/nipegun/dicts/refs/heads/main/windows/eventos-en-es.csv -o /tmp/eventos-en-es.csv
                  # Declarar arrays para guardar los mensajes
                    declare -A aMensajesEng
                    declare -A aMensajesEsp
                  # Popular los arrays
                    while IFS=';' read -r campoIdDelEvento campoMensajeEng campoMensajeEsp; do
                      aMensajesEng["$campoIdDelEvento"]="$campoMensajeEng"
                      aMensajesEsp["$campoIdDelEvento"]="$campoMensajeEsp"
                    done < /tmp/eventos-en-es.csv
                  # Procesar cada archivo .xml
                    for vArchivoXML in "$vCarpetaDondeGuardar"/EventosIndividualesOrdenadosPorFecha/*.xml; do
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
                                    echo "    $vNuevaEtiquetaEng" >> "$vArchivoTemporal"
                                    echo "    $vNuevaEtiquetaEsp" >> "$vArchivoTemporal"
                                else
                                  echo "  No se encontró el evento $vIdDelEvento en el CSV."
                                fi
                            fi
                        done < "$vArchivoXML"
                        # Reemplazar el archivo original con el contenido actualizado
                          mv "$vArchivoTemporal" "$vArchivoXML"
                    done
                # Crear un nuevo archivo xml con todos los eventos
                  echo ""
                  echo "    Agrupando todos los archivos .xml únicos en un archivo unificado final..."
                  echo ""
                  # Este cat da error de memoria
                    #cat $(ls "$vCarpetaDondeGuardar"/EventosIndividualesOrdenadosPorFecha/* | sort) > "$vCarpetaDondeGuardar"/TodosLosEventosOrdenadosPorFecha.xml
                  # Probando con car directo
                    cat "$vCarpetaDondeGuardar"/EventosIndividualesOrdenadosPorFecha/20* > "$vCarpetaDondeGuardar"/TodosLosEventosOrdenadosPorFecha.xml
                  sed -i -e 's-</Event>-</Event>\n-g' "$vCarpetaDondeGuardar"/TodosLosEventosOrdenadosPorFecha.xml
                  sed -i '1i\<Events>' "$vCarpetaDondeGuardar"/TodosLosEventosOrdenadosPorFecha.xml # Agrega la apertura de la etiqueta raiz en la primera linea
                  echo '</Events>' >>  "$vCarpetaDondeGuardar"/TodosLosEventosOrdenadosPorFecha.xml # Agrega el cierre de la etiqueta raíz en una nueva linea al final del archivo
                # Notificar el nombre del archivo
                  echo ""
                  echo "    El archivo con todos los eventos juntos, ordenado por fecha es:"
                  echo ""
                  echo "      "$vCarpetaDondeGuardar"/TodosLosEventosOrdenadosPorFecha.xml"
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
                  apt-get -y update && apt-get -y install libxml2-utils
                  echo ""
                fi
              xmllint --xpath '//*[Data[@Name="SubjectUserSid" and text()='"'$vSIDDelUsuario'"']]/parent::*' "$vCarpetaDondeGuardar"/OriginalesEnXML/*  > "$vCarpetaDondeGuardar"/TodosLosEventosDelUsuario.xml 2> /dev/null
              xmllint --xpath '//*[Security[@UserID='"'$vSIDDelUsuario'"']]/parent::*'                       "$vCarpetaDondeGuardar"/OriginalesEnXML/* >> "$vCarpetaDondeGuardar"/TodosLosEventosDelUsuario.xml 2> /dev/null
              sed -i '1i\<root>' "$vCarpetaDondeGuardar"/TodosLosEventosDelUsuario.xml # Agrega la apertura de la etiqueta raiz en la primera linea
              echo '</root>' >>  "$vCarpetaDondeGuardar"/TodosLosEventosDelUsuario.xml # Agrega el cierre de la etiqueta raíz en una nueva linea al final del archivo
              # Generar un archivo por cada evento dentro del xml
                # Crear una carpeta para almacenar los archivos de vEventos
                  mkdir -p "$vCarpetaDondeGuardar"/EventosIndividualesDeUsuario/
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
                        echo "$vEvento" > "$vCarpetaDondeGuardar"/EventosIndividualesDeUsuario/$vEvento_${vContador}.xml
                      # Incrementar el vContador y limpiar la variable del vEvento
                        vContador=$((vContador + 1))
                      vEvento=""
                    else
                      # Agregar la línea al bloque de vEvento en curso
                        vEvento+=$'\n'"$line"
                    fi
                  done < "$vCarpetaDondeGuardar"/TodosLosEventosDelUsuario.xml
                # Renombrar cada archivo con el valor del campo SystemTime
                  echo ""
                  echo "    Renombrando cada archivo .xml con el valor su etiqueta SystemTime..."
                  echo ""
                  mkdir -p "$vCarpetaDondeGuardar"/EventosIndividualesDeUsuarioOrdenadosPorFecha/
                  # Recorrer cada archivo XML en la carpeta
                    for file in "$vCarpetaDondeGuardar"/EventosIndividualesDeUsuario/* ; do
                      # Extraer el valor de SystemTime usando xmlstarlet
                        system_time=$(xmlstarlet sel -t -v "//TimeCreated/@SystemTime" "$file" 2>/dev/null)
                      # Renombrar el archivo
                        cp "$file" "$vCarpetaDondeGuardar"/EventosIndividualesDeUsuarioOrdenadosPorFecha/"${system_time}".xml
                    done
                  rm -f "$vCarpetaDondeGuardar"/EventosIndividualesDeUsuarioOrdenadosPorFecha/.xml
                # Agregar los mensajes a los eventos
                  echo ""
                  echo "    Agregando los mensajes de evento a cada archivo .xml..."
                  echo ""
                  # Descargar el CSV con los eventos:
                    curl -sL https://raw.githubusercontent.com/nipegun/dicts/refs/heads/main/windows/eventos-en-es.csv -o /tmp/eventos-en-es.csv
                  # Declarar arrays para guardar los mensajes
                    declare -A aMensajesEng
                    declare -A aMensajesEsp
                  # Popular los arrays
                    while IFS=';' read -r campoIdDelEvento campoMensajeEng campoMensajeEsp; do
                      aMensajesEng["$campoIdDelEvento"]="$campoMensajeEng"
                      aMensajesEsp["$campoIdDelEvento"]="$campoMensajeEsp"
                    done < /tmp/eventos-en-es.csv
                  # Procesar cada archivo .xml
                    for vArchivoXML in "$vCarpetaDondeGuardar"/EventosIndividualesDeUsuarioOrdenadosPorFecha/*.xml; do
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
                                    echo "    $vNuevaEtiquetaEng" >> "$vArchivoTemporal"
                                    echo "    $vNuevaEtiquetaEsp" >> "$vArchivoTemporal"
                                else
                                  echo "  No se encontró el evento $vIdDelEvento en el CSV."
                                fi
                            fi
                        done < "$vArchivoXML"
                        # Reemplazar el archivo original con el contenido actualizado
                          mv "$vArchivoTemporal" "$vArchivoXML"
                    done
                # Crear un nuevo archivo xml con todos los eventos
                  echo ""
                  echo "    Agrupando todos los archivos .xml únicos en un archivo unificado final..."
                  echo ""
                  cat $(ls "$vCarpetaDondeGuardar"/EventosIndividualesDeUsuarioOrdenadosPorFecha/* | sort) > "$vCarpetaDondeGuardar"/TodosLosEventosDelUsuarioOrdenadosPorFecha.xml
                  sed -i -e 's-</Event>-</Event>\n-g' "$vCarpetaDondeGuardar"/TodosLosEventosDelUsuarioOrdenadosPorFecha.xml
                  sed -i '1i\<Events>' "$vCarpetaDondeGuardar"/TodosLosEventosDelUsuarioOrdenadosPorFecha.xml # Agrega la apertura de la etiqueta raiz en la primera linea
                  echo '</Events>' >>  "$vCarpetaDondeGuardar"/TodosLosEventosDelUsuarioOrdenadosPorFecha.xml # Agrega el cierre de la etiqueta raíz en una nueva linea al final del archivo
                # Notificar el nombre del archivo
                  echo ""
                  echo "    El archivo con todos los eventos de usuario juntos, ordenado por fecha es:"
                  echo ""
                  echo "      "$vCarpetaDondeGuardar"/TodosLosEventosDelUsuarioOrdenadosPorFecha.xml"
                  echo ""

            ;;

        esac

    done

fi