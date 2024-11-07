
# Montar particiones de imagen
  curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Imagen-Particiones-Montar-SoloLectura.sh | sed 's|$(date +a%Ym%md%d@%T)|Examen|g' | sudo bash -s [RutaAlArchivoDeImagen]

# Instalar RegRipper
  curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/SoftInst/RegRipper-Instalar.sh | sudo bash

# Desplegar menu pidiendo carpetas
hacer un ls y guardar en una variable

# Ejecutar RegRipper
  curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Registro-Extraer-Completo-WindowsVistaYPosterior.sh | sudo bash -s /Casos/Examen/Particiones/2 /Casos/Examen

# Extraer MFT
  curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/MFT-Extraer-Completa.sh | sudo bash -s /Casos/Examen/Particiones/2 /Casos/Examen

