import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/cubit/pdf_to_image_cubit.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/cubit/pdf_to_image_state.dart';
import 'package:pixi_desk/l10n/localization/app_localizations.dart';

class ImagePageView extends StatefulWidget {
  final List<File> images;
  final int initialIndex;

  const ImagePageView({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<ImagePageView> createState() => _ImagePageViewState();
}

class _ImagePageViewState extends State<ImagePageView> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<PdfToImageCubit, PdfToImageState>(
      builder: (context, state) {
        return Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final file = widget.images[index];
                final rotation = state.imageRotations[file.path] ?? 0;

                return Center(
                  child: RotatedBox(
                    quarterTurns: rotation,
                    child: Image.file(file, fit: BoxFit.contain),
                  ),
                );
              },
            ),

            if (_currentIndex > 0)
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 32),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black26,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    tooltip: l10n.previous,
                  ),
                ),
              ),
            if (_currentIndex < widget.images.length - 1)
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 32),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black26,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    tooltip: l10n.next,
                  ),
                ),
              ),
            // Central Rotate Button
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton.extended(
                  onPressed: () {
                    final currentFile = widget.images[_currentIndex];
                    context.read<PdfToImageCubit>().rotateImage(
                      currentFile.path,
                    );
                  },
                  icon: const Icon(Icons.rotate_right),
                  label: Text(l10n.rotateRight),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
