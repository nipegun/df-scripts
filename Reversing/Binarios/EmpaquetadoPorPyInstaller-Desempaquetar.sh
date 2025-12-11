#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para desempaquetar un python empaquetado con PyInstaller usando Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Reversing/Binarios/EmpaquetadoPorPyInstaller-Desempaquetar.sh | bash [RutaAlBinario]
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Reversing/Binarios/EmpaquetadoPorPyInstaller-Desempaquetar.sh | sed 's-sudo--g' | bash -s [RutaAlBinario]
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Reversing/Binarios/EmpaquetadoPorPyInstaller-Desempaquetar.sh | nano -
# ----------

cArchivoBinario="$1"

# Bajar el script de extracción
  cp "$cArchivoBinario" /tmp/Binario
  wget https://raw.githubusercontent.com/extremecoders-re/pyinstxtractor/master/pyinstxtractor.py

# Extraer
  python3 /tmp/pyinstxtractor.py /tmp/Binario

# Notificar fin de ejecución
  echo ""
  echo "  Binario de Python desempaquetado en la carpeta Binario_extracted"
  echo ""

