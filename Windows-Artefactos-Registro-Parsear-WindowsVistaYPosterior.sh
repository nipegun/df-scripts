#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para extraer los archivos de registro de una partición de Windows
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Windows-Artefactos-Registro-Parsear-WindowsVistaYPosterior.sh | sudo bash -s [CarpetaConArchivosDeRegistro] [CarpetaDondeGuardar] (Ambos sin barra final)
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Windows-Artefactos-Registro-Parsear-WindowsVistaYPosterior.sh | nano -
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
    echo "    $0 [CarpetaConArchivosDeRegistro] [CarpetaDondeGuardar] (Ambos sin barra final)"
    echo ""
    echo "  Ejemplo:"
    echo "    $0 /Casos/a2024m11d29/Artefactos/Originales/Registro /Casos/a2024m11d29/Artefactos/Parseados/Registro"
    echo ""
    exit
  else
    echo ""
    echo ""
    echo ""
    # Definir variables
      vCarpetaConArchivosDeRegistro="$1" # Debe ser una carpeta sin barra final
      vCarpetaDondeGuardar="$2"          # Debe ser una carpeta sin barra final
    # Exportar registros
      sudo mkdir -p "$vCarpetaDondeGuardar" 2> /dev/null
      # Comprobar si el script de RegRipper existe. Si no, llamar al script de instalación de RegRipper
        if [ ! -e "/usr/local/bin/rip.pl" ]; then
          echo ""
          echo -e "${cColorRojo}  No se ha encontrado el script en perl de RegRipper. Procediendo con su instalación.${cFinColor}"
          curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/RegRipper-Instalar.sh | bash
          echo ""
        fi

      echo ""
      echo "  RegRippeando SYSTEM..."
      echo ""
      sudo chmod +x /usr/local/bin/rip.pl
      sudo /usr/local/bin/rip.pl -r "$vCarpetaConArchivosDeRegistro"/SYSTEM   -a > "$vCarpetaDondeGuardar"/SYSTEM.txt

      echo ""
      echo "  RegRippeando SAM..."
      echo ""
      sudo chmod +x /usr/local/bin/rip.pl
      sudo /usr/local/bin/rip.pl -r "$vCarpetaConArchivosDeRegistro"/SAM      -a > "$vCarpetaDondeGuardar"/SAM.txt

      echo ""
      echo "  RegRippeando SECURITY..."
      echo ""
      sudo chmod +x /usr/local/bin/rip.pl
      sudo /usr/local/bin/rip.pl -r "$vCarpetaConArchivosDeRegistro"/SECURITY -a > "$vCarpetaDondeGuardar"/SECURITY.txt

      echo ""
      echo "  RegRippeando SOFTWARE..."
      echo ""
      sudo chmod +x /usr/local/bin/rip.pl
      sudo /usr/local/bin/rip.pl -r "$vCarpetaConArchivosDeRegistro"/SOFTWARE -a > "$vCarpetaDondeGuardar"/SOFTWARE.txt

      echo ""
      echo "  RegRippeando DEFAULT..."
      echo ""
      sudo chmod +x /usr/local/bin/rip.pl
      sudo /usr/local/bin/rip.pl -r "$vCarpetaConArchivosDeRegistro"/DEFAULT  -a > "$vCarpetaDondeGuardar"/DEFAULT.txt

    # Exportar registro de usuarios
      echo ""
      echo "  RegRippeando archivos de registro de usuarios..."
      echo ""
      sudo find "$vCarpetaConArchivosDeRegistro"/Usuarios -mindepth 1 -maxdepth 1 -type d > /tmp/CarpetasDeUsuarios.txt
      while IFS= read -r linea; do
        vNomUsuario="${linea##*/}"
        echo ""
        echo "    RegRippeando NTUSER.DAT de $vNomUsuario..."
        echo ""
        mkdir -p "$vCarpetaDondeGuardar"/Usuarios/"$vNomUsuario" 2> /dev/null
        /usr/local/bin/rip.pl -r "$vCarpetaConArchivosDeRegistro"/Usuarios/"$vNomUsuario"/NTUSER.DAT  -a > "$vCarpetaDondeGuardar"/Usuarios/"$vNomUsuario"/NTUSER.DAT.txt
      done < "/tmp/CarpetasDeUsuarios.txt"

    # Reparar permisos
      sudo chown 1000:1000 "$vCarpetaDondeGuardar" -R

fi
