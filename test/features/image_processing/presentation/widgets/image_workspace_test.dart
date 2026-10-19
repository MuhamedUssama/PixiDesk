import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:pixi_desk/core/theme/app_theme.dart';
import 'package:pixi_desk/features/image_processing/domain/entities/image_format.dart';
import 'package:pixi_desk/features/image_processing/domain/entities/image_recipe.dart';
import 'package:pixi_desk/features/image_processing/presentation/pages/image_processing_page.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';
import '../../support/fakes.dart';

void main() {
  for (final locale in ['en', 'ar']) {
    for (final size in [
      const Size(1440, 900),
      const Size(1024, 768),
      const Size(650, 600),
      const Size(500, 350),
    ]) {
      testWidgets(
        '$locale workspace adapts to $size without layout or dropdown errors',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final repo = FakeImageRepository();
          final desktop = FakeDesktop();
          final workspace = FakeWorkspace();
          final bytes = img.encodePng(img.Image(width: 120, height: 60));
          repo.assets['/a.png'] = asset('/a.png', thumbnail: bytes);
          repo.assets['/b.jpg'] = asset(
            '/b.jpg',
            format: ImageFormat.jpg,
            thumbnail: bytes,
          );
          final cubit = makeCubit(repo, desktop, workspace);
          await cubit.initialize();
          await cubit.addImages(['/a.png', '/b.jpg']);
          cubit.selectImage(0);
          cubit.updateRecipe(const ImageRecipe(format: ImageFormat.jpg));
          await tester.pumpWidget(
            MaterialApp(
              locale: Locale(locale),
              theme: locale == 'ar' ? AppTheme.darkTheme : AppTheme.lightTheme,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: BlocProvider.value(
                value: cubit,
                child: const ImageProcessingPage(),
              ),
            ),
          );
          cubit.selectImage(1);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          if (size.width < 1000) {
            await tester.tap(
              find.text(locale == 'ar' ? 'الإعدادات' : 'Settings').first,
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }
          await tester.tap(
            find.text(locale == 'ar' ? 'تعديل' : 'Adjust').first,
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.tap(
            find.text(locale == 'ar' ? 'وصفات' : 'Presets').first,
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
          await cubit.close();
          await workspace.watch.close();
        },
      );
    }
  }
  testWidgets(
    'paste in an inspector field edits text without importing images',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = FakeImageRepository(),
          desktop = FakeDesktop(),
          workspace = FakeWorkspace();
      final cubit = makeCubit(repo, desktop, workspace);
      await cubit.initialize();
      await cubit.addImages(['/a.png']);
      cubit.updateRecipe(const ImageRecipe(format: ImageFormat.jpg));
      desktop.picked = ['/clipboard.png'];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.getData') return {'text': '2048'};
            if (call.method == 'Clipboard.hasStrings') return {'value': true};
            return null;
          });
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider.value(
            value: cubit,
            child: const ImageProcessingPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextField).first);
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        '2048',
      );
      expect(cubit.state.jobs.length, 1);
      await tester.pumpWidget(const SizedBox());
      await cubit.close();
      await workspace.watch.close();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    },
  );
  testWidgets('RTL inspector supports enlarged text without hiding its tools', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = FakeImageRepository(),
        desktop = FakeDesktop(),
        workspace = FakeWorkspace();
    final cubit = makeCubit(repo, desktop, workspace);
    await cubit.initialize();
    await cubit.addImages(['/صورة.png']);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        theme: AppTheme.darkTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.6)),
          child: child!,
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider.value(
          value: cubit,
          child: const ImageProcessingPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('تعديل').first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await cubit.close();
    await workspace.watch.close();
  });
}
