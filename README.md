# PixiDesk

A Flutter desktop workspace for local image processing and PDF utilities.

## Image studio

- Import images, folders, subfolders, file paths, or clipboard images into a batch queue.
- Convert PNG, JPEG, WebP, BMP, TIFF, ICO, and GIF with content-based input inspection.
- Resize, crop, rotate, flip, adjust colors, and apply text or image watermarks.
- Compare the source and encoded preview, zoom the canvas, and inspect export results.
- Set JPEG/lossy WebP quality or a target size. PNG uses lossless optimization; smaller output is not guaranteed.
- Preserve supported animation and metadata or choose explicit flattening/removal policies. Orientation is normalized, and supported ICC profiles are retained.
- Save, rename, duplicate, import, and export versioned presets.
- Pause scheduling, cancel processing, retry failures, and manually restore interrupted jobs from local history.
- Watch a folder for stable new or changed files while the image page remains open. Subfolders are excluded from watching.
- Export icon packs, PNG assets at 1x/2x/3x, or send an ordered image set to the existing PDF converter.

The studio follows the existing presentation/domain/data architecture. The domain contains immutable requests, recipes, results, validation, and repository contracts. Filesystem access, codecs, persistence, dialogs, and local tool adapters live in data. Cubit coordinates the view state and job lifecycle.

## Development

Requires Flutter **3.44 or newer** and Dart **3.12 or newer**. Native validation for this change uses macOS; Windows and Linux runners also exist in the project.

```sh
flutter pub get
flutter gen-l10n
dart run build_runner build
flutter run -d macos
```

The feature inherits PixiDesk's light/dark theme. All product copy is maintained in `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`.

## Optional local tools

OCR uses an existing `tesseract` executable on `PATH` and the chosen `eng`/`ara` language data. Background removal uses an existing `rembg` executable and a preinstalled `U2NET_HOME/u2net.onnx` model. These tools and models are optional, are not bundled, and are not downloaded by PixiDesk.

Image clipboard input uses the native pasteboard on macOS, PowerShell on Windows, and `wl-paste` or `xclip` on Linux. File-path clipboard input remains available when those optional Linux providers are absent.

Presets, up to 200 completed results, and up to 1000 pending recovery records are stored locally in the application support directory. Clearing history never deletes source files or exports. Source files are protected from export replacement, including other sources in the current queue and filesystem aliases.

## Verification

```sh
dart analyze lib test
flutter test --no-pub
flutter build macos --release --no-pub
```

Local review documents and design captures under `docs/` are intentionally excluded from Git.
