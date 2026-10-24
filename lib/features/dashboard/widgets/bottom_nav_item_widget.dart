import 'package:flutter/material.dart';
import 'package:sixam_mart/util/blinkit_ui.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class BottomNavItemWidget extends StatelessWidget {
  final String? selectedIcon;
  final String? unSelectedIcon;
  final IconData? iconData;
  final String title;
  final Function? onTap;
  final bool isSelected;
  final Color? accentColor;
  const BottomNavItemWidget({super.key, this.onTap, this.isSelected = false, required this.title, this.selectedIcon, this.unSelectedIcon, this.iconData, this.accentColor});

  @override
  Widget build(BuildContext context) {
    final Color inactiveColor = BlinkitUi.ink.withValues(alpha: 0.6);
    final Color accent = accentColor ?? BlinkitUi.accent();
    final Color iconColor = isSelected ? BlinkitUi.ink : inactiveColor;

    return Expanded(
      child: InkWell(
        onTap: onTap as void Function()?,
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            height: 46, width: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? accent : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? BlinkitUi.ink : Colors.transparent, width: 2.4),
            ),
            child: iconData != null ? Icon(iconData, size: 24, color: iconColor) : Image.asset(
              isSelected ? selectedIcon! : unSelectedIcon!, height: 24, width: 24, color: iconColor,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            title,
            style: robotoRegular.copyWith(
              color: isSelected ? BlinkitUi.ink : inactiveColor,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),

        ]),
      ),
    );
  }
}
