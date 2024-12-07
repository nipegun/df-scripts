#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para parsear datos extraidos de la RAM de Windows en Debian
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Windows-Artefactos-RAM-Extraer-DeDump-ConVolatility2.sh | sudo bash -s [RutaAlArchivoConDump]
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Windows-Artefactos-RAM-Extraer-DeDump-ConVolatility2.sh | nano -
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

if [ $# -ne $cCantParamEsperados ]
  then
    echo ""
    echo -e "${cColorRojo}  Mal uso del script. El uso correcto sería: ${cFinColor}"
    echo "    $0 [RutaAlArchivoConDump] [CarpetaDondeGuardar]"
    echo ""
    echo "  Ejemplo:"
    echo "    $0 [/Casos/a2024m11d24/Dump/RAM.dump] [/Casos/a2024m11d24/Artefactos]"
    echo ""
    exit
  else
    # Crear constante para archivo de dump
      cRutaAlArchivoDeDump="$1"
      cCarpetaDondeGuardar="$2"
      mkdir -p "$cCarpetaDondeGuardar"
      echo ""
      echo "  Calculando los posibles perfiles de volatility2 que se le pueden aplicar al dump..."
      echo ""
      vPerfilesPosibles=(vol.py -f "$cRutaAlArchivoDeDump" imageinfo | grep uggested | cut -d':' -f2 | sed 's-,--g' | sed "s- -\n-" | sed 's- -|-g')
      echo "    Los posibles perfiles son:"
      echo "      $vPerfilesPosibles"
      echo ""
      mkdir -p /tmp/volatility2/
      # Guardar todos los perfiles en un archivo
        vol.py --info | grep "A Profile" | cut -d' ' -f1 > /tmp/volatility2/Volatility2-TodosLosPerfiles.txt
      # Guardar los perfiles sugeridos en un archivo
        vol.py -f "$cRutaAlArchivoDeDump" imageinfo | grep uggested | cut -d':' -f2 | sed 's-,--g' | sed "s- -\n-" | sed 's- -|-g' | sed 's/|/\n/g' | sed 's-  --g' | sed 's- --g' | sed '/^$/d' > /tmp/Volatility2-PerfilesSugeridos.txt
      # Guardar todos los plugins en un archivo
        vol.py -h | sed "s-\t-|-g" | grep "^||" | sed 's-|--g' | cut -d' ' -f1 > /tmp/volatility2/Volatility2-Plugins.txt
      #
        while IFS= read -r vPerfil; do
          echo "  Aplicando todos los plugins del perfil $vPerfil..."
          while IFS= read -r vPlugin; do
            echo "    Aplicando el plugin $vPlugin..."
            vol.py -f "$cRutaAlArchivoDeDump" --profile=$vPerfil $vPlugin > /tmp/volatility2/Volatility2-"$vPerfil"-"$vPlugin".txt
          done < /tmp/volatility2/Volatility2-Plugins.txt
        done <   /tmp/volatility2/Volatility2-PerfilesSugeridos.txt

fi
