#!/bin/bash

# Ejecuciópn remota únicamente como root:
#  curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Reversing/01-SandBox-Paquetes-InstalarDentro.sh | bash

apt-get -y update
apt-get -y install strace
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
apt-get -y install locales
sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/^# *es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
