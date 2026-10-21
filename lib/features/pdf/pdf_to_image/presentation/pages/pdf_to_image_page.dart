import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../l10n/localization/app_localizations.dart';
import '../bloc/pdf_to_image_bloc.dart';
import '../bloc/pdf_to_image_state.dart';
import '../utils/pdf_failure_label.dart';
import '../widgets/pdf_to_image_appbar.dart';
import '../widgets/review_ui_widget.dart';
import '../widgets/pdf_conversion_workspace.dart';

class PdfToImagePage extends StatelessWidget {
  const PdfToImagePage({super.key});
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
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
            return ReviewUiWidget(state: state, l10n: localizations);
          }
          return PdfConversionWorkspace(state: state);
        },
      ),
    );
  }
}
