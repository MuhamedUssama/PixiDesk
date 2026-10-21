import 'dart:io';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image_codec;
import 'package:mocktail/mocktail.dart';
import 'package:pixi_desk/core/di/injection.dart';
import 'package:pixi_desk/core/router/app_router.dart';
import 'package:pixi_desk/core/theme/app_theme.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/domain/entities/pdf_merge_document.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/domain/entities/pdf_merge_event.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/presentation/bloc/pdf_merge_action.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/presentation/bloc/pdf_merge_bloc.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/presentation/bloc/pdf_merge_state.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/presentation/pages/pdf_merge_page.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/presentation/widgets/pdf_merge_preview_dialog.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class MergeBlocMock extends MockBloc<PdfMergeAction, PdfMergeState>
    implements PdfMergeBloc {}

void main() {
  setUpAll(() => registerFallbackValue(const PdfMergePreviewClosed()));
  for (final locale in ['en', 'ar']) {
    for (final brightness in Brightness.values) {
      for (final size in [const Size(1440, 900), const Size(360, 640)]) {
        testWidgets(
          '$locale $brightness merge UI fits $size and supports page preview',
          (tester) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final fixtures = Directory.systemTemp.createTempSync(
              'merge_ui_test_',
            );
            addTearDown(() => fixtures.deleteSync(recursive: true));
            final preview = File('${fixtures.path}/preview.png')
              ..writeAsBytesSync(
                image_codec.encodePng(image_codec.Image(width: 24, height: 32)),
              );
            final document = PdfMergeDocument(
              id: 'one',
              path: '/documents/long document filename عربي.pdf',
              displayName: 'long document filename عربي.pdf',
              pageCount: 3,
              sizeBytes: 1000,
              modifiedMicroseconds: 1,
              changedMicroseconds: 1,
              selectedPages: [0, 1, 2],
            );
            final bloc = MergeBlocMock();
            when(() => bloc.isClosed).thenReturn(false);
            whenListen(
              bloc,
              const Stream<PdfMergeState>.empty(),
              initialState: const PdfMergeState(),
            );
            for (final state in [
              const PdfMergeState(),
              PdfMergeState(
                documents: [document],
                acknowledgeDocumentChanges: true,
                previewDocumentId: 'one',
                previewPath: preview.path,
              ),
              PdfMergeState(
                documents: [document],
                acknowledgeDocumentChanges: true,
                status: PdfMergeStatus.completed,
                result: const PdfMergeResult(
                  path: '/output.pdf',
                  pageCount: 3,
                  sizeBytes: 1000,
                ),
              ),
            ]) {
              when(() => bloc.state).thenReturn(state);
              await tester.pumpWidget(
                BlocProvider<PdfMergeBloc>.value(
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
                        textScaler: TextScaler.linear(
                          size.width < 400 ? 1.3 : 1,
                        ),
                      ),
                      child: child!,
                    ),
                    home: const PdfMergePage(),
                  ),
                ),
              );
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
              if (state.documents.isNotEmpty) {
                final documentsBounds = tester.getRect(
                  find.byKey(const ValueKey('mergeDocumentsPanel')),
                );
                final settingsBounds = tester.getRect(
                  find.byKey(const ValueKey('mergeSummaryPanel')),
                );
                if (size.width > 850) {
                  expect(documentsBounds.top, closeTo(settingsBounds.top, 1));
                } else {
                  expect(
                    settingsBounds.top,
                    greaterThan(documentsBounds.bottom),
                  );
                }
              }
              if (state.previewDocumentId != null && state.result == null) {
                final localizations = AppLocalizations.of(
                  tester.element(find.byType(PdfMergePage)),
                )!;
                final button = find.widgetWithText(
                  TextButton,
                  localizations.pdfMergeArrangePages,
                );
                await tester.ensureVisible(button);
                await tester.tap(button);
                await tester.pumpAndSettle();
                expect(find.byType(PdfMergePreviewDialog), findsOneWidget);
                expect(tester.takeException(), isNull);
                clearInteractions(bloc);
                final nextKey = locale == 'ar'
                    ? LogicalKeyboardKey.arrowLeft
                    : LogicalKeyboardKey.arrowRight;
                await tester.sendKeyEvent(nextKey);
                verify(
                  () => bloc.add(
                    any(
                      that: isA<PdfMergePreviewRequested>().having(
                        (event) => event.pageIndex,
                        'page',
                        1,
                      ),
                    ),
                  ),
                ).called(1);
                await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
                await tester.sendKeyEvent(nextKey);
                await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
                verifyNever(
                  () => bloc.add(any(that: isA<PdfMergePreviewRequested>())),
                );
                await tester.tap(
                  find.byTooltip(localizations.pdfMergeClosePreview),
                );
                await tester.pumpAndSettle();
              }
              await tester.pumpWidget(const SizedBox());
            }
          },
        );
      }
    }
  }
  testWidgets('named merge route resolves the page-scoped Bloc', (
    tester,
  ) async {
    final bloc = MergeBlocMock();
    when(() => bloc.isClosed).thenReturn(false);
    whenListen(
      bloc,
      const Stream<PdfMergeState>.empty(),
      initialState: const PdfMergeState(),
    );
    getIt.registerFactory<PdfMergeBloc>(() => bloc);
    addTearDown(() => getIt.unregister<PdfMergeBloc>());
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRouter.pdfMergeRoute),
            child: const Text('Open merge'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open merge'));
    await tester.pumpAndSettle();
    expect(find.byType(PdfMergePage), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
