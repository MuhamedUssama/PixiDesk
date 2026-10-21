import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pixi_desk/core/theme/app_theme.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/domain/entities/pdf_merge_document.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/presentation/bloc/pdf_merge_action.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/presentation/bloc/pdf_merge_bloc.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/presentation/bloc/pdf_merge_state.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/presentation/pages/pdf_merge_page.dart';
import 'package:pixi_desk/features/pdf/pdf_merge/presentation/widgets/pdf_merge_document_tile.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class DragBlocMock extends MockBloc<PdfMergeAction, PdfMergeState>
    implements PdfMergeBloc {}

void main() {
  setUpAll(() => registerFallbackValue(const PdfMergePreviewClosed()));
  for (final locale in ['en', 'ar']) {
    testWidgets(
      'route-scoped $locale document drag preserves actions and order',
      (tester) async {
        tester.view.physicalSize = const Size(1440, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        PdfMergeDocument document(String name) => PdfMergeDocument(
          id: name,
          path: '/$name',
          displayName: name,
          pageCount: 3,
          sizeBytes: 1000,
          modifiedMicroseconds: 1,
          changedMicroseconds: 1,
          selectedPages: [0, 1, 2],
        );
        final first = document('first.pdf');
        final second = document('second.pdf');
        final states = StreamController<PdfMergeState>.broadcast(sync: true);
        addTearDown(states.close);
        final bloc = DragBlocMock();
        whenListen(
          bloc,
          states.stream,
          initialState: PdfMergeState(documents: [first, second]),
        );
        // Match production: the route owns the Bloc below the Navigator overlay.
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            locale: Locale(locale),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: BlocProvider<PdfMergeBloc>.value(
              value: bloc,
              child: const PdfMergePage(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final firstTile = find.byKey(const ValueKey('first.pdf'));
        final secondTile = find.byKey(const ValueKey('second.pdf'));
        final handle = find.descendant(
          of: firstTile,
          matching: find.byType(ReorderableDragStartListener),
        );
        final startPosition = tester.getCenter(handle);
        final targetPosition = Offset(
          startPosition.dx,
          tester.getBottomRight(secondTile).dy - 8,
        );
        final drag = await tester.startGesture(startPosition);
        await tester.pump(const Duration(milliseconds: 100));
        await drag.moveBy(const Offset(0, 20));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        // Cross item midpoints over successive frames, like a real drag.
        for (var step = 1; step <= 12; step++) {
          await drag.moveTo(
            Offset.lerp(startPosition, targetPosition, step / 12)!,
          );
          await tester.pump(const Duration(milliseconds: 16));
        }
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await drag.up();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        verify(
          () => bloc.add(
            any(
              that: isA<PdfMergeDocumentMoved>()
                  .having((event) => event.fromIndex, 'from', 0)
                  .having((event) => event.toIndex, 'to', 1),
            ),
          ),
        ).called(1);
        states.add(PdfMergeState(documents: [second, first]));
        await tester.pumpAndSettle();
        expect(
          tester.getTopLeft(secondTile).dy,
          lessThan(tester.getTopLeft(firstTile).dy),
        );
        expect(find.byType(PdfMergeDocumentTile), findsNWidgets(2));
        await tester.enterText(
          find.byKey(const ValueKey('range-first.pdf')),
          '3,1',
        );
        await tester.pumpAndSettle();
        verify(
          () => bloc.add(
            any(
              that: isA<PdfMergeRangeEdited>()
                  .having((event) => event.id, 'document', 'first.pdf')
                  .having((event) => event.text, 'range', '3,1'),
            ),
          ),
        ).called(1);
        await tester.tap(
          find.descendant(
            of: firstTile,
            matching: find.byIcon(Icons.rotate_right_rounded),
          ),
        );
        verify(
          () => bloc.add(
            any(
              that: isA<PdfMergePageRotated>().having(
                (event) => event.id,
                'document',
                'first.pdf',
              ),
            ),
          ),
        ).called(1);
        await tester.tap(
          find.descendant(
            of: firstTile,
            matching: find.byIcon(Icons.arrow_upward_rounded),
          ),
        );
        verify(
          () => bloc.add(
            any(
              that: isA<PdfMergeDocumentMoved>()
                  .having((event) => event.fromIndex, 'from', 1)
                  .having((event) => event.toIndex, 'to', 0),
            ),
          ),
        ).called(1);
        states.add(PdfMergeState(documents: [first, second]));
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: firstTile,
            matching: find.byIcon(Icons.arrow_downward_rounded),
          ),
        );
        verify(
          () => bloc.add(
            any(
              that: isA<PdfMergeDocumentMoved>()
                  .having((event) => event.fromIndex, 'from', 0)
                  .having((event) => event.toIndex, 'to', 1),
            ),
          ),
        ).called(1);
        await tester.tap(
          find.descendant(
            of: firstTile,
            matching: find.byIcon(Icons.close_rounded),
          ),
        );
        verify(
          () => bloc.add(
            any(
              that: isA<PdfMergeDocumentRemoved>().having(
                (event) => event.id,
                'document',
                'first.pdf',
              ),
            ),
          ),
        ).called(1);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
