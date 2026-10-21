import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:image/image.dart' as image_codec;
import '../../domain/entities/pdf_processing_failure.dart';
import 'pdfium_bindings.dart';

/// Only loaded by the helper process. Flutter never invokes PDFium in-process.
class PdfiumDocument {
  final PdfiumBindings bindings;
  final FPDF_DOCUMENT document;
  final Pointer<FPDF_FORMFILLINFO> _formInfo;
  late final FPDF_FORMHANDLE _formEnvironment;
  bool _closed = false;

  PdfiumDocument._(this.bindings, this.document, this._formInfo) {
    if (bindings.FPDF_GetFormType(document) >= 2) {
      bindings.FPDF_CloseDocument(document);
      calloc.free(_formInfo);
      throw const PdfProcessingFailure(
        PdfProcessingFailureCode.invalidDocument,
      );
    }
    _formInfo.ref.version = 2;
    _formEnvironment = bindings.FPDFDOC_InitFormFillEnvironment(
      document,
      _formInfo,
    );
  }

  factory PdfiumDocument.open(
    PdfiumBindings bindings,
    String sourcePath, {
    String? password,
  }) {
    final nativePath = sourcePath.toNativeUtf8();
    final nativePassword = password?.toNativeUtf8();
    try {
      final document = bindings.FPDF_LoadDocument(
        nativePath.cast(),
        nativePassword?.cast() ?? nullptr,
      );
      if (document == nullptr) {
        throw PdfProcessingFailure(
          bindings.FPDF_GetLastError() == 4
              ? PdfProcessingFailureCode.passwordRequired
              : PdfProcessingFailureCode.invalidDocument,
        );
      }
      return PdfiumDocument._(bindings, document, calloc<FPDF_FORMFILLINFO>());
    } finally {
      calloc.free(nativePath);
      if (nativePassword != null) calloc.free(nativePassword);
    }
  }

  List<Map<String, double>> inspect() {
    final pageCount = bindings.FPDF_GetPageCount(document);
    if (pageCount < 1 || pageCount > 5000) {
      throw const PdfProcessingFailure(PdfProcessingFailureCode.resourceLimit);
    }
    return List.generate(pageCount, (pageIndex) {
      final page = bindings.FPDF_LoadPage(document, pageIndex);
      if (page == nullptr) {
        throw const PdfProcessingFailure(
          PdfProcessingFailureCode.invalidDocument,
        );
      }
      try {
        final width = bindings.FPDF_GetPageWidthF(page);
        final height = bindings.FPDF_GetPageHeightF(page);
        if (!width.isFinite || !height.isFinite || width <= 0 || height <= 0) {
          throw const PdfProcessingFailure(
            PdfProcessingFailureCode.invalidDocument,
          );
        }
        return {'width': width, 'height': height};
      } finally {
        bindings.FPDF_ClosePage(page);
      }
    });
  }

