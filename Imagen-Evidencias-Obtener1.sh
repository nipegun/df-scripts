
# Ejecución remota:
#   curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Evidencias-Obtener-DeImagen | sudo bash -s /Ruta/Al/Archivo/De/Imagen/De/Evidencia

# Montar particiones de imagen
  curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Imagen-Particiones-Montar-SoloLectura.sh | sed 's|$(date +a%Ym%md%d@%T)|"Examen"|g' | sudo bash -s $1

# Instalar RegRipper (Sólo se ejecuta en Debian)
  curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/RegRipper-Instalar.sh | sudo bash

# Ejecutar RegRipper
  curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Registro-Extraer-Completo-WindowsVistaYPosterior.sh | sudo bash -s /Casos/Examen/Particiones/2 /Casos/Examen

# MFT

  # Extraer MFT
    curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/MFT-Extraer-Completa.sh | sudo bash -s /Casos/Examen/Particiones/2 /Casos/Examen

  # Instalar analyzeMFT
    curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/ParaCLI/analyzeMFT-Instalar.sh | sudo bash

  # Ejecutar analyzemft sobre la evidencia
    analyzemft -f /Casos/Examen/MFT/\$MFT -o /Casos/Examen/MFT/MFT.csv              --csv      # Exportar como CSV (default)
    analyzemft -f /Casos/Examen/MFT/\$MFT -o /Casos/Examen/MFT/MFT.json             --json     # Exportar como JSON
    analyzemft -f /Casos/Examen/MFT/\$MFT -o /Casos/Examen/MFT/MFT.xml              --xml      # Exportar como XML
    analyzemft -f /Casos/Examen/MFT/\$MFT -o /Casos/Examen/MFT/MFT.xls              --excel    # Exportar como Excel
    analyzemft -f /Casos/Examen/MFT/\$MFT -o /Casos/Examen/MFT/MFT-BodyMactime      --body     # Exportar como body file (for mactime)
    analyzemft -f /Casos/Examen/MFT/\$MFT -o /Casos/Examen/MFT/MFT-TSKTimeLine      --timeline # Exportar como TSK timeline
    analyzemft -f /Casos/Examen/MFT/\$MFT -o /Casos/Examen/MFT/MFT-log2timeline.l2t --l2t      # Exportar como log2timeline CSV
    analyzemft -f /Casos/Examen/MFT/\$MFT -o /Casos/Examen/MFT/MFT-SQLite           --sqlite   # Exportar como SQLite database
    analyzemft -f /Casos/Examen/MFT/\$MFT -o /Casos/Examen/MFT/MFT-TSKbody          --tsk      # Exportar como TSK bodyfile format
