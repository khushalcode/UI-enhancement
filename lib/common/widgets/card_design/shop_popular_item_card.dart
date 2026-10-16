import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/add_favourite_view.dart';
import 'package:sixam_mart/common/widgets/cart_count_view.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';

class ShopPopularItemCard extends StatelessWidget {
  final Item item;
  final int? index;
  const ShopPopularItemCard({super.key, required this.item, this.index});

  @override
  Widget build(BuildContext context) {
    double? discount = item.discount;
    String? discountType = item.discountType;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image and floating badges
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => Get.find<ItemController>().navigateToItemPage(item, context),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: CustomImage(
                      image: '${item.imageFullUrl}',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
                // Blinking discount badge
                if (discount != null && discount > 0)
                  BlinkingDiscountBadge(discount: discount, discountType: discountType ?? 'percent'),
                // Favorite button
                Positioned(
                  top: 8,
                  right: 8,
                  child: AddFavouriteView(item: item),
                ),
              ],
            ),
          ),

          // Details section
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Unit & Delivery Time
                  Row(
                    children: [
                      Text(
                        item.unitType ?? 'Pieces',
                        style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).disabledColor),
                      ),
                      const SizedBox(width: 4),
                      Text('|', style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).disabledColor)),
                      const SizedBox(width: 4),
                      Icon(Icons.access_time, color: Theme.of(context).primaryColor, size: 10),
                      const SizedBox(width: 2),
                      Text('15Min', style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: 9)),
                    ],
                  ),

                  // Product name
                  GestureDetector(
                    onTap: () => Get.find<ItemController>().navigateToItemPage(item, context),
                    child: Text(
                      item.name ?? '',
                      style: robotoBold.copyWith(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Struck-through original price
                  if (discount != null && discount > 0)
                    Text(
                      PriceConverter.convertPrice(Get.find<ItemController>().getStartingPrice(item)),
                      style: robotoRegular.copyWith(
                        fontSize: 10,
                        color: Theme.of(context).disabledColor,
                        decoration: TextDecoration.lineThrough,
                      ),
                    )
                  else
                    const SizedBox(height: 12),

                  // Price and ADD button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          PriceConverter.convertPrice(
                            Get.find<ItemController>().getStartingPrice(item),
                            discount: discount,
                            discountType: discountType,
                          ),
                          style: robotoBold.copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      CartCountView(
                        item: item,
                        index: index,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            border: Border.all(color: Theme.of(context).primaryColor, width: 1.0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'ADD',
                            style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BlinkingDiscountBadge extends StatefulWidget {
  final double discount;
  final String discountType;
  const BlinkingDiscountBadge({super.key, required this.discount, required this.discountType});

  @override
  State<BlinkingDiscountBadge> createState() => _BlinkingDiscountBadgeState();
}

class _BlinkingDiscountBadgeState extends State<BlinkingDiscountBadge> with SingleTickerProviderStateMixin {
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
      top: 8,
      left: 8,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF019B4C).withValues(alpha: 0.3 + (_controller.value * 0.7)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: child,
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_offer, color: Colors.white, size: 10),
            const SizedBox(width: 2),
            Text(
              widget.discountType == 'percent' ? '${widget.discount.toStringAsFixed(0)}% OFF' : '${PriceConverter.convertPrice(widget.discount)} OFF',
              style: robotoBold.copyWith(color: Colors.white, fontSize: 8),
            ),
          ],
        ),
      ),
    );
  }
}
