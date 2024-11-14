#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# Comprobar si el paquete dialog está instalado. Si no lo está, instalarlo.
  if [[ $(dpkg-query -s dialog 2>/dev/null | grep installed) == "" ]]; then
    echo ""
    echo -e "${cColorRojo}  El paquete dialog no está instalado. Iniciando su instalación...${cFinColor}"
    echo ""
    apt-get -y update && apt-get -y install dialog
    echo ""
  fi

# Crear el menú
  #menu=(dialog --timeout 5 --checklist "Marca las opciones que quieras instalar:" 22 96 16)
  menu=(dialog --checklist "Marca las opciones que quieras instalar:" 22 96 16)
    opciones=(
      1 "Crear las carpetas del caso" on
      2 "Copiar los archivos de registro Windows a la carpeta del caso" off
      3 "Copiar los archivos de registro de todos los usuarios a la carpeta del caso" off
      4 "Parsear los archivos de registro de Windows guardados" off
      5 "Parsear los archivos de registro de todos los usuarios guardados" off
    )
  choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)
  #clear

  for choice in $choices
    do
      case $choice in

        1)

          echo ""
          echo "  Creando las carpetas del caso..."
          echo ""
          # Definir fecha del caso
            vFechaCaso=$(date +a%Ym%md%d@%T)

          # Definir variables
                vCarpetaDeCasos="/Casos"
                vPuntoDeMontaje="/Casos/"$vFechaCaso"/Particiones/2"

              # Determinar el caso actual y crear la carpeta
                rm -rf "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/* 2>/dev/null
                mkdir -p  "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/Original/
  
            ;;

            2)

              echo ""
              echo "  Copiando los archivos de registro Windows a la carpeta del caso..."
              echo ""

              # Copiar archivos de registro
              echo ""
              echo "  Copiando SYSTEM..."
              echo ""
              cp "$vPuntoDeMontaje"/WINDOWS/system32/config/system   "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/Original/SYSTEM
              echo ""
              echo "  Copiando SAM..."
              echo ""
              cp "$vPuntoDeMontaje"/WINDOWS/system32/config/SAM      "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/Original/SAM
              echo ""
              echo "  Copiando SECURITY..."
              echo ""
              cp "$vPuntoDeMontaje"/WINDOWS/system32/config/SECURITY "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/Original/SECURITY
              echo ""
              echo "  Copiando SOFTWARE..."
              echo ""
              cp "$vPuntoDeMontaje"/WINDOWS/system32/config/software "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/Original/SOFTWARE
              echo ""
              echo "  Copiando DEFAULT..."
              echo ""
              cp "$vPuntoDeMontaje"/WINDOWS/system32/config/default  "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/Original/DEFAULT

            ;;

            3)

              echo ""
              echo "  Copiando los archivos de registro de todos los usuarios a la carpeta del caso..."
              echo ""

              # Copiar registro de usuarios
                echo ""
                echo "  Copiando archivos de registro de usuarios..."
                echo ""
                find "$vPuntoDeMontaje/Documents and Settings/" -mindepth 1 -maxdepth 1 -type d > /tmp/CarpetasDeUsuarios.txt
                while IFS= read -r linea; do
                  vNomUsuario="${linea##*/}"
                  echo ""
                  echo "    Copiando NTUSER.DAT de $vNomUsuario..."
                  echo ""
                  mkdir -p "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/Original/"$vNomUsuario"
                  cp "$vPuntoDeMontaje"/"Documents and Settings"/"$vNomUsuario"/NTUSER.DAT "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/Original/"$vNomUsuario"/
                done < "/tmp/CarpetasDeUsuarios.txt"
            ;;

            4)

              echo ""
              echo "  Parseando los archivos de registro de Windows guardados..."
              echo ""

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

              # Exportar registros
                mkdir -p "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/RegRipper/ 2> /dev/null
                echo ""
                echo "  RegRippeando SYSTEM..."
                echo ""
                /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/Original/SYSTEM   -a > "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/RegRipper/SYSTEM.txt
                echo ""
                echo "  RegRippeando SAM..."
                echo ""
                /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/Original/SAM      -a > "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/RegRipper/SAM.txt
                echo ""
                echo "  RegRippeando SECURITY..."
                echo ""
                /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/Original/SECURITY -a > "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/RegRipper/SECURITY.txt
                echo ""
                echo "  RegRippeando SOFTWARE..."
                echo ""
                /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/Original/SOFTWARE -a > "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/RegRipper/SOFTWARE.txt
                echo ""
                echo "  RegRippeando DEFAULT..."
                echo ""
                /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/Original/DEFAULT  -a > "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/RegRipper/DEFAULT.txt

            ;;

            5)

              echo ""
              echo "  Parseando los archivos de registro de todos los usuarios guardados..."
              echo ""

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

              # Exportar registro de usuarios
                echo ""
                echo "  RegRippeando archivos de registro de usuarios..."
                echo ""
                find "$vPuntoDeMontaje/Documents and Settings/" -mindepth 1 -maxdepth 1 -type d > /tmp/CarpetasDeUsuarios.txt
                while IFS= read -r linea; do
                  vNomUsuario="${linea##*/}"
                  echo ""
                  echo "    RegRippeando NTUSER.DAT de $vNomUsuario..."
                  echo ""
                  mkdir -p "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/RegRipper/"$vNomUsuario"/ 2> /dev/null
                  /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/Original/"$vNomUsuario"/NTUSER.DAT  -a > "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/RegRipper/"$vNomUsuario"/NTUSER.DAT.txt
                done < "/tmp/CarpetasDeUsuarios.txt"

            ;;

            5)

              echo ""
              echo "  Parseando los archivos de registro de todos los usuarios guardados..."
              echo ""

              # Reparar permisos
                sudo chown 1000:1000 $vCarpetaDeCasos -R

            ;;

        esac

    done

