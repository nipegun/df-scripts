#!/bin/bash

# Ejecución remota:
#  curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Reversing/00-SandBox-Crear.sh -o /tmp/sb.sh && chmod +x /tmp/sb.sh && /tmp/sb.sh [CarpetaAMontar]

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
  echo "      mkdir /mnt/host/tmp"
  echo "      chmod 777 /mnt/host/tmp/" 
  echo "      apt-get -y update && apt-get -y install curl"
  echo "      curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Reversing/01-SandBox-Paquetes-InstalarDentro.sh | bash"
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
