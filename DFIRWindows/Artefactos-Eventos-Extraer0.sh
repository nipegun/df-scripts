#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para copiar los eventos de una partición de Windows y parsearlos a xml
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/DFIRWindows/Artefactos-Eventos-Extraer.sh | bash -s [PuntoDeMontajePartWindows] [CarpetaDelCaso] (Ambos sin barra final)
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/DFIRWindows/Artefactos-Eventos-Extraer.sh | nano -
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
    echo "    $0 [PuntoDeMontajePartWindows] [CarpetaDelCaso] (Ambos sin barra final)"
    echo ""
    echo "  Ejemplo:"
    echo "    $0 '/mnt/Windows/' '/Casos/2/Particiones/'"
    echo ""
    exit
  else
    vPuntoDeMontajePartWindows="$1"
    vCarpetaDelCaso="$2"

    # Notificar inicio de ejecución
      echo ""
      echo "    Copiando todos los eventos .evtx de la partición de Windows a la carpeta del caso..."
      echo ""

    # Detectar donde están los logs, dependiendo de si es windows XP o posterior
      vWindowsDir=""
      vSystem32Dir=""
      vWinEvtDir=""
      vLogsDir=""
      aEventFiles=()

      # Localizar System32 (punto de entrada fiable)
      vSys32Path=$(find "$vPuntoDeMontajePartWindows" -type d -iname "system32" -print -quit 2>/dev/null)

      if [ -n "$vSys32Path" ]; then
        vSystem32Dir=$(basename "$vSys32Path")
        vWindowsDir=$(basename "$(dirname "$vSys32Path")")

        # Caso Vista+ (winevt/Logs con .evtx)
        vWinEvtPath=$(find "$vSys32Path" -maxdepth 1 -type d -iname "winevt" -print -quit 2>/dev/null)
        if [ -n "$vWinEvtPath" ]; then
          vWinEvtDir=$(basename "$vWinEvtPath")
          vLogsPath=$(find "$vWinEvtPath" -maxdepth 1 -type d -iname "logs" -print -quit 2>/dev/null)
          if [ -n "$vLogsPath" ]; then
            vLogsDir=$(basename "$vLogsPath")
            mapfile -t aEventFiles < <(find "$vLogsPath" -type f -iname "*.evtx" -print 2>/dev/null)
            sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Eventos/
            sudo rm -rf "$vCarpetaDelCaso"/Artefactos/Originales/Eventos/*
            find "$vPuntoDeMontajePartWindows"/"$vWindowsDir"/"$vSystem32Dir"/"$vWinEvtDir"/"$vLogsDir" -name "*.evtx" -exec sudo cp -v {} "$vCarpetaDelCaso"/Artefactos/Originales/Eventos/ \;
          fi
        else
          # Caso XP/2003 (system32/config/*.evt)
          vLogsDir="config"
          mapfile -t aEventFiles < <(find "$vSys32Path/config" -maxdepth 1 -type f -iname "*.evt" -print 2>/dev/null)
          sudo mkdir -p "$vCarpetaDelCaso"/Artefactos/Originales/Eventos/
          sudo rm -rf "$vCarpetaDelCaso"/Artefactos/Originales/Eventos/*
          find "$vPuntoDeMontajePartWindows"/"$vWindowsDir"/"$vSystem32Dir"/"$vLogsDir"/ -name "*.evt" -exec sudo cp -v {} "$vCarpetaDelCaso"/Artefactos/Originales/Eventos/ \;
        fi
      fi

    # Reparar permisos
      sudo chown 1000:1000 "$vCarpetaDelCaso"/Artefactos/ -R

fi

