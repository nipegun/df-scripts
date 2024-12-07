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

# Entrar en el entorno virtual
  source ~/repos/python/volatility3/venv/bin/activate
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
# CMDLine (PID, process name, args)
  ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.cmdline > "$cCarpetaDondeGuardar"/windows.cmdline.txt
# Red
  ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.netscan > "$cCarpetaDondeGuardar"/windows.netscan.txt
  ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.netstat > "$cCarpetaDondeGuardar"/windows.netstat.txt

# Registro
  # HiveList
    ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.registry.hivescan > "$cCarpetaDondeGuardar"/windows.registry.hivescan.txt
    ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.registry.hivelist > "$cCarpetaDondeGuardar"/windows.registry.hivelist.txt
  # Registry printkey
    ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.registry.printkey > "$cCarpetaDondeGuardar"/windows.registry.printkey.txt
    ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.registry.printkey ‑‑key "Software\Microsoft\Windows\CurrentVersion"

# Archivos
  # FileScan
    ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.filescan > "$cCarpetaDondeGuardar"/windows.filescan.txt
  # FileDump
    ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" -o "/path/to/dir" windows.dumpfiles
    ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" -o "/path/to/dir" windows.dumpfiles ‑‑virtaddr "<offset>"
    ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" -o "/path/to/dir" windows.dumpfiles ‑‑physaddr "<offset>"

