import 'package:flutter/material.dart';
import '../../domain/entities/pdf_image_item.dart';

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
            return Center(child: Image.file(image.file, fit: BoxFit.contain));
          },
        ),
        Positioned(
          left: 16,
          top: 0,
          bottom: 0,
          child: Center(
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 32),
              onPressed: _previousPage,
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
        Positioned(
          right: 16,
          top: 0,
          bottom: 0,
          child: Center(
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 32),
              onPressed: _nextPage,
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
