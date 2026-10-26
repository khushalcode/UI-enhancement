import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:sixam_mart/features/banner/controllers/banner_controller.dart';
import 'package:sixam_mart/features/brands/controllers/brands_controller.dart';
import 'package:sixam_mart/features/home/controllers/advertisement_controller.dart';
import 'package:sixam_mart/features/home/controllers/home_controller.dart';
import 'package:sixam_mart/features/home/widgets/all_store_filter_widget.dart';
import 'package:sixam_mart/features/home/widgets/refer_bottom_sheet_widget.dart';
import 'package:sixam_mart/features/item/controllers/campaign_controller.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/coupon/controllers/coupon_controller.dart';
import 'package:sixam_mart/features/flash_sale/controllers/flash_sale_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/notification/controllers/notification_controller.dart';
import 'package:sixam_mart/features/item/controllers/item_controller.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/address/controllers/address_controller.dart';
import 'package:sixam_mart/features/home/screens/modules/food_home_screen.dart';
import 'package:sixam_mart/features/home/screens/modules/grocery_home_screen.dart';
import 'package:sixam_mart/features/home/screens/modules/pharmacy_home_screen.dart';
import 'package:sixam_mart/features/home/screens/modules/shop_home_screen.dart';
import 'package:sixam_mart/features/parcel/controllers/parcel_controller.dart';
import 'package:sixam_mart/features/rental_module/home/controllers/taxi_home_controller.dart';
import 'package:sixam_mart/features/rental_module/home/screens/taxi_home_screen.dart';
import 'package:sixam_mart/features/cab_booking/home/screens/cab_home_screen.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/controllers/taxi_cart_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/blinkit_ui.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/voice_search_widget.dart';
import 'package:sixam_mart/common/widgets/item_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/paginated_list_view.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:sixam_mart/features/home/screens/web_new_home_screen.dart';
import 'package:sixam_mart/common/widgets/cart_widget.dart';
import 'package:sixam_mart/common/widgets/module_tabs_bar.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/home/widgets/module_view.dart';
import 'package:sixam_mart/features/home/widgets/unified_home_feed.dart';
import 'package:sixam_mart/features/parcel/screens/parcel_category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});


  static Future<void> loadData(bool reload, {bool fromModule = false}) async {
    Get.find<LocationController>().syncZoneData();
    Get.find<FlashSaleController>().setEmptyFlashSale(fromModule: fromModule);
    if(AuthHelper.isLoggedIn()) {
      Get.find<StoreController>().getVisitAgainStoreList(fromModule: fromModule);
    }
    if(Get.find<SplashController>().module != null && !Get.find<SplashController>().configModel!.moduleConfig!.module!.isParcel! && !Get.find<SplashController>().configModel!.moduleConfig!.module!.isTaxi!) {
      Get.find<BannerController>().getBannerList(reload);
      Get.find<StoreController>().getRecommendedStoreList();
      if(Get.find<SplashController>().module!.moduleType.toString() == AppConstants.grocery) {
        Get.find<FlashSaleController>().getFlashSale(reload, false);
      }
      if(Get.find<SplashController>().module!.moduleType.toString() == AppConstants.ecommerce) {
        Get.find<ItemController>().getFeaturedCategoriesItemList(false, false);
        Get.find<FlashSaleController>().getFlashSale(reload, false);
        Get.find<BrandsController>().getBrandList();
      }
      Get.find<BannerController>().getPromotionalBannerList(reload);
      Get.find<ItemController>().getDiscountedItemList(offset: '1', firstTimeCategoryLoad: true);
      Get.find<ItemController>().getPopularItemList(offset: '1', firstTimeCategoryLoad: true);
      Get.find<ItemController>().getReviewedItemList(offset: '1', firstTimeCategoryLoad: true);
      Get.find<CategoryController>().getCategoryList(reload);
      Get.find<StoreController>().getPopularStoreList(reload, 'all', false);
      Get.find<CampaignController>().getBasicCampaignList(reload);
      Get.find<CampaignController>().getItemCampaignList(reload);
      Get.find<StoreController>().getLatestStoreList(reload, 'all', false);
      Get.find<StoreController>().getTopOfferStoreList(reload, false);
      Get.find<ItemController>().getRecommendedItemList(reload, 'all', false);
      Get.find<StoreController>().getStoreList(1, reload);
      Get.find<AdvertisementController>().getAdvertisementList();
    }
    if(AuthHelper.isLoggedIn()) {
      await Get.find<ProfileController>().getUserInfo();
      Get.find<NotificationController>().getNotificationList(reload);
      Get.find<CouponController>().getCouponList();
    }
    Get.find<SplashController>().getModules();
    if(Get.find<SplashController>().module == null && Get.find<SplashController>().configModel!.module == null) {
      Get.find<BannerController>().getFeaturedBanner();
      Get.find<StoreController>().getFeaturedStoreList();
      // Load cross-module data so the UnifiedHomeFeed has content to show
      // before the user picks a specific module.
      Get.find<CategoryController>().getCategoryList(false);
      Get.find<BannerController>().getPromotionalBannerList(false);
      Get.find<ItemController>().getDiscountedItemList(offset: '1', firstTimeCategoryLoad: true);
      Get.find<ItemController>().getPopularItemList(offset: '1', firstTimeCategoryLoad: true);
      Get.find<ItemController>().getReviewedItemList(offset: '1', firstTimeCategoryLoad: true);
      Get.find<ItemController>().getRecommendedItemList(false, 'all', false);
      Get.find<StoreController>().getPopularStoreList(false, 'all', false);
      Get.find<StoreController>().getLatestStoreList(false, 'all', false);
      Get.find<StoreController>().getTopOfferStoreList(false, false);
      Get.find<StoreController>().getStoreList(1, false);
      Get.find<CampaignController>().getBasicCampaignList(false);
      Get.find<CampaignController>().getItemCampaignList(false);
      Get.find<AdvertisementController>().getAdvertisementList();
      if(AuthHelper.isLoggedIn()) {
        Get.find<AddressController>().getAddressList();
      }
    }
    if(Get.find<SplashController>().module != null && Get.find<SplashController>().configModel!.moduleConfig!.module!.isParcel!) {
      Get.find<ParcelController>().getParcelCategoryList();
    }
    if(Get.find<SplashController>().module != null && Get.find<SplashController>().module!.moduleType.toString() == AppConstants.pharmacy) {
      Get.find<ItemController>().getBasicMedicine(reload, false);
      Get.find<StoreController>().getFeaturedStoreList();
      await Get.find<ItemController>().getCommonConditions(false);
      if(Get.find<ItemController>().commonConditions!.isNotEmpty) {
        Get.find<ItemController>().getConditionsWiseItem(Get.find<ItemController>().commonConditions![0].id!, false);
      }
    }
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool searchBgShow = false;
  final GlobalKey _headerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    HomeScreen.loadData(false).then((value) {
      Get.find<SplashController>().getReferBottomSheetStatus();

      if((Get.find<ProfileController>().userInfoModel?.isValidForDiscount??false) && Get.find<SplashController>().showReferBottomSheet) {
        _showReferBottomSheet();
      }
    });

    if(!ResponsiveHelper.isWeb()) {
      Get.find<LocationController>().getZone(
        AddressHelper.getUserAddressFromSharedPref()!.latitude,
        AddressHelper.getUserAddressFromSharedPref()!.longitude, false, updateInAddress: true,
      );
    }

    _scrollController.addListener(() {
      if(_scrollController.position.userScrollDirection == ScrollDirection.reverse){
        if(Get.find<HomeController>().showFavButton){
          Get.find<HomeController>().changeFavVisibility();
          Future.delayed(const Duration(milliseconds: 800), () => Get.find<HomeController>().changeFavVisibility());
        }
      }else {
        if(Get.find<HomeController>().showFavButton){
          Get.find<HomeController>().changeFavVisibility();
          Future.delayed(const Duration(milliseconds: 800), () => Get.find<HomeController>().changeFavVisibility());
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void _showReferBottomSheet() {
    ResponsiveHelper.isDesktop(context) ? Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge)),
        insetPadding: const EdgeInsets.all(22),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: const ReferBottomSheetWidget(),
      ),
      useSafeArea: false,
    ).then((value) => Get.find<SplashController>().saveReferBottomSheetStatus(false))
        : showModalBottomSheet(
      isScrollControlled: true, useRootNavigator: true, context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: const ReferBottomSheetWidget(),
        );
      },
    ).then((value) => Get.find<SplashController>().saveReferBottomSheetStatus(false));
  }

  Future<void> loadTaxiApis() async{
   await Get.find<TaxiHomeController>().getTaxiBannerList(true);
   await Get.find<TaxiHomeController>().getTopRatedCarList(1, true);
    if (AuthHelper.isLoggedIn()) {
      await Get.find<AddressController>().getAddressList();
      await Get.find<TaxiHomeController>().getTaxiCouponList(true);
      await Get.find<TaxiCartController>().getCarCartList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (splashController) {
      if(splashController.moduleList != null && splashController.moduleList!.length == 1) {
        splashController.switchModule(0, true);
      }
      bool showMobileModule = !ResponsiveHelper.isDesktop(context) && splashController.module == null && splashController.configModel!.module == null;
      bool isParcel = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.parcel;
      bool isPharmacy = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.pharmacy;
      bool isFood = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.food;
      bool isShop = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.ecommerce;
      bool isGrocery = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.grocery;
      bool isTaxi = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.taxi;
      bool isCab = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.cab;

      return GetBuilder<HomeController>(builder: (homeController) {
        return Scaffold(
          appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
          endDrawer: const MenuDrawer(),
          endDrawerEnableOpenDragGesture: false,
          body: isParcel ? const _ModuleScreenWithTabs(child: ParcelCategoryScreen()) : isCab ? const _ModuleScreenWithTabs(child: CabHomeScreen()) : RefreshIndicator(
              onRefresh: () async {
                splashController.setRefreshing(true);
                if (Get.find<SplashController>().module != null && !isTaxi && !isCab) {
                  await Get.find<LocationController>().syncZoneData();
                  await Get.find<BannerController>().getBannerList(true);
                  if (isGrocery) {
                    await Get.find<FlashSaleController>().getFlashSale(true, true);
                  }
                  await Get.find<BannerController>().getPromotionalBannerList(true);
                  await Get.find<ItemController>().getDiscountedItemList(offset: '1');
                  await Get.find<CategoryController>().getCategoryList(true);
                  await Get.find<StoreController>().getPopularStoreList(true, 'all', false);
                  await Get.find<CampaignController>().getItemCampaignList(true);
                  Get.find<CampaignController>().getBasicCampaignList(true);
                  await Get.find<ItemController>().getPopularItemList(offset: '1');
                  await Get.find<StoreController>().getLatestStoreList(true, 'all', false);
                  await Get.find<StoreController>().getTopOfferStoreList(true, false);
                  await Get.find<ItemController>().getReviewedItemList(offset: '1');
                  await Get.find<StoreController>().getStoreList(1, true);
                  Get.find<AdvertisementController>().getAdvertisementList();
                  if (AuthHelper.isLoggedIn()) {
                    await Get.find<ProfileController>().getUserInfo();
                    await Get.find<NotificationController>().getNotificationList(true);
                    Get.find<CouponController>().getCouponList();
                  }
                  if (isPharmacy) {
                    Get.find<ItemController>().getBasicMedicine(true, true);
                    Get.find<ItemController>().getCommonConditions(true);
                  }
                  if (isShop) {
                    await Get.find<FlashSaleController>().getFlashSale(true, true);
                    Get.find<ItemController>().getFeaturedCategoriesItemList(true, true);
                    Get.find<BrandsController>().getBrandList();
                  }
                } else if(isTaxi) {
                  await loadTaxiApis();
                } else {
                  await Get.find<BannerController>().getFeaturedBanner();
                  await Get.find<SplashController>().getModules();
                  if (AuthHelper.isLoggedIn()) {
                    await Get.find<AddressController>().getAddressList();
                  }
                  await Get.find<StoreController>().getFeaturedStoreList();
                  // Refresh cross-module data for the UnifiedHomeFeed
                  await Get.find<CategoryController>().getCategoryList(true);
                  await Get.find<BannerController>().getPromotionalBannerList(true);
                  await Get.find<ItemController>().getDiscountedItemList(offset: '1');
                  await Get.find<ItemController>().getPopularItemList(offset: '1');
                  await Get.find<ItemController>().getReviewedItemList(offset: '1');
                  await Get.find<ItemController>().getRecommendedItemList(true, 'all', false);
                  await Get.find<StoreController>().getPopularStoreList(true, 'all', false);
                  await Get.find<StoreController>().getLatestStoreList(true, 'all', false);
                  await Get.find<StoreController>().getTopOfferStoreList(true, false);
                  await Get.find<StoreController>().getStoreList(1, true);
                  Get.find<CampaignController>().getBasicCampaignList(true);
                  await Get.find<CampaignController>().getItemCampaignList(true);
                  Get.find<AdvertisementController>().getAdvertisementList();
                }
                splashController.setRefreshing(false);
              },
              child: ResponsiveHelper.isDesktop(context) ? WebNewHomeScreen(
                scrollController: _scrollController,
              ) : CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [

                  /// Status bar strip (keeps the accent colour behind the system bar)
                  SliverAppBar(
                    pinned: true, elevation: 0, toolbarHeight: 0, automaticallyImplyLeading: false,
                    surfaceTintColor: Colors.transparent, backgroundColor: BlinkitUi.accent(),
                    actions: const [SizedBox()],
                  ),

                  /// Header: brand, delivery time, address, wallet and profile
                  SliverToBoxAdapter(
                    child: Container(
                      color: BlinkitUi.accent(),
                      padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 2, Dimensions.paddingSizeDefault, 4),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

                        (splashController.module != null && splashController.configModel!.module == null && splashController.moduleList != null && splashController.moduleList!.length != 1) ? Padding(
                          padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                          child: InkWell(
                            onTap: () {
                              splashController.removeModule();
                              Get.find<StoreController>().resetStoreData();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                              child: const Icon(Icons.arrow_back, color: Colors.black, size: 18),
                            ),
                          ),
                        ) : const SizedBox(),

                        /// Location section
                        Expanded(child: InkWell(
                          onTap: () => Get.find<LocationController>().navigateToLocationScreen('home'),
                          child: GetBuilder<LocationController>(builder: (locationController) {
                            final Color textColor = BlinkitUi.onAccent();
                            return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text(AppConstants.appName, style: robotoMedium.copyWith(color: textColor.withValues(alpha: 0.75), fontSize: Dimensions.fontSizeSmall), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(
                                (isFood || isGrocery || isShop) ? '21 minutes' : (AuthHelper.isLoggedIn() ? AddressHelper.getUserAddressFromSharedPref()!.addressType!.tr : 'your_location'.tr),
                                style: robotoBold.copyWith(color: textColor, fontSize: 22, height: 1.1),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ]);
                          }),
                        )),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        /// Wallet
                        InkWell(
                          onTap: () {
                            if(AuthHelper.isLoggedIn()){
                              Get.toNamed(RouteHelper.getWalletRoute());
                            }else {
                              Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.main));
                            }
                          },
                          child: GetBuilder<ProfileController>(builder: (profileController) {
                            final bool showBalance = AuthHelper.isLoggedIn() && profileController.userInfoModel != null;
                            return SizedBox(
                              width: 44, height: 46,
                              child: Stack(alignment: Alignment.topCenter, children: [
                                Container(
                                  width: 38, height: 38,
                                  decoration: BoxDecoration(
                                    color: Colors.white, shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
                                  ),
                                  child: Center(child: Image.asset(Images.walletIcon, height: 20, width: 20, color: BlinkitUi.ink)),
                                ),
                                if (showBalance) Positioned(
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                                    child: Text(
                                      PriceConverter.convertPrice(profileController.userInfoModel!.walletBalance),
                                      style: robotoBold.copyWith(color: BlinkitUi.ink, fontSize: 11),
                                      maxLines: 1, textDirection: TextDirection.ltr,
                                    ),
                                  ),
                                ),
                              ]),
                            );
                          }),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        /// Profile
                        InkWell(
                          onTap: () {
                            if(AuthHelper.isLoggedIn()){
                              Get.toNamed(RouteHelper.getProfileRoute());
                            }else {
                              Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.main));
                            }
                          },
                          child: GetBuilder<ProfileController>(builder: (profileController) {
                            String initials = '';
                            if (AuthHelper.isLoggedIn() && profileController.userInfoModel != null) {
                              final String f = profileController.userInfoModel!.fName ?? '';
                              final String l = profileController.userInfoModel!.lName ?? '';
                              initials = '${f.isNotEmpty ? f[0] : ''}${l.isNotEmpty ? l[0] : ''}'.toUpperCase();
                            }
                            return Container(
                              width: 38, height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(colors: [Color(0xFFFFE08A), Color(0xFFFFB92E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: Center(child: initials.isEmpty
                                ? const Icon(CupertinoIcons.person_fill, size: 20, color: BlinkitUi.ink)
                                : Text(initials, style: robotoBold.copyWith(color: BlinkitUi.ink, fontSize: Dimensions.fontSizeDefault))),
                            );
                          }),
                        ),
                      ]),
                    ),
                  ),

                  /// Search bar (pinned) — now shows in both states so the
                  /// unified home feed (no module selected) also has search.
                  !isTaxi ? SliverPersistentHeader(
                    pinned: true,
                    delegate: HomeSliverDelegate(
                      height: 50,
                      callback: (val){},
                      child: Container(
                        height: 50, width: double.infinity,
                        color: BlinkitUi.accent(),
                        padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, 2, Dimensions.paddingSizeDefault, 8),
                        child: InkWell(
                          onTap: () => Get.toNamed(RouteHelper.getSearchRoute(queryText: '')),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                            ),
                            child: Row(children: [
                              const Icon(CupertinoIcons.search, size: 18, color: BlinkitUi.ink),
                              const SizedBox(width: Dimensions.paddingSizeSmall),
                              Expanded(child: const AnimatedSearchText()),
                              Container(height: 18, width: 1, color: Theme.of(context).disabledColor.withValues(alpha: 0.4)),
                              const SizedBox(width: Dimensions.paddingSizeSmall),
                              InkWell(
                                onTap: () => _openVoiceSearch(),
                                child: const Padding(padding: EdgeInsets.all(4), child: Icon(CupertinoIcons.mic_fill, size: 18, color: BlinkitUi.ink)),
                              ),
                            ]),
                          ),
                        ),
                      ),
                    ),
                  ) : const SliverToBoxAdapter(),

                  /// Inline module tab bar (pinned): module icon on top, label below,
                  /// selected tab gets a dark underline (matches the reference video).
                  (splashController.configModel!.module == null && splashController.moduleList != null && splashController.moduleList!.length > 1) ? SliverPersistentHeader(
                    pinned: true,
                    delegate: HomeSliverDelegate(
                      height: 62,
                      callback: (val){},
                      child: Container(
                        height: 62, width: double.infinity,
                        color: BlinkitUi.accent(),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          itemCount: splashController.moduleList!.length,
                          itemBuilder: (context, index) {
                            final module = splashController.moduleList![index];
                            final bool selected = splashController.module != null && splashController.module!.id == module.id;
                            return InkWell(
                              onTap: selected ? null : () => splashController.switchModule(index, true),
                              child: Container(
                                constraints: const BoxConstraints(minWidth: 64),
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                                  Opacity(
                                    opacity: selected ? 1 : 0.8,
                                    child: CustomImage(image: module.iconFullUrl ?? '', height: 22, width: 22, fit: BoxFit.contain),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    module.moduleName ?? '',
                                    style: (selected ? robotoBold : robotoMedium).copyWith(color: BlinkitUi.ink, fontSize: 11),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    height: 3, width: selected ? 52 : 0,
                                    decoration: BoxDecoration(color: BlinkitUi.ink, borderRadius: BorderRadius.circular(2)),
                                  ),
                                ]),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ) : const SliverToBoxAdapter(),

                  SliverToBoxAdapter(
                    child: Center(child: SizedBox(
                      width: Dimensions.webMaxWidth,
                      child: !showMobileModule ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        isGrocery ? const GroceryHomeScreen()
                            : isPharmacy ? const PharmacyHomeScreen()
                            : isFood ? const FoodHomeScreen()
                            : isShop ? const ShopHomeScreen()
                            : isTaxi ? const TaxiHomeScreen()
                            : const SizedBox(),

                      ]) : const UnifiedHomeFeed(),
                    )),
                  ),

                  !showMobileModule && !isTaxi ? SliverPersistentHeader(
                    key: _headerKey,
                    pinned: true,
                    delegate: HomeSliverDelegate(
                      height: 85,
                      callback: (val) {
                        searchBgShow = val;
                      },
                      child: const AllStoreFilterWidget(),
                    ),
                  ) : const SliverToBoxAdapter(),

                  SliverToBoxAdapter(child: !showMobileModule && !isTaxi ? Center(child: GetBuilder<StoreController>(builder: (storeController) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: ResponsiveHelper.isDesktop(context) ? 0 : 100),
                      child: PaginatedListView(
                        scrollController: _scrollController,
                        totalSize: storeController.storeModel?.totalSize,
                        offset: storeController.storeModel?.offset,
                        onPaginate: (int? offset) async => await storeController.getStoreList(offset!, false),
                        itemView: ItemsView(
                          isStore: true,
                          items: null,
                          isFoodOrGrocery: (isFood || isGrocery || isShop),
                          stores: storeController.storeModel?.stores,
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeSmall,
                            vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeDefault,
                          ),
                        ),
                      ),
                    );
                  })) : const SizedBox()),

                ],
              ),
            ),
          backgroundColor: (isParcel || isCab || Theme.of(context).brightness == Brightness.dark) ? null : BlinkitUi.sectionTint()[1],
          floatingActionButton: null,
        );
      });
    });
  }

  void _openVoiceSearch() {
    Get.bottomSheet(const VoiceSearchWidget()).then((value) {
      if(value != null && value.isNotEmpty) {
        Get.toNamed(RouteHelper.getSearchRoute(queryText: value));
      }
    });
  }
}

class HomeSliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;
  Function(bool isPinned)? callback;
  bool isPinned = false;

  HomeSliverDelegate({required this.child, this.height = 50, this.callback});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    isPinned = shrinkOffset == maxExtent /*|| shrinkOffset < maxExtent*/;
    callback?.call(isPinned);
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant HomeSliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height || oldDelegate.minExtent != height || child != oldDelegate.child;
  }
}

class AnimatedSearchText extends StatefulWidget {
  const AnimatedSearchText({super.key});

  @override
  State<AnimatedSearchText> createState() => _AnimatedSearchTextState();
}

class _AnimatedSearchTextState extends State<AnimatedSearchText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  int _currentIndex = 0;
  late List<String> searchWords;
  
  @override
  void initState() {
    super.initState();
    
    searchWords = ['Pet Food', 'Grocery Items', 'Delicious Food'];
        
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _slideAnimation = Tween<double>(begin: 0.5, end: 0.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    
    _controller.forward();
    _startTimer();
  }
  
  void _startTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) {
            setState(() {
              _currentIndex = (_currentIndex + 1) % searchWords.length;
            });
            _controller.forward();
            _startTimer();
          }
        });
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 20),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Text(
              'Search \"${searchWords[_currentIndex]}\"',
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: BlinkitUi.ink.withValues(alpha: 0.7)),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }
}


/// Presentation-only wrapper: shows the module switcher above screens that
/// don't have their own (Parcel, Cab Booking).
class _ModuleScreenWithTabs extends StatelessWidget {
  final Widget child;
  const _ModuleScreenWithTabs({required this.child});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (splashController) {
      if (!ModuleTabsBar.isVisible(splashController)) return child;
      return Column(children: [
        const ModuleTabsBar(),
        Expanded(child: MediaQuery.removePadding(context: context, removeTop: true, child: child)),
      ]);
    });
  }
}
