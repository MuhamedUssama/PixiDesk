import 'dart:io';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image_codec;
import 'package:mocktail/mocktail.dart';
import 'package:pixi_desk/core/theme/app_theme.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/bloc/pdf_to_image_action.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/bloc/pdf_to_image_bloc.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/bloc/pdf_to_image_state.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/widgets/image_page_view.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class ViewerBlocMock extends MockBloc<PdfToImageAction, PdfToImageState>
    implements PdfToImageBloc {}

void main() {
  late Directory fixtures;
  late List<File> images;
  late ViewerBlocMock bloc;
  setUp(() {
    fixtures = Directory.systemTemp.createTempSync('pdf_keyboard_test_');
    final png = image_codec.encodePng(image_codec.Image(width: 32, height: 24));
    images = List.generate(
      4,
      (pageIndex) =>
          File('${fixtures.path}/page-$pageIndex.png')..writeAsBytesSync(png),
    );
    bloc = ViewerBlocMock();
    whenListen(
      bloc,
      const Stream<PdfToImageState>.empty(),
      initialState: PdfToImageState(
        status: PdfToImageStatus.review,
        generatedImages: images,
      ),
    );
  });
  tearDown(() => fixtures.deleteSync(recursive: true));

  Future<AppLocalizations> openViewer(
    WidgetTester tester, {
    String locale = 'en',
    Brightness brightness = Brightness.dark,
    int initialIndex = 1,
    List<File>? pages,
  }) async {
    await tester.pumpWidget(
      BlocProvider<PdfToImageBloc>.value(
        value: bloc,
        child: MaterialApp(
          theme: brightness == Brightness.dark
              ? AppTheme.darkTheme
              : AppTheme.lightTheme,
          locale: Locale(locale),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: ImagePageView(
                images: pages ?? images,
                initialIndex: initialIndex,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return AppLocalizations.of(tester.element(find.byType(ImagePageView)))!;
  }

  int currentPage(WidgetTester tester) =>
      tester.widget<PageView>(find.byType(PageView)).controller!.page!.round();

  for (final locale in ['en', 'ar']) {
    for (final brightness in Brightness.values) {
      testWidgets(
        '$locale $brightness keyboard arrows match visual direction and remain active after rotating',
        (tester) async {
          final localizations = await openViewer(
            tester,
            locale: locale,
            brightness: brightness,
          );
          final isRightToLeft = locale == 'ar';
          expect(currentPage(tester), 1);
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await tester.pumpAndSettle();
          final expectedPage = isRightToLeft ? 0 : 2;
          expect(currentPage(tester), expectedPage);
          expect(
            find.text(localizations.pdfPageIndicator(expectedPage + 1, 4)),
            findsOneWidget,
          );
          final rotateButton = find.widgetWithText(
            OutlinedButton,
            localizations.rotateRight,
          );
          expect(
            tester.getRect(find.byType(PageView)).bottom,
            lessThan(tester.getRect(rotateButton).top),
          );
          expect(find.byType(FloatingActionButton), findsNothing);
          await tester.tap(rotateButton);
          await tester.pump();
          verify(() => bloc.rotateImage(images[expectedPage].path)).called(1);
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
          await tester.pumpAndSettle();
          expect(currentPage(tester), 1);
          // Modified arrows belong to the enclosing application or operating system.
          await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
          await tester.pumpAndSettle();
          expect(currentPage(tester), 1);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        },
      );
    }
  }
  testWidgets(
    'rapid and repeated arrows reach the last page without wrapping',
    (tester) async {
      await openViewer(tester, initialIndex: 0);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyRepeatEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyRepeatEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyRepeatEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(currentPage(tester), 3);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(currentPage(tester), 3);
      await tester.tap(find.byTooltip('Previous'));
      await tester.pumpAndSettle();
      expect(currentPage(tester), 2);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'shrinking the page list clamps the current page and rotation target',
    (tester) async {
      await openViewer(tester, initialIndex: 99);
      expect(currentPage(tester), 3);
      final localizations = await openViewer(tester, pages: [images.first]);
      expect(currentPage(tester), 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(currentPage(tester), 0);
      await tester.tap(
        find.widgetWithText(OutlinedButton, localizations.rotateRight),
      );
      verify(() => bloc.rotateImage(images.first.path)).called(1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
