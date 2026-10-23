import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/rental_module/common/models/taxi_coupon_model.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/features/coupon/widgets/ticket_clipper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/features/coupon/widgets/coupon_card_widget.dart';

class CouponCard extends StatelessWidget {
  final TaxiCouponModel couponModel;
  final bool? fromCouponScreen;
  final bool? fromBottomSheet;

  const CouponCard({super.key, required this.couponModel, this.fromCouponScreen = false, this.fromBottomSheet = false});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: ClipPath(
        clipper: TicketClipper(),
        child: Container(
          height: 110,
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
                    couponModel.discountType == 'percent' ? Images.percentCouponOffer : couponModel.couponType == 'free_delivery' ? Images.freeDelivery : Images.money,
                    height: 25, width: 25,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Text(
                  '${couponModel.discountType == 'percent' ? '' : Get.find<SplashController>().configModel!.currencySymbol}${couponModel.discount}${couponModel.discountType == 'percent' ? '%' : ''} ${'OFF'.tr}',
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor),
                ),
              ]),
            ),

            // Dashed Line
            CustomPaint(
              size: const Size(1, double.infinity),
              painter: DashedLinePainter(color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
            ),

            // Right Section (Details & Apply)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(
                      child: Text(
                        couponModel.code ?? '',
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, letterSpacing: 1.2),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if(fromBottomSheet!) {
                          Get.back(result: couponModel.code ?? '');
                        } else {
                          Clipboard.setData(ClipboardData(text: couponModel.code ?? ''));
                          showCustomSnackBar('coupon_code_copied'.tr, isError: false, getXSnackBar: fromBottomSheet!);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(fromBottomSheet! ? 'APPLY'.tr : 'COPY'.tr, style: robotoBold.copyWith(fontSize: 10, color: Colors.white)),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  if(couponModel.startDate != null && couponModel.expireDate != null)
                  Text(
                    '${DateConverter.stringToReadableString(couponModel.startDate!)} ${'To'.tr} ${DateConverter.stringToReadableString(couponModel.expireDate!)}',
                    style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: 10),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.info_outline, size: 12, color: Theme.of(context).primaryColor.withValues(alpha: 0.5)),
                    const SizedBox(width: 4),
                    Text(
                      '${'Min Purchase'.tr}: ${PriceConverter.convertPrice(couponModel.minPurchase)}',
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
