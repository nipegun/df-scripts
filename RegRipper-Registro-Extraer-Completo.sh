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



vPuntoDeMontaje="/Particiones/Pruebas"
vCarpetaDelCaso="/Casos/MrEvil"
sudo mkdir -p $vCarpetaDelCaso
sudo chown 1000:1000 $vCarpetaDelCaso -R
sudo /usr/local/bin/rip.pl -r $vPuntoDeMontaje/WINDOWS/system32/config/system   -a > $vCarpetaDelCaso/SYSTEM.txt
sudo /usr/local/bin/rip.pl -r $vPuntoDeMontaje/WINDOWS/system32/config/SAM      -a > $vCarpetaDelCaso/SAM.txt
sudo /usr/local/bin/rip.pl -r $vPuntoDeMontaje/WINDOWS/system32/config/SECURITY -a > $vCarpetaDelCaso/SECURITY.txt
sudo /usr/local/bin/rip.pl -r $vPuntoDeMontaje/WINDOWS/system32/config/software -a > $vCarpetaDelCaso/SOFTWARE.txt
sudo /usr/local/bin/rip.pl -r $vPuntoDeMontaje/WINDOWS/system32/config/default  -a > $vCarpetaDelCaso/DEFAULT.txt


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

