#!/bin/bash

# Instalar dependencias
  sudo apt-get -y update
  sudo apt-get -y install git
  sudo apt-get -y install g++
  sudo apt-get -y install cmake

# Clonar el repo
  mkdir ~/Git
  cd ~/Git
  git clone https://github.com/zrax/pycdc.git

# Configurar
  cd pycdc
  cmake .

# Compilar
  make

# Instalar
  make install
