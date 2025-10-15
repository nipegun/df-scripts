#!/bin/bash

vCarpetaAMontarEnElSandBox="$1"

# Comprobar si el paquete debootstrap está instalado. Si no lo está, instalarlo.
  if [[ $(dpkg-query -s debootstrap 2>/dev/null | grep installed) == "" ]]; then
    echo ""
    echo -e "${cColorRojo}  El paquete debootstrap no está instalado. Iniciando su instalación...${cFinColor}"
    echo ""
    sudo apt-get -y update
    sudo apt-get -y install debootstrap
    echo ""
  fi
sudo debootstrap --variant=minbase stable /var/sandbox/debian http://deb.debian.org/debian

# Entrar en el sandbox con aislamiento
  sudo systemd-nspawn -D /var/sandbox/debian --bind="$vCarpetaAMontarEnElSandBox":/mnt/host

# Más restrictivo
#   --private-network: sin acceso a la red.
#   --read-only: el filesystem es de solo lectura.
#   --tmpfs=/tmp: crea un /tmp temporal y volátil.
  #sudo systemd-nspawn -D /var/sandbox/debian --private-network --read-only --tmpfs=/tmp

# Instalar paquetes dentro del sandbox
  apt-get -y update
  apt-get -y install strace
