import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixi_desk/features/pdf/pdf_compression/domain/entities/compression_level.dart';
import 'package:pixi_desk/features/pdf/pdf_compression/presentation/cubit/pdf_compression_cubit.dart';
import 'package:pixi_desk/features/pdf/pdf_compression/presentation/cubit/pdf_compression_state.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class CompressionSettings extends StatelessWidget {
  final PdfCompressionState state;
  final AppLocalizations l10n;

  const CompressionSettings({
    super.key,
    required this.state,
    required this.l10n,
  });

  String _getCompressionLevelName(
    CompressionLevel level,
    AppLocalizations l10n,
  ) {
    switch (level) {
      case CompressionLevel.screen:
        return l10n.compressionScreen;
      case CompressionLevel.ebook:
        return l10n.compressionEbook;
      case CompressionLevel.printer:
        return l10n.compressionPrinter;
      case CompressionLevel.prepress:
        return l10n.compressionPrepress;
      case CompressionLevel.defaultCompression:
        return l10n.compressionDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.compressionLevel,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<CompressionLevel>(
          initialValue: state.compressionLevel,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: CompressionLevel.values.map((level) {
            return DropdownMenuItem(
              value: level,
              child: Text(_getCompressionLevelName(level, l10n)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              context.read<PdfCompressionCubit>().changeCompressionLevel(value);
            }
          },
        ),
      ],
    );
  }
}
