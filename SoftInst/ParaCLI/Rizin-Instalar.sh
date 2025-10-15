#!/bin/bash

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
  cd /tmp
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


