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


# Software del repo
  curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/AnalyzeMFT-Instalar.sh | bash
  curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/Plaso-Instalar.sh      | bash
  curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/RegRipper-Instalar.sh  | sudo bash
  curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/Volatility-Instalar.sh | bash

# Modificar script internamente
  
