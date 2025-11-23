import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/image_format.dart';
import '../cubit/image_cubit.dart';
import '../cubit/image_state.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageCubit, ImageState>(
      builder: (context, state) {
        if (state.selectedImage == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.dark,
            border: Border(left: BorderSide(color: AppColors.darkWithOpacity)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.convert,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ImageFormat>(
                initialValue: state.targetFormat,
                dropdownColor: AppColors.dark,
                style: const TextStyle(color: AppColors.white),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.selectFormat,
                  labelStyle: const TextStyle(
                    color: AppColors.darkHeadTextColor,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: AppColors.darkWithOpacity,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: AppColors.white),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: ImageFormat.values
                    .where((f) => f != state.selectedImage!.format)
                    .map((format) {
                      return DropdownMenuItem(
                        value: format,
                        child: Text(format.name.toUpperCase()),
                      );
                    })
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    context.read<ImageCubit>().setTargetFormat(value);
                  }
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      state.targetFormat != null &&
                          state.status != ImageStatus.loading
                      ? () => context.read<ImageCubit>().convertImage()
                      : null,
                  child:
                      state.status == ImageStatus.loading &&
                          state.targetFormat != null
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(AppLocalizations.of(context)!.convert),
                ),
              ),
              const SizedBox(height: 32),
              const Divider(color: AppColors.darkWithOpacity),
              const SizedBox(height: 32),
              Text(
                AppLocalizations.of(context)!.compress,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${AppLocalizations.of(context)!.quality}: ${state.quality}%',
                style: const TextStyle(color: AppColors.darkHeadTextColor),
              ),
              Slider(
                value: state.quality.toDouble(),
                min: 1,
                max: 100,
                activeColor: AppColors.white,
                inactiveColor: AppColors.darkWithOpacity,
                onChanged: (value) {
                  context.read<ImageCubit>().setQuality(value.toInt());
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.status != ImageStatus.loading
                      ? () => context.read<ImageCubit>().compressImage()
                      : null,
                  child:
                      state.status == ImageStatus.loading &&
                          state.targetFormat == null
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(AppLocalizations.of(context)!.compress),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
