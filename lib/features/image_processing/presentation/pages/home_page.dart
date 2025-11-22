import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/image_cubit.dart';
import '../cubit/image_state.dart';
import '../widgets/control_panel.dart';
import '../widgets/drop_zone_widget.dart';
import '../widgets/image_preview.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ImageCubit>(),
      child: Scaffold(
        backgroundColor: AppColors.dark,
        appBar: AppBar(
          backgroundColor: AppColors.dark,
          elevation: 0,
          title: Text(
            AppLocalizations.of(context)!.appTitle,
            style: const TextStyle(color: AppColors.white),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(color: AppColors.darkWithOpacity, height: 1),
          ),
        ),
        body: BlocListener<ImageCubit, ImageState>(
          listener: (context, state) {
            if (state.status == ImageStatus.success &&
                state.successMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.successMessage!),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state.status == ImageStatus.error &&
                state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: DropZoneWidget(
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
      ),
    );
  }
}
