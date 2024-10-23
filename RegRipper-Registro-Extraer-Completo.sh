for regfile in /ruta/a/carpeta/con/archivos_de_registro/*; do
    rip.pl -r "$regfile" -f perfiles_todo > "${regfile}.txt"
done

# Windows 98
  # Datos del registro del sistema
    /Windows/SYSTEM.DAT
  # Datos de los usuarios
    /Windows/USER.DAT
#
 /usr/local/bin/rip.pl -r "/Particiones/Pruebas/Documents and Settings/Mr. Evil/NTUSER.DAT" -f ntuser > /tmp/ntuser.txt

vPuntoDeMontaje="/Particiones/Pruebas"
#
  /usr/local/bin/rip.pl -r $vPuntoDeMontaje/Windows/System32/config/SYSTEM   -a > /Particiones/SYSTEM.txt
# 
  /usr/local/bin/rip.pl -r $vPuntoDeMontaje/Windows/System32/config/SAM      -a > /Particiones/SAM.txt
# 
  /usr/local/bin/rip.pl -r $vPuntoDeMontaje/Windows/System32/config/SECURITY -a > /Particiones/SECURITY.txt
# 
  /usr/local/bin/rip.pl -r $vPuntoDeMontaje/Windows/System32/config/SOFTWARE -a > /Particiones/SOFTWARE.txt
# 
  /usr/local/bin/rip.pl -r $vPuntoDeMontaje/Windows/System32/config/DEFAULT  -a > /Particiones/SOFTWARE.txt

# Archivo con información específica de usuario
  C:\Users\[NombreUsuario]\NTUSER.DAT
# Archivo con configuración del entorno de usuario
  C:\Users\[NombreUsuario]\AppData\Local\Microsoft\Windows\USRCLASS.DAT

  # Offline
    /Windows/System32/config/
    Users/[NombreUsuario]/



#
  /usr/local/bin/rip.pl -r $vPuntoDeMontaje/WINDOWS/system32/config/SYSTEM   -a > /Particiones/SYSTEM.txt
# 
  /usr/local/bin/rip.pl -r $vPuntoDeMontaje/WINDOWS/system32/config/SAM      -a > /Particiones/SAM.txt
# 
  /usr/local/bin/rip.pl -r $vPuntoDeMontaje/WINDOWS/system32/config/SECURITY -a > /Particiones/SECURITY.txt
# 
  /usr/local/bin/rip.pl -r $vPuntoDeMontaje/WINDOWS/system32/config/SOFTWARE -a > /Particiones/SOFTWARE.txt
# 
  /usr/local/bin/rip.pl -r $vPuntoDeMontaje/WINDOWS/system32/config/DEFAULT  -a > /Particiones/DEFAULT.txt







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