  Map<String, Object> render(
    int pageIndex,
    int dpi,
    String format,
    String outputPath, {
    int? maxDimension,
    bool includePreviewAssets = true,
  }) {
    if (!['png', 'jpg', 'tiff'].contains(format) || dpi < 72 || dpi > 1200) {
      throw const PdfProcessingFailure(
        PdfProcessingFailureCode.invalidSettings,
      );
    }
    final page = bindings.FPDF_LoadPage(document, pageIndex);
    if (page == nullptr) {
      throw const PdfProcessingFailure(
        PdfProcessingFailureCode.invalidDocument,
      );
    }
    FPDF_BITMAP bitmap = nullptr;
    var formPageLoaded = false;
    try {
      var width = (bindings.FPDF_GetPageWidthF(page) * dpi / 72).ceil();
      var height = (bindings.FPDF_GetPageHeightF(page) * dpi / 72).ceil();
      if (maxDimension != null) {
        if (maxDimension < 1 || maxDimension > 1400) {
          throw const PdfProcessingFailure(
            PdfProcessingFailureCode.invalidSettings,
          );
        }
        final longestEdge = width > height ? width : height;
        if (longestEdge > maxDimension) {
          final scale = maxDimension / longestEdge;
          width = (width * scale).round().clamp(1, maxDimension);
          height = (height * scale).round().clamp(1, maxDimension);
        }
      }
      if (width <= 0 || height <= 0 || width * height > 160000000) {
        throw const PdfProcessingFailure(
          PdfProcessingFailureCode.resourceLimit,
        );
      }
      bitmap = bindings.FPDFBitmap_Create(width, height, 1);
      if (bitmap == nullptr) {
        throw const PdfProcessingFailure(
          PdfProcessingFailureCode.resourceLimit,
        );
      }
      bindings.FPDFBitmap_FillRect(bitmap, 0, 0, width, height, 0xffffffff);
      if (_formEnvironment != nullptr) {
        bindings.FORM_OnAfterLoadPage(page, _formEnvironment);
        formPageLoaded = true;
      }
      const renderFlags =
          1; // FPDF_ANNOT; widget fields are painted by FFLDraw.
      bindings.FPDF_RenderPageBitmap(
        bitmap,
        page,
        0,
        0,
        width,
        height,
        0,
        renderFlags,
      );
      if (_formEnvironment != nullptr) {
        bindings.FPDF_FFLDraw(
          _formEnvironment,
          bitmap,
          page,
          0,
          0,
          width,
          height,
          0,
          renderFlags,
        );
      }
      final stride = bindings.FPDFBitmap_GetStride(bitmap);
      final pixels = bindings.FPDFBitmap_GetBuffer(
        bitmap,
      ).cast<Uint8>().asTypedList(stride * height);
      final rasterImage = image_codec.Image.fromBytes(
        width: width,
        height: height,
        bytes: pixels.buffer,
        bytesOffset: pixels.offsetInBytes,
        rowStride: stride,
        numChannels: 4,
        order: image_codec.ChannelOrder.bgra,
      );
      // BGRA bitmap with an opaque white fill preserves a defined alpha channel.
      final encodedBytes = switch (format) {
        'png' => image_codec.encodePng(rasterImage, level: 3),
        'tiff' => image_codec.encodeTiff(rasterImage),
        _ => image_codec.encodeJpg(rasterImage, quality: 95),
      };
      final stagingFile = File('$outputPath.partial');
      try {
        stagingFile.writeAsBytesSync(encodedBytes);
        if (File(outputPath).existsSync()) {
          throw const PdfProcessingFailure(
            PdfProcessingFailureCode.destinationConflict,
          );
        }
        stagingFile.renameSync(outputPath);
      } finally {
        if (stagingFile.existsSync()) stagingFile.deleteSync();
      }
      if (!includePreviewAssets) {
        return {'path': outputPath, 'width': width, 'height': height};
      }
      final previewPath = '$outputPath.preview.png';
      final thumbnailPath = '$outputPath.thumb.png';
      final previewScale = 1400 / (width > height ? width : height);
      final preview = previewScale < 1
          ? image_codec.copyResize(
              rasterImage,
              width: (width * previewScale).round().clamp(1, 1400),
              height: (height * previewScale).round().clamp(1, 1400),
              interpolation: image_codec.Interpolation.linear,
            )
          : rasterImage;
      File(
        previewPath,
      ).writeAsBytesSync(image_codec.encodePng(preview, level: 1));
      final thumbnailScale = 320 / (width > height ? width : height);
      final thumbnail = thumbnailScale < 1
          ? image_codec.copyResize(
              preview,
              width: (width * thumbnailScale).round().clamp(1, 320),
              height: (height * thumbnailScale).round().clamp(1, 320),
              interpolation: image_codec.Interpolation.linear,
            )
          : preview;
      File(
        thumbnailPath,
      ).writeAsBytesSync(image_codec.encodePng(thumbnail, level: 1));
      return {
        'path': outputPath,
        'width': width,
        'height': height,
        'previewPath': previewPath,
        'thumbnailPath': thumbnailPath,
      };
    } finally {
      if (formPageLoaded) {
        bindings.FORM_OnBeforeClosePage(page, _formEnvironment);
      }
      if (bitmap != nullptr) bindings.FPDFBitmap_Destroy(bitmap);
      bindings.FPDF_ClosePage(page);
    }
  }

  void close() {
    if (_closed) return;
    _closed = true;
    if (_formEnvironment != nullptr) {
      bindings.FPDFDOC_ExitFormFillEnvironment(_formEnvironment);
    }
    bindings.FPDF_CloseDocument(document);
    calloc.free(_formInfo);
  }
}
