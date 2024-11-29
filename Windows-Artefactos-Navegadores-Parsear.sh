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
    echo "  Parseando datos de navegación de todos los navegadores juntos..."
    echo ""
    source ~/repos/python/browser-history/venv/bin/activate
      browser-history 
    # Historial
      browser-history --type history --browser all --format csv     --output bookmarks_all.csv
      browser-history --type history --browser all --format json    --output bookmarks_all.json
      browser-history --type history --browser all --format jsonl   --output bookmarks_all.jsonl
    # Marcadores
      browser-history --type bookmarks --browser all --format csv   --output bookmarks_all.csv
      browser-history --type bookmarks --browser all --format json  --output bookmarks_all.json
      browser-history --type bookmarks --browser all --format jsonl --output bookmarks_all.jsonl
    deactivate

    echo ""
    echo "  Parseando datos de navegación del navegador Brave..."
    echo ""
    source ~/repos/python/browser-history/venv/bin/activate
    # Mostrar los perfiles encontrados
      browser-history --show-profiles Brave
      #browser-history --type bookmarks --browser Firefox --format csv --profile default --output firefox_bookmarks.csv
    # Historial
      browser-history --type history --browser Brave --format csv     --output bookmarks_Brave.csv
      browser-history --type history --browser Brave --format json    --output bookmarks_Brave.json
      browser-history --type history --browser Brave --format jsonl   --output bookmarks_Brave.jsonl
    # Marcadores
      browser-history --type bookmarks --browser Brave --format csv   --output bookmarks_Brave.csv
      browser-history --type bookmarks --browser Brave --format json  --output bookmarks_Brave.json
      browser-history --type bookmarks --browser Brave --format jsonl --output bookmarks_Brave.jsonl
    deactivate

    echo ""
    echo "  Parseando datos de navegación del navegador Chrome..."
    echo ""
    source ~/repos/python/browser-history/venv/bin/activate
    # Mostrar los perfiles encontrados
      browser-history --show-profiles Chrome
    # Historial
      browser-history --type history --browser Chrome --format csv     --output bookmarks_Chrome.csv
      browser-history --type history --browser Chrome --format json    --output bookmarks_Chrome.json
      browser-history --type history --browser Chrome --format jsonl   --output bookmarks_Chrome.jsonl
    # Marcadores
      browser-history --type bookmarks --browser Chrome --format csv   --output bookmarks_Chrome.csv
      browser-history --type bookmarks --browser Chrome --format json  --output bookmarks_Chrome.json
      browser-history --type bookmarks --browser Chrome --format jsonl --output bookmarks_Chrome.jsonl
    deactivate

    echo ""
    echo "  Parseando datos de navegación del navegador Chromium..."
    echo ""
    source ~/repos/python/browser-history/venv/bin/activate
    # Mostrar los perfiles encontrados
      browser-history --show-profiles Chromium
    # Historial
      browser-history --type history --browser Chromium --format csv     --output bookmarks_Chromium.csv
      browser-history --type history --browser Chromium --format json    --output bookmarks_Chromium.json
      browser-history --type history --browser Chromium --format jsonl   --output bookmarks_Chromium.jsonl
    # Marcadores
      browser-history --type bookmarks --browser Chromium --format csv   --output bookmarks_Chromium.csv
      browser-history --type bookmarks --browser Chromium --format json  --output bookmarks_Chromium.json
      browser-history --type bookmarks --browser Chromium --format jsonl --output bookmarks_Chromium.jsonl
    deactivate

    echo ""
    echo "  Parseando datos de navegación del navegador Edge..."
    echo ""
    source ~/repos/python/browser-history/venv/bin/activate
    # Mostrar los perfiles encontrados
      browser-history --show-profiles Edge
    # Historial
      browser-history --type history --browser Edge --format csv     --output bookmarks_Edge.csv
      browser-history --type history --browser Edge --format json    --output bookmarks_Edge.json
      browser-history --type history --browser Edge --format jsonl   --output bookmarks_Edge.jsonl
    # Marcadores
      browser-history --type bookmarks --browser Edge --format csv   --output bookmarks_Edge.csv
      browser-history --type bookmarks --browser Edge --format json  --output bookmarks_Edge.json
      browser-history --type bookmarks --browser Edge --format jsonl --output bookmarks_Edge.jsonl
    deactivate

    echo ""
    echo "  Parseando datos de navegación del navegador Epic..."
    echo ""
    source ~/repos/python/browser-history/venv/bin/activate
    # Mostrar los perfiles encontrados
      browser-history --show-profiles Epic
    # Historial
      browser-history --type history --browser Epic --format csv     --output bookmarks_Epic.csv
      browser-history --type history --browser Epic --format json    --output bookmarks_Epic.json
      browser-history --type history --browser Epic --format jsonl   --output bookmarks_Epic.jsonl
    # Marcadores
      browser-history --type bookmarks --browser Epic --format csv   --output bookmarks_Epic.csv
      browser-history --type bookmarks --browser Epic --format json  --output bookmarks_Epic.json
      browser-history --type bookmarks --browser Epic --format jsonl --output bookmarks_Epic.jsonl
    deactivate

    echo ""
    echo "  Parseando datos de navegación del navegador Firefox..."
    echo ""
    source ~/repos/python/browser-history/venv/bin/activate
    # Mostrar los perfiles encontrados
      browser-history --show-profiles Firefox
    # Historial
      browser-history --type history --browser Firefox --format csv     --output bookmarks_Firefox.csv
      browser-history --type history --browser Firefox --format json    --output bookmarks_Firefox.json
      browser-history --type history --browser Firefox --format jsonl   --output bookmarks_Firefox.jsonl
    # Marcadores
      browser-history --type bookmarks --browser Firefox --format csv   --output bookmarks_Firefox.csv
      browser-history --type bookmarks --browser Firefox --format json  --output bookmarks_Firefox.json
      browser-history --type bookmarks --browser Firefox --format jsonl --output bookmarks_Firefox.jsonl
    deactivate

    echo ""
    echo "  Parseando datos de navegación del navegador LibreWolf..."
    echo ""
    source ~/repos/python/browser-history/venv/bin/activate
    # Mostrar los perfiles encontrados
      browser-history --show-profiles LibreWolf
    # Historial
      browser-history --type history --browser LibreWolf --format csv     --output bookmarks_LibreWolf.csv
      browser-history --type history --browser LibreWolf --format json    --output bookmarks_LibreWolf.json
      browser-history --type history --browser LibreWolf --format jsonl   --output bookmarks_LibreWolf.jsonl
    # Marcadores
      browser-history --type bookmarks --browser LibreWolf --format csv   --output bookmarks_LibreWolf.csv
      browser-history --type bookmarks --browser LibreWolf --format json  --output bookmarks_LibreWolf.json
      browser-history --type bookmarks --browser LibreWolf --format jsonl --output bookmarks_LibreWolf.jsonl
    deactivate

    echo ""
    echo "  Parseando datos de navegación del navegador Opera..."
    echo ""
    source ~/repos/python/browser-history/venv/bin/activate
    # Mostrar los perfiles encontrados
      browser-history --show-profiles Opera
    # Historial
      browser-history --type history --browser Opera --format csv     --output bookmarks_Opera.csv
      browser-history --type history --browser Opera --format json    --output bookmarks_Opera.json
      browser-history --type history --browser Opera --format jsonl   --output bookmarks_Opera.jsonl
    # Marcadores
      browser-history --type bookmarks --browser Opera --format csv   --output bookmarks_Opera.csv
      browser-history --type bookmarks --browser Opera --format json  --output bookmarks_Opera.json
      browser-history --type bookmarks --browser Opera --format jsonl --output bookmarks_Opera.jsonl
    deactivate

    echo ""
    echo "  Parseando datos de navegación del navegador OperaGX..."
    echo ""
    source ~/repos/python/browser-history/venv/bin/activate
    # Mostrar los perfiles encontrados
      browser-history --show-profiles OperaGX
    # Historial
      browser-history --type history --browser OperaGX --format csv     --output bookmarks_OperaGX.csv
      browser-history --type history --browser OperaGX --format json    --output bookmarks_OperaGX.json
      browser-history --type history --browser OperaGX --format jsonl   --output bookmarks_OperaGX.jsonl
    # Marcadores
      browser-history --type bookmarks --browser OperaGX --format csv   --output bookmarks_OperaGX.csv
      browser-history --type bookmarks --browser OperaGX --format json  --output bookmarks_OperaGX.json
      browser-history --type bookmarks --browser OperaGX --format jsonl --output bookmarks_OperaGX.jsonl
    deactivate

    echo ""
    echo "  Parseando datos de navegación del navegador Safari..."
    echo ""
    source ~/repos/python/browser-history/venv/bin/activate
    # Mostrar los perfiles encontrados
      browser-history --show-profiles Safari
    # Historial
      browser-history --type history --browser Safari --format csv     --output bookmarks_Safari.csv
      browser-history --type history --browser Safari --format json    --output bookmarks_Safari.json
      browser-history --type history --browser Safari --format jsonl   --output bookmarks_Safari.jsonl
    # Marcadores
      browser-history --type bookmarks --browser Safari --format csv   --output bookmarks_Safari.csv
      browser-history --type bookmarks --browser Safari --format json  --output bookmarks_Safari.json
      browser-history --type bookmarks --browser Safari --format jsonl --output bookmarks_Safari.jsonl
    deactivate

    echo ""
    echo "  Parseando datos de navegación del navegador Vivaldi..."
    echo ""
    source ~/repos/python/browser-history/venv/bin/activate
    # Mostrar los perfiles encontrados
      browser-history --show-profiles Vivaldi
    # Historial
      browser-history --type history --browser Vivaldi --format csv     --output bookmarks_Vivaldi.csv
      browser-history --type history --browser Vivaldi --format json    --output bookmarks_Vivaldi.json
      browser-history --type history --browser Vivaldi --format jsonl   --output bookmarks_Vivaldi.jsonl
    # Marcadores
      browser-history --type bookmarks --browser Vivaldi --format csv   --output bookmarks_Vivaldi.csv
      browser-history --type bookmarks --browser Vivaldi --format json  --output bookmarks_Vivaldi.json
      browser-history --type bookmarks --browser Vivaldi --format jsonl --output bookmarks_Vivaldi.jsonl
    deactivate

    # Reparar permisos
      sudo chown $USER:$USER "$vCarpetaDondeGuardar"/ -R
      sudo chown $USER:$USER /Casos/ -R 2> /dev/null

fi


