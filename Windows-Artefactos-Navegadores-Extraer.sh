#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para extraer todas las carpetas con información de navegadores de una partición NTFS
#
# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Windows-Artefactos-Navegadores-Extraer.sh | bash -s [PuntoDeMontajeDeLaPartDeWindows] [CarpetaDelCaso]  (Ambos sin barra final)
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Windows-Artefactos-Navegadores-Extraer.sh | nano -
# ----------

# Definir constantes de color
  cColorAzul="\033[0;34m"
  cColorAzulClaro="\033[1;34m"
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

# Definir la cantidad de argumentos esperados
  cCantParamEsperados=2

if [ $# -ne $cCantParamEsperados ]
  then
    echo ""
    echo -e "${cColorRojo}  Mal uso del script. El uso correcto sería: ${cFinColor}"
    echo "    $0 [PuntoDeMontajeDeLaPartDeWindows] [CarpetaDelCaso]  (Ambos sin barra final)"
    echo ""
    echo "  Ejemplo:"
    echo "    $0 '/Casos/a2024m11d29/Imagen/Particiones/2' '/Casos/a2024m11d29/'"
    echo ""
    exit
  else
    echo ""
    echo ""
    echo ""
    vPuntoDeMontajePartWindows="$1" # Debe ser una carpeta sin barra final
    vCarpetaDelCaso="$2"            # Debe ser una carpeta sin barra final
    # Brave
      sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/Brave/
      sudo cp -rf "$vPuntoDeMontajePartWindows"/Users/nipegun/AppData/Roaming/Mozilla/Firefox/Profiles/* "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/Brave/
    # Chrome
      sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/Chrome/
      sudo cp -rf "$vPuntoDeMontajePartWindows"/Users/nipegun/AppData/Roaming/Mozilla/Firefox/Profiles/* "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/Chrome/
    # Chromium
      sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/Chromium/
      sudo cp -rf "$vPuntoDeMontajePartWindows"/Users/nipegun/AppData/Roaming/Mozilla/Firefox/Profiles/* "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/Chromium/
    # Edge
      sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/Edge/
      sudo cp -rf "$vPuntoDeMontajePartWindows"/Users/nipegun/AppData/Roaming/Mozilla/Firefox/Profiles/* "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/Edge/
    # Epic
      sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/Brave/
      sudo cp -rf "$vPuntoDeMontajePartWindows"/Users/nipegun/AppData/Roaming/Mozilla/Firefox/Profiles/* "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/Brave/
    # Firefox
      sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/Firefox/
      sudo cp -rf "$vPuntoDeMontajePartWindows"/Users/nipegun/AppData/Roaming/Mozilla/Firefox/Profiles/* "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/Firefox/
    # LibreWolf
      sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/LibreWolf/
      sudo cp -rf "$vPuntoDeMontajePartWindows"/Users/nipegun/AppData/Roaming/Mozilla/Firefox/Profiles/* "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/LibreWolf/
    # Opera
      sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/Opera/
      sudo cp -rf "$vPuntoDeMontajePartWindows"/Users/nipegun/AppData/Roaming/Mozilla/Firefox/Profiles/* "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/Opera/
    # OperaGX
      sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/OperaGX/
      sudo cp -rf "$vPuntoDeMontajePartWindows"/Users/nipegun/AppData/Roaming/Mozilla/Firefox/Profiles/* "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/OperaGX/
    # Safari
      sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/Safari/
      sudo cp -rf "$vPuntoDeMontajePartWindows"/Users/nipegun/AppData/Roaming/Mozilla/Firefox/Profiles/* "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/Safari/
    # Vivaldi
      sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/Vivaldi/
      sudo cp -rf "$vPuntoDeMontajePartWindows"/Users/nipegun/AppData/Roaming/Mozilla/Firefox/Profiles/* "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/Vivaldi/

    # Reparar permisos
      sudo chown $USER:$USER "$vCarpetaDelCaso"/Artefactos/ -R

fi
Brave

/AppData/Roaming/BraveSoftware/Brave-Browser
/AppData/Roaming/BraveSoftware/Brave-Browser/User Data/Default

Chrome

/AppData/Roaming/Google/Chrome
/AppData/Roaming/Google/Chrome/User Data/Default

Chromium

/AppData/Roaming/Chromium
/AppData/Roaming/Chromium/User Data/Default

Edge

/AppData/Roaming/Microsoft/Edge
/AppData/Roaming/Microsoft/Edge/User Data/Default

Epic

/AppData/Roaming/Epic Privacy Browser
/AppData/Roaming/Epic Privacy Browser/User Data/Default

Firefox

/AppData/Roaming/Mozilla/Firefox/Profiles
/AppData/Roaming/Mozilla/Firefox/Profiles/[Nombre-del-Perfil]

LibreWolf

/AppData/Roaming/LibreWolf
/AppData/Roaming/LibreWolf/Profiles/[Nombre-del-Perfil]

Opera

/AppData/Roaming/Opera Software/Opera Stable
/AppData/Roaming/Opera Software/Opera Stable

OperaGX

/AppData/Roaming/Opera Software/Opera GX Stable
/AppData/Roaming/Opera Software/Opera GX Stable

Safari

/AppData/Roaming/Apple Computer/Safari.
/AppData/Roaming/Apple

Vivaldi

/AppData/Roaming/Vivaldi
/AppData/Roaming/Vivaldi/User Data/Default

