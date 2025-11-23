import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/pdf_image_item.dart';
import '../cubit/pdf_converter_cubit.dart';

class ImageGridView extends StatelessWidget {
  final List<PdfImageItem> images;

  const ImageGridView({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: images.length,
      onReorder: (oldIndex, newIndex) {
        context.read<PdfConverterCubit>().reorderImages(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final image = images[index];
        return GridItem(
          key: ValueKey(image.id),
          image: image,
          onToggleSelection: () {
            context.read<PdfConverterCubit>().toggleSelection(image.id);
          },
          onRemove: () {
            context.read<PdfConverterCubit>().removeImage(image.id);
          },
        );
      },
    );
  }
}

class GridItem extends StatelessWidget {
  final PdfImageItem image;
  final VoidCallback onToggleSelection;
  final VoidCallback onRemove;

  const GridItem({
    super.key,
    required this.image,
    required this.onToggleSelection,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkWithOpacity : AppColors.white;
    final textColor = isDark
        ? AppColors.darkTextColor
        : AppColors.lightTextColor;

    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Image.file(
          image.file,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(
          image.file.path.split('\\').last,
          style: TextStyle(color: textColor),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: image.isSelected,
              onChanged: (_) => onToggleSelection(),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: AppColors.error),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
