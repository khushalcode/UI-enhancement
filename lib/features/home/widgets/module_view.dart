import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/common/widgets/address_widget.dart';
import 'package:sixam_mart/common/widgets/custom_ink_well.dart';
import 'package:sixam_mart/features/banner/controllers/banner_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';
import 'package:sixam_mart/common/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/home/widgets/banner_view.dart';
import 'package:sixam_mart/features/home/widgets/popular_store_view.dart';

class ModuleView extends StatelessWidget {
  final SplashController splashController;
  const ModuleView({super.key, required this.splashController});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      GetBuilder<BannerController>(builder: (bannerController) {
        return const BannerView(isFeatured: true);
      }),

      splashController.moduleList != null ? splashController.moduleList!.isNotEmpty ? 
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeDefault),
        child: _buildStaggeredGrid(context, splashController),
      ) : Center(child: Padding(
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall), child: Text('no_module_found'.tr),
      )) : ModuleShimmer(isEnabled: splashController.moduleList == null),

      GetBuilder<AddressController>(builder: (locationController) {
        List<AddressModel?> addressList = [];
        if(AuthHelper.isLoggedIn() && locationController.addressList != null) {
          addressList = [];
          bool contain = false;
          if(AddressHelper.getUserAddressFromSharedPref()!.id != null) {
            for(int index=0; index<locationController.addressList!.length; index++) {
              if(locationController.addressList![index].id == AddressHelper.getUserAddressFromSharedPref()!.id) {
                contain = true;
                break;
              }
            }
          }
          if(!contain) {
            addressList.add(AddressHelper.getUserAddressFromSharedPref());
          }
          addressList.addAll(locationController.addressList!);
        }
        // Deliver To section is hidden
        return const SizedBox();
      }),

      const PopularStoreView(isPopular: false, isFeatured: true),

      const SizedBox(height: 120),

    ]);
  }

  Widget _buildStaggeredGrid(BuildContext context, SplashController splashController) {
    List<dynamic> modules = splashController.moduleList ?? [];
    if (modules.isEmpty) return const SizedBox();
    
    double spacing = Dimensions.paddingSizeSmall;
    double screenWidth = MediaQuery.of(context).size.width - (Dimensions.paddingSizeSmall * 2);
    double itemWidth = (screenWidth - (spacing * 2)) / 3;
    double itemHeight = itemWidth * 1.25; // Making the cards taller as per the screenshot
    double tallHeight = (itemHeight * 2) + spacing;

    List<Widget> rows = [];
    
    // Top Row: Tall item on left, 2x2 grid on right
    if (modules.isNotEmpty) {
      List<Widget> topRightItems = [];
      for(int i = 1; i < 5 && i < modules.length; i++) {
        topRightItems.add(
          SizedBox(
            width: itemWidth, height: itemHeight,
            child: _buildModuleCard(context, splashController, i),
          )
        );
      }
      
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tall Item
            SizedBox(
              width: itemWidth, height: tallHeight,
              child: _buildModuleCard(context, splashController, 0, isTall: true),
            ),
            SizedBox(width: spacing),
            // Top Right Grid
            Expanded(
              child: Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: topRightItems,
              ),
            ),
          ],
        )
      );
    }
    
    // Remaining Items
    if (modules.length > 5) {
      rows.add(SizedBox(height: spacing));
      List<Widget> remainingItems = [];
      for(int i = 5; i < modules.length; i++) {
        remainingItems.add(
          SizedBox(
            width: itemWidth, height: itemHeight,
            child: _buildModuleCard(context, splashController, i),
          )
        );
      }
      rows.add(
        Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: remainingItems,
        )
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }

  Widget _buildModuleCard(BuildContext context, SplashController splashController, int index, {bool isTall = false}) {
    var module = splashController.moduleList![index];
    return CustomInkWell(
      onTap: () => splashController.switchModule(index, true),
      radius: Dimensions.radiusLarge,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 0.2),
              Theme.of(context).primaryColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2), width: 1.5),
          boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.05), blurRadius: 8, spreadRadius: 1, offset: const Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              child: CustomImage(
                image: '${module.iconFullUrl}',
                height: isTall ? 100 : 65, 
                width: isTall ? 100 : 65,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: isTall ? Dimensions.paddingSizeExtraLarge : Dimensions.paddingSizeDefault),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
              child: Text(
                module.moduleName ?? '',
                textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ModuleShimmer extends StatelessWidget {
  final bool isEnabled;
  const ModuleShimmer({super.key, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, mainAxisSpacing: Dimensions.paddingSizeSmall,
        crossAxisSpacing: Dimensions.paddingSizeSmall, childAspectRatio: (1/1),
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      itemCount: 6,
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            color: Theme.of(context).cardColor,
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
          ),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: isEnabled,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

              Container(
                height: 65, width: 65,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusSmall), color: Colors.grey[300]),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Center(child: Container(height: 15, width: 50, color: Colors.grey[300])),

            ]),
          ),
        );
      },
    );
  }
}

class AddressShimmer extends StatelessWidget {
  final bool isEnabled;
  const AddressShimmer({super.key, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: Dimensions.paddingSizeLarge),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          child: TitleWidget(title: 'deliver_to'.tr),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        SizedBox(
          height: 70,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: 5,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
            itemBuilder: (context, index) {
              return Container(
                width: 300,
                padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                child: Container(
                  padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeDefault
                      : Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      Icons.location_on,
                      size: ResponsiveHelper.isDesktop(context) ? 50 : 40, color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: Shimmer(
                        duration: const Duration(seconds: 2),
                        enabled: isEnabled,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Container(height: 15, width: 100, color: Colors.grey[300]),
                          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                          Container(height: 10, width: 150, color: Colors.grey[300]),
                        ]),
                      ),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


