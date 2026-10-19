import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_surface_colors.dart';
import '../../../../../core/theme/app_theme_metrics.dart';
import '../../../../../l10n/localization/app_localizations.dart';
import '../bloc/pdf_to_image_bloc.dart';
import '../bloc/pdf_to_image_state.dart';

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
  final FocusNode _viewerFocusNode = FocusNode(debugLabel: 'PDF page preview');
  late final PageController _pageController;
  late int _currentPageIndex;
  late int _targetPageIndex;
  int _navigationGeneration = 0;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.images.isEmpty
        ? 0
        : widget.initialIndex.clamp(0, widget.images.length - 1);
    _targetPageIndex = _currentPageIndex;
    _pageController = PageController(initialPage: _currentPageIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _viewerFocusNode.requestFocus();
    });
  }

  @override
  void didUpdateWidget(covariant ImagePageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.images.length != oldWidget.images.length) {
      _navigationGeneration++;
      _isNavigating = false;
      _currentPageIndex = widget.images.isEmpty
          ? 0
          : _currentPageIndex.clamp(0, widget.images.length - 1);
      _targetPageIndex = _currentPageIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _pageController.hasClients) {
          _pageController.jumpToPage(_currentPageIndex);
        }
      });
    }
  }

  void _navigateBy(int pageOffset) {
    if (!_pageController.hasClients || widget.images.isEmpty) return;
    final destination = (_targetPageIndex + pageOffset).clamp(
      0,
      widget.images.length - 1,
    );
    if (destination == _targetPageIndex) return;
    _targetPageIndex = destination;
    _isNavigating = true;
    final generation = ++_navigationGeneration;
    unawaited(
      _pageController
          .animateToPage(
            destination,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
          )
          .whenComplete(() {
            if (mounted && generation == _navigationGeneration) {
              _isNavigating = false;
              _targetPageIndex = _currentPageIndex;
            }
          }),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode focusNode, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    // Keep modified shortcuts available to the app and operating system.
    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isControlPressed ||
        keyboard.isMetaPressed ||
        keyboard.isAltPressed ||
        keyboard.isShiftPressed) {
      return KeyEventResult.ignored;
    }
    final isRightArrow = event.logicalKey == LogicalKeyboardKey.arrowRight;
    if (!isRightArrow && event.logicalKey != LogicalKeyboardKey.arrowLeft) {
      return KeyEventResult.ignored;
    }
    final isRightToLeft = Directionality.of(context) == TextDirection.rtl;
    _navigateBy(isRightArrow == isRightToLeft ? -1 : 1);
    return KeyEventResult.handled;
  }

  @override
  void dispose() {
    _viewerFocusNode.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();
    final localizations = AppLocalizations.of(context)!;
    final surfaceColors = AppSurfaceColors.of(context);
    return Focus(
      focusNode: _viewerFocusNode,
      onKeyEvent: _handleKeyEvent,
      child: BlocBuilder<PdfToImageBloc, PdfToImageState>(
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: surfaceColors.canvasBackground,
                  border: Border.all(color: surfaceColors.borderColor),
                  borderRadius: BorderRadius.circular(
                    AppThemeMetrics.cardRadius,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppThemeMetrics.cardRadius,
                  ),
                  child: Listener(
                    onPointerDown: (_) => _viewerFocusNode.requestFocus(),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.images.length,
                      onPageChanged: (pageIndex) => setState(() {
                        _currentPageIndex = pageIndex;
                        if (!_isNavigating) _targetPageIndex = pageIndex;
                      }),
                      itemBuilder: (context, pageIndex) {
                        final imageFile = widget.images[pageIndex];
                        final quarterTurns =
                            state.imageRotations[imageFile.path] ?? 0;
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: RotatedBox(
                              quarterTurns: quarterTurns,
                              child: Image.file(
                                File(
                                  state.previewPaths[imageFile.path] ??
                                      imageFile.path,
                                ),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 24,
                  runSpacing: 12,
                  children: [
                    Tooltip(
                      message: localizations.pdfKeyboardNavigationHint,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          IconButton(
                            tooltip: localizations.previous,
                            icon: const Icon(Icons.arrow_back_rounded),
                            onPressed: _currentPageIndex > 0
                                ? () => _navigateBy(-1)
                                : null,
                          ),
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              localizations.pdfPageIndicator(
                                _currentPageIndex + 1,
                                widget.images.length,
                              ),
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                          IconButton(
                            tooltip: localizations.next,
                            icon: const Icon(Icons.arrow_forward_rounded),
                            onPressed:
                                _currentPageIndex < widget.images.length - 1
                                ? () => _navigateBy(1)
                                : null,
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: state.isBusy
                          ? null
                          : () => context.read<PdfToImageBloc>().rotateImage(
                              widget.images[_currentPageIndex].path,
                            ),
                      icon: const Icon(Icons.rotate_right_rounded, size: 18),
                      label: Text(localizations.rotateRight),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
