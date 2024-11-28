#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para montar todas las particiones de dentro de un archivo de imagen
#
# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Imagen-Particiones-Todas-Montar-SoloLectura.sh | sudo bash -s [RutaAlArchivoDeImagen]
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Imagen-Particiones-Todas-Montar-SoloLectura.sh | nano -
# ----------

# Definir fecha de ejecución del script
  cFechaDelCaso=$(date +a%Ym%md%d)

# Definir constantes de color
  cColorAzul="\033[0;34m"
  cColorAzulClaro="\033[1;34m"
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

# Definir la cantidad de argumentos esperados
  cCantParamEsperados=1

# Comprobar que se hayan pasado la cantidad de parámetros correctos y proceder
  if [ $# -ne $cCantParamEsperados ]
    then
      echo ""
      echo -e "${cColorRojo}  No le has pasado un parámetro al script. El uso correcto sería: ${cFinColor}"
      echo ""
      echo "    $0 [RutaAlArchivoDeImagen]"
      echo ""
      echo "  Ejemplo:"
      echo ""
      echo "    $0 '/home/pepe/Descargas/imagen.img'"
      echo ""
      exit
    else
      # vTamAsigMinCluster
        # Comprobar si el paquete sleuthkit está instalado. Si no lo está, instalarlo.
          if [[ $(dpkg-query -s sleuthkit 2>/dev/null | grep installed) == "" ]]; then
            echo ""
            echo -e "${cColorRojo}  El paquete sleuthkit no está instalado. Iniciando su instalación...${cFinColor}"
            echo ""
            sudo apt-get -y update && sudo apt-get -y install sleuthkit
            echo ""
          fi
        vBytesPorSector=$(mmls "$1" | grep ector | grep - | cut -d'-' -f1 | sed 's- -\n-g' | grep ^[0-9])
        echo -e "\n" && echo "  Se calcularán offsets finales para tamaño de sector de $vBytesPorSector bytes..." && echo -e "\n"
      # Crear un array con los offsets de incio de cada partición
        aOffsetsDeInicio=()
        # Comprobar si el paquete fdisk está instalado. Si no lo está, instalarlo.
          if [[ $(dpkg-query -s fdisk 2>/dev/null | grep installed) == "" ]]; then
            echo ""
            echo -e "${cColorRojo}  El paquete fdisk no está instalado. Iniciando su instalación...${cFinColor}"
            echo ""
            sudo apt-get -y update && sudo apt-get -y install fdisk
            echo ""
          fi
        for vOffset in $(sudo fdisk -l -o Device,Start "$1" | grep ^/ | rev | cut -d' ' -f1 | rev); do
          aOffsetsDeInicio+=("$vOffset")
        done

      # Multiplicar el valor de cada campo del array x el tamaño de bloque
        for vNroOffsetSimple in "${aOffsetsDeInicio[@]}"; do
          echo "  Multiplicando por $vBytesPorSector el offset $vNroOffsetSimple"
          vOffsetMultiplicado=$((vNroOffsetSimple * $vBytesPorSector))
          aNuevosOffsets+=("$vOffsetMultiplicado")
        done
        echo ""

      # Crear la carpeta del caso y montar las particiones como sólo lectura
        # Comprobar si el paquete util-linux está instalado. Si no lo está, instalarlo.
          if [[ $(dpkg-query -s util-linux 2>/dev/null | grep installed) == "" ]]; then
            echo ""
            echo -e "${cColorRojo}  El paquete util-linux no está instalado. Iniciando su instalación...${cFinColor}"
            echo ""
            sudo apt-get -y update && sudo apt-get -y install util-linux
            echo ""
          fi
        for vIndice in "${!aNuevosOffsets[@]}"; do
          sudo mkdir -p /Casos/$cFechaDelCaso/Imagen/Particiones/$((vIndice + 1))
          
          vDispositivoLoopLibre=$(sudo losetup -f)
          sudo losetup -f -o ${aNuevosOffsets[vIndice]} $1 && echo -e "\n" && echo "  Partición del offset ${aNuevosOffsets[vIndice]} asignada a $vDispositivoLoopLibre. "
          sudo mount -o ro,show_sys_files,streams_interface=windows $vDispositivoLoopLibre /Casos/$cFechaDelCaso/Imagen/Particiones/$((vIndice + 1)) && echo -e "\n" && echo "    $vDispositivoLoopLibre montado en /Casos/$cFechaDelCaso/Imagen/Particiones/$((vIndice + 1))." && echo -e "\n"
        done
        echo ""

  fi

