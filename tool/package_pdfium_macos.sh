#!/bin/sh
# Xcode build phase only; never execute during routine verification.
set -eu
project_root="$PROJECT_DIR/.."
framework_directory="$TARGET_BUILD_DIR/$CONTENTS_FOLDER_PATH/Frameworks/PixiDeskPDFium"
helper_directory="$TARGET_BUILD_DIR/$CONTENTS_FOLDER_PATH/Helpers"
mkdir -p "$helper_directory"
for architecture in $ARCHS; do
  case "$architecture" in
    arm64) dart_architecture="arm64" ;;
    x86_64) dart_architecture="x64" ;;
    *) echo "Unsupported PDFium architecture: $architecture" >&2; exit 1 ;;
  esac
  python3 "$project_root/tool/package_pdfium.py" --target macos --architecture "$dart_architecture" --destination "$framework_directory" --dart "$FLUTTER_ROOT/bin/cache/dart-sdk/bin/dart"
  mv "$framework_directory/pixidesk_pdf_worker_$dart_architecture" "$helper_directory/"
done
signing_identity="${EXPANDED_CODE_SIGN_IDENTITY:--}"
if [ -z "$signing_identity" ]; then signing_identity="-"; fi
if [ "$signing_identity" = "-" ]; then timestamp_option="--timestamp=none"; else timestamp_option="--timestamp"; fi
/usr/bin/codesign --force --sign "$signing_identity" "$timestamp_option" "$framework_directory/libpdfium.dylib"
for architecture in $ARCHS; do
  if [ "$architecture" = "arm64" ]; then dart_architecture="arm64"; else dart_architecture="x64"; fi
  helper_path="$helper_directory/pixidesk_pdf_worker_$dart_architecture"
  if [ "$CONFIGURATION" = "Release" ]; then
    /usr/bin/codesign --force --sign "$signing_identity" "$timestamp_option" --options runtime --entitlements "$project_root/native/pdfium/helper.entitlements" "$helper_path"
  else
    /usr/bin/codesign --force --sign "$signing_identity" "$helper_path"
  fi
done
# Signing changes Mach-O bytes; the signed app seals this updated manifest.
python3 - "$framework_directory" <<'PY'
import hashlib, json, sys
from pathlib import Path
runtime = Path(sys.argv[1])
metadata = json.loads((runtime / 'runtime.json').read_text())
metadata['librarySha256'] = hashlib.sha256((runtime / metadata['library']).read_bytes()).hexdigest()
(runtime / 'runtime.json').write_text(json.dumps(metadata, indent=2) + '\n')
PY
