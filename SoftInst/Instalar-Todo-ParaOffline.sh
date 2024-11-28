#!/bin/bash



# Comprobar si hay conexión a Internet antes de sincronizar los df-scripts
  # Comprobar si el paquete wget está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s wget 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${cColorRojo}  El paquete wget no está instalado. Iniciando su instalación...${cFinColor}"
      echo ""
      sudo apt-get -y update && sudo apt-get -y install wget
      echo ""
    fi
  wget -q --tries=10 --timeout=20 --spider https://github.com
  if [[ $? -eq 0 ]]; then
    # Sincronizar los df-scripts
      echo ""
      echo -e "${cColorAzulClaro}  Sincronizando los df-scripts con las últimas versiones y descargando nuevos df-scripts (si es que existen)...${cFinColor}"
      echo ""
      rm ~/scripts/df-scripts -R 2> /dev/null
      mkdir ~/scripts 2> /dev/null
      cd ~/scripts/
      # Comprobar si el paquete git está instalado. Si no lo está, instalarlo.
        if [[ $(dpkg-query -s git 2>/dev/null | grep installed) == "" ]]; then
          echo ""
          echo -e "${cColorRojo}    El paquete git no está instalado. Iniciando su instalación...${cFinColor}"
          echo ""
          apt-get -y update && apt-get -y install git
          echo ""
        fi
      git clone --depth=1 https://github.com/nipegun/df-scripts
      rm ~/scripts/df-scripts/.git -R 2> /dev/null
      find ~/scripts/df-scripts/ -type f -iname "*.sh" -exec chmod +x {} \;
      echo ""
      echo -e "${cColorVerde}    df-scripts sincronizados correctamente.${cFinColor}"
      echo ""
    # Crear los alias
      mkdir -p ~/scripts/df-scripts/Alias/
      ~/scripts/df-scripts/DFScripts-Alias-Crear.sh
      find ~/scripts/df-scripts/Alias -type f -exec chmod +x {} \;
  else
    echo ""
    echo -e "${cColorRojo}  No se pudo iniciar la sincronización de los df-scripts porque no se detectó conexión a Internet.${cFinColor}"
    echo ""
  fi

