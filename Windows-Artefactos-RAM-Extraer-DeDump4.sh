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
  cCantParamEsperados=1

if [ $# -ne $cCantParamEsperados ]
  then
    echo ""
    echo -e "${cColorRojo}  Mal uso del script. El uso correcto sería: ${cFinColor}"
    echo "    $0 [RutaAlArchivoConDump]"
    echo ""
    echo "  Ejemplo:"
    echo "    $0 'Hola'"
    echo ""
    exit
  else
    # Crear constante para archivo de dump
      cRutaAlArchivoDeDump="$2"
    # Información del sistema operativo
      echo ""
      echo "  Extrayendo información del sistema operativo..."
      echo ""
      ~/PythonVirtualEnvironments/volatility3/bin/activate
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.info
    # Procesos
      echo ""
      echo "  Extrayendo información de procesos"
      echo ""
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.pslist
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.psscan
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.pstree
    # ProcDump (Dumpea .exes y DLLs asociadas)
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" -o "/path/to/dir" windows.dumpfiles ‑‑pid "<PID>" 
    # MemDump
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" -o "/path/to/dir" windows.memmap ‑‑dump ‑‑pid "<PID>"

    # Handles (Dumpea PID, process, offset, handlevalue, type, grantedaccess, name)
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.handles ‑‑pid "<PID>"

    # DLLs (PID, process, base, size, name, path, loadtime, file output)
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.dlllist ‑‑pid "<PID>"

    # CMDLine (PID, process name, args)
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.cmdline

    # Red
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.netscan
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.netstat

# Registro

  # HiveList
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.registry.hivescan
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.registry.hivelist

  # Registry printkey
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.registry.printkey
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.registry.printkey ‑‑key "Software\Microsoft\Windows\CurrentVersion"

# Archivos

  # FileScan
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.filescan

  # FileDump
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" -o "/path/to/dir" windows.dumpfiles
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" -o "/path/to/dir" windows.dumpfiles ‑‑virtaddr "<offset>"
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" -o "/path/to/dir" windows.dumpfiles ‑‑physaddr "<offset>"

# Misceláneo

  # MalFind (Dumpea PID, process name, process start, protection, commit charge, privatememory, file output, hexdump disassembly)
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.malfind

  # Yarascan
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.vadyarascan ‑‑yara-rules "<string>"
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" windows.vadyarascan ‑‑yara-file "/path/to/file.yar"
      ~/scripts/python/volatility3/vol.py -f "$cRutaAlArchivoDeDump" yarascan.yarascan   ‑‑yara-file "/path/to/file.yar"

fi
