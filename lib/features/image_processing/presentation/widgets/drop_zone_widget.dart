import 'dart:io';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DropZoneWidget extends StatefulWidget {
  final Widget child;
  final Function(List<File>) onDropped;

  const DropZoneWidget({
    super.key,
    required this.child,
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
        if (detail.files.isNotEmpty) {
          final files = detail.files.map((e) => File(e.path)).toList();
          widget.onDropped(files);
        }
      },
      onDragEntered: (detail) {
        setState(() {
          _dragging = true;
        });
      },
      onDragExited: (detail) {
        setState(() {
          _dragging = false;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: _dragging ? AppColors.darkWithOpacity : AppColors.transparent,
          border: _dragging
              ? Border.all(color: AppColors.white, width: 2)
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: widget.child,
      ),
    );
  }
}
