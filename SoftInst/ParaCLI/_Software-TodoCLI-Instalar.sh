# 
  apt-get -y update

# Análisis de archivos y discos (Contiene la herramienta mmls y otras)
  apt-get -y install sleuthkit

# Herramientas para el registro de Windows
  apt-get -y install chntpw

# Metadatos de archivos
  apt-get -y install libimage-exiftool-perl

  # Esteganografía
    apt-get -y install steghide

# Otras herramientas de terminal
  apt-get -y install tshark

# Software del repo
  curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/AnalyzeMFT-Instalar.sh | bash
  curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/Plaso-Instalar.sh      | bash
  curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/RegRipper-Instalar.sh  | sudo bash
  curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/Volatility-Instalar.sh | bash

# Modificar script internamente
  
# Herramientas de terminal
  # dd
    apt-get -y install coreutils
  # AFF (Advanced Forensic Format)
    apt-get -y install afflib-tools
  # EWF (Expert Witness Format)
    apt-get -y install libewf-tools
  # dc3dd
    apt-get -y install dc3dd
# Herramientas gráficas
  # guymager
    apt-get -y install guymager
  # 

# Desactivar el automontaje de unidades de Gnome
  gsettings set org.gnome.desktop.media-handling automount false

# O se puede optar por instalar el paquete:
  apt-get -y install forensics-all # Debian Forensics Environment - essential components (metapackage)
