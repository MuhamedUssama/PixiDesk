# Desktop PDFium integration

PDF-to-image uses PDFium `chromium/8100` via a generated subset of the public C
API. Prebuilt libraries come from bblanchon/pdfium-binaries, pinned by archive
SHA-256 in `releases.json`. PDFium itself is BSD-style; all distributed SDK
notices are retained in `third_party/pdfium` and copied into application bundles.
There is no paid engine license in this integration. Other app features and their
dependencies need their own distribution review.

## Setup without building

```sh
flutter pub get
python3 tool/prepare_pdfium.py --target host
flutter test test/features/pdf/pdf_to_image
```

`--target all` prepares every pinned SDK without compiling an app. Downloads live
under ignored `native/pdfium/runtime/`. Nothing is downloaded by the application
at runtime. Python 3.9+ is needed for the packaging/preparation scripts.

Source-mode development runs the Dart helper from `tool/pdfium_worker.dart` with
the host SDK. Production requires a bundled AOT helper and library and never
falls back to a system Dart SDK. After an unavailable-engine error, preparing the
SDK allows a retry; failed runtime resolutions are not cached.

## Architecture

- Domain: immutable conversion requests, typed progress/completion/failures,
  repository contracts, save/cancel/release use cases, export-dialog interface.
- Data: runtime verification, RPC clients, scheduling, PDFium FFI, filesystem
  snapshots, platform dialogs and isolate-based image/ZIP export.
- Presentation: `PdfToImageBloc`, Freezed state and localized widgets. Conversion
  and export requests are droppable while active. Picker results use a stable
  state snapshot. Page disposal cancels child processes and releases owned files.
- Each helper is an OS process with one initialized PDFium library and serial
  JSON-lines RPC. Rendering never calls PDFium concurrently inside one process.
  This also avoids sharing PDFium global state with the separate `printing`
  plugin used by image-to-PDF elsewhere in the app.
- Progress counts actual finished pages. Parallel workers cannot change final
  document/page ordering. Original source files are copied into private job
  snapshots before inspection/rendering; only owned job directories are removed.
- PDFium renders white-background BGRA with annotations and AcroForm appearances.
  XFA and password-protected documents return typed failures; entering passwords
  is not implemented. PNG/JPEG/TIFF encoding uses the Dart `image` package inside
  the helper, not native libjpeg/libpng. Production compiles this helper AOT.
- Review uses bounded PNG previews (1400 px) and thumbnails (320 px), including
  TIFF output. Full-resolution originals remain available for exports.
- Exports run in a Dart isolate, stage in the destination filesystem, reserve
  unique names and rename complete payloads. Existing files/links are preserved.
  Archives deduplicate entry names; rotations retain the original image codec.
  A multi-file export can leave previously completed files if a later file fails.

## Limits

At most 100 input files, 256 MiB each, 2 GiB per job, 5000 pages/document,
10000 pages/job and 160 million pixels/page. Accepted DPI is 72–1200. A worker
RPC has a 2-minute deadline and a whole job a 30-minute deadline. Cancellation
kills helpers, including during startup. Rejected overlapping jobs cannot cancel
an existing job even when they reuse its ID.

Workers are limited to the page count, available cores minus one (minimum one),
8 workers, and an estimated memory budget. The budget is 40% of physical RAM
capped at 4 GiB; failure to query physical RAM falls back to 1 GiB. Admission
estimates each worker as 16 bytes/pixel for the largest page plus 256 MiB.
This is a scheduling estimate, not an enforced OS RSS limit. Complex documents
can use more memory. Temporary disk usage is not hard-quota limited; filesystem
failures are reported and incomplete owned work is removed.

## Packaging (only during explicitly requested application builds)

The platform projects call `tool/package_pdfium.py`; routine tests must not run
that script. It downloads/verifies the pinned SDK, compiles the pure Dart helper,
copies the shared library, writes runtime metadata and retains license notices.

| Platform | Target | Bundled layout |
| --- | --- | --- |
| macOS | Intel x64 and Apple Silicon arm64 | `Contents/Frameworks/PixiDeskPDFium`, arch-specific helpers in `Contents/Helpers` |
| Windows | x64 or arm64 | `pdfium/` next to the runner, including `pixidesk_pdf_worker.exe` |
| Linux | glibc x64 or arm64 | `pdfium/` next to the installed runner |

macOS PDF conversion requires **macOS 13+**, confirmed from both Mach-O
architecture load commands (`LC_BUILD_VERSION minos 13.0`). Older macOS versions
receive a localized unsupported-platform error; the project deployment settings
are not raised. macOS uses a universal PDFium dylib. The Xcode embed phase packages the requested
`ARCHS`, signs nested code, adds inherited sandbox entitlements for release
helpers, then refreshes the library digest after signing. Universal helper
packaging requires an Apple Silicon build host with Rosetta 2: Dart does not
support cross-compilation to macOS, so packaging downloads a checksum-verified
Intel Dart SDK matching the host version and executes it under Rosetta for x64.
A native single-architecture build uses the existing SDK. Windows requires a
native Dart SDK for its target architecture. Linux can use Dart's supported
Linux cross-compilation. Python 3 and network access (or prepared caches) are
build-time requirements. musl Linux and 32-bit systems are not targeted.

Windows/Linux packaging is connected to the CMake runner dependency and install
phase. Shipping the runner without its sibling `pdfium/` directory is incomplete.
macOS signing/notarization and actual signed sandbox file access still require
native package validation before distribution.

## Verification and performance

Tests cover real PDFium subprocess rendering on the prepared host, codecs and
pixel content, page order, progress, cancellation/retry, invalid PDFs and raster
limits; RPC crashes/malformed replies/timeouts/startup cancellation; all six
bundle lookup combinations and digest/path checks; Bloc concurrency/lifecycle;
export collisions, symlinks, rotation codecs and archive names; Arabic/English
layouts at narrow/wide sizes in both themes.

During this implementation only macOS executed PDFium. Windows/Linux library
archives were downloaded and verified, and their resolver layouts are tested,
but their binaries and installed applications were not executed. No application
or AOT-helper build was run. Build/sign/install validation remains required on
each native platform once the user authorizes builds.

There is no measured Poppler-versus-PDFium performance result yet. Parallelism
and render quality are not proof of faster conversion. Benchmark release helpers
on the same corpus, DPI and format, measuring cold/warm time, pages/sec, peak RSS,
output size and visual correctness before making a speed claim. Native encoding
can be evaluated separately if measurements identify the Dart encoder as the
bottleneck.

Sources: [PDFium public API](https://pdfium.googlesource.com/pdfium/+/refs/heads/main/public/),
[pinned SDK release](https://github.com/bblanchon/pdfium-binaries/releases/tag/chromium/8100),
[Dart compilation limits](https://dart.dev/tools/dart-compile#cross-compilation),
[PDFium license](https://pdfium.googlesource.com/pdfium/+/refs/heads/main/LICENSE).
