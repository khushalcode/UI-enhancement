import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

/// Presentation-only helpers shared by the welcome, sign-in and sign-up screens.
/// Nothing in here touches controllers, routes or validation.
class AuthColors {
  static const Color yellow = Color(0xFFF8CB46);
  static const Color yellowSoft = Color(0xFFFFF3C4);
  static const Color ink = Color(0xFF1C1C1C);
}

class _ChipSpec {
  final IconData icon;
  final Alignment alignment;
  final double phase;
  const _ChipSpec(this.icon, this.alignment, this.phase);
}

/// Category chips that drift gently and squish when tapped.
class AuthFloatingChips extends StatefulWidget {
  const AuthFloatingChips({super.key});

  @override
  State<AuthFloatingChips> createState() => _AuthFloatingChipsState();
}

class _AuthFloatingChipsState extends State<AuthFloatingChips> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int? _pressed;

  static const List<_ChipSpec> _chips = [
    _ChipSpec(Icons.shopping_basket_rounded, Alignment(-0.88, -0.3), 0.0),
    _ChipSpec(Icons.ramen_dining_rounded, Alignment(0.9, -0.55), 0.3),
    _ChipSpec(Icons.local_pharmacy_rounded, Alignment(-0.62, 0.85), 0.6),
    _ChipSpec(Icons.delivery_dining_rounded, Alignment(0.7, 0.75), 0.85),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(children: [
          for (int i = 0; i < _chips.length; i++)
            Align(
              alignment: _chips[i].alignment,
              child: Transform.translate(
                offset: Offset(0, math.sin((_controller.value + _chips[i].phase) * 2 * math.pi) * 5),
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _pressed = i),
                  onTapUp: (_) => setState(() => _pressed = null),
                  onTapCancel: () => setState(() => _pressed = null),
                  child: AnimatedScale(
                    scale: _pressed == i ? 0.84 : 1,
                    duration: const Duration(milliseconds: 120),
                    child: Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Icon(_chips[i].icon, size: 22, color: AuthColors.ink),
                    ),
                  ),
                ),
              ),
            ),
        ]);
      },
    );
  }
}

/// Yellow hero on top, white rounded sheet below. On wide screens it falls back to a centered card.
class AuthLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final bool hasAppBar;
  final double wideMaxWidth;
  final bool wideHeader;

  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.hasAppBar = true,
    this.wideMaxWidth = 500,
    this.wideHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    if (media.size.width > 700) {
      return _wide(context);
    }

    final bool keyboardOpen = media.viewInsets.bottom > 0;
    final double topInset = media.padding.top + (hasAppBar ? kToolbarHeight : 0);
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [AuthColors.yellow, Color(0xFFFBDD7A)],
        ),
      ),
      child: Column(children: [
        AnimatedContainer(
          duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          height: keyboardOpen ? topInset + 6 : topInset + 170,
          width: double.infinity,
          child: ClipRect(
            child: AnimatedOpacity(
              duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 200),
              opacity: keyboardOpen ? 0 : 1,
              child: Padding(
                padding: EdgeInsets.only(top: topInset),
                child: Stack(children: [
                  const Positioned.fill(child: AuthFloatingChips()),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 92, height: 92,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      child: Image.asset(Images.logo, fit: BoxFit.contain),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),

        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            builder: (context, value, sheet) => Transform.translate(
              offset: Offset(0, (1 - value) * 48),
              child: Opacity(opacity: value.clamp(0.0, 1.0), child: sheet),
            ),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, -6))],
              ),
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(Dimensions.paddingSizeExtraLarge, 28, Dimensions.paddingSizeExtraLarge, 24 + media.padding.bottom),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: robotoBold.copyWith(fontSize: 26, color: AuthColors.ink)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor)),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                  child,
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _wide(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [AuthColors.yellowSoft, Colors.white],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: wideMaxWidth,
              margin: const EdgeInsets.all(50),
              padding: EdgeInsets.all(wideHeader ? 50 : 0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 24, spreadRadius: 1)],
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                if (wideHeader) ...[
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.clear)),
                  ),
                  Image.asset(Images.logo, width: 80),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  Text(title, style: robotoBold.copyWith(fontSize: 28, color: AuthColors.ink)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Text(subtitle, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).hintColor)),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                ],
                child,
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
