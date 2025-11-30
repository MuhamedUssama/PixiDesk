import 'package:flutter/material.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/cubit/pdf_to_image_cubit.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class DownloadUtils {
  static Future<void> handleDownloadFlow({
    required BuildContext context,
    required PdfToImageCubit cubit,
    required AppLocalizations l10n,
    required bool isMultipleFiles,
  }) async {
    if (isMultipleFiles) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.downloadOptions),
          content: Text(l10n.downloadOptionsMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                cubit.triggerSaveAll();
              },
              child: Text(l10n.combinedFolder),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                cubit.saveAsSeparateZips();
              },
              child: Text(l10n.separateZips),
            ),
          ],
        ),
      );
    } else {
      cubit.triggerSaveAll();
    }
  }
}
