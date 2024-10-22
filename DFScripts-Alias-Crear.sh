#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para crear los alias de los df-scripts 
# ----------

cColorAzul="\033[0;34m"
cColorAzulClaro="\033[1;34m"
cColorVerde='\033[1;32m'
cColorRojo='\033[1;31m'
cFinColor='\033[0m'

echo ""
echo -e "${cColorAzulClaro}  Creando alias para los df-scripts...${cFinColor}"
echo ""

ln -s /root/scripts/df-scripts/x.sh                      /root/scripts/df-scripts/Alias/x

echo ""
echo -e "${cColorVerde}    Alias creados. Deberías poder ejecutar los df-scripts escribiendo el nombre de su alias.${cFinColor}"
echo ""
# sh -c "echo 'export PATH=$PATH:/root/scripts/df-scripts/Alias/' >> /root/.bashrc"
