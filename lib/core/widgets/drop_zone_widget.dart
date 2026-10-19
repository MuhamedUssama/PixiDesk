import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

class DropZoneWidget extends StatefulWidget {
  final bool enabled;
  final Widget child;
  final Function(List<File>) onDropped;

  const DropZoneWidget({
    super.key,
    required this.child,
    this.enabled = true,
    required this.onDropped,
  });

  @override
  State<DropZoneWidget> createState() => _DropZoneWidgetState();
}

class _DropZoneWidgetState extends State<DropZoneWidget> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (detail) {
        setState(() => _dragging = false);
        if (widget.enabled && detail.files.isNotEmpty) {
          final files = detail.files.map((e) => File(e.path)).toList();
          widget.onDropped(files);
        }
      },
      onDragEntered: (detail) {
        setState(() {
          _dragging = widget.enabled;
        });
      },
      onDragExited: (detail) {
        setState(() {
          _dragging = false;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: _dragging
              ? Theme.of(context).colorScheme.onSurface.withValues(alpha: .08)
              : Colors.transparent,
          border: _dragging
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                )
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: widget.child,
      ),
    );
  }
}
