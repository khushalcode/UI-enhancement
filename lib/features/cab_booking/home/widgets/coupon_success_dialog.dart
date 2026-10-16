import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/helper/price_converter.dart';

class CouponSuccessDialog extends StatelessWidget {
  final double discount;
  const CouponSuccessDialog({super.key, required this.discount});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        
        Stack(alignment: Alignment.center, children: [
          Image.asset(Images.congratulationLight, height: 150, width: double.infinity, fit: BoxFit.cover),
          Container(
            height: 150, width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.white.withOpacity(0.8), Colors.white],
              ),
            ),
          ),
          const Positioned(
            bottom: 10,
            child: Icon(Icons.stars_rounded, color: Color(0xFFFFD700), size: 40),
          ),
        ]),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeExtraLarge),
          child: Column(children: [
            Text('Congratulations!'.tr, style: robotoBold.copyWith(fontSize: 22, color: Colors.green[700])),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: robotoRegular.copyWith(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium!.color),
                children: [
                  TextSpan(text: 'You have saved '.tr),
                  TextSpan(
                    text: PriceConverter.convertPrice(discount),
                    style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: 18),
                  ),
                  TextSpan(text: ' using this coupon code.'.tr),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),

            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
              ),
              child: Text('Great!'.tr, style: robotoBold.copyWith(color: Colors.white, fontSize: 16)),
            ),
          ]),
        ),
      ]),
    );
  }
}
