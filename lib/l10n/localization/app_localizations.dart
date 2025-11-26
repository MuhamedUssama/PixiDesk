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
