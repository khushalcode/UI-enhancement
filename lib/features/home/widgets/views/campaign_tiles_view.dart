import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/item/controllers/campaign_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/blinkit_ui.dart';
import 'package:sixam_mart/util/dimensions.dart';

/// Square promo tiles with a themed border (reference video).
/// UI-only: tiles are the existing basic campaigns from CampaignController and
/// open the same campaign route as the middle-section banner does.
class CampaignTilesView extends StatelessWidget {
  final int maxItems;
  const CampaignTilesView({super.key, this.maxItems = 8});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CampaignController>(builder: (campaignController) {
      final list = campaignController.basicCampaignList;
      if (list != null && list.isEmpty) return const SizedBox();

      final int columns = ResponsiveHelper.isDesktop(context) ? 8 : 4;
      final int count = list == null ? 4 : (list.length > maxItems ? maxItems : list.length);
      final Color accent = BlinkitUi.accent();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1,
          ),
          itemCount: count,
          itemBuilder: (context, index) {
            if (list == null) {
              return Container(decoration: BoxDecoration(
                color: BlinkitUi.sectionTint()[0],
                borderRadius: BorderRadius.circular(14),
              ));
            }
            return InkWell(
              onTap: () => Get.toNamed(RouteHelper.getBasicCampaignRoute(list[index])),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent, width: 2),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomImage(image: '${list[index].imageFullUrl}', fit: BoxFit.cover),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
