import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class CustomToast extends StatelessWidget {
  final String text;
  final bool isError;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;

  const CustomToast({
    super.key,
    required this.text,
    this.textColor = Colors.white,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12), required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1F2430),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: (isError ? const Color(0xffFF6B6B) : const Color(0xff2ECC71)).withValues(alpha: 0.35), width: 1),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            padding: padding,
            margin: EdgeInsets.only(
              right: ResponsiveHelper.isDesktop(Get.context) ? Get.context!.width * 0.7 : Dimensions.paddingSizeLarge,
              left: Dimensions.paddingSizeLarge,
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(isError ? CupertinoIcons.multiply_circle_fill : Icons.check_circle, color: isError ? const Color(0xffFF7A7A) : const Color(0xff2ECC71), size: 20),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Flexible(child: Text(text, style: robotoRegular.copyWith(color: textColor), maxLines: 3, overflow: TextOverflow.ellipsis)),
            ]),
          ),
        ),
      ),
    );
  }
}