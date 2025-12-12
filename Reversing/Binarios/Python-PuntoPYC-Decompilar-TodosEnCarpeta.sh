#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para desempaquetar Decompilar todos los archivos .pyc de la carpeta actual Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dfir-scripts/refs/heads/main/Reversing/Binarios/Python-PuntoPYC-Decompilar-TodosEnCarpeta.sh | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/dfir-scripts/refs/heads/main/Reversing/Binarios/Python-PuntoPYC-Decompilar-TodosEnCarpeta.sh | sed 's-sudo--g' | bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/dfir-scripts/refs/heads/main/Reversing/Binarios/Python-PuntoPYC-Decompilar-TodosEnCarpeta.sh | nano -
# ----------

# Decompilar todos los archivos .pyc de la carpeta actual
  # Con decompyle3
    # sudo python3 -m pip install decompyle3 --break-system-packages
    # decompyle3 Binario_extracted/malware.pyc > malware.py
    # for f in *.pyc; do decompyle3 "$f" > "${f%.pyc}.py"; done
  # Con pycdc
    # Comprobar si pydc está instalado. Si no lo está, instalarlo.
      vPycdc="$(which pycdc 2>/dev/null)"
      if [ -z "$vPycdc" ]; then
        echo ""
        echo "  pycdc no está instalado. Instalando..."
        echo ""
        curl -sL https://raw.githubusercontent.com/nipegun/dfir-scripts/refs/heads/main/SoftInst/ParaCLI/pycdc-Instalar.sh | bash
      fi
    for f in *.pyc; do pycdc "$f" > "${f%.pyc}.py"; done
