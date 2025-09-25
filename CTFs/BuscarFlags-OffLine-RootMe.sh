#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para buscar flags en CTFs de RootMe en la terminal de un Linux vivo
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/DFIRLinux/Artefactos-Vivos-Cadena-Buscar-EnSistema.sh | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/DFIRLinux/Artefactos-Vivos-Cadena-Buscar-EnSistema.sh | sed 's-sudo--g' | bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/DFIRLinux/Artefactos-Vivos-Cadena-Buscar-EnSistema.sh | nano -
# ----------

# Definir constantes de color
  cColorAzul='\033[0;34m'
  cColorAzulClaro='\033[1;34m'
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

# expresion regular RM\{[^\}]+\}

# Buscar en base64
  find / -type f -exec sh -c 'strings "$1" | grep -q "RM{" && echo "Coincidencia de RM{ en: $1"' _ {} \; 2>/dev/null
  echo ""
  find / -type f -exec sh -c 'strings "$1" | grep -q "Uk1" && echo "Coincidencia de Uk1 en: $1"' _ {} \; 2>/dev/null
  echo ""
  find / -type f -exec sh -c 'strings "$1" | grep -q "JNe" && echo "Coincidencia de JNe en: $1"' _ {} \; 2>/dev/null
  echo ""
  find / -type f -exec sh -c 'strings "$1" | grep -q "STX" && echo "Coincidencia de STX en: $1"' _ {} \; 2>/dev/null
  echo ""
