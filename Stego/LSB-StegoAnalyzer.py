#!/usr/bin/env python3

# curl -sL https://raw.githubusercontent.com/nipegun/dfir-scripts/refs/heads/main/Stego/LSB-StegoAnalyzer.py | python3 - [archivo]

"""
LSB Steganography Analyzer - Herramienta completa para análisis de esteganografía LSB
Autor: Generado para análisis de CTF
Uso: python3 lsb_stego_analyzer.py <imagen> [opciones]
"""

import argparse
import sys
import os
from pathlib import Path
from PIL import Image


class LSBAnalyzer:
  """Clase principal para análisis de esteganografía LSB."""

  cCHANNEL_MAP = {
    'R': 0, 'G': 1, 'B': 2, 'A': 3,
    'r': 0, 'g': 1, 'b': 2, 'a': 3,
    '0': 0, '1': 1, '2': 2, '3': 3
  }

  def __init__(self, vImagePath: str):
    self.vImagePath = vImagePath
    self.vImage = Image.open(vImagePath)
    self.vWidth, self.vHeight = self.vImage.size
    self.vMode = self.vImage.mode
    self.vPixels = list(self.vImage.getdata())
    self.vAvailableChannels = self.fGetAvailableChannels()

  def fGetAvailableChannels(self) -> dict:
    vModeChannels = {
      'RGB': {'R': 0, 'G': 1, 'B': 2},
      'RGBA': {'R': 0, 'G': 1, 'B': 2, 'A': 3},
      'L': {'L': 0},
      'LA': {'L': 0, 'A': 1},
      'P': {'P': 0},
      'CMYK': {'C': 0, 'M': 1, 'Y': 2, 'K': 3},
      '1': {'1': 0},
      'I': {'I': 0},
      'F': {'F': 0}
    }
    return vModeChannels.get(self.vMode, {'0': 0})

  def fInfo(self) -> dict:
    return {
      'path': self.vImagePath,
      'size': f"{self.vWidth}x{self.vHeight}",
      'mode': self.vMode,
      'total_pixels': len(self.vPixels),
      'available_channels': list(self.vAvailableChannels.keys()),
      'bits_per_channel': self.vWidth * self.vHeight,
      'max_hidden_bytes_per_channel': (self.vWidth * self.vHeight) // 8
    }

  def fExtractBitPlane(self, vChannel: str = 'R', vBit: int = 0, vEnhance: bool = True) -> Image.Image:
    if vChannel.upper() not in self.vAvailableChannels and vChannel not in self.vAvailableChannels:
      raise ValueError(f"Canal '{vChannel}' no disponible")

    vChannelIdx = self.vAvailableChannels.get(
      vChannel.upper(),
      self.vAvailableChannels.get(vChannel, 0)
    )

    vNewPixels = []

    for vPixel in self.vPixels:
      if isinstance(vPixel, int):
        vVal = vPixel
      else:
        vVal = vPixel[vChannelIdx] if vChannelIdx < len(vPixel) else 0

      vExtractedBit = (vVal >> vBit) & 1
      vNewVal = vExtractedBit * 255 if vEnhance else vExtractedBit
      vNewPixels.append(vNewVal)

    vResult = Image.new('L', (self.vWidth, self.vHeight))
    vResult.putdata(vNewPixels)
    return vResult

  def fExtractCombinedLSB(self, vChannels: str = 'RGB', vBit: int = 0, vEnhance: bool = True) -> Image.Image:
    vChannelImages = []
    vTargetChannels = list(vChannels.upper())

    for vCh in vTargetChannels[:3]:
      if vCh in self.vAvailableChannels:
        vBP = self.fExtractBitPlane(vCh, vBit, vEnhance)
        vChannelImages.append(vBP)
      else:
        vChannelImages.append(Image.new('L', (self.vWidth, self.vHeight), 0))

    while len(vChannelImages) < 3:
      vChannelImages.append(Image.new('L', (self.vWidth, self.vHeight), 0))

    return Image.merge('RGB', vChannelImages[:3])

  def fExtractAllBitPlanes(self, vChannel: str = 'R') -> list:
    return [self.fExtractBitPlane(vChannel, vBit) for vBit in range(8)]

  def fExtractLSBData(self, vChannels: str = 'RGB', vBit: int = 0,
                      vOrder: str = 'xy', vNumBytes: int = None) -> bytes:
    vBits = []
    vTargetChannels = list(vChannels.upper())

    if vOrder == 'yx':
      for vX in range(self.vWidth):
        for vY in range(self.vHeight):
          vPixel = self.vPixels[vY * self.vWidth + vX]
          for vCh in vTargetChannels:
            if vCh in self.vAvailableChannels:
              vIdx = self.vAvailableChannels[vCh]
              vVal = vPixel[vIdx] if isinstance(vPixel, tuple) else vPixel
              vBits.append((vVal >> vBit) & 1)
    else:
      for vPixel in self.vPixels:
        for vCh in vTargetChannels:
          if vCh in self.vAvailableChannels:
            vIdx = self.vAvailableChannels[vCh]
            vVal = vPixel[vIdx] if isinstance(vPixel, tuple) else vPixel
            vBits.append((vVal >> vBit) & 1)

    vResult = []
    vMaxBytes = vNumBytes if vNumBytes else len(vBits) // 8

    for vI in range(min(vMaxBytes, len(vBits) // 8)):
      vByteBits = vBits[vI * 8:(vI + 1) * 8]
      vByteVal = int(''.join(str(vB) for vB in vByteBits), 2)
      vResult.append(vByteVal)

    return bytes(vResult)

  def fFindHiddenText(self, vChannels: str = 'RGB', vBit: int = 0,
                      vOrders: list = None, vEncoding: str = 'utf-8') -> dict:
    if vOrders is None:
      vOrders = ['xy', 'yx']

    vResults = {}

    for vOrder in vOrders:
      try:
        vData = self.fExtractLSBData(vChannels, vBit, vOrder, 500)
        vText = vData.decode(vEncoding, errors='ignore')
        vPrintable = ''.join(vC for vC in vText if vC.isprintable() or vC in '\n\t')
        if len(vPrintable) > 5:
          vKey = f"{vChannels}_bit{vBit}_{vOrder}"
          vResults[vKey] = vPrintable[:200]
      except:
        pass

    return vResults


def fPrintBanner():
  print("""
╔═══════════════════════════════════════════════════════════════╗
║           LSB STEGANOGRAPHY ANALYZER v1.0                     ║
║           Herramienta de análisis de esteganografía           ║
╚═══════════════════════════════════════════════════════════════╝
""")


def fMain():
  vParser = argparse.ArgumentParser(
    description='Analizador de esteganografía LSB para imágenes'
  )

  vParser.add_argument('image')
  vParser.add_argument('-o', '--output')
  vParser.add_argument('-c', '--channels', default='R')
  vParser.add_argument('-b', '--bit', type=int, default=0)
  vParser.add_argument('--extract', action='store_true')
  vParser.add_argument('--info', action='store_true')

  vArgs = vParser.parse_args()

  if not os.path.exists(vArgs.image):
    print("Archivo no encontrado", file=sys.stderr)
    sys.exit(1)

  fPrintBanner()
  vAnalyzer = LSBAnalyzer(vArgs.image)

  if vArgs.info:
    for vK, vV in vAnalyzer.fInfo().items():
      print(f"{vK}: {vV}")
    sys.exit(0)

  if vArgs.extract:
    vData = vAnalyzer.fExtractLSBData(vArgs.channels, vArgs.bit)
    if vArgs.output:
      with open(vArgs.output, 'wb') as vF:
        vF.write(vData)
    else:
      print(vData.hex())
    sys.exit(0)

  if not vArgs.output:
    vBase = Path(vArgs.image).stem
    vArgs.output = f"{vBase}_lsb.png"

  if len(vArgs.channels) > 1:
    vImg = vAnalyzer.fExtractCombinedLSB(vArgs.channels, vArgs.bit)
  else:
    vImg = vAnalyzer.fExtractBitPlane(vArgs.channels, vArgs.bit)

  vImg.save(vArgs.output)


if __name__ == '__main__':
  fMain()
