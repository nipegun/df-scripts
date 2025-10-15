#!/bin/bash

# Ejecución remota:
#  curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Reversing/SandBox-Crear.sh | bash -s [NombreDelSandbox] [CarpetaAMontar]

# Crear, iniciar y destruir un sandbox Debian aislado para pruebas con strace
cFechaDeEjec=$(date +a%Ym%md%d@%T)
vDirSandbox="/var/sandbox/debian/$cFechaDeEjec"
vMirrorDebian="http://deb.debian.org/debian"
vRelease="stable"
vNombreContenedor="$1"
vMountHost="$2"

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
  echo "Iniciando sandbox con aislamiento..."
  systemd-nspawn \
    -D "$vDirSandbox" \
    --bind="$vMountHost:/mnt/host" \
    --machine="$vNombreContenedor" \
    /bin/bash 

# Al salir del contenedor, ofrecer opción para destruirlo
  read -p "¿Deseas destruir el sandbox completamente? (s/n): " vRespuesta
  if [ "$vRespuesta" = "s" ]; then
    echo "Destruyendo sandbox..."
    rm -rf "$vDirSandbox"
    echo "Sandbox eliminado."
  fi
