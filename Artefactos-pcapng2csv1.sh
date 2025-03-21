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
  -e arp.src.proto_ipv4 -e arp.dst.proto_ipv4 \
  -e icmp.type -e frame.protocols \
  -E separator=, -E quote=n -E header=n | \
awk -F, '{
  protos = $11;
  split(protos, arr, ":");
  proto = (length(arr) > 0) ? toupper(arr[length(arr)]) : "-";

  if ($1 != "" || $4 != "") {
    src_ip = ($1 != "") ? $1 : "-";
    dst_ip = ($4 != "") ? $4 : "-";
    src_port = ($2 != "") ? $2 : (($3 != "") ? $3 : "-");
    dst_port = ($5 != "") ? $5 : (($6 != "") ? $6 : "-");
  }
  else if (proto == "ARP") {
    src_ip = ($7 != "") ? $7 : "-";
    dst_ip = ($8 != "") ? $8 : "-";
    src_port = "-";
    dst_port = "-";
  }
  else if (proto == "ICMP") {
    src_ip = ($1 != "") ? $1 : "-";
    dst_ip = ($4 != "") ? $4 : "-";
    src_port = "ICMP-" (($9 != "") ? $9 : "?");
    dst_port = "-";
  }
  else {
    src_ip = "-";
    dst_ip = "-";
    src_port = "-";
    dst_port = "-";
  }

  print src_ip "," src_port "," dst_ip "," dst_port "," proto;
}'
