
# Actualizar lista de paquetes disponibles en los repositorios
  echo ""
  echo "    Actualizando la lista de paquetes disponibles en los repositorios..."
  echo ""
  sudo apt -y update && apt -y install python3-pip python3-setuptools python3-dev python3-venv build-essential liblzma-dev

# Instalar plaso
  echo ""
  echo "    Creando la carpeta para guardar el código fuente..."
  echo ""
  mkdir -p ~/SoftInst/Plaso/
  rm -rf ~/SoftInst/Plaso/*
  cd ~/SoftInst/Plaso/
  echo ""
  echo "    Creando el ambiente virtual..."
  echo ""
  python3 -m venv plaso
  echo ""
  echo "    Entrando al ambiente virtual"
  echo ""
  source plaso/bin/activate
  echo ""
  echo "    Instalando plaso..."
  echo ""
  pip3 install plaso
  # Verificando que log2timeline se haya descargado
    echo ""
    echo "    Verificando la ejecución del script log2timeline.py..."
    echo ""
    ~/SoftInst/Plaso/plaso/bin/log2timeline --version && echo "      log2timeline es ejecutable desde ~/SoftInst/Plaso/plaso/bin/log2timeline "
  # Compilar
    echo ""
    echo "    Compilando log2timeline..."
    echo ""
    pip install pyinstaller
    pyinstaller --onefile \
      --add-data ~/"SoftInst/Plaso/plaso/lib/python3.11/site-packages/plaso/parsers/macos_core_location.yaml:plaso/parsers" \
      --add-data ~/"SoftInst/Plaso/plaso/lib/python3.11/site-packages/plaso/parsers/macos_mdns.yaml:plaso/parsers" \
      --add-data ~/"SoftInst/Plaso/plaso/lib/python3.11/site-packages/plaso/parsers/macos_open_directory.yaml:plaso/parsers" \
      --add-data ~/"SoftInst/Plaso/plaso/lib/python3.11/site-packages/plaso/parsers/windows_nt.yaml:plaso/parsers" \
      --add-data ~/"SoftInst/Plaso/plaso/lib/python3.11/site-packages/plaso/preprocessors/time_zone_information.yaml:plaso/preprocessors" \
      --add-data ~/"SoftInst/Plaso/plaso/lib/python3.11/site-packages/plaso/preprocessors/mounted_devices.yaml:plaso/preprocessors" \
      ~/SoftInst/Plaso/plaso/bin/log2timeline
   # Desactivar el entorno virtual
     deactivate
  # Copiar el binario a /usr/bin
    cp -f ~/SoftInst/Plaso/dist/log2timeline /usr/bin/






    # Convertir los eventos a log2timeline
      #~/SoftInst/Plaso/plaso/bin/log2timeline $vCarpetaDelCaso/Eventos/Originales/ --storage-file $vCarpetaDelCaso/Eventos/Parseados/TimeLine.plaso
    # Parsear
      #~/SoftInst/Plaso/plaso/bin/psort "$vCarpetaDelCaso"/Eventos/Parseados/TimeLine.plaso -o dynamic   -w "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineEventos.txt
      #~/SoftInst/Plaso/plaso/bin/psort "$vCarpetaDelCaso"/Eventos/Parseados/TimeLine.plaso -o json      -w "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineEventos.json
      #~/SoftInst/Plaso/plaso/bin/psort "$vCarpetaDelCaso"/Eventos/Parseados/TimeLine.plaso -o json_line -w "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineEventos.json_line 
      #~/SoftInst/Plaso/plaso/bin/psort "$vCarpetaDelCaso"/Eventos/Parseados/TimeLine.plaso -o l2tcsv    -w "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineEventos.l2tcsv
      #~/SoftInst/Plaso/plaso/bin/psort "$vCarpetaDelCaso"/Eventos/Parseados/TimeLine.plaso -o l2ttln    -w "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineEventos.l2ttln
      #~/SoftInst/Plaso/plaso/bin/psort "$vCarpetaDelCaso"/Eventos/Parseados/TimeLine.plaso -o rawpy     -w "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineEventos.rawpy
      #~/SoftInst/Plaso/plaso/bin/psort "$vCarpetaDelCaso"/Eventos/Parseados/TimeLine.plaso -o tln       -w "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineEventos.tln
      #~/SoftInst/Plaso/plaso/bin/psort "$vCarpetaDelCaso"/Eventos/Parseados/TimeLine.plaso -o xlsx      -w "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineEventos.xlsx

     # Pasar todo el TimeLine de eventos, de json a xml
      # cat "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineEventos.json | jq | grep xml_string | sed 's-"xml_string": "--g' | sed 's/\\n/\n/g' | sed '/^"/d' | sed 's-xmlns=\"http://schemas.microsoft.com/win/2004/08/events/event\"--g' > "$vCarpetaDelCaso"/Eventos/Parseados/TimeLineCompleto.xml




     # Exportando actividad del usuario específico desde el archivo .json
     #  echo ""
     #  echo "  Exportando actividad específica del usuario ..."
     #  echo ""
     #  vSIDDelUsuario="S-1-5-21-92896240-835188504-1963242017-1001"
     #  cat '/Casos/Examen/Eventos/Parseados/TimeLineEventos.json' | sed 's-/Casos/Examen/Eventos/Originales/--g'  | jq '.[] | select(.user_sid == "'"$vSIDDelUsuario"'")' > $vCarpetaDelCaso/Eventos/Parseados/TimeLineUsuario.json

#     cat /Casos/Examen/Eventos/Parseados/TimeLineEventos.txt | sed 's-/Casos/Examen/Eventos/Originales/--g' | grep S-1-5-21 > $vCarpetaDelCaso/Eventos/Parseados/TimeLineUsuario.txt


