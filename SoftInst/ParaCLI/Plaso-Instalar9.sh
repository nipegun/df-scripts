
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
    ~/SoftInst/Plaso/plaso/bin/log2timeline --version
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


