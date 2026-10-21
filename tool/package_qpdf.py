#!/usr/bin/env python3
"""Bundle verified QPDF during an explicitly requested application build."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
from prepare_qpdf import prepare, ROOT


def package(target, destination):
    source = prepare(target)
    source_manifest = json.loads((source / 'runtime.json').read_text())
    source_binary = source / source_manifest['executable']
    # Ship runtime code and notices, not headers, static libraries, manuals, or
    # unrelated command-line tools. DLLs stay beside qpdf.exe for Windows loading.
    if destination.exists():
        shutil.rmtree(destination)
    binary_directory = destination / 'bin'
    binary_directory.mkdir(parents=True)
    shutil.copy2(source_binary, binary_directory / source_binary.name)
    if target.startswith('windows'):
        libraries = source_binary.parent.glob('*.dll')
        library_directory = binary_directory
    else:
        libraries = (source_binary.parent.parent / 'lib').glob('*')
        library_directory = destination / 'lib'
        library_directory.mkdir()
    for library in libraries:
        if library.is_file():
            # Dereference upstream loader-name symlinks for Windows-friendly
            # copies. Both the versioned and loader names get verified digests.
            shutil.copy2(library, library_directory / library.name)
    shutil.copytree(ROOT / 'third_party/qpdf', destination / 'licenses')
    manifest = {
        'version': source_manifest['version'], 'target': target,
        'executable': (binary_directory / source_binary.name).relative_to(destination).as_posix(),
        'files': {file.relative_to(destination).as_posix(): hashlib.sha256(file.read_bytes()).hexdigest()
                  for file in sorted(destination.rglob('*')) if file.is_file()},
    }
    (destination / 'runtime.json').write_text(json.dumps(manifest, indent=2) + '\n')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--target', required=True)
    parser.add_argument('--destination', required=True, type=Path)
    arguments = parser.parse_args()
    package(arguments.target, arguments.destination)
