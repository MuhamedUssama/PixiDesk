import 'package:flutter/material.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class ImageProcessingAppbar extends StatelessWidget
    implements PreferredSizeWidget {
  const ImageProcessingAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      title: Text(AppLocalizations.of(context)!.appTitle),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(color: Theme.of(context).dividerColor, height: 1),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
