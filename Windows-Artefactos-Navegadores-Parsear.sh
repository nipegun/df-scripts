


# Historial de todos los navegadores en CSV
browser-history --type history --browser all --format csv --output history_all.csv

# Marcadores de todos los navegadores en JSON
browser-history --type bookmarks --browser all --format json --output bookmarks_all.json

# Historial de Chrome en JSONL
browser-history --type history --browser Chrome --format jsonl --output chrome_history.jsonl

# Marcadores de Firefox en CSV para el perfil predeterminado
browser-history --type bookmarks --browser Firefox --format csv --profile default --output firefox_bookmarks.csv

# Historial de Brave en todos los perfiles, sin guardar en archivo
browser-history --type history --browser Brave

# Marcadores de todos los navegadores en JSON, sin guardar en archivo
browser-history --type bookmarks --browser all --format json

# Mostrar perfiles disponibles para Opera
browser-history --show-profiles Opera

# Historial de Edge en CSV para un perfil específico
browser-history --type history --browser Edge --format csv --profile "Profile 2" --output edge_profile2_history.csv

# Marcadores de LibreWolf en JSONL
browser-history --type bookmarks --browser LibreWolf --format jsonl --output librewolf_bookmarks.jsonl

# Historial de todos los navegadores, formato inferido por extensión
browser-history --type history --browser all --output detailed_history_output.csv


#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para parsear el archivo $MFT original a múltimples formatos
#
# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Windows-Artefactos-MFT-Parsear.sh | bash -s [CarpetaConLaMFTOriginal] [CarpetaDondeGuardarLosParseos]
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Windows-Artefactos-MFT-Parsear.sh | nano -
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
    echo "    $0  [CarpetaConLaMFTOriginal] [CarpetaDondeGuardarLosParseos]"
    echo ""
    echo "  Ejemplo:"
    echo "    $0 '/Casos/a2024m11d29/Artefactos/Originales/MFT' '/Casos/a2024m11d29/Artefactos/Parseados/MFT'"
    exit
  else
    # Comprobar que exista analyzemft
      if [ ! -f /usr/bin/analyzeMFT ]; then
        echo ""
        echo -e "${cColorRojo}    El binario de analyzemft no está instalado. Instalando... ${cFinColor}"
        echo ""
        #curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/analyzeMFT-Instalar.sh | bash
      fi
    vCarpetaConLaMFTOriginal="$1"
    vCarpetaDondeGuardar="$2"
    sudo mkdir -p "$vCarpetaConLaMFTOriginal" 2> /dev/null
    sudo mkdir -p "$vCarpetaDondeGuardar"     2> /dev/null
    sudo chown $USER:$USER "$vCarpetaConLaMFTOriginal" -R
    sudo chown $USER:$USER "$vCarpetaDondeGuardar" -R

    echo ""
    echo "  Parseando datos de navegación del navegador Brave..."
    echo ""
    source ~/repos/python/browser-history/venv/bin/activate
      browser-history 
    deactivate

    echo ""
    echo "  Parseando datos de navegación del navegador Chrome..."
    echo ""
    source ~/repos/python/browser-history/venv/bin/activate
      browser-history 
    deactivate

    echo ""
    echo "  Parseando datos de navegación del navegador Chromium..."
    echo ""
    source ~/repos/python/browser-history/venv/bin/activate
      browser-history 
    deactivate

    echo ""
    echo "  Parseando datos de navegación del navegador Edge..."
    echo ""
    source ~/repos/python/browser-history/venv/bin/activate
      browser-history 
    deactivate

    echo ""
    echo "  Parseando datos de navegación del navegador Epic..."
    echo ""
    source ~/repos/python/browser-history/venv/bin/activate
      browser-history 
    deactivate

    echo ""
    echo "  Parseando datos de navegación del navegador Firefox..."
    echo ""
    source ~/repos/python/browser-history/venv/bin/activate
      browser-history 
    deactivate

    echo ""
    echo "  Parseando datos de navegación del navegador LibreWolf..."
    echo ""
    source ~/repos/python/browser-history/venv/bin/activate
      browser-history 
    deactivate

    echo ""
    echo "  Parseando datos de navegación del navegador Opera..."
    echo ""
    source ~/repos/python/browser-history/venv/bin/activate
      browser-history 
    deactivate

    echo ""
    echo "  Parseando datos de navegación del navegador OperaGX..."
    echo ""
    source ~/repos/python/browser-history/venv/bin/activate
      browser-history 
    deactivate

    echo ""
    echo "  Parseando datos de navegación del navegador Safari..."
    echo ""
    source ~/repos/python/browser-history/venv/bin/activate
      browser-history 
    deactivate

    echo ""
    echo "  Parseando datos de navegación del navegador Vivaldi..."
    echo ""
    source ~/repos/python/browser-history/venv/bin/activate
      browser-history 
    deactivate

    # Reparar permisos
      sudo chown $USER:$USER "$vCarpetaDondeGuardar"/ -R
      sudo chown $USER:$USER /Casos/ -R 2> /dev/null

fi
