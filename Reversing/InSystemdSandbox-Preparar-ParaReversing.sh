#!/bin/bash

# Ejecución remota únicamente como root:
#  curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Reversing/InSystemdSandbox-Preparar-ParaReversing.sh | bash

# Actualizar la lista de paquetes disponibles en los repositorios
  apt-get -y update

# Instalar programas
  apt-get -y install strace
  apt-get -y install ltrace
  apt-get -y install libgl1
  apt-get -y install libxrandr2
  apt-get -y install libxi6
  apt-get -y install libxcursor1
  apt-get -y install libxinerama1
  apt-get -y install binutils # Para el comando strings
  apt-get -y install gdb
  apt-get -y install xxd
  apt-get -y install bzip2
  apt-get -y install file
  apt-get -y install upx
  apt-get -y install binwalk
  apt-get -y install rsync
  apt-get -y install bsdextrautils
  apt-get -y install golang
  apt-get -y install unyaffs

# python
  apt-get -y install python3-pip

# risin
  curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/Rizin-Instalar.sh | sed 's-sudo--g' | bash




