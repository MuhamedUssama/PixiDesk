import 'package:flutter/material.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/bloc/pdf_to_image_bloc.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class PdfExportOptionsDialog {
  static Future<void> show({
    required BuildContext context,
    required PdfToImageBloc bloc,
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
                bloc.triggerSaveAll();
              },
              child: Text(l10n.combinedFolder),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                bloc.saveAsSeparateZips();
              },
              child: Text(l10n.separateZips),
            ),
          ],
        ),
      );
    } else {
      bloc.triggerSaveAll();
    }
  }
}
