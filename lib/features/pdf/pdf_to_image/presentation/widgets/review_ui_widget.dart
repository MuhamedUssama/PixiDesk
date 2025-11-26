import 'package:flutter/material.dart';
import 'package:pixi_desk/features/pdf/pdf_to_image/presentation/cubit/pdf_to_image_state.dart';
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
  bool _isGridView = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.l10n.conversionResult,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isGridView ? Icons.view_list : Icons.grid_view,
                      ),
                      onPressed: () {
                        setState(() {
                          _isGridView = !_isGridView;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: ElevatedButton.icon(
                        onPressed: () => widget.onSaveAll(),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 56),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        icon: const Icon(Icons.save),
                        label: Text(
                          widget.l10n.saveAll,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isGridView
              ? GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: widget.state.generatedImages!.length,
                  itemBuilder: (context, index) {
                    final file = widget.state.generatedImages![index];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: Image.file(file, fit: BoxFit.cover),
                    );
                  },
                )
              : PageView.builder(
                  itemCount: widget.state.generatedImages!.length,
                  itemBuilder: (context, index) {
                    final file = widget.state.generatedImages![index];
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.file(file, fit: BoxFit.contain),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
