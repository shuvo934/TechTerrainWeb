import 'package:flutter/material.dart';

class MeasureSize extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size> onChange;
  const MeasureSize({super.key, required this.child, required this.onChange});

  @override
  State<MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  Size? _oldSize;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = context.findRenderObject() as RenderBox?;
      if (box == null || !mounted) return;
      final newSize = box.size;
      if (_oldSize == newSize) return;
      _oldSize = newSize;
      widget.onChange(newSize);
    });
    return widget.child;
  }
}
