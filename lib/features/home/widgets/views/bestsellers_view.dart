import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/item/domain/models/item_model.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/blinkit_ui.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

/// "Bestsellers" mini-category cards (reference video).
/// UI-only: categories come from CategoryController and the 2x2 thumbnails are
/// built from items ALREADY loaded by ItemController (popular / reviewed /
/// recommended / discounted). No new API calls; tap opens the same category route.
class BestsellersView extends StatelessWidget {
  const BestsellersView({super.key});

  List<Item> _itemsFor(ItemController itemController, int? categoryId) {
    final List<Item> pool = [
      ...?itemController.popularItemList,
      ...?itemController.reviewedItemList,
      ...?itemController.recommendedItemList,
      ...?itemController.discountedItemList,
    ];
    final Set<int?> seen = {};
    final List<Item> result = [];
    for (final Item item in pool) {
      if (item.imageFullUrl == null || !seen.add(item.id)) continue;
      final bool match = item.categoryId == categoryId || (item.categoryIds?.any((c) => c.id == categoryId) ?? false);
      if (match) result.add(item);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(builder: (categoryController) {
      return GetBuilder<ItemController>(builder: (itemController) {
        final bool loading = categoryController.categoryList == null;
        if (!loading && categoryController.categoryList!.isEmpty) return const SizedBox();

        final int count = loading ? 6 : (categoryController.categoryList!.length > 6 ? 6 : categoryController.categoryList!.length);
        final int columns = ResponsiveHelper.isDesktop(context) ? 6 : 3;

        return Padding(
          padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeSmall, Dimensions.paddingSizeExtraSmall, Dimensions.paddingSizeSmall, Dimensions.paddingSizeExtraSmall),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text('Bestsellers', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: BlinkitUi.ink)),
            ),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.82,
              ),
              itemCount: count,
              itemBuilder: (context, index) {
                if (loading) return _card(context, null, const []);
                final category = categoryController.categoryList![index];
                return _card(context, category, _itemsFor(itemController, category.id));
              },
            ),
          ]),
        );
      });
    });
  }

  Widget _thumb(String? url) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: url == null ? null : ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CustomImage(image: url, fit: BoxFit.cover),
      ),
    );
  }

  Widget _card(BuildContext context, dynamic category, List<Item> items) {
    final bool skeleton = category == null;
    final bool useGrid = items.length >= 2;

    return InkWell(
      onTap: skeleton ? null : () => Get.toNamed(RouteHelper.getCategoryItemRoute(category.id, category.name!)),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: skeleton ? BlinkitUi.sectionTint()[0].withValues(alpha: 0.6) : BlinkitUi.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(children: [
          Expanded(
            child: skeleton ? const SizedBox() : useGrid ? Column(children: [
              Expanded(child: Row(children: [
                Expanded(child: _thumb(items[0].imageFullUrl)),
                const SizedBox(width: 4),
                Expanded(child: _thumb(items.length > 1 ? items[1].imageFullUrl : null)),
              ])),
              const SizedBox(height: 4),
              Expanded(child: Row(children: [
                Expanded(child: _thumb(items.length > 2 ? items[2].imageFullUrl : null)),
                const SizedBox(width: 4),
                Expanded(child: _thumb(items.length > 3 ? items[3].imageFullUrl : null)),
              ])),
            ]) : ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomImage(image: '${category.imageFullUrl}', fit: BoxFit.contain, width: double.infinity),
            ),
          ),
          if (!skeleton && items.length > 4) Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text('+${items.length - 4} More', style: robotoRegular.copyWith(fontSize: 10, color: BlinkitUi.ink.withValues(alpha: 0.7))),
          ),
          const SizedBox(height: 4),
          Text(
            skeleton ? '' : (category.name ?? ''),
            style: robotoBold.copyWith(fontSize: 12, color: BlinkitUi.ink),
            maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
          ),
        ]),
      ),
    );
  }
}
