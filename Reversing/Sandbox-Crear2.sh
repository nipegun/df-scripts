#!/bin/bash

# Crear, iniciar (aislado) y opcionalmente destruir un sandbox Debian para pruebas con strace
# Uso:
#   SandBox-Crear.sh [NombreDelSandbox] [CarpetaHostAMontar]
# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Reversing/SandBox-Crear.sh | bash -s [NombreDelSandbox] [CarpetaHostAMontar]

set -euo pipefail

# Colores (fallback si no están definidos en el entorno)
: "${cColorRojo:=\e[31m}"
: "${cFinColor:=\e[0m}"

vDirSandbox="/var/sandbox/debian"
vMirrorDebian="http://deb.debian.org/debian"
vRelease="stable"
vNombreContenedor="${1:-sandbox-$(date +%s)}"
vMountHost="${2:-$(pwd)}"
vBootstrapFlag="$vDirSandbox/root/.sandbox_bootstrapped"

# Re-ejecutar como root si hace falta
if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  exec sudo -E bash "$0" "$@"
fi

# Comprobar dependencias mínimas
if ! command -v debootstrap >/dev/null 2>&1; then
  echo -e "${cColorRojo}Instalando debootstrap...${cFinColor}"
  apt-get -y update
  apt-get -y install debootstrap
fi
if ! command -v systemd-nspawn >/dev/null 2>&1; then
  echo -e "${cColorRojo}Instalando systemd-container (systemd-nspawn)...${cFinColor}"
  apt-get -y update
  apt-get -y install systemd-container
fi

# Crear base si no existe
if [ ! -d "$vDirSandbox" ]; then
  echo "Creando entorno base Debian en $vDirSandbox..."
  mkdir -p "$vDirSandbox"
  debootstrap --variant=minbase "$vRelease" "$vDirSandbox" "$vMirrorDebian"
fi

# Bootstrap de herramientas (solo una vez)
if [ ! -f "$vBootstrapFlag" ]; then
  echo "Bootstrap inicial dentro del sandbox (herramientas y locales)..."
  systemd-nspawn \
    -D "$vDirSandbox" \
    --machine "${vNombreContenedor}-bootstrap" \
    /bin/bash
fi

# Asegurar carpeta a montar
if [ ! -d "$vMountHost" ]; then
  echo -e "${cColorRojo}La carpeta a montar no existe: $vMountHost${cFinColor}"
  exit 1
fi

# Sesión aislada (sin red) y efímera (no persiste cambios)
echo "Iniciando sandbox (aislado, efímero, con /mnt/host)..."
systemd-nspawn \
  -D "$vDirSandbox" \
  --machine "$vNombreContenedor" \
  --bind "$vMountHost:/mnt/host" \
  --private-network \
  --ephemeral \
  --setenv=LANG=en_US.UTF-8 \
  --setenv=LC_ALL=en_US.UTF-8 \
  --setenv=DEBIAN_FRONTEND=noninteractive \
  /bin/bash

# Al salir del contenedor, ofrecer opción para destruir la base
read -r -p "¿Deseas destruir el sandbox base en $vDirSandbox? (s/n): " vRespuesta
if [ "${vRespuesta,,}" = "s" ]; then
  echo "Destruyendo sandbox..."
  rm -rf "$vDirSandbox"
  echo "Sandbox eliminado."
fi
