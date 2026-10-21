import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../l10n/localization/app_localizations.dart';
import '../bloc/pdf_to_image_bloc.dart';
import '../bloc/pdf_to_image_state.dart';

class PdfToImageAppbar extends StatelessWidget implements PreferredSizeWidget {
  const PdfToImageAppbar({super.key});
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<PdfToImageBloc, PdfToImageState>(
        builder: (context, state) {
          final localizations = AppLocalizations.of(context)!;
          return AppBar(
            title: Text(localizations.pdfToImage),
            actions: [
              IconButton(
                tooltip: localizations.selectPdf,
                icon: const Icon(Icons.upload_file_outlined),
                onPressed: state.isBusy
                    ? null
                    : () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf'],
                          allowMultiple: true,
                        );
                        if (context.mounted && result != null) {
                          context.read<PdfToImageBloc>().selectFiles(
                            result.files
                                .where((file) => file.path != null)
                                .map((file) => File(file.path!))
                                .toList(),
                          );
                        }
                      },
              ),
            ],
          );
        },
      );
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
