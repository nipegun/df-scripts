#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para copiar los eventos de una partición de Windows y parsearlos a xml
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Windows-Artefactos-Eventos-Extraer.sh | sudo bash -s [PuntoDeMontajePartWindows] [CarpetaDelCaso]  (Ambos sin barra final)
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Windows-Artefactos-Eventos-Extraer.sh | nano -
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
    echo "    $0 [PuntoDeMontajePartWindows] [CarpetaDelCaso] (Ambos sin barra final)"
    echo ""
    echo "  Ejemplo:"
    echo "    $0 '/mnt/Windows/' '/Casos/2/Particiones/'"
    echo ""
    exit
  else
    vPuntoDeMontajePartWindows="$1"
    vCarpetaDelCaso="$2"

    # Copiar los eventos originales
      echo ""
      echo "    Copiando todos los eventos .evtx de la partición de Windows a la carpeta del caso..."
      echo ""
      sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Eventos/
      sudo rm -rf "$vCarpetaDelCaso"/Artefactos/Originales/Eventos/*
      find "$vPuntoDeMontajePartWindows" -name "*.evtx" -exec sudo cp -v {} "$vCarpetaDelCaso"/Artefactos/Originales/Eventos/ \;

    # Reparar permisos
      sudo chown 1000:1000 "$vCarpetaDelCaso"/Artefactos/ -R

fi

