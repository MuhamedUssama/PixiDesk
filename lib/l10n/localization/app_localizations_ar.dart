// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'بيكسي ديسك';

  @override
  String get pdfConverterTitle => 'محول PDF';

  @override
  String get pdfConverterSubtitle => 'تحويل الصور إلى ملفات PDF';

  @override
  String get addPhotos => 'إضافة صور';

  @override
  String get generatePdf => 'إنشاء ملف PDF';

  @override
  String get pageSize => 'حجم الصفحة';

  @override
  String get quality => 'الجودة';

  @override
  String get noImagesSelected => 'لم يتم اختيار صور';

  @override
  String get pdfGeneratedSuccess => 'تم إنشاء ملف PDF بنجاح';

  @override
  String get saveAs => 'حفظ باسم';

  @override
  String get original => 'الأصلي';

  @override
  String get a4 => 'A4';

  @override
  String get letter => 'Letter';

  @override
  String get high => 'عالية';

  @override
  String get medium => 'متوسطة';

  @override
  String get low => 'منخفضة';

  @override
  String get dropImageHere => 'اسحب الصورة هنا';

  @override
  String get orClickToUpload => 'أو اضغط للرفع';

  @override
  String get convert => 'تحويل';

  @override
  String get compress => 'ضغط';

  @override
  String get save => 'حفظ';

  @override
  String get selectFormat => 'اختر الصيغة';

  @override
  String get success => 'نجاح';

  @override
  String get error => 'خطأ';

  @override
  String get imageSaved => 'تم حفظ الصورة بنجاح';

  @override
  String get invalidPath => 'مسار غير صالح';

  @override
  String get dragAndDropImages => 'اسحب وأفلت الصور هنا للبدء';

  @override
  String get imageProcessingTitle => 'معالجة الصور';

  @override
  String get imageProcessingSubtitle => 'ضغط وتحويل الصور بكفاءة';

  @override
  String get pdfTools => 'أدوات PDF';

  @override
  String get pdfToolsSubtitle => 'تحويل، ضغط، إدارة ملفات PDF بكفاءة';

  @override
  String get appSubtitle => 'أداة متكاملة لمعالجة الصور والملفات PDF';

  @override
  String get compressPdf => 'ضغط PDF';

  @override
  String get compressPdfSubtitle => 'ضغط ملفات PDF بكفاءة';

  @override
  String get pdfCompression => 'ضغط PDF';

  @override
  String get compressionSuccess => 'تم ضغط ملف PDF بنجاح';

  @override
  String get invalidPdfFile => 'ملف PDF غير صالح';

  @override
  String get dragDropPdf => 'اسحب وأفلت ملف PDF هنا';

  @override
  String get selectPdf => 'اختر ملف PDF';

  @override
  String get removeFile => 'حذف الملف';

  @override
  String get compressionLevel => 'مستوى الضغط';

  @override
  String get compressionScreen => 'شاشة (72 dpi)';

  @override
  String get compressionEbook => 'كتاب إلكتروني (150 dpi)';

  @override
  String get compressionPrinter => 'طابعة (300 dpi)';

  @override
  String get compressionPrepress => 'طباعة احترافية (300 dpi)';

  @override
  String get compressionDefault => 'افتراضي';

  @override
  String get originalFile => 'الملف الأصلي';

  @override
  String get compressedFile => 'الملف المضغوط';

  @override
  String get quickSave => 'حفظ سريع';

  @override
  String get previewAndSave => 'معاينة وحفظ';

  @override
  String get size => 'الحجم';

  @override
  String get previewPdf => 'معاينة PDF';

  @override
  String get savePdf => 'حفظ PDF';

  @override
  String get pdfToImages => 'PDF إلى صور';

  @override
  String get pdfToImagesSubtitle => 'تحويل ملفات PDF إلى صور بكفاءة';

  @override
  String get pdfToImage => 'PDF إلى صور';

  @override
  String get conversionSettings => 'إعدادات التحويل';

  @override
  String get outputFormat => 'صيغة الإخراج';

  @override
  String get qualityDpi => 'الجودة (DPI)';

  @override
  String convertingPageOf(int currentPage, String totalPages) {
    return 'جاري تحويل الصفحة $currentPage من $totalPages';
  }

  @override
  String get filesSaved => 'تم حفظ الملفات بنجاح';

  @override
  String get conversionResult => 'نتيجة التحويل';

  @override
  String get saveAll => 'حفظ الكل';

  @override
  String get dragPdfHere => 'اسحب وأفلت ملف PDF هنا';

  @override
  String get selectPdfFile => 'اختر ملف PDF';

  @override
  String get preparing => 'جاري التحضير...';

  @override
  String get dpi1200Label => '1200 نقطة في البوصة (للمستخدمين المحترفين)';

  @override
  String get dpi1200Warning =>
      'ملاحظة: دقة 1200 تتطلب موارد عالية من النظام وقد تستغرق وقتاً طويلاً في المعالجة.';
}
