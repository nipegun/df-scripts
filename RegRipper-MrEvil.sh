#!/bin/bash

# ------
  vPuntoDeMontaje="/Particiones/Pruebas"
  vCarpetaDeCasos="/Casos"
  # Determinar el caso actual
  vCasoActual="/22"
  sudo mkdir -p $vCarpetaDeCasos$vCasoActual
  sudo chown 1000:1000 $vCarpetaDeCasos -R
  sudo /usr/local/bin/rip.pl -r $vPuntoDeMontaje/WINDOWS/system32/config/system   -a > $vCarpetaDeCasos$vCasoActual/SYSTEM.txt
  sudo /usr/local/bin/rip.pl -r $vPuntoDeMontaje/WINDOWS/system32/config/SAM      -a > $vCarpetaDeCasos$vCasoActual/SAM.txt
  sudo /usr/local/bin/rip.pl -r $vPuntoDeMontaje/WINDOWS/system32/config/SECURITY -a > $vCarpetaDeCasos$vCasoActual/SECURITY.txt
  sudo /usr/local/bin/rip.pl -r $vPuntoDeMontaje/WINDOWS/system32/config/software -a > $vCarpetaDeCasos$vCasoActual/SOFTWARE.txt
  sudo /usr/local/bin/rip.pl -r $vPuntoDeMontaje/WINDOWS/system32/config/default  -a > $vCarpetaDeCasos$vCasoActual/DEFAULT.txt

vPuntoDeMontaje="/Particiones/Pruebas"
for vCarpeta in "$vPuntoDeMontaje/Documents and Settings/*"; do
  #if [ -d "$vCarpeta" ]; then
    # Comandos a ejecutar por cada carpeta
    echo "Procesando carpeta: $vCarpeta"
    # Tus comandos aquí, por ejemplo:
    # cd "$dir" && ejecutar_comando
  #fi
done
