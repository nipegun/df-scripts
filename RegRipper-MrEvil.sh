#!/bin/bash

# Definir variables
  vPuntoDeMontaje="/Particiones/Pruebas"
  vCarpetaDeCasos="/Casos"

# Determinar el caso actual y crear la carpeta
  vCasoActual="/22"
  rm -rf $vCarpetaDeCasos$vCasoActual 2>/dev/null
  sudo mkdir -p $vCarpetaDeCasos$vCasoActual/Registro/

# Reparar permisos
  sudo chown 1000:1000 $vCarpetaDeCasos -R

# Copiar archivos de registro
  echo ""
  echo "  Copiando SYSTEM..."
  echo ""
  sudo cp "$vPuntoDeMontaje"/WINDOWS/system32/config/system "$vCarpetaDeCasos""$vCasoActual"/Registro/SYSTEM
  echo ""
  echo "  Copiando SAM..."
  echo ""
  sudo cp "$vPuntoDeMontaje"/WINDOWS/system32/config/SAM      "$vCarpetaDeCasos""$vCasoActual"/Registro/SAM
  echo ""
  echo "  Copiando SECURITY..."
  echo ""
  sudo cp "$vPuntoDeMontaje"/WINDOWS/system32/config/SECURITY "$vCarpetaDeCasos""$vCasoActual"/Registro/SECURITY
  echo ""
  echo "  Copiando SOFTWARE..."
  echo ""
  sudo cp "$vPuntoDeMontaje"/WINDOWS/system32/config/software "$vCarpetaDeCasos""$vCasoActual"/Registro/SOFTWARE
  echo ""
  echo "  Copiando DEFAULT..."
  echo ""
  sudo cp "$vPuntoDeMontaje"/WINDOWS/system32/config/default  "$vCarpetaDeCasos""$vCasoActual"/Registro/DEFAULT

# Exportando registro de usuarios
  echo ""
  echo "  Copiando archivos de registro de usuarios..."
  echo ""
  find "$vPuntoDeMontaje/Documents and Settings/" -mindepth 1 -maxdepth 1 -type d > /tmp/CarpetasDeUsuarios.txt
  while IFS= read -r linea; do
    vNomUsuario="${linea##*/}"
    echo ""
    echo "    Copiando NTUSER.DAT de $vNomUsuario..."
    echo ""
    sudo mkdir -p "$vCarpetaDeCasos$vCasoActual"/Usuarios/"$vNomUsuario"
    cp "$vPuntoDeMontaje"/"Documents and Settings"/"$vNomUsuario"/NTUSER.DAT "$vCarpetaDeCasos$vCasoActual"/Usuarios/"$vNomUsuario"/
  done < "/tmp/CarpetasDeUsuarios.txt"


# Exportar registros
  echo ""
  echo "  Exportando SYSTEM..."
  echo ""

  sudo /usr/local/bin/rip.pl -r $vCarpetaDeCasos$vCasoActual/Registro/SYSTEM   -a > $vCarpetaDeCasos$vCasoActual/SYSTEM.txt
  echo ""
  echo "  Exportando SAM..."
  echo ""
  sudo /usr/local/bin/rip.pl -r $vCarpetaDeCasos$vCasoActual/Registro/SAM      -a > $vCarpetaDeCasos$vCasoActual/SAM.txt
  echo ""
  echo "  Exportando SECURITY..."
  echo ""
  sudo /usr/local/bin/rip.pl -r $vCarpetaDeCasos$vCasoActual/Registro/SECURITY -a > $vCarpetaDeCasos$vCasoActual/SECURITY.txt
  echo ""
  echo "  Exportando SOFTWARE..."
  echo ""
  sudo /usr/local/bin/rip.pl -r $vCarpetaDeCasos$vCasoActual/Registro/SOFTWARE -a > $vCarpetaDeCasos$vCasoActual/SOFTWARE.txt
  echo ""
  echo "  Exportando DEFAULT..."
  echo ""
  sudo /usr/local/bin/rip.pl -r $vCarpetaDeCasos$vCasoActual/Registro/DEFAULT  -a > $vCarpetaDeCasos$vCasoActual/DEFAULT.txt

