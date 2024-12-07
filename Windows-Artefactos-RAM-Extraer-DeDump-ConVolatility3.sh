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
    # windows.callbacks ()
      vol -f "$cRutaAlArchivoDeDump" windows.callbacks               > "$cCarpetaDondeGuardar"/windows.cmdline.txt
    # windows.cmdline ()
      vol -f "$cRutaAlArchivoDeDump" windows.cmdline                 > "$cCarpetaDondeGuardar"/windows.cmdline.txt
    # windows.cmdscan ()
      vol -f "$cRutaAlArchivoDeDump" windows.cmdscan                 > "$cCarpetaDondeGuardar"/windows.cmdscan.txt
    # windows.consoles ()
      vol -f "$cRutaAlArchivoDeDump" windows.consoles                > "$cCarpetaDondeGuardar"/windows.consoles.txt
    # windows.crashinfo ()
      vol -f "$cRutaAlArchivoDeDump" windows.crashinfo               > "$cCarpetaDondeGuardar"/windows.crashinfo.txt
    # windows.debugregisters ()
      vol -f "$cRutaAlArchivoDeDump" windows.debugregisters          > "$cCarpetaDondeGuardar"/windows.debugregisters.txt
    # windows.devicetree ()
      vol -f "$cRutaAlArchivoDeDump" windows.devicetree              > "$cCarpetaDondeGuardar"/windows.devicetree.txt
    # windows.dlllist ()
      vol -f "$cRutaAlArchivoDeDump" windows.dlllist                 > "$cCarpetaDondeGuardar"/windows.dlllist.txt
    # windows.driverirp ()
      vol -f "$cRutaAlArchivoDeDump" windows.driverirp               > "$cCarpetaDondeGuardar"/windows.driverirp.txt
    # windows.drivermodule ()
      vol -f "$cRutaAlArchivoDeDump" windows.drivermodule            > "$cCarpetaDondeGuardar"/windows.drivermodule.txt
    # windows.driverscan ()
      vol -f "$cRutaAlArchivoDeDump" windows.driverscan              > "$cCarpetaDondeGuardar"/windows.driverscan.txt
    # windows.dumfiles ()
      mkdir -p ~/ArtefactosRAM/Archivos
      cd ~/ArtefactosRAM/Archivos/
      aExtensiones=("jpg" "png" "gif" "txt" "pdf")
      for vExtens in "${aExtensiones[@]}"; do
        echo -e "\n  Extrayendo todos los archivos $vExtens...\n"
        vol -f "$cRutaAlArchivoDeDump" windows.dumpfiles --filter \.$vExtens\$
      done
      cd ..
      dd if=file.None.0xfffffa8000d06e10.dat of=img.png bs=1 skip=0
    # windows.envars ()
      vol -f "$cRutaAlArchivoDeDump" windows.envars                  > "$cCarpetaDondeGuardar"/windows.envars.txt
    # windows.filescan ()
      vol -f "$cRutaAlArchivoDeDump" windows.filescan                > "$cCarpetaDondeGuardar"/windows.filescan.txt
    # windows.getservicesids ()
      vol -f "$cRutaAlArchivoDeDump" windows.getservicesids          > "$cCarpetaDondeGuardar"/windows.getservicesids.txt
    # windows.getsids ()
      vol -f "$cRutaAlArchivoDeDump" windows.getsids                 > "$cCarpetaDondeGuardar"/windows.getsids.txt
    # windows.handles ()
      vol -f "$cRutaAlArchivoDeDump" windows.handles                 > "$cCarpetaDondeGuardar"/windows.handles.txt
    # windows.hollowprocesses ()
      vol -f "$cRutaAlArchivoDeDump" windows.hollowprocesses         > "$cCarpetaDondeGuardar"/windows.hollowprocesses.txt
    # windows.iat ()
      vol -f "$cRutaAlArchivoDeDump" windows.iat                     > "$cCarpetaDondeGuardar"/windows.iat.txt
    # windows.info ()
      vol -f "$cRutaAlArchivoDeDump" windows.info                    > "$cCarpetaDondeGuardar"/windows.info.txt
    # windows.joblinks ()
      vol -f "$cRutaAlArchivoDeDump" windows.joblinks                > "$cCarpetaDondeGuardar"/windows.joblinks.txt
    # windows.kpcrs ()
      vol -f "$cRutaAlArchivoDeDump" windows.kpcrs                   > "$cCarpetaDondeGuardar"/windows.kpcrs.txt
    # windows.ldrmodules ()
      vol -f "$cRutaAlArchivoDeDump" windows.ldrmodules              > "$cCarpetaDondeGuardar"/windows.ldrmodules.txt
    # windows.malfind ()
      vol -f "$cRutaAlArchivoDeDump" windows.malfind                 > "$cCarpetaDondeGuardar"/windows.malfind.txt
    # windows.mbrscan ()
      vol -f "$cRutaAlArchivoDeDump" windows.mbrscan                 > "$cCarpetaDondeGuardar"/windows.mbrscan.txt
    # windows.memmap ()
      vol -f "$cRutaAlArchivoDeDump" windows.memmap                  > "$cCarpetaDondeGuardar"/windows.memmap.txt
    # windows.modscan ()
      vol -f "$cRutaAlArchivoDeDump" windows.modscan                 > "$cCarpetaDondeGuardar"/windows.modscan.txt
    # windows.modules ()
      vol -f "$cRutaAlArchivoDeDump" windows.modules                 > "$cCarpetaDondeGuardar"/windows.modules.txt
    # windows.mutantscan ()
      vol -f "$cRutaAlArchivoDeDump" windows.mutantscan              > "$cCarpetaDondeGuardar"/windows.mutantscan.txt
    # windows.netscan ()
      vol -f "$cRutaAlArchivoDeDump" windows.netscan                 > "$cCarpetaDondeGuardar"/windows.netscan.txt
    # windows.netstat ()
      vol -f "$cRutaAlArchivoDeDump" windows.netstat                 > "$cCarpetaDondeGuardar"/windows.netstat.txt
    # windows.orphan_kernel_threads ()
      vol -f "$cRutaAlArchivoDeDump" windows.orphan_kernel_threads   > "$cCarpetaDondeGuardar"/windows.orphan_kernel_threads.txt
    # windows.pe_symbols ()
      vol -f "$cRutaAlArchivoDeDump" windows.pe_symbols              > "$cCarpetaDondeGuardar"/ # Requiere argumentos --source {kernel,processes} --module MODULE [--symbols [SYMBOLS ...]] [--addresses [ADDRESSES ...]]
    # windows.pedump ()
      vol -f "$cRutaAlArchivoDeDump" windows.pedump                  > "$cCarpetaDondeGuardar"/ # Requiere argumentos [--pid [PID ...]] --base BASE [--kernel-module]
    # windows.poolscanner ()
      vol -f "$cRutaAlArchivoDeDump" windows.poolscanner             > "$cCarpetaDondeGuardar"/windows.poolscanner.txt
    # windows.privileges
      vol -f "$cRutaAlArchivoDeDump" windows.privileges              > "$cCarpetaDondeGuardar"/windows.privileges.txt
    # windows.processghosting ()
      vol -f "$cRutaAlArchivoDeDump" windows.processghosting         > "$cCarpetaDondeGuardar"/windows.processghosting.txt
    # windows.pslist ()
      vol -f "$cRutaAlArchivoDeDump" windows.pslist                  > "$cCarpetaDondeGuardar"/windows.pslist.txt
    # windows.psscan ()
      vol -f "$cRutaAlArchivoDeDump" windows.psscan                  > "$cCarpetaDondeGuardar"/windows.psscan.txt
    # windows.pstree ()
      vol -f "$cRutaAlArchivoDeDump" windows.pstree                  > "$cCarpetaDondeGuardar"/windows.pstree.txt
    # windows.psxview ()
      vol -f "$cRutaAlArchivoDeDump" windows.psxview                 > "$cCarpetaDondeGuardar"/windows.psxview.txt
    # windows.registry.certificates ()
      vol -f "$cRutaAlArchivoDeDump" windows.registry.certificates   > "$cCarpetaDondeGuardar"/ # Dio error
    # windows.registry.getcellroutine ()
      vol -f "$cRutaAlArchivoDeDump" windows.registry.getcellroutine > "$cCarpetaDondeGuardar"/windows.registry.getcellroutine.txt
    # windows.registry.hivelist ()
      vol -f "$cRutaAlArchivoDeDump" windows.registry.hivelist       > "$cCarpetaDondeGuardar"/windows.registry.hivelist.txt
    # windows.registry.hivescan ()
      vol -f "$cRutaAlArchivoDeDump" windows.registry.hivescan       > "$cCarpetaDondeGuardar"/windows.registry.hivescan.txt
    # windows.registry.printkey ()
      vol -f "$cRutaAlArchivoDeDump" windows.registry.printkey       > "$cCarpetaDondeGuardar"/windows.registry.printkey.txt
    # windows.registry.userassist ()
      vol -f "$cRutaAlArchivoDeDump" windows.registry.userassist     > "$cCarpetaDondeGuardar"/windows.registry.userassist.txt
    # windows.scheduled_tasks ()
      vol -f "$cRutaAlArchivoDeDump" windows.scheduled_tasks         > "$cCarpetaDondeGuardar"/windows.scheduled_tasks.txt # dio error
    # windows.sessions ()
      vol -f "$cRutaAlArchivoDeDump" windows.sessions                > "$cCarpetaDondeGuardar"/windows.sessions.txt
    # windows.shimcachemem ()
      vol -f "$cRutaAlArchivoDeDump" windows.shimcachemem            > "$cCarpetaDondeGuardar"/windows.shimcachemem.txt
    # windows.skeleton_key_check ()
      vol -f "$cRutaAlArchivoDeDump" windows.skeleton_key_check      > "$cCarpetaDondeGuardar"/windows.skeleton_key_check.txt
    # windows.ssdt ()
      vol -f "$cRutaAlArchivoDeDump" windows.ssdt                    > "$cCarpetaDondeGuardar"/windows.ssdt.txt
    # windows.statistics ()
      vol -f "$cRutaAlArchivoDeDump" windows.statistics              > "$cCarpetaDondeGuardar"/windows.statistics.txt
    # windows.strings ()
      vol -f "$cRutaAlArchivoDeDump" windows.strings                 > "$cCarpetaDondeGuardar"/ # Requiere argumentos [--pid [PID ...]] --strings-file STRINGS_FILE
    # windows.suspicious_threads ()
      vol -f "$cRutaAlArchivoDeDump" windows.suspicious_threads      > "$cCarpetaDondeGuardar"/windows.suspicious_threads.txt
    # windows.svcdiff ()
      vol -f "$cRutaAlArchivoDeDump" windows.svcdiff                 > "$cCarpetaDondeGuardar"/windows.svcdiff.txt
    # windows.svclist ()
      vol -f "$cRutaAlArchivoDeDump" windows.svclist                 > "$cCarpetaDondeGuardar"/windows.svclist.txt
    # windows.svcscan ()
      vol -f "$cRutaAlArchivoDeDump" windows.svcscan                 > "$cCarpetaDondeGuardar"/windows.svcscan.txt
    # windows.symlinkscan
      vol -f "$cRutaAlArchivoDeDump" windows.symlinkscan             > "$cCarpetaDondeGuardar"/windows.symlinkscan.txt
    # windows.thrdscan ()
      vol -f "$cRutaAlArchivoDeDump" windows.thrdscan                > "$cCarpetaDondeGuardar"/windows.thrdscan.txt
    # windows.threads ()
      vol -f "$cRutaAlArchivoDeDump" windows.threads                 > "$cCarpetaDondeGuardar"/windows.threads.txt
    # windows.timers ()
      vol -f "$cRutaAlArchivoDeDump" windows.timers                  > "$cCarpetaDondeGuardar"/windows.timers.txt
    # windows.truecrypt ()
      vol -f "$cRutaAlArchivoDeDump" windows.truecrypt               > "$cCarpetaDondeGuardar"/windows.truecrypt # Dio erro ruecrypt_module_base = next(
    # windows.unhooked_system_calls ()
      vol -f "$cRutaAlArchivoDeDump" windows.unhooked_system_calls   > "$cCarpetaDondeGuardar"/windows.unhooked_system_calls.txt
    # windows.unloadedmodules
      vol -f "$cRutaAlArchivoDeDump" windows.unloadedmodules         > "$cCarpetaDondeGuardar"/windows.unloadedmodules.txt
    # windows.vadinfo ()
      vol -f "$cRutaAlArchivoDeDump" windows.vadinfo                 > "$cCarpetaDondeGuardar"/windows.vadinfo.txt
    # windows.vadregexscan ()
      vol -f "$cRutaAlArchivoDeDump" windows.vadregexscan            > "$cCarpetaDondeGuardar"/windows.vadregexscan.txt # Requiere argumentos: [--pid [PID ...]] --pattern PATTERN [--maxsize MAXSIZE]
    # windows.vadwalk ()
      vol -f "$cRutaAlArchivoDeDump" windows.vadwalk                 > "$cCarpetaDondeGuardar"/windows.vadwalk.txt
    # windows.verinfo ()
      vol -f "$cRutaAlArchivoDeDump" windows.verinfo                 > "$cCarpetaDondeGuardar"/windows.verinfo.txt
    # windows.virtmap ()
      vol -f "$cRutaAlArchivoDeDump" windows.virtmap                 > "$cCarpetaDondeGuardar"/windows.virtmap.txt

    # No windows
      # banners ()
        vol -f "$cRutaAlArchivoDeDump" banners                         > "$cCarpetaDondeGuardar"/banners.txt
      # configwriter ()
        vol -f "$cRutaAlArchivoDeDump" configwriter                    > "$cCarpetaDondeGuardar"/configwriter.txt
      # frameworkinfo ()
        vol -f "$cRutaAlArchivoDeDump" frameworkinfo                   > "$cCarpetaDondeGuardar"/frameworkinfo.txt
      # isinfo ()
        vol -f "$cRutaAlArchivoDeDump" isfinfo                         > "$cCarpetaDondeGuardar"/isfinfo.txt
      # layerwriter ()
        mkdir -p ~/ArtefactosRAM/MemoryLayer/
        cd ~/ArtefactosRAM/MemoryLayer/
        vol -f "$cRutaAlArchivoDeDump" layerwriter
        cd ..
      # regexscan.RegExScan ()
        vol -f "$cRutaAlArchivoDeDump" regexscan.RegExScan             > "$cCarpetaDondeGuardar"/regexscan.RegExScan # Requiere argumentos --pattern PATTERN [--maxsize MAXSIZE]
      # timeliner ()
        vol -f "$cRutaAlArchivoDeDump" timeliner                       > "$cCarpetaDondeGuardar"/timeliner.txt
      # vmscan ()
        vol -f "$cRutaAlArchivoDeDump" vmscan                          > "$cCarpetaDondeGuardar"/vmscan.txt