# Misceláneo
  # MalFind (Dumpea PID, process name, process start, protection, commit charge, privatememory, file output, hexdump disassembly)
    ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.malfind > "$cCarpetaDondeGuardar"/windows.malfind.txt

  # Yarascan
    vol -f "$cRutaAlArchivoDeDump" windows.vadyarascan ‑‑yara-rules "<string>"
    vol -f "$cRutaAlArchivoDeDump" windows.vadyarascan ‑‑yara-file "/path/to/file.yar"
    vol -f "$cRutaAlArchivoDeDump" yarascan.yarascan   ‑‑yara-file "/path/to/file.yar"

  # Desactivar el entorno virtual
    deactivate

    # windows.amcache (Extract information on executed applications from the AmCache)
      vol -f "$cRutaAlArchivoDeDump" windows.amcache                 > "$cCarpetaDondeGuardar"/windows.amcache.txt
    # windows.bigpools (List big page pools)
      vol -f "$cRutaAlArchivoDeDump" windows.bigpools                > "$cCarpetaDondeGuardar"/windows.bigpools.txt
    # windows.callbacks (Lists kernel callbacks and notification routines)
      vol -f "$cRutaAlArchivoDeDump" windows.callbacks               > "$cCarpetaDondeGuardar"/windows.cmdline.txt
    # windows.cmdline (Lists process command line arguments)
      vol -f "$cRutaAlArchivoDeDump" windows.cmdline                 > "$cCarpetaDondeGuardar"/windows.cmdline.txt
    # windows.cmdscan (Looks for Windows Command History lists)
      vol -f "$cRutaAlArchivoDeDump" windows.cmdscan                 > "$cCarpetaDondeGuardar"/windows.cmdscan.txt
    # windows.consoles (Looks for Windows console buffers)
      vol -f "$cRutaAlArchivoDeDump" windows.consoles                > "$cCarpetaDondeGuardar"/windows.consoles.txt
    # windows.crashinfo (Lists the information from a Windows crash dump)
      vol -f "$cRutaAlArchivoDeDump" windows.crashinfo               > "$cCarpetaDondeGuardar"/windows.crashinfo.txt
    # windows.debugregisters ()
      vol -f "$cRutaAlArchivoDeDump" windows.debugregisters          > "$cCarpetaDondeGuardar"/windows.debugregisters.txt
    # windows.devicetree (Listing tree based on drivers and attached devices in a particular windows memory image)
      vol -f "$cRutaAlArchivoDeDump" windows.devicetree              > "$cCarpetaDondeGuardar"/windows.devicetree.txt
    # windows.dlllist (Lists the loaded modules in a particular windows memory image)
      vol -f "$cRutaAlArchivoDeDump" windows.dlllist                 > "$cCarpetaDondeGuardar"/windows.dlllist.txt
    # windows.driverirp (List IRPs for drivers in a particular windows memory image)
      vol -f "$cRutaAlArchivoDeDump" windows.driverirp               > "$cCarpetaDondeGuardar"/windows.driverirp.txt
    # windows.drivermodule (Determines if any loaded drivers were hidden by a rootkit)
      vol -f "$cRutaAlArchivoDeDump" windows.drivermodule            > "$cCarpetaDondeGuardar"/windows.drivermodule.txt
    # windows.driverscan (Scans for drivers present in a particular windows memory image)
      vol -f "$cRutaAlArchivoDeDump" windows.driverscan              > "$cCarpetaDondeGuardar"/windows.driverscan.txt
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
      vol -f "$cRutaAlArchivoDeDump" windows.envars                  > "$cCarpetaDondeGuardar"/windows.envars.txt
    # windows.filescan (Scans for file objects present in a particular windows memory image)
      vol -f "$cRutaAlArchivoDeDump" windows.filescan                > "$cCarpetaDondeGuardar"/windows.filescan.txt
    # windows.getservicesids ()
      vol -f "$cRutaAlArchivoDeDump" windows.getservicesids          > "$cCarpetaDondeGuardar"/windows.getservicesids.txt
    # windows.getsids (Lists process token sids)
      vol -f "$cRutaAlArchivoDeDump" windows.getsids                 > "$cCarpetaDondeGuardar"/windows.getsids.txt
    # windows.handles (Lists process open handles)
      vol -f "$cRutaAlArchivoDeDump" windows.handles                 > "$cCarpetaDondeGuardar"/windows.handles.txt
    # windows.hollowprocesses (Lists hollowed processes)
      vol -f "$cRutaAlArchivoDeDump" windows.hollowprocesses         > "$cCarpetaDondeGuardar"/windows.hollowprocesses.txt
    # windows.iat (Extract Import Address Table to list API (functions) used by a program contained in external libraries)
      vol -f "$cRutaAlArchivoDeDump" windows.iat                     > "$cCarpetaDondeGuardar"/windows.iat.txt
    # windows.info (Show OS & kernel details of the memory sample being analyzed.)
      vol -f "$cRutaAlArchivoDeDump" windows.info                    > "$cCarpetaDondeGuardar"/windows.info.txt
    # windows.joblinks (Print process job link information)
      vol -f "$cRutaAlArchivoDeDump" windows.joblinks                > "$cCarpetaDondeGuardar"/windows.joblinks.txt
    # windows.kpcrs (Print KPCR structure for each processor)
      vol -f "$cRutaAlArchivoDeDump" windows.kpcrs                   > "$cCarpetaDondeGuardar"/windows.kpcrs.txt
    # windows.ldrmodules (Lists the loaded modules in a particular windows memory image)
      vol -f "$cRutaAlArchivoDeDump" windows.ldrmodules              > "$cCarpetaDondeGuardar"/windows.ldrmodules.txt
    # windows.malfind (Lists process memory ranges that potentially contain injected code)
      vol -f "$cRutaAlArchivoDeDump" windows.malfind                 > "$cCarpetaDondeGuardar"/windows.malfind.txt
    # windows.mbrscan (Scans for and parses potential Master Boot Records (MBRs))
      vol -f "$cRutaAlArchivoDeDump" windows.mbrscan                 > "$cCarpetaDondeGuardar"/windows.mbrscan.txt
    # windows.memmap (Prints the memory map)
      vol -f "$cRutaAlArchivoDeDump" windows.memmap                  > "$cCarpetaDondeGuardar"/windows.memmap.txt
    # windows.modscan (Scans for modules present in a particular windows memory image)
      vol -f "$cRutaAlArchivoDeDump" windows.modscan                 > "$cCarpetaDondeGuardar"/windows.modscan.txt
    # windows.modules (Lists the loaded kernel modules)
      vol -f "$cRutaAlArchivoDeDump" windows.modules                 > "$cCarpetaDondeGuardar"/windows.modules.txt
    # windows.mutantscan (Scans for mutexes present in a particular windows memory image)
      vol -f "$cRutaAlArchivoDeDump" windows.mutantscan              > "$cCarpetaDondeGuardar"/windows.mutantscan.txt
    # windows.netscan (Scans for network objects present in a particular windows memory image)
      vol -f "$cRutaAlArchivoDeDump" windows.netscan                 > "$cCarpetaDondeGuardar"/windows.netscan.txt
    # windows.netstat (Traverses network tracking structures present in a particular windows memory image)
      vol -f "$cRutaAlArchivoDeDump" windows.netstat                 > "$cCarpetaDondeGuardar"/windows.netstat.txt
    # windows.orphan_kernel_threads (Lists process threads)
      vol -f "$cRutaAlArchivoDeDump" windows.orphan_kernel_threads   > "$cCarpetaDondeGuardar"/windows.orphan_kernel_threads.txt
    # windows.pe_symbols (Prints symbols in PE files in process and kernel memory)
      vol -f "$cRutaAlArchivoDeDump" windows.pe_symbols              > "$cCarpetaDondeGuardar"/ # Requiere argumentos --source {kernel,processes} --module MODULE [--symbols [SYMBOLS ...]] [--addresses [ADDRESSES ...]]
    # windows.pedump (Allows extracting PE Files from a specific address in a specific address space)
      vol -f "$cRutaAlArchivoDeDump" windows.pedump                  > "$cCarpetaDondeGuardar"/ # Requiere argumentos [--pid [PID ...]] --base BASE [--kernel-module]
    # windows.poolscanner (A generic pool scanner plugin)
      vol -f "$cRutaAlArchivoDeDump" windows.poolscanner             > "$cCarpetaDondeGuardar"/windows.poolscanner.txt
    # windows.privileges (Lists process token privileges)
      vol -f "$cRutaAlArchivoDeDump" windows.privileges              > "$cCarpetaDondeGuardar"/windows.privileges.txt
    # windows.processghosting (Lists processes whose DeletePending bit is set or whose FILE_OBJECT is set to 0)
      vol -f "$cRutaAlArchivoDeDump" windows.processghosting         > "$cCarpetaDondeGuardar"/windows.processghosting.txt
    # windows.pslist (Lists the processes present in a particular windows memory image)
      vol -f "$cRutaAlArchivoDeDump" windows.pslist                  > "$cCarpetaDondeGuardar"/windows.pslist.txt
    # windows.psscan (Scans for processes present in a particular windows memory image)
      vol -f "$cRutaAlArchivoDeDump" windows.psscan                  > "$cCarpetaDondeGuardar"/windows.psscan.txt
    # windows.pstree (Plugin for listing processes in a tree based on their parent process ID)
      vol -f "$cRutaAlArchivoDeDump" windows.pstree                  > "$cCarpetaDondeGuardar"/windows.pstree.txt
    # windows.psxview (Lists all processes found via four of the methods described in "The Art of Memory Forensics," which may help identify processes that are trying to hide themselves. I recommend using -r pretty if you are looking at this plugin's output in a terminal)
      vol -r pretty -f "$cRutaAlArchivoDeDump" windows.psxview       > "$cCarpetaDondeGuardar"/windows.psxview.txt
    # windows.registry.certificates (Lists the certificates in the registry's Certificate Store)
      vol -f "$cRutaAlArchivoDeDump" windows.registry.certificates   > "$cCarpetaDondeGuardar"/ # Dio error
    # windows.registry.getcellroutine (Reports registry hives with a hooked GetCellRoutine handler)
      vol -f "$cRutaAlArchivoDeDump" windows.registry.getcellroutine > "$cCarpetaDondeGuardar"/windows.registry.getcellroutine.txt
    # windows.registry.hivelist (Lists the registry hives present in a particular memory image)
      vol -f "$cRutaAlArchivoDeDump" windows.registry.hivelist       > "$cCarpetaDondeGuardar"/windows.registry.hivelist.txt
    # windows.registry.hivescan (Scans for registry hives present in a particular windows memory image)
      vol -f "$cRutaAlArchivoDeDump" windows.registry.hivescan       > "$cCarpetaDondeGuardar"/windows.registry.hivescan.txt
    # windows.registry.printkey (Lists the registry keys under a hive or specific key value)
      vol -f "$cRutaAlArchivoDeDump" windows.registry.printkey       > "$cCarpetaDondeGuardar"/windows.registry.printkey.txt
    # windows.registry.userassist (Print userassist registry keys and information)
      vol -f "$cRutaAlArchivoDeDump" windows.registry.userassist     > "$cCarpetaDondeGuardar"/windows.registry.userassist.txt
    # windows.scheduled_tasks (Decodes scheduled task information from the Windows registry, including information about triggers, actions, run times, and creation times)
      vol -f "$cRutaAlArchivoDeDump" windows.scheduled_tasks         > "$cCarpetaDondeGuardar"/windows.scheduled_tasks.txt # dio error
    # windows.sessions (lists Processes with Session information extracted from Environmental Variables)
      vol -f "$cRutaAlArchivoDeDump" windows.sessions                > "$cCarpetaDondeGuardar"/windows.sessions.txt
    # windows.shimcachemem (Reads Shimcache entries from the ahcache.sys AVL tree)
      vol -f "$cRutaAlArchivoDeDump" windows.shimcachemem            > "$cCarpetaDondeGuardar"/windows.shimcachemem.txt
    # windows.skeleton_key_check (Looks for signs of Skeleton Key malware)
      vol -f "$cRutaAlArchivoDeDump" windows.skeleton_key_check      > "$cCarpetaDondeGuardar"/windows.skeleton_key_check.txt
    # windows.ssdt (Lists the system call table)
      vol -f "$cRutaAlArchivoDeDump" windows.ssdt                    > "$cCarpetaDondeGuardar"/windows.ssdt.txt
    # windows.statistics (Lists statistics about the memory space)
      vol -f "$cRutaAlArchivoDeDump" windows.statistics              > "$cCarpetaDondeGuardar"/windows.statistics.txt
    # windows.strings (Reads output from the strings command and indicates which process(es) each string belongs to)
      vol -f "$cRutaAlArchivoDeDump" windows.strings                 > "$cCarpetaDondeGuardar"/ # Requiere argumentos [--pid [PID ...]] --strings-file STRINGS_FILE
    # windows.suspicious_threads (Lists suspicious userland process threads)
      vol -f "$cRutaAlArchivoDeDump" windows.suspicious_threads      > "$cCarpetaDondeGuardar"/windows.suspicious_threads.txt
    # windows.svcdiff (Compares services found through list walking versus scanning to find rootkits)
      vol -f "$cRutaAlArchivoDeDump" windows.svcdiff                 > "$cCarpetaDondeGuardar"/windows.svcdiff.txt
    # windows.svclist (Lists services contained with the services.exe doubly linked list of services)
      vol -f "$cRutaAlArchivoDeDump" windows.svclist                 > "$cCarpetaDondeGuardar"/windows.svclist.txt
    # windows.svcscan (Scans for windows services)
      vol -f "$cRutaAlArchivoDeDump" windows.svcscan                 > "$cCarpetaDondeGuardar"/windows.svcscan.txt
    # windows.symlinkscan (Scans for links present in a particular windows memory image)
      vol -f "$cRutaAlArchivoDeDump" windows.symlinkscan             > "$cCarpetaDondeGuardar"/windows.symlinkscan.txt
    # windows.thrdscan (Scans for windows threads)
      vol -f "$cRutaAlArchivoDeDump" windows.thrdscan                > "$cCarpetaDondeGuardar"/windows.thrdscan.txt
    # windows.threads (Lists process threads)
      vol -f "$cRutaAlArchivoDeDump" windows.threads                 > "$cCarpetaDondeGuardar"/windows.threads.txt
    # windows.timers (Print kernel timers and associated module DPCs)
      vol -f "$cRutaAlArchivoDeDump" windows.timers                  > "$cCarpetaDondeGuardar"/windows.timers.txt
    # windows.truecrypt (TrueCrypt Cached Passphrase Finder)
      vol -f "$cRutaAlArchivoDeDump" windows.truecrypt               > "$cCarpetaDondeGuardar"/windows.truecrypt # Dio erro ruecrypt_module_base = next(
    # windows.unhooked_system_calls (Looks for signs of Skeleton Key malware)
      vol -f "$cRutaAlArchivoDeDump" windows.unhooked_system_calls   > "$cCarpetaDondeGuardar"/windows.unhooked_system_calls.txt
    # windows.unloadedmodules (Lists the unloaded kernel modules)
      vol -f "$cRutaAlArchivoDeDump" windows.unloadedmodules         > "$cCarpetaDondeGuardar"/windows.unloadedmodules.txt
    # windows.vadinfo (Lists process memory ranges)
      vol -f "$cRutaAlArchivoDeDump" windows.vadinfo                 > "$cCarpetaDondeGuardar"/windows.vadinfo.txt
    # windows.vadregexscan (Scans all virtual memory areas for tasks using RegEx)
      vol -f "$cRutaAlArchivoDeDump" windows.vadregexscan            > "$cCarpetaDondeGuardar"/windows.vadregexscan.txt # Requiere argumentos: [--pid [PID ...]] --pattern PATTERN [--maxsize MAXSIZE]
    # windows.vadwalk (Walk the VAD tree)
      vol -f "$cRutaAlArchivoDeDump" windows.vadwalk                 > "$cCarpetaDondeGuardar"/windows.vadwalk.txt
    # windows.verinfo (Lists version information from PE files)
      vol -f "$cRutaAlArchivoDeDump" windows.verinfo                 > "$cCarpetaDondeGuardar"/windows.verinfo.txt
    # windows.virtmap (Lists virtual mapped sections)
      vol -f "$cRutaAlArchivoDeDump" windows.virtmap                 > "$cCarpetaDondeGuardar"/windows.virtmap.txt

    # No windows
      # isinfo (Determines information about the currently available ISF files, or a specific one)
        vol -f "$cRutaAlArchivoDeDump" isfinfo                         > "$cCarpetaDondeGuardar"/isfinfo.txt
      # layerwriter ()
        mkdir -p ~/ArtefactosRAM/MemoryLayer/
        cd ~/ArtefactosRAM/MemoryLayer/
        vol -f "$cRutaAlArchivoDeDump" layerwriter
        cd ..
      # regexscan.RegExScan (Scans kernel memory using RegEx patterns)
        vol -f "$cRutaAlArchivoDeDump" regexscan.RegExScan             > "$cCarpetaDondeGuardar"/regexscan.RegExScan # Requiere argumentos --pattern PATTERN [--maxsize MAXSIZE]
      # timeliner (Runs all relevant plugins that provide time related information and orders the results by time)
        vol -f "$cRutaAlArchivoDeDump" timeliner                       > "$cCarpetaDondeGuardar"/timeliner.txt

