import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'PixiDesk'**
  String get appTitle;

  /// No description provided for @pdfConverterTitle.
  ///
  /// In en, this message translates to:
  /// **'PDF Converter'**
  String get pdfConverterTitle;

  /// No description provided for @pdfConverterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Convert images to PDF documents'**
  String get pdfConverterSubtitle;

  /// No description provided for @addPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add Photos'**
  String get addPhotos;

  /// No description provided for @generatePdf.
  ///
  /// In en, this message translates to:
  /// **'Generate PDF'**
  String get generatePdf;

  /// No description provided for @pageSize.
  ///
  /// In en, this message translates to:
  /// **'Page Size'**
  String get pageSize;

  /// No description provided for @quality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get quality;

  /// No description provided for @noImagesSelected.
  ///
  /// In en, this message translates to:
  /// **'No images selected'**
  String get noImagesSelected;

  /// No description provided for @pdfGeneratedSuccess.
  ///
  /// In en, this message translates to:
  /// **'PDF Generated Successfully'**
  String get pdfGeneratedSuccess;

  /// No description provided for @saveAs.
  ///
  /// In en, this message translates to:
  /// **'Save PDF As'**
  String get saveAs;

  /// No description provided for @original.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get original;

  /// No description provided for @a4.
  ///
  /// In en, this message translates to:
  /// **'A4'**
  String get a4;

  /// No description provided for @letter.
  ///
  /// In en, this message translates to:
  /// **'Letter'**
  String get letter;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @dropImageHere.
  ///
  /// In en, this message translates to:
  /// **'Drop Image Here'**
  String get dropImageHere;

  /// No description provided for @orClickToUpload.
  ///
  /// In en, this message translates to:
  /// **'Or click to upload'**
  String get orClickToUpload;

  /// No description provided for @convert.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get convert;

  /// No description provided for @compress.
  ///
  /// In en, this message translates to:
  /// **'Compress'**
  String get compress;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @selectFormat.
  ///
  /// In en, this message translates to:
  /// **'Select Format'**
  String get selectFormat;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @imageSaved.
  ///
  /// In en, this message translates to:
  /// **'Image saved successfully'**
  String get imageSaved;

  /// No description provided for @invalidPath.
  ///
  /// In en, this message translates to:
  /// **'Invalid path'**
  String get invalidPath;

  /// No description provided for @dragAndDropImages.
  ///
  /// In en, this message translates to:
  /// **'Drag and drop images here to start'**
  String get dragAndDropImages;

  /// No description provided for @imageProcessingTitle.
  ///
  /// In en, this message translates to:
  /// **'Image Processing'**
  String get imageProcessingTitle;

  /// No description provided for @imageProcessingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Compress and convert images efficiently'**
  String get imageProcessingSubtitle;

  /// No description provided for @pdfTools.
  ///
  /// In en, this message translates to:
  /// **'PDF Tools'**
  String get pdfTools;

  /// No description provided for @pdfToolsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Convert, compress, manage PDFs efficiently'**
  String get pdfToolsSubtitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your all-in-one desktop utility for image and PDF processing.'**
  String get appSubtitle;

  /// No description provided for @compressPdf.
  ///
  /// In en, this message translates to:
  /// **'Compress PDF'**
  String get compressPdf;

  /// No description provided for @compressPdfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Compress PDF files efficiently'**
  String get compressPdfSubtitle;

  /// No description provided for @pdfCompression.
  ///
  /// In en, this message translates to:
  /// **'PDF Compression'**
  String get pdfCompression;

  /// No description provided for @compressionSuccess.
  ///
  /// In en, this message translates to:
  /// **'PDF Compressed Successfully'**
  String get compressionSuccess;

  /// No description provided for @invalidPdfFile.
  ///
  /// In en, this message translates to:
  /// **'Invalid PDF file'**
  String get invalidPdfFile;

  /// No description provided for @dragDropPdf.
  ///
  /// In en, this message translates to:
  /// **'Drag and drop PDF here to start'**
  String get dragDropPdf;

  /// No description provided for @selectPdf.
  ///
  /// In en, this message translates to:
  /// **'Select PDF'**
  String get selectPdf;

  /// No description provided for @removeFile.
  ///
  /// In en, this message translates to:
  /// **'Remove File'**
  String get removeFile;

  /// No description provided for @compressionLevel.
  ///
  /// In en, this message translates to:
  /// **'Compression Level'**
  String get compressionLevel;

  /// No description provided for @compressionScreen.
  ///
  /// In en, this message translates to:
  /// **'Screen (72 dpi)'**
  String get compressionScreen;

  /// No description provided for @compressionEbook.
  ///
  /// In en, this message translates to:
  /// **'eBook (150 dpi)'**
  String get compressionEbook;

  /// No description provided for @compressionPrinter.
  ///
  /// In en, this message translates to:
  /// **'Printer (300 dpi)'**
  String get compressionPrinter;

  /// No description provided for @compressionPrepress.
  ///
  /// In en, this message translates to:
  /// **'Prepress (300 dpi)'**
  String get compressionPrepress;

  /// No description provided for @compressionDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get compressionDefault;

  /// No description provided for @originalFile.
  ///
  /// In en, this message translates to:
  /// **'Original File'**
  String get originalFile;

  /// No description provided for @compressedFile.
  ///
  /// In en, this message translates to:
  /// **'Compressed File'**
  String get compressedFile;

  /// No description provided for @quickSave.
  ///
  /// In en, this message translates to:
  /// **'Quick Save'**
  String get quickSave;

  /// No description provided for @previewAndSave.
  ///
  /// In en, this message translates to:
  /// **'Preview & Save'**
  String get previewAndSave;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @previewPdf.
  ///
  /// In en, this message translates to:
  /// **'Preview PDF'**
  String get previewPdf;

  /// No description provided for @savePdf.
  ///
  /// In en, this message translates to:
  /// **'Save PDF'**
  String get savePdf;

  /// No description provided for @pdfToImages.
  ///
  /// In en, this message translates to:
  /// **'PDF To Images'**
  String get pdfToImages;

  /// No description provided for @pdfToImagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Convert PDF documents to images'**
  String get pdfToImagesSubtitle;

  /// No description provided for @pdfToImage.
  ///
  /// In en, this message translates to:
  /// **'PDF to Image'**
  String get pdfToImage;

  /// No description provided for @conversionSettings.
  ///
  /// In en, this message translates to:
  /// **'Conversion Settings'**
  String get conversionSettings;

  /// No description provided for @outputFormat.
  ///
  /// In en, this message translates to:
  /// **'Output Format'**
  String get outputFormat;

  /// No description provided for @qualityDpi.
  ///
  /// In en, this message translates to:
  /// **'Quality (DPI)'**
  String get qualityDpi;

  /// No description provided for @convertingPageOf.
  ///
  /// In en, this message translates to:
  /// **'Converting page {currentPage} of {totalPages}'**
  String convertingPageOf(int currentPage, String totalPages);

  /// No description provided for @filesSaved.
  ///
  /// In en, this message translates to:
  /// **'Files saved successfully'**
  String get filesSaved;

  /// No description provided for @conversionResult.
  ///
  /// In en, this message translates to:
  /// **'Conversion Result'**
  String get conversionResult;

  /// No description provided for @saveAll.
  ///
  /// In en, this message translates to:
  /// **'Save All'**
  String get saveAll;

  /// No description provided for @dragPdfHere.
  ///
  /// In en, this message translates to:
  /// **'Drag PDF Here'**
  String get dragPdfHere;

  /// No description provided for @selectPdfFile.
  ///
  /// In en, this message translates to:
  /// **'Select PDF File'**
  String get selectPdfFile;

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing...'**
  String get preparing;

  /// No description provided for @dpi1200Label.
  ///
  /// In en, this message translates to:
  /// **'1200 DPI (For Professional Users)'**
  String get dpi1200Label;

  /// No description provided for @dpi1200Warning.
  ///
  /// In en, this message translates to:
  /// **'Note: 1200 DPI is resource-intensive and may take a significant amount of time to process.'**
  String get dpi1200Warning;

  /// No description provided for @deleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected'**
  String get deleteSelected;

  /// No description provided for @rotateRight.
  ///
  /// In en, this message translates to:
  /// **'Rotate Right'**
  String get rotateRight;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @gridView.
  ///
  /// In en, this message translates to:
  /// **'Grid View'**
  String get gridView;

  /// No description provided for @saveAsZip.
  ///
  /// In en, this message translates to:
  /// **'Save As Zip'**
  String get saveAsZip;

  /// No description provided for @downloadOptions.
  ///
  /// In en, this message translates to:
  /// **'Download Options'**
  String get downloadOptions;

  /// No description provided for @downloadOptionsMessage.
  ///
  /// In en, this message translates to:
  /// **'How would you like to save the images?'**
  String get downloadOptionsMessage;

  /// No description provided for @combinedFolder.
  ///
  /// In en, this message translates to:
  /// **'Combined Folder'**
  String get combinedFolder;

  /// No description provided for @separateZips.
  ///
  /// In en, this message translates to:
  /// **'Separate ZIPs'**
  String get separateZips;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @imageAddFiles.
  ///
  /// In en, this message translates to:
  /// **'Add images'**
  String get imageAddFiles;

  /// No description provided for @imageAddFolder.
  ///
  /// In en, this message translates to:
  /// **'Add folder'**
  String get imageAddFolder;

  /// No description provided for @imageAddRecursive.
  ///
  /// In en, this message translates to:
  /// **'Include subfolders'**
  String get imageAddRecursive;

  /// No description provided for @imagePaste.
  ///
  /// In en, this message translates to:
  /// **'Paste images or file paths'**
  String get imagePaste;

  /// No description provided for @imageQueue.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get imageQueue;

  /// No description provided for @imageSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get imageSettings;

  /// No description provided for @imagePreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get imagePreview;

  /// No description provided for @imagePreviewHint.
  ///
  /// In en, this message translates to:
  /// **'Preview is a scaled still image. Export preserves supported animation.'**
  String get imagePreviewHint;

  /// No description provided for @imageBeforeAfter.
  ///
  /// In en, this message translates to:
  /// **'Before / after'**
  String get imageBeforeAfter;

  /// No description provided for @imageAfter.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get imageAfter;

  /// No description provided for @imageFit.
  ///
  /// In en, this message translates to:
  /// **'Fit view'**
  String get imageFit;

  /// No description provided for @imagePreviewError.
  ///
  /// In en, this message translates to:
  /// **'Unable to display this image. Try importing it again.'**
  String get imagePreviewError;

  /// No description provided for @imageExport.
  ///
  /// In en, this message translates to:
  /// **'Export image'**
  String get imageExport;

  /// No description provided for @imageExportAll.
  ///
  /// In en, this message translates to:
  /// **'Export queue'**
  String get imageExportAll;

  /// No description provided for @imageExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Save processed image'**
  String get imageExportTitle;

  /// No description provided for @imageOutputFolder.
  ///
  /// In en, this message translates to:
  /// **'Output folder'**
  String get imageOutputFolder;

  /// No description provided for @imageRetryFailed.
  ///
  /// In en, this message translates to:
  /// **'Retry failed or cancelled'**
  String get imageRetryFailed;

  /// No description provided for @imageClearQueue.
  ///
  /// In en, this message translates to:
  /// **'Clear queue'**
  String get imageClearQueue;

  /// No description provided for @imageRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove image'**
  String get imageRemove;

  /// No description provided for @imagePause.
  ///
  /// In en, this message translates to:
  /// **'Pause after current image'**
  String get imagePause;

  /// No description provided for @imageResume.
  ///
  /// In en, this message translates to:
  /// **'Resume queue'**
  String get imageResume;

  /// No description provided for @imageCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get imageCancelled;

  /// No description provided for @imagePending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get imagePending;

  /// No description provided for @imageRunning.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get imageRunning;

  /// No description provided for @imageCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get imageCompleted;

  /// No description provided for @imageFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get imageFailed;

  /// No description provided for @imageSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get imageSkipped;

  /// No description provided for @imageImporting.
  ///
  /// In en, this message translates to:
  /// **'Inspecting images…'**
  String get imageImporting;

  /// No description provided for @imageChoosing.
  ///
  /// In en, this message translates to:
  /// **'Choosing destination…'**
  String get imageChoosing;

  /// No description provided for @imageProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing images…'**
  String get imageProcessing;

  /// No description provided for @imagePreviewing.
  ///
  /// In en, this message translates to:
  /// **'Preparing preview…'**
  String get imagePreviewing;

  /// No description provided for @imageRecognizing.
  ///
  /// In en, this message translates to:
  /// **'Recognizing text locally…'**
  String get imageRecognizing;

  /// No description provided for @imageRemovingBackground.
  ///
  /// In en, this message translates to:
  /// **'Removing background locally…'**
  String get imageRemovingBackground;

  /// No description provided for @imageResize.
  ///
  /// In en, this message translates to:
  /// **'Resize and crop'**
  String get imageResize;

  /// No description provided for @imageWidth.
  ///
  /// In en, this message translates to:
  /// **'Width (pixels)'**
  String get imageWidth;

  /// No description provided for @imageHeight.
  ///
  /// In en, this message translates to:
  /// **'Height (pixels)'**
  String get imageHeight;

  /// No description provided for @imageKeepOriginal.
  ///
  /// In en, this message translates to:
  /// **'Auto / original'**
  String get imageKeepOriginal;

  /// No description provided for @imageResizeFit.
  ///
  /// In en, this message translates to:
  /// **'Fit within bounds'**
  String get imageResizeFit;

  /// No description provided for @imageResizeFill.
  ///
  /// In en, this message translates to:
  /// **'Fill and crop'**
  String get imageResizeFill;

  /// No description provided for @imageResizeStretch.
  ///
  /// In en, this message translates to:
  /// **'Stretch to size'**
  String get imageResizeStretch;

  /// No description provided for @imageAllowUpscale.
  ///
  /// In en, this message translates to:
  /// **'Allow upscaling'**
  String get imageAllowUpscale;

  /// No description provided for @imageCropLeft.
  ///
  /// In en, this message translates to:
  /// **'Crop left (%)'**
  String get imageCropLeft;

  /// No description provided for @imageCropTop.
  ///
  /// In en, this message translates to:
  /// **'Crop top (%)'**
  String get imageCropTop;

  /// No description provided for @imageCropWidth.
  ///
  /// In en, this message translates to:
  /// **'Crop width (%)'**
  String get imageCropWidth;

  /// No description provided for @imageCropHeight.
  ///
  /// In en, this message translates to:
  /// **'Crop height (%)'**
  String get imageCropHeight;

  /// No description provided for @imageSquareCrop.
  ///
  /// In en, this message translates to:
  /// **'Center square crop'**
  String get imageSquareCrop;

  /// No description provided for @imageResetCrop.
  ///
  /// In en, this message translates to:
  /// **'Reset crop'**
  String get imageResetCrop;

  /// No description provided for @imageRotate.
  ///
  /// In en, this message translates to:
  /// **'Rotate 90°'**
  String get imageRotate;

  /// No description provided for @imageFlipHorizontal.
  ///
  /// In en, this message translates to:
  /// **'Flip horizontally'**
  String get imageFlipHorizontal;

  /// No description provided for @imageFlipVertical.
  ///
  /// In en, this message translates to:
  /// **'Flip vertically'**
  String get imageFlipVertical;

  /// No description provided for @imageAdjustments.
  ///
  /// In en, this message translates to:
  /// **'Color adjustments'**
  String get imageAdjustments;

  /// No description provided for @imageBrightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get imageBrightness;

  /// No description provided for @imageContrast.
  ///
  /// In en, this message translates to:
  /// **'Contrast'**
  String get imageContrast;

  /// No description provided for @imageSaturation.
  ///
  /// In en, this message translates to:
  /// **'Saturation'**
  String get imageSaturation;

  /// No description provided for @imageGrayscale.
  ///
  /// In en, this message translates to:
  /// **'Grayscale'**
  String get imageGrayscale;

  /// No description provided for @imageReset.
  ///
  /// In en, this message translates to:
  /// **'Reset settings'**
  String get imageReset;

  /// No description provided for @imageUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get imageUndo;

  /// No description provided for @imageRedo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get imageRedo;

  /// No description provided for @imageCompression.
  ///
  /// In en, this message translates to:
  /// **'Encoding and compression'**
  String get imageCompression;

  /// No description provided for @imageLossless.
  ///
  /// In en, this message translates to:
  /// **'Lossless WebP'**
  String get imageLossless;

  /// No description provided for @imageLosslessHint.
  ///
  /// In en, this message translates to:
  /// **'PNG uses lossless optimization. Quality applies to JPEG and lossy WebP.'**
  String get imageLosslessHint;

  /// No description provided for @imageTargetSize.
  ///
  /// In en, this message translates to:
  /// **'Target size (KB, optional)'**
  String get imageTargetSize;

  /// No description provided for @imageMinQuality.
  ///
  /// In en, this message translates to:
  /// **'Minimum quality'**
  String get imageMinQuality;

  /// No description provided for @imageTargetHint.
  ///
  /// In en, this message translates to:
  /// **'Set a file size goal. If it cannot be reached, the result will tell you.'**
  String get imageTargetHint;

  /// No description provided for @imageMetadata.
  ///
  /// In en, this message translates to:
  /// **'Metadata and animation'**
  String get imageMetadata;

  /// No description provided for @imageMetadataRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove EXIF and text metadata'**
  String get imageMetadataRemove;

  /// No description provided for @imageMetadataPreserve.
  ///
  /// In en, this message translates to:
  /// **'Preserve supported metadata'**
  String get imageMetadataPreserve;

  /// No description provided for @imageMetadataHint.
  ///
  /// In en, this message translates to:
  /// **'Orientation is normalized. ICC color profiles are retained where the format supports them; exact metadata preservation varies by codec.'**
  String get imageMetadataHint;

  /// No description provided for @imageAnimationPreserve.
  ///
  /// In en, this message translates to:
  /// **'Preserve supported animation'**
  String get imageAnimationPreserve;

  /// No description provided for @imageAnimationFirst.
  ///
  /// In en, this message translates to:
  /// **'Export first frame only'**
  String get imageAnimationFirst;

  /// No description provided for @imageAlphaHint.
  ///
  /// In en, this message translates to:
  /// **'JPEG and BMP flatten transparency onto the selected background. Unsupported animation is flattened with a result notice.'**
  String get imageAlphaHint;

  /// No description provided for @imageBackground.
  ///
  /// In en, this message translates to:
  /// **'Background color (RRGGBB)'**
  String get imageBackground;

  /// No description provided for @imageIconPack.
  ///
  /// In en, this message translates to:
  /// **'ICO pack: 16, 32, 48, 64, 128, 256 px'**
  String get imageIconPack;

  /// No description provided for @imageWatermark.
  ///
  /// In en, this message translates to:
  /// **'Watermark'**
  String get imageWatermark;

  /// No description provided for @imageWatermarkText.
  ///
  /// In en, this message translates to:
  /// **'Watermark text (Arabic or English)'**
  String get imageWatermarkText;

  /// No description provided for @imageWatermarkLogo.
  ///
  /// In en, this message translates to:
  /// **'Choose watermark image'**
  String get imageWatermarkLogo;

  /// No description provided for @imageWatermarkRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove watermark image'**
  String get imageWatermarkRemove;

  /// No description provided for @imageOpacity.
  ///
  /// In en, this message translates to:
  /// **'Opacity'**
  String get imageOpacity;

  /// No description provided for @imageWatermarkScale.
  ///
  /// In en, this message translates to:
  /// **'Relative watermark size'**
  String get imageWatermarkScale;

  /// No description provided for @imageTopLeft.
  ///
  /// In en, this message translates to:
  /// **'Top left'**
  String get imageTopLeft;

  /// No description provided for @imageTopCenter.
  ///
  /// In en, this message translates to:
  /// **'Top center'**
  String get imageTopCenter;

  /// No description provided for @imageTopRight.
  ///
  /// In en, this message translates to:
  /// **'Top right'**
  String get imageTopRight;

  /// No description provided for @imageCenterLeft.
  ///
  /// In en, this message translates to:
  /// **'Center left'**
  String get imageCenterLeft;

  /// No description provided for @imageCenter.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get imageCenter;

  /// No description provided for @imageCenterRight.
  ///
  /// In en, this message translates to:
  /// **'Center right'**
  String get imageCenterRight;

  /// No description provided for @imageBottomLeft.
  ///
  /// In en, this message translates to:
  /// **'Bottom left'**
  String get imageBottomLeft;

  /// No description provided for @imageBottomCenter.
  ///
  /// In en, this message translates to:
  /// **'Bottom center'**
  String get imageBottomCenter;

  /// No description provided for @imageBottomRight.
  ///
  /// In en, this message translates to:
  /// **'Bottom right'**
  String get imageBottomRight;

  /// No description provided for @imageNaming.
  ///
  /// In en, this message translates to:
  /// **'Output naming and conflicts'**
  String get imageNaming;

  /// No description provided for @imageNamePattern.
  ///
  /// In en, this message translates to:
  /// **'Name pattern'**
  String get imageNamePattern;

  /// No description provided for @imageNamePatternHint.
  ///
  /// In en, this message translates to:
  /// **'Tokens: \'{\'name\'}\', \'{\'index\'}\', \'{\'width\'}\', \'{\'height\'}\'. Dimensions reflect the final edits.'**
  String get imageNamePatternHint;

  /// No description provided for @imageConflictRename.
  ///
  /// In en, this message translates to:
  /// **'Rename if a file exists'**
  String get imageConflictRename;

  /// No description provided for @imageConflictSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip existing files'**
  String get imageConflictSkip;

  /// No description provided for @imageConflictReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace existing files'**
  String get imageConflictReplace;

  /// No description provided for @imageReplaceHint.
  ///
  /// In en, this message translates to:
  /// **'Replace overwrites existing exports. Original source files are always protected.'**
  String get imageReplaceHint;

  /// No description provided for @imageOpen.
  ///
  /// In en, this message translates to:
  /// **'Open result'**
  String get imageOpen;

  /// No description provided for @imageReveal.
  ///
  /// In en, this message translates to:
  /// **'Show in folder'**
  String get imageReveal;

  /// No description provided for @imageNoSavings.
  ///
  /// In en, this message translates to:
  /// **'The output is not smaller; requested edits and metadata settings were retained.'**
  String get imageNoSavings;

  /// No description provided for @imageUnchanged.
  ///
  /// In en, this message translates to:
  /// **'The original was already smaller; an unchanged copy was saved.'**
  String get imageUnchanged;

  /// No description provided for @imageTargetNotReached.
  ///
  /// In en, this message translates to:
  /// **'The target size could not be reached within the quality limit.'**
  String get imageTargetNotReached;

  /// No description provided for @imageAnimationFlattened.
  ///
  /// In en, this message translates to:
  /// **'Only the first frame was exported.'**
  String get imageAnimationFlattened;

  /// No description provided for @imageAlphaFlattened.
  ///
  /// In en, this message translates to:
  /// **'Transparency was flattened onto the selected background.'**
  String get imageAlphaFlattened;

  /// No description provided for @imageMetadataLimited.
  ///
  /// In en, this message translates to:
  /// **'This codec preserves only limited metadata.'**
  String get imageMetadataLimited;

  /// No description provided for @imagePresets.
  ///
  /// In en, this message translates to:
  /// **'Presets and recipes'**
  String get imagePresets;

  /// No description provided for @imagePresetSharing.
  ///
  /// In en, this message translates to:
  /// **'JPEG for sharing'**
  String get imagePresetSharing;

  /// No description provided for @imagePresetTransparent.
  ///
  /// In en, this message translates to:
  /// **'Transparent PNG'**
  String get imagePresetTransparent;

  /// No description provided for @imagePresetStore.
  ///
  /// In en, this message translates to:
  /// **'Store photos: 1600 px'**
  String get imagePresetStore;

  /// No description provided for @imagePresetIcon.
  ///
  /// In en, this message translates to:
  /// **'Desktop icon pack'**
  String get imagePresetIcon;

  /// No description provided for @imageSavePreset.
  ///
  /// In en, this message translates to:
  /// **'Save current preset'**
  String get imageSavePreset;

  /// No description provided for @imagePresetName.
  ///
  /// In en, this message translates to:
  /// **'Preset name'**
  String get imagePresetName;

  /// No description provided for @imageImportPreset.
  ///
  /// In en, this message translates to:
  /// **'Import preset JSON'**
  String get imageImportPreset;

  /// No description provided for @imageExportPreset.
  ///
  /// In en, this message translates to:
  /// **'Export preset JSON'**
  String get imageExportPreset;

  /// No description provided for @imageDeletePreset.
  ///
  /// In en, this message translates to:
  /// **'Delete preset'**
  String get imageDeletePreset;

  /// No description provided for @imageHistory.
  ///
  /// In en, this message translates to:
  /// **'Processing history'**
  String get imageHistory;

  /// No description provided for @imageClearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get imageClearHistory;

  /// No description provided for @imageHistoryHint.
  ///
  /// In en, this message translates to:
  /// **'Stores up to 200 local results. Clearing history never deletes your files.'**
  String get imageHistoryHint;

  /// No description provided for @imageRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore source and recipe'**
  String get imageRestore;

  /// No description provided for @imageEmptyHistory.
  ///
  /// In en, this message translates to:
  /// **'No saved results yet.'**
  String get imageEmptyHistory;

  /// No description provided for @imageWatch.
  ///
  /// In en, this message translates to:
  /// **'Watch folder'**
  String get imageWatch;

  /// No description provided for @imageStopWatch.
  ///
  /// In en, this message translates to:
  /// **'Stop watching'**
  String get imageStopWatch;

  /// No description provided for @imageWatchInput.
  ///
  /// In en, this message translates to:
  /// **'Choose input folder to watch'**
  String get imageWatchInput;

  /// No description provided for @imageWatchHint.
  ///
  /// In en, this message translates to:
  /// **'While this page is open, new or changed stable files in the selected folder are processed with a snapshot of the current settings. Subfolders are excluded. Input and output folders must not overlap.'**
  String get imageWatchHint;

  /// No description provided for @imageTools.
  ///
  /// In en, this message translates to:
  /// **'Local tools'**
  String get imageTools;

  /// No description provided for @imageOcr.
  ///
  /// In en, this message translates to:
  /// **'Extract text (OCR)'**
  String get imageOcr;

  /// No description provided for @imageOcrLanguage.
  ///
  /// In en, this message translates to:
  /// **'OCR language'**
  String get imageOcrLanguage;

  /// No description provided for @imageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get imageEnglish;

  /// No description provided for @imageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get imageArabic;

  /// No description provided for @imageArabicEnglish.
  ///
  /// In en, this message translates to:
  /// **'Arabic and English'**
  String get imageArabicEnglish;

  /// No description provided for @imageOcrHint.
  ///
  /// In en, this message translates to:
  /// **'Requires a local Tesseract installation with the selected language data. Images stay on your device.'**
  String get imageOcrHint;

  /// No description provided for @imageCutout.
  ///
  /// In en, this message translates to:
  /// **'Remove background'**
  String get imageCutout;

  /// No description provided for @imageCutoutHint.
  ///
  /// In en, this message translates to:
  /// **'Requires local rembg and a preinstalled u2net.onnx model in U2NET_HOME. No model is downloaded automatically.'**
  String get imageCutoutHint;

  /// No description provided for @imageCopyText.
  ///
  /// In en, this message translates to:
  /// **'Copy text'**
  String get imageCopyText;

  /// No description provided for @imageSaveText.
  ///
  /// In en, this message translates to:
  /// **'Save text'**
  String get imageSaveText;

  /// No description provided for @imageToPdf.
  ///
  /// In en, this message translates to:
  /// **'Send images to PDF'**
  String get imageToPdf;

  /// No description provided for @imageFromPdf.
  ///
  /// In en, this message translates to:
  /// **'Process these images'**
  String get imageFromPdf;

  /// No description provided for @imageResourceHint.
  ///
  /// In en, this message translates to:
  /// **'Limits: 64 MiB input, 24 MP per frame, 32 MP total, 120 frames and 1000 queue items. Files are processed sequentially.'**
  String get imageResourceHint;

  /// No description provided for @imageInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'The file is missing, unreadable, or not a valid image.'**
  String get imageInvalidInput;

  /// No description provided for @imageUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This image format is not supported.'**
  String get imageUnsupported;

  /// No description provided for @imageResourceLimit.
  ///
  /// In en, this message translates to:
  /// **'The image or queue exceeds the supported resource limits.'**
  String get imageResourceLimit;

  /// No description provided for @imageInvalidOptions.
  ///
  /// In en, this message translates to:
  /// **'Check dimensions, crop, quality, naming tokens and folder settings.'**
  String get imageInvalidOptions;

  /// No description provided for @imagePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Unable to read or write this location. Choose another folder.'**
  String get imagePermissionDenied;

  /// No description provided for @imageDestinationConflict.
  ///
  /// In en, this message translates to:
  /// **'The destination conflicts with a source or another output. Choose another name.'**
  String get imageDestinationConflict;

  /// No description provided for @imageSourceChanged.
  ///
  /// In en, this message translates to:
  /// **'The source changed since import. Import it again before processing.'**
  String get imageSourceChanged;

  /// No description provided for @imageEncodeFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to process or save the image. Your source has not been replaced.'**
  String get imageEncodeFailed;

  /// No description provided for @imageInvalidPreset.
  ///
  /// In en, this message translates to:
  /// **'This preset file is invalid or uses an unsupported version.'**
  String get imageInvalidPreset;

  /// No description provided for @imageStorageFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to load or save the local workspace. Existing saved data was preserved.'**
  String get imageStorageFailed;

  /// No description provided for @imageToolUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The required local tool or model is not installed or cannot be found. Check the tool requirements.'**
  String get imageToolUnavailable;

  /// No description provided for @imageToolFailed.
  ///
  /// In en, this message translates to:
  /// **'The local tool failed or timed out. Check the installation and language/model files.'**
  String get imageToolFailed;

  /// No description provided for @imageQueueCount.
  ///
  /// In en, this message translates to:
  /// **'{count} images'**
  String imageQueueCount(int count);

  /// No description provided for @imageProgressCount.
  ///
  /// In en, this message translates to:
  /// **'{finished} / {total} processed'**
  String imageProgressCount(int finished, int total);

  /// No description provided for @imageDimensions.
  ///
  /// In en, this message translates to:
  /// **'{width} × {height} px · {frames} frame(s)'**
  String imageDimensions(int width, int height, int frames);

  /// No description provided for @imageResultStats.
  ///
  /// In en, this message translates to:
  /// **'{before} → {after} · {savings}% saved'**
  String imageResultStats(String before, String after, String savings);

  /// No description provided for @imageSettingValue.
  ///
  /// In en, this message translates to:
  /// **'{label}: {value}'**
  String imageSettingValue(String label, String value);

  /// No description provided for @imageWatchingPath.
  ///
  /// In en, this message translates to:
  /// **'Watching: {path}'**
  String imageWatchingPath(String path);

  /// No description provided for @imageFileSize.
  ///
  /// In en, this message translates to:
  /// **'{value} {unit}'**
  String imageFileSize(String value, String unit);

  /// No description provided for @imageBytesUnit.
  ///
  /// In en, this message translates to:
  /// **'B'**
  String get imageBytesUnit;

  /// No description provided for @imageKbUnit.
  ///
  /// In en, this message translates to:
  /// **'KiB'**
  String get imageKbUnit;

  /// No description provided for @imageMbUnit.
  ///
  /// In en, this message translates to:
  /// **'MiB'**
  String get imageMbUnit;

  /// No description provided for @imageAssetScales.
  ///
  /// In en, this message translates to:
  /// **'Export PNG assets: 1x / 2x / 3x'**
  String get imageAssetScales;

  /// No description provided for @imageInterrupted.
  ///
  /// In en, this message translates to:
  /// **'Interrupted or pending — restore to retry'**
  String get imageInterrupted;

  /// No description provided for @imageRenamePreset.
  ///
  /// In en, this message translates to:
  /// **'Rename preset'**
  String get imageRenamePreset;

  /// No description provided for @imageDuplicatePreset.
  ///
  /// In en, this message translates to:
  /// **'Duplicate preset'**
  String get imageDuplicatePreset;

  /// No description provided for @imageLastExport.
  ///
  /// In en, this message translates to:
  /// **'Last saved export'**
  String get imageLastExport;

  /// No description provided for @imageStudioTitle.
  ///
  /// In en, this message translates to:
  /// **'Image studio'**
  String get imageStudioTitle;

  /// No description provided for @imageStudioEdit.
  ///
  /// In en, this message translates to:
  /// **'Adjust'**
  String get imageStudioEdit;

  /// No description provided for @imageStudioExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get imageStudioExport;

  /// No description provided for @imageStudioPresets.
  ///
  /// In en, this message translates to:
  /// **'Presets'**
  String get imageStudioPresets;

  /// No description provided for @imageStudioInspector.
  ///
  /// In en, this message translates to:
  /// **'Make it yours'**
  String get imageStudioInspector;

  /// No description provided for @imageStudioInspectorHint.
  ///
  /// In en, this message translates to:
  /// **'Fine-tune your next export.'**
  String get imageStudioInspectorHint;

  /// No description provided for @imageStudioLibrary.
  ///
  /// In en, this message translates to:
  /// **'Your images'**
  String get imageStudioLibrary;

  /// No description provided for @imageStudioQueueEmpty.
  ///
  /// In en, this message translates to:
  /// **'A little quiet here'**
  String get imageStudioQueueEmpty;

  /// No description provided for @imageStudioQueuePrompt.
  ///
  /// In en, this message translates to:
  /// **'Your images will appear here.'**
  String get imageStudioQueuePrompt;

  /// No description provided for @imageStudioEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'A fresh canvas.'**
  String get imageStudioEmptyTitle;

  /// No description provided for @imageStudioEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Drop your images here to start. A single shot or a whole collection.'**
  String get imageStudioEmptyHint;

  /// No description provided for @imageStudioLocal.
  ///
  /// In en, this message translates to:
  /// **'Processed on your device'**
  String get imageStudioLocal;

  /// No description provided for @imageStudioReady.
  ///
  /// In en, this message translates to:
  /// **'Ready when you are'**
  String get imageStudioReady;

  /// No description provided for @imageStudioFit.
  ///
  /// In en, this message translates to:
  /// **'Fit'**
  String get imageStudioFit;

  /// No description provided for @imageStudioCompare.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get imageStudioCompare;

  /// No description provided for @imageStudioResult.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get imageStudioResult;

  /// No description provided for @imageStudioZoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get imageStudioZoomIn;

  /// No description provided for @imageStudioZoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get imageStudioZoomOut;

  /// No description provided for @imageStudioExportAll.
  ///
  /// In en, this message translates to:
  /// **'Export all'**
  String get imageStudioExportAll;

  /// No description provided for @imageStudioMore.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get imageStudioMore;

  /// No description provided for @imageStudioImportOptions.
  ///
  /// In en, this message translates to:
  /// **'Import options'**
  String get imageStudioImportOptions;

  /// No description provided for @imageStudioPreviewAction.
  ///
  /// In en, this message translates to:
  /// **'Update preview'**
  String get imageStudioPreviewAction;

  /// No description provided for @imageStudioSingleExport.
  ///
  /// In en, this message translates to:
  /// **'Export image'**
  String get imageStudioSingleExport;

  /// No description provided for @imageStudioQuickPresets.
  ///
  /// In en, this message translates to:
  /// **'A good starting point'**
  String get imageStudioQuickPresets;

  /// No description provided for @imageStudioSavedPresets.
  ///
  /// In en, this message translates to:
  /// **'Your recipes'**
  String get imageStudioSavedPresets;

  /// No description provided for @imageStudioSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected image'**
  String get imageStudioSelected;

  /// No description provided for @imageStudioInfo.
  ///
  /// In en, this message translates to:
  /// **'Image information'**
  String get imageStudioInfo;

  /// No description provided for @imageStudioMoreFormats.
  ///
  /// In en, this message translates to:
  /// **'More formats'**
  String get imageStudioMoreFormats;

  /// No description provided for @imageStudioPercent.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String imageStudioPercent(String value);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
