import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/image_cubit.dart';
import '../cubit/image_state.dart';

class ImagePreview extends StatelessWidget {
  const ImagePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageCubit, ImageState>(
      builder: (context, state) {
        if (state.selectedImage == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.image_outlined,
                  size: 64,
                  color: AppColors.darkHeadTextColor,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.dropImageHere,
                  style: const TextStyle(
                    color: AppColors.darkTextColor,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.read<ImageCubit>().pickImage(),
                  child: Text(
                    AppLocalizations.of(context)!.orClickToUpload,
                    style: const TextStyle(color: AppColors.white),
                  ),
                ),
              ],
            ),
          );
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.file(
                    state.selectedImage!.file,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Text(
                '${state.selectedImage!.name} (${(state.selectedImage!.sizeInBytes / 1024).toStringAsFixed(2)} KB)',
                style: const TextStyle(color: AppColors.darkTextColor),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => context.read<ImageCubit>().pickImage(),
                icon: const Icon(Icons.refresh, color: AppColors.white),
                label: const Text(
                  'Change Image',
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
