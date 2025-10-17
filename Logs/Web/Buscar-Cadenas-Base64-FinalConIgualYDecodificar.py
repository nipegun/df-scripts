#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Ejecución remota:
#  curl -sL https://raw.githubusercontent.com/nipegun/df-scripts/refs/heads/main/Logs/Web/Buscar-Cadenas-Base64-FinalConIgualYDecidificar.py | python3 - [Carpeta]

"""
Busca cadenas en Base64 dentro de todos los archivos de una carpeta (recursivo).
Solo reporta coincidencias que TERMINEN en '=' (incluye '==') y muestra:
- ENC (Base64) en azul
- DEC (decodificación) en verde

Uso:
  ./find_b64.py /ruta/a/carpeta
  ./find_b64.py /ruta/a/carpeta -u -m 24
  ./find_b64.py /ruta/a/carpeta --color always
"""

import argparse
import base64
import json
import mmap
import os
import re
import sys
from math import ceil

cEXCLUDE_DIRS_DEFAULT = {".git", ".svn", ".hg", "node_modules", "__pycache__"}

# Colores ANSI
cCOLOR_BLUE  = "\033[34m"
cCOLOR_GREEN = "\033[32m"
cCOLOR_RESET = "\033[0m"
cENABLE_COLOR = False  # se decide en runtime

def set_color_mode(vMode: str):
  global cENABLE_COLOR
  if vMode == "always":
    cENABLE_COLOR = True
  elif vMode == "never":
    cENABLE_COLOR = False
  else:  # auto
    cENABLE_COLOR = sys.stdout.isatty()

def colorize(vText: str, vColor: str) -> str:
  if not cENABLE_COLOR:
    return vText
  if vColor == "blue":
    return f"{cCOLOR_BLUE}{vText}{cCOLOR_RESET}"
  if vColor == "green":
    return f"{cCOLOR_GREEN}{vText}{cCOLOR_RESET}"
  return vText

def is_mostly_printable(vBytes: bytes, vThreshold: float = 0.85) -> bool:
  if not vBytes:
    return False
  vPrintable = sum((32 <= vCh <= 126) or vCh in (9, 10, 13) for vCh in vBytes)
  return (vPrintable / len(vBytes)) >= vThreshold

def to_display_text(vBytes: bytes) -> str:
  """
  Muestra la decodificación de forma legible:
  - Si parece texto, UTF-8 (con sustituciones).
  - Si no, HEX para no romper la salida.
  """
  if is_mostly_printable(vBytes):
    return vBytes.decode("utf-8", errors="replace")
  return vBytes.hex()

def decode_b64(vEncoded: bytes, vIncludeURLSafe: bool) -> bytes | None:
  try:
    return base64.b64decode(vEncoded, validate=True)
  except Exception:
    pass
  if vIncludeURLSafe:
    try:
      return base64.b64decode(vEncoded, altchars=b"-_", validate=True)
    except Exception:
      pass
  return None

def compile_regex(vMinEncodedLen: int, vIncludeURLSafe: bool) -> re.Pattern[bytes]:
  # La validación real la hace base64.b64decode(validate=True).
  vCharClass = rb"[A-Za-z0-9+/_-]" if vIncludeURLSafe else rb"[A-Za-z0-9+/]"
  vPattern = rb"%s{%d,}={0,2}" % (vCharClass, vMinEncodedLen)
  return re.compile(vPattern)

def scan_file(vPath: str,
              vRx: re.Pattern[bytes],
              vIncludeURLSafe: bool,
              vMinDecodedLen: int) -> list[dict]:
  aResults: list[dict] = []
  try:
    with open(vPath, "rb") as vF:
      try:
        with mmap.mmap(vF.fileno(), length=0, access=mmap.ACCESS_READ) as vMM:
          for vMatch in vRx.finditer(vMM):
            vCandidate = vMatch.group(0)
            # Solo coincidencias que terminen en '=' (incluye '==')
            if not vCandidate.endswith(b"="):
              continue
            # Debe ser múltiplo de 4
            if len(vCandidate) % 4 != 0:
              continue
            vDecoded = decode_b64(vCandidate, vIncludeURLSafe)
            if vDecoded is None or len(vDecoded) < vMinDecodedLen:
              continue
            aResults.append({
              "file": vPath,
              "offset": int(vMatch.start()),
              "encoded": vCandidate.decode("ascii", errors="ignore"),
              "decoded_bytes": vDecoded
            })
      except ValueError:
        vF.seek(0)
        vData = vF.read()
        for vMatch in vRx.finditer(vData):
          vCandidate = vMatch.group(0)
          if not vCandidate.endswith(b"="):
            continue
          if len(vCandidate) % 4 != 0:
            continue
          vDecoded = decode_b64(vCandidate, vIncludeURLSafe)
          if vDecoded is None or len(vDecoded) < vMinDecodedLen:
            continue
          aResults.append({
            "file": vPath,
            "offset": int(vMatch.start()),
            "encoded": vCandidate.decode("ascii", errors="ignore"),
            "decoded_bytes": vDecoded
          })
  except (PermissionError, FileNotFoundError, IsADirectoryError) as vE:
    print(f"[WARN] No se puede leer '{vPath}': {vE}", file=sys.stderr)
  except Exception as vE:
    print(f"[WARN] Error procesando '{vPath}': {vE}", file=sys.stderr)
  return aResults

