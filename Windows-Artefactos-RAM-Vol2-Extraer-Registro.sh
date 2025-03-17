#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para usar volatility2 para extraer la RAM de todos los procesos
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Windows-Artefactos-RAM-Vol2-Extraer-Registro.sh | bash -s [RutaAlArchivoConDump] [RutaALaCarpetaDestino]
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Windows-Artefactos-RAM-Vol2-Extraer-Registro.sh | nano -
#
# Más info aquí: https://github.com/volatilityfoundation/volatility/wiki/Command-Reference
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

# Calcular los posibles perfiles a aplicar al dump
  echo ""
  echo "  Calculando que perfiles se le pueden aplicar al dump..."
  echo ""
  vPerfilesSugeridos=$(vol.py -f "$cRutaAlArchivoDeDump" imageinfo | grep uggested | cut -d':' -f2 | sed 's-,--g' | sed "s- -\n-" | sed 's- -|-g' | sed 's-|- | -g')
  echo ""
  echo "    Se le pueden aplicar los siguientes perfiles:"
  echo "      $vPerfilesSugeridos"

# Guardar todos los perfiles en un archivo
  mkdir -p ~/volatility2/
  vol.py --info | grep "A Profile" | cut -d' ' -f1 > ~/volatility2/Volatility2-TodosLosPerfiles.txt
# Guardar los perfiles sugeridos en un archivo
  vol.py -f "$cRutaAlArchivoDeDump" imageinfo | grep uggested | cut -d':' -f2 | sed 's-,--g' | sed "s- -\n-" | sed 's- -|-g' | sed 's/|/\n/g' | sed 's-  --g' | sed 's- --g' | sed '/^$/d' > ~/volatility2/Volatility2-PerfilesSugeridos-Temp.txt
  cat ~/volatility2/Volatility2-PerfilesSugeridos-Temp.txt | sed '/^$/d' | sed '/^(/d' | sed '/^with/d' | sed 's-)--g' | sort -n > ~/volatility2/Volatility2-PerfilesSugeridos.txt
# Obtener la versión correcta del sistema operativo
  vPerfil=$(cat ~/volatility2/Volatility2-PerfilesSugeridos.txt | grep 19041)
  vol.py -f "$cRutaAlArchivoDeDump" --profile="$vPerfil" pslist | tr -s ' ' | cut -d' ' -f3 | grep ^[0-9] | sort -n | uniq | grep -v ^0 > ~/volatility2/Volatility2-TodosLosHives.txt

  vol.py -f "$cRutaAlArchivoDeDump" --profile="$vPerfil" pslist | tr -s ' ' | cut -d' ' -f3 | grep ^[0-9] | sort -n | uniq | grep -v ^0 > ~/volatility2/Volatility2-TodosLosProcesos.txt
# Extraer los ejecutables de todos los procesos
    echo ""
    echo "  Extrayendo los ejecutables de todos los procesos..."
    echo ""
    while IFS= read -r vNumProceso; do
      mkdir -p "$cCarpetaDondeGuardar"/Proceso$vNumProceso/
      vol.py -f "$cRutaAlArchivoDeDump" --profile="$vPerfil" procdump -p $vNumProceso -D "$cCarpetaDondeGuardar"/Proceso$vNumProceso/
    done < ~/volatility2/Volatility2-TodosLosProcesos.txt
# Extraer la memoria de todos todos los procesos
    echo ""
    echo "  Extrayendo la memoria de todos los procesos..."
    echo ""
    while IFS= read -r vNumProceso; do
      mkdir -p "$cCarpetaDondeGuardar"/Proceso$vNumProceso/
      vol.py -f "$cRutaAlArchivoDeDump" --profile="$vPerfil" memdump -p $vNumProceso -D "$cCarpetaDondeGuardar"/Proceso$vNumProceso/
    done < ~/volatility2/Volatility2-TodosLosProcesos.txt
# Extraer las dll de todos los procesos
    echo ""
    echo "  Extrayendo los ejecutables de todos los procesos..."
    echo ""
    while IFS= read -r vNumProceso; do
      mkdir -p "$cCarpetaDondeGuardar"/Proceso$vNumProceso/
      vol.py -f "$cRutaAlArchivoDeDump" --profile="$vPerfil" dlldump -p $vNumProceso -D "$cCarpetaDondeGuardar"/Proceso$vNumProceso/
    done < ~/volatility2/Volatility2-TodosLosProcesos.txt
# Extraer módulos del kernel en memoria.
  mkdir -p "$cCarpetaDondeGuardar"/ModulosDelKernel/
  vol.py -f "$cRutaAlArchivoDeDump" --profile="$vPerfil" moddump -D "$cCarpetaDondeGuardar"/ModulosDelKernel/
