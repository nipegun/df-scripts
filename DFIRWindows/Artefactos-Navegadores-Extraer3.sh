#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para extraer todas las carpetas con información de navegadores de una partición de Windows
#
# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/DFIRWindows/Artefactos-Navegadores-Extraer.sh | bash -s [PuntoDeMontajeDeLaPartDeWindows] [CarpetaDelCaso]  (Ambos sin barra final)
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/DFIRWindows/Artefactos-Navegadores-Extraer.sh | nano -
# ----------

# Definir constantes de color
  cColorAzul="\033[0;34m"
  cColorAzulClaro="\033[1;34m"
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
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
    vPuntoDeMontajePartWindows="$1"
    vCarpetaDelCaso="$2"

    echo ""
    echo "  Buscando perfiles de usuario..."
    echo ""

    # Detectar el directorio real de Windows (WINDOWS, WINNT, WIN98, etc.)
      vWindowsDir=$(find "$vPuntoDeMontajePartWindows" -maxdepth 1 -type d \( -iname "windows" -o -iname "winnt" -o -iname "win" -o -iname "win98" -o -iname "winme" -o -iname "win9x" \) -print -quit 2>/dev/null)
      if [ -z "$vWindowsDir" ]; then
        echo "No se ha podido localizar la carpeta del sistema Windows."
        exit 1
      fi

    # Detectar tipo de estructura según versión
      if [ -d "$vPuntoDeMontajePartWindows/Users" ]; then
        echo "    Se ha detectado Windows Vista o posterior."
        vBaseUsers="$vPuntoDeMontajePartWindows/Users"
        vAppDataRel="AppData/Roaming"
      elif [ -d "$vPuntoDeMontajePartWindows/Documents and Settings" ]; then
        echo "    Se ha detectado Windows XP / 2003."
        vBaseUsers="$vPuntoDeMontajePartWindows/Documents and Settings"
        vAppDataRel="Application Data"
      elif [ -d "$vWindowsDir/Profiles" ]; then
        echo "    Se ha detectado Windows 95 / 98 / Me."
        vBaseUsers="$vWindowsDir/Profiles"
        vAppDataRel="Application Data"
      else
        echo "No se han encontrado carpetas de usuarios conocidas."
        exit 1
      fi

    sudo find "$vBaseUsers" -mindepth 1 -maxdepth 1 -type d -print0 | sudo tee /tmp/CarpetasDeUsuarios.txt > /dev/null

    while IFS= read -r -d '' vRutaUsuario; do
      vNomUsuario="${vRutaUsuario##*/}"
      echo ""
      echo "    Procesando usuario: $vNomUsuario"
      echo ""

      vDestinoBase="$vCarpetaDelCaso/Artefactos/Originales/Navegadores/$vNomUsuario"
      sudo mkdir -p "$vDestinoBase"

      # ---- Internet Explorer (todas las versiones) ----
        sudo mkdir -p "$vDestinoBase/InternetExplorer"
        sudo cp -rfv "$vRutaUsuario/$vAppDataRel/Microsoft/Internet Explorer"/* \
        "$vDestinoBase/InternetExplorer/" 2>/dev/null

      # ---- Elementos clásicos de Internet Explorer ----
        sudo mkdir -p "$vDestinoBase/InternetExplorer/Cookies"
        sudo mkdir -p "$vDestinoBase/InternetExplorer/Favorites"
        sudo mkdir -p "$vDestinoBase/InternetExplorer/History"
        sudo cp -rfv "$vRutaUsuario/Cookies"/* \
        "$vDestinoBase/InternetExplorer/Cookies/" 2>/dev/null
        sudo cp -rfv "$vRutaUsuario/Favorites"/* \
        "$vDestinoBase/InternetExplorer/Favorites/" 2>/dev/null
        sudo cp -rfv "$vRutaUsuario/History"/* \
        "$vDestinoBase/InternetExplorer/History/" 2>/dev/null
        sudo find "$vRutaUsuario" -type f -iname "index.dat" -exec sudo cp -vf {} \
        "$vDestinoBase/InternetExplorer/" \; 2>/dev/null

      # ---- Firefox / Mozilla ----
        sudo mkdir -p "$vDestinoBase/Firefox"
        sudo cp -rfv "$vRutaUsuario/$vAppDataRel/Mozilla/Firefox"/* \
        "$vDestinoBase/Firefox/" 2>/dev/null
        sudo cp -rfv "$vRutaUsuario/$vAppDataRel/Mozilla"/* \
        "$vDestinoBase/Firefox/" 2>/dev/null
        sudo find "$vRutaUsuario" -type f \( -iname "places.sqlite" -o -iname "history.dat" \) -exec sudo cp -vf {} \
        "$vDestinoBase/Firefox/" \; 2>/dev/null

      # ---- Netscape (95-Me-XP) ----
        sudo mkdir -p "$vDestinoBase/Netscape"
        sudo cp -rfv "$vRutaUsuario/$vAppDataRel/Netscape"/* \
        "$vDestinoBase/Netscape/" 2>/dev/null
        sudo find "$vRutaUsuario" -type f -iname "history.dat" -exec sudo cp -vf {} \
        "$vDestinoBase/Netscape/" \; 2>/dev/null

      # ---- Opera (todas las versiones antiguas) ----
        sudo mkdir -p "$vDestinoBase/Opera"
        sudo cp -rfv "$vRutaUsuario/$vAppDataRel/Opera"/* \
        "$vDestinoBase/Opera/" 2>/dev/null
        sudo cp -rfv "$vRutaUsuario/$vAppDataRel/Opera Software"/* \
        "$vDestinoBase/Opera/" 2>/dev/null
        sudo find "$vRutaUsuario" -type f \( -iname "global_history.dat" -o -iname "History" \) -exec sudo cp -vf {} \
        "$vDestinoBase/Opera/" \; 2>/dev/null

    done < /tmp/CarpetasDeUsuarios.txt

    sudo chown -R "$USER:$USER" "$vCarpetaDelCaso/Artefactos/"
    sudo find "$vCarpetaDelCaso/Artefactos/Originales/Navegadores/" -type d -empty -delete

fi
