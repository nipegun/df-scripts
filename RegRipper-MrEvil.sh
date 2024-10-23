#!/bin/bash

# Definir fecha de ejecución del script
  cFechaDeEjec=$(date +a%Ym%md%d@%T)

# Definir variables
  vPuntoDeMontaje="/Particiones/Pruebas"
  vCarpetaDeCasos="/Casos"

# Determinar el caso actual y crear la carpeta
  vFechaCaso="$cFechaDeEjec"
  rm -rf "$vCarpetaDeCasos""$vFechaCaso" 2>/dev/null
  sudo mkdir -p "$vCarpetaDeCasos""$vFechaCaso"/Registro/

# Copiar archivos de registro
  echo ""
  echo "  Copiando SYSTEM..."
  echo ""
  sudo cp "$vPuntoDeMontaje"/WINDOWS/system32/config/system "$vCarpetaDeCasos""$vFechaCaso"/Registro/SYSTEM
  echo ""
  echo "  Copiando SAM..."
  echo ""
  sudo cp "$vPuntoDeMontaje"/WINDOWS/system32/config/SAM      "$vCarpetaDeCasos""$vFechaCaso"/Registro/SAM
  echo ""
  echo "  Copiando SECURITY..."
  echo ""
  sudo cp "$vPuntoDeMontaje"/WINDOWS/system32/config/SECURITY "$vCarpetaDeCasos""$vFechaCaso"/Registro/SECURITY
  echo ""
  echo "  Copiando SOFTWARE..."
  echo ""
  sudo cp "$vPuntoDeMontaje"/WINDOWS/system32/config/software "$vCarpetaDeCasos""$vFechaCaso"/Registro/SOFTWARE
  echo ""
  echo "  Copiando DEFAULT..."
  echo ""
  sudo cp "$vPuntoDeMontaje"/WINDOWS/system32/config/default  "$vCarpetaDeCasos""$vFechaCaso"/Registro/DEFAULT

# Copiar registro de usuarios
  echo ""
  echo "  Copiando archivos de registro de usuarios..."
  echo ""
  find "$vPuntoDeMontaje/Documents and Settings/" -mindepth 1 -maxdepth 1 -type d > /tmp/CarpetasDeUsuarios.txt
  while IFS= read -r linea; do
    vNomUsuario="${linea##*/}"
    echo ""
    echo "    Copiando NTUSER.DAT de $vNomUsuario..."
    echo ""
    sudo mkdir -p "$vCarpetaDeCasos$vFechaCaso"/Registro/Usuarios/"$vNomUsuario"
    cp "$vPuntoDeMontaje"/"Documents and Settings"/"$vNomUsuario"/NTUSER.DAT "$vCarpetaDeCasos$vFechaCaso"/Registro/Usuarios/"$vNomUsuario"/
  done < "/tmp/CarpetasDeUsuarios.txt"

# Exportar registros
  sudo mkdir -p "$vCarpetaDeCasos""$vFechaCaso"/RegRipper/ 2> /dev/null
  echo ""
  echo "  RegRippeando SYSTEM..."
  echo ""
  sudo /usr/local/bin/rip.pl -r "$vCarpetaDeCasos""$vFechaCaso"/Registro/SYSTEM   -a > "$vCarpetaDeCasos""$vFechaCaso"/RegRipper/SYSTEM.txt
  echo ""
  echo "  RegRippeando SAM..."
  echo ""
  sudo /usr/local/bin/rip.pl -r "$vCarpetaDeCasos""$vFechaCaso"/Registro/SAM      -a > "$vCarpetaDeCasos""$vFechaCaso"/RegRipper/SAM.txt
  echo ""
  echo "  RegRippeando SECURITY..."
  echo ""
  sudo /usr/local/bin/rip.pl -r "$vCarpetaDeCasos""$vFechaCaso"/Registro/SECURITY -a > "$vCarpetaDeCasos""$vFechaCaso"/RegRipper/SECURITY.txt
  echo ""
  echo "  RegRippeando SOFTWARE..."
  echo ""
  sudo /usr/local/bin/rip.pl -r "$vCarpetaDeCasos""$vFechaCaso"/Registro/SOFTWARE -a > "$vCarpetaDeCasos""$vFechaCaso"/RegRipper/SOFTWARE.txt
  echo ""
  echo "  RegRippeando DEFAULT..."
  echo ""
  sudo /usr/local/bin/rip.pl -r "$vCarpetaDeCasos""$vFechaCaso"/Registro/DEFAULT  -a > "$vCarpetaDeCasos""$vFechaCaso"/RegRipper/DEFAULT.txt

# Exportar registro de usuarios
  echo ""
  echo "  RegRippeando archivos de registro de usuarios..."
  echo ""
  find "$vPuntoDeMontaje/Documents and Settings/" -mindepth 1 -maxdepth 1 -type d > /tmp/CarpetasDeUsuarios.txt
  while IFS= read -r linea; do
    vNomUsuario="${linea##*/}"
    echo ""
    echo "    RegRippeando NTUSER.DAT de $vNomUsuario..."
    echo ""
    sudo mkdir -p "$vCarpetaDeCasos$vFechaCaso"/RegRipper/Usuarios/"$vNomUsuario" 2> /dev/null
    sudo /usr/local/bin/rip.pl -r "$vCarpetaDeCasos$vFechaCaso"/Registro/Usuarios/"$vNomUsuario"/NTUSER.DAT  -a > "$vCarpetaDeCasos$vFechaCaso"/RegRipper/Usuarios/"$vNomUsuario"/NTUSER.DAT.txt
  done < "/tmp/CarpetasDeUsuarios.txt"

# Reparar permisos
  sudo chown 1000:1000 $vCarpetaDeCasos -R


