#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para parsear datos extraidos de la RAM de Windows en Debian
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Windows-Artefactos-RAM-Extraer-DeDump.sh | sudo bash -s [RutaAlArchivoConDump]
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Windows-Artefactos-RAM-Extraer-DeDump.sh | nano -
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

if [ $# -ne $cCantParamEsperados ]
  then
    echo ""
    echo -e "${cColorRojo}  Mal uso del script. El uso correcto sería: ${cFinColor}"
    echo "    $0 [RutaAlArchivoConDump] [CarpetaDondeGuardar]"
    echo ""
    echo "  Ejemplo:"
    echo "    $0 [/Casos/a2024m11d24/Dump/RAM.dump] [/Casos/a2024m11d24/Artefactos]"
    echo ""
    exit
  else
    # Crear constante para archivo de dump
      cRutaAlArchivoDeDump="$1"
      cCarpetaDondeGuardar="$2"
      mkdir -p "$cCarpetaDondeGuardar"

    # Entrar en el entorno virtual
      python3 -m venv ~/PythonVirtualEnvironments/volatility3
      source ~/PythonVirtualEnvironments/volatility3/bin/activate
    # Información del sistema operativo
      echo ""
      echo "  Extrayendo información del sistema operativo..."
      echo ""
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.info > "$cCarpetaDondeGuardar"/windows.info.txt
    # Procesos
      echo ""
      echo "  Extrayendo información de procesos"
      echo ""
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.pslist | sort -n | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.pslist.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.psscan | sort -n | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.psscan.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.pstree | sort -n | grep -v "Volatility 3" > "$cCarpetaDondeGuardar"/windows.pstree.txt
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
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.vadyarascan ‑‑yara-rules "<string>"
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.vadyarascan ‑‑yara-file "/path/to/file.yar"
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" yarascan.yarascan   ‑‑yara-file "/path/to/file.yar"

  # Desactivar el entorno virtual
    deactivate

fi

      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.amcache                 > "$cCarpetaDondeGuardar"/windows.amcache.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.bigpools                > "$cCarpetaDondeGuardar"/windows.bigpools.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.cachedump               > "$cCarpetaDondeGuardar"/windows.cachedump.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.callbacks               > "$cCarpetaDondeGuardar"/windows.cmdline.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.cmdline                 > "$cCarpetaDondeGuardar"/windows.cmdline.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.cmdscan                 > "$cCarpetaDondeGuardar"/windows.cmdscan.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.consoles                > "$cCarpetaDondeGuardar"/windows.consoles.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.crashinfo               > "$cCarpetaDondeGuardar"/windows.crashinfo.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.debugregisters          > "$cCarpetaDondeGuardar"/windows.debugregisters.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.devicetree              > "$cCarpetaDondeGuardar"/windows.devicetree.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.dlllist                 > "$cCarpetaDondeGuardar"/windows.dlllist.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.driverirp               > "$cCarpetaDondeGuardar"/windows.driverirp.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.drivermodule            > "$cCarpetaDondeGuardar"/windows.drivermodule.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.driverscan              > "$cCarpetaDondeGuardar"/windows.driverscan.txt
      mkdir -p ~/ArtefactosRAM/Archivos
      cd ~/ArtefactosRAM/Archivos/
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.dumpfiles
      cd .. 
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.envars                  > "$cCarpetaDondeGuardar"/windows.envars.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.filescan                > "$cCarpetaDondeGuardar"/windows.filescan.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.getservicesids          > "$cCarpetaDondeGuardar"/windows.getservicesids.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.getsids                 > "$cCarpetaDondeGuardar"/windows.getsids.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.handles                 > "$cCarpetaDondeGuardar"/windows.handles.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.hashdump                > "$cCarpetaDondeGuardar"/windows.hashdump.txt # creo que requiere parámetros
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.hollowprocesses         > "$cCarpetaDondeGuardar"/windows.hollowprocesses.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.iat                     > "$cCarpetaDondeGuardar"/windows.iat.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.info                    > "$cCarpetaDondeGuardar"/windows.info.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.joblinks                > "$cCarpetaDondeGuardar"/windows.joblinks.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.kpcrs                   > "$cCarpetaDondeGuardar"/windows.kpcrs.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.ldrmodules              > "$cCarpetaDondeGuardar"/windows.ldrmodules.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.lsadump                 > "$cCarpetaDondeGuardar"/windows.lsadump.txt # Dio error  enc_secret_value = next(sec_val_key.get_values())
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.malfind                 > "$cCarpetaDondeGuardar"/windows.malfind.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.mbrscan                 > "$cCarpetaDondeGuardar"/windows.mbrscan.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.memmap                  > "$cCarpetaDondeGuardar"/windows.memmap.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.mftscan.ADS             > "$cCarpetaDondeGuardar"/windows.mftscan.ADS.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.mftscan.MFTScan         > "$cCarpetaDondeGuardar"/windows.mftscan.MFTScan.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.modscan                 > "$cCarpetaDondeGuardar"/windows.modscan.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.modules                 > "$cCarpetaDondeGuardar"/windows.modules.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.mutantscan              > "$cCarpetaDondeGuardar"/windows.mutantscan.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.netscan                 > "$cCarpetaDondeGuardar"/windows.netscan.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.netstat                 > "$cCarpetaDondeGuardar"/windows.netstat.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.orphan_kernel_threads   > "$cCarpetaDondeGuardar"/windows.orphan_kernel_threads.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.pe_symbols              > "$cCarpetaDondeGuardar"/ # Requiere argumentos
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.pedump                  > "$cCarpetaDondeGuardar"/ # Requiere argumentos
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.poolscanner             > "$cCarpetaDondeGuardar"/windows.poolscanner.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.privileges              > "$cCarpetaDondeGuardar"/windows.privileges.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.processghosting         > "$cCarpetaDondeGuardar"/windows.processghosting.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.pslist                  > "$cCarpetaDondeGuardar"/windows.pslist.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.psscan                  > "$cCarpetaDondeGuardar"/windows.psscan.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.pstree                  > "$cCarpetaDondeGuardar"/windows.pstree.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.psxview                 > "$cCarpetaDondeGuardar"/windows.psxview.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.registry.certificates   > "$cCarpetaDondeGuardar"/ # Dio error
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.registry.getcellroutine > "$cCarpetaDondeGuardar"/windows.registry.getcellroutine.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.registry.hivelist       > "$cCarpetaDondeGuardar"/windows.registry.hivelist.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.registry.hivescan       > "$cCarpetaDondeGuardar"/windows.registry.hivescan.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.registry.printkey       > "$cCarpetaDondeGuardar"/windows.registry.printkey.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.registry.userassist     > "$cCarpetaDondeGuardar"/windows.registry.userassist.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.scheduled_tasks         > "$cCarpetaDondeGuardar"/windows.scheduled_tasks.txt # dio error
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.sessions                > "$cCarpetaDondeGuardar"/windows.sessions.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.shimcachemem            > "$cCarpetaDondeGuardar"/windows.shimcachemem.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.skeleton_key_check      > "$cCarpetaDondeGuardar"/windows.skeleton_key_check.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.ssdt                    > "$cCarpetaDondeGuardar"/windows.ssdt.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.statistics              > "$cCarpetaDondeGuardar"/windows.statistics.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.strings                 > "$cCarpetaDondeGuardar"/ # Requiere parámetros
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.suspicious_threads      > "$cCarpetaDondeGuardar"/windows.suspicious_threads.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.svcdiff                 > "$cCarpetaDondeGuardar"/windows.svcdiff.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.svclist                 > "$cCarpetaDondeGuardar"/windows.svclist.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.svcscan                 > "$cCarpetaDondeGuardar"/windows.svcscan.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.symlinkscan             > "$cCarpetaDondeGuardar"/windows.symlinkscan.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.thrdscan                > "$cCarpetaDondeGuardar"/windows.thrdscan.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.threads                 > "$cCarpetaDondeGuardar"/windows.threads.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.timers                  > "$cCarpetaDondeGuardar"/windows.timers.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.truecrypt               > "$cCarpetaDondeGuardar"/windows.truecrypt # Dio erro ruecrypt_module_base = next(
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.unhooked_system_calls   > "$cCarpetaDondeGuardar"/windows.unhooked_system_calls.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.unloadedmodules         > "$cCarpetaDondeGuardar"/windows.unloadedmodules.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.vadinfo                 > "$cCarpetaDondeGuardar"/windows.vadinfo.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.vadwalk                 > "$cCarpetaDondeGuardar"/windows.vadwalk.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.vadyarascan             > "$cCarpetaDondeGuardar"/windows.vadyarascan # Dio error
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.verinfo                 > "$cCarpetaDondeGuardar"/windows.verinfo.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.virtmap                 > "$cCarpetaDondeGuardar"/windows.virtmap.txt
     # No windows
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" banners                         > "$cCarpetaDondeGuardar"/banners.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" configwriter                    > "$cCarpetaDondeGuardar"/configwriter.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" frameworkinfo                   > "$cCarpetaDondeGuardar"/frameworkinfo.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" isfinfo                         > "$cCarpetaDondeGuardar"/isfinfo.txt
      mkdir -p ~/ArtefactosRAM/MemoryLayer/
      cd ~/ArtefactosRAM/MemoryLayer/
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" layerwriter
      cd .. 
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" timeliner                       > "$cCarpetaDondeGuardar"/timeliner.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" vmscan                          > "$cCarpetaDondeGuardar"/vmscan.txt
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" yarascan                        > "$cCarpetaDondeGuardar"/yarascan.YaraScan

