import 'dart:io';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/widgets/conversion_settings_widget.dart';
import 'package:image/image.dart' as image_codec;
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/widgets/image_page_view.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pixi_desk/core/theme/app_theme.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/domain/entities/conversion_progress.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/bloc/pdf_to_image_action.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/bloc/pdf_to_image_bloc.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/bloc/pdf_to_image_state.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/pages/pdf_to_image_page.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class PdfBlocMock extends MockBloc<PdfToImageAction, PdfToImageState>
    implements PdfToImageBloc {}

void main() {
  for (final locale in ['ar', 'en']) {
    for (final brightness in Brightness.values) {
      for (final size in [const Size(1440, 900), const Size(360, 500)]) {
        testWidgets('$locale $brightness PDF workspace fits $size', (
          tester,
        ) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final fixtures = Directory.systemTemp.createTempSync(
            'pdf_preview_widget_',
          );
          addTearDown(() => fixtures.deleteSync(recursive: true));
          final preview = File('${fixtures.path}/preview.png')
            ..writeAsBytesSync(
              image_codec.encodePng(image_codec.Image(width: 32, height: 24)),
            );
          final result = File('${fixtures.path}/page.tiff');
          final bloc = PdfBlocMock();
          whenListen(
            bloc,
            const Stream<PdfToImageState>.empty(),
            initialState: const PdfToImageState(),
          );
          for (final state in [
            const PdfToImageState(),
            PdfToImageState(
              selectedFiles: [File('/test/long descriptive filename عربي.pdf')],
              dpi: 1200,
            ),
            PdfToImageState(
              selectedFiles: [File('/test/document.pdf')],
              status: PdfToImageStatus.converting,
              progress: const ConversionProgress(
                currentPage: 100,
                totalPages: 10000,
                percentage: .01,
              ),
            ),
            PdfToImageState(
              status: PdfToImageStatus.review,
              generatedImages: [result],
              previewPaths: {result.path: preview.path},
              thumbnailPaths: {result.path: preview.path},
            ),
          ]) {
            when(() => bloc.state).thenReturn(state);
            await tester.pumpWidget(
              BlocProvider<PdfToImageBloc>.value(
                value: bloc,
                child: MaterialApp(
                  key: UniqueKey(),
                  theme: brightness == Brightness.dark
                      ? AppTheme.darkTheme
                      : AppTheme.lightTheme,
                  locale: Locale(locale),
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(size.width < 400 ? 1.3 : 1),
                    ),
                    child: child!,
                  ),
                  home: const PdfToImagePage(),
                ),
              ),
            );
            await tester.pump();
            await tester.pump(const Duration(seconds: 1));
            expect(tester.takeException(), isNull);
            if (state.selectedFiles.isNotEmpty &&
                state.status != PdfToImageStatus.review) {
              final documentsBounds = tester.getRect(
                find.byKey(const ValueKey('pdfDocumentsPanel')),
              );
              final settingsBounds = tester.getRect(
                find.byType(ConversionSettingsWidget),
              );
              if (size.width >= 850) {
                expect(documentsBounds.top, closeTo(settingsBounds.top, 1));
                expect(documentsBounds.top, lessThan(250));
              } else {
                expect(settingsBounds.top, greaterThan(documentsBounds.bottom));
              }
            }
            if (state.status == PdfToImageStatus.review) {
              final gridImage = tester.widget<Image>(find.byType(Image).first);
              final thumbnail =
                  (gridImage.image as ResizeImage).imageProvider as FileImage;
              expect(thumbnail.file.path, preview.path);
              await tester.tap(find.byType(Image).first);
              await tester.pumpAndSettle();
              expect(find.byType(ImagePageView), findsOneWidget);
              expect(
                (tester.widget<Image>(find.byType(Image).first).image
                        as FileImage)
                    .file
                    .path,
                preview.path,
              );
              expect(tester.takeException(), isNull);
            }
            await tester.pumpWidget(const SizedBox());
          }
        });
      }
    }
  }
}
