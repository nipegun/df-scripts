#!/bin/bash

# Definir fecha de ejecución del script
  cFechaDeEjec=$(date +a%Ym%md%d@%T)

# Definir variables
  vPuntoDeMontaje="$1" # Debe ser una carpeta sin barra final
  vCarpetaDeCasos="$2" # Debe ser una carpeta sin barra final

# Determinar el caso actual y crear la carpeta
  vFechaCaso="$cFechaDeEjec"
  rm -rf "$vCarpetaDeCasos"/"$vFechaCaso" 2>/dev/null
  sudo mkdir -p "$vCarpetaDeCasos"/"$vFechaCaso"/Registro/Archivos/

# Copiar archivos de registro
  echo ""
  echo "  Copiando SYSTEM..."
  echo ""
  sudo cp "$vPuntoDeMontaje"/Windows/System32/config/SYSTEM   "$vCarpetaDeCasos"/Registro/Archivos/SYSTEM
  echo ""
  echo "  Copiando SAM..."
  echo ""
  sudo cp "$vPuntoDeMontaje"/Windows/System32/config/SAM      "$vCarpetaDeCasos"/Registro/Archivos/SAM
  echo ""
  echo "  Copiando SECURITY..."
  echo ""
  sudo cp "$vPuntoDeMontaje"/Windows/System32/config/SECURITY "$vCarpetaDeCasos"/Registro/Archivos/SECURITY
  echo ""
  echo "  Copiando SOFTWARE..."
  echo ""
  sudo cp "$vPuntoDeMontaje"/Windows/System32/config/SOFTWARE "$vCarpetaDeCasos"/Registro/Archivos/SOFTWARE
  echo ""
  echo "  Copiando DEFAULT..."
  echo ""
  sudo cp "$vPuntoDeMontaje"/Windows/system32/config/DEFAULT  "$vCarpetaDeCasos"/Registro/Archivos/DEFAULT

# Copiar registro de usuarios
  echo ""
  echo "  Copiando archivos de registro de usuarios..."
  echo ""
  find "$vPuntoDeMontaje/Users/" -mindepth 1 -maxdepth 1 -type d > /tmp/CarpetasDeUsuarios.txt
  while IFS= read -r linea; do
    vNomUsuario="${linea##*/}"
    echo ""
    echo "    Copiando NTUSER.DAT de $vNomUsuario..."
    echo ""
    sudo mkdir -p "$vCarpetaDeCasos"/Registro/Archivos/Usuarios/"$vNomUsuario"
    cp "$vPuntoDeMontaje"/"Users"/"$vNomUsuario"/NTUSER.DAT "$vCarpetaDeCasos"/Registro/Archivos/Usuarios/"$vNomUsuario"/
  done < "/tmp/CarpetasDeUsuarios.txt"


# Exportar registros
  sudo mkdir -p "$vCarpetaDeCasos"/Registro/RegRipper/ 2> /dev/null
  echo ""
  echo "  RegRippeando SYSTEM..."
  echo ""
  sudo /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/Registro/Archivos/SYSTEM   -a > "$vCarpetaDeCasos"/Registro/RegRipper/SYSTEM.txt
  echo ""
  echo "  RegRippeando SAM..."
  echo ""
  sudo /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/Registro/Archivos/SAM      -a > "$vCarpetaDeCasos"/Registro/RegRipper/SAM.txt
  echo ""
  echo "  RegRippeando SECURITY..."
  echo ""
  sudo /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/Registro/Archivos/SECURITY -a > "$vCarpetaDeCasos"/Registro/RegRipper/SECURITY.txt
  echo ""
  echo "  RegRippeando SOFTWARE..."
  echo ""
  sudo /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/Registro/Archivos/SOFTWARE -a > "$vCarpetaDeCasos"/Registro/RegRipper/SOFTWARE.txt
  echo ""
  echo "  RegRippeando DEFAULT..."
  echo ""
  sudo /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/Registro/Archivos/DEFAULT  -a > "$vCarpetaDeCasos"/Registro/RegRipper/DEFAULT.txt

# Exportar registro de usuarios
  echo ""
  echo "  RegRippeando archivos de registro de usuarios..."
  echo ""
  find "$vPuntoDeMontaje/Users/" -mindepth 1 -maxdepth 1 -type d > /tmp/CarpetasDeUsuarios.txt
  while IFS= read -r linea; do
    vNomUsuario="${linea##*/}"
    echo ""
    echo "    RegRippeando NTUSER.DAT de $vNomUsuario..."
    echo ""
    sudo mkdir -p "$vCarpetaDeCasos"/Registro/RegRipper/Usuarios/"$vNomUsuario" 2> /dev/null
    sudo /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/Registro/Archivos/Usuarios/"$vNomUsuario"/NTUSER.DAT  -a > "$vCarpetaDeCasos"/Registro/RegRipper/Usuarios/"$vNomUsuario"/NTUSER.DAT.txt
  done < "/tmp/CarpetasDeUsuarios.txt"

# Reparar permisos
  sudo chown 1000:1000 $vCarpetaDeCasos -R

