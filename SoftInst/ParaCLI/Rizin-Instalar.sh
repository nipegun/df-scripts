#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar Rizin en Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/Rizin-Instalar.sh | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/Rizin-Instalar.sh | sed 's-sudo--g' | bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/Rizin-Instalar.sh | nano -
# ----------

# Actualizar lista de paquetes disponibles en los repositorios
  sudo apt-get -y update

# Instalar paquetes necesarios para descargar y compilar la herramienta
  sudo apt-get -y install git
  sudo apt-get -y install meson
  sudo apt-get -y install ninja-build
  sudo apt-get -y install cmake
  sudo apt-get -y install build-essential
  sudo apt-get -y install pkg-config
  sudo apt-get -y install libssl-dev
  sudo apt-get -y install libzip-dev
  sudo apt-get -y install liblz4-dev
  sudo apt-get -y install libxxhash-dev
  sudo apt-get -y install libmagic-dev
  sudo apt-get -y install libpcre2-dev
  sudo apt-get -y install libzstd-dev
  #sudo apt-get -y install tree-sitter
  sudo apt-get -y install libcapstone-dev

# Descargar el repo
  cd /tmp/
  sudo rm -rf /tmp/rizin/ 2> /dev/null
  git clone https://github.com/rizinorg/rizin.git

# Configurar la compilación con meso
  cd /tmp/rizin/
  meson setup build
  #meson setup --reconfigure build

# Compilar
  meson compile -C build

# Instalar
  sudo meson install -C build

# Comprobar versión instalada
  rz-bin -v

# Desinstalar
  #cd /tmp/rizin/
  #sudo meson install -C build --uninstall

