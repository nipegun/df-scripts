#!/bin/bash

# Definir variables
  vPuntoDeMontaje="/Particiones/Pruebas"
  vCarpetaDeCasos="/Casos"

# Determinar el caso actual y crear la carpeta
  vCasoActual="/22"
  rm -rf $vCarpetaDeCasos$vCasoActual 2>/dev/null
  sudo mkdir -p $vCarpetaDeCasos$vCasoActual

# Reparar permisos
  sudo chown 1000:1000 $vCarpetaDeCasos -R

# Exportar registros
  echo ""
  echo "  Exportando SYSTEM..."
  echo ""
  sudo /usr/local/bin/rip.pl -r $vPuntoDeMontaje/WINDOWS/system32/config/system   -a > $vCarpetaDeCasos$vCasoActual/SYSTEM.txt
  echo ""
  echo "  Exportando SAM..."
  echo ""
  sudo /usr/local/bin/rip.pl -r $vPuntoDeMontaje/WINDOWS/system32/config/SAM      -a > $vCarpetaDeCasos$vCasoActual/SAM.txt
  echo ""
  echo "  Exportando SECURITY..."
  echo ""
  sudo /usr/local/bin/rip.pl -r $vPuntoDeMontaje/WINDOWS/system32/config/SECURITY -a > $vCarpetaDeCasos$vCasoActual/SECURITY.txt
  echo ""
  echo "  Exportando SOFTWARE..."
  echo ""
  sudo /usr/local/bin/rip.pl -r $vPuntoDeMontaje/WINDOWS/system32/config/software -a > $vCarpetaDeCasos$vCasoActual/SOFTWARE.txt
  echo ""
  echo "  Exportando DEFAULT..."
  echo ""
  sudo /usr/local/bin/rip.pl -r $vPuntoDeMontaje/WINDOWS/system32/config/default  -a > $vCarpetaDeCasos$vCasoActual/DEFAULT.txt

# Exportando registro de usuarios
  echo ""
  echo "  Exportando registro de usuarios..."
  echo ""
  find "$vPuntoDeMontaje/Documents and Settings/" -mindepth 1 -maxdepth 1 -type d > /tmp/CarpetasDeUsuarios.txt
  while IFS= read -r linea; do
    vNomUsuario="${linea##*/}"
    echo "$vNomUsuario"
    sudo mkdir -p "$vCarpetaDeCasos$vCasoActual"/Usuarios/"$vNomUsuario"
  done < "/tmp/CarpetasDeUsuarios.txt"
