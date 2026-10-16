import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/common/widgets/add_favourite_view.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/common/widgets/hover/text_hover.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/common/models/module_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/discount_tag.dart';
import 'package:sixam_mart/common/widgets/hover/on_hover.dart';
import 'package:sixam_mart/common/widgets/not_available_widget.dart';
import 'package:sixam_mart/common/widgets/closing_soon_widget.dart';
import 'package:sixam_mart/features/store/screens/store_screen.dart';

class StoreCardWidget extends StatelessWidget {
  final Store? store;
  const StoreCardWidget({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    double? discount = store!.discount != null ? store!.discount!.discount : 0;
    String? discountType = store!.discount != null ? store!.discount!.discountType : 'percent';
    bool isAvailable = store!.open == 1 && store!.active!;
    return OnHover(
      isItem: true,
      child: TextHover(
        builder: (hovered) {
          return Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                  boxShadow: ResponsiveHelper.isDesktop(context) ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, spreadRadius: 1, offset: const Offset(0, 5))],
                ),
                child: CustomInkWell(
                  onTap: () {
                    if(store != null) {
                      if(Get.find<SplashController>().moduleList != null) {
                        for(ModuleModel module in Get.find<SplashController>().moduleList!) {
                          if(module.id == store!.moduleId) {
                            Get.find<SplashController>().setModule(module);
                            break;
                          }
                        }
                      }
                      Get.toNamed(
                        RouteHelper.getStoreRoute(id: store!.id, page: 'item'),
                        arguments: StoreScreen(store: store, fromModule: false),
                      );
                    }
                  },
                  radius: 24,
                  padding: const EdgeInsets.all(1),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

                    Stack(clipBehavior: Clip.none, children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        child: CustomImage(
                          isHovered: hovered,
                          image: '${store!.coverPhotoFullUrl}',
                          height: 120, width: double.infinity, fit: BoxFit.cover,
                        ),
                      ),
                      DiscountTag(
                        discount: discount, discountType: discountType,
                      ),
                      isAvailable ? ClosingSoonWidget(store: store!, fontSize: Dimensions.fontSizeExtraSmall) : NotAvailableWidget(isStore: true, store: store, fontSize: Dimensions.fontSizeExtraSmall, isAllSideRound: false),

                      AddFavouriteView(
                        top: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
                        item: null, storeId: store!.id,
                      ),

                      Positioned(
                        top: 10, left: 10,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              color: Colors.white.withOpacity(0.2),
                              child: Row(children: [
                                const Icon(Icons.timer, size: 12, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  '${store!.deliveryTime}',
                                  style: robotoMedium.copyWith(fontSize: 10, color: Colors.white),
                                ),
                              ]),
                            ),
                          ),
                        ),
                      ),

                      store!.ratingCount! > 0 ? Positioned(
                        bottom: -15,
                        left: Get.find<LocalizationController>().isLtr ? null : 10,
                        right: Get.find<LocalizationController>().isLtr ? 10 : null,
                        child: Container(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: const BorderRadius.all(Radius.circular(100)),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 1)],
                          ),
                          child: Row(children: [
                            const Icon(Icons.star, size: 15, color: Color(0xFFFF6B00)),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                            Text(
                              store!.avgRating!.toStringAsFixed(1),
                              style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: const Color(0xFF2D2D2D)),
                            ),
                          ]),
                        ),
                      ) : const SizedBox(),
                    ]),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                          SizedBox(
                            width: context.width * 0.7,
                            child: Text(
                              store!.name ?? '',
                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: const Color(0xFF2D2D2D)),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                          Row(children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFFFF6B00)),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                            Flexible(
                              child: Text(
                                store!.address ?? '',
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ]),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                          Row(children: [
                            store!.freeDelivery! ? Row(children: [
                              Image.asset(Images.deliveryIcon, height: 14, width: 14, color: const Color(0xFFFF6B00)),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                              Text(
                                'free_delivery'.tr,
                                style: robotoMedium.copyWith(fontSize: 10, color: Theme.of(context).disabledColor),
                              ),
                            ]) : const SizedBox(),
                          ]),
                        ]),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}


class StoreCardShimmer extends StatelessWidget {
  const StoreCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return  Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      width: 500,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      ),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Container(
            height: 120, width: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              color: Theme.of(context).shadowColor,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(height: 15, width: 200, color: Theme.of(context).shadowColor),
                const SizedBox(height: 5),

                Container(height: 10, width: 130, color: Theme.of(context).shadowColor),
                const SizedBox(height: 5),

                Row(
                  children: List.generate(5, (index) {
                    return Icon(Icons.star, color: Theme.of(context).shadowColor, size: 15);
                  }),
                ),

              ]),
            ),
          ),

        ]),
      ),
    );
  }
}