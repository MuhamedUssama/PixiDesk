import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/entities/pdf_to_image_params.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/entities/pdf_to_image_event.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/entities/pdf_conversion_failure.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/repositories/pdf_to_image_repository.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/services/pdf_export_dialogs.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/usecases/convert_pdf_to_images_usecase.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/usecases/cancel_conversion_usecase.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/usecases/release_pdf_conversion_usecase.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/usecases/save_images_usecase.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/usecases/save_as_zip_usecase.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/usecases/save_as_separate_zips_usecase.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/bloc/pdf_to_image_bloc.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/bloc/pdf_to_image_state.dart';

class RepositoryMock extends Mock implements PdfToImageRepository {}

class DialogsMock extends Mock implements PdfExportDialogs {}

Future<void> drainEvents() =>
    Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  late RepositoryMock repository;
  late DialogsMock dialogs;
  late PdfToImageBloc bloc;
  late StreamController<PdfToImageEvent> conversion;
  setUpAll(
    () => registerFallbackValue(
      PdfToImageParams(jobId: 'fallback', inputPaths: ['/test.pdf']),
    ),
  );
  setUp(() {
    repository = RepositoryMock();
    dialogs = DialogsMock();
    conversion = StreamController<PdfToImageEvent>();
    when(() => repository.convert(any())).thenAnswer((_) => conversion.stream);
    when(() => repository.cancelCurrentConversion(any())).thenAnswer((_) async {
      await conversion.close();
    });
    when(() => repository.releaseConversion(any())).thenAnswer((_) async {});
    bloc = PdfToImageBloc(
      ConvertPdfToImagesUseCase(repository),
      SaveImagesUseCase(repository),
      SaveAsZipUseCase(repository),
      SaveAsSeparateZipsUseCase(repository),
      CancelConversionUseCase(repository),
      ReleasePdfConversionUseCase(repository),
      dialogs,
    );
  });
  tearDown(() async {
    await bloc.close();
    if (!conversion.isClosed) {
      if (!conversion.hasListener) unawaited(conversion.stream.drain<void>());
      await conversion.close();
    }
  });
  Future<void> start() async {
    bloc.selectFiles([File('/input.pdf')]);
    await drainEvents();
    bloc.startConversion();
    await drainEvents();
  }

  Future<void> complete() async {
    await start();
    conversion.add(
      const PdfToImageCompleted(
        ['/page.tiff'],
        groupedPaths: {
          '/input.pdf': ['/page.tiff'],
        },
        previewPaths: {'/page.tiff': '/preview.png'},
        thumbnailPaths: {'/page.tiff': '/thumb.png'},
      ),
    );
    await conversion.close();
    await drainEvents();
  }

  test(
    'duplicate conversion is dropped and busy input/settings are locked',
    () async {
      await start();
      bloc.startConversion();
      bloc.updateSettings(dpi: 600);
      bloc.selectFiles([File('/other.pdf')]);
      bloc.clearFile();
      await drainEvents();
      verify(() => repository.convert(any())).called(1);
      expect(bloc.state.dpi, 150);
      expect(bloc.state.selectedFiles.single.path, '/input.pdf');
      bloc.cancelConversion();
      await drainEvents();
      expect(bloc.state.status, PdfToImageStatus.initial);
      expect(bloc.state.progress, isNull);
      verify(() => repository.cancelCurrentConversion(any())).called(1);
    },
  );
  test(
    'TIFF preview paths, nested groups, and explicit null resets remain consistent',
    () async {
      await complete();
      expect(bloc.state.status, PdfToImageStatus.review);
      expect(bloc.state.previewPaths['/page.tiff'], '/preview.png');
      expect(
        () => bloc.state.groupedImages['/input.pdf']!.add(File('/bad')),
        throwsUnsupportedError,
      );
      bloc.rotateImage('/page.tiff');
      bloc.toggleImageSelection('/page.tiff');
      await drainEvents();
      bloc.deleteSelectedImages();
      await drainEvents();
      expect(bloc.state.generatedImages, isNull);
      expect(bloc.state.imageRotations, isEmpty);
      expect(bloc.state.previewPaths, isEmpty);
      expect(bloc.state.groupedImages['/input.pdf'], isEmpty);
      bloc.clearFile();
      await drainEvents();
      verify(() => repository.releaseConversion(any())).called(1);
    },
  );
  test(
    'export keeps a stable snapshot and drops a second request while the picker is open',
    () async {
      await complete();
      final destination = Completer<String?>();
      when(() => dialogs.chooseFolder()).thenAnswer((_) => destination.future);
      when(
        () => repository.saveImages(
          any(),
          any(),
          rotations: any(named: 'rotations'),
        ),
      ).thenAnswer((_) async {});
      bloc.triggerSaveAll();
      await drainEvents();
      bloc.triggerSaveAll();
      bloc.clearFile();
      bloc.rotateImage('/page.tiff');
      await drainEvents();
      expect(bloc.state.status, PdfToImageStatus.saving);
      destination.complete('/output');
      await drainEvents();
      verify(() => dialogs.chooseFolder()).called(1);
      verify(
        () => repository.saveImages(
          ['/page.tiff'],
          '/output',
          rotations: <String, int>{},
        ),
      ).called(1);
      expect(bloc.state.success, PdfExportSuccess.images);
    },
  );
  test('closing while picker is open prevents a late export', () async {
    await complete();
    final destination = Completer<String?>();
    when(() => dialogs.chooseFolder()).thenAnswer((_) => destination.future);
    bloc.triggerSaveAll();
    await drainEvents();
    final closing = bloc.close();
    destination.complete('/output');
    await closing;
    verifyNever(
      () => repository.saveImages(
        any(),
        any(),
        rotations: any(named: 'rotations'),
      ),
    );
  });
  test(
    'typed failures and an unexpectedly empty completion are visible',
    () async {
      await start();
      conversion.addError(
        const PdfConversionFailure(PdfConversionFailureCode.passwordRequired),
      );
      await conversion.close();
      await drainEvents();
      expect(bloc.state.failure, PdfConversionFailureCode.passwordRequired);
      expect(bloc.state.status, PdfToImageStatus.error);
    },
  );
  test('synchronous backend failure cannot leave conversion stuck', () async {
    when(() => repository.convert(any())).thenThrow(
      const PdfConversionFailure(PdfConversionFailureCode.engineUnavailable),
    );
    await start();
    expect(bloc.state.failure, PdfConversionFailureCode.engineUnavailable);
    expect(bloc.state.status, PdfToImageStatus.error);
  });
  test('a completed stream with no pages becomes an error', () async {
    await start();
    conversion.add(const PdfToImageCompleted([]));
    await conversion.close();
    await drainEvents();
    expect(bloc.state.status, PdfToImageStatus.error);
    expect(bloc.state.failure, PdfConversionFailureCode.workerFailed);
  });
}
