import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/localization/app_localizations.dart';
import '../../domain/entities/pdf_config.dart';
import '../cubit/pdf_converter_cubit.dart';
import '../cubit/pdf_converter_state.dart';

class PdfConfigSection extends StatelessWidget {
  const PdfConfigSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.darkHeadTextColor
        : AppColors.lightHeadTextColor;

    return BlocBuilder<PdfConverterCubit, PdfConverterState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.pageSize,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PdfPageFormatOption>(
                initialValue: state.config.pageFormat,
                decoration: InputDecoration(
                  labelText: l10n.pageSize,
                  border: const OutlineInputBorder(),
                ),
                items: PdfPageFormatOption.values.map((format) {
                  String label;
                  switch (format) {
                    case PdfPageFormatOption.a4:
                      label = l10n.a4;
                      break;
                    case PdfPageFormatOption.letter:
                      label = l10n.letter;
                      break;
                    case PdfPageFormatOption.original:
                      label = l10n.original;
                      break;
                  }
                  return DropdownMenuItem(value: format, child: Text(label));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    context.read<PdfConverterCubit>().updateConfig(
                      PdfConfig(pageFormat: value),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
