#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para montar todas las particiones de dentro de un archivo de imagen
#
# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Imagen-Particion-NTFS-Montar-DesdeOffsetAutomatico-SoloLectura.sh | bash -s [RutaAlArchivoDeImagen] [PuntoDeMontaje] [Offset]
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Imagen-Particion-NTFS-Montar-DesdeOffsetAutomatico-SoloLectura.sh | nano -
# ----------

# Definir fecha de ejecución del script
  cFechaDeEjec=$(date +a%Ym%md%d@%T)
      
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

# Montar todas las particiones
  for vOffsetDeInicio in "${aOffsetsDeInicio[@]}"; do
    mkdir -p /Casos/$cFechaDeEjec/Particiones/Offset$vOffsetDeInicio
    mount -o loop,offset=$vOffsetDeInicio "$1" /Casos/$cFechaDeEjec/Particiones/Offset$vOffsetDeInicio
  done

# Determinar el primer dispositivo de loopback disponible
  echo ""
  echo "    Determinando el primer dispositivo de loopback libre..."
  vPrimerDispLB=$(losetup -f)
  echo ""
  echo "      El primer dispositivo de loopback libre es $vPrimerDispLB"
  echo ""

