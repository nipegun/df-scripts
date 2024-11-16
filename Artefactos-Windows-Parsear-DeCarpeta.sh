#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para analizar y exportar el archivo $MFT original a múltimples formatos
#
# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Artefactos-Windows-Obtener-DeImagen.sh | sudo bash -s /Ruta/Al/Archivo/De/Imagen/De/Evidencia
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
    vFechaDeEjec=$(date +a%Ym%md%d)
    # Comprobar si el paquete dialog está instalado. Si no lo está, instalarlo.
      if [[ $(dpkg-query -s dialog 2>/dev/null | grep installed) == "" ]]; then
        echo ""
        echo -e "${cColorRojo}  El paquete dialog no está instalado. Iniciando su instalación...${cFinColor}"
        echo ""
        apt-get -y update && apt-get -y install dialog
        echo ""
      fi

    # Crear el menú
      menu=(dialog --checklist "Marca las opciones que quieras instalar:" 22 72 16)
        opciones=(
          1 "Comprobar que existe la carpeta "  on
          2 "  Parsear la MFT"                  on
          3 "  Parsear el registro"             on
          4 "  Parsear los eventos"             off
          5 "  Parsear x"                       on
          6 "  Parsear x"                       on
          7 "  Parsear x"                       on
          8 "  Parsear x"                       on
        )
      choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)

      for choice in $choices
        do
          case $choice in

            1)

              echo ""
              echo "  Comprobando que existe la carpeta con los eventos extraídos.."
              echo ""


            ;;

            2)

              echo ""
              echo "  Parseando la MFT..."
              echo ""


            ;;

            3)

              echo ""
              echo "  Extrayendo y parseando el registro..."
              echo ""
              # Instalar RegRipper (Sólo se ejecuta en Debian)
                curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/RegRipper-Instalar.sh | sudo bash
              # Ejecutar RegRipper
                curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Registro-Extraer-Completo-WindowsVistaYPosterior.sh | sudo bash -s /Casos/"$vNombreCaso"/Imagen/Particiones/2 /Casos/"$vNombreCaso"/Artefactos

            ;;

            4)

              echo ""
              echo "  Extrayendo y parseando la MFT..."
              echo ""
              # Extraer MFT
                curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/MFT-Extraer-Original.sh | sudo bash -s /Casos/"$vNombreCaso"/Imagen/Particiones/2 /Casos/"$vNombreCaso"/Artefactos
             # Instalar analyzeMFT
               curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/analyzeMFT-Instalar.sh | sudo bash
             # Ejecutar analyzemft sobre la evidencia
               curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/MFT-AnalizarYExportar.sh | sudo bash -s /Casos/"$vNombreCaso"/Artefactos/MFT/MFTOriginal /Casos/"$vNombreCaso"/Artefactos/MFT/

            ;;

            5)

              echo ""
              echo "  Recolectando eventos originales..."
              echo ""
              curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Evidencia-Windows-Eventos-Originales-Recolectar.sh | sudo bash -s /Casos/"$vNombreCaso"/Imagen/Particiones/2 /Casos/"$vNombreCaso"/Artefactos/Windows

            ;;

            6)

              echo ""
              echo "  Parseando eventos recolectados..."
              echo ""
              curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Evidencia-Windows-Eventos-Recolectados-Parsear.sh | sudo bash -s /Casos/"$vNombreCaso"/Artefactos/Eventos/Originales/ /Casos/"$vNombreCaso"/Artefactos/Windows

            ;;

        esac

    done

fi
