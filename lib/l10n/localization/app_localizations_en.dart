// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PixiDesk';

  @override
  String get pdfConverterTitle => 'PDF Converter';

  @override
  String get pdfConverterSubtitle => 'Convert images to PDF documents';

  @override
  String get addPhotos => 'Add Photos';

  @override
  String get generatePdf => 'Generate PDF';

  @override
  String get pageSize => 'Page Size';

  @override
  String get quality => 'Quality';

  @override
  String get noImagesSelected => 'No images selected';

  @override
  String get pdfGeneratedSuccess => 'PDF Generated Successfully';

  @override
  String get saveAs => 'Save PDF As';

  @override
  String get original => 'Original';

  @override
  String get a4 => 'A4';

  @override
  String get letter => 'Letter';

  @override
  String get high => 'High';

  @override
  String get medium => 'Medium';

  @override
  String get low => 'Low';

  @override
  String get dropImageHere => 'Drop Image Here';

  @override
  String get orClickToUpload => 'Or click to upload';

  @override
  String get convert => 'Convert';

  @override
  String get compress => 'Compress';

  @override
  String get save => 'Save';

  @override
  String get selectFormat => 'Select Format';

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String get imageSaved => 'Image saved successfully';

  @override
  String get invalidPath => 'Invalid path';

  @override
  String get dragAndDropImages => 'Drag and drop images here to start';

  @override
  String get imageProcessingTitle => 'Image Processing';

  @override
  String get imageProcessingSubtitle =>
      'Compress and convert images efficiently';

  @override
  String get pdfTools => 'PDF Tools';

  @override
  String get pdfToolsSubtitle => 'Convert, compress, manage PDFs efficiently';

  @override
  String get appSubtitle =>
      'Your all-in-one desktop utility for image and PDF processing.';

  @override
  String get compressPdf => 'Compress PDF';

  @override
  String get compressPdfSubtitle => 'Compress PDF files efficiently';

  @override
  String get pdfCompression => 'PDF Compression';

  @override
  String get compressionSuccess => 'PDF Compressed Successfully';

  @override
  String get invalidPdfFile => 'Invalid PDF file';

  @override
  String get dragDropPdf => 'Drag and drop PDF here to start';

  @override
  String get selectPdf => 'Select PDF';

  @override
  String get removeFile => 'Remove File';

  @override
  String get compressionLevel => 'Compression Level';

  @override
  String get compressionScreen => 'Screen (72 dpi)';

  @override
  String get compressionEbook => 'eBook (150 dpi)';

  @override
  String get compressionPrinter => 'Printer (300 dpi)';

  @override
  String get compressionPrepress => 'Prepress (300 dpi)';

  @override
  String get compressionDefault => 'Default';

  @override
  String get originalFile => 'Original File';

  @override
  String get compressedFile => 'Compressed File';

  @override
  String get quickSave => 'Quick Save';

  @override
  String get previewAndSave => 'Preview & Save';

  @override
  String get size => 'Size';

  @override
  String get previewPdf => 'Preview PDF';

  @override
  String get savePdf => 'Save PDF';

  @override
  String get pdfToImages => 'PDF To Images';

  @override
  String get pdfToImagesSubtitle => 'Convert PDF documents to images';

  @override
  String get pdfToImage => 'PDF to Image';

  @override
  String get conversionSettings => 'Conversion Settings';

  @override
  String get outputFormat => 'Output Format';

  @override
  String get qualityDpi => 'Quality (DPI)';

  @override
  String convertingPageOf(int currentPage, String totalPages) {
    return 'Converting page $currentPage of $totalPages';
  }

  @override
  String get filesSaved => 'Files saved successfully';

  @override
  String get conversionResult => 'Conversion Result';

  @override
  String get saveAll => 'Save All';

  @override
  String get dragPdfHere => 'Drag PDF Here';

  @override
  String get selectPdfFile => 'Select PDF File';

  @override
  String get preparing => 'Preparing...';

  @override
  String get dpi1200Label => '1200 DPI (For Professional Users)';

  @override
  String get dpi1200Warning =>
      'Note: 1200 DPI is resource-intensive and may take a significant amount of time to process.';

  @override
  String get deleteSelected => 'Delete Selected';

  @override
  String get rotateRight => 'Rotate Right';

  @override
  String get selected => 'Selected';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get gridView => 'Grid View';

  @override
  String get saveAsZip => 'Save As Zip';

  @override
  String get downloadOptions => 'Download Options';

  @override
  String get downloadOptionsMessage => 'How would you like to save the images?';

  @override
  String get combinedFolder => 'Combined Folder';

  @override
  String get separateZips => 'Separate ZIPs';

  @override
  String get cancel => 'Cancel';

  @override
  String get imageAddFiles => 'Add images';

  @override
  String get imageAddFolder => 'Add folder';

  @override
  String get imageAddRecursive => 'Include subfolders';

  @override
  String get imagePaste => 'Paste images or file paths';

  @override
  String get imageQueue => 'Queue';

  @override
  String get imageSettings => 'Settings';

  @override
  String get imagePreview => 'Preview';

  @override
  String get imagePreviewHint =>
      'Preview is a scaled still image. Export preserves supported animation.';

  @override
  String get imageBeforeAfter => 'Before / after';

  @override
  String get imageAfter => 'After';

  @override
  String get imageFit => 'Fit view';

  @override
  String get imagePreviewError =>
      'Unable to display this image. Try importing it again.';

  @override
  String get imageExport => 'Export image';

  @override
  String get imageExportAll => 'Export queue';

  @override
  String get imageExportTitle => 'Save processed image';

  @override
  String get imageOutputFolder => 'Output folder';

  @override
  String get imageRetryFailed => 'Retry failed or cancelled';

  @override
  String get imageClearQueue => 'Clear queue';

  @override
  String get imageRemove => 'Remove image';

  @override
  String get imagePause => 'Pause after current image';

  @override
  String get imageResume => 'Resume queue';

  @override
  String get imageCancelled => 'Cancelled';

  @override
  String get imagePending => 'Pending';

  @override
  String get imageRunning => 'Processing';

  @override
  String get imageCompleted => 'Completed';

  @override
  String get imageFailed => 'Failed';

  @override
  String get imageSkipped => 'Skipped';

  @override
  String get imageImporting => 'Inspecting images…';

  @override
  String get imageChoosing => 'Choosing destination…';

  @override
  String get imageProcessing => 'Processing images…';

  @override
  String get imagePreviewing => 'Preparing preview…';

  @override
  String get imageRecognizing => 'Recognizing text locally…';

  @override
  String get imageRemovingBackground => 'Removing background locally…';

  @override
  String get imageResize => 'Resize and crop';

  @override
  String get imageWidth => 'Width (pixels)';

  @override
  String get imageHeight => 'Height (pixels)';

  @override
  String get imageKeepOriginal => 'Auto / original';

  @override
  String get imageResizeFit => 'Fit within bounds';

  @override
  String get imageResizeFill => 'Fill and crop';

  @override
  String get imageResizeStretch => 'Stretch to size';

  @override
  String get imageAllowUpscale => 'Allow upscaling';

  @override
  String get imageCropLeft => 'Crop left (%)';

  @override
  String get imageCropTop => 'Crop top (%)';

  @override
  String get imageCropWidth => 'Crop width (%)';

  @override
  String get imageCropHeight => 'Crop height (%)';

  @override
  String get imageSquareCrop => 'Center square crop';

  @override
  String get imageResetCrop => 'Reset crop';

  @override
  String get imageRotate => 'Rotate 90°';

  @override
  String get imageFlipHorizontal => 'Flip horizontally';

  @override
  String get imageFlipVertical => 'Flip vertically';

  @override
  String get imageAdjustments => 'Color adjustments';

  @override
  String get imageBrightness => 'Brightness';

  @override
  String get imageContrast => 'Contrast';

  @override
  String get imageSaturation => 'Saturation';

  @override
  String get imageGrayscale => 'Grayscale';

  @override
  String get imageReset => 'Reset settings';

  @override
  String get imageUndo => 'Undo';

  @override
  String get imageRedo => 'Redo';

  @override
  String get imageCompression => 'Encoding and compression';

  @override
  String get imageLossless => 'Lossless WebP';

  @override
  String get imageLosslessHint =>
      'PNG uses lossless optimization. Quality applies to JPEG and lossy WebP.';

  @override
  String get imageTargetSize => 'Target size (KB, optional)';

  @override
  String get imageMinQuality => 'Minimum quality';

  @override
  String get imageTargetHint =>
      'Set a file size goal. If it cannot be reached, the result will tell you.';

  @override
  String get imageMetadata => 'Metadata and animation';

  @override
  String get imageMetadataRemove => 'Remove EXIF and text metadata';

  @override
  String get imageMetadataPreserve => 'Preserve supported metadata';

  @override
  String get imageMetadataHint =>
      'Orientation is normalized. ICC color profiles are retained where the format supports them; exact metadata preservation varies by codec.';

  @override
  String get imageAnimationPreserve => 'Preserve supported animation';

  @override
  String get imageAnimationFirst => 'Export first frame only';

  @override
  String get imageAlphaHint =>
      'JPEG and BMP flatten transparency onto the selected background. Unsupported animation is flattened with a result notice.';

  @override
  String get imageBackground => 'Background color (RRGGBB)';

  @override
  String get imageIconPack => 'ICO pack: 16, 32, 48, 64, 128, 256 px';

  @override
  String get imageWatermark => 'Watermark';

  @override
  String get imageWatermarkText => 'Watermark text (Arabic or English)';

  @override
  String get imageWatermarkLogo => 'Choose watermark image';

  @override
  String get imageWatermarkRemove => 'Remove watermark image';

  @override
  String get imageOpacity => 'Opacity';

  @override
  String get imageWatermarkScale => 'Relative watermark size';

  @override
  String get imageTopLeft => 'Top left';

  @override
  String get imageTopCenter => 'Top center';

  @override
  String get imageTopRight => 'Top right';

  @override
  String get imageCenterLeft => 'Center left';

  @override
  String get imageCenter => 'Center';

  @override
  String get imageCenterRight => 'Center right';

  @override
  String get imageBottomLeft => 'Bottom left';

  @override
  String get imageBottomCenter => 'Bottom center';

  @override
  String get imageBottomRight => 'Bottom right';

  @override
  String get imageNaming => 'Output naming and conflicts';

  @override
  String get imageNamePattern => 'Name pattern';

  @override
  String get imageNamePatternHint =>
      'Tokens: {name}, {index}, {width}, {height}. Dimensions reflect the final edits.';

  @override
  String get imageConflictRename => 'Rename if a file exists';

  @override
  String get imageConflictSkip => 'Skip existing files';

  @override
  String get imageConflictReplace => 'Replace existing files';

  @override
  String get imageReplaceHint =>
      'Replace overwrites existing exports. Original source files are always protected.';

  @override
  String get imageOpen => 'Open result';

  @override
  String get imageReveal => 'Show in folder';

  @override
  String get imageNoSavings =>
      'The output is not smaller; requested edits and metadata settings were retained.';

  @override
  String get imageUnchanged =>
      'The original was already smaller; an unchanged copy was saved.';

  @override
  String get imageTargetNotReached =>
      'The target size could not be reached within the quality limit.';

  @override
  String get imageAnimationFlattened => 'Only the first frame was exported.';

  @override
  String get imageAlphaFlattened =>
      'Transparency was flattened onto the selected background.';

  @override
  String get imageMetadataLimited =>
      'This codec preserves only limited metadata.';

  @override
  String get imagePresets => 'Presets and recipes';

  @override
  String get imagePresetSharing => 'JPEG for sharing';

  @override
  String get imagePresetTransparent => 'Transparent PNG';

  @override
  String get imagePresetStore => 'Store photos: 1600 px';

  @override
  String get imagePresetIcon => 'Desktop icon pack';

  @override
  String get imageSavePreset => 'Save current preset';

  @override
  String get imagePresetName => 'Preset name';

  @override
  String get imageImportPreset => 'Import preset JSON';

  @override
  String get imageExportPreset => 'Export preset JSON';

  @override
  String get imageDeletePreset => 'Delete preset';

  @override
  String get imageHistory => 'Processing history';

  @override
  String get imageClearHistory => 'Clear history';

  @override
  String get imageHistoryHint =>
      'Stores up to 200 local results. Clearing history never deletes your files.';

  @override
  String get imageRestore => 'Restore source and recipe';

  @override
  String get imageEmptyHistory => 'No saved results yet.';

  @override
  String get imageWatch => 'Watch folder';

  @override
  String get imageStopWatch => 'Stop watching';

  @override
  String get imageWatchInput => 'Choose input folder to watch';

  @override
  String get imageWatchHint =>
      'While this page is open, new or changed stable files in the selected folder are processed with a snapshot of the current settings. Subfolders are excluded. Input and output folders must not overlap.';

  @override
  String get imageTools => 'Local tools';

  @override
  String get imageOcr => 'Extract text (OCR)';

  @override
  String get imageOcrLanguage => 'OCR language';

  @override
  String get imageEnglish => 'English';

  @override
  String get imageArabic => 'Arabic';

  @override
  String get imageArabicEnglish => 'Arabic and English';

  @override
  String get imageOcrHint =>
      'Requires a local Tesseract installation with the selected language data. Images stay on your device.';

  @override
  String get imageCutout => 'Remove background';

  @override
  String get imageCutoutHint =>
      'Requires local rembg and a preinstalled u2net.onnx model in U2NET_HOME. No model is downloaded automatically.';

  @override
  String get imageCopyText => 'Copy text';

  @override
  String get imageSaveText => 'Save text';

  @override
  String get imageToPdf => 'Send images to PDF';

  @override
  String get imageFromPdf => 'Process these images';

  @override
  String get imageResourceHint =>
      'Limits: 64 MiB input, 24 MP per frame, 32 MP total, 120 frames and 1000 queue items. Files are processed sequentially.';

  @override
  String get imageInvalidInput =>
      'The file is missing, unreadable, or not a valid image.';

  @override
  String get imageUnsupported => 'This image format is not supported.';

  @override
  String get imageResourceLimit =>
      'The image or queue exceeds the supported resource limits.';

  @override
  String get imageInvalidOptions =>
      'Check dimensions, crop, quality, naming tokens and folder settings.';

  @override
  String get imagePermissionDenied =>
      'Unable to read or write this location. Choose another folder.';

  @override
  String get imageDestinationConflict =>
      'The destination conflicts with a source or another output. Choose another name.';

  @override
  String get imageSourceChanged =>
      'The source changed since import. Import it again before processing.';

  @override
  String get imageEncodeFailed =>
      'Unable to process or save the image. Your source has not been replaced.';

  @override
  String get imageInvalidPreset =>
      'This preset file is invalid or uses an unsupported version.';

  @override
  String get imageStorageFailed =>
      'Unable to load or save the local workspace. Existing saved data was preserved.';

  @override
  String get imageToolUnavailable =>
      'The required local tool or model is not installed or cannot be found. Check the tool requirements.';

  @override
  String get imageToolFailed =>
      'The local tool failed or timed out. Check the installation and language/model files.';

  @override
  String imageQueueCount(int count) {
    return '$count images';
  }

  @override
  String imageProgressCount(int finished, int total) {
    return '$finished / $total processed';
  }

  @override
  String imageDimensions(int width, int height, int frames) {
    return '$width × $height px · $frames frame(s)';
  }

  @override
  String imageResultStats(String before, String after, String savings) {
    return '$before → $after · $savings% saved';
  }

  @override
  String imageSettingValue(String label, String value) {
    return '$label: $value';
  }

  @override
  String imageWatchingPath(String path) {
    return 'Watching: $path';
  }

  @override
  String imageFileSize(String value, String unit) {
    return '$value $unit';
  }

  @override
  String get imageBytesUnit => 'B';

  @override
  String get imageKbUnit => 'KiB';

  @override
  String get imageMbUnit => 'MiB';

  @override
  String get imageAssetScales => 'Export PNG assets: 1x / 2x / 3x';

  @override
  String get imageInterrupted => 'Interrupted or pending — restore to retry';

  @override
  String get imageRenamePreset => 'Rename preset';

  @override
  String get imageDuplicatePreset => 'Duplicate preset';

  @override
  String get imageLastExport => 'Last saved export';

  @override
  String get imageStudioTitle => 'Image studio';

  @override
  String get imageStudioEdit => 'Adjust';

  @override
  String get imageStudioExport => 'Export';

  @override
  String get imageStudioPresets => 'Presets';

  @override
  String get imageStudioInspector => 'Make it yours';

  @override
  String get imageStudioInspectorHint => 'Fine-tune your next export.';

  @override
  String get imageStudioLibrary => 'Your images';

  @override
  String get imageStudioQueueEmpty => 'A little quiet here';

  @override
  String get imageStudioQueuePrompt => 'Your images will appear here.';

  @override
  String get imageStudioEmptyTitle => 'A fresh canvas.';

  @override
  String get imageStudioEmptyHint =>
      'Drop your images here to start. A single shot or a whole collection.';

  @override
  String get imageStudioLocal => 'Processed on your device';

  @override
  String get imageStudioReady => 'Ready when you are';

  @override
  String get imageStudioFit => 'Fit';

  @override
  String get imageStudioCompare => 'Compare';

  @override
  String get imageStudioResult => 'Result';

  @override
  String get imageStudioZoomIn => 'Zoom in';

  @override
  String get imageStudioZoomOut => 'Zoom out';

  @override
  String get imageStudioExportAll => 'Export all';

  @override
  String get imageStudioMore => 'More actions';

  @override
  String get imageStudioImportOptions => 'Import options';

  @override
  String get imageStudioPreviewAction => 'Update preview';

  @override
  String get imageStudioSingleExport => 'Export image';

  @override
  String get imageStudioQuickPresets => 'A good starting point';

  @override
  String get imageStudioSavedPresets => 'Your recipes';

  @override
  String get imageStudioSelected => 'Selected image';

  @override
  String get imageStudioInfo => 'Image information';

  @override
  String get imageStudioMoreFormats => 'More formats';

  @override
  String imageStudioPercent(String value) {
    return '$value%';
  }
}
