import 'package:flutter/material.dart';
import 'package:pixi_desk/core/router/app_router.dart';
import 'package:pixi_desk/core/theme/app_colors.dart';
import 'package:pixi_desk/features/pdf/widgets/pdf_tool_item.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class PdfToolsPage extends StatelessWidget {
  const PdfToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.pdfTools)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        children: [
          Container(
            height: 500,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.card : AppColors.darkTextColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                PdfToolItem(
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.pdfConverterRoute);
                  },
                  toolName: l10n.pdfConverterTitle,
                  toolDescription: l10n.pdfConverterSubtitle,
                  icon: Icons.file_open,
                ),
                const Divider(),
                PdfToolItem(
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.pdfCompressionRoute);
                  },
                  toolName: l10n.compressPdf,
                  toolDescription: l10n.compressPdfSubtitle,
                  icon: Icons.compress,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
