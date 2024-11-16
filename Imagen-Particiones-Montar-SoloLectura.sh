#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para montar todas las particiones de dentro de un archivo de imagen
#
# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Imagen-Particiones-Montar-SoloLectura.sh | sudo bash -s [RutaAlArchivoDeImagen]
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Imagen-Particiones-Montar-SoloLectura.sh | nano -
# ----------

# Definir fecha de ejecución del script
  cFechaDelCaso=$(date +a%Ym%md%d)

# vTamAsigMinCluster
  vBytesPorSector=512

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

# Crear un array con los offsets de incio de cada partición
  aOffsetsDeInicio=()
  # Comprobar si el paquete fdisk está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s fdisk 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${cColorRojo}  El paquete fdisk no está instalado. Iniciando su instalación...${cFinColor}"
      echo ""
      apt-get -y update && apt-get -y install fdisk
      echo ""
    fi
  for vOffset in $(fdisk -l -o Device,Start "$1" | grep ^/ | rev | cut -d' ' -f1 | rev); do
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
  for vIndice in "${!aNuevosOffsets[@]}"; do
    mkdir -p /Casos/$cFechaDeEjec/Imagen/Particiones/$((vIndice + 1))
    vDispositivoLoopLibre=$(losetup -f)
    losetup -f -o ${aNuevosOffsets[vIndice]} $1 && echo "  Partición del offset ${aNuevosOffsets[vIndice]} asignada a $vDispositivoLoopLibre. "
    mount -o ro,show_sys_files,streams_interface=windows $vDispositivoLoopLibre /Casos/$cFechaDelCaso/Imagen/Particiones/$((vIndice + 1)) &&  echo "    $vDispositivoLoopLibre montado en /Casos/$cFechaDelCaso/Imagen/Particiones/$((vIndice + 1))."
  done
  echo ""
