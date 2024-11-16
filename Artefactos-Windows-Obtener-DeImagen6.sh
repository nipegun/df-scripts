#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para analizar y exportar el archivo $MFT original a múltimples formatos
#
# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Artefactos-Windows-Obtener-DeImagen.sh | sudo bash -s [RutaAlArchivoDeImagen]
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Artefactos-Windows-Obtener-DeImagen.sh | nano -
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
  cCantParamEsperados=1

if [ $# -ne $cCantParamEsperados ]
  then
    echo ""
    echo -e "${cColorRojo}  Mal uso del script. El uso correcto sería: ${cFinColor}"
    echo "    $0 [RutaAlArchivoDeImagen]"
    echo ""
    echo "  Ejemplo:"
    echo "    $0 '/Casos/imagen.dd'"
    echo ""
    exit
  else
    vFechaDelCaso=$(date +a%Ym%md%d)
    # Comprobar si el paquete dialog está instalado. Si no lo está, instalarlo.
      if [[ $(dpkg-query -s dialog 2>/dev/null | grep installed) == "" ]]; then
        echo ""
        echo -e "${cColorRojo}  El paquete dialog no está instalado. Iniciando su instalación...${cFinColor}"
        echo ""
        apt-get -y update && apt-get -y install dialog
        echo ""
      fi

    # Crear el menú
      menu=(dialog --checklist "Marca las opciones que quieras instalar:" 22 80 16)
        opciones=(
          1 "Desmontar todas las particiones loopback montadas como sólo lectura"  on
          2 "Montar todas las particiones de la imagen en modo lectura"            on
          3 "  Extraer la MFT"                                                     on
          4 "  Extraer el registro"                                                on
          5 "  Extraer los eventos"                                                on
          6 "  Extraer x"                                                          on
          7 "  Extraer x"                                                          on
          8 "  Extraer x"                                                          on
        )
      choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)

      for choice in $choices
        do
          case $choice in

            1)

              echo ""
              echo "  Desmontando todas las particiones loopback montadas previamente como sólo lectura.."
              echo ""
              curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Imagen-Particiones-Desmontar-Todas.sh | sudo bash

            ;;

            2)

              echo ""
              echo "  Montando todas las particiones en modo lectura..."
              echo ""
              curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Imagen-Particiones-Montar-SoloLectura.sh | sudo bash -s $1

            ;;

            3)

              echo ""
              echo "  Extrayendo la MFT..."
              echo ""
              # Determinar la partición de Windows
                vPartWindows=2
              curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Artefactos-Windows-MFT-Extraer.sh | sudo bash -s "/Casos/$vFechaDelCaso/Imagen/Particiones/$vPartWindows" "/Casos/$vFechaDelCaso"

            ;;

            4)

              echo ""
              echo "  Extrayendo el registro..."
              echo ""
              # Determinar la partición de Windows
                vPartWindows=2
              curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Artefactos-Windows-Registro-Extraer-WindowsVistaYPosterior.sh | sudo bash -s "/Casos/$vFechaDelCaso/Imagen/Particiones/$vPartWindows" "/Casos/$vFechaDelCaso"

            ;;

            5)

              echo ""
              echo "  Extrayendo los eventos..."
              echo ""
              curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Artefactos-Windows-Eventos-Extraer.sh | sudo bash -s "/Casos/$vFechaDelCaso/Imagen/Particiones/$vPartWindows" "/Casos/$vFechaDelCaso"

            ;;

            6)

              echo ""
              echo "  Extrayendo x..."
              echo ""

            ;;

            7)

              echo ""
              echo "  Extrayendo x..."
              echo ""

            ;;

            8)

              echo ""
              echo "  Extrayendo x..."
              echo ""

            ;;

        esac

    done

fi

