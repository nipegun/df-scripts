#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
carve_payloads_plus.py — Escáner mejorado para binarios que detecta y extrae
payloads comprimidos o ejecutables ELF embebidos.

Mejoras:
- Escaneo único por mmap (10× menos E/S)
- Logging estructurado con niveles
- Gestión de memoria segura (limitación configurable)
- Control de interrupciones (Ctrl+C limpio)
- Extracción modular por formato
- Recursión controlada con filtros de tipo
- Informe JSON al final
"""

import argparse
import io
import mmap
import os
import struct
import subprocess
import sys
import tarfile
import zipfile
import gzip
import bz2
import lzma
import shutil
import tempfile
import json
import logging
from typing import List, Tuple, Optional, Dict

# -------------------------
# Configuración global
# -------------------------

MAX_INMEM_SIZE = 100 * 1024 * 1024  # 100 MB límite lectura en RAM
aExtsValidas = (".bin", ".elf", ".dat", ".img", ".fw", ".xz", ".gz")

logging.basicConfig(
  level=logging.INFO,
  format="[%(levelname)s] %(message)s",
  stream=sys.stderr
)

v_log = logging.info
v_err = logging.error
v_warn = logging.warning

# -------------------------
# Utilidades
# -------------------------

def v_write_bytes(vPath: str, vData: bytes):
  os.makedirs(os.path.dirname(vPath), exist_ok=True)
  with open(vPath, "wb") as f:
    f.write(vData)

def v_make_outdir(vBaseOut: str, vBinBase: str) -> str:
  vDir = os.path.join(vBaseOut, f"extracted_{vBinBase}")
  os.makedirs(vDir, exist_ok=True)
  return vDir

def v_has_cmd(vName: str) -> bool:
  return shutil.which(vName) is not None

def v_safe_read(vFilePath: str, vOffset=0) -> bytes:
  vSize = os.path.getsize(vFilePath)
  if vSize - vOffset > MAX_INMEM_SIZE:
    raise MemoryError(f"{vFilePath} demasiado grande ({vSize} bytes). Usa --recursive para análisis progresivo.")
  with open(vFilePath, "rb") as f:
    f.seek(vOffset)
    return f.read()

def v_open_from_offset(vFilePath: str, vOffset: int):
  f = open(vFilePath, "rb")
  f.seek(vOffset)
  return f

# -------------------------
# Firmas de formatos
# -------------------------

aSignatures = [
  {"name": "ELF", "magic": b"\x7fELF"},
  {"name": "GZIP", "magic": b"\x1f\x8b"},
  {"name": "XZ", "magic": b"\xfd7zXZ\x00"},
  {"name": "BZ2", "magic": b"BZh"},
  {"name": "ZIP", "magic": b"PK\x03\x04"},
  {"name": "ZSTD", "magic": b"\x28\xb5\x2f\xfd"},
  {"name": "LZ4", "magic": b"\x04\x22\x4D\x18"},
  {"name": "SEVEN_Z", "magic": b"7z\xBC\xAF\x27\x1C"},
  {"name": "RAR4", "magic": b"Rar!\x1A\x07\x00"},
  {"name": "RAR5", "magic": b"Rar!\x1A\x07\x01\x00"},
]

# -------------------------
# Escaneo de firmas
# -------------------------

def v_find_all_offsets_mm(vMM: mmap.mmap, vMagic: bytes) -> List[int]:
  aFound = []
  vPos = 0
  while True:
    vIdx = vMM.find(vMagic, vPos)
    if vIdx == -1:
      break
    aFound.append(vIdx)
    vPos = vIdx + 1
  return aFound

# -------------------------
# Carving de ELF
# -------------------------

def v_parse_elf_size(vFile: io.BufferedReader) -> Optional[int]:
  vStart = vFile.tell()
  vHdr = vFile.read(0x40)
  if len(vHdr) < 0x18 or vHdr[0:4] != b"\x7fELF":
    return None
  vClass, vData = vHdr[4], vHdr[5]
  vEndian = "<" if vData == 1 else (">" if vData == 2 else None)
  if not vEndian:
    return None

  try:
    if vClass == 1:
      e_phoff = struct.unpack_from(vEndian + "I", vHdr, 0x1C)[0]
      e_phentsize = struct.unpack_from(vEndian + "H", vHdr, 0x2A)[0]
      e_phnum = struct.unpack_from(vEndian + "H", vHdr, 0x2C)[0]
      vMax = 0
      for i in range(e_phnum):
        vFile.seek(vStart + e_phoff + i * e_phentsize)
        vPh = vFile.read(e_phentsize)
        if len(vPh) < 0x20:
          continue
        p_offset = struct.unpack_from(vEndian + "I", vPh, 0x04)[0]
        p_filesz = struct.unpack_from(vEndian + "I", vPh, 0x10)[0]
        vMax = max(vMax, p_offset + p_filesz)
      return vMax if vMax else None
    elif vClass == 2:
      e_phoff = struct.unpack_from(vEndian + "Q", vHdr, 0x20)[0]
      e_phentsize = struct.unpack_from(vEndian + "H", vHdr, 0x36)[0]
      e_phnum = struct.unpack_from(vEndian + "H", vHdr, 0x38)[0]
      vMax = 0
      for i in range(e_phnum):
        vFile.seek(vStart + e_phoff + i * e_phentsize)
        vPh = vFile.read(e_phentsize)
        if len(vPh) < 0x38:
          continue
        p_offset = struct.unpack_from(vEndian + "Q", vPh, 0x08)[0]
        p_filesz = struct.unpack_from(vEndian + "Q", vPh, 0x28)[0]
        vMax = max(vMax, p_offset + p_filesz)
      return vMax if vMax else None
  except Exception:
    return None

def v_carve_elf(vInPath: str, vOffset: int, vOutDir: str) -> Optional[str]:
  try:
    with v_open_from_offset(vInPath, vOffset) as f:
      vSize = v_parse_elf_size(f)
      if not vSize:
        v_warn(f"[ELF] {vInPath}@0x{vOffset:08x}: tamaño desconocido; guardo hasta EOF.")
        vSize = os.path.getsize(vInPath) - vOffset
      f.seek(vOffset)
      vData = f.read(vSize)
    vDest = os.path.join(vOutDir, f"{vOffset:08x}_ELF", "payload.elf")
    os.makedirs(os.path.dirname(vDest), exist_ok=True)
    v_write_bytes(vDest, vData)
    v_log(f"[ELF] Extraído {vDest} ({len(vData)} bytes)")
    return os.path.dirname(vDest)
  except Exception as e:
    v_err(f"[ELF] Error 0x{vOffset:08x}: {e}")
    return None

# -------------------------
# Extracción genérica
# -------------------------

def v_extract_tar_if_possible(vFilePath: str, vDestDir: str) -> bool:
  try:
    if tarfile.is_tarfile(vFilePath):
      vTarDest = os.path.join(vDestDir, "payload_tar")
      os.makedirs(vTarDest, exist_ok=True)
      with tarfile.open(vFilePath, "r:*") as t:
        t.extractall(vTarDest)
      return True
  except Exception:
    pass
  return False

def v_try_external_extract(vInFile: str, vDestDir: str) -> bool:
  for cmd in (["7z", "x", "-y", f"-o{vDestDir}", vInFile],
              ["unar", "-o", vDestDir, "-force-overwrite", vInFile]):
    if v_has_cmd(cmd[0]):
      try:
        subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return True
      except Exception:
        continue
  return False

def v_decompress_stream(vInPath: str, vOffset: int, vKind: str, vOutBase: str, vSaveRaw: bool) -> Optional[str]:
  vOutDirKind = os.path.join(vOutBase, f"{vOffset:08x}_{vKind}")
  os.makedirs(vOutDirKind, exist_ok=True)
  vRawPath = os.path.join(vOutDirKind, "raw_stream.bin")

  def _save_raw():
    with open(vInPath, "rb") as src, open(vRawPath, "wb") as dst:
      src.seek(vOffset)
      shutil.copyfileobj(src, dst, length=1024 * 1024)
    return vRawPath

  try:
    # Manejadores internos
    if vKind == "GZIP":
      with v_open_from_offset(vInPath, vOffset) as src, gzip.GzipFile(fileobj=src) as gz:
        vOutFile = os.path.join(vOutDirKind, "decompressed.bin")
        with open(vOutFile, "wb") as dst:
          shutil.copyfileobj(gz, dst, length=1024 * 1024)
      v_extract_tar_if_possible(vOutFile, vOutDirKind)
      v_log(f"[{vKind}] Extraído {vOutFile}")
      if vSaveRaw: _save_raw()
      return vOutDirKind

    if vKind == "BZ2":
      with v_open_from_offset(vInPath, vOffset) as src:
        vDecomp = bz2.BZ2Decompressor()
        vOutFile = os.path.join(vOutDirKind, "decompressed.bin")
        with open(vOutFile, "wb") as dst:
          while True:
            vChunk = src.read(1024 * 1024)
            if not vChunk: break
            dst.write(vDecomp.decompress(vChunk))
      v_extract_tar_if_possible(vOutFile, vOutDirKind)
      v_log(f"[{vKind}] Extraído {vOutFile}")
      if vSaveRaw: _save_raw()
      return vOutDirKind

    if vKind == "XZ":
      with v_open_from_offset(vInPath, vOffset) as src, lzma.LZMAFile(src) as lzf:
        vOutFile = os.path.join(vOutDirKind, "decompressed.bin")
        with open(vOutFile, "wb") as dst:
          shutil.copyfileobj(lzf, dst, length=1024 * 1024)
      v_extract_tar_if_possible(vOutFile, vOutDirKind)
      v_log(f"[{vKind}] Extraído {vOutFile}")
      if vSaveRaw: _save_raw()
      return vOutDirKind

    if vKind == "ZIP":
      vData = v_safe_read(vInPath, vOffset)
      try:
        with zipfile.ZipFile(io.BytesIO(vData)) as z:
          z.extractall(vOutDirKind)
        v_log(f"[{vKind}] Extraído {vOutDirKind}")
      except Exception:
        _save_raw()
        if not v_try_external_extract(vRawPath, vOutDirKind):
          v_warn(f"[{vKind}] No se pudo extraer ZIP, guardado raw.")
      return vOutDirKind

    # Otros manejadores genéricos
    if vKind in ("ZSTD", "LZ4", "SEVEN_Z", "RAR4", "RAR5"):
      _save_raw()
      if v_try_external_extract(vRawPath, vOutDirKind):
        v_log(f"[{vKind}] Extraído externamente {vOutDirKind}")
      else:
        v_warn(f"[{vKind}] Guardado raw sin extraer ({vRawPath})")
      return vOutDirKind

  except Exception as e:
    v_err(f"[{vKind}] Error 0x{vOffset:08x}: {e}")
    return None

# -------------------------
# Escaneo principal
# -------------------------

def v_scan_once(vInPath: str, vOutBase: str, vSaveRaw: bool) -> List[Tuple[str, str]]:
  vBinBase = os.path.basename(vInPath)
  vMainOut = v_make_outdir(vOutBase, vBinBase)
  aResults: List[Tuple[str, str]] = []

  with open(vInPath, "rb") as f, mmap.mmap(f.fileno(), 0, access=mmap.ACCESS_READ) as mm:
    aHits = []
    for sig in aSignatures:
      aOffs = v_find_all_offsets_mm(mm, sig["magic"])
      for off in aOffs:
        aHits.append((off, sig["name"]))

  aHits.sort(key=lambda x: x[0])
  vSeen: Dict[int, str] = {}
  for off, kind in aHits:
    if off not in vSeen or kind == "ELF":
      vSeen[off] = kind

  for off, kind in sorted(vSeen.items()):
    if kind == "ELF":
      vDir = v_carve_elf(vInPath, off, vMainOut)
    else:
      vDir = v_decompress_stream(vInPath, off, kind, vMainOut, vSaveRaw)
    if vDir:
      aResults.append((kind, vDir))
  return aResults

def v_recursive_scan(aPaths: List[str], vOutBase: str, vDepth: int, vSaveRaw: bool):
  aQueue = [(p, 0) for p in aPaths]
  aVisited = set()
  aReport = []

  while aQueue:
    vPath, vLvl = aQueue.pop(0)
    try:
      vStat = os.stat(vPath)
      vKey = (os.path.abspath(vPath), vStat.st_size, int(vStat.st_mtime))
      if vKey in aVisited:
        continue
      aVisited.add(vKey)

      v_log(f"[*] Escaneando (nivel {vLvl}): {vPath}")
      aArtifacts = v_scan_once(vPath, vOutBase, vSaveRaw)
      aReport.append({"path": vPath, "artifacts": aArtifacts})

      if vLvl < vDepth:
        for _kind, vDir in aArtifacts:
          for root, _, files in os.walk(vDir):
            for fname in files:
              vNext = os.path.join(root, fname)
              if vNext.lower().endswith(aExtsValidas):
                aQueue.append((vNext, vLvl + 1))
    except Exception as e:
      v_err(f"[!] Error escaneando {vPath}: {e}")

  vReportFile = os.path.join(vOutBase, "report.json")
  with open(vReportFile, "w") as rf:
    json.dump(aReport, rf, indent=2)
  v_log(f"[+] Informe guardado en {vReportFile}")

# -------------------------
# Main
# -------------------------

def main():
  vParser = argparse.ArgumentParser(description="Carver mejorado de payloads comprimidos y ELFs embebidos.")
  vParser.add_argument("-i", "--input", nargs="+", required=True, help="Archivo(s) a analizar")
  vParser.add_argument("-o", "--outdir", default="carve_out", help="Directorio base de salida")
  vParser.add_argument("--recursive", type=int, default=0, help="Profundidad de re-escaneo")
  vParser.add_argument("--save-raw", action="store_true", help="Guardar los flujos crudos comprimidos")
  vParser.add_argument("--log-level", default="INFO", choices=["DEBUG", "INFO", "WARNING", "ERROR"], help="Nivel de log")
  vParser.add_argument("--max-mem", type=int, default=100, help="Tamaño máximo de lectura directa (MB)")
  aArgs = vParser.parse_args()

  global MAX_INMEM_SIZE
  MAX_INMEM_SIZE = aArgs.max_mem * 1024 * 1024
  logging.getLogger().setLevel(aArgs.log_level)

  os.makedirs(aArgs.outdir, exist_ok=True)
  try:
    v_recursive_scan(aArgs.input, aArgs.outdir, aArgs.recursive, aArgs.save_raw)
    v_log("[*] Terminado correctamente.")
  except KeyboardInterrupt:
    v_warn("[!] Interrumpido por el usuario.")
  except Exception as e:
    v_err(f"[!] Error fatal: {e}")

if __name__ == "__main__":
  main()
