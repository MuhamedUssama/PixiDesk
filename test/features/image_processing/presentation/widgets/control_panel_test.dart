import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixi_desk/core/theme/app_theme.dart';
import 'package:pixi_desk/features/image_processing/domain/entities/image_format.dart';
import 'package:pixi_desk/features/image_processing/domain/entities/image_recipe.dart';
import 'package:pixi_desk/features/image_processing/presentation/widgets/control_panel.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

import '../../support/fakes.dart';

void main() {
  for (final locale in ['en', 'ar']) {
    testWidgets(
      '$locale inspector restores sections without corrupting text scroll state',
      (tester) async {
        tester.view.physicalSize = const Size(500, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final workspace = FakeWorkspace();
        final cubit = makeCubit(
          FakeImageRepository(),
          FakeDesktop(),
          workspace,
        );
        addTearDown(cubit.close);
        addTearDown(workspace.watch.close);
        await cubit.initialize();
        cubit.updateRecipe(const ImageRecipe(format: ImageFormat.jpg));
        await cubit.chooseOutputFolder('Output folder');
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(locale),
            theme: AppTheme.lightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: BlocProvider.value(
                value: cubit,
                child: const ControlPanel(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final l = AppLocalizations.of(
          tester.element(find.byType(ControlPanel)),
        )!;

        Future<void> toggle(String title) async {
          final heading = find.text(title);
          await tester.ensureVisible(heading);
          await tester.pumpAndSettle();
          await tester.tap(heading);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }

        Future<void> reopen(
          String title, {
          bool initiallyExpanded = false,
        }) async {
          if (!initiallyExpanded) await toggle(title);
          await toggle(title);
          await toggle(title);
        }

        await reopen(l.imageCompression, initiallyExpanded: true);
        await reopen(l.imageMetadata);
        await reopen(l.imageNaming);
        await tester.tap(find.text(l.imageStudioEdit));
        await tester.pumpAndSettle();
        await reopen(l.imageResize, initiallyExpanded: true);
        await reopen(l.imageWatermark);
        // Returning to a tab remounts its sections and restores their saved state.
        await tester.tap(find.text(l.imageStudioExport));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.text(l.imageStudioEdit));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final watermark = find.descendant(
          of: find.ancestor(
            of: find.text(l.imageWatermark),
            matching: find.byType(ExpansionTile),
          ),
          matching: find.byType(TextField),
        );
        await tester.ensureVisible(watermark);
        await tester.enterText(watermark, 'PixiDesk');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        expect(cubit.state.recipe.watermarkText, 'PixiDesk');
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