def walk_and_scan(vRoot: str,
                  vRx: re.Pattern[bytes],
                  vIncludeURLSafe: bool,
                  vMinDecodedLen: int,
                  aExcludeDirs: set[str],
                  vFollowSymlinks: bool) -> list[dict]:
  aAllResults: list[dict] = []
  for vDirPath, aDirNames, aFileNames in os.walk(vRoot, followlinks=vFollowSymlinks):
    aDirNames[:] = [d for d in aDirNames if d not in aExcludeDirs]
    for vName in aFileNames:
      vFPath = os.path.join(vDirPath, vName)
      if not vFollowSymlinks and os.path.islink(vFPath):
        continue
      aAllResults.extend(scan_file(vFPath, vRx, vIncludeURLSafe, vMinDecodedLen))
  return aAllResults

def main():
  vParser = argparse.ArgumentParser(
    description="Busca cadenas Base64 (terminadas en '=') en todos los archivos (recursivo) y muestra su decodificación."
  )
  vParser.add_argument("carpeta", help="Ruta a la carpeta raíz a escanear")
  vParser.add_argument("-m", "--min-encoded-len", type=int, default=16,
                       help="Longitud mínima de la cadena Base64 (codificada). Por defecto: 16")
  vParser.add_argument("-D", "--min-decoded-len", type=int, default=8,
                       help="Longitud mínima tras decodificar. Por defecto: 8")
  vParser.add_argument("-u", "--include-urlsafe", action="store_true",
                       help="Incluir variantes URL-safe ('-' y '_'). (Igualmente se exige '=' al final)")
  vParser.add_argument("-f", "--follow-symlinks", action="store_true",
                       help="Seguir enlaces simbólicos.")
  vParser.add_argument("-x", "--exclude-dirs", default=",".join(sorted(cEXCLUDE_DIRS_DEFAULT)),
                       help=f"Directorios a excluir, separados por comas. Por defecto: {','.join(sorted(cEXCLUDE_DIRS_DEFAULT))}")
  vParser.add_argument("-j", "--json", action="store_true",
                       help="Salida en JSON (una línea por hallazgo). Sin colores.")
  vParser.add_argument("--color", choices=["auto", "always", "never"], default="auto",
                       help="Colorear salida de texto: auto (por defecto), always, never.")
  vArgs = vParser.parse_args()

  vRoot = vArgs.carpeta
  if not os.path.isdir(vRoot):
    print(f"ERROR: '{vRoot}' no es una carpeta válida.", file=sys.stderr)
    sys.exit(2)

  # Modo color (no afecta a JSON)
  set_color_mode(vArgs.color if not vArgs.json else "never")

  # Asegurar tamaño mínimo codificado coherente con min_decoded_len (múltiplos de 4)
  vEncFromDec = int(ceil(vArgs.min_decoded_len / 3.0) * 4)
  vMinEncodedLen = max(vArgs.min_encoded_len, vEncFromDec)

  vRx = compile_regex(vMinEncodedLen=vMinEncodedLen, vIncludeURLSafe=vArgs.include_urlsafe)
  aExcludeDirs = {d for d in (vArgs.exclude_dirs.split(",") if vArgs.exclude_dirs else []) if d}

  aResults = walk_and_scan(
    vRoot=vRoot,
    vRx=vRx,
    vIncludeURLSafe=vArgs.include_urlsafe,
    vMinDecodedLen=vArgs.min_decoded_len,
    aExcludeDirs=aExcludeDirs,
    vFollowSymlinks=vArgs.follow_symlinks
  )

  if vArgs.json:
    for vR in aResults:
      vOut = {
        "file": vR["file"],
        "offset": vR["offset"],
        "encoded": vR["encoded"],
        "decoded_utf8": to_display_text(vR["decoded_bytes"]),
        "decoded_hex": vR["decoded_bytes"].hex()
      }
      print(json.dumps(vOut, ensure_ascii=False))
  else:
    if not aResults:
      print("No se encontraron cadenas Base64 que cumplan los criterios.")
      return
    for vR in aResults:
      vDecText = to_display_text(vR["decoded_bytes"])
      print(f"{vR['file']}@{vR['offset']}")
      print(f"ENC: {colorize(vR['encoded'], 'blue')}")
      print(f"DEC: {colorize(vDecText, 'green')}")
      print()  # línea en blanco separadora

if __name__ == "__main__":
  main()
