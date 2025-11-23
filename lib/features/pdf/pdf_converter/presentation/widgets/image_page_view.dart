import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/pdf_image_item.dart';
import '../cubit/pdf_converter_cubit.dart';

class ImagePageView extends StatefulWidget {
  final List<PdfImageItem> images;

  const ImagePageView({super.key, required this.images});

  @override
  State<ImagePageView> createState() => _ImagePageViewState();
}

class _ImagePageViewState extends State<ImagePageView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return const Center(child: Text('No images selected'));
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.images.length,
          itemBuilder: (context, index) {
            final image = widget.images[index];
            return Center(
              child: RotatedBox(
                quarterTurns: image.quarterTurns,
                child: Image.file(image.file, fit: BoxFit.contain),
              ),
            );
          },
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, size: 32),
                  onPressed: _previousPage,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    alignment: Alignment.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.rotate_right, size: 32),
                  onPressed: () {
                    final currentImage =
                        widget.images[_pageController.page!.round()];
                    context.read<PdfConverterCubit>().rotateImage(
                      currentImage.id,
                    );
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.white,
                    alignment: Alignment.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 32),
                  onPressed: _nextPage,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    alignment: Alignment.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
