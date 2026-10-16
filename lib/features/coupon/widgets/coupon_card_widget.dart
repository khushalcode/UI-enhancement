import 'package:flutter/material.dart';
import 'package:sixam_mart/features/cab_booking/home/controllers/cab_controller.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/coupon/domain/models/coupon_model.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/coupon/widgets/ticket_clipper.dart';

class CouponCardWidget extends StatelessWidget {
  final CouponModel coupon;
  final int index;
  final bool isExpand;
  const CouponCardWidget({super.key, required this.coupon, required this.index, this.isExpand = false});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isLtr = Get.find<LocalizationController>().isLtr;

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: ClipPath(
        clipper: TicketClipper(),
        child: Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), width: 1),
          ),
          child: Row(children: [
            // Left Section (Icon & Discount)
            Container(
              width: size.width * 0.3,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    coupon.discountType == 'percent' ? Images.percentCouponOffer : coupon.couponType == 'free_delivery' ? Images.freeDelivery : Images.money,
                    height: 25, width: 25,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Text(
                  '${coupon.discountType == 'percent' ? '' : Get.find<SplashController>().configModel!.currencySymbol}${coupon.discount}${coupon.discountType == 'percent' ? '%' : ''} ${'OFF'.tr}',
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor),
                ),
                Text(
                  coupon.couponType == 'free_delivery' ? 'Free Delivery'.tr : 'Discount'.tr,
                  style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).disabledColor),
                ),
              ]),
            ),

            // Dashed Line
            CustomPaint(
              size: const Size(1, double.infinity),
              painter: DashedLinePainter(color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
            ),

            // Right Section (Details & Copy)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(
                      child: Text(
                        coupon.code ?? '',
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, letterSpacing: 1.2),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if(Get.isRegistered<CabController>()) {
                           Get.find<CabController>().applyCoupon(coupon.code ?? '');
                           Get.back();
                        } else {
                          Clipboard.setData(ClipboardData(text: coupon.code ?? ''));
                          Get.snackbar('Success', 'coupon_code_copied'.tr, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white, margin: const EdgeInsets.all(10));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('APPLY'.tr, style: robotoBold.copyWith(fontSize: 10, color: Colors.white)),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(
                    '${DateConverter.stringToReadableString(coupon.startDate!)} ${'To'.tr} ${DateConverter.stringToReadableString(coupon.expireDate!)}',
                    style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: 10),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.info_outline, size: 12, color: Theme.of(context).primaryColor.withValues(alpha: 0.5)),
                    const SizedBox(width: 4),
                    Text(
                      '${'Min Purchase'.tr}: ${PriceConverter.convertPrice(coupon.minPurchase)}',
                      style: robotoMedium.copyWith(color: Theme.of(context).disabledColor, fontSize: 10),
                    ),
                  ]),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  DashedLinePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 5, dashSpace = 3, startY = 0;
    final paint = Paint()..color = color..strokeWidth = 1;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
