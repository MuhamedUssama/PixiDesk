import 'package:flutter/material.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/app_catalog_page.dart';
import '../../l10n/localization/app_localizations.dart';
import 'widgets/pdf_tool_item.dart';

class PdfToolsPage extends StatelessWidget {
  const PdfToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return AppCatalogPage(
      appBar: AppBar(title: Text(localizations.pdfTools)),
      eyebrow: localizations.pdfCatalogEyebrow,
      title: localizations.pdfCatalogHeadline,
      description: localizations.pdfCatalogDescription,
      sectionTitle: localizations.pdfCatalogChooseTool,
      sectionCaption: localizations.desktopWorkspaceCaption,
      toolCards: [
        PdfToolItem(
          icon: Icons.add_photo_alternate_outlined,
          title: localizations.pdfConverterTitle,
          description: localizations.pdfCreateDescription,
          actionLabel: localizations.pdfCreateAction,
          capabilityLabels: [
            localizations.catalogArrange,
            localizations.catalogPageSize,
          ],
          onPressed: () =>
              Navigator.pushNamed(context, AppRouter.pdfConverterRoute),
        ),
        PdfToolItem(
          icon: Icons.compress_rounded,
          title: localizations.compressPdf,
          description: localizations.pdfCompressDescription,
          actionLabel: localizations.pdfCompressAction,
          capabilityLabels: [
            localizations.catalogQuality,
            localizations.catalogPreview,
          ],
          onPressed: () =>
              Navigator.pushNamed(context, AppRouter.pdfCompressionRoute),
        ),
        PdfToolItem(
          icon: Icons.photo_library_outlined,
          title: localizations.pdfToImages,
          description: localizations.pdfExtractDescription,
          actionLabel: localizations.pdfExtractAction,
          capabilityLabels: [
            localizations.catalogResolution,
            localizations.catalogBatchExport,
          ],
          onPressed: () =>
              Navigator.pushNamed(context, AppRouter.pdfToImageRoute),
        ),
      ],
    );
  }
}
