import 'package:sixam_mart/features/coupon/controllers/coupon_controller.dart';
import 'package:sixam_mart/features/cab_booking/home/controllers/cab_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/no_data_screen.dart';
import 'package:sixam_mart/common/widgets/not_logged_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/web_page_title_widget.dart';
import 'package:sixam_mart/features/coupon/widgets/coupon_card_widget.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class CouponScreen extends StatefulWidget {
  const CouponScreen({super.key});

  @override
  State<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {

  ScrollController scrollController = ScrollController();
  final TextEditingController _couponTextController = TextEditingController();
  @override
  void initState() {
    super.initState();

    initCall();
  }

  void initCall(){
    if(AuthHelper.isLoggedIn()) {
      Get.find<CouponController>().getCouponList();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: 'offers'.tr),
      endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
      body: isLoggedIn ? GetBuilder<CouponController>(builder: (couponController) {
        return couponController.couponList != null ? RefreshIndicator(
          onRefresh: () async {
            await couponController.getCouponList();
          },
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Center(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  
                  // Coupon Input Header
                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    color: Theme.of(context).cardColor,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      
                      // Loyalty Points Section (Similar to Rapido Coins)
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
                              Text('Use Loyalty Points'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                              Text('You have some points to spend'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                            ]),
                          ),
                          Text('${Get.find<CouponController>().couponList?.length ?? 0}', style: robotoBold.copyWith(fontSize: 24)),
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
                          controller: _couponTextController,
                          decoration: InputDecoration(
                            hintText: 'Enter Coupon Code'.tr,
                            hintStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            suffixIcon: TextButton(
                              onPressed: () {
                                String code = _couponTextController.text.trim();
                                if(code.isNotEmpty) {
                                  if(Get.isRegistered<CabController>()) {
                                    Get.find<CabController>().applyCoupon(code);
                                    Get.back();
                                  } else {
                                    showCustomSnackBar('coupon_applied_to_cart'.tr, isError: false);
                                  }
                                } else {
                                  showCustomSnackBar('enter_coupon_code'.tr);
                                }
                              },
                              child: Text('APPLY'.tr, style: robotoBold.copyWith(color: Theme.of(context).primaryColor)),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),

                  const SizedBox(height: 10),

                  // Coupon List
                  couponController.couponList!.isNotEmpty ? GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveHelper.isDesktop(context) ? 3 : ResponsiveHelper.isTab(context) ? 2 : 1,
                      mainAxisSpacing: Dimensions.paddingSizeSmall, crossAxisSpacing: Dimensions.paddingSizeSmall,
                      childAspectRatio: ResponsiveHelper.isMobile(context) ? 2.8 : 3,
                    ),
                    itemCount: couponController.couponList!.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    itemBuilder: (context, index) {
                      return CouponCardWidget(coupon: couponController.couponList![index], index: index);
                    },
                  ) : NoDataScreen(text: 'no_coupon_found'.tr),
                  
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ),
        ) : const Center(child: CircularProgressIndicator());
      }) : NotLoggedInScreen(callBack: (bool value) {
        initCall();
        setState(() {});
      }),
    );
  }
}