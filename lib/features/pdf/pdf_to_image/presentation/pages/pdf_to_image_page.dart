import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/widgets/drop_zone_widget.dart';
import '../../../../../l10n/localization/app_localizations.dart';
import '../bloc/pdf_to_image_bloc.dart';
import '../bloc/pdf_to_image_state.dart';
import '../utils/pdf_failure_label.dart';
import '../widgets/conversion_settings_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/pdf_to_image_appbar.dart';
import '../widgets/review_ui_widget.dart';
import '../widgets/selected_file_state.dart';

class PdfToImagePage extends StatelessWidget {
  const PdfToImagePage({super.key});
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final bloc = context.read<PdfToImageBloc>();
    return Scaffold(
      appBar: const PdfToImageAppbar(),
      body: BlocConsumer<PdfToImageBloc, PdfToImageState>(
        listenWhen: (previous, current) =>
            previous.messageId != current.messageId,
        listener: (context, state) {
          if (state.failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(pdfFailureLabel(localizations, state.failure!)),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state.success != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(localizations.filesSaved)));
          }
        },
        builder: (context, state) {
          if (state.generatedImages?.isNotEmpty ?? false) {
            return ReviewUiWidget(
              state: state,
              l10n: localizations,
              onSaveAll: bloc.triggerSaveAll,
            );
          }
          final inputArea = DropZoneWidget(
            enabled: !state.isBusy,
            onDropped: (files) => bloc.selectFiles(
              files
                  .where((file) => file.path.toLowerCase().endsWith('.pdf'))
                  .toList(),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: state.selectedFiles.isEmpty
                    ? EmptyStateWidget(l10n: localizations)
                    : SelectedFileState(state: state, l10n: localizations),
              ),
            ),
          );
          if (state.selectedFiles.isEmpty) return inputArea;
          final inspector = Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ConversionSettingsWidget(),
              const SizedBox(height: 16),
              if (state.status == PdfToImageStatus.cancelling)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(localizations.pdfCancelling),
                ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (state.isBusy)
                    OutlinedButton(
                      onPressed: state.status == PdfToImageStatus.cancelling
                          ? null
                          : bloc.cancelConversion,
                      child: Text(localizations.cancel),
                    ),
                  FilledButton.icon(
                    onPressed: state.isBusy ? null : bloc.startConversion,
                    icon: const Icon(Icons.image_outlined),
                    label: Text(localizations.convert),
                  ),
                ],
              ),
            ],
          );
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 850 || constraints.maxHeight < 400) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 280, child: inputArea),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: inspector,
                      ),
                    ],
                  ),
                );
              }
              return Row(
                children: [
                  Expanded(child: inputArea),
                  SizedBox(
                    width: 340,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: inspector,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
