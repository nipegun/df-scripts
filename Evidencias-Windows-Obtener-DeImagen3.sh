#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para analizar y exportar el archivo $MFT original a múltimples formatos
#
# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Evidencias-Windows-Obtener-DeImagen.sh | sudo bash -s /Ruta/Al/Archivo/De/Imagen/De/Evidencia
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Evidencias-Windows-Obtener-DeImagen.sh | nano -
# ----------

# Comprobar si el paquete dialog está instalado. Si no lo está, instalarlo.
  if [[ $(dpkg-query -s dialog 2>/dev/null | grep installed) == "" ]]; then
    echo ""
    echo -e "${cColorRojo}  El paquete dialog no está instalado. Iniciando su instalación...${cFinColor}"
    echo ""
    apt-get -y update && apt-get -y install dialog
    echo ""
  fi

# Crear el menú
  menu=(dialog --checklist "Marca las opciones que quieras instalar:" 22 62 16)
    opciones=(
      1 "Montar todas las particiones en modo lectura" on
      2 "Extraer y parsear el registro" on
      3 "Extraer y parsear la MFT" off
      4 "Recolectar eventos originales" on
      5 "  Parsear eventos originales" off
    )
  choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)

  for choice in $choices
    do
      case $choice in

        1)

          echo ""
          echo "  Montando todas las particiones en modo lectura..."
          echo ""
          curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Imagen-Particiones-Montar-SoloLectura.sh | sed 's|$(date +a%Ym%md%d@%T)|"Examen"|g' | sudo bash -s $1

        ;;

        2)

          echo ""
          echo "  Extrayendo y parseando el registro..."
          echo ""
          # Instalar RegRipper (Sólo se ejecuta en Debian)
            curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/RegRipper-Instalar.sh | sudo bash
          # Ejecutar RegRipper
            curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Registro-Extraer-Completo-WindowsVistaYPosterior.sh | sudo bash -s /Casos/Examen/Particiones/2 /Casos/Examen

        ;;

        3)

          echo ""
          echo "  Extrayendo y parseando la MFT..."
          echo ""
          # Extraer MFT
            curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/MFT-Extraer-Original.sh | sudo bash -s /Casos/Examen/Particiones/2 /Casos/Examen
         # Instalar analyzeMFT
           curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/analyzeMFT-Instalar.sh | sudo bash
         # Ejecutar analyzemft sobre la evidencia
           curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/MFT-AnalizarYExportar.sh | sudo bash -s /Casos/Examen/MFT/MFTOriginal /Casos/Examen/MFT

        ;;

        4)

          echo ""
          echo "  Recolectando eventos originales..."
          echo ""
          curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Evidencia-Windows-Eventos-Originales-Recolectar.sh | sudo bash -s /Casos/Examen/Particiones/2 /Casos/Examen

        ;;

        5)

          echo ""
          echo "  Parseando eventos recolectados..."
          echo ""
          curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Evidencia-Windows-Eventos-Recolectados-Parsear.sh | sudo bash -s /Casos/Examen/Eventos/Originales/ /Casos/Examen

        ;;

    esac

done

