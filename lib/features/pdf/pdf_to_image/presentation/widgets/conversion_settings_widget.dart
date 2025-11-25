import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/cubit/pdf_to_image_cubit.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/cubit/pdf_to_image_state.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class ConversionSettingsWidget extends StatelessWidget {
  const ConversionSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<PdfToImageCubit, PdfToImageState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.conversionSettings, // Need to add to arb
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: l10n.outputFormat,
                  ), // Need to add
                  value: state.outputFormat,
                  items: ['jpg', 'png', 'tiff'].map((format) {
                    return DropdownMenuItem(
                      value: format,
                      child: Text(format.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      context.read<PdfToImageCubit>().updateSettings(
                        format: value,
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: l10n.qualityDpi,
                  ), // Need to add
                  value: state.dpi,
                  items: [72, 150, 300, 600].map((dpi) {
                    return DropdownMenuItem(
                      value: dpi,
                      child: Text('$dpi DPI'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      context.read<PdfToImageCubit>().updateSettings(
                        dpi: value,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
