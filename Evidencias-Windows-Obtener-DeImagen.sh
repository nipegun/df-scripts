#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para analizar y exportar el archivo $MFT original a múltimples formatos
#
# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Evidencias-Windows-Obtener-DeImagen.sh | sudo bash -s /Ruta/Al/Archivo/De/Imagen/De/Evidencia
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Evidencias-Windows-Obtener-DeImagen.sh | nano -
# ----------

# Montar particiones de imagen
  curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Imagen-Particiones-Montar-SoloLectura.sh | sed 's|$(date +a%Ym%md%d@%T)|"Examen"|g' | sudo bash -s $1

# Registro

  # Instalar RegRipper (Sólo se ejecuta en Debian)
    curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/RegRipper-Instalar.sh | sudo bash

  # Ejecutar RegRipper
    curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Registro-Extraer-Completo-WindowsVistaYPosterior.sh | sudo bash -s /Casos/Examen/Particiones/2 /Casos/Examen

# MFT

  # Extraer MFT
    curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/MFT-Extraer-Original.sh | sudo bash -s /Casos/Examen/Particiones/2 /Casos/Examen

  # Instalar analyzeMFT
    curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/analyzeMFT-Instalar.sh | sudo bash

  # Ejecutar analyzemft sobre la evidencia
    curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/MFT-AnalizarYExportar.sh | sudo bash -s /Casos/Examen/MFT/MFTOriginal /Casos/Examen/MFT

# Eventos

  #
