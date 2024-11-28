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
    echo "  Intentando exportar la MFT a formato CSV..."
    echo ""
    source ~/repos/python/analyzeMFT/venv/bin/activate
      analyzemft -f "$vCarpetaConLaMFTOriginal"/\$MFT -o "$vCarpetaDondeGuardar"/MFT.csv --csv      # Exportar como CSV (default)
    deactivate
    echo ""
    echo "    Archivo .csv exportado. Puedes abrirlo directamente con libreoffice ejecutando en la terminal:"
    echo ""
    echo "      libreoffice --calc --infilter='CSV:44' "$vCarpetaDondeGuardar"/MFT.csv"
    echo ""

    echo ""
    echo "  Intentando exportar la MFT a formato JSON..."
    echo ""
    sudo analyzeMFT -f "$vCarpetaConLaMFTOriginal"/\$MFT -o "$vCarpetaDondeGuardar"/MFT.json --json     # Exportar como JSON
    
    echo ""
    echo "  Intentando exportar la MFT a formato XML..."
    echo ""
    sudo analyzeMFT -f "$vCarpetaConLaMFTOriginal"/\$MFT -o "$vCarpetaDondeGuardar"/MFT.xml --xml      # Exportar como XML
    
    echo ""
    echo "  Intentando exportar la MFT a formato Excel..."
    echo ""
    sudo analyzeMFT -f "$vCarpetaConLaMFTOriginal"/\$MFT -o "$vCarpetaDondeGuardar"/MFT.xls --excel    # Exportar como Excel
    
    echo ""
    echo "  Intentando exportar la MFT a formato Body para mactime..."
    echo ""
    sudo analyzeMFT -f "$vCarpetaConLaMFTOriginal"/\$MFT -o "$vCarpetaDondeGuardar"/MFT-BodyMactime --body     # Exportar como body file (for mactime)

    echo ""
    echo "  Intentando exportar la MFT a formato TSK timeline..."
    echo ""
    sudo analyzeMFT -f "$vCarpetaConLaMFTOriginal"/\$MFT -o "$vCarpetaDondeGuardar"/MFT-TSKTimeLine --timeline # Exportar como TSK timeline

    echo ""
    echo "  Exportando la MFT a formato log2timeline CSV..."
    echo ""
    sudo analyzeMFT -f "$vCarpetaConLaMFTOriginal"/\$MFT -o "$vCarpetaDondeGuardar"/MFT-log2timeline.l2t --l2t      # Exportar como log2timeline CSV

    echo ""
    echo "  Intentando exportar la MFT a formato SQLite..."
    echo ""
    sudo analyzeMFT -f "$vCarpetaConLaMFTOriginal"/\$MFT -o "$vCarpetaDondeGuardar"/MFT-SQLite --sqlite   # Exportar como SQLite database

    echo ""
    echo "  Intentando exportar la MFT a formato TSK Body..."
    echo ""
    sudo analyzeMFT -f "$vCarpetaConLaMFTOriginal"/\$MFT -o "$vCarpetaDondeGuardar"/MFT-TSKbody --tsk      # Exportar como TSK bodyfile format

    # Reparar permisos
      sudo chown 1000:1000 "$vCarpetaDondeGuardar"/Artefactos -R

fi
