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


mac.bash.Bash
mac.check_syscall.Check_syscall
mac.check_sysctl.Check_sysctl
mac.check_trap_table.Check_trap_table
mac.dmesg.Dmesg
mac.ifconfig.Ifconfig
mac.kauth_listeners.Kauth_listeners
mac.kauth_scopes.Kauth_scopes
mac.kevents.Kevents
mac.list_files.List_Files
mac.lsmod.Lsmod
mac.lsof.Lsof
mac.malfind.Malfind
mac.mount.Mount
mac.netstat.Netstat
mac.proc_maps.Maps
mac.psaux.Psaux
mac.pslist.PsList
mac.pstree.PsTree
mac.socket_filters.Socket_filters
mac.timers.Timers
mac.trustedbsd.Trustedbsd
mac.vfsevents.VFSevents

banners.Banners
configwriter.ConfigWriter
frameworkinfo.FrameworkInfo
isfinfo.IsfInfo
layerwriter.LayerWriter
timeliner.Timeliner
vmscan.Vmscan
yarascan.YaraScan
