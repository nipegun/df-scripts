#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para obtener evidencia forense de un dispositivo
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Evidencia-Disco-Imagen-Volcar.sh | sudo bash -s [Dispositivo] [CarpetaDondeGuardar]  (Ambos sin barra final)
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Evidencia-Disco-Imagen-Volcar.sh | nano -
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

# Comprobar que se hayan pasado la cantidad de parámetros correctos y proceder
  if [ $# -ne $cCantParamEsperados ]
    then
      echo ""
      echo -e "${cColorRojo}  No se han pasado suficientes parámetros al script. El uso correcto sería: ${cFinColor}"
      echo ""
      echo "    Evidencia-Disco-Imagen-Volcar.sh [Dispositivo] [CarpetaDondeGuardar] (Ambos sin barra final)"
      echo ""
      echo "  Ejemplo:"
      echo ""
      echo "    Evidencia-Disco-Imagen-Volcar.sh '/dev/sda' '/home/$USER/Escritorio/Forense/Evidencia/Examen'"
      echo ""
      exit
    else
      # Definir variables
        vDispositivo="$1"
        vCarpetaDondeGuardar="$2"
      # Crear el menú
        # Comprobar si el paquete dialog está instalado. Si no lo está, instalarlo.
          if [[ $(dpkg-query -s dialog 2>/dev/null | grep installed) == "" ]]; then
            echo ""
            echo -e "${cColorRojo}  El paquete dialog no está instalado. Iniciando su instalación...${cFinColor}"
            echo ""
            sudo apt-get -y update && sudo apt-get -y install dialog
            echo ""
          fi
        menu=(dialog --checklist "Marca las opciones que quieras instalar:" 22 96 16)
          opciones=(
            1 "Obtener todo el disco" on
            2 "Obtener la partición 1" off
            3 "Obtener la particion 2" off
            4 "Obtener la partición 3" off
            5 "Obtener la partición 4" off
            6 "Obtener la partición 5" off
            7 "Obtener la particion 6" off
            8 "Obtener la partición 7" off
            9 "Obtener la partición 8" off
          )
        choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)

          for choice in $choices
            do
              case $choice in

                1)

                  echo ""
                  echo "  Obtener todo el disco..."
                  echo ""
                  sudo dd if="$vDispositivo" of="$vCarpetaDondeGuardar"/evidencia.img status=progress

                ;;

                2)

                  echo ""
                  echo "  Obtener la partición 1..."
                  echo ""
                  sudo dd if="$vDispositivo"1 of="$vCarpetaDondeGuardar"/evidencia_p1.img status=progress

                ;;

                3)

                  echo ""
                  echo "  Obtener la partición 2..."
                  echo ""
                  sudo dd if="$vDispositivo"2 of="$vCarpetaDondeGuardar"/evidencia_p2.img status=progress

                ;;

                4)

                  echo ""
                  echo "  Obtener la partición 3..."
                  echo ""
                  sudo dd if="$vDispositivo"3 of="$vCarpetaDondeGuardar"/evidencia_p3.img status=progress

                ;;

                5)

                  echo ""
                  echo "  Obtener la partición 4..."
                  echo ""
                  sudo dd if="$vDispositivo"4 of="$vCarpetaDondeGuardar"/evidencia_p4.img status=progress

                ;;

                6)

                  echo ""
                  echo "  Obtener la partición 5..."
                  echo ""
                  sudo dd if="$vDispositivo"5 of="$vCarpetaDondeGuardar"/evidencia_p5.img status=progress

                ;;

                7)

                  echo ""
                  echo "  Obtener la partición 6..."
                  echo ""
                  sudo dd if="$vDispositivo"6 of="$vCarpetaDondeGuardar"/evidencia_p6.img status=progress

                ;;

                8)

                  echo ""
                  echo "  Obtener la partición 7..."
                  echo ""
                  sudo dd if="$vDispositivo"7 of="$vCarpetaDondeGuardar"/evidencia_p7.img status=progress

                ;;

                9)

                  echo ""
                  echo "  Obtener la partición 8..."
                  echo ""
                  sudo dd if="$vDispositivo"8 of="$vCarpetaDondeGuardar"/evidencia_p8.img status=progress

                ;;

              esac

            done
  
  fi
