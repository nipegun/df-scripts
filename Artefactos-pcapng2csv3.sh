#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para parsear tráfico pcpng en la terminal
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Artefactos-pcapng2csv.sh | sudo bash -s [Archivo .pcapng]
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Artefactos-pcapng2csv.sh | nano -
# ----------

cColorAzul="\033[0;34m"
cColorAzulClaro="\033[1;34m"
cColorVerde='\033[1;32m'
cColorRojo='\033[1;31m'
cFinColor='\033[0m'

vArchivoPCAPNG="$1"

tshark -r  $vArchivoPCAPNG -T fields \
  -e ip.src -e tcp.srcport -e udp.srcport \
  -e ip.dst -e tcp.dstport -e udp.dstport \
  -e frame.protocols \
  -E separator=, -E quote=n -E header=n | \
awk -F, '{
  protos = $7;
  proto = "-";
  appproto = "-";

  if (protos ~ /tcp/) proto = "TCP";
  else if (protos ~ /udp/) proto = "UDP";

  if (protos ~ /s7comm/) appproto = "S7COMM";
  else if (protos ~ /cipio/) appproto = "CIPIO";
  else if (protos ~ /vnc/) appproto = "VNC";
  else if (protos ~ /lldp/) appproto = "LLDP";
  else if (protos ~ /arp/) appproto = "ARP";

  src_ip = ($1 != "") ? $1 : "-";
  dst_ip = ($4 != "") ? $4 : "-";
  src_port = ($2 != "") ? $2 : (($3 != "") ? $3 : "-");
  dst_port = ($5 != "") ? $5 : (($6 != "") ? $6 : "-");

  print src_ip "," src_port "," dst_ip "," dst_port "," proto "," appproto;
}'
