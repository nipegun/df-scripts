#!/bin/bash

# sudo python3 -m pip install decompyle3 --break-system-packages

# decompyle3 Binario_extracted/malware.pyc > malware.py

# Extraer todos los .pyc de la carpeta actual
  for f in *.pyc; do decompyle3 "$f" > "${f%.pyc}.py"; done

