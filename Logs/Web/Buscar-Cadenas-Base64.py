#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Busca cadenas en Base64 dentro de todos los archivos de una carpeta (recursivo).
Valida el alfabeto y el padding. Opcionalmente muestra una previsualización decodificada.

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

EXCLUDE_DIRS_DEFAULT = {".git", ".svn", ".hg", "node_modules", "__pycache__"}

def is_mostly_printable(b: bytes, threshold: float = 0.85) -> bool:
  if not b:
    return False
  printable = sum((32 <= ch <= 126) or ch in (9, 10, 13) for ch in b)
  return (printable / len(b)) >= threshold

def safe_preview(b: bytes, max_len: int = 120) -> str:
  cut = b[:max_len]
  if is_mostly_printable(cut):
    try:
      return cut.decode("utf-8", errors="replace").replace("\n", "\\n").replace("\r", "\\r")
    except Exception:
      pass
  # Fallback a hex si no es texto legible
  return cut.hex()

def decode_b64(s: bytes, include_urlsafe: bool) -> bytes | None:
  try:
    return base64.b64decode(s, validate=True)
  except Exception:
    pass
  if include_urlsafe:
    try:
      return base64.b64decode(s, altchars=b'-_', validate=True)
    except Exception:
      pass
  return None

def compile_regex(min_encoded_len: int, include_urlsafe: bool) -> re.Pattern[bytes]:
  # Acepta bloques largos de [A-Za-z0-9+/] (y opcionalmente - _), con 0–2 '=' al final.
  # La validación real la hace base64.b64decode(validate=True).
  if include_urlsafe:
    charclass = rb"[A-Za-z0-9+/_-]"
  else:
    charclass = rb"[A-Za-z0-9+/]"
  pattern = rb"%s{%d,}={0,2}" % (charclass, min_encoded_len)
  return re.compile(pattern)

def scan_file(path: str, rx: re.Pattern[bytes], include_urlsafe: bool, min_decoded_len: int) -> list[dict]:
  results = []
  try:
    with open(path, "rb") as f:
      try:
        with mmap.mmap(f.fileno(), length=0, access=mmap.ACCESS_READ) as mm:
          for m in rx.finditer(mm):
            candidate = m.group(0)
            # Debe tener longitud múltiplo de 4 para que valga
            if len(candidate) % 4 != 0:
              continue
            decoded = decode_b64(candidate, include_urlsafe)
            if decoded is None:
              continue
            if len(decoded) < min_decoded_len:
              continue
            results.append({
              "file": path,
              "offset": int(m.start()),
              "encoded": candidate.decode("ascii", errors="ignore"),
              "decoded_len": len(decoded),
              "decoded_preview": safe_preview(decoded)
            })
      except ValueError:
        # Si no se puede mmap (p.ej. archivo vacío), retrocede a lectura normal
        f.seek(0)
        data = f.read()
        for m in rx.finditer(data):
          candidate = m.group(0)
          if len(candidate) % 4 != 0:
            continue
          decoded = decode_b64(candidate, include_urlsafe)
          if decoded is None or len(decoded) < min_decoded_len:
            continue
          results.append({
            "file": path,
            "offset": int(m.start()),
            "encoded": candidate.decode("ascii", errors="ignore"),
            "decoded_len": len(decoded),
            "decoded_preview": safe_preview(decoded)
          })
  except (PermissionError, FileNotFoundError, IsADirectoryError) as e:
    print(f"[WARN] No se puede leer '{path}': {e}", file=sys.stderr)
  except Exception as e:
    print(f"[WARN] Error procesando '{path}': {e}", file=sys.stderr)
  return results

def walk_and_scan(root: str,
                  rx: re.Pattern[bytes],
                  include_urlsafe: bool,
                  min_decoded_len: int,
                  exclude_dirs: set[str],
                  follow_symlinks: bool) -> list[dict]:
  all_results = []
  for dirpath, dirnames, filenames in os.walk(root, followlinks=follow_symlinks):
    # Filtrar directorios comunes
    dirnames[:] = [d for d in dirnames if d not in exclude_dirs]
    for name in filenames:
      fpath = os.path.join(dirpath, name)
      if not follow_symlinks and os.path.islink(fpath):
        continue
      all_results.extend(scan_file(fpath, rx, include_urlsafe, min_decoded_len))
  return all_results

def main():
  parser = argparse.ArgumentParser(
    description="Busca cadenas Base64 en todos los archivos de una carpeta (recursivo)."
  )
  parser.add_argument("carpeta", help="Ruta a la carpeta raíz a escanear")
  parser.add_argument("-m", "--min-encoded-len", type=int, default=16,
                      help="Longitud mínima de la cadena Base64 (codificada). Por defecto: 16")
  parser.add_argument("-D", "--min-decoded-len", type=int, default=8,
                      help="Longitud mínima tras decodificar. Por defecto: 8")
  parser.add_argument("-u", "--include-urlsafe", action="store_true",
                      help="Incluir variantes URL-safe ('-' y '_').")
  parser.add_argument("-f", "--follow-symlinks", action="store_true",
                      help="Seguir enlaces simbólicos.")
  parser.add_argument("-x", "--exclude-dirs", default=",".join(sorted(EXCLUDE_DIRS_DEFAULT)),
                      help=f"Directorios a excluir, separados por comas. Por defecto: {','.join(sorted(EXCLUDE_DIRS_DEFAULT))}")
  parser.add_argument("-j", "--json", action="store_true",
                      help="Salida en JSON (una línea por hallazgo).")
  parser.add_argument("-d", "--decode", action="store_true",
                      help="Mostrar previsualización decodificada (texto o hex).")
  args = parser.parse_args()

  root = args.carpeta
  if not os.path.isdir(root):
    print(f"ERROR: '{root}' no es una carpeta válida.", file=sys.stderr)
    sys.exit(2)

  # Asegurar múltiplo de 4 razonable según min_decoded_len
  # Encoded min equivalente a min_decoded_len
  from math import ceil
  enc_from_dec = int(ceil(args.min_decoded_len / 3.0) * 4)
  min_encoded_len = max(args.min_encoded_len, enc_from_dec)

  rx = compile_regex(min_encoded_len=min_encoded_len, include_urlsafe=args.include_urlsafe)
  exclude_dirs = {d for d in (args.exclude_dirs.split(",") if args.exclude_dirs else []) if d}

  results = walk_and_scan(
    root=root,
    rx=rx,
    include_urlsafe=args.include_urlsafe,
    min_decoded_len=args.min_decoded_len,
    exclude_dirs=exclude_dirs,
    follow_symlinks=args.follow_symlinks
  )

  if args.json:
    for r in results:
      out = dict(r)
      if not args.decode:
        out.pop("decoded_preview", None)
      print(json.dumps(out, ensure_ascii=False))
  else:
    if not results:
      print("No se encontraron cadenas Base64 que cumplan los criterios.")
      return
    for r in results:
      line = f"{r['file']}@{r['offset']}: len_dec={r['decoded_len']} enc=\"{r['encoded']}\""
      if args.decode:
        line += f" -> dec_preview=\"{r['decoded_preview']}\""
      print(line)

if __name__ == "__main__":
  main()
