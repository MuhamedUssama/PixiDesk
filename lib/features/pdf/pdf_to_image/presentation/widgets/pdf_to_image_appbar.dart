import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/cubit/pdf_to_image_cubit.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class PdfToImageAppbar extends StatelessWidget implements PreferredSizeWidget {
  const PdfToImageAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      title: Text(l10n.pdfToImage),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          onPressed: () async {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf'],
              allowMultiple: true,
            );
            if (result != null && result.files.isNotEmpty) {
              if (context.mounted) {
                final files = result.files.map((f) => File(f.path!)).toList();
                context.read<PdfToImageCubit>().selectFiles(files);
              }
            }
          },
          icon: const Icon(Icons.upload_file),
          tooltip: l10n.selectPdf,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
