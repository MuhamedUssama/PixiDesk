#!/usr/bin/env python3
"""Build-time packaging only. Never invoked by setup, tests, or application runtime.
This script compiles the helper and must only run as part of a user-requested build.
"""
import argparse
import json
import hashlib
import platform
import re
import urllib.request
import zipfile
from pathlib import Path
import shutil
import subprocess
import sys

PROJECT_ROOT = Path(__file__).resolve().parent.parent



def select_dart(dart_executable, operating_system, architecture):
    version_output = subprocess.run([dart_executable, '--version'], capture_output=True, text=True, check=True).stdout
    if operating_system == 'linux' or f'{operating_system}_{architecture}' in version_output:
        return dart_executable
    if operating_system != 'macos' or architecture != 'x64' or platform.machine().lower() not in ('arm64', 'aarch64'):
        raise RuntimeError('Use a native Dart SDK for this target. Universal macOS packaging requires Apple Silicon with Rosetta 2.')
    # Dart only supports Linux cross-compilation. Execute the official Intel SDK
    # under Rosetta for the Intel half of a universal macOS application.
    match = re.search(r'Dart SDK version: ([^ ]+)', version_output)
    if not match:
        raise RuntimeError('Cannot identify the Dart SDK version')
    version = match.group(1)
    channel = 'dev' if '-' in version else 'stable'
    sdk_root = PROJECT_ROOT / 'native/pdfium/worker/toolchains' / version
    sdk_dart = sdk_root / 'dart-sdk/bin/dart'
    if not sdk_dart.exists():
        base = f'https://storage.googleapis.com/dart-archive/channels/{channel}/release/{version}/sdk/dartsdk-macos-x64-release.zip'
        with urllib.request.urlopen(base + '.sha256sum', timeout=120) as response:
            expected_digest = response.read().decode().split()[0]
        archive_path = sdk_root / 'sdk.zip'
        sdk_root.mkdir(parents=True, exist_ok=True)
        urllib.request.urlretrieve(base, archive_path)
        if hashlib.sha256(archive_path.read_bytes()).hexdigest() != expected_digest:
            archive_path.unlink()
            raise RuntimeError('Intel Dart SDK checksum mismatch')
        with zipfile.ZipFile(archive_path) as archive:
            for entry in archive.infolist():
                extracted_path = (sdk_root / entry.filename).resolve()
                if not extracted_path.is_relative_to(sdk_root.resolve()):
                    raise RuntimeError('Unsafe Dart SDK archive path')
                archive.extract(entry, sdk_root)
                if not entry.is_dir():
                    extracted_path.chmod((entry.external_attr >> 16) & 0o755 or 0o644)
        archive_path.unlink()
    return str(sdk_dart)


def package(target, destination, dart_executable, architecture=None):
    # Preparation only downloads prebuilt PDFium and verifies a pinned SHA-256.
    subprocess.run([sys.executable, str(PROJECT_ROOT / 'tool/prepare_pdfium.py'), '--target', target], check=True)
    sdk = PROJECT_ROOT / 'native/pdfium/runtime' / target
    metadata = json.loads((sdk / 'runtime.json').read_text())
    destination.mkdir(parents=True, exist_ok=True)
    library_name = Path(metadata['library']).name
    shutil.copy2(sdk / metadata['library'], destination / library_name)
    metadata['library'] = library_name
    (destination / 'runtime.json').write_text(json.dumps(metadata, indent=2) + '\n')
    shutil.copytree(PROJECT_ROOT / 'third_party/pdfium', destination / 'licenses', dirs_exist_ok=True)
    architecture = architecture or (('arm64' if platform.machine().lower() in ('arm64', 'aarch64') else 'x64') if target == 'macos' else target.rsplit('-', 1)[-1])
    operating_system = 'macos' if target == 'macos' else target.split('-')[0]
    worker_name = f'pixidesk_pdf_worker_{architecture}' if target == 'macos' else ('pixidesk_pdf_worker.exe' if target.startswith('windows') else 'pixidesk_pdf_worker')
    worker = destination / worker_name
    dart_executable = select_dart(dart_executable, operating_system, architecture)
    compile_arguments = [dart_executable, 'compile', 'exe']
    if operating_system == 'linux':
        compile_arguments += ['--target-os=linux', f'--target-arch={architecture}']
    subprocess.run([*compile_arguments, str(PROJECT_ROOT / 'tool/pdfium_worker.dart'), '-o', str(worker)], cwd=PROJECT_ROOT, check=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--target', required=True, choices=['macos', 'linux-x64', 'linux-arm64', 'windows-x64', 'windows-arm64'])
    parser.add_argument('--destination', required=True, type=Path)
    parser.add_argument('--dart', required=True)
    parser.add_argument('--architecture', choices=['arm64', 'x64'])
    arguments = parser.parse_args()
    package(arguments.target, arguments.destination.resolve(), arguments.dart, arguments.architecture)
