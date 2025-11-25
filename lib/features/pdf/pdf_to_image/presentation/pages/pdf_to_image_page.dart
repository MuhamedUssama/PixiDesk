import 'package:flutter/material.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class PdfToImagePage extends StatelessWidget {
  const PdfToImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    return Scaffold(appBar: AppBar(title: Text(l10n.pdfToImages)));
  }
}
