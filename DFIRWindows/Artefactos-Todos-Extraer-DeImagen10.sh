#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para analizar y exportar el archivo $MFT original a múltimples formatos
#
# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/DFIRWindows/Artefactos-Todos-Extraer-DeImagen.sh | sudo bash -s [RutaAlArchivoDeImagen]
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/DFIRWindows/Artefactos-Todos-Extraer-DeImagen.sh | nano -
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
        apt-get -y update
        apt-get -y install dialog
        echo ""
      fi

    # Crear el menú
      menu=(dialog --checklist "Marca las opciones que quieras instalar:" 22 84 16)
        opciones=(
          1 "Desmontar todas las particiones loopback montadas como sólo lectura"  on
          2 "Montar todas las particiones de la imagen en modo lectura"            on
          3 "  Extraer el archivo MFT"                                             on
          4 "  Extraer los archivos de registro"                                   on
          5 "  Extraer los archivos de eventos"                                    on
          6 "  Extraer los navegadores"                                            on
          7 "  Extraer x"                                                          on
          8 "  Reparar permisos"                                                   on
        )
      choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)

      for choice in $choices
        do
          case $choice in

            1)

              echo ""
              echo "  Desmontando todas las particiones loopback montadas previamente como sólo lectura.."
              echo ""
              sudo ~/scripts/df-scripts/Imagen-Particiones-Todas-Desmontar-SoloLectura.sh
              sudo chown $USER:$USER /Casos/ -R 2> /dev/null

            ;;

            2)

              echo ""
              echo "  Montando todas las particiones en modo lectura..."
              echo ""
              sudo ~/scripts/df-scripts/Imagen-Particiones-Todas-Montar-SoloLectura.sh $1
              sudo chown $USER:$USER /Casos/ -R 2> /dev/null

            ;;

            3)

              echo ""
              echo "  Extrayendo el archivo MFT..."
              echo ""
              # Determinar el punto de montaje de la partición de Windows
                # Obtener el nombre de la carpeta
                  vNumCarpeta=$(ls /Casos/"$vFechaDelCaso"/Imagen/Particiones/ | tail -n1)
                # Comprobar que exista el archivo $MFT
                  if [ -f /Casos/"$vFechaDelCaso"/Imagen/Particiones/"$vNumCarpeta"/$\MFT ]; then
                    vPuntoMontajePartWindows="/Casos/$vFechaDelCaso/Imagen/Particiones/$vNumCarpeta"
                  else
                    echo ""
                    echo "    La partición no está montada. No se puede continuar."
                    echo ""
                    exit
                  fi
              sudo ~/scripts/df-scripts/DFIRWindows/Artefactos-MFT-Extraer.sh "$vPuntoMontajePartWindows" "/Casos/$vFechaDelCaso/"
              sudo chown $USER:$USER /Casos/ -R 2> /dev/null

            ;;

            4)

              echo ""
              echo "  Extrayendo los archivos de registro..."
              echo ""
              # Determinar el punto de montaje de la partición de Windows
                # Obtener el nombre de la carpeta
                  vNumCarpeta=$(ls /Casos/"$vFechaDelCaso"/Imagen/Particiones/ | tail -n1)
                # Comprobar que exista el archivo $MFT
                  if [ -f /Casos/"$vFechaDelCaso"/Imagen/Particiones/"$vNumCarpeta"/$\MFT ]; then
                    vPuntoMontajePartWindows="/Casos/$vFechaDelCaso/Imagen/Particiones/$vNumCarpeta"
                  else
                    echo ""
                    echo "    La partición no está montada. No se puede continuar."
                    echo ""
                    exit
                  fi
              sudo ~/scripts/df-scripts/DFIRWindows/Artefactos-Registro-Extraer.sh "$vPuntoMontajePartWindows" "/Casos/$vFechaDelCaso/"
              sudo chown $USER:$USER /Casos/ -R 2> /dev/null

            ;;

            5)

              echo ""
              echo "  Extrayendo los archivos de eventos..."
              echo ""
              # Determinar el punto de montaje de la partición de Windows
                # Obtener el nombre de la carpeta
                  vNumCarpeta=$(ls /Casos/"$vFechaDelCaso"/Imagen/Particiones/ | tail -n1)
                # Comprobar que exista el archivo $MFT
                  if [ -f /Casos/"$vFechaDelCaso"/Imagen/Particiones/"$vNumCarpeta"/$\MFT ]; then
                    vPuntoMontajePartWindows="/Casos/$vFechaDelCaso/Imagen/Particiones/$vNumCarpeta"
                  else
                    echo ""
                    echo "    La partición no está montada. No se puede continuar."
                    echo ""
                    exit
                  fi
              sudo ~/scripts/df-scripts/DFIRWindows/Artefactos-Eventos-Extraer.sh "$vPuntoMontajePartWindows" "/Casos/$vFechaDelCaso/"
              sudo chown $USER:$USER /Casos/ -R 2> /dev/null

            ;;

            6)

              echo ""
              echo "  Extrayendo los navegadores..."
              echo ""
              # Determinar el punto de montaje de la partición de Windows
                # Obtener el nombre de la carpeta
                  vNumCarpeta=$(ls /Casos/"$vFechaDelCaso"/Imagen/Particiones/ | tail -n1)
                # Comprobar que exista el archivo $MFT
                  if [ -f /Casos/"$vFechaDelCaso"/Imagen/Particiones/"$vNumCarpeta"/$\MFT ]; then
                    vPuntoMontajePartWindows="/Casos/$vFechaDelCaso/Imagen/Particiones/$vNumCarpeta"
                  else
                    echo ""
                    echo "    La partición no está montada. No se puede continuar."
                    echo ""
                    exit
                  fi
              sudo ~/scripts/df-scripts/DFIRWindows/Artefactos-Navegadores-Extraer.sh "$vPuntoMontajePartWindows" "/Casos/$vFechaDelCaso/"
              sudo chown $USER:$USER /Casos/ -R 2> /dev/null

            ;;

            7)

              echo ""
              echo "  Extrayendo x..."
              echo ""
              
              sudo chown $USER:$USER /Casos/ -R 2> /dev/null

            ;;

            8)

              echo ""
              echo "  Extrayendo x..."
              echo ""
              sudo chown $USER:$USER /Casos/ -R 2> /dev/null

            ;;

        esac

    done

fi

