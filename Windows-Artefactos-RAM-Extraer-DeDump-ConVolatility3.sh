#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para parsear datos extraidos de la RAM de Windows en Debian
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Windows-Artefactos-RAM-Extraer-DeDump-ConVolatility3.sh | sudo bash -s [RutaAlArchivoConDump]
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Windows-Artefactos-RAM-Extraer-DeDump-ConVolatility3.sh | nano -
# ----------

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
    echo -e "    Ejemplo:"
    echo ""
    echo "    $0 /Casos/a2024m11d24/Dump/RAM.dump /Casos/a2024m11d24/Artefactos"
    echo ""
    exit 1
  fi

# Crear constantes para las carpetas
  cRutaAlArchivoDeDump="$1"
  cCarpetaDondeGuardar="$2"
  mkdir -p "$cCarpetaDondeGuardar"

# Comprobar si existe el repo de volatility3
  if [ ! -d ~/repos/python/volatility3/ ]; then
    echo ""
    echo "  El repo de volatility3 existe. Descargándolo..."
    echo ""
    mkdir -p ~/repos/python/
    cd ~/repos/python/
    # Comprobar si el paquete git está instalado. Si no lo está, instalarlo.
      if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
        echo ""
        echo -e "${cColorRojo}  El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
        echo ""
        sudo apt-get -y update && sudo apt-get -y install git
        echo ""
      fi
    git clone https://github.com/volatilityfoundation/volatility3.git
  fi

# Comprobar si existe el entorno virtual de python de volatility3
  if [ ! -d ~/repos/python/volatility3/venv/ ]; then
    echo ""
    echo "  El entorno virtual de python de volatility3 no existe. Creándolo..."
    echo ""
    cd ~/repos/python/volatility3/
    python3 -m venv venv
  fi

# Entrar en el entorno virtual de python
  source ~/repos/python/volatility3/venv/bin/activate

