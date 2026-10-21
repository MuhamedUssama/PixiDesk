#!/usr/bin/env python3
"""Download and verify prebuilt QPDF. No compilation or application build."""
import argparse
import hashlib
import io
import json
import os
from pathlib import Path
import platform
import stat
import urllib.request
import zipfile

ROOT = Path(__file__).resolve().parent.parent
SPEC = json.loads((ROOT / 'native/qpdf/releases.json').read_text())


def prepare(target):
    destination = ROOT / 'native/qpdf/runtime' / target
    archive_spec = SPEC['targets'][target]
    manifest_path = destination / 'runtime.json'
    if manifest_path.exists():
        manifest = json.loads(manifest_path.read_text())
        if manifest.get('version') == SPEC['version'] and all(
            (destination / name).is_file() and hashlib.sha256((destination / name).read_bytes()).hexdigest() == digest
            for name, digest in manifest['files'].items()
        ):
            print(f'{target}: verified QPDF runtime')
            return destination
    url = f"{SPEC['source']}/{archive_spec['archive']}"
    with urllib.request.urlopen(url, timeout=120) as response:
        payload = response.read()
    if hashlib.sha256(payload).hexdigest() != archive_spec['sha256']:
        raise RuntimeError('QPDF archive checksum mismatch')
    destination.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(io.BytesIO(payload)) as archive:
        for entry in archive.infolist():
            output = destination / entry.filename
            if not output.resolve().is_relative_to(destination.resolve()):
                raise RuntimeError('Unsafe QPDF archive path')
            if entry.is_dir():
                output.mkdir(parents=True, exist_ok=True)
                continue
            output.parent.mkdir(parents=True, exist_ok=True)
            mode = entry.external_attr >> 16
            data = archive.read(entry)
            if stat.S_ISLNK(mode):
                link = data.decode()
                if not (output.parent / link).resolve().is_relative_to(destination.resolve()):
                    raise RuntimeError('Unsafe QPDF symlink')
                if output.exists() or output.is_symlink():
                    output.unlink()
                output.symlink_to(link)
            else:
                output.write_bytes(data)
                os.chmod(output, mode & 0o755 or 0o644)
    binary_name = 'qpdf.exe' if target.startswith('windows') else 'qpdf'
    candidates = list(destination.rglob(binary_name))
    if len(candidates) != 1:
        raise RuntimeError('Expected exactly one QPDF binary')
    binary = candidates[0]
    manifest = {
        'version': SPEC['version'], 'target': target,
        'executable': binary.relative_to(destination).as_posix(),
        'files': {file.relative_to(destination).as_posix(): hashlib.sha256(file.read_bytes()).hexdigest()
                  for file in destination.rglob('*') if file.is_file() and file.name != 'runtime.json'},
    }
    manifest_path.write_text(json.dumps(manifest, indent=2) + '\n')
    print(f'{target}: prepared QPDF {SPEC["version"]}')
    return destination


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--target', default='host', choices=['host', 'all', *SPEC['targets']])
    arguments = parser.parse_args()
    architecture = 'arm64' if platform.machine().lower() in ('arm64', 'aarch64') else 'x64'
    operating_system = {'Darwin': 'macos', 'Windows': 'windows', 'Linux': 'linux'}[platform.system()]
    targets = list(SPEC['targets']) if arguments.target == 'all' else [f'{operating_system}-{architecture}' if arguments.target == 'host' else arguments.target]
    for selected in targets:
        prepare(selected)
