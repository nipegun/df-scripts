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
    # Copiar registro de usuarios
      echo ""
      echo "  Copiando datos de navegadores de usuarios..."
      echo ""
      sudo find "$vPuntoDeMontajePartWindows"/Users/ -mindepth 1 -maxdepth 1 -type d > /tmp/CarpetasDeUsuarios.txt
      while IFS= read -r linea; do
        vNomUsuario="${linea##*/}"
        echo ""
        echo "    Copiando Navegadores de $vNomUsuario..."
        echo ""
        sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"
        sudo chown $USER:$USER "$vCarpetaDelCaso"/Artefactos/ -R 2> /dev/null
      # Brave
          sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Brave/
          sudo chown $USER:$USER "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Brave/
          sudo cp -rf "$vPuntoDeMontajePartWindows"/Users/"$vNomUsuario"/AppData/Roaming/BraveSoftware/Brave-Browser/* \
          "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Brave/
      # Chrome
          sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Chrome/
          sudo chown $USER:$USER "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Chrome/
          sudo cp -rf "$vPuntoDeMontajePartWindows"/Users/"$vNomUsuario"/AppData/Roaming/Google/Chrome/* \
          "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Chrome/
      # Chromium
          sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Chromium/
          sudo chown $USER:$USER "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Chromium/
          sudo cp -rf "$vPuntoDeMontajePartWindows"/Users/"$vNomUsuario"/AppData/Roaming/Chromium/* \
          "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Chromium/
      # Edge
          sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Edge/
          sudo chown $USER:$USER "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Edge/
          sudo cp -rf "$vPuntoDeMontajePartWindows"/Users/"$vNomUsuario"/AppData/Roaming/Microsoft/Edge/* \
          "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Edge/
      # Epic
          sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Epic/
          sudo chown $USER:$USER "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Epic/
          sudo cp -rf "$vPuntoDeMontajePartWindows"/Users/"$vNomUsuario"/AppData/Roaming/Epic Privacy Browser/* \
          "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Epic/
      # Firefox
          sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Firefox/
          sudo chown $USER:$USER "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Firefox/
          sudo cp -rf "$vPuntoDeMontajePartWindows"/Users/"$vNomUsuario"/AppData/Roaming/Mozilla/Firefox/* \
          "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Epic/
      # Librewolf
          sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Librewolf/
          sudo chown $USER:$USER "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Librewolf/
          sudo cp -rf "$vPuntoDeMontajePartWindows"/Users/"$vNomUsuario"/AppData/Roaming/Mozilla/Librewolf/* \
          "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Librewolf/
      # Opera
          sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Opera/
          sudo chown $USER:$USER "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Opera/
          sudo cp -rf "$vPuntoDeMontajePartWindows"/Users/"$vNomUsuario"/AppData/Roaming/Opera Software/Opera GX Stable/* \
          "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Opera/
      # OperaGX
          sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/OperaGX/
          sudo chown $USER:$USER "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/OperaGX/
          sudo cp -rf "$vPuntoDeMontajePartWindows"/Users/"$vNomUsuario"/AppData/Roaming/Opera Software/Opera GX Stable/* \
          "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/OperaGX/
      # Safari
          sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Safari/
          sudo chown $USER:$USER "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Safari/
          sudo cp -rf "$vPuntoDeMontajePartWindows"/Users/"$vNomUsuario"/AppData/Roaming/Apple Computer/Safari/* \
          "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Safari/
      # Safari
          sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Vivaldi/
          sudo chown $USER:$USER "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Vivaldi/
          sudo cp -rf "$vPuntoDeMontajePartWindows"/Users/"$vNomUsuario"/AppData/Roaming/Vivaldi/* \
          "$vCarpetaDelCaso"/Artefactos/Originales/Navegadores/"$vNomUsuario"/Vivaldi/
      done < "/tmp/CarpetasDeUsuarios.txt"
      # Eliminar carpetas vacias
        sudo find "$vCarpetaDelCaso"/Artefactos/Originales/Registro/Usuarios/ -type d -empty -delete

    # Reparar permisos
      sudo chown $USER:$USER "$vCarpetaDelCaso"/Artefactos/ -R





    
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



