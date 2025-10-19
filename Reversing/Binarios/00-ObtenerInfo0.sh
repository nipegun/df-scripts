#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para obtener datos sobre binarios de Linux
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Reversing/Binarios/00-ObtenerInfo.sh | bash -s [RutaAbsolutaAlArchivoBinario]
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Reversing/Binarios/00-ObtenerInfo.sh | sed 's-sudo--g' | bash -s [RutaAbsolutaAlArchivoBinario]
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Reversing/Binarios/00-ObtenerInfo.sh | nano -
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

# Crear carpeta
  sudo mkdir -p "$cCarpetaDondeGuardar"/SiMóduloDelKernel/
  sudo chown $USER:$USER "$cCarpetaDondeGuardar" -R

# Obtener info del elf

  # file
    # Comprobar si el paquete file está instalado. Si no lo está, instalarlo.
      if [[ $(dpkg-query -s file 2>/dev/null | grep installed) == "" ]]; then
        echo ""
        echo -e "${cColorRojo}    El paquete file no está instalado. Iniciando su instalación...${cFinColor}"
        echo ""
        sudo apt-get -y update
        sudo apt-get -y install file
        echo ""
      fi 
    file "$cRutaAbsolutaAlArchivoBinario" &> "$cCarpetaDondeGuardar""$cNombreDeArchivo".file.txt

  # readelf
    # Comprobar si el paquete binutils está instalado. Si no lo está, instalarlo.
      if [[ $(dpkg-query -s binutils 2>/dev/null | grep installed) == "" ]]; then
        echo ""
        echo -e "${cColorRojo}    El paquete binutils no está instalado. Iniciando su instalación...${cFinColor}"
        echo ""
        sudo apt-get -y update
        sudo apt-get -y install binutils
        echo ""
      fi
    readelf -h -l -S -s -r -d -V -A -I -n -N -x . -w -W          "$cRutaAbsolutaAlArchivoBinario" &> "$cCarpetaDondeGuardar""$cNombreDeArchivo".readelf.txt

  # objdump
    objdump x -s -S -D -r -R -t -T -p -f -g -G -h -w -W --source "$cRutaAbsolutaAlArchivoBinario" &> "$cCarpetaDondeGuardar""$cNombreDeArchivo".objdump.txt

  # strings
    strings -a                                                   "$cRutaAbsolutaAlArchivoBinario" &> "$cCarpetaDondeGuardar""$cNombreDeArchivo".strings.txt

  # hexdump
    # Comprobar si el paquete bsdextrautils está instalado. Si no lo está, instalarlo.
      if [[ $(dpkg-query -s bsdextrautils 2>/dev/null | grep installed) == "" ]]; then
        echo ""
        echo -e "${cColorRojo}    El paquete bsdextrautils no está instalado. Iniciando su instalación...${cFinColor}"
        echo ""
        sudo apt-get -y update
        sudo apt-get -y install bsdextrautils
        echo ""
      fi
    hexdump -C                                                   "$cRutaAbsolutaAlArchivoBinario" &> "$cCarpetaDondeGuardar""$cNombreDeArchivo".hexdump.txt


# Ver si es módulo
  sudo cp "$cRutaAbsolutaAlArchivoBinario" "$cCarpetaDondeGuardar"/SiMóduloDelKernel/"$cNombreDeArchivo".ko
  # info
    # Comprobar si el paquete kmod está instalado. Si no lo está, instalarlo.
      if [[ $(dpkg-query -s kmod 2>/dev/null | grep installed) == "" ]]; then
        echo ""
        echo -e "${cColorRojo}    El paquete kmod no está instalado. Iniciando su instalación...${cFinColor}"
        echo ""
        sudo apt-get -y update
        sudo apt-get -y install kmod
        echo ""
      fi
    sudo modinfo "$cCarpetaDondeGuardar"/SiMóduloDelKernel/"$cNombreDeArchivo".ko &> "$cCarpetaDondeGuardar"/SiMóduloDelKernel/"$cNombreDeArchivo".ko.modinfo.txt
  # Ver qué símbolos exporta
    sudo nm -D "$cCarpetaDondeGuardar"/SiMóduloDelKernel/"$cNombreDeArchivo".ko   &> "$cCarpetaDondeGuardar"/SiMóduloDelKernel/"$cNombreDeArchivo".ko.simbolosqueexporta.txt
  # Ver qué dependencias tiene (por si hace falta enlazarlo)
    # Comprobar si el paquete libc-bin está instalado. Si no lo está, instalarlo.
      if [[ $(dpkg-query -s libc-bin 2>/dev/null | grep installed) == "" ]]; then
        echo ""
        echo -e "${cColorRojo}    El paquete libc-bin no está instalado. Iniciando su instalación...${cFinColor}"
        echo ""
        sudo apt-get -y update
        sudo apt-get -y install libc-bin
        echo ""
      fi
    sudo ldd "$cCarpetaDondeGuardar"/SiMóduloDelKernel/"$cNombreDeArchivo".ko     &> "$cCarpetaDondeGuardar"/SiMóduloDelKernel/"$cNombreDeArchivo".ko.dependencias.txt

# Reparar permisos
  sudo chown $USER:$USER "$cCarpetaDondeGuardar" -R

# Notificar fin de ejecución del script
  echo ""
  echo "  Ejecución del script, finalizada..."
  echo ""
