#!/bin/bash

# Definir fecha del caso
  vFechaCaso=$(date +a%Ym%md%d@%T)

# Definir variables
  vCarpetaDeCasos="/Casos"
  vPuntoDeMontaje="/Casos/"$vFechaCaso"/Particiones/2"

# Determinar el caso actual y crear la carpeta
  rm -rf "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/* 2>/dev/null
  mkdir -p  "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/Original/

# Copiar archivos de registro
  echo ""
  echo "  Copiando SYSTEM..."
  echo ""
  cp "$vPuntoDeMontaje"/WINDOWS/system32/config/system   "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/Original/SYSTEM
  echo ""
  echo "  Copiando SAM..."
  echo ""
  cp "$vPuntoDeMontaje"/WINDOWS/system32/config/SAM      "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/Original/SAM
  echo ""
  echo "  Copiando SECURITY..."
  echo ""
  cp "$vPuntoDeMontaje"/WINDOWS/system32/config/SECURITY "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/Original/SECURITY
  echo ""
  echo "  Copiando SOFTWARE..."
  echo ""
  cp "$vPuntoDeMontaje"/WINDOWS/system32/config/software "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/Original/SOFTWARE
  echo ""
  echo "  Copiando DEFAULT..."
  echo ""
  cp "$vPuntoDeMontaje"/WINDOWS/system32/config/default  "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/Original/DEFAULT

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
    mkdir -p "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/Original/"$vNomUsuario"
    cp "$vPuntoDeMontaje"/"Documents and Settings"/"$vNomUsuario"/NTUSER.DAT "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/Original/"$vNomUsuario"/
  done < "/tmp/CarpetasDeUsuarios.txt"


# Exportar registros
  sudo mkdir -p "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/RegRipper/ 2> /dev/null
  echo ""
  echo "  RegRippeando SYSTEM..."
  echo ""
  /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/Original/SYSTEM   -a > "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/RegRipper/SYSTEM.txt
  echo ""
  echo "  RegRippeando SAM..."
  echo ""
  /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/Original/SAM      -a > "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/RegRipper/SAM.txt
  echo ""
  echo "  RegRippeando SECURITY..."
  echo ""
  /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/Original/SECURITY -a > "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/RegRipper/SECURITY.txt
  echo ""
  echo "  RegRippeando SOFTWARE..."
  echo ""
  /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/Original/SOFTWARE -a > "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/RegRipper/SOFTWARE.txt
  echo ""
  echo "  RegRippeando DEFAULT..."
  echo ""
  /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/Original/DEFAULT  -a > "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/RegRipper/DEFAULT.txt

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
    mkdir -p "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/RegRipper/"$vNomUsuario"/ 2> /dev/null
    /usr/local/bin/rip.pl -r "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/Original/"$vNomUsuario"/NTUSER.DAT  -a > "$vCarpetaDeCasos"/"$vFechaCaso"/Artefactos/Registro/RegRipper/"$vNomUsuario"/NTUSER.DAT.txt
  done < "/tmp/CarpetasDeUsuarios.txt"

# Reparar permisos
  sudo chown 1000:1000 $vCarpetaDeCasos -R

