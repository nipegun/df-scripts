#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para decompilar binarios en Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Reversing/Binarios/Decompilar.sh | bash -s [RutaAbsolutaAlArchivoBinario]
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Reversing/Binarios/Decompilar.sh | sed 's-sudo--g' | bash -s [RutaAbsolutaAlArchivoBinario]
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Reversing/Binarios/Decompilar.sh | nano -
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

# Comprobar si el paquete rizin está instalado. Si no lo está, instalarlo.
  if [[ $(dpkg-query -s rizin 2>/dev/null | grep installed) == "" ]]; then
    echo ""
    echo -e "${cColorRojo}    El paquete rizin no está instalado. Iniciando su instalación...${cFinColor}"
    echo ""
    sudo apt-get -y update
    sudo apt-get -y install rizin
    echo ""
  fi

# Determinar si es un binario de Linux, de macOS o de Windows
  if file "$cRutaAbsolutaAlArchivoBinario"   | grep -q "ELF"; then    # (Para Linux)
    echo ""
    echo "    El archivo parece ser un binario de Linux."
    echo ""
    r2pm -U
    r2pm -ci r2dec
    echo ""
    echo "      Decompilando funciones..."
    echo ""
    r2 -e bin.relocs.apply=true -Aqc "e scr.color=0; afl" "$cRutaAbsolutaAlArchivoBinario" > "$cCarpetaDondeGuardar""$cNombreDeArchivo".r2-ListaDeFunciones.txt
    echo ""
    r2 -AA -e bin.relocs.apply=true -Aqc "e scr.color=0; afl" "$cRutaAbsolutaAlArchivoBinario" > "$cCarpetaDondeGuardar""$cNombreDeArchivo".r2-ListaDeFunciones-Experimental.txt
    echo ""
    echo "      Decompilando completamente..."
    echo ""
    r2 -e bin.relocs.apply=true -Aqc "e scr.color=0; pdd" "$cRutaAbsolutaAlArchivoBinario" > "$cCarpetaDondeGuardar""$cNombreDeArchivo".r2-Decompilado.c
    echo ""
    r2 -AA -e bin.relocs.apply=true -Aqc "e scr.color=0; pdd" "$cRutaAbsolutaAlArchivoBinario" > "$cCarpetaDondeGuardar""$cNombreDeArchivo".r2-Decompilado-Experimental.c
    echo ""
  elif file "$cRutaAbsolutaAlArchivoBinario" | grep -q "PE32"; then   # (Para .exe o .dll)
    echo ""
    echo "    El archivo parece ser un binario de Windows."
    echo ""
    r2pm -U
    r2pm -ci r2dec
    echo ""
    echo "      Decompilando funciones..."
    echo ""
    r2 -e bin.cache=true -Aqc "e scr.color=0; afl" "$cRutaAbsolutaAlArchivoBinario"        > "$cCarpetaDondeGuardar""$cNombreDeArchivo".r2-ListaDeFunciones.txt
    echo ""
    r2 -AA -e bin.cache=true -Aqc "e scr.color=0; afl" "$cRutaAbsolutaAlArchivoBinario"        > "$cCarpetaDondeGuardar""$cNombreDeArchivo".r2-ListaDeFunciones-Experimental.txt
    echo ""
    echo "      Decompilando completamente..."
    echo ""
    r2 -e bin.cache=true -Aqc "e scr.color=0; pdd" "$cRutaAbsolutaAlArchivoBinario"        > "$cCarpetaDondeGuardar""$cNombreDeArchivo".r2-Decompilado.c
    echo ""
    r2 -AA -e bin.cache=true -Aqc "e scr.color=0; pdd" "$cRutaAbsolutaAlArchivoBinario"        > "$cCarpetaDondeGuardar""$cNombreDeArchivo".r2-Decompilado-Experimental.c
    echo ""
  elif file "$cRutaAbsolutaAlArchivoBinario" | grep -q "Mach-O"; then # (Para macOS)
    echo ""
    echo "    El archivo parece ser un binario de macOS."
    echo ""
    r2pm -U
    r2pm -ci r2dec
    echo ""
    echo "      Decompilando funciones..."
    echo ""
    r2 -e bin.cache=true -Aqc "e scr.color=0; afl" "$cRutaAbsolutaAlArchivoBinario"        > "$cCarpetaDondeGuardar""$cNombreDeArchivo".r2-ListaDeFunciones.txt
    echo ""
    r2 -AA -e bin.cache=true -Aqc "e scr.color=0; afl" "$cRutaAbsolutaAlArchivoBinario"        > "$cCarpetaDondeGuardar""$cNombreDeArchivo".r2-ListaDeFunciones-Experimental.txt
    echo ""
    echo "      Decompilando completamente..."
    echo ""
    r2 -e bin.cache=true -Aqc "e scr.color=0; pdd" "$cRutaAbsolutaAlArchivoBinario"        > "$cCarpetaDondeGuardar""$cNombreDeArchivo".r2-Decompilado.c
    echo ""
    r2 -AA -e bin.cache=true -Aqc "e scr.color=0; pdd" "$cRutaAbsolutaAlArchivoBinario"        > "$cCarpetaDondeGuardar""$cNombreDeArchivo".r2-Decompilado-Experimental.c
    echo ""
  else
    echo "No se pudo determinar si el binario es de Linux, Windows o macOS"
  fi

# Para decompilar con rizin
  #rizin -Aqc "pdg" "$cRutaAbsolutaAlArchivoBinario"        > "$cCarpetaDondeGuardar""$cNombreDeArchivo".rizin-Decompilado-Experimental.c


# Reparar permisos
  sudo chown $USER:$USER "$cCarpetaDondeGuardar" -R

# Notificar fin de ejecución del script
  echo ""
  echo "  Ejecución del script, finalizada..."
  echo ""

