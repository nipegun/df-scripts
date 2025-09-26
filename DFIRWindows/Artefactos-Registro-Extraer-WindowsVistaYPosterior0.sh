#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para extraer los archivos de registro de una partición de Windows
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/DFIRWindows/Artefactos-Registro-Extraer-WindowsVistaYPosterior.sh | sudo bash -s [PuntoDeMontajeDePartConWindows] [CarpetaDelCaso]    (Ambos sin barra final) 
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/DFIRWindows/Artefactos-Registro-Extraer-WindowsVistaYPosterior.sh | nano -
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

# Comprobar que se hayan pasado los parámetros correctos
if [ $# -ne $cCantParamEsperados ]
  then
    echo ""
    echo -e "${cColorRojo}  Mal uso del script. El uso correcto sería: ${cFinColor}"
    echo "    $0 [PuntoDeMontajeDeLaPartDeWindows] [CarpetaDelCaso]  (Ambos sin barra final)"
    echo ""
    echo "  Ejemplo:"
    echo "    $0 '/Casos/a2024m11d29/Imagen/Particiones/2' '/Casos/a2024m11d29'"
    echo ""
    exit
  else
    echo ""
    echo ""
    echo ""
    # Definir fecha de ejecución del script
      vFechaDelCaso=$(date +a%Ym%md%d@%T)

    # Definir variables
      vPuntoDeMontajePartWindows="$1" # Debe ser una carpeta sin barra final
      vCarpetaDelCaso="$2"            # Debe ser una carpeta sin barra final

    # Determinar el caso actual y crear la carpeta
      sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Registro

    # Determinar el nombre de la carpeta donde está instalado Windows
      while IFS= read -r -d '' win; do
        sys32=$(find "$win" -maxdepth 1 -type d -iname "system32" -print -quit)
        if [ -n "$sys32" ] && find "$sys32/config" -maxdepth 1 -type f -iname "SYSTEM" | grep -q .; then
          vWindowsDir="$win"
          vSystem32Dir="$sys32"
          break
        fi
      done < <(find "$vPuntoDeMontajePartWindows" -type d -iname "windows" -print0 2>/dev/null)
    # Copiar archivos de registro
      echo ""
      echo "  Copiando SYSTEM..."
      echo ""
      sudo cp "$vPuntoDeMontajePartWindows"/"$vWindowsDir"/"$vSystem32Dir"/config/SYSTEM   "$vCarpetaDelCaso"/Artefactos/Originales/Registro/SYSTEM
      echo ""
      echo "  Copiando SAM..."
      echo ""
      sudo cp "$vPuntoDeMontajePartWindows"/"$vWindowsDir"/"$vSystem32Dir"/config/SAM      "$vCarpetaDelCaso"/Artefactos/Originales/Registro/SAM
      echo ""
      echo "  Copiando SECURITY..."
      echo ""
      sudo cp "$vPuntoDeMontajePartWindows"/"$vWindowsDir"/"$vSystem32Dir"/config/SECURITY "$vCarpetaDelCaso"/Artefactos/Originales/Registro/SECURITY
      echo ""
      echo "  Copiando SOFTWARE..."
      echo ""
      sudo cp "$vPuntoDeMontajePartWindows"/"$vWindowsDir"/"$vSystem32Dir"/config/SOFTWARE "$vCarpetaDelCaso"/Artefactos/Originales/Registro/SOFTWARE
      echo ""
      echo "  Copiando DEFAULT..."
      echo ""
      sudo cp "$vPuntoDeMontajePartWindows"/"$vWindowsDir"/"$vSystem32Dir"/config/DEFAULT  "$vCarpetaDelCaso"/Artefactos/Originales/Registro/DEFAULT

    # Copiar registro de usuarios
      echo ""
      echo "  Copiando archivos de registro de usuarios..."
      echo ""
      sudo find "$vPuntoDeMontajePartWindows"/Users/ -mindepth 1 -maxdepth 1 -type d > /tmp/CarpetasDeUsuarios.txt
      while IFS= read -r linea; do
        vNomUsuario="${linea##*/}"
        echo ""
        echo "    Copiando NTUSER.DAT de $vNomUsuario..."
        echo ""
        sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Registro/Usuarios/"$vNomUsuario"
        sudo cp "$vPuntoDeMontajePartWindows"/Users/"$vNomUsuario"/NTUSER.DAT "$vCarpetaDelCaso"/Artefactos/Originales/Registro/Usuarios/"$vNomUsuario"/
      done < "/tmp/CarpetasDeUsuarios.txt"
      # Eliminar carpetas vacias
        sudo find "$vCarpetaDelCaso"/Artefactos/Originales/Registro/Usuarios/ -type d -empty -delete

    # Reparar permisos
      sudo chown $USER:$USER "$vCarpetaDelCaso"/Artefactos/ -R

fi

