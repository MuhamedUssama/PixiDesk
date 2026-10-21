# QPDF merge runtime

PixiDesk uses **QPDF 12.4.2** in a native child process for page inspection and
structural PDF merging. It preserves page streams without rasterizing the PDF.
PDFium remains the on-demand preview renderer. No benchmark or comparative
speed claim accompanies this choice.

## Prepare precompiled tools (no build)

```sh
python3 tool/prepare_qpdf.py --target host
# Or download all pinned platform archives:
python3 tool/prepare_qpdf.py --target all
```

Supported targets: `macos-arm64`, `macos-x64`, `windows-arm64`, `windows-x64`,
`linux-arm64`, `linux-x64`. Official archive URLs and SHA-256 values are pinned in
[releases.json](releases.json). Downloads live in ignored `native/qpdf/runtime/`.
Preparation verifies archives and writes runtime manifests; it compiles nothing.

The application verifies the runtime target/version and every bundled file's
SHA-256 before first use. A packaged release requires its own runtime and never
falls back to `PATH`, a package manager, Python, the Dart SDK, or a network fetch.
Source-mode development can resolve a prepared runtime under the project root.

## Packaging

Packaging is wired into **future explicitly authorized application builds**;
do not run a build as part of routine verification in this workspace.

- macOS: `tool/package_qpdf_macos.sh` copies architecture-specific runtimes under
  `Contents/Helpers/PixiDeskQPDF/{arm64,x64}`, signs the executable and dylibs,
  and refreshes checksums after signing.
- Windows/Linux: the desktop CMake integration packages the matching runtime
  beside the runner under `qpdf/`.
- `tool/package_qpdf.py` copies only the executable, runtime libraries, and
  notices; SDK headers, static libraries, manuals, and unrelated executables
  are excluded. Windows DLLs remain next to `qpdf.exe`.

QPDF and all dependent runtime libraries must travel together. The upstream
Linux stand-alone distribution bundles GnuTLS and several dependencies; system
ABI requirements still need execution on the actual target distribution.
The existing PDFium macOS binary requires macOS 13+ for previews. Structural
merging remains independent of preview availability.

## Behavior and limits

One session owns one merge at a time. A separate process allows cancellation to
kill native work. Passwords go through a private temporary JSON job file rather
than command arguments or state. Jobs and previews are cleaned on normal session
shutdown; abrupt termination may leave private temporary files behind.

Document ordering, explicit/reversed/repeated page ranges, exclusion, relative
90-degree rotation, staged output, expected-page-count validation, exclusive
filename reservation, source/alias protection, and source-change checks are
implemented. Existing destination files are rejected. Source-change detection
uses size/mtime/ctime checks, not a full immutable copy or cryptographic snapshot.

Interactive forms and signed form fields are rejected. Bookmarks, attachments,
accessibility structure, document-level metadata, and signature validity are not
combined. Cross-document annotation/link semantics are not guaranteed. Output is
unencrypted; the UI requires acknowledgment of the structure/encryption policy.

Limits: 100 documents, 512 MiB per source, 4 GiB aggregate input, 20,000 source or
output pages, 2-minute inspection/validation timeout, 30-minute merge timeout.
These are work limits, not a hard OS-process memory quota. Progress percentages
represent QPDF's writer phase rather than total elapsed job progress.

## Licensing and release validation

QPDF is Apache-2.0 licensed. Its LICENSE and NOTICE are under
`third_party/qpdf/` and copied into bundles. Apache-2.0 does not remove the
obligations of separately bundled libraries or the Microsoft runtime. Review
those notices and corresponding-source requirements before redistribution; the
release checklist in that directory identifies platform dependencies.

Only host macOS native execution has been performed for this implementation.
All six upstream archives were downloaded and SHA-256 verified; resolver tests
use fixture layouts for all six targets. Those checks do not prove Windows/Linux
execution, signing, sandbox compatibility, installer layout, or store approval.
No application or native-helper build was run.

See [QPDF page selection/JSON jobs](https://qpdf.readthedocs.io/en/stable/cli.html),
[official release](https://github.com/qpdf/qpdf/releases/tag/v12.4.2), and
[license](https://qpdf.readthedocs.io/en/stable/license.html).
