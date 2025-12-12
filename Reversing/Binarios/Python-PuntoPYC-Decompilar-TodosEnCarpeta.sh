#!/bin/bash

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
    for f in *.pyc; do decompyle3 "$f" > "${f%.pyc}.py"; done
