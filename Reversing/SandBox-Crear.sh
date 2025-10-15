#!/bin/bash

# Ejecución remota:
#  curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Reversing/SandBox-Crear.sh | bash

# Crear, iniciar y destruir un sandbox Debian aislado para pruebas con strace

vDirSandbox="/var/sandbox/debian"
vMirrorDebian="http://deb.debian.org/debian"
vRelease="stable"
vMountHost="$1"
vNombreContenedor="sandbox-debian"

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
      echo "Creando entorno base Debian en $vDirSandbox..."
      debootstrap --variant=minbase "$vRelease" "$vDirSandbox" "$vMirrorDebian"
    fi

# Iniciar el sandbox con aislamiento y carpeta compartida
#   --private-network: sin acceso a la red.
#   --read-only: el filesystem es de solo lectura.
#   --tmpfs=/tmp: crea un /tmp temporal y volátil.
  echo "Iniciando sandbox con aislamiento..."
  systemd-nspawn \
    -D "$vDirSandbox" \
    --bind="$vMountHost:/mnt/host" \
    --machine="$vNombreContenedor" \
    --private-network \
    --read-only \
    --tmpfs=/tmp \
    #/bin/bash
    /bin/bash -c "
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
    bash
  "

# Al salir del contenedor, ofrecer opción para destruirlo
  read -p "¿Deseas destruir el sandbox completamente? (s/n): " vRespuesta
  if [ "$vRespuesta" = "s" ]; then
    echo "Destruyendo sandbox..."
    rm -rf "$vDirSandbox"
    echo "Sandbox eliminado."
  fi
