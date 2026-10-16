import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedGradientBorder extends StatefulWidget {
  final Widget child;
  final double borderWidth;
  final double size;
  
  const AnimatedGradientBorder({
    super.key, 
    required this.child,
    this.borderWidth = 3.0,
    required this.size,
  });

  @override
  State<AnimatedGradientBorder> createState() => _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late double _randomOffset;

  @override
  void initState() {
    super.initState();
    _randomOffset = math.Random().nextDouble() * 2 * math.pi;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          double sineValue = math.sin(_controller.value * 2 * math.pi + _randomOffset);
          double normalizedSine = (sineValue + 1) / 2;
          double scale = 0.85 + (normalizedSine * 0.25);
          double opacity = 0.5 + (normalizedSine * 0.5);

          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: _controller.value * 2 * math.pi,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            Colors.purple,
                            Colors.blue,
                            Colors.green,
                            Colors.yellow,
                            Colors.orange,
                            Colors.red,
                            Colors.purple,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: _controller.value * 2 * math.pi,
                    child: Container(
                      width: widget.size - (widget.borderWidth * 2),
                      height: widget.size - (widget.borderWidth * 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).cardColor,
                      ),
                      child: ClipOval(
                        child: widget.child,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
