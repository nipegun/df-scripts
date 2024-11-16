#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para extraer los archivos de registro de una partición de Windows
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Registro-Extraer-Completo-WindowsVistaYPosterior.sh | sudo bash -s [PuntoDeMontajeDePartConWindows] [CarpetaDelCaso]    (Ambos sin barra final) 
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Registro-Extraer-Completo-WindowsVistaYPosterior.sh | nano -
# ----------

# Definir constantes de color
  cColorAzul="\033[0;34m"
  cColorAzulClaro="\033[1;34m"
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

# Comprobar si el script está corriendo como root
  #if [ $(id -u) -ne 0 ]; then     # Sólo comprueba si es root
  if [[ $EUID -ne 0 ]]; then       # Comprueba si es root o sudo
    echo ""
    echo -e "${cColorRojo}  Este script está preparado para ejecutarse con privilegios de administrador (como root o con sudo).${cFinColor}"
    echo ""
    exit
  fi

# Definir la cantidad de argumentos esperados
  cCantParamEsperados=2

# Comprobar que se hayan pasado los parámetros correctos
if [ $# -ne $cCantParamEsperados ]
  then
    echo ""
    echo -e "${cColorRojo}  Mal uso del script. El uso correcto sería: ${cFinColor}"
    echo "    $0 [PuntoDeMontajeDePartConWindows] [CarpetaDelCaso] (Ambos sin barra final)"
    echo ""
    echo "  Ejemplo:"
    echo "    $0 'Hola' 'Mundo'"
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
      vCarpetaDelCaso="$2"

    # Determinar el caso actual y crear la carpeta
      mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Registro

    # Copiar archivos de registro
      echo ""
      echo "  Copiando SYSTEM..."
      echo ""
      cp "$vPuntoDeMontajePartWindows"/Windows/System32/config/SYSTEM   "$vCarpetaDelCaso"/Artefactos/Originales/Registro/SYSTEM
      echo ""
      echo "  Copiando SAM..."
      echo ""
      cp "$vPuntoDeMontajePartWindows"/Windows/System32/config/SAM      "$vCarpetaDelCaso"/Artefactos/Originales/Registro/SAM
      echo ""
      echo "  Copiando SECURITY..."
      echo ""
      cp "$vPuntoDeMontajePartWindows"/Windows/System32/config/SECURITY "$vCarpetaDelCaso"/Artefactos/Originales/Registro/SECURITY
      echo ""
      echo "  Copiando SOFTWARE..."
      echo ""
      cp "$vPuntoDeMontajePartWindows"/Windows/System32/config/SOFTWARE "$vCarpetaDelCaso"/Artefactos/Originales/Registro/SOFTWARE
      echo ""
      echo "  Copiando DEFAULT..."
      echo ""
      cp "$vPuntoDeMontajePartWindows"/Windows/system32/config/DEFAULT  "$vCarpetaDelCaso"/Artefactos/Originales/Registro/DEFAULT

    # Copiar registro de usuarios
      echo ""
      echo "  Copiando archivos de registro de usuarios..."
      echo ""
      find "$vPuntoDeMontajePartWindows"/Users/ -mindepth 1 -maxdepth 1 -type d > /tmp/CarpetasDeUsuarios.txt
      while IFS= read -r linea; do
        vNomUsuario="${linea##*/}"
        echo ""
        echo "    Copiando NTUSER.DAT de $vNomUsuario..."
        echo ""
        mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Registro/Usuarios/"$vNomUsuario"
        cp "$vPuntoDeMontajePartWindows"/Users/"$vNomUsuario"/NTUSER.DAT "$vCarpetaDelCaso"/Artefactos/Originales/Registro/Usuarios/"$vNomUsuario"/
      done < "/tmp/CarpetasDeUsuarios.txt"

    # Reparar permisos
      chown 1000:1000 "$vCarpetaDelCaso"/Artefactos/ -R

fi

