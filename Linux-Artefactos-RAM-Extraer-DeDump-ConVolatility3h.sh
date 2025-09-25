#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para extraer artefactos de un dump de RAM de Linux
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Linux-Artefactos-RAM-Extraer-DeDump-ConVolatility3.sh | bash -s [RutaAlArchivoConDump] [CarpetaDondeGuardar]
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Linux-Artefactos-RAM-Extraer-DeDump-ConVolatility3.sh | nano -
#
# Más info aquí:
#  https://volatility3.readthedocs.io/en/latest/
#  https://book.hacktricks.xyz/generic-methodologies-and-resources/basic-forensic-methodology/memory-dump-analysis/volatility-cheatsheet
#
# Descarga de símbolos para Linux:
#  https://github.com/Abyss-W4tcher/volatility3-symbols/
# ----------

cCarpetaVolatility3="$HOME/repos/python/volatility3/"

# Definir constantes de color
  cColorAzul="\033[0;34m"
  cColorAzulClaro="\033[1;34m"
  cColorVerde="\033[1;32m"
  cColorRojo="\033[1;31m"
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor="\033[0m"

# Salir si la cantidad de parámetros pasados no es correcta
  cCantParamEsperados=2
  if [ $# -ne $cCantParamEsperados ]; then
    echo ""
    echo -e "${cColorRojo}  Mal uso del script. El uso correcto sería:${cFinColor}"
    echo ""
    echo "    $0 [RutaAlArchivoConDump] [CarpetaDondeGuardar]"
    echo ""
    echo "      Ejemplo:"
    echo ""
    echo "    $0 ~/Descargas/RAM.dump ~/Escritorio/ArtefactosRAM"
    echo ""
    exit 1
  fi

# Crear constantes para las carpetas
  cRutaAlArchivoDeDump="$1"
  cCarpetaDondeGuardar="$2"
  mkdir -p "$cCarpetaDondeGuardar"

# Crear el menú
  # Comprobar si el paquete dialog está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s dialog 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${cColorRojo}  El paquete dialog no está instalado. Iniciando su instalación...${cFinColor}"
      echo ""
      apt-get -y update
      apt-get -y install dialog
      echo ""
    fi
  menu=(dialog --checklist "Marca los formatos de salida que quieras obtener:" 22 130 16)
    opciones=(
      1 "Comprobar que volatility3 esté instalado"                     on
      2 "  Descargar los símbolos para la versión del kernel obtenida" on
      3 "    Aplicar plugins básicos"                                  on
      4 "    Aplicar plugins de terminales sospechosas y keyloggers"   on
      5 "  Aplicar plugins de módulos"                                 on
      6 "    Extraer todos los módulos listados por los plugins"       off
      7 "  Aplicar plugins básicos de procesos"                        on
      8 "  Aplicar plugins avanzados de procesos"                      off
      9 "  Aplicar plugins de conexiones de red"                       on
     10 "  Aplicar plugins de archivos"                                off
     11 "  Aplicar resto de plugins"                                   off

     15 "  Parsear datos hacia archivos txt"                           off
     16 "  Parsear datos hacia archivos csv"                           off
     17 "  Parsear datos hacia archivos json"                          off
     
     18 "Extraer IPs privadas de clase A"                              off
     19 "Extraer IPs privadas de clase B"                              off
     20 "Extraer IPs privadas de clase C"                              off
     21 "Extraer datos POST de LoginForms"                             off

     22 "Extraer el sistema de carpetas y archivos de dentro del dump" off
    )
  choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)
  #clear

  for choice in $choices
    do
      case $choice in

        1)

          echo ""
          echo "  Comprobando si volatility 3 está instalado..."
          echo ""
          ## Comprobar si existe el repo de volatility3
          #  if [ ! -d ~/repos/python/volatility3/ ]; then
          #    echo ""
          #    echo "  El repo de volatility3 existe. Descargándolo..."
          #    echo ""
          #    mkdir -p ~/repos/python/
          #    cd ~/repos/python/
          #    # Comprobar si el paquete git está instalado. Si no lo está, instalarlo.
          #      if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
          #        echo ""
          #        echo -e "${cColorRojo}  El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
          #        echo ""
          #        sudo apt-get -y update
          #        sudo apt-get -y install git
          #        echo ""
          #      fi
          #    git clone https://github.com/volatilityfoundation/volatility3.git
          #  fi

          ## Comprobar si existe el entorno virtual de python de volatility3
          #  if [ ! -d ~/repos/python/volatility3/venv/ ]; then
          #    echo ""
          #    echo "  El entorno virtual de python de volatility3 no existe. Creándolo..."
          #    echo ""
          #    cd ~/repos/python/volatility3/
          #    python3 -m venv venv
          #  fi
          #
            if [ -d "$cCarpetaVolatility3" ]; then
              echo "    Volatility3 está instalado"
              echo ""
            else
              echo -e "${cColorRojo}    Volatility3 no está instalado. Procediendo a su instalación...${cFinColor}"
              echo ""
              curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/Volatility3-Instalar.sh | bash
            fi

        ;;

        2)

          echo ""
          echo "  Descargando los simbolos para la versión del kernel de la imagen proporcionada..."
          echo ""
          # Entrar en el entorno virtual de volatility
            source ~/repos/python/volatility3/venv/bin/activate
          # Guardar en una variable la versión del kernel
            vVersKernel=$($HOME/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" banners.Banners | sed 's-Linux version -\n-g' | grep gcc | cut -d' ' -f1 | tail -n1)
            echo ""
            echo "    La versión del kernel detectada en la imagen es $vVersKernel"
            echo ""
          # Desgranar la variable y guardar en subdatos
            vKernelArch="$(echo $vVersKernel | rev | cut -d- -f1 | rev)"
            vKernelRama="$(echo $vVersKernel | cut -d'-' -f1)"
            vKernelSubRama="$(echo $vVersKernel | cut -d'-' -f2)"
          # Descargar archivo de símbolos para la imagen detectada
            vArchivoADescargar=$(curl -sL "https://api.github.com/repos/Abyss-W4tcher/volatility3-symbols/contents/Debian/$vKernelArch/$vKernelRama/$vKernelSubRama" | grep -oP '"name":\s*"[^"]+\.json.xz"' | head -n1 | cut -d'"' -f4)
            echo ""
            echo "    Descargando el archivo $vArchivoADescargar..."
            echo ""
            cd ~/repos/python/volatility3/volatility3/symbols/linux/
            curl -L -O https://raw.githubusercontent.com/Abyss-W4tcher/volatility3-symbols/refs/heads/master/Debian/"$vKernelArch"/"$vKernelRama"/"$vKernelSubRama"/"$vArchivoADescargar"
            cd ~
          # Salir del entorno virtual
            deactivate

        ;;

        3)

          echo ""
          echo "  Aplicando plugins básicos..."
          echo ""

          # Crear carpeta para los archivos tabulados
            mkdir -p "$cCarpetaDondeGuardar"/tab 2> /dev/null

          # Entrar en el entorno virtual de python
            source ~/repos/python/volatility3/venv/bin/activate

            # linux.boottime.Boottime (Recupera la hora de arranque del sistema)
              echo ""
              echo "    Aplicando el plugin linux.boottime.Boottime..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.boottime.Boottime > "$cCarpetaDondeGuardar"/tab/linux.boottime.Boottime.tab

            # linux.mountinfo.MountInfo (Extrae info de montajes (/proc/<pid>/mountinfo)
              echo ""
              echo "    Aplicando el plugin linux.mountinfo.MountInfo..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.mountinfo.MountInfo > "$cCarpetaDondeGuardar"/tab/linux.mountinfo.MountInfo.tab

            # linux.bash.Bash (Extrae el historial de comandos de procesos bash encontrados en memoria)
              echo ""
              echo "    Aplicando el plugin linux.bash.Bash..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.bash.Bash > "$cCarpetaDondeGuardar"/tab/linux.bash.Bash.tab

            # linux.envars.Envars (Extrae variables de entorno de procesos)
              echo ""
              echo "    Aplicando el plugin linux.envars.Envars..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.envars.Envars > "$cCarpetaDondeGuardar"/tab/linux.envars.Envars.tab

          # Salir del entorno virtual
            deactivate

        ;;

        4)

          echo ""
          echo "  Aplicando plugins de terminales sospechosas y keyloggers..."
          echo ""

          # Crear carpeta para los archivos tabulados
            mkdir -p "$cCarpetaDondeGuardar"/tab 2> /dev/null

          # Entrar en el entorno virtual de python
            source ~/repos/python/volatility3/venv/bin/activate

            # linux.malware.tty_check.Tty_Check (Busca alteraciones sospechosas en TTYs)
              echo ""
              echo "    Aplicando el plugin linux.malware.tty_check.Tty_Check..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.malware.tty_check.Tty_Check > "$cCarpetaDondeGuardar"/tab/linux.malware.tty_check.Tty_Check.tab

            # linux.malware.keyboard_notifiers.Keyboard_notifiers (Busca hooks de teclado sospechosos (keyloggers))
              echo ""
              echo "    Aplicando el plugin linux.malware.keyboard_notifiers.Keyboard_notifiers..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.malware.keyboard_notifiers.Keyboard_notifiers > "$cCarpetaDondeGuardar"/tab/linux.malware.keyboard_notifiers.Keyboard_notifiers.tab

          # Salir del entorno virtual
            deactivate

        ;;

        5)

          echo ""
          echo "  Aplicando plugins de módulos..."
          echo ""

          # Crear carpeta para los archivos tabulados
            mkdir -p "$cCarpetaDondeGuardar"/tab 2> /dev/null

          # Entrar en el entorno virtual de python
            source ~/repos/python/volatility3/venv/bin/activate

            # linux.lsmod.Lsmod (Lista módulos cargados (similar a lsmod))
              echo ""
              echo "    Aplicando el plugin linux.lsmod.Lsmod..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.lsmod.Lsmod > "$cCarpetaDondeGuardar"/tab/linux.lsmod.Lsmod.tab

            # linux.malware.check_modules.Check_modules (Verifica lista de módulos cargados buscando incoherencias)
              echo ""
              echo "    Aplicando el plugin linux.malware.check_modules.Check_modules..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.malware.check_modules.Check_modules > "$cCarpetaDondeGuardar"/tab/linux.malware.check_modules.Check_modules.tab

            # linux.malware.hidden_modules.Hidden_modules (Detecta módulos ocultos en memoria (rootkits))
              echo ""
              echo "    Aplicando el plugin linux.malware.hidden_modules.Hidden_modules..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.malware.hidden_modules.Hidden_modules > "$cCarpetaDondeGuardar"/tab/linux.malware.hidden_modules.Hidden_modules.tab

            # linux.malware.modxview.Modxview (Detecta módulos que intentan ocultarse de la lista oficial)
              echo ""
              echo "    Aplicando el plugin linux.malware.modxview.Modxview..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.malware.modxview.Modxview > "$cCarpetaDondeGuardar"/tab/linux.malware.modxview.Modxview.tab

          # Salir del entorno virtual
            deactivate

        ;;

        6)

          echo ""
          echo "  Extrayendo todos los módulos listados por los plugins..."
          echo ""

          # Crear carpeta para los archivos tabulados
            mkdir -p "$cCarpetaDondeGuardar"/tab 2> /dev/null

          # Entrar en el entorno virtual de python
            source ~/repos/python/volatility3/venv/bin/activate

              # Crear las carpetas para guardar los módulos
                rm -rf "$cCarpetaDondeGuardar"/modules/ 2> /dev/null
                mkdir -p "$cCarpetaDondeGuardar"/modules/

              # Extraer módulos visibles
                echo ""
                echo "    Extrayendo módulos visibles por el plugin lsmod..."
                echo ""
                # Crear un array con la lista de direcciones de memoria de los módulos listados por lsmod
                  declare -A aModMapLsMod=()
                  cArchivoConListaDeModulos="$cCarpetaDondeGuardar/tab/linux.lsmod.Lsmod.tab"
                  # Leer líneas válidas y poblar el array
                    while IFS=$'\t' read -r vOffset vName _rest; do
                      [[ -z "$vOffset" || -z "$vName" ]] && continue
                      aModMapLsMod["$vName"]="$vOffset"
                    done < <(grep -E '^[0-9]' "$cArchivoConListaDeModulos" || true)
                # Extraer
                  cd "$cCarpetaDondeGuardar"/modules/
                  for vModulo in "${!aModMapLsMod[@]}"; do
                    echo "      Extrayendo el módulo $vModulo de la dirección ${aModMapLsMod[$vModulo]} ..."
                    "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.module_extract.ModuleExtract --base ${aModMapLsMod[$vModulo]} > /dev/null
                  done

              # Extraer módulos ocultos
                echo ""
                echo "    Extrayendo módulos ocultos (visibles por el plugin hidden_modules)..."
                echo ""
                # Crear un array con la lista de direcciones de memoria de los módulos listados hidden_modules
                  declare -A aModMapHidMod=()
                  cArchivoConListaDeModulos="$cCarpetaDondeGuardar/tab/linux.malware.hidden_modules.Hidden_modules.tab"
                  # Leer líneas válidas y poblar el array
                    while IFS=$'\t' read -r vOffset vName _rest; do
                      [[ -z "$vOffset" || -z "$vName" ]] && continue
                      aModMapHidMod["$vName"]="$vOffset"
                    done < <(grep -E '^[0-9]' "$cArchivoConListaDeModulos" || true)
                # Extraer
                  cd "$cCarpetaDondeGuardar"/modules/
                  for vModulo in "${!aModMapHidMod[@]}"; do
                    echo "      Extrayendo el módulo $vModulo de la dirección ${aModMapHidMod[$vModulo]} ..."
                    "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.module_extract.ModuleExtract --base ${aModMapHidMod[$vModulo]} > /dev/null
                  done

              # Corregir nombre a los archivos
                for vArchivo in "$cCarpetaDondeGuardar"/modules/kernel_module.*; do
                  mv "$vArchivo" "$(dirname "$vArchivo")/$(basename "$vArchivo" | sed 's/^kernel_module\.//')";
                done
                for vArchivo in "$cCarpetaDondeGuardar"/modules/*.*.*; do
                  mv "$vArchivo" "$(dirname "$vArchivo")/$(echo "$(basename "$vArchivo")" | sed -E 's/\.[^.]*\.[^.]*$//')";
                done

          # Salir del entorno virtual
            deactivate

        ;;

        7)

          echo ""
          echo "  Aplicando plugins básicos de procesos..."
          echo ""

          # Crear carpeta para los archivos tabulados
            mkdir -p "$cCarpetaDondeGuardar"/tab

          # Entrar en el entorno virtual de python
            source ~/repos/python/volatility3/venv/bin/activate

            # linux.psaux.PsAux (Lista procesos con sus argumentos de línea de comandos (ps aux))
              echo ""
              echo "    Aplicando el plugin linux.psaux.PsAux..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.psaux.PsAux > "$cCarpetaDondeGuardar"/tab/linux.psaux.PsAux.tab

            # linux.pslist.PsList (Lista procesos activos según las estructuras enlazadas (task_struct))
              echo ""
              echo "    Aplicando el plugin linux.pslist.PsList..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.pslist.PsList > "$cCarpetaDondeGuardar"/tab/linux.pslist.PsList.tab

            # linux.psscan.PsScan (Escanea memoria buscando estructuras de procesos, incluso terminados u ocultos)
              echo ""
              echo "    Aplicando el plugin linux.psscan.PsScan..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.psscan.PsScan > "$cCarpetaDondeGuardar"/tab/linux.psscan.PsScan.tab

            # linux.pstree.PsTree (Muestra procesos en formato jerárquico (árbol padre-hijo))
              echo ""
              echo "    Aplicando el plugin linux.pstree.PsTree..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.pstree.PsTree > "$cCarpetaDondeGuardar"/tab/linux.pstree.PsTree.tab

          # Salir del entorno virtual
            deactivate

        ;;

        8)

          echo ""
          echo "  Aplicando plugins avanzados de procesos..."
          echo ""

          # Crear carpeta para los archivos tabulados
            mkdir -p "$cCarpetaDondeGuardar"/tab

          # Entrar en el entorno virtual de python
            source ~/repos/python/volatility3/venv/bin/activate

            # linux.pscallstack.PsCallStack (Muestra el stack de llamadas de procesos)
              echo ""
              echo "    Aplicando el plugin linux.pscallstack.PsCallStack..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.pscallstack.PsCallStack > "$cCarpetaDondeGuardar"/tab/linux.pscallstack.PsCallStack.tab

# !! >>     # linux.proc.Maps (Extrae el mapeo de memoria de procesos (/proc/<pid>/maps))
              echo ""
              echo "    Aplicando el plugin linux.proc.Maps..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.proc.Maps > "$cCarpetaDondeGuardar"/tab/linux.proc.Maps.tab
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.proc.Maps --pid 38825 > "$cCarpetaDondeGuardar"/tab/linux.proc.Maps-PID38825.tab

            # linux.ptrace.Ptrace (Enumera procesos que usan/reciben ptrace)
              echo ""
              echo "    Aplicando el plugin linux.ptrace.Ptrace..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.ptrace.Ptrace > "$cCarpetaDondeGuardar"/tab/linux.ptrace.Ptrace.tab

            # linux.malware.check_creds.Check_creds (Valida estructuras de credenciales en procesos)
              echo ""
              echo "    Aplicando el plugin linux.malware.check_creds.Check_creds..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.malware.check_creds.Check_creds > "$cCarpetaDondeGuardar"/tab/linux.malware.check_creds.Check_creds.tab

            # linux.pidhashtable.PIDHashTable (Lista procesos a partir de la PID hash table)
              echo ""
              echo "    Aplicando el plugin linux.pidhashtable.PIDHashTable..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.pidhashtable.PIDHashTable > "$cCarpetaDondeGuardar"/tab/linux.pidhashtable.PIDHashTable.tab

# !! >>     # linux.capabilities.Capabilities (Lista capacidades de seguridad asignadas a procesos (Linux capabilities)
              echo ""
              echo "    Aplicando el plugin linux.capabilities.Capabilities..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.capabilities.Capabilities > "$cCarpetaDondeGuardar"/tab/linux.capabilities.Capabilities.tab

          # Salir del entorno virtual
            deactivate

        ;;

        9)

          echo ""
          echo "  Aplicando plugins de red..."
          echo ""

          # Crear carpeta para los archivos tabulados
            mkdir -p "$cCarpetaDondeGuardar"/tab

          # Entrar en el entorno virtual de python
            source ~/repos/python/volatility3/venv/bin/activate

            # linux.ip.Addr (Lista direcciones IP asociadas a interfaces de red)
              echo ""
              echo "    Aplicando el plugin linux.ip.Addr..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.ip.Addr > "$cCarpetaDondeGuardar"/tab/linux.ip.Addr.tab

            # linux.ip.Link (Lista interfaces de red)
              echo ""
              echo "    Aplicando el plugin linux.ip.Link..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.ip.Link > "$cCarpetaDondeGuardar"/tab/linux.ip.Link.tab

            # linux.malware.netfilter.Netfilter (Busca hooks en Netfilter usados para ocultar tráfico)
              echo ""
              echo "    Aplicando el plugin linux.malware.netfilter.Netfilter..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.malware.netfilter.Netfilter > "$cCarpetaDondeGuardar"/tab/linux.malware.netfilter.Netfilter.tab

            # linux.sockstat.Sockstat (Extrae información de sockets en memoria)
              echo ""
              echo "    Aplicando el plugin linux.sockstat.Sockstat..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.sockstat.Sockstat > "$cCarpetaDondeGuardar"/tab/linux.sockstat.Sockstat.tab

          # Salir del entorno virtual
            deactivate

        ;;

       10)

          echo ""
          echo "  Aplicando plugins de archivos..."
          echo ""

          # Crear carpeta para los archivos tabulados
            mkdir -p "$cCarpetaDondeGuardar"/tab

          # Entrar en el entorno virtual de python
            source ~/repos/python/volatility3/venv/bin/activate

            # linux.pagecache.Files (Recupera archivos almacenados en el page cache)
              echo ""
              echo "    Aplicando el plugin linux.pagecache.Files..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.pagecache.Files > "$cCarpetaDondeGuardar"/tab/linux.pagecache.Files.tab

            # linux.lsof.Lsof
              # Recorre los procesos y lista los file descriptors y los ficheros/mappings asociados (rutas, inodos, sockets, mapped ELF, archivos borrados en uso, etc.))
              # Sirve para ver qué archivos y sockets tenía abierto cada proceso en el volcado de memoria.
              # Muy útil para detectar handles a ficheros borrados, conexiones de red abiertas por procesos sospechosos o módulos/mappings mapeados en memoria.
              echo ""
              echo "    Aplicando el plugin linux.lsof.Lsof..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.lsof.Lsof > "$cCarpetaDondeGuardar"/tab/linux.lsof.Lsof.tab

            # linux.elfs.Elfs (Localiza y extrae binarios ELF de memoria)
              echo ""
              echo "    Aplicando el plugin linux.elfs.Elfs..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.elfs.Elfs > "$cCarpetaDondeGuardar"/tab/linux.elfs.Elfs.tab

# !! >>     # linux.pagecache.InodePages (Lista inodos en el page cache)
              echo ""
              echo "    Aplicando el plugin linux.pagecache.InodePages..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.pagecache.InodePages --inode x
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.pagecache.InodePages --find x

            # linux.pagecache.RecoverFs (Reconstruye y extrae archivos que estaban en la cache de página (page cache) y en tmpfs)
              echo ""
              echo "    Aplicando el plugin linux.pagecache.RecoverFs..."
              echo ""
              mkdir -p "$cCarpetaDondeGuardar"/recovered_fs/ 2> /dev/null
              cd "$cCarpetaDondeGuardar"/recovered_fs/
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.pagecache.RecoverFs > "$cCarpetaDondeGuardar"/tab/linux.pagecache.RecoverFs.tab
              # Re-crear el sistema de archivos del disco
                echo ""
                echo "    Re-creando el sistema de archivos del disco..."
                echo ""
                # Extraer el contenido del archivo recovered_fs.tar.gz
                  tar -xzf recovered_fs.tar.gz
                # Unificar carpetas
                  vCarpetaDestino="$cCarpetaDondeGuardar/recovered_fs/../hd"
                  for vCarpeta in "$cCarpetaDondeGuardar"/recovered_fs/*; do
                    # Saltar la carpeta destino si ya existe
                      [ "$vCarpeta" = "$vCarpetaDestino" ] && continue
                      [ -d "$vCarpeta" ] || continue
                    # Mover contenido dentro de la carpeta destino
                     rsync -a "$vCarpeta"/ "$vCarpetaDestino"/
                  done
                # Eliminar carpeta recovered_fs
                  cd "$cCarpetaDondeGuardar"
                  rm -rf "$cCarpetaDondeGuardar"/recovered_fs/ 2> /dev/null
                # Eliminar carpetas vacías recursivamente dentro de hd
                  echo "Eliminando carpetas vacías..."
                  find "$cCarpetaDondeGuardar"/hd/ -type d -empty -delete

          # Salir del entorno virtual
            deactivate

        ;;

       11)

          echo ""
          echo "  Aplicando resto de plugins..."
          echo ""

          # Crear carpeta para los archivos tabulados
            mkdir -p "$cCarpetaDondeGuardar"/tab

          # Entrar en el entorno virtual de python
            source ~/repos/python/volatility3/venv/bin/activate

          # Kernel

            # linux.kmsg.Kmsg (Recupera mensajes del log del kernel (dmesg))
              echo ""
              echo "    Aplicando el plugin linux.kmsg.Kmsg..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.kmsg.Kmsg > "$cCarpetaDondeGuardar"/tab/linux.kmsg.Kmsg.tab

            # linux.ebpf.EBPF (Lista programas eBPF cargados en el kernel)
              echo ""
              echo "    Aplicando el plugin linux.ebpf.EBPF..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.ebpf.EBPF > "$cCarpetaDondeGuardar"/tab/linux.ebpf.EBPF.tab

            # linux.malware.check_idt.Check_idt (Revisa la tabla de interrupciones del kernel (detectar hooks))
              echo ""
              echo "    Aplicando el plugin linux.malware.check_idt.Check_idt..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.malware.check_idt.Check_idt > "$cCarpetaDondeGuardar"/tab/linux.malware.check_idt.Check_idt.tab

            # linux.malware.check_afinfo.Check_afinfo (Revisa hooks de la tabla afinfo (posibles rootkits))
              echo ""
              echo "    Aplicando el plugin linux.malware.check_afinfo.Check_afinfo..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.malware.check_afinfo.Check_afinfo > "$cCarpetaDondeGuardar"/tab/linux.malware.check_afinfo.Check_afinfo.tab

            # linux.kthreads.Kthreads (Lista hilos del kernel (kthreads))
              echo ""
              echo "    Aplicando el plugin linux.kthreads.Kthreads..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.kthreads.Kthreads > "$cCarpetaDondeGuardar"/tab/linux.kthreads.Kthreads.tab

            # linux.malware.check_syscall.Check_syscall (Inspecciona la tabla de syscalls buscando redirecciones sospechosas)
              echo ""
              echo "    Aplicando el plugin linux.malware.check_syscall.Check_syscall..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.malware.check_syscall.Check_syscall > "$cCarpetaDondeGuardar"/tab/linux.malware.check_syscall.Check_syscall.tab

# !! >>     # linux.kallsyms.Kallsyms (Extrae la tabla de símbolos del kernel (/proc/kallsyms))
              echo ""
              echo "    Aplicando el plugin linux.kallsyms.Kallsyms..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.kallsyms.Kallsyms > "$cCarpetaDondeGuardar"/tab/linux.kallsyms.Kallsyms.tab

          # Librerías

            # linux.library_list.LibraryList (Extrae librerías cargadas por procesos)
              echo ""
              echo "    Aplicando el plugin linux.library_list.LibraryList..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.library_list.LibraryList > "$cCarpetaDondeGuardar"/tab/linux.library_list.LibraryList.tab

          # Memoria

            # linux.vmcoreinfo.VMCoreInfo (Muestra datos de la estructura vmcoreinfo)
              echo ""
              echo "    Aplicando el plugin linux.vmcoreinfo.VMCoreInfo..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.vmcoreinfo.VMCoreInfo > "$cCarpetaDondeGuardar"/tab/linux.vmcoreinfo.VMCoreInfo.tab

            # linux.malware.malfind.Malfind (Busca regiones de memoria sospechosas (ejecución inyectada))
              echo ""
              echo "    Aplicando el plugin linux.malware.malfind.Malfind..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.malware.malfind.Malfind > "$cCarpetaDondeGuardar"/tab/linux.malware.malfind.Malfind.tab

            # linux.iomem.IOMem (Muestra rangos de memoria I/O mapeados)
              echo ""
              echo "    Aplicando el plugin linux.iomem.IOMem..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.iomem.IOMem > "$cCarpetaDondeGuardar"/tab/linux.iomem.IOMem.tab

# !! >>     # linux.vmaregexscan.VmaRegExScan (Escanea regiones de memoria con regex)
              echo ""
              echo "    Aplicando el plugin linux.vmaregexscan.VmaRegExScan..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.vmaregexscan.VmaRegExScan --patern x > "$cCarpetaDondeGuardar"/tab/linux.vmaregexscan.VmaRegExScan.tab

            # linux.vmayarascan.VmaYaraScan (Escanea memoria con reglas YARA)
              echo ""
              echo "    Aplicando el plugin linux.vmayarascan.VmaYaraScan..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.vmayarascan.VmaYaraScan > "$cCarpetaDondeGuardar"/tab/linux.vmayarascan.VmaYaraScan.tab


            # linux.graphics.fbdev.Fbdev (Extrae contenido de framebuffers (pantallas virtuales/consolas gráficas))
              echo ""
              echo "    Aplicando el plugin linux.graphics.fbdev.Fbdev..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.graphics.fbdev.Fbdev > "$cCarpetaDondeGuardar"/tab/linux.graphics.fbdev.Fbdev.tab


            # linux.tracing.ftrace.CheckFtrace (Verifica integridad de ftrace)
              echo ""
              echo "    Aplicando el plugin linux.tracing.ftrace.CheckFtrace..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.tracing.ftrace.CheckFtrace > "$cCarpetaDondeGuardar"/tab/linux.tracing.ftrace.CheckFtrace.tab

            # linux.tracing.perf_events.PerfEvents (Lista eventos de perf)
              echo ""
              echo "    Aplicando el plugin linux.tracing.perf_events.PerfEvents..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.tracing.perf_events.PerfEvents > "$cCarpetaDondeGuardar"/tab/linux.tracing.perf_events.PerfEvents.tab

            # linux.tracing.tracepoints.CheckTracepoints (Verifica tracepoints del kernel)
              echo ""
              echo "    Aplicando el plugin linux.tracing.tracepoints.CheckTracepoints..."
              echo ""
              "$HOME"/repos/python/volatility3/vol.py -q -f "$cRutaAlArchivoDeDump" -s /home/nipegun/repos/python/volatility3/volatility3/symbols linux.tracing.tracepoints.CheckTracepoints > "$cCarpetaDondeGuardar"/tab/linux.tracing.tracepoints.CheckTracepoints.tab

          # Salir del entorno virtual
            deactivate

        ;;

       15)

          echo ""
          echo "  Parseando hacia archivos txt..."
          echo ""

          # Entrar en el entorno virtual de python
            source ~/repos/python/volatility3/venv/bin/activate

          # Parsear datos

            # Crear carpeta
              mkdir -p "$cCarpetaDondeGuardar"/txt

            # windows.amcache (Extract information on executed applications from the AmCache)
              echo ""
              echo "    Aplicando el plugin windows.amcache..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.amcache | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.amcache.txt

            # windows.bigpools (List big page pools)
              # Argumentos:
              #   --tags TAGS - Comma separated list of pool tags to filter pools returned
              #   --show-free - Show freed regions (otherwise only show allocations in use)
              echo ""
              echo "    Aplicando el plugin windows.bigpools..."
              echo ""
              # En uso
                vol -r pretty -f "$cRutaAlArchivoDeDump" windows.bigpools             | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.bigpools-enuso.txt
              # En uso y libres
                vol -r pretty -f "$cRutaAlArchivoDeDump" windows.bigpools --show-free | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.bigpools-enusoylibres.txt

            # windows.callbacks (Lists kernel callbacks and notification routines)
              echo ""
              echo "    Aplicando el plugin windows.callbacks..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.callbacks | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.callbacks.txt

            # windows.cmdline (Lists process command line arguments)
              # Argumentos:
              #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
              echo ""
              echo "    Aplicando el plugin windows.cmdline..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.cmdline | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.cmdline.txt

            # windows.cmdscan (Looks for Windows Command History lists)
              # Argumentos:
              #   --no-registry                   - Don't search the registry for possible values of CommandHistorySize
              #   --max-history [MAX_HISTORY ...] - CommandHistorySize values to search for.
              echo ""
              echo "    Aplicando el plugin windows.cmdscan..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.cmdscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.cmdscan.txt

            # windows.consoles (Looks for Windows console buffers)
              # Argumentos:
              #   --no-registry                   - Don't search the registry for possible values of CommandHistorySize and HistoryBufferMax
              #   --max-history [MAX_HISTORY ...] - CommandHistorySize values to search for.
              #   --max-buffers [MAX_BUFFERS ...] - HistoryBufferMax values to search for.
              echo ""
              echo "    Aplicando el plugin windows.consoles..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.consoles | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.consoles.txt

            # windows.crashinfo (Lists the information from a Windows crash dump)
              echo ""
              echo "    Aplicando el plugin windows.crashinfo..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.crashinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.crashinfo.txt

            # windows.debugregisters ()
              echo ""
              echo "    Aplicando el plugin windows.debugregisters..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.debugregisters | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.debugregisters.txt

            # windows.devicetree (Listing tree based on drivers and attached devices in a particular windows memory image)
              echo ""
              echo "    Aplicando el plugin windows.devicetree..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.devicetree | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.devicetree.txt

            # windows.dlllist (Lists the loaded modules in a particular windows memory image)
              # Argumentos:
              #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
              #   --offset OFFSET - Process offset in the physical address space
              #   --name NAME     - Specify a regular expression to match dll name(s)
              #   --base BASE     - Specify a base virtual address in process memory
              #   --ignore-case   - Specify case insensitivity for the regular expression name matching
              #   --dump          - Extract listed DLLs
              echo ""
              echo "    Aplicando el plugin windows.dlllist..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.dlllist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.dlllist.txt
              #vol -f "$cRutaAlArchivoDeDump" windows.dlllist ‑‑pid "<PID>"

            # windows.driverirp (List IRPs for drivers in a particular windows memory image)
              echo ""
              echo "    Aplicando el plugin windows.driverirp..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.driverirp | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.driverirp.txt

            # windows.drivermodule (Determines if any loaded drivers were hidden by a rootkit)
              echo ""
              echo "    Aplicando el plugin windows.drivermodule..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.drivermodule | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.drivermodule.txt

            # windows.driverscan (Scans for drivers present in a particular windows memory image)
              echo ""
              echo "    Aplicando el plugin windows.driverscan..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.driverscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.driverscan.txt

            # windows.envars (Display process environment variables)
              # Argumentos:
              #   --pid [PID ...] - Filter on specific process IDs
              #   --silent        - Suppress common and non-persistent variables
              echo ""
              echo "    Aplicando el plugin windows.envars..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.envars | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.envars.txt

            # windows.filescan (Scans for file objects present in a particular windows memory image)
              echo ""
              echo "    Aplicando el plugin windows.filescan..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.filescan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.filescan.txt

            # windows.getservicesids (Lists process token sids)
              echo ""
              echo "    Aplicando el plugin windows.getservicesids..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.getservicesids | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.getservicesids.txt

            # windows.getsids (Print the SIDs owning each process)
              # Argumentos:
              #   --pid [PID ...] - Filter on specific process IDs
              echo ""
              echo "    Aplicando el plugin windows.getsids..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.getsids | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.getsids.txt

            # windows.handles (Lists process open handles)
              # Argumentos:
              #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
              #   --offset OFFSET - Process offset in the physical address space
              echo ""
              echo "    Aplicando el plugin windows.handles..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.handles | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.handles.txt
              #vol -f "$cRutaAlArchivoDeDump" windows.handles ‑‑pid "<PID>"

            # windows.hashdump (Dumps user hashes from memory)
              echo ""
              echo "    Aplicando el plugin windows.hashdump..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.hashdump | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.hashdump.txt

            # windows.hollowprocesses (Lists hollowed processes)
              # Argumentos:
              #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
              echo ""
              echo "    Aplicando el plugin windows.hollowprocesses..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.hollowprocesses | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.hollowprocesses.txt

            # windows.iat (Extract Import Address Table to list API (functions) used by a program contained in external libraries)
              # Argumentos:
              #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
              echo ""
              echo "    Aplicando el plugin windows.iat..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.iat | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.iat.txt

            # windows.info (Show OS & kernel details of the memory sample being analyzed)
              echo ""
              echo "    Aplicando el plugin windows.info..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.info | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.info.txt

            # windows.joblinks (Print process job link information)
             # Argumentos:
              #   --physical - Display physical offset instead of virtual
              echo ""
              echo "    Aplicando el plugin windows.joblinks..."
              echo ""
              # Offset virtual
                vol -r pretty -f "$cRutaAlArchivoDeDump" windows.joblinks            | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.joblinks-offsetvirtual.txt
              # Offset físico
                vol -r pretty -f "$cRutaAlArchivoDeDump" windows.joblinks --physical | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.joblinks-offsetfisico.txt


            # windows.kpcrs (Print KPCR structure for each processor)
              echo ""
              echo "    Aplicando el plugin windows.kpcrs..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.kpcrs | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.kpcrs.txt

            # windows.ldrmodules (Lists the loaded modules in a particular windows memory image)
              # Argumentos:
              #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
              echo ""
              echo "    Aplicando el plugin windows.ldrmodules..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.ldrmodules | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.ldrmodules.txt

            # windows.malfind (Lists process memory ranges that potentially contain injected code)
              echo ""
              echo "    Aplicando el plugin windows.malfind..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.malfind | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.malfind.txt

            # windows.mbrscan (Scans for and parses potential Master Boot Records (MBRs))
              # Argumentos:
              #   --full - It analyzes and provides all the information in the partition entry and bootcode hexdump. (It returns a lot of information, so we recommend you render it in CSV.)
              echo ""
              echo "    Aplicando el plugin windows.mbrscan..."
              echo ""
              # Simple
                vol -r pretty -f "$cRutaAlArchivoDeDump" windows.mbrscan        | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.mbrscan.txt
              # Completo
                vol -r pretty -f "$cRutaAlArchivoDeDump" windows.mbrscan --full | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.mbrscan-full.txt

            # windows.memmap (Prints the memory map)
              # Argumentos:
              #   --pid PID - Process ID to include (all other processes are excluded)
              #   --dump    - Extract listed memory segments
              echo ""
              echo "    Aplicando el plugin windows.memmap..."
              echo ""
              #vol -r pretty -f "$cRutaAlArchivoDeDump" windows.memmap | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.memmap.txt
              #vol -f "$cRutaAlArchivoDeDump" -o "/path/to/dir" windows.memmap ‑‑dump ‑‑pid "<PID>"

            # windows.modscan (Scans for modules present in a particular windows memory image)
              # Argumentos:
              #   --dump      - Extract listed modules
              #   --base BASE - Extract a single module with BASE address
              #   --name NAME - module name/sub string
              echo ""
              echo "    Aplicando el plugin windows.modscan..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.modscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.modscan.txt

            # windows.modules (Lists the loaded kernel modules)
              # Argumentos:
              #   --dump      - Extract listed modules
              #   --base BASE - Extract a single module with BASE address
              #   --name NAME - module name/sub string
              echo ""
              echo "    Aplicando el plugin windows.modules..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.modules | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.modules.txt

            # windows.mutantscan (Scans for mutexes present in a particular windows memory image)
              echo ""
              echo "    Aplicando el plugin windows.mutantscan..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.mutantscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.mutantscan.txt

            # windows.netscan (Scans for network objects present in a particular windows memory image)
              # Argumentos:
              #   --include-corrupt - Radically eases result validation. This will show partially overwritten data. WARNING: the results are likely to include garbage and/or corrupt data. Be cautious!
              echo ""
              echo "    Aplicando el plugin windows.netscan..."
              echo ""
              # Sin corruptos
                vol -r pretty -f "$cRutaAlArchivoDeDump" windows.netscan                   | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.netscan.txt
              # Con corruptos
                vol -r pretty -f "$cRutaAlArchivoDeDump" windows.netscan --include-corrupt | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.netscan-corrupt.txt

            # windows.netstat (Traverses network tracking structures present in a particular windows memory image)
              # Argumentos:
              #   --include-corrupt - Radically eases result validation. This will show partially overwritten data. WARNING: the results are likely to include garbage and/or corrupt data. Be cautious!
              echo ""
              echo "    Aplicando el plugin windows.netstat..."
              echo ""
              # Sin corruptos
                vol -r pretty -f "$cRutaAlArchivoDeDump" windows.netstat                   | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.netstat.txt
              # Con corruptos
                vol -r pretty -f "$cRutaAlArchivoDeDump" windows.netstat --include-corrupt | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.netstat-corrupt.txt

            # windows.orphan_kernel_threads (Lists process threads)
              echo ""
              echo "    Aplicando el plugin windows.orphan_kernel_threads..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.orphan_kernel_threads | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.orphan_kernel_threads.txt

            # windows.pe_symbols (Prints symbols in PE files in process and kernel memory)
              # Argumentos:
              #   --source {kernel,processes} - Where to resolve symbols.
              #   --module MODULE             - Module in which to resolve symbols. Use "ntoskrnl.exe" to resolve in the base kernel executable.
              #   --symbols [SYMBOLS ...]     - Symbol name to resolve
              #   --addresses [ADDRESSES ...] - Address of symbol to resolve
              echo ""
              echo "    Aplicando el plugin windows.pe_symbols..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.pe_symbols | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.pe_symbols.txt

            # windows.pedump (Allows extracting PE Files from a specific address in a specific address space)
              # Argumentos:
              #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
              #   --base BASE     - Base address to reconstruct a PE file
              #   --kernel-module - Extract from kernel address space.
              echo ""
              echo "    Aplicando el plugin windows.pedump..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.pedump | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.pedump.txt

            # windows.poolscanner (A generic pool scanner plugin)
              echo ""
              echo "    Aplicando el plugin windows.poolscanner..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.poolscanner | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.poolscanner.txt

            # windows.privileges (Lists process token privileges)
              # Argumentos:
              #   --pid [PID ...] - Filter on specific process IDs
              echo ""
              echo "    Aplicando el plugin windows.privileges..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.privileges | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.privileges.txt

            # windows.processghosting (Lists processes whose DeletePending bit is set or whose FILE_OBJECT is set to 0)
              echo ""
              echo "    Aplicando el plugin windows.processghosting..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.processghosting | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.processghosting.txt

            # windows.pslist (Lists the processes present in a particular windows memory image)
              # Argumentos:
              #   --physical      - Display physical offsets instead of virtual
              #   --pid [PID ...] - Process ID to include (all other processes are excluded)
              #   --dump          - Extract listed processes
              echo ""
              echo "    Aplicando el plugin windows.pslist..."
              echo ""
              # Offset virtual
                vol -r pretty -f "$cRutaAlArchivoDeDump" windows.pslist            | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.pslist-offsetvirtual.txt
              # Offset físico
                vol -r pretty -f "$cRutaAlArchivoDeDump" windows.pslist --physical | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.pslist-offsetfisico.txt

            # windows.psscan (Scans for processes present in a particular windows memory image)
              # Argumentos:
              #   --physical      - Display physical offsets instead of virtual
              #   --pid [PID ...] - Process ID to include (all other processes are excluded)
              #   --dump          - Extract listed processes
              echo ""
              echo "    Aplicando el plugin windows.psscan..."
              echo ""
              # Offset virtual
                vol -r pretty -f "$cRutaAlArchivoDeDump" windows.psscan            | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.psscan-offsetvirtual.txt
              # Offset físico
                vol -r pretty -f "$cRutaAlArchivoDeDump" windows.psscan --physical | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.psscan-offsetfisico.txt

            # windows.pstree (Plugin for listing processes in a tree based on their parent process ID)
              # Argumentos:
              #   --physical      - Display physical offsets instead of virtual
              #   --pid [PID ...] - Process ID to include (all other processes are excluded)
              echo ""
              echo "    Aplicando el plugin windows.pstree..."
              echo ""
              # Offset virtual
                vol -r pretty -f "$cRutaAlArchivoDeDump" windows.pstree            | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.pstree-offsetvirtual.txt
              # Offset físico
                vol -r pretty -f "$cRutaAlArchivoDeDump" windows.pstree --physical | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.pstree-offsetfisico.txt

            # windows.psxview (Lists all processes found via four of the methods described in "The Art of Memory Forensics," which may help identify processes that are trying to hide themselves. I recommend using -r pretty if you are looking at this plugin's output in a terminal)
              # Argumentos:
              # --physical-offsets - List processes with physical offsets instead of virtual offsets.
              echo ""
              echo "    Aplicando el plugin windows.psxview..."
              echo ""
              # Offsets virtuales
                vol -r pretty -f "$cRutaAlArchivoDeDump" windows.psxview                    | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.psxview-offsetsvirtuales.txt
              # Offsets físicos
                vol -r pretty -f "$cRutaAlArchivoDeDump" windows.psxview --physical-offsets | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.psxview-offsetsfisicos.txt

            # windows.registry.certificates (Lists the certificates in the registry's Certificate Store)
              # Argumentos:
              #   --dump - Extract listed certificates
              echo ""
              echo "    Aplicando el plugin windows.registry.certificates..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.registry.certificates | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.registry.certificates.txt

            # windows.registry.getcellroutine (Reports registry hives with a hooked GetCellRoutine handler)
              echo ""
              echo "    Aplicando el plugin windows.registry.getcellroutine..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.registry.getcellroutine | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.registry.getcellroutine.txt

            # windows.registry.hivelist (Lists the registry hives present in a particular memory image)
              # Argumentos:
              #   --filter FILTER - String to filter hive names returned
              #   --dump          - Extract listed registry hives
              echo ""
              echo "    Aplicando el plugin windows.registry.hivelist..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.registry.hivelist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.registry.hivelist.txt

            # windows.registry.hivescan (Scans for registry hives present in a particular windows memory image)
              echo ""
              echo "    Aplicando el plugin windows.registry.hivescan..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.registry.hivescan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.registry.hivescan.txt

            # windows.registry.printkey (Lists the registry keys under a hive or specific key value)
              # Argumentos:
              #   --offset OFFSET - Hive Offset
              #   --key KEY       - Key to start from
              #   --recurse       - Recurses through keys
              echo ""
              echo "    Aplicando el plugin windows.registry.printkey..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.registry.printkey | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.registry.printkey.txt
              #vol -f "$cRutaAlArchivoDeDump" windows.registry.printkey ‑‑key "Software\Microsoft\Windows\CurrentVersion" | grep -v "Volatility 3"

            # windows.registry.userassist (Print userassist registry keys and information)
              # Argumentos:
              #   --offset OFFSET - Hive Offset
              echo ""
              echo "    Aplicando el plugin windows.registry.userassist..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.registry.userassist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.registry.userassist.txt

            # windows.scheduled_tasks (Decodes scheduled task information from the Windows registry, including information about triggers, actions, run times, and creation times)
              echo ""
              echo "    Aplicando el plugin windows.scheduled_tasks..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.scheduled_tasks | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.scheduled_tasks.txt

            # windows.sessions (lists Processes with Session information extracted from Environmental Variables)
              # Argumentos:
              #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
              echo ""
              echo "    Aplicando el plugin windows.sessions..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.sessions | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.sessions.txt

            # windows.shimcachemem (Reads Shimcache entries from the ahcache.sys AVL tree)
              echo ""
              echo "    Aplicando el plugin windows.shimcachemem..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.shimcachemem | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.shimcachemem.txt

            # windows.skeleton_key_check (Looks for signs of Skeleton Key malware)
              echo ""
              echo "    Aplicando el plugin windows.skeleton_key_check..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.skeleton_key_check | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.skeleton_key_check.txt

            # windows.ssdt (Lists the system call table)
              echo ""
              echo "    Aplicando el plugin windows.ssdt..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.ssdt | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.ssdt.txt

            # windows.statistics (Lists statistics about the memory space)
              echo ""
              echo "    Aplicando el plugin windows.statistics..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.statistics | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.statistics.txt

            # windows.strings (Reads output from the strings command and indicates which process(es) each string belongs to)
              # Argumentos:
              #   --pid [PID ...]             - Process ID to include (all other processes are excluded)
              #   --strings-file STRINGS_FILE - Strings file
              echo ""
              echo "    Aplicando el plugin windows.strings..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.strings | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.strings.txt

            # windows.suspicious_threads (Lists suspicious userland process threads)
              # Argumentos:
              #   --pid [PID ...] - Filter on specific process IDs
              echo ""
              echo "    Aplicando el plugin windows.suspicious_threads..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.suspicious_threads | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.suspicious_threads.txt

            # windows.svcdiff (Compares services found through list walking versus scanning to find rootkits)
              echo ""
              echo "    Aplicando el plugin windows.svcdiff..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.svcdiff | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.svcdiff.txt

            # windows.svclist (Lists services contained with the services.exe doubly linked list of services)
              echo ""
              echo "    Aplicando el plugin windows.svclist..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.svclist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.svclist.txt

            # windows.svcscan (Scans for windows services)
              echo ""
              echo "    Aplicando el plugin windows.svcscan..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.svcscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.svcscan.txt

            # windows.symlinkscan (Scans for links present in a particular windows memory image)
              echo ""
              echo "    Aplicando el plugin windows.symlinkscan..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.symlinkscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.symlinkscan.txt

            # windows.thrdscan (Scans for windows threads)
              echo ""
              echo "    Aplicando el plugin windows.thrdscan..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.thrdscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.thrdscan.txt

            # windows.threads (Lists process threads)
              # Argumentos:
              #   --pid [PID ...] - Filter on specific process IDs
              echo ""
              echo "    Aplicando el plugin windows.threads..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.threads | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.threads.txt

            # windows.timers (Print kernel timers and associated module DPCs)
              echo ""
              echo "    Aplicando el plugin windows.timers..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.timers | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.timers.txt

            # windows.truecrypt (TrueCrypt Cached Passphrase Finder)
              # Argumentos:
              #   --min-length MIN-LENGTH - Minimum length of passphrases to identify
              echo ""
              echo "    Aplicando el plugin windows.truecrypt..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.truecrypt | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.truecrypt.txt

            # windows.unhooked_system_calls (Looks for signs of Skeleton Key malware)
              echo ""
              echo "    Aplicando el plugin windows.unhooked_system_calls..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.unhooked_system_calls | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.unhooked_system_calls.txt

            # windows.unloadedmodules (Lists the unloaded kernel modules)
              echo ""
              echo "    Aplicando el plugin windows.unloadedmodules..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.unloadedmodules | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.unloadedmodules.txt

            # windows.vadinfo (Lists process memory ranges)
              # Argumentos:
              #   --address ADDRESS - Process virtual memory address to include (all other address ranges are excluded).
              #   --pid [PID ...]   - Filter on specific process IDs
              #   --dump            - Extract listed memory ranges
              #   --maxsize MAXSIZE - Maximum size for dumped VAD sections (all the bigger sections will be ignored)
              echo ""
              echo "    Aplicando el plugin windows.vadinfo..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.vadinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.vadinfo.txt

            # windows.vadregexscan (Scans all virtual memory areas for tasks using RegEx)
              # Argumentos:
              #   --pid [PID ...]   - Filter on specific process IDs
              #   --pattern PATTERN - RegEx pattern
              #   --maxsize MAXSIZE - Maximum size in bytes for displayed context
              echo ""
              echo "    Aplicando el plugin windows.vadregexscan..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.vadregexscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.vadregexscan.txt

            # windows.vadwalk (Walk the VAD tree)
              # Argumentos:
              #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
              echo ""
              echo "    Aplicando el plugin windows.vadwalk..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.vadwalk | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.vadwalk.txt

            # windows.verinfo (Lists version information from PE files)
              # Argumenots:
              #   --extensive - Search physical layer for version information
              echo ""
              echo "    Aplicando el plugin windows.verinfo..."
              echo ""
              # Normal
                vol -r pretty -f "$cRutaAlArchivoDeDump" windows.verinfo             | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.verinfo-normal.txt
              # Extensivo
                vol -r pretty -f "$cRutaAlArchivoDeDump" windows.verinfo --extensive | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.verinfo-extensivo.txt

            # windows.virtmap (Lists virtual mapped sections)
              echo ""
              echo "    Aplicando el plugin windows.virtmap..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.virtmap | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/windows.virtmap.txt

            # windows.vadyarascan (Scans all the Virtual Address Descriptor memory maps using yara)
              # Argumentos:
              #   --insensitive                           - Makes the search case insensitive
              #   --wide                                  - Match wide (unicode) strings
              #   --yara-string YARA_STRING               - Yara rules (as a string)
              #   --yara-file YARA_FILE                   - Yara rules (as a file)
              #   --yara-compiled-file YARA_COMPILED_FILE - Yara compiled rules (as a file)
              #   --max-size MAX_SIZE                     - Set the maximum size (default is 1GB)
              #   --pid [PID ...]                         - Process IDs to include (all other processes are excluded)
              echo ""
              echo "    Aplicando el plugin windows.vadyarascan..."
              echo ""
              vol -r pretty -f "$cRutaAlArchivoDeDump" windows.vadyarascan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.vadyarascan.txt

            # No windows

              # isinfo (Determines information about the currently available ISF files, or a specific one)
                # Argumentos:
                #   --filter [FILTER ...] - String that must be present in the file URI to display the ISF
                #   --isf ISF             - Specific ISF file to process
                #   --validate            - Validate against schema if possible
                #   --live                - Traverse all files, rather than use the cache
                echo ""
                echo "    Aplicando el plugin isinfo..."
                echo ""
                vol -r pretty -f "$cRutaAlArchivoDeDump" isfinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/isfinfo.txt

              # layerwriter (Runs the automagics and writes out the primary layer produced by the stacker)
                # Argumentos:
                #   --block-size BLOCK_SIZE - Size of blocks to copy over
                #   --list                  - List available layers
                #   --layers [LAYERS ...]   - Names of layers to write (defaults to the highest non-mapped layer)
                echo ""
                echo "    Aplicando el plugin layerwriter..."
                echo ""
                mkdir -p "$cCarpetaDondeGuardar"/txt/MemoryLayer/
                cd "$cCarpetaDondeGuardar"/txt/MemoryLayer/
                vol -f "$cRutaAlArchivoDeDump" layerwriter
                cd ~/repos/python/volatility3

              # regexscan.RegExScan (Scans kernel memory using RegEx patterns)
                # Argumentos:
                #   --pattern PATTERN - RegEx pattern
                #   --maxsize MAXSIZE - Maximum size in bytes for displayed context
                echo ""
                echo "    Aplicando el plugin regexscan.RegExScan..."
                echo ""
                vol -r pretty -f "$cRutaAlArchivoDeDump" regexscan.RegExScan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/regexscan.RegExScan.txt

              # timeliner (Runs all relevant plugins that provide time related information and orders the results by time)
                # Argumentos:
                #   --record-config                     - Whether to record the state of all the plugins once complete
                #   --plugin-filter [PLUGIN-FILTER ...] - Only run plugins featuring this substring
                #   --create-bodyfile                   - Whether to create a body file whilst producing results
                echo ""
                echo "    Aplicando el plugin timeliner..."
                echo ""
                vol -r pretty -f "$cRutaAlArchivoDeDump" timeliner | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/txt/timeliner.txt

            # Desactivar el entorno virtual
              deactivate

        ;;

       16)

          echo ""
          echo "  Parseando hacia archivos csv..."
          echo ""

          # Entrar en el entorno virtual de python
            source ~/repos/python/volatility3/venv/bin/activate

          # Parsear datos

            # Crear carpeta
              mkdir -p "$cCarpetaDondeGuardar"/csv

            # windows.amcache (Extract information on executed applications from the AmCache)
              echo ""
              echo "    Aplicando el plugin windows.amcache..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.amcache | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.amcache.csv

            # windows.bigpools (List big page pools)
              # Argumentos:
              #   --tags TAGS - Comma separated list of pool tags to filter pools returned
              #   --show-free - Show freed regions (otherwise only show allocations in use)
              echo ""
              echo "    Aplicando el plugin windows.bigpools..."
              echo ""
              # En uso
                vol -r csv -f "$cRutaAlArchivoDeDump" windows.bigpools             | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.bigpools-enuso.csv
              # En uso y libres
                vol -r csv -f "$cRutaAlArchivoDeDump" windows.bigpools --show-free | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.bigpools-enusoylibres.csv

            # windows.callbacks (Lists kernel callbacks and notification routines)
              echo ""
              echo "    Aplicando el plugin windows.callbacks..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.callbacks | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.callbacks.csv

            # windows.cmdline (Lists process command line arguments)
              # Argumentos:
              #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
              echo ""
              echo "    Aplicando el plugin windows.cmdline..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.cmdline | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.cmdline.csv

            # windows.cmdscan (Looks for Windows Command History lists)
              # Argumentos:
              #   --no-registry                   - Don't search the registry for possible values of CommandHistorySize
              #   --max-history [MAX_HISTORY ...] - CommandHistorySize values to search for.
              echo ""
              echo "    Aplicando el plugin windows.cmdscan..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.cmdscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.cmdscan.csv

            # windows.consoles (Looks for Windows console buffers)
              # Argumentos:
              #   --no-registry                   - Don't search the registry for possible values of CommandHistorySize and HistoryBufferMax
              #   --max-history [MAX_HISTORY ...] - CommandHistorySize values to search for.
              #   --max-buffers [MAX_BUFFERS ...] - HistoryBufferMax values to search for.
              echo ""
              echo "    Aplicando el plugin windows.consoles..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.consoles | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.consoles.csv

            # windows.crashinfo (Lists the information from a Windows crash dump)
              echo ""
              echo "    Aplicando el plugin windows.crashinfo..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.crashinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.crashinfo.csv

            # windows.debugregisters ()
              echo ""
              echo "    Aplicando el plugin windows.debugregisters..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.debugregisters | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.debugregisters.csv

            # windows.devicetree (Listing tree based on drivers and attached devices in a particular windows memory image)
              echo ""
              echo "    Aplicando el plugin windows.devicetree..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.devicetree | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.devicetree.csv

            # windows.dlllist (Lists the loaded modules in a particular windows memory image)
              # Argumentos:
              #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
              #   --offset OFFSET - Process offset in the physical address space
              #   --name NAME     - Specify a regular expression to match dll name(s)
              #   --base BASE     - Specify a base virtual address in process memory
              #   --ignore-case   - Specify case insensitivity for the regular expression name matching
              #   --dump          - Extract listed DLLs
              echo ""
              echo "    Aplicando el plugin windows.dlllist..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.dlllist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.dlllist.csv
              #vol -f "$cRutaAlArchivoDeDump" windows.dlllist ‑‑pid "<PID>"

            # windows.driverirp (List IRPs for drivers in a particular windows memory image)
              echo ""
              echo "    Aplicando el plugin windows.driverirp..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.driverirp | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.driverirp.csv

            # windows.drivermodule (Determines if any loaded drivers were hidden by a rootkit)
              echo ""
              echo "    Aplicando el plugin windows.drivermodule..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.drivermodule | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.drivermodule.csv

            # windows.driverscan (Scans for drivers present in a particular windows memory image)
              echo ""
              echo "    Aplicando el plugin windows.driverscan..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.driverscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.driverscan.csv

            # windows.envars (Display process environment variables)
              # Argumentos:
              #   --pid [PID ...] - Filter on specific process IDs
              #   --silent        - Suppress common and non-persistent variables
              echo ""
              echo "    Aplicando el plugin windows.envars..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.envars | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.envars.csv

            # windows.filescan (Scans for file objects present in a particular windows memory image)
              echo ""
              echo "    Aplicando el plugin windows.filescan..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.filescan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.filescan.csv

            # windows.getservicesids (Lists process token sids)
              echo ""
              echo "    Aplicando el plugin windows.getservicesids..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.getservicesids | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.getservicesids.csv

            # windows.getsids (Print the SIDs owning each process)
              # Argumentos:
              #   --pid [PID ...] - Filter on specific process IDs
              echo ""
              echo "    Aplicando el plugin windows.getsids..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.getsids | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.getsids.csv

            # windows.handles (Lists process open handles)
              # Argumentos:
              #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
              #   --offset OFFSET - Process offset in the physical address space
              echo ""
              echo "    Aplicando el plugin windows.handles..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.handles | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.handles.csv
              #vol -f "$cRutaAlArchivoDeDump" windows.handles ‑‑pid "<PID>"

            # windows.hashdump (Dumps user hashes from memory)
              echo ""
              echo "    Aplicando el plugin windows.hashdump..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.hashdump | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.hashdump.csv

            # windows.hollowprocesses (Lists hollowed processes)
              # Argumentos:
              #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
              echo ""
              echo "    Aplicando el plugin windows.hollowprocesses..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.hollowprocesses | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.hollowprocesses.csv

            # windows.iat (Extract Import Address Table to list API (functions) used by a program contained in external libraries)
              # Argumentos:
              #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
              echo ""
              echo "    Aplicando el plugin windows.iat..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.iat | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.iat.csv

            # windows.info (Show OS & kernel details of the memory sample being analyzed)
              echo ""
              echo "    Aplicando el plugin windows.info..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.info | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.info.csv

            # windows.joblinks (Print process job link information)
             # Argumentos:
              #   --physical - Display physical offset instead of virtual
              echo ""
              echo "    Aplicando el plugin windows.joblinks..."
              echo ""
              # Offset virtual
                vol -r csv -f "$cRutaAlArchivoDeDump" windows.joblinks            | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.joblinks-offsetvirtual.csv
              # Offset físico
                vol -r csv -f "$cRutaAlArchivoDeDump" windows.joblinks --physical | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.joblinks-offsetfisico.csv

            # windows.kpcrs (Print KPCR structure for each processor)
              echo ""
              echo "    Aplicando el plugin windows.kpcrs..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.kpcrs | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.kpcrs.csv

            # windows.ldrmodules (Lists the loaded modules in a particular windows memory image)
              # Argumentos:
              #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
              echo ""
              echo "    Aplicando el plugin windows.ldrmodules..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.ldrmodules | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.ldrmodules.csv

            # windows.malfind (Lists process memory ranges that potentially contain injected code)
              echo ""
              echo "    Aplicando el plugin windows.malfind..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.malfind | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.malfind.csv

            # windows.mbrscan (Scans for and parses potential Master Boot Records (MBRs))
              # Argumentos:
              #   --full - It analyzes and provides all the information in the partition entry and bootcode hexdump. (It returns a lot of information, so we recommend you render it in CSV.)
              echo ""
              echo "    Aplicando el plugin windows.mbrscan..."
              echo ""
              # Simple
                vol -r csv -f "$cRutaAlArchivoDeDump" windows.mbrscan        | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.mbrscan.csv
              # Completo
                vol -r csv -f "$cRutaAlArchivoDeDump" windows.mbrscan --full | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.mbrscan-full.csv

            # windows.memmap (Prints the memory map)
              # Argumentos:
              #   --pid PID - Process ID to include (all other processes are excluded)
              #   --dump    - Extract listed memory segments
              echo ""
              echo "    Aplicando el plugin windows.memmap..."
              echo ""
              #vol -r csv -f "$cRutaAlArchivoDeDump" windows.memmap | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.memmap.csv
              #vol -f "$cRutaAlArchivoDeDump" -o "/path/to/dir" windows.memmap ‑‑dump ‑‑pid "<PID>"

            # windows.modscan (Scans for modules present in a particular windows memory image)
              # Argumentos:
              #   --dump      - Extract listed modules
              #   --base BASE - Extract a single module with BASE address
              #   --name NAME - module name/sub string
              echo ""
              echo "    Aplicando el plugin windows.modscan..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.modscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.modscan.csv

            # windows.modules (Lists the loaded kernel modules)
              # Argumentos:
              #   --dump      - Extract listed modules
              #   --base BASE - Extract a single module with BASE address
              #   --name NAME - module name/sub string
              echo ""
              echo "    Aplicando el plugin windows.modules..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.modules | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.modules.csv

            # windows.mutantscan (Scans for mutexes present in a particular windows memory image)
              echo ""
              echo "    Aplicando el plugin windows.mutantscan..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.mutantscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.mutantscan.csv

            # windows.netscan (Scans for network objects present in a particular windows memory image)
              # Argumentos:
              #   --include-corrupt - Radically eases result validation. This will show partially overwritten data. WARNING: the results are likely to include garbage and/or corrupt data. Be cautious!
              echo ""
              echo "    Aplicando el plugin windows.netscan..."
              echo ""
              # Sin corruptos
                vol -r csv -f "$cRutaAlArchivoDeDump" windows.netscan                   | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.netscan.csv
              # Con corruptos
                vol -r csv -f "$cRutaAlArchivoDeDump" windows.netscan --include-corrupt | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.netscan-corrupt.csv

            # windows.netstat (Traverses network tracking structures present in a particular windows memory image)
              # Argumentos:
              #   --include-corrupt - Radically eases result validation. This will show partially overwritten data. WARNING: the results are likely to include garbage and/or corrupt data. Be cautious!
              echo ""
              echo "    Aplicando el plugin windows.netstat..."
              echo ""
              # Sin corruptos
                vol -r csv -f "$cRutaAlArchivoDeDump" windows.netstat                   | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.netstat.csv
              # Con corruptos
                vol -r csv -f "$cRutaAlArchivoDeDump" windows.netstat --include-corrupt | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.netstat-corrupt.csv

            # windows.orphan_kernel_threads (Lists process threads)
              echo ""
              echo "    Aplicando el plugin windows.orphan_kernel_threads..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.orphan_kernel_threads | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.orphan_kernel_threads.csv

            # windows.pe_symbols (Prints symbols in PE files in process and kernel memory)
              # Argumentos:
              #   --source {kernel,processes} - Where to resolve symbols.
              #   --module MODULE             - Module in which to resolve symbols. Use "ntoskrnl.exe" to resolve in the base kernel executable.
              #   --symbols [SYMBOLS ...]     - Symbol name to resolve
              #   --addresses [ADDRESSES ...] - Address of symbol to resolve
              echo ""
              echo "    Aplicando el plugin windows.pe_symbols..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.pe_symbols | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.pe_symbols.csv

            # windows.pedump (Allows extracting PE Files from a specific address in a specific address space)
              # Argumentos:
              #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
              #   --base BASE     - Base address to reconstruct a PE file
              #   --kernel-module - Extract from kernel address space.
              echo ""
              echo "    Aplicando el plugin windows.pedump..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.pedump | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.pedump.csv

            # windows.poolscanner (A generic pool scanner plugin)
              echo ""
              echo "    Aplicando el plugin windows.poolscanner..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.poolscanner | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.poolscanner.csv

            # windows.privileges (Lists process token privileges)
              # Argumentos:
              #   --pid [PID ...] - Filter on specific process IDs
              echo ""
              echo "    Aplicando el plugin windows.privileges..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.privileges | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.privileges.csv

            # windows.processghosting (Lists processes whose DeletePending bit is set or whose FILE_OBJECT is set to 0)
              echo ""
              echo "    Aplicando el plugin windows.processghosting..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.processghosting | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.processghosting.csv

            # windows.pslist (Lists the processes present in a particular windows memory image)
              # Argumentos:
              #   --physical      - Display physical offsets instead of virtual
              #   --pid [PID ...] - Process ID to include (all other processes are excluded)
              #   --dump          - Extract listed processes
              echo ""
              echo "    Aplicando el plugin windows.pslist..."
              echo ""
              # Offset virtual
                vol -r csv -f "$cRutaAlArchivoDeDump" windows.pslist            | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.pslist-offsetvirtual.csv
              # Offset físico
                vol -r csv -f "$cRutaAlArchivoDeDump" windows.pslist --physical | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.pslist-offsetfisico.csv

            # windows.psscan (Scans for processes present in a particular windows memory image)
              # Argumentos:
              #   --physical      - Display physical offsets instead of virtual
              #   --pid [PID ...] - Process ID to include (all other processes are excluded)
              #   --dump          - Extract listed processes
              echo ""
              echo "    Aplicando el plugin windows.psscan..."
              echo ""
              # Offset virtual
                vol -r csv -f "$cRutaAlArchivoDeDump" windows.psscan            | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.psscan-offsetvirtual.csv
              # Offset físico
                vol -r csv -f "$cRutaAlArchivoDeDump" windows.psscan --physical | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.psscan-offsetfisico.csv

            # windows.pstree (Plugin for listing processes in a tree based on their parent process ID)
              # Argumentos:
              #   --physical      - Display physical offsets instead of virtual
              #   --pid [PID ...] - Process ID to include (all other processes are excluded)
              echo ""
              echo "    Aplicando el plugin windows.pstree..."
              echo ""
              # Offset virtual
                vol -r csv -f "$cRutaAlArchivoDeDump" windows.pstree            | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.pstree-offsetvirtual.csv
              # Offset físico
                vol -r csv -f "$cRutaAlArchivoDeDump" windows.pstree --physical | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.pstree-offsetfisico.csv

            # windows.psxview (Lists all processes found via four of the methods described in "The Art of Memory Forensics," which may help identify processes that are trying to hide themselves. I recommend using -r pretty if you are looking at this plugin's output in a terminal)
              # Argumentos:
              # --physical-offsets - List processes with physical offsets instead of virtual offsets.
              echo ""
              echo "    Aplicando el plugin windows.psxview..."
              echo ""
              # Offsets virtuales
                vol -r csv -f "$cRutaAlArchivoDeDump" windows.psxview                    | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.psxview-offsetsvirtuales.csv
              # Offsets físicos
                vol -r csv -f "$cRutaAlArchivoDeDump" windows.psxview --physical-offsets | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.psxview-offsetsfisicos.csv

            # windows.registry.certificates (Lists the certificates in the registry's Certificate Store)
              # Argumentos:
              #   --dump - Extract listed certificates
              echo ""
              echo "    Aplicando el plugin windows.registry.certificates..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.registry.certificates | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.registry.certificates.csv

            # windows.registry.getcellroutine (Reports registry hives with a hooked GetCellRoutine handler)
              echo ""
              echo "    Aplicando el plugin windows.registry.getcellroutine..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.registry.getcellroutine | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.registry.getcellroutine.csv

            # windows.registry.hivelist (Lists the registry hives present in a particular memory image)
              # Argumentos:
              #   --filter FILTER - String to filter hive names returned
              #   --dump          - Extract listed registry hives
              echo ""
              echo "    Aplicando el plugin windows.registry.hivelist..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.registry.hivelist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.registry.hivelist.csv

            # windows.registry.hivescan (Scans for registry hives present in a particular windows memory image)
              echo ""
              echo "    Aplicando el plugin windows.registry.hivescan..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.registry.hivescan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.registry.hivescan.csv

            # windows.registry.printkey (Lists the registry keys under a hive or specific key value)
              # Argumentos:
              #   --offset OFFSET - Hive Offset
              #   --key KEY       - Key to start from
              #   --recurse       - Recurses through keys
              echo ""
              echo "    Aplicando el plugin windows.registry.printkey..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.registry.printkey | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.registry.printkey.csv
              #vol -f "$cRutaAlArchivoDeDump" windows.registry.printkey ‑‑key "Software\Microsoft\Windows\CurrentVersion" | grep -v "Volatility 3"

            # windows.registry.userassist (Print userassist registry keys and information)
              # Argumentos:
              #   --offset OFFSET - Hive Offset
              echo ""
              echo "    Aplicando el plugin windows.registry.userassist..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.registry.userassist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.registry.userassist.csv

            # windows.scheduled_tasks (Decodes scheduled task information from the Windows registry, including information about triggers, actions, run times, and creation times)
              echo ""
              echo "    Aplicando el plugin windows.scheduled_tasks..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.scheduled_tasks | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.scheduled_tasks.csv

            # windows.sessions (lists Processes with Session information extracted from Environmental Variables)
              # Argumentos:
              #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
              echo ""
              echo "    Aplicando el plugin windows.sessions..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.sessions | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.sessions.csv

            # windows.shimcachemem (Reads Shimcache entries from the ahcache.sys AVL tree)
              echo ""
              echo "    Aplicando el plugin windows.shimcachemem..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.shimcachemem | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.shimcachemem.csv

            # windows.skeleton_key_check (Looks for signs of Skeleton Key malware)
              echo ""
              echo "    Aplicando el plugin windows.skeleton_key_check..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.skeleton_key_check | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.skeleton_key_check.csv

            # windows.ssdt (Lists the system call table)
              echo ""
              echo "    Aplicando el plugin windows.ssdt..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.ssdt | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.ssdt.csv

            # windows.statistics (Lists statistics about the memory space)
              echo ""
              echo "    Aplicando el plugin windows.statistics..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.statistics | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.statistics.csv

            # windows.strings (Reads output from the strings command and indicates which process(es) each string belongs to)
              # Argumentos:
              #   --pid [PID ...]             - Process ID to include (all other processes are excluded)
              #   --strings-file STRINGS_FILE - Strings file
              echo ""
              echo "    Aplicando el plugin windows.strings..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.strings | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.strings.csv

            # windows.suspicious_threads (Lists suspicious userland process threads)
              # Argumentos:
              #   --pid [PID ...] - Filter on specific process IDs
              echo ""
              echo "    Aplicando el plugin windows.suspicious_threads..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.suspicious_threads | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.suspicious_threads.csv

            # windows.svcdiff (Compares services found through list walking versus scanning to find rootkits)
              echo ""
              echo "    Aplicando el plugin windows.svcdiff..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.svcdiff | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.svcdiff.csv

            # windows.svclist (Lists services contained with the services.exe doubly linked list of services)
              echo ""
              echo "    Aplicando el plugin windows.svclist..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.svclist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.svclist.csv

            # windows.svcscan (Scans for windows services)
              echo ""
              echo "    Aplicando el plugin windows.svcscan..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.svcscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.svcscan.csv

            # windows.symlinkscan (Scans for links present in a particular windows memory image)
              echo ""
              echo "    Aplicando el plugin windows.symlinkscan..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.symlinkscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.symlinkscan.csv

            # windows.thrdscan (Scans for windows threads)
              echo ""
              echo "    Aplicando el plugin windows.thrdscan..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.thrdscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.thrdscan.csv

            # windows.threads (Lists process threads)
              # Argumentos:
              #   --pid [PID ...] - Filter on specific process IDs
              echo ""
              echo "    Aplicando el plugin windows.threads..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.threads | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.threads.csv

            # windows.timers (Print kernel timers and associated module DPCs)
              echo ""
              echo "    Aplicando el plugin windows.timers..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.timers | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.timers.csv

            # windows.truecrypt (TrueCrypt Cached Passphrase Finder)
              # Argumentos:
              #   --min-length MIN-LENGTH - Minimum length of passphrases to identify
              echo ""
              echo "    Aplicando el plugin windows.truecrypt..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.truecrypt | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.truecrypt.csv

            # windows.unhooked_system_calls (Looks for signs of Skeleton Key malware)
              echo ""
              echo "    Aplicando el plugin windows.unhooked_system_calls..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.unhooked_system_calls | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.unhooked_system_calls.csv

            # windows.unloadedmodules (Lists the unloaded kernel modules)
              echo ""
              echo "    Aplicando el plugin windows.unloadedmodules..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.unloadedmodules | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.unloadedmodules.csv

            # windows.vadinfo (Lists process memory ranges)
              # Argumentos:
              #   --address ADDRESS - Process virtual memory address to include (all other address ranges are excluded).
              #   --pid [PID ...]   - Filter on specific process IDs
              #   --dump            - Extract listed memory ranges
              #   --maxsize MAXSIZE - Maximum size for dumped VAD sections (all the bigger sections will be ignored)
              echo ""
              echo "    Aplicando el plugin windows.vadinfo..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.vadinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.vadinfo.csv

            # windows.vadregexscan (Scans all virtual memory areas for tasks using RegEx)
              # Argumentos:
              #   --pid [PID ...]   - Filter on specific process IDs
              #   --pattern PATTERN - RegEx pattern
              #   --maxsize MAXSIZE - Maximum size in bytes for displayed context
              echo ""
              echo "    Aplicando el plugin windows.vadregexscan..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.vadregexscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.vadregexscan.csv

            # windows.vadwalk (Walk the VAD tree)
              # Argumentos:
              #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
              echo ""
              echo "    Aplicando el plugin windows.vadwalk..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.vadwalk | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.vadwalk.csv

            # windows.verinfo (Lists version information from PE files)
              # Argumenots:
              #   --extensive - Search physical layer for version information
              echo ""
              echo "    Aplicando el plugin windows.verinfo..."
              echo ""
              # Normal
                vol -r csv -f "$cRutaAlArchivoDeDump" windows.verinfo             | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.verinfo-normal.csv
              # Extensivo
                vol -r csv -f "$cRutaAlArchivoDeDump" windows.verinfo --extensive | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.verinfo-extensivo.csv

            # windows.virtmap (Lists virtual mapped sections)
              echo ""
              echo "    Aplicando el plugin windows.virtmap..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.virtmap | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.virtmap.csv

            # windows.vadyarascan (Scans all the Virtual Address Descriptor memory maps using yara)
              # Argumentos:
              #   --insensitive                           - Makes the search case insensitive
              #   --wide                                  - Match wide (unicode) strings
              #   --yara-string YARA_STRING               - Yara rules (as a string)
              #   --yara-file YARA_FILE                   - Yara rules (as a file)
              #   --yara-compiled-file YARA_COMPILED_FILE - Yara compiled rules (as a file)
              #   --max-size MAX_SIZE                     - Set the maximum size (default is 1GB)
              #   --pid [PID ...]                         - Process IDs to include (all other processes are excluded)
              echo ""
              echo "    Aplicando el plugin windows.vadyarascan..."
              echo ""
              vol -r csv -f "$cRutaAlArchivoDeDump" windows.vadyarascan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.vadyarascan.csv

            # No windows

              # isinfo (Determines information about the currently available ISF files, or a specific one)
                # Argumentos:
                #   --filter [FILTER ...] - String that must be present in the file URI to display the ISF
                #   --isf ISF             - Specific ISF file to process
                #   --validate            - Validate against schema if possible
                #   --live                - Traverse all files, rather than use the cache
                echo ""
                echo "    Aplicando el plugin isinfo..."
                echo ""
                vol -r csv -f "$cRutaAlArchivoDeDump" isfinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/isfinfo.csv

              # layerwriter (Runs the automagics and writes out the primary layer produced by the stacker)
                # Argumentos:
                #   --block-size BLOCK_SIZE - Size of blocks to copy over
                #   --list                  - List available layers
                #   --layers [LAYERS ...]   - Names of layers to write (defaults to the highest non-mapped layer)
                echo ""
                echo "    Aplicando el plugin layerwriter..."
                echo ""
                mkdir -p "$cCarpetaDondeGuardar"/csv/MemoryLayer/
                cd "$cCarpetaDondeGuardar"/csv/MemoryLayer/
                vol -f "$cRutaAlArchivoDeDump" layerwriter
                cd ~/repos/python/volatility3

              # regexscan.RegExScan (Scans kernel memory using RegEx patterns)
                # Argumentos:
                #   --pattern PATTERN - RegEx pattern
                #   --maxsize MAXSIZE - Maximum size in bytes for displayed context
                echo ""
                echo "    Aplicando el plugin regexscan.RegExScan..."
                echo ""
                vol -r csv -f "$cRutaAlArchivoDeDump" regexscan.RegExScan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/regexscan.RegExScan.csv

              # timeliner (Runs all relevant plugins that provide time related information and orders the results by time)
                # Argumentos:
                #   --record-config                     - Whether to record the state of all the plugins once complete
                #   --plugin-filter [PLUGIN-FILTER ...] - Only run plugins featuring this substring
                #   --create-bodyfile                   - Whether to create a body file whilst producing results
                echo ""
                echo "    Aplicando el plugin timeliner..."
                echo ""
                vol -r csv -f "$cRutaAlArchivoDeDump" timeliner | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/timeliner.csv

            # Desactivar el entorno virtual
              deactivate

        ;;

       17)

          echo ""
          echo "  Parseando hacia archivos json..."
          echo ""

          # Entrar en el entorno virtual de python
            source ~/repos/python/volatility3/venv/bin/activate

          # Parsear datos

            # Crear carpeta
              mkdir -p "$cCarpetaDondeGuardar"/json

            # windows.amcache (Extract information on executed applications from the AmCache)
              echo ""
              echo "    Aplicando el plugin windows.amcache..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.amcache | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.amcache.json

            # windows.bigpools (List big page pools)
              # Argumentos:
              #   --tags TAGS - Comma separated list of pool tags to filter pools returned
              #   --show-free - Show freed regions (otherwise only show allocations in use)
              echo ""
              echo "    Aplicando el plugin windows.bigpools..."
              echo ""
              # En uso
                vol -r json -f "$cRutaAlArchivoDeDump" windows.bigpools             | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.bigpools-enuso.json
              # En uso y libres
                vol -r json -f "$cRutaAlArchivoDeDump" windows.bigpools --show-free | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.bigpools-enusoylibres.json

            # windows.callbacks (Lists kernel callbacks and notification routines)
              echo ""
              echo "    Aplicando el plugin windows.callbacks..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.callbacks | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.callbacks.json

            # windows.cmdline (Lists process command line arguments)
              # Argumentos:
              #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
              echo ""
              echo "    Aplicando el plugin windows.cmdline..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.cmdline | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.cmdline.json

            # windows.cmdscan (Looks for Windows Command History lists)
              # Argumentos:
              #   --no-registry                   - Don't search the registry for possible values of CommandHistorySize
              #   --max-history [MAX_HISTORY ...] - CommandHistorySize values to search for.
              echo ""
              echo "    Aplicando el plugin windows.cmdscan..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.cmdscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.cmdscan.json

            # windows.consoles (Looks for Windows console buffers)
              # Argumentos:
              #   --no-registry                   - Don't search the registry for possible values of CommandHistorySize and HistoryBufferMax
              #   --max-history [MAX_HISTORY ...] - CommandHistorySize values to search for.
              #   --max-buffers [MAX_BUFFERS ...] - HistoryBufferMax values to search for.
              echo ""
              echo "    Aplicando el plugin windows.consoles..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.consoles | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.consoles.json

            # windows.crashinfo (Lists the information from a Windows crash dump)
              echo ""
              echo "    Aplicando el plugin windows.crashinfo..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.crashinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.crashinfo.json

            # windows.debugregisters ()
              echo ""
              echo "    Aplicando el plugin windows.debugregisters..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.debugregisters | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.debugregisters.json

            # windows.devicetree (Listing tree based on drivers and attached devices in a particular windows memory image)
              echo ""
              echo "    Aplicando el plugin windows.devicetree..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.devicetree | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.devicetree.json

            # windows.dlllist (Lists the loaded modules in a particular windows memory image)
              # Argumentos:
              #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
              #   --offset OFFSET - Process offset in the physical address space
              #   --name NAME     - Specify a regular expression to match dll name(s)
              #   --base BASE     - Specify a base virtual address in process memory
              #   --ignore-case   - Specify case insensitivity for the regular expression name matching
              #   --dump          - Extract listed DLLs
              echo ""
              echo "    Aplicando el plugin windows.dlllist..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.dlllist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.dlllist.json
              #vol -f "$cRutaAlArchivoDeDump" windows.dlllist ‑‑pid "<PID>"

            # windows.driverirp (List IRPs for drivers in a particular windows memory image)
              echo ""
              echo "    Aplicando el plugin windows.driverirp..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.driverirp | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.driverirp.json

            # windows.drivermodule (Determines if any loaded drivers were hidden by a rootkit)
              echo ""
              echo "    Aplicando el plugin windows.drivermodule..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.drivermodule | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.drivermodule.json

            # windows.driverscan (Scans for drivers present in a particular windows memory image)
              echo ""
              echo "    Aplicando el plugin windows.driverscan..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.driverscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.driverscan.json

            # windows.envars (Display process environment variables)
              # Argumentos:
              #   --pid [PID ...] - Filter on specific process IDs
              #   --silent        - Suppress common and non-persistent variables
              echo ""
              echo "    Aplicando el plugin windows.envars..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.envars | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.envars.json

            # windows.filescan (Scans for file objects present in a particular windows memory image)
              echo ""
              echo "    Aplicando el plugin windows.filescan..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.filescan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.filescan.json

            # windows.getservicesids (Lists process token sids)
              echo ""
              echo "    Aplicando el plugin windows.getservicesids..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.getservicesids | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.getservicesids.json

            # windows.getsids (Print the SIDs owning each process)
              # Argumentos:
              #   --pid [PID ...] - Filter on specific process IDs
              echo ""
              echo "    Aplicando el plugin windows.getsids..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.getsids | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.getsids.json

            # windows.handles (Lists process open handles)
              # Argumentos:
              #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
              #   --offset OFFSET - Process offset in the physical address space
              echo ""
              echo "    Aplicando el plugin windows.handles..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.handles | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.handles.json
              #vol -f "$cRutaAlArchivoDeDump" windows.handles ‑‑pid "<PID>"

            # windows.hashdump (Dumps user hashes from memory)
              echo ""
              echo "    Aplicando el plugin windows.hashdump..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.hashdump | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.hashdump.json

            # windows.hollowprocesses (Lists hollowed processes)
              # Argumentos:
              #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
              echo ""
              echo "    Aplicando el plugin windows.hollowprocesses..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.hollowprocesses | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.hollowprocesses.json

            # windows.iat (Extract Import Address Table to list API (functions) used by a program contained in external libraries)
              # Argumentos:
              #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
              echo ""
              echo "    Aplicando el plugin windows.iat..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.iat | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.iat.json

            # windows.info (Show OS & kernel details of the memory sample being analyzed)
              echo ""
              echo "    Aplicando el plugin windows.info..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.info | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.info.json

            # windows.joblinks (Print process job link information)
             # Argumentos:
              #   --physical - Display physical offset instead of virtual
              echo ""
              echo "    Aplicando el plugin windows.joblinks..."
              echo ""
              # Offset virtual
                vol -r json -f "$cRutaAlArchivoDeDump" windows.joblinks            | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.joblinks-offsetvirtual.json
              # Offset físico
                vol -r json -f "$cRutaAlArchivoDeDump" windows.joblinks --physical | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.joblinks-offsetfisico.json

            # windows.kpcrs (Print KPCR structure for each processor)
              echo ""
              echo "    Aplicando el plugin windows.kpcrs..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.kpcrs | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.kpcrs.json

            # windows.ldrmodules (Lists the loaded modules in a particular windows memory image)
              # Argumentos:
              #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
              echo ""
              echo "    Aplicando el plugin windows.ldrmodules..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.ldrmodules | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.ldrmodules.json

            # windows.malfind (Lists process memory ranges that potentially contain injected code)
              echo ""
              echo "    Aplicando el plugin windows.malfind..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.malfind | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.malfind.json

            # windows.mbrscan (Scans for and parses potential Master Boot Records (MBRs))
              # Argumentos:
              #   --full - It analyzes and provides all the information in the partition entry and bootcode hexdump. (It returns a lot of information, so we recommend you render it in CSV.)
              echo ""
              echo "    Aplicando el plugin windows.mbrscan..."
              echo ""
              # Simple
                vol -r json -f "$cRutaAlArchivoDeDump" windows.mbrscan        | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.mbrscan.json
              # Completo
                vol -r json -f "$cRutaAlArchivoDeDump" windows.mbrscan --full | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.mbrscan-full.json

            # windows.memmap (Prints the memory map)
              # Argumentos:
              #   --pid PID - Process ID to include (all other processes are excluded)
              #   --dump    - Extract listed memory segments
              echo ""
              echo "    Aplicando el plugin windows.memmap..."
              echo ""
              #vol -r json -f "$cRutaAlArchivoDeDump" windows.memmap | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.memmap.json
              #vol -f "$cRutaAlArchivoDeDump" -o "/path/to/dir" windows.memmap ‑‑dump ‑‑pid "<PID>"

            # windows.modscan (Scans for modules present in a particular windows memory image)
              # Argumentos:
              #   --dump      - Extract listed modules
              #   --base BASE - Extract a single module with BASE address
              #   --name NAME - module name/sub string
              echo ""
              echo "    Aplicando el plugin windows.modscan..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.modscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.modscan.json

            # windows.modules (Lists the loaded kernel modules)
              # Argumentos:
              #   --dump      - Extract listed modules
              #   --base BASE - Extract a single module with BASE address
              #   --name NAME - module name/sub string
              echo ""
              echo "    Aplicando el plugin windows.modules..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.modules | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.modules.json

            # windows.mutantscan (Scans for mutexes present in a particular windows memory image)
              echo ""
              echo "    Aplicando el plugin windows.mutantscan..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.mutantscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.mutantscan.json

            # windows.netscan (Scans for network objects present in a particular windows memory image)
              # Argumentos:
              #   --include-corrupt - Radically eases result validation. This will show partially overwritten data. WARNING: the results are likely to include garbage and/or corrupt data. Be cautious!
              echo ""
              echo "    Aplicando el plugin windows.netscan..."
              echo ""
              # Sin corruptos
                vol -r json -f "$cRutaAlArchivoDeDump" windows.netscan                   | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.netscan.json
              # Con corruptos
                vol -r json -f "$cRutaAlArchivoDeDump" windows.netscan --include-corrupt | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.netscan-corrupt.json

            # windows.netstat (Traverses network tracking structures present in a particular windows memory image)
              # Argumentos:
              #   --include-corrupt - Radically eases result validation. This will show partially overwritten data. WARNING: the results are likely to include garbage and/or corrupt data. Be cautious!
              echo ""
              echo "    Aplicando el plugin windows.netstat..."
              echo ""
              # Sin corruptos
                vol -r json -f "$cRutaAlArchivoDeDump" windows.netstat                   | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.netstat.json
              # Con corruptos
                vol -r json -f "$cRutaAlArchivoDeDump" windows.netstat --include-corrupt | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.netstat-corrupt.json

            # windows.orphan_kernel_threads (Lists process threads)
              echo ""
              echo "    Aplicando el plugin windows.orphan_kernel_threads..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.orphan_kernel_threads | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.orphan_kernel_threads.json

            # windows.pe_symbols (Prints symbols in PE files in process and kernel memory)
              # Argumentos:
              #   --source {kernel,processes} - Where to resolve symbols.
              #   --module MODULE             - Module in which to resolve symbols. Use "ntoskrnl.exe" to resolve in the base kernel executable.
              #   --symbols [SYMBOLS ...]     - Symbol name to resolve
              #   --addresses [ADDRESSES ...] - Address of symbol to resolve
              echo ""
              echo "    Aplicando el plugin windows.pe_symbols..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.pe_symbols | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.pe_symbols.json

            # windows.pedump (Allows extracting PE Files from a specific address in a specific address space)
              # Argumentos:
              #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
              #   --base BASE     - Base address to reconstruct a PE file
              #   --kernel-module - Extract from kernel address space.
              echo ""
              echo "    Aplicando el plugin windows.pedump..."
              echo ""

              vol -r json -f "$cRutaAlArchivoDeDump" windows.pedump | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.pedump.json

            # windows.poolscanner (A generic pool scanner plugin)
              echo ""
              echo "    Aplicando el plugin windows.poolscanner..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.poolscanner | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.poolscanner.json

            # windows.privileges (Lists process token privileges)
              # Argumentos:
              #   --pid [PID ...] - Filter on specific process IDs
              echo ""
              echo "    Aplicando el plugin windows.privileges..."
              echo ""

              vol -r json -f "$cRutaAlArchivoDeDump" windows.privileges | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.privileges.json

            # windows.processghosting (Lists processes whose DeletePending bit is set or whose FILE_OBJECT is set to 0)
              echo ""
              echo "    Aplicando el plugin windows.processghosting..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.processghosting | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.processghosting.json

            # windows.pslist (Lists the processes present in a particular windows memory image)
              # Argumentos:
              #   --physical      - Display physical offsets instead of virtual
              #   --pid [PID ...] - Process ID to include (all other processes are excluded)
              #   --dump          - Extract listed processes
              echo ""
              echo "    Aplicando el plugin windows.pslist..."
              echo ""
              # Offset virtual
                vol -r json -f "$cRutaAlArchivoDeDump" windows.pslist            | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.pslist-offsetvirtual.json
              # Offset físico
                vol -r json -f "$cRutaAlArchivoDeDump" windows.pslist --physical | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.pslist-offsetfisico.json

            # windows.psscan (Scans for processes present in a particular windows memory image)
              # Argumentos:
              #   --physical      - Display physical offsets instead of virtual
              #   --pid [PID ...] - Process ID to include (all other processes are excluded)
              #   --dump          - Extract listed processes
              echo ""
              echo "    Aplicando el plugin windows.psscan..."
              echo ""
              # Offset virtual
                vol -r json -f "$cRutaAlArchivoDeDump" windows.psscan            | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.psscan-offsetvirtual.json
              # Offset físico
                vol -r json -f "$cRutaAlArchivoDeDump" windows.psscan --physical | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.psscan-offsetfisico.json

            # windows.pstree (Plugin for listing processes in a tree based on their parent process ID)
              # Argumentos:
              #   --physical      - Display physical offsets instead of virtual
              #   --pid [PID ...] - Process ID to include (all other processes are excluded)
              echo ""
              echo "    Aplicando el plugin windows.pstree..."
              echo ""
              # Offset virtual
                vol -r json -f "$cRutaAlArchivoDeDump" windows.pstree            | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.pstree-offsetvirtual.json
              # Offset físico
                vol -r json -f "$cRutaAlArchivoDeDump" windows.pstree --physical | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.pstree-offsetfisico.json

            # windows.psxview (Lists all processes found via four of the methods described in "The Art of Memory Forensics," which may help identify processes that are trying to hide themselves. I recommend using -r pretty if you are looking at this plugin's output in a terminal)
              # Argumentos:
              # --physical-offsets - List processes with physical offsets instead of virtual offsets.
              echo ""
              echo "    Aplicando el plugin windows.psxview..."
              echo ""
              # Offsets virtuales
                vol -r json -f "$cRutaAlArchivoDeDump" windows.psxview                    | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.psxview-offsetsvirtuales.json
              # Offsets físicos
                vol -r json -f "$cRutaAlArchivoDeDump" windows.psxview --physical-offsets | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.psxview-offsetsfisicos.json

            # windows.registry.certificates (Lists the certificates in the registry's Certificate Store)
              # Argumentos:
              #   --dump - Extract listed certificates
              echo ""
              echo "    Aplicando el plugin windows.registry.certificates..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.registry.certificates | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.registry.certificates.json

            # windows.registry.getcellroutine (Reports registry hives with a hooked GetCellRoutine handler)
              echo ""
              echo "    Aplicando el plugin windows.registry.getcellroutine..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.registry.getcellroutine | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.registry.getcellroutine.json

            # windows.registry.hivelist (Lists the registry hives present in a particular memory image)
              # Argumentos:
              #   --filter FILTER - String to filter hive names returned
              #   --dump          - Extract listed registry hives
              echo ""
              echo "    Aplicando el plugin windows.registry.hivelist..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.registry.hivelist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.registry.hivelist.json

            # windows.registry.hivescan (Scans for registry hives present in a particular windows memory image)
              echo ""
              echo "    Aplicando el plugin windows.registry.hivescan..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.registry.hivescan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.registry.hivescan.json

            # windows.registry.printkey (Lists the registry keys under a hive or specific key value)
              # Argumentos:
              #   --offset OFFSET - Hive Offset
              #   --key KEY       - Key to start from
              #   --recurse       - Recurses through keys
              echo ""
              echo "    Aplicando el plugin windows.registry.printkey..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.registry.printkey | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.registry.printkey.json
              #vol -f "$cRutaAlArchivoDeDump" windows.registry.printkey ‑‑key "Software\Microsoft\Windows\CurrentVersion" | grep -v "Volatility 3"

            # windows.registry.userassist (Print userassist registry keys and information)
              # Argumentos:
              #   --offset OFFSET - Hive Offset
              echo ""
              echo "    Aplicando el plugin windows.registry.userassist..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.registry.userassist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.registry.userassist.json

            # windows.scheduled_tasks (Decodes scheduled task information from the Windows registry, including information about triggers, actions, run times, and creation times)
              echo ""
              echo "    Aplicando el plugin windows.scheduled_tasks..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.scheduled_tasks | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.scheduled_tasks.json

            # windows.sessions (lists Processes with Session information extracted from Environmental Variables)
              # Argumentos:
              #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
              echo ""
              echo "    Aplicando el plugin windows.sessions..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.sessions | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.sessions.json

            # windows.shimcachemem (Reads Shimcache entries from the ahcache.sys AVL tree)
              echo ""
              echo "    Aplicando el plugin windows.shimcachemem..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.shimcachemem | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.shimcachemem.json

            # windows.skeleton_key_check (Looks for signs of Skeleton Key malware)
              echo ""
              echo "    Aplicando el plugin windows.skeleton_key_check..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.skeleton_key_check | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.skeleton_key_check.json

            # windows.ssdt (Lists the system call table)
              echo ""
              echo "    Aplicando el plugin windows.ssdt..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.ssdt | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.ssdt.json

            # windows.statistics (Lists statistics about the memory space)
              echo ""
              echo "    Aplicando el plugin windows.statistics..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.statistics | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.statistics.json

            # windows.strings (Reads output from the strings command and indicates which process(es) each string belongs to)
              # Argumentos:
              #   --pid [PID ...]             - Process ID to include (all other processes are excluded)
              #   --strings-file STRINGS_FILE - Strings file
              echo ""
              echo "    Aplicando el plugin windows.strings..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.strings | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.strings.json

            # windows.suspicious_threads (Lists suspicious userland process threads)
              # Argumentos:
              #   --pid [PID ...] - Filter on specific process IDs
              echo ""
              echo "    Aplicando el plugin windows.suspicious_threads..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.suspicious_threads | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.suspicious_threads.json

            # windows.svcdiff (Compares services found through list walking versus scanning to find rootkits)
              echo ""
              echo "    Aplicando el plugin windows.svcdiff..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.svcdiff | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.svcdiff.json

            # windows.svclist (Lists services contained with the services.exe doubly linked list of services)
              echo ""
              echo "    Aplicando el plugin windows.svclist..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.svclist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.svclist.json

            # windows.svcscan (Scans for windows services)
              echo ""
              echo "    Aplicando el plugin windows.svcscan..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.svcscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.svcscan.json

            # windows.symlinkscan (Scans for links present in a particular windows memory image)
              echo ""
              echo "    Aplicando el plugin windows.symlinkscan..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.symlinkscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.symlinkscan.json

            # windows.thrdscan (Scans for windows threads)
              echo ""
              echo "    Aplicando el plugin windows.thrdscan..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.thrdscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.thrdscan.json

            # windows.threads (Lists process threads)
              # Argumentos:
              #   --pid [PID ...] - Filter on specific process IDs
              echo ""
              echo "    Aplicando el plugin windows.threads..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.threads | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.threads.json

            # windows.timers (Print kernel timers and associated module DPCs)
              echo ""
              echo "    Aplicando el plugin windows.timers..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.timers | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.timers.json

            # windows.truecrypt (TrueCrypt Cached Passphrase Finder)
              # Argumentos:
              #   --min-length MIN-LENGTH - Minimum length of passphrases to identify
              echo ""
              echo "    Aplicando el plugin windows.truecrypt..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.truecrypt | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.truecrypt.json

            # windows.unhooked_system_calls (Looks for signs of Skeleton Key malware)
              echo ""
              echo "    Aplicando el plugin windows.unhooked_system_calls..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.unhooked_system_calls | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.unhooked_system_calls.json

            # windows.unloadedmodules (Lists the unloaded kernel modules)
              echo ""
              echo "    Aplicando el plugin windows.unloadedmodules..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.unloadedmodules | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.unloadedmodules.json

            # windows.vadinfo (Lists process memory ranges)
              # Argumentos:
              #   --address ADDRESS - Process virtual memory address to include (all other address ranges are excluded).
              #   --pid [PID ...]   - Filter on specific process IDs
              #   --dump            - Extract listed memory ranges
              #   --maxsize MAXSIZE - Maximum size for dumped VAD sections (all the bigger sections will be ignored)
              echo ""
              echo "    Aplicando el plugin windows.vadinfo..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.vadinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.vadinfo.json

            # windows.vadregexscan (Scans all virtual memory areas for tasks using RegEx)
              # Argumentos:
              #   --pid [PID ...]   - Filter on specific process IDs
              #   --pattern PATTERN - RegEx pattern
              #   --maxsize MAXSIZE - Maximum size in bytes for displayed context
              echo ""
              echo "    Aplicando el plugin windows.vadregexscan..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.vadregexscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.vadregexscan.json

            # windows.vadwalk (Walk the VAD tree)
              # Argumentos:
              #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
              echo ""
              echo "    Aplicando el plugin windows.vadwalk..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.vadwalk | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.vadwalk.json

            # windows.verinfo (Lists version information from PE files)
              # Argumenots:
              #   --extensive - Search physical layer for version information
              echo ""
              echo "    Aplicando el plugin windows.verinfo..."
              echo ""
              # Normal
                vol -r json -f "$cRutaAlArchivoDeDump" windows.verinfo             | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.verinfo-normal.json
              # Extensivo
                vol -r json -f "$cRutaAlArchivoDeDump" windows.verinfo --extensive | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.verinfo-extensivo.json

            # windows.virtmap (Lists virtual mapped sections)
              echo ""
              echo "    Aplicando el plugin windows.virtmap..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.virtmap | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.virtmap.json

            # windows.vadyarascan (Scans all the Virtual Address Descriptor memory maps using yara)
              # Argumentos:
              #   --insensitive                           - Makes the search case insensitive
              #   --wide                                  - Match wide (unicode) strings
              #   --yara-string YARA_STRING               - Yara rules (as a string)
              #   --yara-file YARA_FILE                   - Yara rules (as a file)
              #   --yara-compiled-file YARA_COMPILED_FILE - Yara compiled rules (as a file)
              #   --max-size MAX_SIZE                     - Set the maximum size (default is 1GB)
              #   --pid [PID ...]                         - Process IDs to include (all other processes are excluded)
              echo ""
              echo "    Aplicando el plugin windows.vadyarascan..."
              echo ""
              vol -r json -f "$cRutaAlArchivoDeDump" windows.vadyarascan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.vadyarascan.json

            # No windows

              # isinfo (Determines information about the currently available ISF files, or a specific one)
                # Argumentos:
                #   --filter [FILTER ...] - String that must be present in the file URI to display the ISF
                #   --isf ISF             - Specific ISF file to process
                #   --validate            - Validate against schema if possible
                #   --live                - Traverse all files, rather than use the cache
                echo ""
                echo "    Aplicando el plugin isinfo..."
                echo ""
                vol -r json -f "$cRutaAlArchivoDeDump" isfinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/isfinfo.json

              # layerwriter (Runs the automagics and writes out the primary layer produced by the stacker)
                # Argumentos:
                #   --block-size BLOCK_SIZE - Size of blocks to copy over
                #   --list                  - List available layers
                #   --layers [LAYERS ...]   - Names of layers to write (defaults to the highest non-mapped layer)
                echo ""
                echo "    Aplicando el plugin layerwriter..."
                echo ""
                mkdir -p "$cCarpetaDondeGuardar"/json/MemoryLayer/
                cd "$cCarpetaDondeGuardar"/json/MemoryLayer/
                vol -f "$cRutaAlArchivoDeDump" layerwriter
                cd ~/repos/python/volatility3

              # regexscan.RegExScan (Scans kernel memory using RegEx patterns)
                # Argumentos:
                #   --pattern PATTERN - RegEx pattern
                #   --maxsize MAXSIZE - Maximum size in bytes for displayed context
                echo ""
                echo "    Aplicando el plugin regexscan.RegExScan..."
                echo ""
                vol -r json -f "$cRutaAlArchivoDeDump" regexscan.RegExScan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/regexscan.RegExScan.json

              # timeliner (Runs all relevant plugins that provide time related information and orders the results by time)
                # Argumentos:
                #   --record-config                     - Whether to record the state of all the plugins once complete
                #   --plugin-filter [PLUGIN-FILTER ...] - Only run plugins featuring this substring
                #   --create-bodyfile                   - Whether to create a body file whilst producing results
                echo ""
                echo "    Aplicando el plugin timeliner..."
                echo ""
                vol -r json -f "$cRutaAlArchivoDeDump" timeliner | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/timeliner.json

            # Desactivar el entorno virtual
              deactivate

        ;;

       18)

          echo ""
          echo "  Buscando IPs privadas de clase A..."
          echo ""
          mkdir -p "$cCarpetaDondeGuardar"/strings/ 2> /dev/null
          strings "$cRutaAlArchivoDeDump" | grep -Eo '10\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])' | sort -n | uniq | tee "$cCarpetaDondeGuardar"/strings/IPsPrivadasDeClaseA.txt

        ;;

       19)

          echo ""
          echo "  Buscando IPs privadas de clase B..."
          echo ""
          mkdir -p "$cCarpetaDondeGuardar"/strings/ 2> /dev/null
          strings "$cRutaAlArchivoDeDump" | grep -Eo '172\.(1[6-9]|2[0-9]|3[0-1])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])' | sort -n | uniq | tee "$cCarpetaDondeGuardar"/strings/IPsPrivadasDeClaseB.txt

        ;;

       20)

          echo ""
          echo "  Buscando IPs privadas de clase C..."
          echo ""
          mkdir -p "$cCarpetaDondeGuardar"/strings/ 2> /dev/null
          strings "$cRutaAlArchivoDeDump" | grep -Eo '192\.168\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])' | sort -n | uniq | tee "$cCarpetaDondeGuardar"/strings/IPsPrivadasDeClaseC.txt

        ;;

       21)

          echo ""
          echo "  Buscando datos POST de LoginForms..."
          echo ""
          mkdir -p "$cCarpetaDondeGuardar"/strings/ 2> /dev/null
          strings "$cRutaAlArchivoDeDump" | grep --color -E 'username=|password=' | tee "$cCarpetaDondeGuardar"/strings/DatosPOSTdeLoginForms.txt

        ;;

       22)

          echo ""
          echo "  Extrayendo el sistema carpetas y archivos de dentro del dump..."
          echo ""

          # Crear carpetas
            mkdir -p "$cCarpetaDondeGuardar"/tab
            mkdir -p "$cCarpetaDondeGuardar"/Archivos/Reales

          # Entrar en el entorno virtual de python
            source ~/repos/python/volatility3/venv/bin/activate

          # Parsear datos

            # windows.filescan (Scans for file objects present in a particular windows memory image)
              echo ""
              echo "    Aplicando el plugin windows.filescan..."
              echo ""
              vol -f "$cRutaAlArchivoDeDump" windows.filescan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.filescan.tab
              # Borrar la línea con las palabras Offset y Name
                sed -i '/Offset.*Name/d' "$cCarpetaDondeGuardar"/tab/windows.filescan.tab
              # Borrar todas las líneas vacias
                sed -i '/^$/d' "$cCarpetaDondeGuardar"/tab/windows.filescan.tab
              # Reemplazar las barras para adaptarlas al sistema de carpetas de Linux
                sed -i 's|\\|/|g' "$cCarpetaDondeGuardar"/tab/windows.filescan.tab

          # Crear el array asociativo y meter dentro todos los offsets y los archivos
            declare -A aOffsetsArchivos
            while IFS=$'\t' read -r key value; do
              aOffsetsArchivos["$key"]="$value"
            done < "$cCarpetaDondeGuardar"/tab/windows.filescan.tab

          # Recorrer el array e ir creando archivos
            for key in "${!aOffsetsArchivos[@]}"; do
              mkdir -p "$cCarpetaDondeGuardar"/Archivos/Reales/"$(dirname "${aOffsetsArchivos[$key]}")" \
              && cd "$cCarpetaDondeGuardar"/Archivos/Reales/"$(dirname "${aOffsetsArchivos[$key]}")" \
              && vol --quiet -f "$cRutaAlArchivoDeDump" -o "$cCarpetaDondeGuardar"/Archivos/Reales/"$(dirname "${aOffsetsArchivos[$key]}")" windows.dumpfiles --virtaddr $key
            done

          # Eliminar la extension .dat a todos los archivos
            find "$cCarpetaDondeGuardar"/Archivos/Reales/ -type f -name "*.dat" | while IFS= read -r vArchivo; do
              # Verificar si el nombre del archivo contiene "DataSectionObject"
                if [[ "$vArchivo" == *"DataSectionObject"* ]]; then
                  # Obtener la nueva ruta sin la extensión .dat
                    vNuevoNombre="${vArchivo%.dat}"
                  # Renombrar el archivo
                    mv "$vArchivo" "$vNuevoNombre"
                fi
            done

          # Eliminar del nombre del archivo todo antes del . de DataSectionObject
            find "$cCarpetaDondeGuardar"/Archivos/Reales/ -type f | while IFS= read -r vArchivo; do
              # Extraer el nombre del archivo
                vNombreArchivo=$(basename "$vArchivo")
              # Verificar si el nombre contiene "DataSectionObject."
                if [[ "$vNombreArchivo" == *"DataSectionObject."* ]]; then
                  # Eliminar todo lo anterior a "DataSectionObject." (incluido)
                    vNuevoNombre="${vNombreArchivo#*DataSectionObject.}"
                  # Obtener la ruta completa del nuevo nombre
                    vDirectorio=$(dirname "$vArchivo")
                    vRutaNueva="$vDirectorio/$vNuevoNombre"
                  # Renombrar el archivo
                    mv "$vArchivo" "$vRutaNueva"
                fi
            done

          # Eliminar la extension .img a todos los archivos
            find "$cCarpetaDondeGuardar"/Archivos/Reales/ -type f -name "*.img" | while IFS= read -r vArchivo; do
              # Verificar si el nombre del archivo contiene "ImageSectionObject"
                if [[ "$vArchivo" == *"ImageSectionObject"* ]]; then
                  # Obtener la nueva ruta sin la extensión .dat
                    vNuevoNombre="${vArchivo%.img}"
                  # Renombrar el archivo
                    mv "$vArchivo" "$vNuevoNombre"
                fi
            done

          # Eliminar del nombre del archivo todo antes del . de ImageSectionObject
            find "$cCarpetaDondeGuardar"/Archivos/Reales/ -type f | while IFS= read -r vArchivo; do
              # Extraer el nombre del archivo
                vNombreArchivo=$(basename "$vArchivo")
              # Verificar si el nombre contiene "ImageSectionObject."
                if [[ "$vNombreArchivo" == *"ImageSectionObject."* ]]; then
                  # Eliminar todo lo anterior a "ImageSectionObject." (incluido)
                    vNuevoNombre="${vNombreArchivo#*ImageSectionObject.}"
                  # Obtener la ruta completa del nuevo nombre
                    vDirectorio=$(dirname "$vArchivo")
                    vRutaNueva="$vDirectorio/$vNuevoNombre"
                  # Renombrar el archivo
                    mv "$vArchivo" "$vRutaNueva"
                fi
            done


            # windows. (Dumps cached file contents from Windows memory samples)
              # Argumentos:
              #  --pid PID           - Process ID to include (all other processes are excluded)
              #  --virtaddr VIRTADDR - Dump a single _FILE_OBJECT at this virtual address
              #  --physaddr PHYSADDR - Dump a single _FILE_OBJECT at this physical address
              #  --filter FILTER     - Dump files matching regular expression FILTER
              #  --ignore-case       - Ignore case in filter match
      #        echo ""
     #         echo "    Aplicando el plugin windows.dumpfiles..."
          #    echo ""
         #     mkdir -p "$cCarpetaDondeGuardar"/Archivos/
        #      cd "$cCarpetaDondeGuardar"/Archivos/
       #       for vExtens in "${aExtensionesAExtraer[@]}"; do
      #          echo -e "\n      Extrayendo todos los archivos $vExtens...\n"
     #           vol -f "$cRutaAlArchivoDeDump" windows.dumpfiles --filter \.$vExtens\$
     #         done
    #          cd ~/repos/python/volatility3
   #           dd if=file.None.0xfffffa8000d06e10.dat of=img.png bs=1 skip=0
              #vol -f "$cRutaAlArchivoDeDump" -o "/path/to/dir" windows.dumpfiles ‑‑pid "<PID>" 
              #vol -f "$cRutaAlArchivoDeDump" -o "/path/to/dir" windows.dumpfiles
              #vol -f "$cRutaAlArchivoDeDump" -o "/path/to/dir" windows.dumpfiles ‑‑virtaddr "<offset>"
              #vol -f "$cRutaAlArchivoDeDump" -o "/path/to/dir" windows.dumpfiles ‑‑physaddr "<offset>"   
              #vol -f "$cRutaAlArchivoDeDump" -o "$cCarpetaDondeGuardar"/Archivos windows.dumpfiles --virtaddr 0xe70f57293860

        ;;

      esac

    done
