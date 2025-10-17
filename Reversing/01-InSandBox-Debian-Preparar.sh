#!/bin/bash

# Ejecución remota únicamente como root:
#  curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Reversing/01-InSandBox-Debian-Preparar.sh | bash

echo 'SanboxParaReversing'            | tee -a /etc/hostname
echo '127.0.0.1 SandboxParaReversing' | tee -a /etc/hosts
echo '127.0.1.1 SandboxParaReversing' | tee -a /etc/hosts

mkdir /mnt/host/tmp
chmod 777 /mnt/host/tmp/

apt-get -y update
apt-get -y install sudo
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
apt-get -y install nano
apt-get -y install mc
curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/Rizin-Instalar.sh | sed 's-sudo--g' | bash

# python
  apt-get -y install python3-pip
  python3 -m pip install yaffshiv --break-system-packages

# locales
  apt-get -y install locales
  sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
  sed -i 's/^# *es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/' /etc/locale.gen
  echo 'export LANG=en_US.UTF-8'     >> /etc/profile
  echo 'export LC_ALL=en_US.UTF-8'   >> /etc/profile
  echo 'export LANGUAGE=en_US.UTF-8' >> /etc/profile
  locale-gen
  update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US.UTF-8

# Entrar en la carpeta montada del host
  cd /mnt/host/

