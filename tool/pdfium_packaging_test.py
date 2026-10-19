"""Packaging contract tests; subprocess compilation is mocked, never executed."""
import importlib.util
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

specification = importlib.util.spec_from_file_location('package_pdfium', Path(__file__).with_name('package_pdfium.py'))
packaging = importlib.util.module_from_spec(specification)
specification.loader.exec_module(packaging)


class PackagingContracts(unittest.TestCase):
    def test_all_target_layouts_and_native_compiler_arguments(self):
        for target, architecture in [('macos', 'arm64'), ('macos', 'x64'), ('windows-x64', 'x64'), ('windows-arm64', 'arm64'), ('linux-x64', 'x64'), ('linux-arm64', 'arm64')]:
            with self.subTest(target=target, architecture=architecture), tempfile.TemporaryDirectory() as temporary:
                root = Path(temporary)
                sdk = root / 'native/pdfium/runtime' / target
                sdk.mkdir(parents=True)
                library = 'pdfium.dll' if target.startswith('windows') else ('libpdfium.dylib' if target == 'macos' else 'libpdfium.so')
                (sdk / library).write_bytes(b'library fixture')
                (sdk / 'runtime.json').write_text(json.dumps({'revision': 'chromium/8100', 'library': library, 'librarySha256': 'fixture'}))
                notices = root / 'third_party/pdfium'
                notices.mkdir(parents=True)
                (notices / 'LICENSE').write_text('notice fixture')
                destination = root / 'bundle/pdfium'
                with patch.object(packaging, 'PROJECT_ROOT', root), patch.object(packaging, 'select_dart', return_value='/native/dart'), patch.object(packaging.subprocess, 'run') as command:
                    packaging.package(target, destination, '/host/dart', architecture)
                arguments = command.call_args_list[-1].args[0]
                self.assertEqual(arguments[:3], ['/native/dart', 'compile', 'exe'])
                if target.startswith('linux'):
                    self.assertIn('--target-os=linux', arguments)
                    self.assertIn(f'--target-arch={architecture}', arguments)
                else:
                    self.assertFalse(any(argument.startswith('--target-') for argument in arguments))
                worker = f'pixidesk_pdf_worker_{architecture}' if target == 'macos' else ('pixidesk_pdf_worker.exe' if target.startswith('windows') else 'pixidesk_pdf_worker')
                self.assertEqual(arguments[-1], str(destination / worker))
                self.assertEqual((destination / library).read_bytes(), b'library fixture')
                self.assertEqual((destination / 'licenses/LICENSE').read_text(), 'notice fixture')

    def test_native_sdk_is_reused(self):
        with patch.object(packaging.subprocess, 'run', return_value=subprocess.CompletedProcess([], 0, 'Dart SDK version: 3.13.2 (stable) on "macos_arm64"')):
            self.assertEqual(packaging.select_dart('/dart', 'macos', 'arm64'), '/dart')

    def test_unsupported_cross_target_is_rejected(self):
        with patch.object(packaging.subprocess, 'run', return_value=subprocess.CompletedProcess([], 0, 'Dart SDK version: 3.13.2 (stable) on "windows_x64"')):
            with self.assertRaises(RuntimeError):
                packaging.select_dart('/dart', 'windows', 'arm64')


if __name__ == '__main__':
    unittest.main()
