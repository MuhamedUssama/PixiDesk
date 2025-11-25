import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/cubit/pdf_to_image_cubit.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/cubit/pdf_to_image_state.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class ConversionProgressWidget extends StatelessWidget {
  const ConversionProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<PdfToImageCubit, PdfToImageState>(
      builder: (context, state) {
        if (state.progress == null) return const SizedBox.shrink();

        final progress = state.progress!;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: progress.percentage > 0 ? progress.percentage : null,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.convertingPageOf(
                    progress.currentPage,
                    progress.totalPages > 0
                        ? progress.totalPages.toString()
                        : '?',
                  ),
                  // Need to add convertingPageOf(int, String) to arb
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
