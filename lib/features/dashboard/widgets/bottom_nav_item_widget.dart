import 'package:flutter/material.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class BottomNavItemWidget extends StatelessWidget {
  final String? selectedIcon;
  final String? unSelectedIcon;
  final IconData? iconData;
  final String title;
  final Function? onTap;
  final bool isSelected;
  const BottomNavItemWidget({super.key, this.onTap, this.isSelected = false, required this.title, this.selectedIcon, this.unSelectedIcon, this.iconData});

  @override
  Widget build(BuildContext context) {
    final Color activeColor = Colors.white;
    final Color inactiveColor = Colors.white.withValues(alpha: 0.55);

    return Expanded(
      child: InkWell(
        onTap: onTap as void Function()?,
        borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: iconData != null ? Icon(
              iconData, size: 22,
              color: isSelected ? activeColor : inactiveColor,
            ) : Image.asset(
              isSelected ? selectedIcon! : unSelectedIcon!, height: 22, width: 22,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            title,
            style: robotoRegular.copyWith(
              color: isSelected ? activeColor : inactiveColor,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),

        ]),
      ),
    );
  }
}
