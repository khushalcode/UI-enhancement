import 'dart:async';
import 'package:flutter/material.dart';

/// Presentation-only: slowly auto-scrolls a horizontal scrollable (ping-pong),
/// pauses while the user touches it and resumes shortly after.
class AutoScroller extends StatefulWidget {
  final ScrollController controller;
  final Widget child;
  final bool reverse;
  final double pixelsPerTick;
  const AutoScroller({super.key, required this.controller, required this.child, this.reverse = false, this.pixelsPerTick = 0.7});

  @override
  State<AutoScroller> createState() => _AutoScrollerState();
}

class _AutoScrollerState extends State<AutoScroller> {
  Timer? _timer;
  Timer? _resumeTimer;
  bool _paused = false;
  bool _started = false;
  late double _dir;

  @override
  void initState() {
    super.initState();
    _dir = widget.reverse ? -1 : 1;
    _timer = Timer.periodic(const Duration(milliseconds: 30), (_) => _tick());
  }

  void _tick() {
    if (!mounted || _paused) return;
    final ScrollController c = widget.controller;
    if (!c.hasClients) return;
    final ScrollPosition pos = c.position;
    if (!pos.haveDimensions || pos.maxScrollExtent <= 0) return;
    if (!_started) {
      _started = true;
      if (widget.reverse) {
        c.jumpTo(pos.maxScrollExtent);
        return;
      }
    }
    double next = c.offset + _dir * widget.pixelsPerTick;
    if (next >= pos.maxScrollExtent) {
      next = pos.maxScrollExtent;
      _dir = -1;
    } else if (next <= 0) {
      next = 0;
      _dir = 1;
    }
    c.jumpTo(next);
  }

  void _pause() {
    _resumeTimer?.cancel();
    _paused = true;
  }

  void _resumeLater() {
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) _paused = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _resumeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _pause(),
      onPointerUp: (_) => _resumeLater(),
      onPointerCancel: (_) => _resumeLater(),
      child: widget.child,
    );
  }
}
