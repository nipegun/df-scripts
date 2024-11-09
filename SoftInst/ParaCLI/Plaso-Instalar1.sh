
# Actualizar lista de paquetes disponibles en los repositorios
  apt update

# Instalar dependencias
  apt -y install python3-pip
  apt -y install python3-setuptools
  apt -y install python3-dev
  apt -y install build-essential
  apt -y install liblzma-dev

# Instalar plaso
  rm -rf /root/SoftInst/Plaso/*
  mkdir -p /root/SoftInst/Plaso/
  cd /root/SoftInst/Plaso/
    # Comprobar si el paquete python3-venv está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s python3-venv 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${cColorRojo}  El paquete python3-venv no está instalado. Iniciando su instalación...${cFinColor}"
      echo ""
      apt-get -y update && apt-get -y install python3-venv
      echo ""
    fi
  python3 -m venv plaso
  source plaso/bin/activate
  # Comprobar si el paquete python3-pip está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s python3-pip 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${cColorRojo}  El paquete python3-pip no está instalado. Iniciando su instalación...${cFinColor}"
      echo ""
      apt-get -y update && apt-get -y install python3-pip
      echo ""
    fi
  pip3 install plaso
  # Verificando que log2timeline se haya descargado
    ./plaso/bin/log2timeline --version
  # Compilar el script
    pip install pyinstaller
    pyinstaller --onefile /root/SoftInst/Plaso/plaso/bin/log2timeline
    pyinstaller --onefile \
      --add-data "/root/SoftInst/Plaso/plaso/lib/python3.11/site-packages/plaso/parsers/macos_core_location.yaml:plaso/parsers" \
      --add-data "/root/SoftInst/Plaso/plaso/lib/python3.11/site-packages/plaso/parsers/macos_mdns.yaml:plaso/parsers" \
      --add-data "/root/SoftInst/Plaso/plaso/lib/python3.11/site-packages/plaso/parsers/macos_open_directory.yaml:plaso/parsers" \
      /root/SoftInst/Plaso/plaso/bin/log2timeline
   # Desactivar el entorno virtual
     deactivate
  # Copiar el binario a /usr/bin
    cp -r /root/SoftInst/Plaso/dist/log2timeline /usr/bin/


