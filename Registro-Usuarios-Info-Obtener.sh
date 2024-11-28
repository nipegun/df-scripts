#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# Definir constantes de color
  cColorAzul="\033[0;34m"
  cColorAzulClaro="\033[1;34m"
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

# Definir la cantidad de argumentos esperados
  cCantArgumEsperados=1

if [ $# -ne $cCantArgumEsperados ]
  then
    echo ""
    echo -e "${cColorRojo}  Mal uso del script. El uso correcto sería: ${cFinColor}"
    echo "    $0 [RutaAlArchivoSAM]"
    echo ""
    echo "  Ejemplo:"
    echo "    $0 '/Particiones/Pruebas/WINDOWS/system32/config/SAM'"
    echo ""
    exit
  else
    echo ""
    echo ""
    echo ""
    # Comprobar si el paquete dialog está instalado. Si no lo está, instalarlo.
      if [[ $(dpkg-query -s dialog 2>/dev/null | grep installed) == "" ]]; then
        echo ""
        echo -e "${cColorRojo}  El paquete dialog no está instalado. Iniciando su instalación...${cFinColor}"
        echo ""
        sudo apt-get -y update && sudo apt-get -y install dialog
        echo ""
      fi
    declare -A aUsuarios
    # Comprobar si el paquete chntpw está instalado. Si no lo está, instalarlo.
      if [[ $(dpkg-query -s chntpw 2>/dev/null | grep installed) == "" ]]; then
        echo ""
        echo -e "${cColorRojo}  El paquete chntpw no está instalado. Iniciando su instalación...${cFinColor}"
        echo ""
        sudo apt-get -y update && sudo apt-get -y install chntpw
        echo ""
      fi
    # Obtener pares de datos de RID y Username de todos los usuarios locales
    sudo chntpw -l /Particiones/Pruebas/WINDOWS/system32/config/SAM | grep -v sername
    cat $1$2

    # Leer la salida línea por línea, excluyendo la primera línea de encabezado
      while read -r line; do

      # Saltar la línea de encabezado o las líneas vacías
        [[ "$line" =~ "RID" || -z "$line" ]] && continue
  
      # Extraer el RID y el Nombre de Usuario usando awk
        rid=$(echo "$line" | awk '{print $1}')
        nombre_usuario=$(echo "$line" | awk '{print $2}')
  
      # Asignar al array asociativo
       usuarios["$rid"]="$nombre_usuario"
    done <<EOF
| 01f4 | Administrator                  | ADMIN  |          |
| 01f5 | Guest                          |        | *BLANK*  |
| 03e8 | HelpAssistant                  |        |          |
| 03eb | Mr. Evil                       | ADMIN  |          |
| 03ea | SUPPORT_388945a0               |        | dis/lock |
EOF

# Mostrar el contenido del array
for rid in "${!usuarios[@]}"; do
  echo "RID: $rid, Nombre de Usuario: ${usuarios[$rid]}"
done

fi

