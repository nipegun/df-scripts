#!/bin/bash

# Ejecución remota:
#  curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Reversing/SandBox-Crear.sh -o /tmp/sb.sh && chmod +x /tmp/sb.sh && /tmp/sb.sh [CarpetaAMontar]

# Crear, iniciar y destruir un sandbox Debian aislado para pruebas con strace
cFechaDeEjec=$(date +a%Ym%md%d@%T)
mkdir -p "$HOME"/SandBoxes/Reversing/ 2> /dev/null
vDirSandbox="$HOME/SandBoxes/Reversing/$cFechaDeEjec"
vMirrorDebian="http://deb.debian.org/debian"
vRelease="stable"
vNombreContenedor="SandboxParaReversing"
vMountHost="$1"

# Crear el sandbox si no existe
  # Comprobar si el paquete debootstrap está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s debootstrap 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${cColorRojo}  El paquete debootstrap no está instalado. Iniciando su instalación...${cFinColor}"
      echo ""
      sudo apt-get -y update
      sudo apt-get -y install debootstrap
      echo ""
    fi
  # Comprobar si existe o no antes de crearlo
    if [ ! -d "$vDirSandbox" ]; then
      echo ""
      echo "  Creando sandbox/contenedor de systemd con Debian "$vRelease" en $vDirSandbox..."
      echo ""
      sudo debootstrap --variant=minbase "$vRelease" "$vDirSandbox" "$vMirrorDebian"
    fi

# Iniciar el sandbox con aislamiento y carpeta compartida
  echo ""
  echo "  Iniciando sandbox/contenedor de systemd..."
  echo ""
  echo "    Dentro del contenedor pega y ejecuta los siguientes comandos:"
  echo ""
  echo "      apt-get -y update"
  echo "      apt-get -y update"
  echo "      apt-get -y install strace"
  echo "      apt-get -y install ltrace"
  echo "      apt-get -y install libgl1"
  echo "      apt-get -y install libxrandr2"
  echo "      apt-get -y install libxi6"
  echo "      apt-get -y install libxcursor1"
  echo "      apt-get -y install libxinerama1"
  echo "      apt-get -y install binutils # Para el comando strings"
  echo "      apt-get -y install gdb"
  echo "      apt-get -y install xxd"
  echo "      apt-get -y install bzip2"
  echo "      apt-get -y install file"
  echo "      apt-get -y install upx"
  echo "      apt-get -y install binwalk"
  echo "      apt-get -y install bsdextrautils"
  echo "      apt-get -y install golang"
  echo "      apt-get -y install nano"
  echo "      apt-get -y install mc"
  echo "      curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/Rizin-Instalar.sh | sed 's-sudo--g' | bash"
  echo "      apt-get -y install locales"
  echo "      sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen"
  echo "      sed -i 's/^# *es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/' /etc/locale.gen"
  echo "      echo 'export LANG=en_US.UTF-8'     >> /etc/profile"
  echo "      echo 'export LC_ALL=en_US.UTF-8'   >> /etc/profile"
  echo "      echo 'export LANGUAGE=en_US.UTF-8' >> /etc/profile"
  echo "      locale-gen"
  echo "      update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US.UTF-8"
  echo ""
  echo "      cd /mnt/host/"
  echo ""
  sudo systemd-nspawn -D "$vDirSandbox" --bind="$vMountHost:/mnt/host" --machine="$vNombreContenedor"

# Notificar salida del contenedor
  echo ""
  echo "  Saliendo del contenedor..."
  echo ""
  echo "    Para vovler a entrar:"
  echo ""
  echo "      sudo systemd-nspawn -D "$vDirSandbox" --bind="$vMountHost:/mnt/host" --machine="$vNombreContenedor""
  echo ""
  echo "    Para borrarlo:"
  echo ""
  echo "      sudo rm -rf "$vDirSandbox""
  echo ""

# Al salir del contenedor, destruirlo
  #echo ""
  #echo "  Destruyendo el sandbox/contenedor de la carpeta "$vDirSandbox"..."
  #echo ""
  #sudo rm -rf "$vDirSandbox"
