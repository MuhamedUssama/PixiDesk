import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixi_desk/features/pdf/pdf_compression/presentation/cubit/pdf_compression_cubit.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class CompressPdfAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CompressPdfAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      title: Text(l10n.compressPdf),
      actions: [
        IconButton(
          onPressed: () async {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf'],
            );
            if (result != null &&
                result.files.single.path != null &&
                context.mounted) {
              context.read<PdfCompressionCubit>().selectFile(
                File(result.files.single.path!),
              );
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
