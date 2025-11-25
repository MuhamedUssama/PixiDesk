import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/cubit/pdf_to_image_cubit.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class EmptyStateWidget extends StatelessWidget {
  final AppLocalizations l10n;
  const EmptyStateWidget({super.key, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.picture_as_pdf, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        Text(l10n.dragPdfHere, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () async {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf'],
            );
            if (result != null && result.files.isNotEmpty) {
              if (context.mounted) {
                context.read<PdfToImageCubit>().selectFile(
                  File(result.files.single.path!),
                );
              }
            }
          },
          child: Text(l10n.selectPdfFile),
        ),
      ],
    );
  }
}
