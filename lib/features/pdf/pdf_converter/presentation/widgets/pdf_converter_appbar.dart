import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixi_desk/features/pdf/pdf_converter/presentation/cubit/pdf_converter_cubit.dart';
import 'package:pixi_desk/features/pdf/pdf_converter/presentation/cubit/pdf_converter_state.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class PdfConverterAppbar extends StatelessWidget
    implements PreferredSizeWidget {
  const PdfConverterAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      elevation: 0,
      title: Text(l10n.pdfConverterTitle),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_photo_alternate),
          tooltip: l10n.addPhotos,
          onPressed: () async {
            final result = await FilePicker.platform.pickFiles(
              allowMultiple: true,
              type: FileType.image,
            );
            if (result != null) {
              final files = result.paths
                  .where((path) => path != null)
                  .map((path) => File(path!))
                  .toList();
              if (context.mounted) {
                context.read<PdfConverterCubit>().addImages(files);
              }
            }
          },
        ),
        BlocBuilder<PdfConverterCubit, PdfConverterState>(
          builder: (context, state) {
            return IconButton(
              icon: Icon(
                state.isGridView ? Icons.view_carousel : Icons.grid_view,
              ),
              onPressed: () {
                context.read<PdfConverterCubit>().changeViewMode(
                  !state.isGridView,
                );
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
