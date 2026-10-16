import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/item/controllers/campaign_controller.dart';
import 'package:sixam_mart/features/item/domain/models/basic_campaign_model.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class GroceryCampaignView extends StatelessWidget {
  final CampaignController campaignController;
  const GroceryCampaignView({super.key, required this.campaignController});

  @override
  Widget build(BuildContext context) {
    if (campaignController.basicCampaignList == null) {
      return const SizedBox();
    }
    if (campaignController.basicCampaignList!.isEmpty) {
      return const SizedBox();
    }

    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? 0 : Dimensions.paddingSizeSmall,
        vertical: Dimensions.paddingSizeDefault,
      ),
      decoration: BoxDecoration(
        gradient: Get.find<ThemeController>().darkTheme
            ? null
            : const LinearGradient(
                colors: [
                  Color(0xFFF4FBF7),
                  Color(0xFFE8F5E9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: Get.find<ThemeController>().darkTheme
            ? Theme.of(context).disabledColor.withValues(alpha: 0.15)
            : null,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Featured Campaign'.tr,
                    style: robotoBold.copyWith(
                      fontSize: 18,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Explore Your Need'.tr,
                    style: robotoRegular.copyWith(
                      fontSize: 12,
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => Get.toNamed(RouteHelper.getCategoryRoute()),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'see_all'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 10,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 175,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: campaignController.basicCampaignList!.length,
              itemBuilder: (context, index) {
                BasicCampaignModel campaign = campaignController.basicCampaignList![index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () => Get.toNamed(RouteHelper.getBasicCampaignRoute(campaign)),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 130,
                      decoration: BoxDecoration(
                        gradient: Get.find<ThemeController>().darkTheme ? null : const LinearGradient(
                          colors: [
                            Color(0xFFE8F5E9),
                            Color(0xFFC8E6C9),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        color: Get.find<ThemeController>().darkTheme ? Theme.of(context).cardColor : null,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Get.find<ThemeController>().darkTheme
                              ? Theme.of(context).primaryColor.withValues(alpha: 0.18)
                              : const Color(0xFF81C784).withValues(alpha: 0.5),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 12, left: 8, right: 8, bottom: 8),
                            child: Text(
                              campaign.title ?? '',
                              style: robotoBold.copyWith(
                                fontSize: 13,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                height: 1.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 6, left: 6, right: 6),
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                                color: Colors.transparent,
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                                child: CustomImage(
                                  image: '${campaign.imageFullUrl}',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
