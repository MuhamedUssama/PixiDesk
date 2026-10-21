#!/bin/sh
# Packaging/signing phase only, as part of a user-requested application build.
set -eu
project_root="$PROJECT_DIR/.."
runtime_root="$TARGET_BUILD_DIR/$CONTENTS_FOLDER_PATH/Helpers/PixiDeskQPDF"
signing_identity="${EXPANDED_CODE_SIGN_IDENTITY:--}"
if [ -z "$signing_identity" ]; then signing_identity="-"; fi
if [ "$signing_identity" = "-" ]; then timestamp_option="--timestamp=none"; else timestamp_option="--timestamp"; fi
for architecture in $ARCHS; do
  case "$architecture" in
    arm64) target_architecture="arm64" ;;
    x86_64) target_architecture="x64" ;;
    *) echo "Unsupported QPDF architecture: $architecture" >&2; exit 1 ;;
  esac
  destination="$runtime_root/$target_architecture"
  python3 "$project_root/tool/package_qpdf.py" --target "macos-$target_architecture" --destination "$destination"
  for library in "$destination"/lib/*.dylib; do
    /usr/bin/codesign --force --sign "$signing_identity" "$timestamp_option" "$library"
  done
  for executable in "$destination"/bin/*; do
    if [ "$CONFIGURATION" = "Release" ]; then
      /usr/bin/codesign --force --sign "$signing_identity" "$timestamp_option" --options runtime --entitlements "$project_root/native/pdfium/helper.entitlements" "$executable"
    else
      /usr/bin/codesign --force --sign "$signing_identity" "$executable"
    fi
  done
  python3 - "$destination" <<'PY'
import hashlib, json, sys
from pathlib import Path
runtime = Path(sys.argv[1])
metadata = json.loads((runtime / 'runtime.json').read_text())
metadata['files'] = {name: hashlib.sha256((runtime / name).read_bytes()).hexdigest() for name in metadata['files']}
(runtime / 'runtime.json').write_text(json.dumps(metadata, indent=2) + '\n')
PY
done
