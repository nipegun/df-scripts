#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para extraer los archivos de registro de una partición de Windows
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Artefactos-Windows-Registro-Parsear-WindowsVistaYPosterior.sh | sudo bash -s [CarpetaConArchivosDeRegistro] [CarpetaDondeGuardar] (Ambos sin barra final)
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Artefactos-Windows-Registro-Parsear-WindowsVistaYPosterior.sh | nano -
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
    echo "    $0 [CarpetaConArchivosDeRegistro] [CarpetaDondeGuardar] (Ambos sin barra final)"
    echo ""
    echo "  Ejemplo:"
    echo "    $0 /Casos/a2024m11d16/Artefactos/Originales/Registro /Casos/a2024m11d16/Artefactos/Parseados/Registro"
    echo ""
    exit
  else
    echo ""
    echo ""
    echo ""
    # Definir variables
      vCarpetaConArchivosDeRegistro="$1" # Debe ser una carpeta sin barra final
      vCarpetaDondeGuardar="$2" # Debe ser una carpeta sin barra final
    # Exportar registros
      mkdir -p "$vCarpetaDondeGuardar" 2> /dev/null
      # Comprobar si el script de RegRipper existe. Si no, llamar al script de instalación de RegRipper
        if [ ! -e "/usr/local/bin/rip.pl" ]; then
          echo ""
          echo -e "${cColorRojo}  No se ha encontrado el script en perl de RegRipper. Procediendo con su instalación.${cFinColor}"
          curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/RegRipper-Instalar.sh | sudo bash
          echo ""
        fi
      echo ""
      echo "  RegRippeando SYSTEM..."
      echo ""
      /usr/local/bin/rip.pl -r "$vCarpetaConArchivosDeRegistro"/SYSTEM   -a > "$vCarpetaDondeGuardar"/SYSTEM.txt
      echo ""
      echo "  RegRippeando SAM..."
      echo ""
      /usr/local/bin/rip.pl -r "$vCarpetaConArchivosDeRegistro"/SAM      -a > "$vCarpetaDondeGuardar"/SAM.txt
      echo ""
      echo "  RegRippeando SECURITY..."
      echo ""
      /usr/local/bin/rip.pl -r "$vCarpetaConArchivosDeRegistro"/SECURITY -a > "$vCarpetaDondeGuardar"/SECURITY.txt
      echo ""
      echo "  RegRippeando SOFTWARE..."
      echo ""
      /usr/local/bin/rip.pl -r "$vCarpetaConArchivosDeRegistro"/SOFTWARE -a > "$vCarpetaDondeGuardar"/SOFTWARE.txt
      echo ""
      echo "  RegRippeando DEFAULT..."
      echo ""
      /usr/local/bin/rip.pl -r "$vCarpetaConArchivosDeRegistro"/DEFAULT  -a > "$vCarpetaDondeGuardar"/DEFAULT.txt

    # Exportar registro de usuarios
      echo ""
      echo "  RegRippeando archivos de registro de usuarios..."
      echo ""
      find "$vCarpetaConArchivosDeRegistro"/Usuarios -mindepth 1 -maxdepth 1 -type d > /tmp/CarpetasDeUsuarios.txt
      while IFS= read -r linea; do
        vNomUsuario="${linea##*/}"
        echo ""
        echo "    RegRippeando NTUSER.DAT de $vNomUsuario..."
        echo ""
        mkdir -p "$vCarpetaDondeGuardar"/Usuarios/"$vNomUsuario" 2> /dev/null
        /usr/local/bin/rip.pl -r "$vCarpetaDondeGuardar"/Usuarios/"$vNomUsuario"/NTUSER.DAT  -a > "$vCarpetaDondeGuardar"/Usuarios/"$vNomUsuario"/NTUSER.DAT.txt
      done < "/tmp/CarpetasDeUsuarios.txt"

    # Reparar permisos
      chown 1000:1000 "$vCarpetaDondeGuardar" -R

fi
