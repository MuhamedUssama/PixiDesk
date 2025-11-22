import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixi_desk/features/image_processing/presentation/widgets/image_processing_appbar.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/image_cubit.dart';
import '../cubit/image_state.dart';
import '../widgets/control_panel.dart';
import '../widgets/drop_zone_widget.dart';
import '../widgets/image_preview.dart';

class ImageProcessingPage extends StatelessWidget {
  const ImageProcessingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppbar(),
      body: BlocListener<ImageCubit, ImageState>(
        listener: (context, state) {
          if (state.status == ImageStatus.success &&
              state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: AppColors.darkHeadTextColor,
              ),
            );
          } else if (state.status == ImageStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.darkHeadTextColor,
              ),
            );
          }
        },
        child: DropZoneWidget(
          onDropped: (files) {
            if (files.isNotEmpty) {
              context.read<ImageCubit>().selectImage(files.first);
            }
          },
          child: Row(
            children: [
              const Expanded(flex: 2, child: ImagePreview()),
              BlocBuilder<ImageCubit, ImageState>(
                builder: (context, state) {
                  if (state.selectedImage != null) {
                    return const SizedBox(width: 350, child: ControlPanel());
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
