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

#
  /usr/local/bin/rip.pl -r /Windows/System32/config/SYSTEM
# 
  /usr/local/bin/rip.pl -r /Windows/System32/config/SAM
# 
  /usr/local/bin/rip.pl -r /Windows/System32/config/SECURITY
# 
  /usr/local/bin/rip.pl -r /Windows/System32/config/SOFTWARE
# 
  /usr/local/bin/rip.pl -r /Windows/System32/config/DEFAULT
# Archivo con información específica de usuario
  C:\Users\[NombreUsuario]\NTUSER.DAT
# Archivo con configuración del entorno de usuario
  C:\Users\[NombreUsuario]\AppData\Local\Microsoft\Windows\USRCLASS.DAT

  # Offline
    /Windows/System32/config/
    Users/[NombreUsuario]/
