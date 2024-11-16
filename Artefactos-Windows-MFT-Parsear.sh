#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para parsear el archivo $MFT original a múltimples formatos
#
# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Artefactos-Windows-MFT-Parsear.sh | sudo bash -s [CarpetaConLaMFTOriginal] [CarpetaDondeGuardarLosParseos]
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Artefactos-Windows-MFT-Parsear.sh | nano -
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
    echo "    $0 '/Casos/2/MFT/\$MFT' '/Casos/2/MFT'"
    echo ""
    exit
  else
    # Comprobar que exista analyzemft
      if [ ! -f /usr/bin/analyzeMFT ]; then
        echo ""
        echo -e "${cColorRojo}    El binario de analyzemft no está instalado. Instalando... ${cFinColor}"
        echo ""
        curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/analyzeMFT-Instalar.sh | bash
      fi
    vCarpetaConLaMFTOriginal="$1"
    vCarpetaDondeGuardar="$2"
    mkdir -p "$vCarpetaDondeGuardar"
    echo ""
    echo "  Intentando exportar la MFT a formato CSV..."
    echo ""
    analyzeMFT -f "$vCarpetaConLaMFTOriginal"/\$MFT -o "$vCarpetaDondeGuardar"/MFT.csv --csv      # Exportar como CSV (default)

    echo ""
    echo "  Intentando exportar la MFT a formato JSON..."
    echo ""
    analyzeMFT -f "$vCarpetaConLaMFTOriginal"/\$MFT -o "$vCarpetaDondeGuardar"/MFT.json --json     # Exportar como JSON
    
    echo ""
    echo "  Intentando exportar la MFT a formato XML..."
    echo ""
    analyzeMFT -f "$vCarpetaConLaMFTOriginal"/\$MFT -o "$vCarpetaDondeGuardar"/MFT.xml --xml      # Exportar como XML
    
    echo ""
    echo "  Intentando exportar la MFT a formato Excel..."
    echo ""
    analyzeMFT -f "$vCarpetaConLaMFTOriginal"/\$MFT -o "$vCarpetaDondeGuardar"/MFT.xls --excel    # Exportar como Excel
    
    echo ""
    echo "  Intentando exportar la MFT a formato Body para mactime..."
    echo ""
    analyzeMFT -f "$vCarpetaConLaMFTOriginal"/\$MFT -o "$vCarpetaDondeGuardar"/MFT-BodyMactime --body     # Exportar como body file (for mactime)

    echo ""
    echo "  Intentando exportar la MFT a formato TSK timeline..."
    echo ""
    analyzeMFT -f "$vCarpetaConLaMFTOriginal"/\$MFT -o "$vCarpetaDondeGuardar"/MFT-TSKTimeLine --timeline # Exportar como TSK timeline

    echo ""
    echo "  Exportando la MFT a formato log2timeline CSV..."
    echo ""
    analyzeMFT -f "$vCarpetaConLaMFTOriginal"/\$MFT -o "$vCarpetaDondeGuardar"/MFT-log2timeline.l2t --l2t      # Exportar como log2timeline CSV

    echo ""
    echo "  Intentando exportar la MFT a formato SQLite..."
    echo ""
    analyzeMFT -f "$vCarpetaConLaMFTOriginal"/\$MFT -o "$vCarpetaDondeGuardar"/MFT-SQLite --sqlite   # Exportar como SQLite database

    echo ""
    echo "  Intentando exportar la MFT a formato TSK Body..."
    echo ""
    analyzeMFT -f "$vCarpetaConLaMFTOriginal"/\$MFT -o "$vCarpetaDondeGuardar"/MFT-TSKbody --tsk      # Exportar como TSK bodyfile format

    # Reparar permisos
      chown 1000:1000 "$vCarpetaDondeGuardar"/Artefactos -R

fi
