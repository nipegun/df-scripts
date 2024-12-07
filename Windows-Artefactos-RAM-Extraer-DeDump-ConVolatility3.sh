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

  # windows.amcache (Extract information on executed applications from the AmCache)
    vol -f "$cRutaAlArchivoDeDump" windows.amcache | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.amcache.txt

  # windows.bigpools (List big page pools)
    # Argumentos:
    #   --tags TAGS - Comma separated list of pool tags to filter pools returned
    #   --show-free - Show freed regions (otherwise only show allocations in use)
    vol -f "$cRutaAlArchivoDeDump" windows.bigpools | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.bigpools.txt

  # windows.callbacks (Lists kernel callbacks and notification routines)
    vol -f "$cRutaAlArchivoDeDump" windows.callbacks | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.cmdline.txt

  # windows.cmdline (Lists process command line arguments)
    # Argumentos:
    #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
    vol -f "$cRutaAlArchivoDeDump" windows.cmdline | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.cmdline.txt

  # windows.cmdscan (Looks for Windows Command History lists)
    # Argumentos:
    #   --no-registry                   - Don't search the registry for possible values of CommandHistorySize
    #   --max-history [MAX_HISTORY ...] - CommandHistorySize values to search for.
    vol -f "$cRutaAlArchivoDeDump" windows.cmdscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.cmdscan.txt

  # windows.consoles (Looks for Windows console buffers)
    # Argumentos:
    #   --no-registry                   - Don't search the registry for possible values of CommandHistorySize and HistoryBufferMax
    #   --max-history [MAX_HISTORY ...] - CommandHistorySize values to search for.
    #   --max-buffers [MAX_BUFFERS ...] - HistoryBufferMax values to search for.
    vol -f "$cRutaAlArchivoDeDump" windows.consoles | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.consoles.txt

  # windows.crashinfo (Lists the information from a Windows crash dump)
    vol -f "$cRutaAlArchivoDeDump" windows.crashinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.crashinfo.txt

  # windows.debugregisters ()
    vol -f "$cRutaAlArchivoDeDump" windows.debugregisters | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.debugregisters.txt

  # windows.devicetree (Listing tree based on drivers and attached devices in a particular windows memory image)
    vol -f "$cRutaAlArchivoDeDump" windows.devicetree | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.devicetree.txt

  # windows.dlllist (Lists the loaded modules in a particular windows memory image)
    # Argumentos:
    #   --pid [PID ...] - Process IDs to include (all other processes are excluded)
    #   --offset OFFSET - Process offset in the physical address space
    #   --name NAME     - Specify a regular expression to match dll name(s)
    #   --base BASE     - Specify a base virtual address in process memory
    #   --ignore-case   - Specify case insensitivity for the regular expression name matching
    #   --dump          - Extract listed DLLs
    vol -f "$cRutaAlArchivoDeDump" windows.dlllist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.dlllist.txt

  # windows.driverirp (List IRPs for drivers in a particular windows memory image)
    vol -f "$cRutaAlArchivoDeDump" windows.driverirp | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.driverirp.txt

  # windows.drivermodule (Determines if any loaded drivers were hidden by a rootkit)
    vol -f "$cRutaAlArchivoDeDump" windows.drivermodule | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.drivermodule.txt

  # windows.driverscan (Scans for drivers present in a particular windows memory image)
    vol -f "$cRutaAlArchivoDeDump" windows.driverscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.driverscan.txt

  # windows.dumfiles (Dumps cached file contents from Windows memory samples)
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
    vol -f "$cRutaAlArchivoDeDump" windows.envars | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.envars.txt

  # windows.filescan (Scans for file objects present in a particular windows memory image)
    vol -f "$cRutaAlArchivoDeDump" windows.filescan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.filescan.txt

  # windows.getservicesids ()
    vol -f "$cRutaAlArchivoDeDump" windows.getservicesids | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.getservicesids.txt

  # windows.getsids (Lists process token sids)
    vol -f "$cRutaAlArchivoDeDump" windows.getsids | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.getsids.txt

  # windows.handles (Lists process open handles)
    vol -f "$cRutaAlArchivoDeDump" windows.handles | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.handles.txt

  # windows.hollowprocesses (Lists hollowed processes)
    vol -f "$cRutaAlArchivoDeDump" windows.hollowprocesses | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.hollowprocesses.txt

  # windows.iat (Extract Import Address Table to list API (functions) used by a program contained in external libraries)
    vol -f "$cRutaAlArchivoDeDump" windows.iat | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.iat.txt

  # windows.info (Show OS & kernel details of the memory sample being analyzed.)
    vol -f "$cRutaAlArchivoDeDump" windows.info | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.info.txt

  # windows.joblinks (Print process job link information)
    vol -f "$cRutaAlArchivoDeDump" windows.joblinks | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.joblinks.txt

  # windows.kpcrs (Print KPCR structure for each processor)
    vol -f "$cRutaAlArchivoDeDump" windows.kpcrs | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.kpcrs.txt

  # windows.ldrmodules (Lists the loaded modules in a particular windows memory image)
    vol -f "$cRutaAlArchivoDeDump" windows.ldrmodules | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.ldrmodules.txt

  # windows.malfind (Lists process memory ranges that potentially contain injected code)
    vol -f "$cRutaAlArchivoDeDump" windows.malfind | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.malfind.txt

  # windows.mbrscan (Scans for and parses potential Master Boot Records (MBRs))
    vol -f "$cRutaAlArchivoDeDump" windows.mbrscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.mbrscan.txt

  # windows.memmap (Prints the memory map)
    vol -f "$cRutaAlArchivoDeDump" windows.memmap | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.memmap.txt

  # windows.modscan (Scans for modules present in a particular windows memory image)
    vol -f "$cRutaAlArchivoDeDump" windows.modscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.modscan.txt

  # windows.modules (Lists the loaded kernel modules)
    vol -f "$cRutaAlArchivoDeDump" windows.modules | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.modules.txt

  # windows.mutantscan (Scans for mutexes present in a particular windows memory image)
    vol -f "$cRutaAlArchivoDeDump" windows.mutantscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.mutantscan.txt

  # windows.netscan (Scans for network objects present in a particular windows memory image)
    vol -f "$cRutaAlArchivoDeDump" windows.netscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.netscan.txt

  # windows.netstat (Traverses network tracking structures present in a particular windows memory image)
    vol -f "$cRutaAlArchivoDeDump" windows.netstat | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.netstat.txt

  # windows.orphan_kernel_threads (Lists process threads)
    vol -f "$cRutaAlArchivoDeDump" windows.orphan_kernel_threads | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.orphan_kernel_threads.txt

  # windows.pe_symbols (Prints symbols in PE files in process and kernel memory)
    vol -f "$cRutaAlArchivoDeDump" windows.pe_symbols | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/ # Requiere argumentos --source {kernel,processes} --module MODULE [--symbols [SYMBOLS ...]] [--addresses [ADDRESSES ...]]

  # windows.pedump (Allows extracting PE Files from a specific address in a specific address space)
    vol -f "$cRutaAlArchivoDeDump" windows.pedump | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/ # Requiere argumentos [--pid [PID ...]] --base BASE [--kernel-module]

  # windows.poolscanner (A generic pool scanner plugin)
    vol -f "$cRutaAlArchivoDeDump" windows.poolscanner | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.poolscanner.txt

  # windows.privileges (Lists process token privileges)
    vol -f "$cRutaAlArchivoDeDump" windows.privileges | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.privileges.txt

  # windows.processghosting (Lists processes whose DeletePending bit is set or whose FILE_OBJECT is set to 0)
    vol -f "$cRutaAlArchivoDeDump" windows.processghosting | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.processghosting.txt

  # windows.pslist (Lists the processes present in a particular windows memory image)
    vol -f "$cRutaAlArchivoDeDump" windows.pslist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.pslist.txt

  # windows.psscan (Scans for processes present in a particular windows memory image)
    vol -f "$cRutaAlArchivoDeDump" windows.psscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.psscan.txt

  # windows.pstree (Plugin for listing processes in a tree based on their parent process ID)
    vol -f "$cRutaAlArchivoDeDump" windows.pstree | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.pstree.txt

  # windows.psxview (Lists all processes found via four of the methods described in "The Art of Memory Forensics," which may help identify processes that are trying to hide themselves. I recommend using -r pretty if you are looking at this plugin's output in a terminal)
    vol -r pretty -f "$cRutaAlArchivoDeDump" windows.psxview | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.psxview.txt

  # windows.registry.certificates (Lists the certificates in the registry's Certificate Store)
    vol -f "$cRutaAlArchivoDeDump" windows.registry.certificates | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/ # Dio error

  # windows.registry.getcellroutine (Reports registry hives with a hooked GetCellRoutine handler)
    vol -f "$cRutaAlArchivoDeDump" windows.registry.getcellroutine | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.registry.getcellroutine.txt

  # windows.registry.hivelist (Lists the registry hives present in a particular memory image)
    vol -f "$cRutaAlArchivoDeDump" windows.registry.hivelist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.registry.hivelist.txt

  # windows.registry.hivescan (Scans for registry hives present in a particular windows memory image)
    vol -f "$cRutaAlArchivoDeDump" windows.registry.hivescan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.registry.hivescan.txt

  # windows.registry.printkey (Lists the registry keys under a hive or specific key value)
    vol -f "$cRutaAlArchivoDeDump" windows.registry.printkey | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.registry.printkey.txt

  # windows.registry.userassist (Print userassist registry keys and information)
    vol -f "$cRutaAlArchivoDeDump" windows.registry.userassist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.registry.userassist.txt

  # windows.scheduled_tasks (Decodes scheduled task information from the Windows registry, including information about triggers, actions, run times, and creation times)
    vol -f "$cRutaAlArchivoDeDump" windows.scheduled_tasks | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.scheduled_tasks.txt # dio error

  # windows.sessions (lists Processes with Session information extracted from Environmental Variables)
    vol -f "$cRutaAlArchivoDeDump" windows.sessions | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.sessions.txt

  # windows.shimcachemem (Reads Shimcache entries from the ahcache.sys AVL tree)
    vol -f "$cRutaAlArchivoDeDump" windows.shimcachemem | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.shimcachemem.txt

  # windows.skeleton_key_check (Looks for signs of Skeleton Key malware)
    vol -f "$cRutaAlArchivoDeDump" windows.skeleton_key_check | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.skeleton_key_check.txt

  # windows.ssdt (Lists the system call table)
    vol -f "$cRutaAlArchivoDeDump" windows.ssdt | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.ssdt.txt

  # windows.statistics (Lists statistics about the memory space)
    vol -f "$cRutaAlArchivoDeDump" windows.statistics | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.statistics.txt

  # windows.strings (Reads output from the strings command and indicates which process(es) each string belongs to)
    vol -f "$cRutaAlArchivoDeDump" windows.strings | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/ # Requiere argumentos [--pid [PID ...]] --strings-file STRINGS_FILE

  # windows.suspicious_threads (Lists suspicious userland process threads)
    vol -f "$cRutaAlArchivoDeDump" windows.suspicious_threads | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.suspicious_threads.txt

  # windows.svcdiff (Compares services found through list walking versus scanning to find rootkits)
    vol -f "$cRutaAlArchivoDeDump" windows.svcdiff | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.svcdiff.txt

  # windows.svclist (Lists services contained with the services.exe doubly linked list of services)
    vol -f "$cRutaAlArchivoDeDump" windows.svclist | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.svclist.txt

  # windows.svcscan (Scans for windows services)
    vol -f "$cRutaAlArchivoDeDump" windows.svcscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.svcscan.txt

  # windows.symlinkscan (Scans for links present in a particular windows memory image)
    vol -f "$cRutaAlArchivoDeDump" windows.symlinkscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.symlinkscan.txt

  # windows.thrdscan (Scans for windows threads)
    vol -f "$cRutaAlArchivoDeDump" windows.thrdscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.thrdscan.txt

  # windows.threads (Lists process threads)
    vol -f "$cRutaAlArchivoDeDump" windows.threads | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.threads.txt

  # windows.timers (Print kernel timers and associated module DPCs)
    vol -f "$cRutaAlArchivoDeDump" windows.timers | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.timers.txt

  # windows.truecrypt (TrueCrypt Cached Passphrase Finder)
    vol -f "$cRutaAlArchivoDeDump" windows.truecrypt | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.truecrypt # Dio error: truecrypt_module_base = next(
      
  # windows.unhooked_system_calls (Looks for signs of Skeleton Key malware)
    vol -f "$cRutaAlArchivoDeDump" windows.unhooked_system_calls | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.unhooked_system_calls.txt

  # windows.unloadedmodules (Lists the unloaded kernel modules)
    vol -f "$cRutaAlArchivoDeDump" windows.unloadedmodules | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.unloadedmodules.txt

  # windows.vadinfo (Lists process memory ranges)
    vol -f "$cRutaAlArchivoDeDump" windows.vadinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.vadinfo.txt

  # windows.vadregexscan (Scans all virtual memory areas for tasks using RegEx)
    vol -f "$cRutaAlArchivoDeDump" windows.vadregexscan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.vadregexscan.txt # Requiere argumentos: [--pid [PID ...]] --pattern PATTERN [--maxsize MAXSIZE]

  # windows.vadwalk (Walk the VAD tree)
    vol -f "$cRutaAlArchivoDeDump" windows.vadwalk | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.vadwalk.txt

  # windows.verinfo (Lists version information from PE files)
    vol -f "$cRutaAlArchivoDeDump" windows.verinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.verinfo.txt

  # windows.virtmap (Lists virtual mapped sections)
    vol -f "$cRutaAlArchivoDeDump" windows.virtmap | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.virtmap.txt

  # No windows

    # isinfo (Determines information about the currently available ISF files, or a specific one)
      vol -f "$cRutaAlArchivoDeDump" isfinfo | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/isfinfo.txt

    # layerwriter ()
      mkdir -p ~/ArtefactosRAM/MemoryLayer/
      cd ~/ArtefactosRAM/MemoryLayer/
      vol -f "$cRutaAlArchivoDeDump" layerwriter
      cd ..

    # regexscan.RegExScan (Scans kernel memory using RegEx patterns)
      vol -f "$cRutaAlArchivoDeDump" regexscan.RegExScan | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/regexscan.RegExScan # Requiere argumentos --pattern PATTERN [--maxsize MAXSIZE]

    # timeliner (Runs all relevant plugins that provide time related information and orders the results by time)
      vol -f "$cRutaAlArchivoDeDump" timeliner | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/timeliner.txt

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

