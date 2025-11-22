import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixi_desk/features/pdf_converter/presentation/pages/pdf_converter_page.dart';
import 'package:pixi_desk/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class HomeAppbar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      title: Text(AppLocalizations.of(context)!.appTitle),
      actions: [
        IconButton(
          icon: const Icon(Icons.language),
          onPressed: () => context.read<SettingsCubit>().toggleLocale(),
        ),
        IconButton(
          icon: Icon(
            Theme.of(context).brightness == Brightness.dark
                ? Icons.light_mode
                : Icons.dark_mode,
          ),
          onPressed: () => context.read<SettingsCubit>().toggleTheme(),
        ),
        IconButton(
          icon: const Icon(Icons.picture_as_pdf),
          tooltip: 'Images to PDF',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PdfConverterPage()),
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(color: Theme.of(context).dividerColor, height: 1),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
