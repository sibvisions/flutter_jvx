import 'package:flutter/material.dart';

/// A simple blinking circle widget
class BlinkingCircle extends StatefulWidget {

  final Color color;

  final double size;

  const BlinkingCircle({
    super.key,
    required this.color,
    required this.size
  });

  @override
  State<BlinkingCircle> createState() => _BlinkingCircleState();
}

class _BlinkingCircleState extends State<BlinkingCircle> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _animationController,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
