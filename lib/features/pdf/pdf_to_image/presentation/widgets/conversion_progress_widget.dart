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
        final progress = state.progress;
        final isPreparing = progress == null;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(
                value: isPreparing
                    ? null
                    : (progress.percentage > 0 ? progress.percentage : null),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isPreparing
                        ? l10n.preparing
                        : l10n.convertingPageOf(
                            progress.currentPage,
                            progress.totalPages > 0
                                ? progress.totalPages.toString()
                                : '?',
                          ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (!isPreparing)
                    Text(
                      '${(progress.percentage * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
