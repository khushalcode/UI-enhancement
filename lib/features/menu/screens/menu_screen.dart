import 'package:sixam_mart/util/blinkit_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/auth/widgets/auth_dialog_widget.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/home/controllers/home_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/language/widgets/language_bottom_sheet_widget.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/rental_module/rental_cart_screen/controllers/taxi_cart_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/confirmation_dialog.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/menu/widgets/portion_widget.dart';
import 'package:sixam_mart/features/profile/widgets/notification_status_change_bottom_sheet.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlinkitUi.surface,
      body: GetBuilder<ProfileController>(builder: (profileController) {
        final bool isLoggedIn = AuthHelper.isLoggedIn();

        return Column(children: [

          // ===== Yellow gradient header with avatar, name, phone, and quick tiles =====
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [BlinkitUi.accent(), BlinkitUi.surface],
              ),
            ),
            padding: EdgeInsets.fromLTRB(Dimensions.paddingSizeLarge, MediaQuery.of(context).padding.top + Dimensions.paddingSizeSmall, Dimensions.paddingSizeLarge, Dimensions.paddingSizeDefault),
            child: Column(children: [

              // Top row: notification bell (right)
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
                  child: Container(
                    height: 46, width: 46,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.7), shape: BoxShape.circle),
                    child: const Icon(CupertinoIcons.bell, size: 22, color: BlinkitUi.ink),
                  ),
                ),
              ),

              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                padding: const EdgeInsets.all(5),
                child: ClipOval(child: CustomImage(
                  placeholder: Images.guestIconLight,
                  image: '${(profileController.userInfoModel != null && isLoggedIn) ? profileController.userInfoModel!.imageFullUrl : ''}',
                  height: 96, width: 96, fit: BoxFit.cover,
                )),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              // Name
              isLoggedIn && profileController.userInfoModel == null ? Shimmer(
                child: Container(
                  height: 18, width: 150,
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(5)),
                ),
              ) : Text(
                isLoggedIn ? '${profileController.userInfoModel?.fName ?? ''} ${profileController.userInfoModel?.lName ?? ''}' : 'guest_user'.tr,
                style: robotoBold.copyWith(fontSize: 26, color: BlinkitUi.ink),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

              // Phone or login link
              isLoggedIn && profileController.userInfoModel == null ? Shimmer(
                child: Container(
                  height: 14, width: 100,
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(5)),
                ),
              ) : isLoggedIn ? Text(
                profileController.userInfoModel?.phone ?? '',
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: BlinkitUi.ink.withValues(alpha: 0.7)),
                textDirection: TextDirection.ltr,
              ) : InkWell(
                onTap: () async {
                  if(!ResponsiveHelper.isDesktop(context)) {
                    await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
                    if(AuthHelper.isLoggedIn()) {
                      profileController.getUserInfo();
                    }
                  }else{
                    Get.dialog(const Center(child: AuthDialogWidget(exitFromApp: true, backFromThis: true)));
                  }
                },
                child: Text(
                  'login_to_view_all_feature'.tr,
                  style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: BlinkitUi.ink, decoration: TextDecoration.underline),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),

              // Quick tiles: Orders, Favourite, Wallet, Support
              Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Expanded(child: _quickTile(context, CupertinoIcons.bag_fill, 'orders'.tr, RouteHelper.getOrderRoute())),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(child: _quickTile(context, Icons.favorite_border_rounded, 'favourite'.tr, RouteHelper.getFavouriteScreen())),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(child: _quickTile(context, Icons.account_balance_wallet_outlined, 'my_wallet'.tr, RouteHelper.getWalletRoute(),
                  caption: isLoggedIn ? PriceConverter.convertPrice(profileController.userInfoModel != null ? profileController.userInfoModel!.walletBalance : 0) : null)),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(child: _quickTile(context, Icons.headset_mic_outlined, 'help_and_support'.tr, RouteHelper.getSupportRoute())),
              ]),
            ]),
          ),

          // ===== Scrollable body with all menu sections =====
          Expanded(child: SingleChildScrollView(
            child: Ink(
              color: BlinkitUi.surface,
              padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
              child: Column(children: [

                // --- Account section ---
                _sectionTitle(context, 'my_account'.tr),
                _sectionCard(context, children: [
                  PortionWidget(icon: Images.profileIcon, title: 'profile'.tr, route: RouteHelper.getProfileRoute()),
                  PortionWidget(icon: Images.addressIcon, title: 'my_address'.tr, route: RouteHelper.getAddressRoute()),
                  PortionWidget(icon: Images.orderSelect, title: 'my_orders'.tr, route: RouteHelper.getOrderRoute(),
                    hideDivider: Get.find<SplashController>().configModel!.loyaltyPointStatus == 1 ? false : true,
                  ),
                  (Get.find<SplashController>().configModel!.loyaltyPointStatus == 1) ? PortionWidget(
                      icon: Images.pointIcon, title: 'loyalty_points'.tr, route: RouteHelper.getLoyaltyRoute(),
                    hideDivider: Get.find<SplashController>().configModel!.customerWalletStatus == 1 ? false : true,
                    suffix: !isLoggedIn ? null : '${profileController.userInfoModel?.loyaltyPoint != null ? profileController.userInfoModel!.loyaltyPoint.toString() : '0'} ${'points'.tr}',
                  ) : const SizedBox(),
                  (Get.find<SplashController>().configModel!.customerWalletStatus == 1) ? PortionWidget(
                      icon: Images.walletIcon, title: 'my_wallet'.tr, hideDivider: true, route: RouteHelper.getWalletRoute(),
                    suffix: !isLoggedIn ? null : PriceConverter.convertPrice(profileController.userInfoModel != null ? profileController.userInfoModel!.walletBalance : 0),
                  ) : const SizedBox(),
                ]),

                // --- Browse section ---
                _sectionTitle(context, 'all_stores'.tr),
                _sectionCard(context, children: [
                  PortionWidget(icon: Images.favouriteUnselect, title: 'favourite'.tr, route: RouteHelper.getFavouriteScreen()),
                  PortionWidget(icon: Images.couponIcon, title: 'coupon'.tr, route: RouteHelper.getCouponRoute(), hideDivider: true),
                ]),

                // --- Settings section (Dark Mode, Notifications, Language) ---
                _sectionTitle(context, 'settings'.tr),
                _sectionCard(context, children: [
                  // Dark Mode toggle
                  GetBuilder<ThemeController>(builder: (themeController) {
                    return _toggleTile(
                      context,
                      icon: Get.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      title: 'dark_mode'.tr,
                      value: themeController.darkTheme,
                      onChanged: (bool? value) => themeController.toggleTheme(),
                    );
                  }),
                  // Notifications toggle (only if logged in)
                  isLoggedIn ? GetBuilder<AuthController>(builder: (authController) {
                    return _toggleTile(
                      context,
                      icon: Icons.notifications_none_rounded,
                      title: 'notification'.tr,
                      value: authController.notification,
                      hideDivider: false,
                      onChanged: (bool? value) => Get.bottomSheet(const NotificationStatusChangeBottomSheet()),
                    );
                  }) : const SizedBox(),
                  // Language picker
                  PortionWidget(icon: Images.languageIcon, title: 'language'.tr, hideDivider: true, onTap: ()=> _manageLanguageFunctionality(), route: ''),
                ]),

                // --- Promotional Activity section ---
                _sectionTitle(context, 'promotional_activity'.tr),
                _sectionCard(context, children: [
                  PortionWidget(
                    icon: Images.couponIcon, title: 'coupon'.tr, route: RouteHelper.getCouponRoute(),
                    hideDivider: Get.find<SplashController>().configModel!.loyaltyPointStatus == 1 || Get.find<SplashController>().configModel!.customerWalletStatus == 1 ? false : true,
                  ),
                  (Get.find<SplashController>().configModel!.loyaltyPointStatus == 1) ? PortionWidget(
                      icon: Images.pointIcon, title: 'loyalty_points'.tr, route: RouteHelper.getLoyaltyRoute(),
                    hideDivider: Get.find<SplashController>().configModel!.customerWalletStatus == 1 ? false : true,
                    suffix: !isLoggedIn ? null : '${profileController.userInfoModel?.loyaltyPoint != null ? profileController.userInfoModel!.loyaltyPoint.toString() : '0'} ${'points'.tr}',
                  ) : const SizedBox(),
                  (Get.find<SplashController>().configModel!.customerWalletStatus == 1) ? PortionWidget(
                      icon: Images.walletIcon, title: 'my_wallet'.tr, hideDivider: true, route: RouteHelper.getWalletRoute(),
                    suffix: !isLoggedIn ? null : PriceConverter.convertPrice(profileController.userInfoModel != null ? profileController.userInfoModel!.walletBalance : 0),
                  ) : const SizedBox(),
                ]),

                // --- Earnings section ---
                (Get.find<SplashController>().configModel!.refEarningStatus == 1 ) || (Get.find<SplashController>().configModel!.toggleDmRegistration! && !ResponsiveHelper.isDesktop(context)) ||
                    (Get.find<SplashController>().configModel!.toggleStoreRegistration! && !ResponsiveHelper.isDesktop(context)) ?
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _sectionTitle(context, 'earnings'.tr),
                  _sectionCard(context, children: [
                    (Get.find<SplashController>().configModel!.refEarningStatus == 1 ) ? PortionWidget(
                        icon: Images.referIcon, title: 'refer_and_earn'.tr, route: RouteHelper.getReferAndEarnRoute(),
                      hideDivider: (Get.find<SplashController>().configModel!.toggleDmRegistration! && !ResponsiveHelper.isDesktop(context)) ||
                          (Get.find<SplashController>().configModel!.toggleStoreRegistration! && !ResponsiveHelper.isDesktop(context)) ? false : true,
                    ) : const SizedBox(),

                    (Get.find<SplashController>().configModel!.toggleDmRegistration! && !ResponsiveHelper.isDesktop(context)) ? PortionWidget(
                        icon: Images.dmIcon, title: 'join_as_a_delivery_man'.tr, route: RouteHelper.getDeliverymanRegistrationRoute(),
                      hideDivider: (Get.find<SplashController>().configModel!.toggleStoreRegistration! && !ResponsiveHelper.isDesktop(context)) ? false : true,
                    ) : const SizedBox(),

                    (Get.find<SplashController>().configModel!.toggleStoreRegistration! && !ResponsiveHelper.isDesktop(context)) ? PortionWidget(
                        icon: Images.storeIcon, title: 'open_vendor'.tr, hideDivider: true, route: RouteHelper.getRestaurantRegistrationRoute(),
                    ) : const SizedBox(),
                  ]),
                ]) : const SizedBox(),

                // --- Help & Support section ---
                _sectionTitle(context, 'help_and_support'.tr),
                _sectionCard(context, children: [
                  PortionWidget(icon: Images.chatIcon, title: 'live_chat'.tr, route: RouteHelper.getConversationRoute()),
                  PortionWidget(icon: Images.helpIcon, title: 'help_and_support'.tr, route: RouteHelper.getSupportRoute()),
                  PortionWidget(icon: Images.aboutIcon, title: 'about_us'.tr, route: RouteHelper.getHtmlRoute('about-us')),
                  PortionWidget(icon: Images.termsIcon, title: 'terms_conditions'.tr, route: RouteHelper.getHtmlRoute('terms-and-condition')),
                  PortionWidget(icon: Images.privacyIcon, title: 'privacy_policy'.tr, route: RouteHelper.getHtmlRoute('privacy-policy')),

                  (Get.find<SplashController>().configModel!.refundPolicyStatus == 1 ) ? PortionWidget(
                      icon: Images.refundIcon, title: 'refund_policy'.tr, route: RouteHelper.getHtmlRoute('refund-policy'),
                    hideDivider: (Get.find<SplashController>().configModel!.cancellationPolicyStatus == 1 ) ||
                        (Get.find<SplashController>().configModel!.shippingPolicyStatus == 1 ) ? false : true,
                  ) : const SizedBox(),

                  (Get.find<SplashController>().configModel!.cancellationPolicyStatus == 1 ) ? PortionWidget(
                      icon: Images.cancelationIcon, title: 'cancellation_policy'.tr, route: RouteHelper.getHtmlRoute('cancellation-policy'),
                    hideDivider: (Get.find<SplashController>().configModel!.shippingPolicyStatus == 1 ) ? false : true,
                  ) : const SizedBox(),

                  (Get.find<SplashController>().configModel!.shippingPolicyStatus == 1 ) ? PortionWidget(
                      icon: Images.shippingIcon, title: 'shipping_policy'.tr, hideDivider: true, route: RouteHelper.getHtmlRoute('shipping-policy'),
                  ) : const SizedBox(),
                ]),

                // --- Logout / Sign In button ---
                InkWell(
                  onTap: () async {
                    if(AuthHelper.isLoggedIn()) {
                      Get.dialog(ConfirmationDialog(icon: Images.support, description: 'are_you_sure_to_logout'.tr, isLogOut: true, onYesPressed: () async {
                        Get.find<AuthController>().resetOtpView();
                        Get.find<ProfileController>().clearUserInfo();
                        Get.find<AuthController>().socialLogout();
                        Get.find<CartController>().clearCartList(canRemoveOnline: false);
                        Get.find<FavouriteController>().removeFavourite();
                        await Get.find<AuthController>().clearSharedData();
                        Get.find<HomeController>().forcefullyNullCashBackOffers();
                        Get.find<TaxiCartController>().getCarCartList();
                        Get.offAllNamed(RouteHelper.getInitialRoute());
                      }), useSafeArea: false);
                    }else {
                      Get.find<FavouriteController>().removeFavourite();
                      await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
                      if(AuthHelper.isLoggedIn()) {
                        await Get.find<FavouriteController>().getFavouriteList();
                        profileController.getUserInfo();
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                        child: Icon(Icons.power_settings_new_sharp, size: 18, color: Theme.of(context).cardColor),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                      Text(AuthHelper.isLoggedIn() ? 'logout'.tr : 'sign_in'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge))
                    ]),
                  ),
                ),

                SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeExtremeLarge : 100),

              ]),
            ),
          )),
        ]);
      }),
    );
  }

  /// Section title (e.g. "Account", "Settings")
  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeLarge, Dimensions.paddingSizeSmall, Dimensions.paddingSizeDefault, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: BlinkitUi.ink),
        ),
      ),
    );
  }

  /// Rounded white card that groups a list of PortionWidget rows
  Widget _sectionCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeDefault),
      margin: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(children: children),
    );
  }

  /// A toggle row (used for Dark Mode and Notifications)
  Widget _toggleTile(BuildContext context, {required IconData icon, required String title, required bool value, required Function(bool?) onChanged, bool hideDivider = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
      child: Column(children: [
        Row(children: [
          Container(
            height: 44, width: 44,
            decoration: BoxDecoration(color: BlinkitUi.surface, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, size: 22, color: BlinkitUi.ink),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(child: Text(title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: BlinkitUi.ink))),
          Transform.scale(
            scale: 0.85,
            child: CupertinoSwitch(
              value: value,
              activeTrackColor: BlinkitUi.accent(),
              onChanged: onChanged,
            ),
          ),
        ]),
        hideDivider ? const SizedBox() : Padding(
          padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
          child: Divider(height: 1, thickness: 1, color: Colors.black.withValues(alpha: 0.08)),
        ),
      ]),
    );
  }

  Widget _quickTile(BuildContext context, IconData icon, String title, String route, {String? caption}) {
    return InkWell(
      onTap: () => Get.toNamed(route),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeExtraSmall),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            height: 48, width: 48,
            decoration: BoxDecoration(color: BlinkitUi.yellow.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, size: 24, color: BlinkitUi.ink),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(title, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: BlinkitUi.ink), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          if (caption != null) Text(caption, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: BlinkitUi.ink.withValues(alpha: 0.6)), textDirection: TextDirection.ltr),
        ]),
      ),
    );
  }

  void _manageLanguageFunctionality() {
    Get.find<LocalizationController>().saveCacheLanguage(null);
    Get.find<LocalizationController>().searchSelectedLanguage();

    showModalBottomSheet(
      isScrollControlled: true, useRootNavigator: true, context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusExtraLarge), topRight: Radius.circular(Dimensions.radiusExtraLarge)),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: const LanguageBottomSheetWidget(),
        );
      },
    ).then((value) => Get.find<LocalizationController>().setLanguage(Get.find<LocalizationController>().getCacheLocaleFromSharedPref()));
  }

}
