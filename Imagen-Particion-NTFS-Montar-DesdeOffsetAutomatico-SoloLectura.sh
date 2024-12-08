#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para montar una imagen desde un offset específico
#
# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Imagen-Particion-NTFS-Montar-DesdeOffsetAutomatico-SoloLectura.sh | bash -s [RutaAlArchivoDeImagen] [PuntoDeMontaje] [Offset]
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Imagen-Particion-NTFS-Montar-DesdeOffsetAutomatico-SoloLectura.sh | nano -
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
  cCantArgumEsperados=2

if [ $# -ne $cCantArgumEsperados ]
  then
    echo ""
    echo -e "${cColorRojo}  Mal uso del script. El uso correcto sería: ${cFinColor}"
    echo ""
    echo "    $0 [RutaAlArchivoDeImagen] [PuntoDeMontaje]"
    echo ""
    echo "  Ejemplo:"
    echo ""
    echo "    $0 '~/Descargas/Imagen.dd' '/Particiones/Pruebas'"
    echo ""
    exit
  else
    echo ""
    echo "  Intentando montar la primer partición NTFS de dentro del archivo de imagen $1"
    echo ""
    # Calcular offset
      # Comprobar si el paquete sleuthkit está instalado. Si no lo está, instalarlo.
        if [[ $(dpkg-query -s sleuthkit 2>/dev/null | grep installed) == "" ]]; then
          echo ""
          echo -e "${cColorRojo}  El paquete sleuthkit no está instalado. Iniciando su instalación...${cFinColor}"
          echo ""
          sudo apt-get -y update
          sudo apt-get -y install sleuthkit
          echo ""
        fi
      vOffset=$(mmls "$1" | grep NTFS | sed 's-  - -g' | sed 's-  - -g' | cut -d' ' -f3 | sed 's/^0*//')
    if [ -d "$2" ]; then
      sudo mount "$1" "$2" -o ro,loop,show_sys_files,streams_interface=windows,offset=$(($vOffset*512))
    else
      sudo mkdir -p "$2"
      sudo mount "$1" "$2" -o ro,loop,show_sys_files,streams_interface=windows,offset=$(($vOffset*512))
      sudo chown $USER:$USER "$1" -R
      sudo chown $USER:$USER "$2" -R
    fi
fi
