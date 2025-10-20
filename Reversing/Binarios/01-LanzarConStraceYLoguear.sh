#!/bin/bash


# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para instalar y configurar xxxxxxxxx en Debian
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL x | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL x | sed 's-sudo--g' | bash
#
# Ejecución remota sin caché:
#   curl -sL -H 'Cache-Control: no-cache, no-store' x | bash
#
# Ejecución remota con parámetros:
#   curl -sL x | bash -s Parámetro1 Parámetro2
#
# Bajar y editar directamente el archivo en nano
#   curl -sL x | nano -
# ----------

# Cuardar el argumento en una variable
  vRutaAlBinario="$1"

# Obtener la ruta absoluta en la que está el binario
  vCarpetaBinario=""

# Ejecutar strace
  # Comprobar si el paquete strace está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s strace 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${cColorRojo}  El paquete strace no está instalado. Iniciando su instalación...${cFinColor}"
      echo ""
      sudo apt-get -y update
      sudo apt-get -y install strace
      echo ""
    fi
  strace -f -ttt -T -v -s 4096 -yy -e trace=all -o "$vCarpetaBinario"/strace.log "$vRutaAlBionario"

# Notificar fin de ejecución del script
  echo ""
  echo "  Ejecución del script, finalizada. El archivo con el log de strace debería estar en:"
  echo ""
  echo "    "$vCarpetaBinario"/strace.log"
  echo ""
