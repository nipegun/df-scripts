#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para buscar direcciones IP privadas en archivos usando Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/CTFs/Reversing/IPs-Privadas-BuscarEnArchivo.sh | bash -s [RutaAlArchivo]
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/CTFs/Reversing/IPs-Privadas-BuscarEnArchivo.sh | sed 's-sudo--g' | bash -s [RutaAlArchivo]
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/CTFs/Reversing/IPs-Privadas-BuscarEnArchivo.sh | nano -
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
  cCantArgsEsperados=1

# Comprobar que se hayan pasado la cantidad de argumentos esperados. Abortar el script si no.
  if [ $# -ne $cCantArgsEsperados ]
    then
      echo ""
      echo -e "${cColorRojo}  Mal uso del script. El uso correcto sería: ${cFinColor}"
      echo ""
      if [[ "$0" == "bash" ]]; then
        vNombreDelScript="script.sh"
      else
        vNombreDelScript="$0"
      fi
      echo "    $vNombreDelScript [RutaAlArchivo]"
      echo ""
      echo "  Ejemplo:"
      echo ""
      echo "    $vNombreDelScript '/home/usuariox/Descargas/binario'"
      echo ""
      exit
  fi

cArchivo="$1"

# Comprobar si el paquete binutils está instalado. Si no lo está, instalarlo.
  if [[ $(dpkg-query -s binutils 2>/dev/null | grep installed) == "" ]]; then
    echo ""
    echo -e "${cColorRojo}  El paquete binutils no está instalado. Iniciando su instalación...${cFinColor}"
    echo ""
    sudo apt-get -y update
    sudo apt-get -y install binutils
    echo ""
  fi

# Buscar direcciones IP privadas de clase A
  echo ""
  echo "  Buscando IPs privadas de clase A..."
  echo ""
  strings "$cArchivo" | grep -Eo '10\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])' | sort -n | uniq

# Buscar direcciones IPs privadas de clase B
  echo ""
  echo "  Buscando IPs privadas de clase B..."
  echo ""
  strings "$cArchivo" | grep -Eo '172\.(1[6-9]|2[0-9]|3[0-1])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])' | sort -n | uniq

# Buscar direcciones IPs privadas de clase C
  echo ""
  echo "  Buscando IPs privadas de clase C..."
  echo ""
  strings "$cArchivo" | grep -Eo '192\.168\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])' | sort -n | uniq
