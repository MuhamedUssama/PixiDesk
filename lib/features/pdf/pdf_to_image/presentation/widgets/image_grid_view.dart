import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/cubit/pdf_to_image_cubit.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/cubit/pdf_to_image_state.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class ImageGridView extends StatelessWidget {
  final List<File> images;
  final Function(int) onImageTap;

  const ImageGridView({
    super.key,
    required this.images,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<PdfToImageCubit, PdfToImageState>(
      builder: (context, state) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            final file = images[index];
            final isSelected = state.selectedImagePaths.contains(file.path);
            final rotation = state.imageRotations[file.path] ?? 0;

            return Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    // If in selection mode (any selected), toggle selection
                    // Otherwise, open detail view
                    if (state.selectedImagePaths.isNotEmpty) {
                      context.read<PdfToImageCubit>().toggleImageSelection(
                        file.path,
                      );
                    } else {
                      onImageTap(index);
                    }
                  },
                  onLongPress: () {
                    context.read<PdfToImageCubit>().toggleImageSelection(
                      file.path,
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).primaryColor,
                              width: 3,
                            )
                          : Border.all(
                              color: Colors.grey.withValues(alpha: 0.3),
                            ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: AnimatedRotation(
                        turns: rotation / 4.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Image.file(
                          file,
                          fit: BoxFit.contain,
                          cacheWidth: 400,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      context.read<PdfToImageCubit>().toggleImageSelection(
                        file.path,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.check,
                          color: isSelected ? Colors.white : Colors.transparent,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: IconButton(
                    icon: const Icon(Icons.rotate_right),
                    tooltip: l10n.rotateRight,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      context.read<PdfToImageCubit>().rotateImage(file.path);
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
