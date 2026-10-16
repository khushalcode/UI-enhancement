import 'package:flutter/material.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';

class DeliverItemCardWidget extends StatelessWidget {
  final String image;
  final String itemName;
  final String description;
  final bool isDeliverItem;
  const DeliverItemCardWidget({super.key, required this.image, required this.itemName, required this.description, this.isDeliverItem = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: isDeliverItem ? Colors.white : Theme.of(context).cardColor.withValues(alpha: 0.5),
        border: Border.all(color: isDeliverItem ? Colors.grey.withValues(alpha: 0.2) : Theme.of(context).cardColor),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: isDeliverItem ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, spreadRadius: 1)] : null,
      ),
      child: isDeliverItem ? Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomImage(
            image: image,
            height: 40, width: 40,
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Text(itemName, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoBold, textAlign: TextAlign.center),
          const SizedBox(height: 2),

          Text(
            description,
            maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
            style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
          ),
        ],
      ) : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CustomImage(
          image: image,
          height: 30, width: 30,
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: ResponsiveHelper.isDesktop(context) ? MainAxisAlignment.start : MainAxisAlignment.spaceBetween, children: [
            Text(itemName, maxLines: 1, overflow: TextOverflow.ellipsis, style: robotoMedium),
            SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeSmall : 0),

            Text(
              description,
              maxLines: 2, overflow: TextOverflow.ellipsis,
              style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall),
            ),
          ]),
        ),
      ]),
    );
  }
}
