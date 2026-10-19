import 'package:flutter/material.dart';
import '../../../../l10n/localization/app_localizations.dart';
import 'image_studio_style.dart';

class ImageProcessingAppbar extends StatelessWidget
    implements PreferredSizeWidget {
  final List<Widget> actions;
  const ImageProcessingAppbar({super.key, this.actions = const []});
  @override
  Widget build(BuildContext context) {
    final c = StudioColors(context);
    final l = AppLocalizations.of(context)!;
    return AppBar(
      toolbarHeight: 76,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          if (Navigator.canPop(context)) ...[
            IconButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_rounded, size: 19),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: c.ink,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              Icons.photo_filter_rounded,
              color: Theme.of(context).colorScheme.surface,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.appTitle,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: c.muted,
                    letterSpacing: .5,
                  ),
                ),
                Text(
                  l.imageStudioTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -.4,
                    color: c.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [...actions, const SizedBox(width: 16)],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(76);
}
