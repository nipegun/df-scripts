#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para decompilar binarios en Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Reversing/Binarios/Desensamblar.sh | bash -s [RutaAbsolutaAlArchivoBinario]
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Reversing/Binarios/Desensamblar.sh | sed 's-sudo--g' | bash -s [RutaAbsolutaAlArchivoBinario]
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Reversing/Binarios/Desensamblar.sh | nano -
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
  cCantParamEsperados=1

# Comprobar que se hayan pasado la cantidad de parámetros correctos. Abortar el script si no.
  if [ $# -ne $cCantParamEsperados ]
    then
      echo ""
      echo -e "${cColorRojo}  Mal uso del script. El uso correcto sería: ${cFinColor}"
      echo "    $0 [RutaAbsolutaAlArchivoBinario]"
      echo ""
      echo "  Ejemplo:"
      echo "    $0 '/tmp/binario.bin'"
      echo ""
      exit
  fi

# Comprobar que exista el archivo
  if [ ! -f "$1" ]; then
    echo ""
    echo -e "${cColorRojo}    El archivo pasado como parámetro no existe. Abortando... ${cFinColor}"
    echo ""
    exit
  fi

# Definir constantes
  cRutaAbsolutaAlArchivoBinario="$1"
  cCarpetaDelArchivoBinario="$(echo "$cRutaAbsolutaAlArchivoBinario" | rev | cut -d'/' -f2- | rev)"
  cCarpetaDondeGuardar="$(echo "$cCarpetaDelArchivoBinario""/InfoDelBinario/")"
  cNombreDeArchivo="$(basename "$cRutaAbsolutaAlArchivoBinario")"
  sudo chown $USER:$USER "$cCarpetaDondeGuardar" -R

# Notificar inicio de ejecución del script
  echo ""
  echo -e "${cColorAzulClaro}   Iniciando el script de decompilado del binario $cNombreDeArchivo  ${cFinColor}"
  echo ""

# Desensamblar
  r2pm -U
  r2pm -ci r2dec
  echo ""
  echo "      Desensamblando..."
  echo ""
  r2 -Aqc "aaa; pdi""$cRutaAbsolutaAlArchivoBinario" > "$cCarpetaDondeGuardar""$cNombreDeArchivo".r2-Desensamblado.asm
  echo ""

# Reparar permisos
  sudo chown $USER:$USER "$cCarpetaDondeGuardar" -R

# Notificar fin de ejecución del script
  echo ""
  echo "  Ejecución del script, finalizada..."
  echo ""
