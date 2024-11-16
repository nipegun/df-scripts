#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para extraer los archivos de registro de una partición de Windows
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Registro-Extraer-Completo-WindowsVistaYPosterior.sh | sudo bash -s Parámetro1 Parámetro2
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

# Comprobar si el script de RegRipper existe. Si no, llamar al script de instalación de RegRipper
  if [ ! -e "/usr/local/bin/rip.pl" ]; then
    echo ""
    echo -e "${cColorRojo}  No se ha encontrado el script en perl de RegRipper. Seguramente RegRipper no esté instalado.${cFinColor}"
    echo ""
    echo "  Puedes instalarlo con:"
    echo ""
    echo "    curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/main/SoftInst/ParaCLI/RegRipper-Instalar.sh | sudo bash"
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
    echo "    $0 [PuntoDeMontajeDePartConWindows] [CarpetaDondeExtraerElRegistro] (Ambos sin barra final)"
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
      cFechaDeEjec=$(date +a%Ym%md%d@%T)

    # Definir variables
      vPuntoDeMontaje="$1" # Debe ser una carpeta sin barra final
      vCarpetaDeCasos="$2" # Debe ser una carpeta sin barra final

    # Determinar el caso actual y crear la carpeta
      mkdir -p "$vCarpetaDeCasos"/Registro/ArchivosCrudos/

    # Copiar archivos de registro
      echo ""
      echo "  Copiando SYSTEM..."
      echo ""
      cp "$vPuntoDeMontaje"/Windows/System32/config/SYSTEM   "$vCarpetaDeCasos"/Registro/ArchivosCrudos/SYSTEM
      echo ""
      echo "  Copiando SAM..."
      echo ""
      cp "$vPuntoDeMontaje"/Windows/System32/config/SAM      "$vCarpetaDeCasos"/Registro/ArchivosCrudos/SAM
      echo ""
      echo "  Copiando SECURITY..."
      echo ""
      cp "$vPuntoDeMontaje"/Windows/System32/config/SECURITY "$vCarpetaDeCasos"/Registro/ArchivosCrudos/SECURITY
      echo ""
      echo "  Copiando SOFTWARE..."
      echo ""
      cp "$vPuntoDeMontaje"/Windows/System32/config/SOFTWARE "$vCarpetaDeCasos"/Registro/ArchivosCrudos/SOFTWARE
      echo ""
      echo "  Copiando DEFAULT..."
      echo ""
      cp "$vPuntoDeMontaje"/Windows/system32/config/DEFAULT  "$vCarpetaDeCasos"/Registro/ArchivosCrudos/DEFAULT

    # Copiar registro de usuarios
      echo ""
      echo "  Copiando archivos de registro de usuarios..."
      echo ""
      find "$vPuntoDeMontaje/Users/" -mindepth 1 -maxdepth 1 -type d > /tmp/CarpetasDeUsuarios.txt
      while IFS= read -r linea; do
        vNomUsuario="${linea##*/}"
        echo ""
        echo "    Copiando NTUSER.DAT de $vNomUsuario..."
        echo ""
        mkdir -p "$vCarpetaDeCasos"/Registro/ArchivosCrudos/Usuarios/"$vNomUsuario"
        cp "$vPuntoDeMontaje"/"Users"/"$vNomUsuario"/NTUSER.DAT "$vCarpetaDeCasos"/Registro/ArchivosCrudos/Usuarios/"$vNomUsuario"/
      done < "/tmp/CarpetasDeUsuarios.txt"


    # Exportar registros
      mkdir -p "$vCarpetaDeCasos"/Registro/ArchivosParseados/ 2> /dev/null
      echo ""
      echo "  RegRippeando SYSTEM..."
      echo ""
      /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/Registro/ArchivosCrudos/SYSTEM   -a > "$vCarpetaDeCasos"/Registro/ArchivosParseados/SYSTEM.txt
      echo ""
      echo "  RegRippeando SAM..."
      echo ""
      /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/Registro/ArchivosCrudos/SAM      -a > "$vCarpetaDeCasos"/Registro/ArchivosParseados/SAM.txt
      echo ""
      echo "  RegRippeando SECURITY..."
      echo ""
      /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/Registro/ArchivosCrudos/SECURITY -a > "$vCarpetaDeCasos"/Registro/ArchivosParseados/SECURITY.txt
      echo ""
      echo "  RegRippeando SOFTWARE..."
      echo ""
      /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/Registro/ArchivosCrudos/SOFTWARE -a > "$vCarpetaDeCasos"/Registro/ArchivosParseados/SOFTWARE.txt
      echo ""
      echo "  RegRippeando DEFAULT..."
      echo ""
      /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/Registro/ArchivosCrudos/DEFAULT  -a > "$vCarpetaDeCasos"/Registro/ArchivosParseados/DEFAULT.txt

    # Exportar registro de usuarios
      echo ""
      echo "  RegRippeando archivos de registro de usuarios..."
      echo ""
      find "$vPuntoDeMontaje/Users/" -mindepth 1 -maxdepth 1 -type d > /tmp/CarpetasDeUsuarios.txt
      while IFS= read -r linea; do
        vNomUsuario="${linea##*/}"
        echo ""
        echo "    RegRippeando NTUSER.DAT de $vNomUsuario..."
        echo ""
        mkdir -p "$vCarpetaDeCasos"/Registro/ArchivosParseados/Usuarios/"$vNomUsuario" 2> /dev/null
        /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/Registro/ArchivosCrudos/Usuarios/"$vNomUsuario"/NTUSER.DAT  -a > "$vCarpetaDeCasos"/Registro/ArchivosParseados/Usuarios/"$vNomUsuario"/NTUSER.DAT.txt
      done < "/tmp/CarpetasDeUsuarios.txt"

    # Reparar permisos
      chown 1000:1000 "$vCarpetaDeCasos"/Registro/ -R

fi

