#!/bin/bash

# Definir fecha de ejecución del script
  cFechaDeEjec=$(date +a%Ym%md%d@%T)

# Definir variables
  vPuntoDeMontaje="/Particiones/Pruebas"
  vCarpetaDeCasos="/Casos"

# Determinar el caso actual y crear la carpeta
  vFechaCaso="$cFechaDeEjec"
  rm -rf "$vCarpetaDeCasos"/"$vFechaCaso" 2>/dev/null
  sudo mkdir -p "$vCarpetaDeCasos"/"$vFechaCaso"/Registro/Archivos/

# Copiar archivos de registro
  echo ""
  echo "  Copiando SYSTEM..."
  echo ""
  sudo cp "$vPuntoDeMontaje"/WINDOWS/system32/config/system   "$vCarpetaDeCasos"/"$vFechaCaso"/Registro/Archivos/SYSTEM
  echo ""
  echo "  Copiando SAM..."
  echo ""
  sudo cp "$vPuntoDeMontaje"/WINDOWS/system32/config/SAM      "$vCarpetaDeCasos"/"$vFechaCaso"/Registro/Archivos/SAM
  echo ""
  echo "  Copiando SECURITY..."
  echo ""
  sudo cp "$vPuntoDeMontaje"/WINDOWS/system32/config/SECURITY "$vCarpetaDeCasos"/"$vFechaCaso"/Registro/Archivos/SECURITY
  echo ""
  echo "  Copiando SOFTWARE..."
  echo ""
  sudo cp "$vPuntoDeMontaje"/WINDOWS/system32/config/software "$vCarpetaDeCasos"/"$vFechaCaso"/Registro/Archivos/SOFTWARE
  echo ""
  echo "  Copiando DEFAULT..."
  echo ""
  sudo cp "$vPuntoDeMontaje"/WINDOWS/system32/config/default  "$vCarpetaDeCasos"/"$vFechaCaso"/Registro/Archivos/DEFAULT

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
    sudo mkdir -p "$vCarpetaDeCasos"/"$vFechaCaso"/Registro/Archivos/Usuarios/"$vNomUsuario"
    cp "$vPuntoDeMontaje"/"Documents and Settings"/"$vNomUsuario"/NTUSER.DAT "$vCarpetaDeCasos"/"$vFechaCaso"/Registro/Archivos/Usuarios/"$vNomUsuario"/
  done < "/tmp/CarpetasDeUsuarios.txt"


# Exportar registros
  sudo mkdir -p "$vCarpetaDeCasos"/"$vFechaCaso"/Registro/RegRipper/ 2> /dev/null
  echo ""
  echo "  RegRippeando SYSTEM..."
  echo ""
  sudo /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/"$vFechaCaso"/Registro/Archivos/SYSTEM   -a > "$vCarpetaDeCasos"/"$vFechaCaso"/Registro/RegRipper/SYSTEM.txt
  echo ""
  echo "  RegRippeando SAM..."
  echo ""
  sudo /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/"$vFechaCaso"/Registro/Archivos/SAM      -a > "$vCarpetaDeCasos"/"$vFechaCaso"/Registro/RegRipper/SAM.txt
  echo ""
  echo "  RegRippeando SECURITY..."
  echo ""
  sudo /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/"$vFechaCaso"/Registro/Archivos/SECURITY -a > "$vCarpetaDeCasos"/"$vFechaCaso"/Registro/RegRipper/SECURITY.txt
  echo ""
  echo "  RegRippeando SOFTWARE..."
  echo ""
  sudo /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/"$vFechaCaso"/Registro/Archivos/SOFTWARE -a > "$vCarpetaDeCasos"/"$vFechaCaso"/Registro/RegRipper/SOFTWARE.txt
  echo ""
  echo "  RegRippeando DEFAULT..."
  echo ""
  sudo /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/"$vFechaCaso"/Registro/Archivos/DEFAULT  -a > "$vCarpetaDeCasos"/"$vFechaCaso"/Registro/RegRipper/DEFAULT.txt

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
    sudo mkdir -p "$vCarpetaDeCasos"/"$vFechaCaso"/Registro/RegRipper/Usuarios/"$vNomUsuario" 2> /dev/null
    sudo /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/"$vFechaCaso"/Registro/Archivos/Usuarios/"$vNomUsuario"/NTUSER.DAT  -a > "$vCarpetaDeCasos"/"$vFechaCaso"/Registro/RegRipper/Usuarios/"$vNomUsuario"/NTUSER.DAT.txt
  done < "/tmp/CarpetasDeUsuarios.txt"

# Reparar permisos
  sudo chown 1000:1000 $vCarpetaDeCasos -R


