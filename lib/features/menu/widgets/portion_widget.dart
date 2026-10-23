import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/blinkit_ui.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
class PortionWidget extends StatelessWidget {
  final String icon;
  final String title;
  final bool hideDivider;
  final String route;
  final String? suffix;
  final Function()? onTap;
  const PortionWidget({super.key, required this.icon, required this.title, required this.route, this.hideDivider = false, this.suffix, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () => Get.toNamed(route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        child: Column(children: [
          Row(children: [
            Container(
              height: 44, width: 44,
              decoration: BoxDecoration(color: BlinkitUi.surface, borderRadius: BorderRadius.circular(14)),
              child: Center(child: Image.asset(icon, height: 20, width: 20, color: BlinkitUi.ink)),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),

            Expanded(child: Text(title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: BlinkitUi.ink))),

            suffix != null ? Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE9ECFB),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: Dimensions.paddingSizeDefault),
              child: Text(suffix!, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: const Color(0xFF3F4A9E)), textDirection: TextDirection.ltr),
            ) : const SizedBox(),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Icon(Icons.chevron_right_rounded, size: 26, color: BlinkitUi.ink.withValues(alpha: 0.7)),
          ]),
          hideDivider ? const SizedBox() : Padding(
            padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
            child: Divider(height: 1, thickness: 1, color: Colors.black.withValues(alpha: 0.08)),
          ),
        ]),
      ),
    );
  }
}
