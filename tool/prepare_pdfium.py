#!/usr/bin/env python3
"""Download pinned, verified PDFium SDKs. Does not compile or launch an app."""
import argparse
import hashlib
import io
import json
import os
from pathlib import Path
import platform
import shutil
import tarfile
import urllib.request

PROJECT_ROOT = Path(__file__).resolve().parent.parent
MANIFEST = json.loads((PROJECT_ROOT / 'native/pdfium/releases.json').read_text())


def prepare(target):
    specification = MANIFEST['targets'][target]
    destination = PROJECT_ROOT / 'native/pdfium/runtime' / target
    existing = destination / 'runtime.json'
    if existing.exists():
        metadata = json.loads(existing.read_text())
        library = destination / specification['library']
        if library.exists() and metadata.get('revision') == MANIFEST['revision'] and hashlib.sha256(library.read_bytes()).hexdigest() == metadata.get('librarySha256'):
            print(f'{target}: verified existing runtime')
            return
    url = f"{MANIFEST['source']}/releases/download/{MANIFEST['revision']}/{specification['archive']}"
    request = urllib.request.Request(url, headers={'User-Agent': 'PixiDesk-PDFium-setup'})
    payload = urllib.request.urlopen(request, timeout=120).read()
    if hashlib.sha256(payload).hexdigest() != specification['sha256']:
        raise RuntimeError(f'Archive checksum mismatch for {target}')
    destination.mkdir(parents=True, exist_ok=True)
    with tarfile.open(fileobj=io.BytesIO(payload), mode='r:gz') as archive:
        # Only regular files and directories, never symlinks or paths outside SDK.
        for member in archive.getmembers():
            output = (destination / member.name).resolve()
            if not output.is_relative_to(destination.resolve()):
                raise RuntimeError('Unsafe archive path')
            if member.isdir():
                output.mkdir(parents=True, exist_ok=True)
            elif member.isfile():
                output.parent.mkdir(parents=True, exist_ok=True)
                output.write_bytes(archive.extractfile(member).read())
                os.chmod(output, member.mode & 0o755)
            else:
                raise RuntimeError('Unsupported archive entry')
    library = destination / specification['library']
    metadata = {'revision': MANIFEST['revision'], 'target': target, 'library': specification['library'], 'librarySha256': hashlib.sha256(library.read_bytes()).hexdigest()}
    existing.write_text(json.dumps(metadata, indent=2) + '\n')
    print(f'{target}: prepared {library.name}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--target', choices=[*MANIFEST['targets'], 'host', 'all'], default='host')
    arguments = parser.parse_args()
    architecture = 'arm64' if platform.machine().lower() in ('arm64', 'aarch64') else 'x64'
    host = {'Darwin': 'macos', 'Windows': f'windows-{architecture}', 'Linux': f'linux-{architecture}'}[platform.system()]
    targets = list(MANIFEST['targets']) if arguments.target == 'all' else [host if arguments.target == 'host' else arguments.target]
    for target_name in targets:
        prepare(target_name)
