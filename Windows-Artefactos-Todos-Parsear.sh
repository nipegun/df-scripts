#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para analizar y exportar el archivo $MFT original a múltimples formatos
#
# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Windows-Artefactos-Todos-Parsear.sh | sudo bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Windows-Artefactos-Todos-Parsear.sh | nano -
# ----------

# Definir constantes de color
  cColorAzul="\033[0;34m"
  cColorAzulClaro="\033[1;34m"
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

# Definir fecha de ejecución del script para saber la carpeta del caso
  vFechaDeEjec=$(date +a%Ym%md%d)

# Crear el menú
  # Comprobar si el paquete dialog está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s dialog 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${cColorRojo}  El paquete dialog no está instalado. Iniciando su instalación...${cFinColor}"
      echo ""
      sudo apt-get -y update && sudo apt-get -y install dialog
      echo ""
    fi
  menu=(dialog --checklist "Marca las opciones que quieras instalar:" 22 72 16)
    opciones=(
      1 "Comprobar que existe la carpeta "       on
      2 "  (Con internet) - Parsear la MFT"      on
      3 "  (Con internet) - Parsear el registro" on
      4 "  (Con internet) - Parsear los eventos" on
      5 "  Parsear x"                            off
      6 "  Parsear x"                            off
      7 "  Parsear x"                            off
      8 "  Parsear x"                            off
      9 "  Parsear x"                            off
     10 "  Parsear x"                            off
     11 "  Parsear x"                            off
     12 "  (Sin internet) - Parsear la MFT"      off
     13 "  (Sin internet) - Parsear el registro" off
     14 "  (Sin internet) - Parsear los eventos" off
     15 "  (Sin internet) - x"                   off
     16 "  (Sin internet) - x"                   off
     17 "  (Sin internet) - x"                   off
    )
    choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)

      for choice in $choices
        do
          case $choice in

            1)

              echo ""
              echo "  Comprobando que existe la carpeta con los eventos extraídos.."
              echo ""
              if [ ! -d "$1"]; then
                echo ""
                echo "    La carpeta no existe. Abortando script..."
                echo ""
                exit
              fi

            ;;

            2)

              echo ""
              echo "  Parseando la MFT..."
              echo ""
              curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Windows-Artefactos-MFT-Parsear.sh | sudo bash -s /Casos/$vFechaDeEjec/Artefactos/Originales/MFT /Casos/$vFechaDeEjec/Artefactos/Parseados/MFT
              

            ;;

            3)

              echo ""
              echo "  Parseando el registro..."
              echo ""
              curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Windows-Artefactos-Registro-Parsear-WindowsVistaYPosterior.sh | sudo bash -s /Casos/$vFechaDeEjec/Artefactos/Originales/Registro /Casos/$vFechaDeEjec/Artefactos/Parseados/Registro

            ;;

            4)

              echo ""
              echo "  Parseando los eventos..."
              echo ""
              curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Windows-Artefactos-Eventos-Parsear.sh | sudo bash -s /Casos/$vFechaDeEjec/Artefactos/Originales/Eventos /Casos/$vFechaDeEjec/Artefactos/Parseados/Eventos

            ;;

            5)

              echo ""
              echo "  Parseando x..."
              echo ""

            ;;

            6)

              echo ""
              echo "  Parseando x..."
              echo ""

            ;;


            7)

              echo ""
              echo "  Parseando x..."
              echo ""

            ;;

            8)

              echo ""
              echo "  Parseando x..."
              echo ""

            ;;

            9)

              echo ""
              echo "  Parseando x..."
              echo ""

            ;;

           10)

              echo ""
              echo "  Parseando x..."
              echo ""

            ;;

           11)

              echo ""
              echo "  Parseando x..."
              echo ""

            ;;

           12)

              echo ""
              echo "  Parseando la MFT (sin internet)..."
              echo ""
              sudo ~/scripts/df-scripts/Windows-Artefactos-MFT-Parsear.sh /Casos/$vFechaDeEjec/Artefactos/Originales/MFT /Casos/$vFechaDeEjec/Artefactos/Parseados/MFT
              

            ;;

           13)

              echo ""
              echo "  Parseando el registro (sin internet)..."
              echo ""
              sudo ~/scripts/df-scripts/Windows-Artefactos-Registro-Parsear-WindowsVistaYPosterior.sh /Casos/$vFechaDeEjec/Artefactos/Originales/Registro /Casos/$vFechaDeEjec/Artefactos/Parseados/Registro

            ;;

           14)

              echo ""
              echo "  Parseando los eventos (sin internet)..."
              echo ""
              sudo ~/scripts/df-scripts/Windows-Artefactos-Eventos-Parsear.sh /Casos/$vFechaDeEjec/Artefactos/Originales/Eventos /Casos/$vFechaDeEjec/Artefactos/Parseados/Eventos

            ;;

           15)

              echo ""
              echo "  Parseando x..."
              echo ""

            ;;

           16)

              echo ""
              echo "  Parseando x..."
              echo ""

            ;;

           17)

              echo ""
              echo "  Parseando x..."
              echo ""

            ;;

          esac

      done

