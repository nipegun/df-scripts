#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para obtener evidencia forense de un dispositivo
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Evidencia-RAM-Dumpear-Debian.sh | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Evidencia-RAM-Dumpear-Debian.sh | sudo 's-sudo--g' | bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Evidencia-RAM-Dumpear-Debian.sh | nano -
#https://github.com/Abyss-W4tcher/volatility2-profiles/tree/master/Debian/amd64
# Enlace interesante para descargar símbolos: https://github.com/Abyss-W4tcher/volatility3-symbols/
#
# ----------

# Definir constantes de color
  cColorAzul="\033[0;34m"
  cColorAzulClaro="\033[1;34m"
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

# Actualizar lista de paquetes disponibles en los repositorios
  echo ""
  echo "  Actualizando la lista de paquetes disponibles en los repositorios..."
  echo ""
  sudo apt -y update

# Crear el menú
  # Comprobar si el paquete dialog está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s dialog 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${cColorRojo}  El paquete dialog no está instalado. Iniciando su instalación...${cFinColor}"
      echo ""
      sudo apt-get -y update
      sudo apt-get -y install dialog
      echo ""
    fi
  menu=(dialog --checklist "Marca las opciones que quieras instalar:" 22 96 16)
    opciones=(
      1 "Volcar RAM"                                                   off
      2 "Crear archivo Dwarf ..no disponible..."                       off
      3 "Crear JSON con símbolos del Kernel iniciado para Volatility3" off
      4 "Crear perfil para Volatility2"                                off
    )
  choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)
    for choice in $choices
      do
        case $choice in

          1)

            echo ""
            echo "  Dumpeando RAM..."
            echo ""

            # Instalar paquetes necesarios
              echo ""
              echo "    Instalando paquetes necesarios..."
              echo ""
              sudo apt-get -y update
              sudo apt -y install git
              sudo apt -y install build-essential
              sudo apt -y install linux-headers-$(uname -r)

            # Clonar el repo de LiME
              echo ""
              echo "    Clonando el repositorio de LiME..."
              echo ""
              cd ~/
              sudo rm -rf ~/LiME/
              git clone https://github.com/504ensicsLabs/LiME.git

            # Compilar LiME
              echo ""
              echo "    Compilando LiME..."
              echo ""
              cd LiME/src
              sudo make

            # Volcar la RAM
              echo ""
              echo "    Volcando la RAM..."
              echo ""
              sudo insmod lime-$(uname -r).ko "path=/tmp/RAMDump.lime format=raw"

            # Notificar fin del volcado
              if [ -f  /tmp/RAMDump.lime ]; then
                echo ""
                echo "    RAM Volcada al archivo /tmp/RAMDump.lime"
                echo ""
              fi

          ;;

          2)

            echo ""
            echo "  Creando archivo DWARF..."
            echo ""

          ;;

          3)

            echo ""
            echo "  Creando JSON con símbolos del kernel booteado (para Volatility)..."
            echo ""

            # Instalar paquetes necesarios
              sudo apt-get -y update
              sudo apt -y install linux-image-$(uname -r)-dbg
              sudo apt -y install linux-headers-$(uname -r)
              sudo apt -y install dwarfdump
              sudo apt -y install zip
              sudo apt -y install curl
              curl -L https://github.com/volatilityfoundation/dwarf2json/releases/download/v0.9.0/dwarf2json-linux-amd64 -o /tmp/dwarf2json
              chmod +x /tmp/dwarf2json

           # Crear el archivo json con los símbolos del kernel
             echo ""
             echo "    Creando el archivo .json con los símbolos del kernel"
             echo ""
             vVersKernel="$(uname -r)"
             # Kernel en ejecución
               curl https://raw.githubusercontent.com/torvalds/linux/master/scripts/extract-vmlinux -o /tmp/extract-vmlinux
               chmod +x /tmp/extract-vmlinux
               extract-vmlinux /boot/vmlinuz-$vVersKernel > /tmp/kernel
               # Extraer el mapa de símbolos del kernel en ejecución:
                 cat /proc/kallsyms > /tmp/System.map
               # Extraer los módulos cargados:
                 lsmod > /tmp/modules
               /tmp/dwarf2json linux --elf /tmp/kernel --system-map  /tmp/System.map > "/tmp/Debian_$vVersKernel-DeBoot.json"
             # Kernel debug
               /tmp/dwarf2json linux --elf "/usr/lib/debug/boot/vmlinux-$vVersKernel" > "/tmp/Debian_$vVersKernel-DeDebug.json"
               /tmp/dwarf2json linux --elf "/usr/lib/debug/boot/vmlinux-$vVersKernel" --system-map "/usr/lib/debug/boot/System.map-$vVersKernel" > "/tmp/Debian_$vVersKernel-SystemMap-DeDebug.json"

            # Notificar fin de creación de los archívos de símbolos
              echo ""
              echo "  Creación de simbolos para Volatility3, finalizada"
              echo ""
              echo "  Recuerda que puedes descargar perfiles de Volatility2 para Debian aquí:"
              echo ""
              echo "    https://github.com/Abyss-W4tcher/volatility3-symbols/tree/master/Debian/amd64"
              echo ""

          ;;

          4)

            echo ""
            echo "  Creando perfil para Volatility2..."
            echo ""
            sudo apt-get -y update
            sudo apt-get -y install git
            sudo apt-get -y install build-essential
            sudo apt-get -y install linux-headers-$(uname -r)
            sudo apt-get -y install linux-image-$(uname -r)-dbg
            sudo apt-get -y install make
            sudo apt-get -y install zip
            sudo apt-get -y install dwarfdump
            cd /tmp
            git clone https://github.com/volatilityfoundation/volatility.git
            cd volatility/tools/linux
            echo 'MODULE_LICENSE("GPL");' >> module.c
            make
            zip /tmp/Debian_$(uname -r).zip module.dwarf /usr/lib/debug/boot/System.map-&(uname -r)

            echo ""
            echo "  Archivo /tmp/Debian_$(uname -r).zip creado. Deberás meterlo en:"
            echo ""
            echo "    /volatility/plugins/overlays/linux/"
            echo ""
            echo "  Para saber que nombre le ha asignado volatility2 al perfil, ejecuta:"
            echo ""
            echo "    vol.py --info | grep Debian_"
            echo ""
            echo "  Para usar el perfil, ejecuta:"
            echo ""
            echo "    vol.py -f [ArchivoDeDump] --profile=[NombreDelNuevoPerfil] [Plugin]"
            echo ""
            echo "  Recuerda que puedes descargar perfiles de Volatility2 para Debian aquí:"
            echo ""
            echo "    https://github.com/Abyss-W4tcher/volatility2-profiles/tree/master/Debian/amd64"
            echo ""

          ;;

      esac

  done

