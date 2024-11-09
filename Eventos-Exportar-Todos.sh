#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para exportar eventos de una partición de Windows y parsearlos a xml
#
# Ejecución remota:
#   curl -sL x | bash
#
# Ejecución remota sin caché:
#   curl -sL -H 'Cache-Control: no-cache, no-store' x | bash
#
# Ejecución remota con parámetros:
#   curl -sL x | bash -s Parámetro1 Parámetro2
#
# Bajar y editar directamente el archivo en nano
#   curl -sL x | nano -
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
      find $vPuntoDeMontajePartWindows -name "*.evtx" -exec cp {} $vCarpetaDelCaso/Eventos/Crudos/ \;

    # Parsear los eventos
      mkdir -p $vCarpetaDelCaso/Eventos/Parseados
      # Comprobar si el paquete libevtx-utils está instalado. Si no lo está, instalarlo.
        if [[ $(dpkg-query -s libevtx-utils 2>/dev/null | grep installed) == "" ]]; then
          echo ""
          echo -e "${cColorRojo}  El paquete libevtx-utils no está instalado. Iniciando su instalación...${cFinColor}"
          echo ""
          apt-get -y update && apt-get -y install libevtx-utils
          echo ""
        fi
      # Recorrer la carpeta y guardar todos los logs
        find $vCarpetaDelCaso/Eventos/Crudos/ -name "*.evtx" | while read vArchivo; do
          vArchivoDeSalida="$vCarpetaDelCaso/Eventos/Parseados/$(basename "$vArchivo" .evtx).xml"
          evtxexport -f xml "$vArchivo" > "$vArchivoDeSalida"
        done
fi

