import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/blinkit_ui.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';

import 'package:sixam_mart/common/widgets/cart_count_view.dart';
import 'package:sixam_mart/common/widgets/custom_favourite_widget.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
class SpecialOfferView extends StatelessWidget {
  final bool isFood;
  final bool isShop;
  const SpecialOfferView({super.key, required this.isFood, required this.isShop});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ItemController>(builder: (itemController) {
      List<Item>? discountedItemList = itemController.discountedItemList;

      return discountedItemList != null ? discountedItemList.isNotEmpty ? Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: BlinkitUi.sectionTint(), begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Special Offer', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    const AnimatedBlinkingBadge(),
                  ],
                ),
                InkWell(
                  onTap: () => Get.toNamed(RouteHelper.getItemViewAllScreen(false, true)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Text('See All', style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall)),
                        Icon(Icons.chevron_right, color: Theme.of(context).primaryColor, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: ResponsiveHelper.isDesktop(context) ? 2.0 : 0.75, 
              crossAxisSpacing: Dimensions.paddingSizeSmall,
              mainAxisSpacing: Dimensions.paddingSizeDefault,
            ),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
            itemCount: discountedItemList.length > 9 ? 9 : discountedItemList.length,
            itemBuilder: (context, index) {
              return CustomSpecialOfferCard(item: discountedItemList[index]);
            },
          ),
        ]),
      ) : const SizedBox() : const ItemShimmerView(isPopularItem: false);
    });
  }
}

class AnimatedBlinkingBadge extends StatefulWidget {
  const AnimatedBlinkingBadge({super.key});
  @override
  State<AnimatedBlinkingBadge> createState() => _AnimatedBlinkingBadgeState();
}

class _AnimatedBlinkingBadgeState extends State<AnimatedBlinkingBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
        child: const Icon(Icons.percent, size: 12, color: Colors.white),
      ),
    );
  }
}

class AnimatedProductDiscountBadge extends StatefulWidget {
  final double discount;
  final String discountType;
  const AnimatedProductDiscountBadge({super.key, required this.discount, required this.discountType});
  @override
  State<AnimatedProductDiscountBadge> createState() => _AnimatedProductDiscountBadgeState();
}

class _AnimatedProductDiscountBadgeState extends State<AnimatedProductDiscountBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 5, left: 5,
      child: FadeTransition(
        opacity: _controller,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(children: [
            const Icon(Icons.local_offer, color: Colors.white, size: 10),
            const SizedBox(width: 2),
            Text(
              widget.discountType == 'percent' ? '${widget.discount.toStringAsFixed(0)}% OFF' : '${PriceConverter.convertPrice(widget.discount)} OFF',
              style: robotoMedium.copyWith(color: Colors.white, fontSize: 8),
            ),
          ]),
        ),
      ),
    );
  }
}

class CustomSpecialOfferCard extends StatelessWidget {
  final Item item;
  const CustomSpecialOfferCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    double? discount = item.discount;
    String? discountType = item.discountType;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, spreadRadius: 1)],
      ),
      child: CustomInkWell(
        onTap: () => Get.find<ItemController>().navigateToItemPage(item, context),
        radius: 15,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Stack(children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                child: CustomImage(
                  image: '${item.imageFullUrl}',
                  fit: BoxFit.cover, width: double.infinity, height: double.infinity,
                ),
              ),
              if (discount != null && discount > 0)
                AnimatedProductDiscountBadge(discount: discount, discountType: discountType ?? 'percent'),
              Positioned(
                top: 8, right: 8,
                child: GetBuilder<FavouriteController>(builder: (favouriteController) {
                  bool isWished = favouriteController.wishItemIdList.contains(item.id);
                  return CustomFavouriteWidget(
                    isWished: isWished,
                    isStore: false,
                    item: item,
                    size: 20,
                  );
                }),
              ),
            ]),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Unit or Store Name + Timer
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.unitType ?? item.storeName ?? '',
                        style: robotoMedium.copyWith(fontSize: 9, color: Theme.of(context).disabledColor),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.access_time, size: 10, color: Colors.blue),
                    const SizedBox(width: 2),
                    Text('15Min', style: robotoMedium.copyWith(fontSize: 9, color: Colors.blue)),
                  ],
                ),
                const SizedBox(height: 2),

                // Title
                Text(
                  item.name ?? '',
                  style: robotoBold.copyWith(fontSize: 11),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Strikethrough Price (Original Price)
                if (discount != null && discount > 0)
                  Text(
                    PriceConverter.convertPrice(Get.find<ItemController>().getStartingPrice(item)),
                    style: robotoMedium.copyWith(fontSize: 9, color: Theme.of(context).disabledColor, decoration: TextDecoration.lineThrough),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  )
                else
                  const SizedBox(height: 12),

                // Final Price & ADD Button Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        PriceConverter.convertPrice(Get.find<ItemController>().getStartingPrice(item), discount: discount, discountType: discountType),
                        style: robotoBold.copyWith(fontSize: 11),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 2),
                    CartCountView(
                      item: item,
                      child: Container(
                        height: 24,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.center,
                        child: Text('ADD', style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: 10)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class ItemShimmerView extends StatelessWidget {
  final bool isPopularItem;
  const ItemShimmerView({super.key, required this.isPopularItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(height: 20, width: 120, color: Colors.grey[300]),
              Container(height: 20, width: 60, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(15))),
            ],
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: ResponsiveHelper.isDesktop(context) ? 2.0 : 0.75, 
            crossAxisSpacing: Dimensions.paddingSizeSmall,
            mainAxisSpacing: Dimensions.paddingSizeDefault,
          ),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Shimmer(
              duration: const Duration(seconds: 2),
              enabled: true,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                ),
                child: Column(children: [
                  Expanded(child: Container(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Container(height: 10, width: 40, color: Colors.grey[300]),
                      Container(height: 20, width: double.infinity, color: Colors.grey[300]),
                      Container(height: 10, width: 50, color: Colors.grey[300]),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(height: 15, width: 30, color: Colors.grey[300]),
                          Container(height: 15, width: 30, color: Colors.grey[300]),
                        ],
                      ),
                    ]),
                  ),
                ]),
              ),
            );
          },
        ),
      ]),
    );
  }
}
