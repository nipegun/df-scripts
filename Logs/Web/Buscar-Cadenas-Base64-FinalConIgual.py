#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Busca cadenas en Base64 dentro de todos los archivos de una carpeta (recursivo).
Solo muestra coincidencias que TERMINEN en '=' (incluye '==').
Valida alfabeto/padding con base64.b64decode(validate=True).

Uso:
  ./find_b64.py /ruta/a/carpeta
  ./find_b64.py /ruta/a/carpeta -d
  ./find_b64.py /ruta/a/carpeta -d -u -m 20
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

def is_mostly_printable(vBytes: bytes, vThreshold: float = 0.85) -> bool:
  if not vBytes:
    return False
  vPrintable = sum((32 <= vCh <= 126) or vCh in (9, 10, 13) for vCh in vBytes)
  return (vPrintable / len(vBytes)) >= vThreshold

def safe_preview(vBytes: bytes, vMaxLen: int = 120) -> str:
  vCut = vBytes[:vMaxLen]
  if is_mostly_printable(vCut):
    try:
      return vCut.decode("utf-8", errors="replace").replace("\n", "\\n").replace("\r", "\\r")
    except Exception:
      pass
  return vCut.hex()

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
  # Coincide con bloques largos de B64; el filtro de "terminar en '='" se hace después.
  vCharClass = rb"[A-Za-z0-9+/_-]" if vIncludeURLSafe else rb"[A-Za-z0-9+/]"
  vPattern = rb"%s{%d,}={0,2}" % (vCharClass, vMinEncodedLen)
  return re.compile(vPattern)

def scan_file(vPath: str,
              vRx: re.Pattern[bytes],
              vIncludeURLSafe: bool,
              vMinDecodedLen: int) -> list[dict]:
  vResults = []
  try:
    with open(vPath, "rb") as vF:
      try:
        with mmap.mmap(vF.fileno(), length=0, access=mmap.ACCESS_READ) as vMM:
          for vMatch in vRx.finditer(vMM):
            vCandidate = vMatch.group(0)
            # Solo coincidencias que terminen en '=' (incluye '==')
            if not vCandidate.endswith(b"="):
              continue
            # Múltiplo de 4
            if len(vCandidate) % 4 != 0:
              continue
            vDecoded = decode_b64(vCandidate, vIncludeURLSafe)
            if vDecoded is None or len(vDecoded) < vMinDecodedLen:
              continue
            vResults.append({
              "file": vPath,
              "offset": int(vMatch.start()),
              "encoded": vCandidate.decode("ascii", errors="ignore"),
              "decoded_len": len(vDecoded),
              "decoded_preview": safe_preview(vDecoded)
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
          vResults.append({
            "file": vPath,
            "offset": int(vMatch.start()),
            "encoded": vCandidate.decode("ascii", errors="ignore"),
            "decoded_len": len(vDecoded),
            "decoded_preview": safe_preview(vDecoded)
          })
  except (PermissionError, FileNotFoundError, IsADirectoryError) as vE:
    print(f"[WARN] No se puede leer '{vPath}': {vE}", file=sys.stderr)
  except Exception as vE:
    print(f"[WARN] Error procesando '{vPath}': {vE}", file=sys.stderr)
  return vResults

def walk_and_scan(vRoot: str,
                  vRx: re.Pattern[bytes],
                  vIncludeURLSafe: bool,
                  vMinDecodedLen: int,
                  vExcludeDirs: set[str],
                  vFollowSymlinks: bool) -> list[dict]:
  vAllResults = []
  for vDirPath, vDirNames, vFileNames in os.walk(vRoot, followlinks=vFollowSymlinks):
    vDirNames[:] = [d for d in vDirNames if d not in vExcludeDirs]
    for vName in vFileNames:
      vFPath = os.path.join(vDirPath, vName)
      if not vFollowSymlinks and os.path.islink(vFPath):
        continue
      vAllResults.extend(scan_file(vFPath, vRx, vIncludeURLSafe, vMinDecodedLen))
  return vAllResults

def main():
  vParser = argparse.ArgumentParser(
    description="Busca cadenas Base64 en todos los archivos de una carpeta (recursivo). Solo termina en '='."
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
                       help="Salida en JSON (una línea por hallazgo).")
  vParser.add_argument("-d", "--decode", action="store_true",
                       help="Mostrar previsualización decodificada (texto o hex).")
  vArgs = vParser.parse_args()

  vRoot = vArgs.carpeta
  if not os.path.isdir(vRoot):
    print(f"ERROR: '{vRoot}' no es una carpeta válida.", file=sys.stderr)
    sys.exit(2)

  # Asegurar tamaño mínimo codificado coherente con min_decoded_len (múltiplos de 4)
  vEncFromDec = int(ceil(vArgs.min_decoded_len / 3.0) * 4)
  vMinEncodedLen = max(vArgs.min_encoded_len, vEncFromDec)

  vRx = compile_regex(vMinEncodedLen=vMinEncodedLen, vIncludeURLSafe=vArgs.include_urlsafe)
  vExcludeDirs = {d for d in (vArgs.exclude_dirs.split(",") if vArgs.exclude_dirs else []) if d}

  vResults = walk_and_scan(
    vRoot=vRoot,
    vRx=vRx,
    vIncludeURLSafe=vArgs.include_urlsafe,
    vMinDecodedLen=vArgs.min_decoded_len,
    vExcludeDirs=vExcludeDirs,
    vFollowSymlinks=vArgs.follow_symlinks
  )

  if vArgs.json:
    for vR in vResults:
      vOut = dict(vR)
      if not vArgs.decode:
        vOut.pop("decoded_preview", None)
      print(json.dumps(vOut, ensure_ascii=False))
  else:
    if not vResults:
      print("No se encontraron cadenas Base64 que cumplan los criterios.")
      return
    for vR in vResults:
      vLine = f"{vR['file']}@{vR['offset']}: len_dec={vR['decoded_len']} enc=\"{vR['encoded']}\""
      if vArgs.decode:
        vLine += f" -> dec_preview=\"{vR['decoded_preview']}\""
      print(vLine)

if __name__ == "__main__":
  main()
