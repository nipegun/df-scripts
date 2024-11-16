#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para montar todas las particiones de dentro de un archivo de imagen
#
# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Imagen-Particiones-Desmontar-Todas.sh | sudo bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Imagen-Particiones-Desmontar-Todas.sh | nano -
# ----------

# Obtener los dispositivos de loopback montados como sólo lectura
  vLoopsMontadosComoReadOnly=$(mount | grep loop | grep ro | cut -d' ' -f1)

# Desmontarlos
  while read -r vDispositivo; do
    if mount | grep -q "$vDispositivo"; then
      echo ""
      echo "    Desmontando $vDispositivo..."
      echo ""
      sudo umount "$vDispositivo"
      echo ""
      echo "    Liberando $vDispositivo"
      echo ""
      sudo losetup -d "$vDispositivo"
    else
      echo "    $vDispositivo no está montado o no existe."
    fi
  done <<< "$vLoopsMontadosComoReadOnly"