# Parsear datos

  # Crear carpetas
    mkdir -p "$cCarpetaDondeGuardar"/tab
    mkdir -p "$cCarpetaDondeGuardar"/txt
    mkdir -p "$cCarpetaDondeGuardar"/csv
    mkdir -p "$cCarpetaDondeGuardar"/json

  # windows.amcache (Extract information on executed applications from the AmCache)
    vol           -f "$cRutaAlArchivoDeDump" windows.amcache | grep -v "Volatility 3" >  "$cCarpetaDondeGuardar"/tab/windows.amcache.tab
    vol -r pretty -f "$cRutaAlArchivoDeDump" windows.amcache | grep -v "Volatility 3" >  "$cCarpetaDondeGuardar"/txt/windows.amcache.txt
    vol -r csv    -f "$cRutaAlArchivoDeDump" windows.amcache | grep -v "Volatility 3" >  "$cCarpetaDondeGuardar"/csv/windows.amcache.csv
    vol -r json   -f "$cRutaAlArchivoDeDump" windows.amcache | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.amcache.json

  # windows.bigpools (List big page pools)
    # Argumentos:
    #   --tags TAGS - Comma separated list of pool tags to filter pools returned
    #   --show-free - Show freed regions (otherwise only show allocations in use)
    # En uso
      vol           -f "$cRutaAlArchivoDeDump" windows.bigpools | grep -v "Volatility 3"             >  "$cCarpetaDondeGuardar"/tab/windows.bigpools-enuso.tab
      vol -r pretty -f "$cRutaAlArchivoDeDump" windows.bigpools | grep -v "Volatility 3"             >  "$cCarpetaDondeGuardar"/txt/windows.bigpools-enuso.txt
      vol -r csv    -f "$cRutaAlArchivoDeDump" windows.bigpools | grep -v "Volatility 3"             >  "$cCarpetaDondeGuardar"/csv/windows.bigpools-enuso.csv
      vol -r json   -f "$cRutaAlArchivoDeDump" windows.bigpools | grep -v "Volatility 3"             > "$cCarpetaDondeGuardar"/json/windows.bigpools-enuso.json
    # En uso y libres
      vol           -f "$cRutaAlArchivoDeDump" windows.bigpools --show-free | grep -v "Volatility 3" >  "$cCarpetaDondeGuardar"/tab/windows.bigpools-enusoylibres.tab
      vol -r pretty -f "$cRutaAlArchivoDeDump" windows.bigpools --show-free | grep -v "Volatility 3" >  "$cCarpetaDondeGuardar"/txt/windows.bigpools-enusoylibres.txt
      vol -r csv    -f "$cRutaAlArchivoDeDump" windows.bigpools --show-free | grep -v "Volatility 3" >  "$cCarpetaDondeGuardar"/csv/windows.bigpools-enusoylibres.csv
      vol -r json   -f "$cRutaAlArchivoDeDump" windows.bigpools --show-free | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.bigpools-enusoylibres.json

  # windows.callbacks (Lists kernel callbacks and notification routines)
    vol           -f "$cRutaAlArchivoDeDump" windows.callbacks | grep -v "Volatility 3" >  "$cCarpetaDondeGuardar"/tab/windows.callbacks.tab
    vol -r pretty -f "$cRutaAlArchivoDeDump" windows.callbacks | grep -v "Volatility 3" >  "$cCarpetaDondeGuardar"/txt/windows.callbacks.txt
    vol -r csv    -f "$cRutaAlArchivoDeDump" windows.callbacks | grep -v "Volatility 3" >  "$cCarpetaDondeGuardar"/csv/windows.callbacks.csv
    vol -r json   -f "$cRutaAlArchivoDeDump" windows.callbacks | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.callbacks.json

  # windows.cmdline (Lists process command line arguments)
    # Argumentos:
    #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
    vol           -f "$cRutaAlArchivoDeDump" windows.cmdline | grep -v "Volatility 3" >  "$cCarpetaDondeGuardar"/tab/windows.cmdline.tab
    vol -r pretty -f "$cRutaAlArchivoDeDump" windows.cmdline | grep -v "Volatility 3" >  "$cCarpetaDondeGuardar"/txt/windows.cmdline.txt
    vol -r csv    -f "$cRutaAlArchivoDeDump" windows.cmdline | grep -v "Volatility 3" >  "$cCarpetaDondeGuardar"/csv/windows.cmdline.csv
    vol -r json   -f "$cRutaAlArchivoDeDump" windows.cmdline | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.cmdline.json






  # windows.cmdscan (Looks for Windows Command History lists)
    # Argumentos:
    #   --no-registry                   - Don't search the registry for possible values of CommandHistorySize
    #   --max-history [MAX_HISTORY ...] - CommandHistorySize values to search for.
    vol -f "$cRutaAlArchivoDeDump" windows.cmdscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.cmdscan.tab
    vol -f "$cRutaAlArchivoDeDump" windows.cmdscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.cmdscan.tab
    vol -f "$cRutaAlArchivoDeDump" windows.cmdscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.cmdscan.csv
    vol -f "$cRutaAlArchivoDeDump" windows.cmdscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.cmdscan.json

  # windows.consoles (Looks for Windows console buffers)
    # Argumentos:
    #   --no-registry                   - Don't search the registry for possible values of CommandHistorySize and HistoryBufferMax
    #   --max-history [MAX_HISTORY ...] - CommandHistorySize values to search for.
    #   --max-buffers [MAX_BUFFERS ...] - HistoryBufferMax values to search for.
    vol -f "$cRutaAlArchivoDeDump" windows.consoles | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.consoles.tab
    vol -f "$cRutaAlArchivoDeDump" windows.consoles | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.consoles.tab
    vol -f "$cRutaAlArchivoDeDump" windows.consoles | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.consoles.csv
    vol -f "$cRutaAlArchivoDeDump" windows.consoles | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.consoles.json

  # windows.crashinfo (Lists the information from a Windows crash dump)
    vol -f "$cRutaAlArchivoDeDump" windows.crashinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.crashinfo.tab
    vol -f "$cRutaAlArchivoDeDump" windows.crashinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.crashinfo.tab
    vol -f "$cRutaAlArchivoDeDump" windows.crashinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.crashinfo.csv
    vol -f "$cRutaAlArchivoDeDump" windows.crashinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.crashinfo.json

  # windows.debugregisters ()
    vol -f "$cRutaAlArchivoDeDump" windows.debugregisters | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.debugregisters.tab
    vol -f "$cRutaAlArchivoDeDump" windows.debugregisters | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.debugregisters.tab
    vol -f "$cRutaAlArchivoDeDump" windows.debugregisters | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.debugregisters.csv
    vol -f "$cRutaAlArchivoDeDump" windows.debugregisters | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.debugregisters.json

  # windows.devicetree (Listing tree based on drivers and attached devices in a particular windows memory image)
    vol -f "$cRutaAlArchivoDeDump" windows.devicetree | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.devicetree.tab
    vol -f "$cRutaAlArchivoDeDump" windows.devicetree | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.devicetree.tab
    vol -f "$cRutaAlArchivoDeDump" windows.devicetree | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/csv/windows.devicetree.csv
    vol -f "$cRutaAlArchivoDeDump" windows.devicetree | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.devicetree.json

  # windows.dlllist (Lists the loaded modules in a particular windows memory image)
    # Argumentos:
    #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
    #   --offset OFFSET - Process offset in the physical address space
    #   --name NAME     - Specify a regular expression to match dll name(s)
    #   --base BASE     - Specify a base virtual address in process memory
    #   --ignore-case   - Specify case insensitivity for the regular expression name matching
    #   --dump          - Extract listed DLLs
    vol -f "$cRutaAlArchivoDeDump" windows.dlllist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.dlllist.tab
    vol -f "$cRutaAlArchivoDeDump" windows.dlllist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.dlllist.tab
    vol -f "$cRutaAlArchivoDeDump" windows.dlllist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.dlllist.tab
    vol -f "$cRutaAlArchivoDeDump" windows.dlllist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.dlllist.json

  # windows.driverirp (List IRPs for drivers in a particular windows memory image)
    vol -f "$cRutaAlArchivoDeDump" windows.driverirp | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.driverirp.tab
    vol -f "$cRutaAlArchivoDeDump" windows.driverirp | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.driverirp.tab
    vol -f "$cRutaAlArchivoDeDump" windows.driverirp | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.driverirp.tab
    vol -f "$cRutaAlArchivoDeDump" windows.driverirp | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.driverirp.json

  # windows.drivermodule (Determines if any loaded drivers were hidden by a rootkit)
    vol -f "$cRutaAlArchivoDeDump" windows.drivermodule | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.drivermodule.tab
    vol -f "$cRutaAlArchivoDeDump" windows.drivermodule | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.drivermodule.tab
    vol -f "$cRutaAlArchivoDeDump" windows.drivermodule | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.drivermodule.tab
    vol -f "$cRutaAlArchivoDeDump" windows.drivermodule | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.drivermodule.json

  # windows.driverscan (Scans for drivers present in a particular windows memory image)
    vol -f "$cRutaAlArchivoDeDump" windows.driverscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.driverscan.tab
    vol -f "$cRutaAlArchivoDeDump" windows.driverscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.driverscan.tab
    vol -f "$cRutaAlArchivoDeDump" windows.driverscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.driverscan.tab
    vol -f "$cRutaAlArchivoDeDump" windows.driverscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.driverscan.json

  # windows.dumfiles (Dumps cached file contents from Windows memory samples)
    # Argumentos:
    #  --pid PID           - Process ID to include (all other processes are excluded)
    #  --virtaddr VIRTADDR - Dump a single _FILE_OBJECT at this virtual address
    #  --physaddr PHYSADDR - Dump a single _FILE_OBJECT at this physical address
    #  --filter FILTER     - Dump files matching regular expression FILTER
    #  --ignore-case       - Ignore case in filter match
    mkdir -p ~/ArtefactosRAM/Archivos
    cd ~/ArtefactosRAM/Archivos/
    aExtensiones=("jpg" "png" "gif" "txt" "pdf")
    for vExtens in "${aExtensiones[@]}"; do
      echo -e "\n  Extrayendo todos los archivos $vExtens...\n"
      vol -f "$cRutaAlArchivoDeDump" windows.dumpfiles --filter \.$vExtens\$
    done
    cd ..
    dd if=file.None.0xfffffa8000d06e10.dat of=img.png bs=1 skip=0

  # windows.envars (Display process environment variables)
    # Argumentos:
    #   --pid [PID ...] - Filter on specific process IDs
    #   --silent        - Suppress common and non-persistent variables
    vol -f "$cRutaAlArchivoDeDump" windows.envars | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.envars.tab
    vol -f "$cRutaAlArchivoDeDump" windows.envars | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.envars.tab
    vol -f "$cRutaAlArchivoDeDump" windows.envars | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.envars.tab
    vol -f "$cRutaAlArchivoDeDump" windows.envars | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.envars.json

  # windows.filescan (Scans for file objects present in a particular windows memory image)
    vol -f "$cRutaAlArchivoDeDump" windows.filescan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.filescan.tab
    vol -f "$cRutaAlArchivoDeDump" windows.filescan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.filescan.tab
    vol -f "$cRutaAlArchivoDeDump" windows.filescan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.filescan.tab
    vol -f "$cRutaAlArchivoDeDump" windows.filescan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.filescan.json

  # windows.getservicesids ()
    vol -f "$cRutaAlArchivoDeDump" windows.getservicesids | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.getservicesids.tab
    vol -f "$cRutaAlArchivoDeDump" windows.getservicesids | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.getservicesids.tab
    vol -f "$cRutaAlArchivoDeDump" windows.getservicesids | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.getservicesids.tab
    vol -f "$cRutaAlArchivoDeDump" windows.getservicesids | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.getservicesids.json

  # windows.getsids (Lists process token sids)
    # Argumentos:
    #   --pid [PID ...] - Filter on specific process IDs
    vol -f "$cRutaAlArchivoDeDump" windows.getsids | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.getsids.tab
    vol -f "$cRutaAlArchivoDeDump" windows.getsids | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.getsids.tab
    vol -f "$cRutaAlArchivoDeDump" windows.getsids | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.getsids.tab
    vol -f "$cRutaAlArchivoDeDump" windows.getsids | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.getsids.json

  # windows.handles (Lists process open handles)
    # Argumentos:
    #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
    #   --offset OFFSET - Process offset in the physical address space
    vol -f "$cRutaAlArchivoDeDump" windows.handles | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.handles.tab
    vol -f "$cRutaAlArchivoDeDump" windows.handles | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.handles.tab
    vol -f "$cRutaAlArchivoDeDump" windows.handles | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.handles.tab
    vol -f "$cRutaAlArchivoDeDump" windows.handles | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.handles.json

  # windows.hollowprocesses (Lists hollowed processes)
    # Argumentos:
    #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
    vol -f "$cRutaAlArchivoDeDump" windows.hollowprocesses | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.hollowprocesses.tab
    vol -f "$cRutaAlArchivoDeDump" windows.hollowprocesses | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.hollowprocesses.tab
    vol -f "$cRutaAlArchivoDeDump" windows.hollowprocesses | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.hollowprocesses.tab
    vol -f "$cRutaAlArchivoDeDump" windows.hollowprocesses | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.hollowprocesses.json

  # windows.iat (Extract Import Address Table to list API (functions) used by a program contained in external libraries)
    # Argumentos:
    #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
    vol -f "$cRutaAlArchivoDeDump" windows.iat | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.iat.tab
    vol -f "$cRutaAlArchivoDeDump" windows.iat | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.iat.tab
    vol -f "$cRutaAlArchivoDeDump" windows.iat | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.iat.tab
    vol -f "$cRutaAlArchivoDeDump" windows.iat | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.iat.json

  # windows.info (Show OS & kernel details of the memory sample being analyzed)
    vol -f "$cRutaAlArchivoDeDump" windows.info | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.info.tab
    vol -f "$cRutaAlArchivoDeDump" windows.info | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.info.tab
    vol -f "$cRutaAlArchivoDeDump" windows.info | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.info.tab
    vol -f "$cRutaAlArchivoDeDump" windows.info | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.info.json

  # windows.joblinks (Print process job link information)
    # Argumentos:
    #   --physical - Display physical offset instead of virtual
    # Offset virtual
      vol -f "$cRutaAlArchivoDeDump" windows.joblinks | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.joblinks-offsetvirtual.tab
      vol -f "$cRutaAlArchivoDeDump" windows.joblinks | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.joblinks-offsetvirtual.tab
      vol -f "$cRutaAlArchivoDeDump" windows.joblinks | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.joblinks-offsetvirtual.tab
      vol -f "$cRutaAlArchivoDeDump" windows.joblinks | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.joblinks-offsetvirtual.json
    # Offset físico
      vol --physical -f "$cRutaAlArchivoDeDump" windows.joblinks | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.joblinks-offsetfisico.tab
      vol --physical -f "$cRutaAlArchivoDeDump" windows.joblinks | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.joblinks-offsetfisico.tab
      vol --physical -f "$cRutaAlArchivoDeDump" windows.joblinks | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.joblinks-offsetfisico.tab
      vol --physical -f "$cRutaAlArchivoDeDump" windows.joblinks | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.joblinks-offsetfisico.json

  # windows.kpcrs (Print KPCR structure for each processor)
    vol -f "$cRutaAlArchivoDeDump" windows.kpcrs | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.kpcrs.tab
    vol -f "$cRutaAlArchivoDeDump" windows.kpcrs | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.kpcrs.tab
    vol -f "$cRutaAlArchivoDeDump" windows.kpcrs | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.kpcrs.tab
    vol -f "$cRutaAlArchivoDeDump" windows.kpcrs | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.kpcrs.json

  # windows.ldrmodules (Lists the loaded modules in a particular windows memory image)
    # Argumentos:
    #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
    vol -f "$cRutaAlArchivoDeDump" windows.ldrmodules | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.ldrmodules.tab
    vol -f "$cRutaAlArchivoDeDump" windows.ldrmodules | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.ldrmodules.tab
    vol -f "$cRutaAlArchivoDeDump" windows.ldrmodules | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.ldrmodules.tab
    vol -f "$cRutaAlArchivoDeDump" windows.ldrmodules | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.ldrmodules.json

  # windows.malfind (Lists process memory ranges that potentially contain injected code)
    vol -f "$cRutaAlArchivoDeDump" windows.malfind | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.malfind.tab
    vol -f "$cRutaAlArchivoDeDump" windows.malfind | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.malfind.tab
    vol -f "$cRutaAlArchivoDeDump" windows.malfind | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.malfind.tab
    vol -f "$cRutaAlArchivoDeDump" windows.malfind | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.malfind.json

  # windows.mbrscan (Scans for and parses potential Master Boot Records (MBRs))
    # Argumentos:
    #   --full - It analyzes and provides all the information in the partition entry and bootcode hexdump. (It returns a lot of information, so we recommend you render it in CSV.)
    # Simple
      vol -f "$cRutaAlArchivoDeDump" windows.mbrscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.mbrscan.tab
      vol -f "$cRutaAlArchivoDeDump" windows.mbrscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.mbrscan.tab
      vol -f "$cRutaAlArchivoDeDump" windows.mbrscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.mbrscan.tab
      vol -f "$cRutaAlArchivoDeDump" windows.mbrscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.mbrscan.json
    # Completo
      vol --full -f "$cRutaAlArchivoDeDump" windows.mbrscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.mbrscan-full.tab
      vol --full -f "$cRutaAlArchivoDeDump" windows.mbrscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.mbrscan-full.tab
      vol --full -f "$cRutaAlArchivoDeDump" windows.mbrscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.mbrscan-full.tab
      vol --full -f "$cRutaAlArchivoDeDump" windows.mbrscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.mbrscan-full.json

  # windows.memmap (Prints the memory map)
    # Argumentos:
    #   --pid PID - Process ID to include (all other processes are excluded)
    #   --dump    - Extract listed memory segments
    vol -f "$cRutaAlArchivoDeDump" windows.memmap | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.memmap.tab
    vol -f "$cRutaAlArchivoDeDump" windows.memmap | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.memmap.tab
    vol -f "$cRutaAlArchivoDeDump" windows.memmap | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.memmap.tab
    vol -f "$cRutaAlArchivoDeDump" windows.memmap | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.memmap.json

  # windows.modscan (Scans for modules present in a particular windows memory image)
    # Argumentos:
    #   --dump      - Extract listed modules
    #   --base BASE - Extract a single module with BASE address
    #   --name NAME - module name/sub string
    vol -f "$cRutaAlArchivoDeDump" windows.modscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.modscan.tab
    vol -f "$cRutaAlArchivoDeDump" windows.modscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.modscan.tab
    vol -f "$cRutaAlArchivoDeDump" windows.modscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.modscan.tab
    vol -f "$cRutaAlArchivoDeDump" windows.modscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.modscan.json

  # windows.modules (Lists the loaded kernel modules)
    # Argumentos:
    #   --dump      - Extract listed modules
    #   --base BASE - Extract a single module with BASE address
    #   --name NAME - module name/sub string
    vol -f "$cRutaAlArchivoDeDump" windows.modules | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.modules.tab
    vol -f "$cRutaAlArchivoDeDump" windows.modules | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.modules.tab
    vol -f "$cRutaAlArchivoDeDump" windows.modules | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.modules.tab
    vol -f "$cRutaAlArchivoDeDump" windows.modules | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.modules.json

  # windows.mutantscan (Scans for mutexes present in a particular windows memory image)
    vol -f "$cRutaAlArchivoDeDump" windows.mutantscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.mutantscan.tab
    vol -f "$cRutaAlArchivoDeDump" windows.mutantscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.mutantscan.tab
    vol -f "$cRutaAlArchivoDeDump" windows.mutantscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.mutantscan.tab
    vol -f "$cRutaAlArchivoDeDump" windows.mutantscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.mutantscan.json

  # windows.netscan (Scans for network objects present in a particular windows memory image)
    # Argumentos:
    #   --include-corrupt - Radically eases result validation. This will show partially overwritten data. WARNING: the results are likely to include garbage and/or corrupt data. Be cautious!
    # Sin corruptos
      vol -f "$cRutaAlArchivoDeDump" windows.netscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.netscan.tab
      vol -f "$cRutaAlArchivoDeDump" windows.netscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.netscan.tab
      vol -f "$cRutaAlArchivoDeDump" windows.netscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.netscan.tab
      vol -f "$cRutaAlArchivoDeDump" windows.netscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.netscan.json
    # Con corruptos
      vol --include-corrupt -f "$cRutaAlArchivoDeDump" windows.netscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.netscan-corrupt.tab
      vol --include-corrupt -f "$cRutaAlArchivoDeDump" windows.netscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.netscan-corrupt.tab
      vol --include-corrupt -f "$cRutaAlArchivoDeDump" windows.netscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.netscan-corrupt.tab
      vol --include-corrupt -f "$cRutaAlArchivoDeDump" windows.netscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.netscan-corrupt.json

  # windows.netstat (Traverses network tracking structures present in a particular windows memory image)
    # Argumentos:
    #   --include-corrupt - Radically eases result validation. This will show partially overwritten data. WARNING: the results are likely to include garbage and/or corrupt data. Be cautious!
    # Sin corruptos
      vol -f "$cRutaAlArchivoDeDump" windows.netstat | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.netstat.tab
      vol -f "$cRutaAlArchivoDeDump" windows.netstat | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.netstat.tab
      vol -f "$cRutaAlArchivoDeDump" windows.netstat | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.netstat.tab
      vol -f "$cRutaAlArchivoDeDump" windows.netstat | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.netstat.json
    # Con corruptos
      vol -f "$cRutaAlArchivoDeDump" windows.netstat | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.netstat-corrupt.tab
      vol -f "$cRutaAlArchivoDeDump" windows.netstat | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.netstat-corrupt.tab
      vol -f "$cRutaAlArchivoDeDump" windows.netstat | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.netstat-corrupt.tab
      vol -f "$cRutaAlArchivoDeDump" windows.netstat | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.netstat-corrupt.json

  # windows.orphan_kernel_threads (Lists process threads)
    vol -f "$cRutaAlArchivoDeDump" windows.orphan_kernel_threads | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.orphan_kernel_threads.tab
    vol -f "$cRutaAlArchivoDeDump" windows.orphan_kernel_threads | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.orphan_kernel_threads.tab
    vol -f "$cRutaAlArchivoDeDump" windows.orphan_kernel_threads | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.orphan_kernel_threads.tab
    vol -f "$cRutaAlArchivoDeDump" windows.orphan_kernel_threads | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.orphan_kernel_threads.json

  # windows.pe_symbols (Prints symbols in PE files in process and kernel memory)
    # Argumentos:
    #   --source {kernel,processes} - Where to resolve symbols.
    #   --module MODULE             - Module in which to resolve symbols. Use "ntoskrnl.exe" to resolve in the base kernel executable.
    #   --symbols [SYMBOLS ...]     - Symbol name to resolve
    #   --addresses [ADDRESSES ...] - Address of symbol to resolve
    vol -f "$cRutaAlArchivoDeDump" windows.pe_symbols | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.pe_symbols.tab
    vol -f "$cRutaAlArchivoDeDump" windows.pe_symbols | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.pe_symbols.tab
    vol -f "$cRutaAlArchivoDeDump" windows.pe_symbols | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.pe_symbols.tab
    vol -f "$cRutaAlArchivoDeDump" windows.pe_symbols | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.pe_symbols.json

  # windows.pedump (Allows extracting PE Files from a specific address in a specific address space)
    # Argumentos:
    #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
    #   --base BASE     - Base address to reconstruct a PE file
    #   --kernel-module - Extract from kernel address space.
    vol -f "$cRutaAlArchivoDeDump" windows.pedump | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.pedump.tab
    vol -f "$cRutaAlArchivoDeDump" windows.pedump | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.pedump.tab
    vol -f "$cRutaAlArchivoDeDump" windows.pedump | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.pedump.tab
    vol -f "$cRutaAlArchivoDeDump" windows.pedump | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.pedump.json

  # windows.poolscanner (A generic pool scanner plugin)
    vol -f "$cRutaAlArchivoDeDump" windows.poolscanner | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.poolscanner.tab
    vol -f "$cRutaAlArchivoDeDump" windows.poolscanner | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.poolscanner.tab
    vol -f "$cRutaAlArchivoDeDump" windows.poolscanner | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.poolscanner.tab
    vol -f "$cRutaAlArchivoDeDump" windows.poolscanner | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.poolscanner.json

  # windows.privileges (Lists process token privileges)
    # Argumentos:
    #   --pid [PID ...] - Filter on specific process IDs
    vol -f "$cRutaAlArchivoDeDump" windows.privileges | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.privileges.tab
    vol -f "$cRutaAlArchivoDeDump" windows.privileges | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.privileges.tab
    vol -f "$cRutaAlArchivoDeDump" windows.privileges | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.privileges.tab
    vol -f "$cRutaAlArchivoDeDump" windows.privileges | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.privileges.json

  # windows.processghosting (Lists processes whose DeletePending bit is set or whose FILE_OBJECT is set to 0)
    vol -f "$cRutaAlArchivoDeDump" windows.processghosting | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.processghosting.tab
    vol -f "$cRutaAlArchivoDeDump" windows.processghosting | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.processghosting.tab
    vol -f "$cRutaAlArchivoDeDump" windows.processghosting | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.processghosting.tab
    vol -f "$cRutaAlArchivoDeDump" windows.processghosting | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.processghosting.json

  # windows.pslist (Lists the processes present in a particular windows memory image)
    # Argumentos:
    #   --physical      - Display physical offsets instead of virtual
    #   --pid [PID ...] - Process ID to include (all other processes are excluded)
    #   --dump          - Extract listed processes
    # Offset virtual
      vol -f "$cRutaAlArchivoDeDump" windows.pslist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.pslist-offsetvirtual.tab
      vol -f "$cRutaAlArchivoDeDump" windows.pslist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.pslist-offsetvirtual.tab
      vol -f "$cRutaAlArchivoDeDump" windows.pslist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.pslist-offsetvirtual.tab
      vol -f "$cRutaAlArchivoDeDump" windows.pslist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.pslist-offsetvirtual.json
    # Offset físico
      vol --physical -f "$cRutaAlArchivoDeDump" windows.pslist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.pslist-offsetfisico.tab
      vol --physical -f "$cRutaAlArchivoDeDump" windows.pslist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.pslist-offsetfisico.tab
      vol --physical -f "$cRutaAlArchivoDeDump" windows.pslist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.pslist-offsetfisico.tab
      vol --physical -f "$cRutaAlArchivoDeDump" windows.pslist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.pslist-offsetfisico.json

  # windows.psscan (Scans for processes present in a particular windows memory image)
    # Argumentos:
    #   --physical      - Display physical offsets instead of virtual
    #   --pid [PID ...] - Process ID to include (all other processes are excluded)
    #   --dump          - Extract listed processes
    # Offset virtual
      vol -f "$cRutaAlArchivoDeDump" windows.psscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.psscan-offsetvirtual.tab
      vol -f "$cRutaAlArchivoDeDump" windows.psscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.psscan-offsetvirtual.tab
      vol -f "$cRutaAlArchivoDeDump" windows.psscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.psscan-offsetvirtual.tab
      vol -f "$cRutaAlArchivoDeDump" windows.psscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.psscan-offsetvirtual.json
    # Offset físico
      vol --physical -f "$cRutaAlArchivoDeDump" windows.psscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.psscan-offsetfisico.tab
      vol --physical -f "$cRutaAlArchivoDeDump" windows.psscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.psscan-offsetfisico.tab
      vol --physical -f "$cRutaAlArchivoDeDump" windows.psscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.psscan-offsetfisico.tab
      vol --physical -f "$cRutaAlArchivoDeDump" windows.psscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.psscan-offsetfisico.json

  # windows.pstree (Plugin for listing processes in a tree based on their parent process ID)
    # Argumentos:
    #   --physical      - Display physical offsets instead of virtual
    #   --pid [PID ...] - Process ID to include (all other processes are excluded)
    # Offset virtual
      vol -f "$cRutaAlArchivoDeDump" windows.pstree | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.pstree-offsetvirtual.tab
      vol -f "$cRutaAlArchivoDeDump" windows.pstree | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.pstree-offsetvirtual.tab
      vol -f "$cRutaAlArchivoDeDump" windows.pstree | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.pstree-offsetvirtual.tab
      vol -f "$cRutaAlArchivoDeDump" windows.pstree | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.pstree-offsetvirtual.json
    # Offset físico
      vol --physical -f "$cRutaAlArchivoDeDump" windows.pstree | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.pstree-offsetfisico.tab
      vol --physical -f "$cRutaAlArchivoDeDump" windows.pstree | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.pstree-offsetfisico.tab
      vol --physical -f "$cRutaAlArchivoDeDump" windows.pstree | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.pstree-offsetfisico.tab
      vol --physical -f "$cRutaAlArchivoDeDump" windows.pstree | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.pstree-offsetfisico.json

  # windows.psxview (Lists all processes found via four of the methods described in "The Art of Memory Forensics," which may help identify processes that are trying to hide themselves. I recommend using -r pretty if you are looking at this plugin's output in a terminal)
    # Argumentos:
    # --physical-offsets - List processes with physical offsets instead of virtual offsets.
    # Offsets virtuales
      vol -f "$cRutaAlArchivoDeDump" windows.psxview | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.psxview-offsetsvirtuales.tab
      vol -f "$cRutaAlArchivoDeDump" windows.psxview | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.psxview-offsetsvirtuales.tab
      vol -f "$cRutaAlArchivoDeDump" windows.psxview | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.psxview-offsetsvirtuales.tab
      vol -f "$cRutaAlArchivoDeDump" windows.psxview | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.psxview-offsetsvirtuales.json
    # Offsets físicos
      vol --physical-offsets -f "$cRutaAlArchivoDeDump" windows.psxview | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.psxview-offsetsfisicos.tab
      vol --physical-offsets -f "$cRutaAlArchivoDeDump" windows.psxview | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.psxview-offsetsfisicos.tab
      vol --physical-offsets -f "$cRutaAlArchivoDeDump" windows.psxview | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.psxview-offsetsfisicos.tab
      vol --physical-offsets -f "$cRutaAlArchivoDeDump" windows.psxview | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.psxview-offsetsfisicos.json

  # windows.registry.certificates (Lists the certificates in the registry's Certificate Store)
    # Argumentos:
    #   --dump - Extract listed certificates
    vol -f "$cRutaAlArchivoDeDump" windows.registry.certificates | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.registry.certificates.tab
    vol -f "$cRutaAlArchivoDeDump" windows.registry.certificates | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.registry.certificates.tab
    vol -f "$cRutaAlArchivoDeDump" windows.registry.certificates | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.registry.certificates.tab
    vol -f "$cRutaAlArchivoDeDump" windows.registry.certificates | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.registry.certificates.json

  # windows.registry.getcellroutine (Reports registry hives with a hooked GetCellRoutine handler)
    vol -f "$cRutaAlArchivoDeDump" windows.registry.getcellroutine | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.registry.getcellroutine.tab
    vol -f "$cRutaAlArchivoDeDump" windows.registry.getcellroutine | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.registry.getcellroutine.tab
    vol -f "$cRutaAlArchivoDeDump" windows.registry.getcellroutine | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.registry.getcellroutine.tab
    vol -f "$cRutaAlArchivoDeDump" windows.registry.getcellroutine | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.registry.getcellroutine.json

  # windows.registry.hivelist (Lists the registry hives present in a particular memory image)
    # Argumentos:
    #   --filter FILTER - String to filter hive names returned
    #   --dump          - Extract listed registry hives
    vol -f "$cRutaAlArchivoDeDump" windows.registry.hivelist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.registry.hivelist.tab
    vol -f "$cRutaAlArchivoDeDump" windows.registry.hivelist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.registry.hivelist.tab
    vol -f "$cRutaAlArchivoDeDump" windows.registry.hivelist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.registry.hivelist.tab
    vol -f "$cRutaAlArchivoDeDump" windows.registry.hivelist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.registry.hivelist.json

  # windows.registry.hivescan (Scans for registry hives present in a particular windows memory image)
    vol -f "$cRutaAlArchivoDeDump" windows.registry.hivescan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.registry.hivescan.tab
    vol -f "$cRutaAlArchivoDeDump" windows.registry.hivescan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.registry.hivescan.tab
    vol -f "$cRutaAlArchivoDeDump" windows.registry.hivescan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.registry.hivescan.tab
    vol -f "$cRutaAlArchivoDeDump" windows.registry.hivescan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.registry.hivescan.json


  # windows.registry.printkey (Lists the registry keys under a hive or specific key value)
    # Argumentos:
    #   --offset OFFSET - Hive Offset
    #   --key KEY       - Key to start from
    #   --recurse       - Recurses through keys
    vol -f "$cRutaAlArchivoDeDump" windows.registry.printkey | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.registry.printkey.tab
    vol -f "$cRutaAlArchivoDeDump" windows.registry.printkey | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.registry.printkey.tab
    vol -f "$cRutaAlArchivoDeDump" windows.registry.printkey | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.registry.printkey.tab
    vol -f "$cRutaAlArchivoDeDump" windows.registry.printkey | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.registry.printkey.json

  # windows.registry.userassist (Print userassist registry keys and information)
    # Argumentos:
    #   --offset OFFSET - Hive Offset
    vol -f "$cRutaAlArchivoDeDump" windows.registry.userassist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.registry.userassist.tab
    vol -f "$cRutaAlArchivoDeDump" windows.registry.userassist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.registry.userassist.tab
    vol -f "$cRutaAlArchivoDeDump" windows.registry.userassist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.registry.userassist.tab
    vol -f "$cRutaAlArchivoDeDump" windows.registry.userassist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.registry.userassist.json

  # windows.scheduled_tasks (Decodes scheduled task information from the Windows registry, including information about triggers, actions, run times, and creation times)
    vol -f "$cRutaAlArchivoDeDump" windows.scheduled_tasks | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.scheduled_tasks.tab
    vol -f "$cRutaAlArchivoDeDump" windows.scheduled_tasks | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.scheduled_tasks.tab
    vol -f "$cRutaAlArchivoDeDump" windows.scheduled_tasks | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.scheduled_tasks.tab
    vol -f "$cRutaAlArchivoDeDump" windows.scheduled_tasks | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.scheduled_tasks.json

  # windows.sessions (lists Processes with Session information extracted from Environmental Variables)
    # Argumentos:
    #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
    vol -f "$cRutaAlArchivoDeDump" windows.sessions | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.sessions.tab
    vol -f "$cRutaAlArchivoDeDump" windows.sessions | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.sessions.tab
    vol -f "$cRutaAlArchivoDeDump" windows.sessions | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.sessions.tab
    vol -f "$cRutaAlArchivoDeDump" windows.sessions | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.sessions.json

  # windows.shimcachemem (Reads Shimcache entries from the ahcache.sys AVL tree)
    vol -f "$cRutaAlArchivoDeDump" windows.shimcachemem | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.shimcachemem.tab
    vol -f "$cRutaAlArchivoDeDump" windows.shimcachemem | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.shimcachemem.tab
    vol -f "$cRutaAlArchivoDeDump" windows.shimcachemem | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.shimcachemem.tab
    vol -f "$cRutaAlArchivoDeDump" windows.shimcachemem | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.shimcachemem.json

  # windows.skeleton_key_check (Looks for signs of Skeleton Key malware)
    vol -f "$cRutaAlArchivoDeDump" windows.skeleton_key_check | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.skeleton_key_check.tab
    vol -f "$cRutaAlArchivoDeDump" windows.skeleton_key_check | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.skeleton_key_check.tab
    vol -f "$cRutaAlArchivoDeDump" windows.skeleton_key_check | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.skeleton_key_check.tab
    vol -f "$cRutaAlArchivoDeDump" windows.skeleton_key_check | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.skeleton_key_check.json

  # windows.ssdt (Lists the system call table)
    vol -f "$cRutaAlArchivoDeDump" windows.ssdt | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.ssdt.tab
    vol -f "$cRutaAlArchivoDeDump" windows.ssdt | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.ssdt.tab
    vol -f "$cRutaAlArchivoDeDump" windows.ssdt | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.ssdt.tab
    vol -f "$cRutaAlArchivoDeDump" windows.ssdt | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.ssdt.json

  # windows.statistics (Lists statistics about the memory space)
    vol -f "$cRutaAlArchivoDeDump" windows.statistics | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.statistics.tab
    vol -f "$cRutaAlArchivoDeDump" windows.statistics | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.statistics.tab
    vol -f "$cRutaAlArchivoDeDump" windows.statistics | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.statistics.tab
    vol -f "$cRutaAlArchivoDeDump" windows.statistics | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.statistics.json

  # windows.strings (Reads output from the strings command and indicates which process(es) each string belongs to)
    # Argumentos:
    #   --pid [PID ...]             - Process ID to include (all other processes are excluded)
    #   --strings-file STRINGS_FILE - Strings file
    vol -f "$cRutaAlArchivoDeDump" windows.strings | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.strings.tab
    vol -f "$cRutaAlArchivoDeDump" windows.strings | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.strings.tab
    vol -f "$cRutaAlArchivoDeDump" windows.strings | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.strings.tab
    vol -f "$cRutaAlArchivoDeDump" windows.strings | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.strings.json

  # windows.suspicious_threads (Lists suspicious userland process threads)
    # Argumentos:
    #   --pid [PID ...] - Filter on specific process IDs
    vol -f "$cRutaAlArchivoDeDump" windows.suspicious_threads | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.suspicious_threads.tab
    vol -f "$cRutaAlArchivoDeDump" windows.suspicious_threads | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.suspicious_threads.tab
    vol -f "$cRutaAlArchivoDeDump" windows.suspicious_threads | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.suspicious_threads.tab
    vol -f "$cRutaAlArchivoDeDump" windows.suspicious_threads | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.suspicious_threads.json

  # windows.svcdiff (Compares services found through list walking versus scanning to find rootkits)
    vol -f "$cRutaAlArchivoDeDump" windows.svcdiff | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.svcdiff.tab
    vol -f "$cRutaAlArchivoDeDump" windows.svcdiff | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.svcdiff.tab
    vol -f "$cRutaAlArchivoDeDump" windows.svcdiff | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.svcdiff.tab
    vol -f "$cRutaAlArchivoDeDump" windows.svcdiff | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.svcdiff.json

  # windows.svclist (Lists services contained with the services.exe doubly linked list of services)
    vol -f "$cRutaAlArchivoDeDump" windows.svclist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.svclist.tab
    vol -f "$cRutaAlArchivoDeDump" windows.svclist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.svclist.tab
    vol -f "$cRutaAlArchivoDeDump" windows.svclist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.svclist.tab
    vol -f "$cRutaAlArchivoDeDump" windows.svclist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.svclist.json

  # windows.svcscan (Scans for windows services)
    vol -f "$cRutaAlArchivoDeDump" windows.svcscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.svcscan.tab
    vol -f "$cRutaAlArchivoDeDump" windows.svcscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.svcscan.tab
    vol -f "$cRutaAlArchivoDeDump" windows.svcscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.svcscan.tab
    vol -f "$cRutaAlArchivoDeDump" windows.svcscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.svcscan.json

  # windows.symlinkscan (Scans for links present in a particular windows memory image)
    vol -f "$cRutaAlArchivoDeDump" windows.symlinkscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.symlinkscan.tab
    vol -f "$cRutaAlArchivoDeDump" windows.symlinkscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.symlinkscan.tab
    vol -f "$cRutaAlArchivoDeDump" windows.symlinkscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.symlinkscan.tab
    vol -f "$cRutaAlArchivoDeDump" windows.symlinkscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.symlinkscan.json

  # windows.thrdscan (Scans for windows threads)
    vol -f "$cRutaAlArchivoDeDump" windows.thrdscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.thrdscan.tab
    vol -f "$cRutaAlArchivoDeDump" windows.thrdscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.thrdscan.tab
    vol -f "$cRutaAlArchivoDeDump" windows.thrdscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.thrdscan.tab
    vol -f "$cRutaAlArchivoDeDump" windows.thrdscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.thrdscan.json

  # windows.threads (Lists process threads)
    # Argumentos:
    #   --pid [PID ...] - Filter on specific process IDs
    vol -f "$cRutaAlArchivoDeDump" windows.threads | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.threads.tab
    vol -f "$cRutaAlArchivoDeDump" windows.threads | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.threads.tab
    vol -f "$cRutaAlArchivoDeDump" windows.threads | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.threads.tab
    vol -f "$cRutaAlArchivoDeDump" windows.threads | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.threads.json

  # windows.timers (Print kernel timers and associated module DPCs)
    vol -f "$cRutaAlArchivoDeDump" windows.timers | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.timers.tab
    vol -f "$cRutaAlArchivoDeDump" windows.timers | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.timers.tab
    vol -f "$cRutaAlArchivoDeDump" windows.timers | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.timers.tab
    vol -f "$cRutaAlArchivoDeDump" windows.timers | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.timers.json

  # windows.truecrypt (TrueCrypt Cached Passphrase Finder)
    # Argumentos:
    #   --min-length MIN-LENGTH - Minimum length of passphrases to identify
    vol -f "$cRutaAlArchivoDeDump" windows.truecrypt | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.truecrypt.tab
    vol -f "$cRutaAlArchivoDeDump" windows.truecrypt | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.truecrypt.tab
    vol -f "$cRutaAlArchivoDeDump" windows.truecrypt | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.truecrypt.tab
    vol -f "$cRutaAlArchivoDeDump" windows.truecrypt | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.truecrypt.json

  # windows.unhooked_system_calls (Looks for signs of Skeleton Key malware)
    vol -f "$cRutaAlArchivoDeDump" windows.unhooked_system_calls | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.unhooked_system_calls.tab
    vol -f "$cRutaAlArchivoDeDump" windows.unhooked_system_calls | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.unhooked_system_calls.tab
    vol -f "$cRutaAlArchivoDeDump" windows.unhooked_system_calls | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.unhooked_system_calls.tab
    vol -f "$cRutaAlArchivoDeDump" windows.unhooked_system_calls | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.unhooked_system_calls.json

  # windows.unloadedmodules (Lists the unloaded kernel modules)
    vol -f "$cRutaAlArchivoDeDump" windows.unloadedmodules | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.unloadedmodules.tab
    vol -f "$cRutaAlArchivoDeDump" windows.unloadedmodules | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.unloadedmodules.tab
    vol -f "$cRutaAlArchivoDeDump" windows.unloadedmodules | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.unloadedmodules.tab
    vol -f "$cRutaAlArchivoDeDump" windows.unloadedmodules | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.unloadedmodules.json

  # windows.vadinfo (Lists process memory ranges)
    # Argumentos:
    #   --address ADDRESS - Process virtual memory address to include (all other address ranges are excluded).
    #   --pid [PID ...]   - Filter on specific process IDs
    #   --dump            - Extract listed memory ranges
    #   --maxsize MAXSIZE - Maximum size for dumped VAD sections (all the bigger sections will be ignored)
    vol -f "$cRutaAlArchivoDeDump" windows.vadinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.vadinfo.tab
    vol -f "$cRutaAlArchivoDeDump" windows.vadinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.vadinfo.tab
    vol -f "$cRutaAlArchivoDeDump" windows.vadinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.vadinfo.tab
    vol -f "$cRutaAlArchivoDeDump" windows.vadinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.vadinfo.json

  # windows.vadregexscan (Scans all virtual memory areas for tasks using RegEx)
    # Argumentos:
    #   --pid [PID ...]   - Filter on specific process IDs
    #   --pattern PATTERN - RegEx pattern
    #   --maxsize MAXSIZE - Maximum size in bytes for displayed context
    vol -f "$cRutaAlArchivoDeDump" windows.vadregexscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.vadregexscan.tab
    vol -f "$cRutaAlArchivoDeDump" windows.vadregexscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.vadregexscan.tab
    vol -f "$cRutaAlArchivoDeDump" windows.vadregexscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.vadregexscan.tab
    vol -f "$cRutaAlArchivoDeDump" windows.vadregexscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.vadregexscan.json

  # windows.vadwalk (Walk the VAD tree)
    # Argumentos:
    #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
    vol -f "$cRutaAlArchivoDeDump" windows.vadwalk | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.vadwalk.tab
    vol -f "$cRutaAlArchivoDeDump" windows.vadwalk | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.vadwalk.tab
    vol -f "$cRutaAlArchivoDeDump" windows.vadwalk | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.vadwalk.tab
    vol -f "$cRutaAlArchivoDeDump" windows.vadwalk | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.vadwalk.json

  # windows.verinfo (Lists version information from PE files)
    # Argumenots:
    #   --extensive - Search physical layer for version information
    # Normal
      vol -f "$cRutaAlArchivoDeDump" windows.verinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.verinfo-normal.tab
      vol -f "$cRutaAlArchivoDeDump" windows.verinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.verinfo-normal.tab
      vol -f "$cRutaAlArchivoDeDump" windows.verinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.verinfo-normal.tab
      vol -f "$cRutaAlArchivoDeDump" windows.verinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.verinfo-normal.json
    # Extensivo
      vol --extensive -f "$cRutaAlArchivoDeDump" windows.verinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.verinfo-extensivo.tab
      vol --extensive -f "$cRutaAlArchivoDeDump" windows.verinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.verinfo-extensivo.tab
      vol --extensive -f "$cRutaAlArchivoDeDump" windows.verinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.verinfo-extensivo.tab
      vol --extensive -f "$cRutaAlArchivoDeDump" windows.verinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.verinfo-extensivo.json

  # windows.virtmap (Lists virtual mapped sections)
    vol -f "$cRutaAlArchivoDeDump" windows.virtmap | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.virtmap.tab
    vol -f "$cRutaAlArchivoDeDump" windows.virtmap | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.virtmap.tab
    vol -f "$cRutaAlArchivoDeDump" windows.virtmap | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/windows.virtmap.tab
    vol -f "$cRutaAlArchivoDeDump" windows.virtmap | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/windows.virtmap.json

  # No windows

    # isinfo (Determines information about the currently available ISF files, or a specific one)
      # Argumentos:
      #   --filter [FILTER ...] - String that must be present in the file URI to display the ISF
      #   --isf ISF             - Specific ISF file to process
      #   --validate            - Validate against schema if possible
      #   --live                - Traverse all files, rather than use the cache
      vol -f "$cRutaAlArchivoDeDump" isfinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/isfinfo.tab
      vol -f "$cRutaAlArchivoDeDump" isfinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/isfinfo.tab
      vol -f "$cRutaAlArchivoDeDump" isfinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/isfinfo.tab
      vol -f "$cRutaAlArchivoDeDump" isfinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/isfinfo.json

    # layerwriter (Runs the automagics and writes out the primary layer produced by the stacker)
      # Argumentos:
      #   --block-size BLOCK_SIZE - Size of blocks to copy over
      #   --list                  - List available layers
      #   --layers [LAYERS ...]   - Names of layers to write (defaults to the highest non-mapped layer)
      mkdir -p ~/ArtefactosRAM/MemoryLayer/
      cd ~/ArtefactosRAM/MemoryLayer/
      vol -f "$cRutaAlArchivoDeDump" layerwriter
      cd ..

    # regexscan.RegExScan (Scans kernel memory using RegEx patterns)
      # Argumentos:
      #   --pattern PATTERN - RegEx pattern
      #   --maxsize MAXSIZE - Maximum size in bytes for displayed context
      vol -f "$cRutaAlArchivoDeDump" regexscan.RegExScan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/regexscan.RegExScan.tab
      vol -f "$cRutaAlArchivoDeDump" regexscan.RegExScan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/regexscan.RegExScan.tab
      vol -f "$cRutaAlArchivoDeDump" regexscan.RegExScan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/regexscan.RegExScan.tab
      vol -f "$cRutaAlArchivoDeDump" regexscan.RegExScan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/regexscan.RegExScan.json

    # timeliner (Runs all relevant plugins that provide time related information and orders the results by time)
      # Argumentos:
      #   --record-config                     - Whether to record the state of all the plugins once complete
      #   --plugin-filter [PLUGIN-FILTER ...] - Only run plugins featuring this substring
      #   --create-bodyfile                   - Whether to create a body file whilst producing results
      vol -f "$cRutaAlArchivoDeDump" timeliner | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/timeliner.tab
      vol -f "$cRutaAlArchivoDeDump" timeliner | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/timeliner.tab
      vol -f "$cRutaAlArchivoDeDump" timeliner | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/tab/timeliner.tab
      vol -f "$cRutaAlArchivoDeDump" timeliner | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/json/timeliner.json

  # Desactivar el entorno virtual
    deactivate







