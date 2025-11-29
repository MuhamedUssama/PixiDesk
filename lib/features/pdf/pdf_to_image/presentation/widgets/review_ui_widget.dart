import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixi_desk/core/theme/app_colors.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/cubit/pdf_to_image_cubit.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/cubit/pdf_to_image_state.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/widgets/image_grid_view.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/widgets/image_page_view.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class ReviewUiWidget extends StatefulWidget {
  final PdfToImageState state;
  final AppLocalizations l10n;
  final Function() onSaveAll;
  const ReviewUiWidget({
    super.key,
    required this.state,
    required this.l10n,
    required this.onSaveAll,
  });

  @override
  State<ReviewUiWidget> createState() => _ReviewUiWidgetState();
}

class _ReviewUiWidgetState extends State<ReviewUiWidget> {
  bool _isGridView = true;
  int _initialPageIndex = 0;

  void _handleSaveAll(BuildContext context) {
    final cubit = context.read<PdfToImageCubit>();
    if (widget.state.selectedFiles.length > 1) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Download Options'),
          content: const Text('How would you like to save the images?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                cubit.triggerSaveAll();
              },
              child: const Text('Combined Folder'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                cubit.saveAsSeparateZips();
              },
              child: const Text('Separate ZIPs'),
            ),
          ],
        ),
      );
    } else {
      widget.onSaveAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state.generatedImages == null ||
        widget.state.generatedImages!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Top Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.l10n.conversionResult,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    spacing: 12,
                    children: [
                      if (!_isGridView)
                        IconButton(
                          icon: const Icon(Icons.grid_view_rounded),
                          tooltip: widget.l10n.gridView,
                          onPressed: () {
                            setState(() {
                              _isGridView = true;
                            });
                          },
                        ),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<PdfToImageCubit>().saveAsZip();
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        icon: const Icon(Icons.archive),
                        label: Text(widget.l10n.saveAsZip),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _handleSaveAll(context),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        icon: const Icon(Icons.save),
                        label: Text(widget.l10n.saveAll),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Main Content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isGridView
                  ? ImageGridView(
                      key: const ValueKey('gridView'),
                      images: widget.state.generatedImages!,
                      onImageTap: (index) {
                        setState(() {
                          _initialPageIndex = index;
                          _isGridView = false;
                        });
                      },
                    )
                  : ImagePageView(
                      key: const ValueKey('pageView'),
                      images: widget.state.generatedImages!,
                      initialIndex: _initialPageIndex,
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton:
          _isGridView && widget.state.selectedImagePaths.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                context.read<PdfToImageCubit>().deleteSelectedImages();
              },
              backgroundColor: AppColors.error,
              icon: const Icon(Icons.delete, color: Colors.white),
              label: Text(
                widget.l10n.deleteSelected,
                style: const TextStyle(color: Colors.white),
              ),
            ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack)
          : null,
    );
  }
}
