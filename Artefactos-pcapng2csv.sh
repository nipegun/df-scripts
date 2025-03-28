#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para parsear tráfico pcpng en la terminal
#
# Ejecución remota con parámetros:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Artefactos-pcapng2csv.sh | bash -s [Archivo .pcapng]
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

# Imprimir cabecera
echo "timestamp,src_ip,src_port,dst_ip,dst_port,proto,appproto,length,info"

tshark -r  "$vArchivoPCAPNG" -T fields     \
  -e frame.time_epoch -e ip.src -e tcp.srcport -e udp.srcport \
  -e ip.dst -e tcp.dstport -e udp.dstport \
  -e frame.protocols -e frame.len -e _ws.col.Info \
  -E separator=, -E quote=n -E header=n | \
awk -F, '{
  ts = ($1 != "") ? $1 : "-";
  src_ip = ($2 != "") ? $2 : "-";
  src_port = ($3 != "") ? $3 : (($4 != "") ? $4 : "-");
  dst_ip = ($5 != "") ? $5 : "-";
  dst_port = ($6 != "") ? $6 : (($7 != "") ? $7 : "-");
  protos = $8;
  pkt_len = ($9 != "") ? $9 : "-";
  info = ($10 != "") ? $10 : "-";

  proto = "-";
  appproto = "-";

  if (protos ~ /tcp/) proto = "TCP";
  else if (protos ~ /udp/) proto = "UDP";

  if (protos ~ /s7comm/) appproto = "S7COMM";
  else if (protos ~ /cipio/) appproto = "CIPIO";
  else if (protos ~ /vnc/) appproto = "VNC";
  else if (protos ~ /lldp/) appproto = "LLDP";
  else if (protos ~ /arp/) appproto = "ARP";

  gsub(/,/, " ", info);

  print ts "," src_ip "," src_port "," dst_ip "," dst_port "," proto "," appproto "," pkt_len ",\"" info "\"";
}'

