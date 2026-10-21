"""Source-only packaging contract tests. No build, download, or signing."""
import hashlib
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
import package_qpdf


class PackageQpdfTest(unittest.TestCase):
    def test_minimal_runtime_preserves_loader_layout_and_verifies_every_file(self):
        for operating_system in ('macos', 'windows', 'linux'):
            with self.subTest(operating_system=operating_system), tempfile.TemporaryDirectory() as temporary:
                root = Path(temporary)
                source = root / 'sdk'
                binary = source / 'upstream/bin' / ('qpdf.exe' if operating_system == 'windows' else 'qpdf')
                binary.parent.mkdir(parents=True)
                binary.write_bytes(b'executable')
                if operating_system == 'windows':
                    library = binary.parent / 'qpdf30.dll'
                else:
                    library = binary.parent.parent / 'lib' / ('libqpdf.dylib' if operating_system == 'macos' else 'libqpdf.so.30')
                    library.parent.mkdir()
                library.write_bytes(b'library')
                (binary.parent / 'unused-tool').write_bytes(b'exclude this')
                (source / 'manual.html').write_text('exclude this too')
                (source / 'runtime.json').write_text(json.dumps({'version': '12.4.2', 'executable': binary.relative_to(source).as_posix()}))
                notices = root / 'third_party/qpdf'
                notices.mkdir(parents=True)
                (notices / 'LICENSE.txt').write_text('license fixture')
                destination = root / 'package'
                destination.mkdir()
                (destination / 'obsolete.dll').write_bytes(b'old version')
                with patch.object(package_qpdf, 'prepare', return_value=source), patch.object(package_qpdf, 'ROOT', root):
                    package_qpdf.package(f'{operating_system}-arm64', destination)
                manifest = json.loads((destination / 'runtime.json').read_text())
                self.assertEqual(manifest['target'], f'{operating_system}-arm64')
                self.assertEqual(manifest['executable'], f'bin/{binary.name}')
                self.assertEqual(len(manifest['files']), 3)
                self.assertFalse((destination / 'obsolete.dll').exists())
                for name, digest in manifest['files'].items():
                    self.assertEqual(hashlib.sha256((destination / name).read_bytes()).hexdigest(), digest)
                self.assertTrue((destination / ('bin' if operating_system == 'windows' else 'lib') / library.name).exists())


if __name__ == '__main__':
    unittest.main()
