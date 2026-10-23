import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/features/rental_module/home/controllers/taxi_home_controller.dart';
import 'package:sixam_mart/features/rental_module/widgets/coupon_card.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class TaxiCouponScreen extends StatefulWidget {
  const TaxiCouponScreen({super.key});

  @override
  State<TaxiCouponScreen> createState() => _TaxiCouponScreenState();
}

class _TaxiCouponScreenState extends State<TaxiCouponScreen> {
  @override
  void initState() {
    super.initState();

    if (AuthHelper.isLoggedIn()) {
      Get.find<TaxiHomeController>().getTaxiCouponList(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'offers'.tr),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: GetBuilder<TaxiHomeController>(
        builder: (taxiHomeController) {
          return taxiHomeController.taxiCouponList != null ? RefreshIndicator(
            onRefresh: () async {
              await taxiHomeController.getTaxiCouponList(true);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                
                // Coupon Input Header
                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  color: Theme.of(context).cardColor,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    
                    // Loyalty Points Section
                    Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.2)),
                      ),
                      child: Row(children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Use Rapido Coins'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                            Text('You don\'t have any coins currently'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                          ]),
                        ),
                        Text('0', style: robotoBold.copyWith(fontSize: 24)),
                        const SizedBox(width: 8),
                        Image.asset(Images.loyal, height: 25, width: 25),
                      ]),
                    ),
                    
                    const SizedBox(height: 25),
                    Text('Coupons'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    const SizedBox(height: 15),

                    // Search Input
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter Coupon Code'.tr,
                          hintStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          suffixIcon: TextButton(
                            onPressed: () {},
                            child: Text('APPLY'.tr, style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),

                const SizedBox(height: 10),

                // Coupon List
                taxiHomeController.taxiCouponList!.isNotEmpty ? ListView.builder(
                  itemCount: taxiHomeController.taxiCouponList!.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                  itemBuilder: (context, index) {
                    return CouponCard(couponModel: taxiHomeController.taxiCouponList![index], fromCouponScreen: true);
                  },
                ) : Column(children: [
                  const SizedBox(height: 50),
                  Center(child: Image.asset(Images.noCoupon, height: 70)),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Text('no_promo_available'.tr, style: robotoMedium),
                ]),

                const SizedBox(height: 100),
              ]),
            ),
          ) : const Center(child: CircularProgressIndicator());
        },
      )
    );
  }
}
