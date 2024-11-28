#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para montar una imagen desde un offset específico
#
# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Imagen-Particion-NTFS-Montar-DesdeOffsetIndicado-SoloLectura.sh | bash -s [RutaAlArchivoDeImagen] [PuntoDeMontaje] [Offset]
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Imagen-Particion-NTFS-Montar-DesdeOffsetIndicado-SoloLectura.sh | nano -
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
  cCantArgumEsperados=3

if [ $# -ne $cCantArgumEsperados ]
  then
    echo ""
    echo -e "${cColorRojo}  Mal uso del script. El uso correcto sería: ${cFinColor}"
    echo ""
    echo "    $0 [RutaAlArchivoDeImagen] [PuntoDeMontaje] [Offset]"
    echo ""
    echo "  Ejemplo:"
    echo "    $0 '~/Descargas/Imagen.dd' '/Particiones/Pruebas' '63'"
    echo ""
    exit
  else
    echo ""
    echo ""
    echo ""
    if [ -d "$2" ]; then
      sudo mount "$1" "$2" -o ro,loop,show_sys_files,streams_interface=windows,offset=$(($3*512))
      sudo chown $USER:$USER "$1" -R
      sudo chown $USER:$USER "$2" -R
    else
      sudo mkdir -p "$2"
      sudo mount "$1" "$2" -o ro,loop,show_sys_files,streams_interface=windows,offset=$(($3*512))
      sudo chown $USER:$USER "$1" -R
      sudo chown $USER:$USER "$2" -R
    fi
fi