# Obtener información sobre el sistema operativo
  echo ""
  echo "    Extrayendo información del sistema operativo..."
  echo ""
  vol -f "$cRutaAlArchivoDeDump" windows.info > "$cCarpetaDondeGuardar"/windows.info.txt
# Procesos
  echo ""
  echo "    Extrayendo información de procesos"
  echo ""
  vol -f "$cRutaAlArchivoDeDump" windows.pslist | sort -n | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.pslist.txt
  vol -f "$cRutaAlArchivoDeDump" windows.psscan | sort -n | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.psscan.txt
  vol -f "$cRutaAlArchivoDeDump" windows.pstree | sort -n | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.pstree.txt
# ProcDump (Dumpea .exes y DLLs asociadas)
  ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" -o "/path/to/dir" windows.dumpfiles ‑‑pid "<PID>" 
# MemDump
  ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" -o "/path/to/dir" windows.memmap ‑‑dump ‑‑pid "<PID>"
# Handles (Dumpea PID, process, offset, handlevalue, type, grantedaccess, name)
  ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.handles ‑‑pid "<PID>"
# DLLs (PID, process, base, size, name, path, loadtime, file output)
  ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.dlllist ‑‑pid "<PID>"



  # Registry printkey
    ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.registry.printkey > "$cCarpetaDondeGuardar"/windows.registry.printkey.txt
    ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.registry.printkey ‑‑key "Software\Microsoft\Windows\CurrentVersion"

  # FileDump
    ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" -o "/path/to/dir" windows.dumpfiles
    ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" -o "/path/to/dir" windows.dumpfiles ‑‑virtaddr "<offset>"
    ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" -o "/path/to/dir" windows.dumpfiles ‑‑physaddr "<offset>"

