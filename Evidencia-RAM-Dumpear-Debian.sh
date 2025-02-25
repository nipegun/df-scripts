#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para obtener evidencia forense de un dispositivo
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Evidencia-RAM-Dumpear-Debian.sh | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Evidencia-RAM-Dumpear-Debian.sh | sudo 's-sudo--g' | bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Evidencia-RAM-Dumpear-Debian.sh | nano -
# ----------

# Definir constantes de color
  cColorAzul="\033[0;34m"
  cColorAzulClaro="\033[1;34m"
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

# Actualizar lista de paquetes disponibles en los repositorios
  sudo apt -y update

# Instalar paquetes necesarios
  sudo apt -y install git
  sudo apt -y install build-essential
  sudo apt -y install linux-headers-$(uname -r)

# Clonar el repo de LiME
  cd ~/
  git clone https://github.com/504ensicsLabs/LiME.git

# Compilar LiME
  cd LiME/src
  sudo make

# Volcar la RAM
  sudo insmod lime-*.ko "path=/tmp/RAMDump.lime format=raw"

# Crear el archivo json con los símbolos del kernel
  sudo apt -y install linux-image-$(uname -r)-dbg
  sudo apt -y install linux-headers-$(uname -r)
  sudo apt -y install dwarfdump
  sudo apt -y install zip
  curl -L https://github.com/volatilityfoundation/dwarf2json/releases/download/v0.9.0/dwarf2json-linux-amd64 -o /tmp/dwarf2json
  /tmp/dwarf2json linux --elf /usr/lib/debug/boot/vmlinux-$(uname -r) --system-map /usr/lib/debug/boot/vmlinux-$(uname -r) > /tmp/output.json

