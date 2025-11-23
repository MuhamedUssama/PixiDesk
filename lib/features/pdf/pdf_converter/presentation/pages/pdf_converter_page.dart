import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixi_desk/features/pdf/pdf_converter/presentation/widgets/empty_list_widget.dart';
import 'package:pixi_desk/features/pdf/pdf_converter/presentation/widgets/pdf_converter_appbar.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/localization/app_localizations.dart';
import '../cubit/pdf_converter_cubit.dart';
import '../cubit/pdf_converter_state.dart';
import '../widgets/image_grid_view.dart';
import '../widgets/image_page_view.dart';
import '../widgets/pdf_config_section.dart';
import '../../../../image_processing/presentation/widgets/drop_zone_widget.dart';

class PdfConverterPage extends StatelessWidget {
  const PdfConverterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const PdfConverterAppbar(),
      body: BlocConsumer<PdfConverterCubit, PdfConverterState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            (current.status == PdfConverterStatus.success ||
                current.status == PdfConverterStatus.error),
        listener: (context, state) {
          if (state.status == PdfConverterStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? l10n.error),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state.status == PdfConverterStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.pdfGeneratedSuccess),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == PdfConverterStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return DropZoneWidget(
            onDropped: (files) {
              context.read<PdfConverterCubit>().addImages(files);
            },
            child: state.images.isEmpty
                ? const EmptyListWidget()
                : Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: isDark ? AppColors.dark : AppColors.light,
                          child: state.isGridView
                              ? ImageGridView(images: state.images)
                              : ImagePageView(images: state.images),
                        ),
                      ),
                      Divider(color: Theme.of(context).dividerColor),
                      const PdfConfigSection(),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: state.images.isNotEmpty
                                ? () async {
                                    final outputPath = await FilePicker.platform
                                        .saveFile(
                                          dialogTitle: l10n.saveAs,
                                          fileName: 'images.pdf',
                                          type: FileType.custom,
                                          allowedExtensions: ['pdf'],
                                        );
                                    if (outputPath != null && context.mounted) {
                                      context
                                          .read<PdfConverterCubit>()
                                          .generatePdf(outputPath);
                                    }
                                  }
                                : null,
                            child: Text(l10n.generatePdf),
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
