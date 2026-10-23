import 'package:sixam_mart/features/profile/widgets/notification_status_change_bottom_sheet.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/date_converter.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/confirmation_dialog.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:sixam_mart/features/profile/widgets/profile_button_widget.dart';
import 'package:sixam_mart/features/profile/widgets/profile_card_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/profile/widgets/web_profile_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    if(AuthHelper.isLoggedIn() && Get.find<ProfileController>().userInfoModel == null) {
      Get.find<ProfileController>().getUserInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showWalletCard = Get.find<SplashController>().configModel!.customerWalletStatus == 1 || Get.find<SplashController>().configModel!.loyaltyPointStatus == 1;
    bool isLoggedIn = AuthHelper.isLoggedIn();
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      appBar: isDesktop ? const WebMenuBar() : null,
      endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
      key: UniqueKey(),
      body: GetBuilder<ProfileController>(builder: (profileController) {
        return (isLoggedIn && profileController.userInfoModel == null) ? const Center(child: CircularProgressIndicator()) : isDesktop ? SingleChildScrollView(
          child:  FooterView(
            minHeight: isLoggedIn ? 0.6 : 0.35,
            child: const WebProfileWidget(),
          ),
        ) : CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [

            // === Yellow gradient header with sun + bell icons and user info ===
            SliverToBoxAdapter(
              child: GetBuilder<ThemeController>(builder: (_) => _ProfileHeader(isLoggedIn: isLoggedIn, profileController: profileController)),
            ),

            // === Body: white rounded sheet with all the cards ===
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeLarge, Dimensions.paddingSizeDefault, Dimensions.paddingSizeLarge, Dimensions.paddingSizeExtraLarge),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  // === Birthday card ===
                  _BirthdayCard(isLoggedIn: isLoggedIn),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // === Three stat cards: Orders / Wallet / Help ===
                  Row(children: [
                    Expanded(
                      child: _StatCard(
                        icon: CupertinoIcons.bag_fill,
                        iconBg: const Color(0xFFE8F4FF),
                        iconColor: const Color(0xFF2E7BD6),
                        title: 'Your orders',
                        subtitle: isLoggedIn ? '${profileController.userInfoModel?.orderCount ?? 0} placed' : 'Login to view',
                        onTap: () => Get.toNamed(RouteHelper.getOrderRoute()),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: _StatCard(
                        icon: CupertinoIcons.creditcard_fill,
                        iconBg: const Color(0xFFFFF3D6),
                        iconColor: const Color(0xFFE0A800),
                        title: 'Blinksy Money',
                        subtitle: isLoggedIn
                            ? PriceConverter.convertPrice(profileController.userInfoModel?.walletBalance ?? 0)
                            : '₹ 0',
                        onTap: () {
                          if (isLoggedIn) {
                            Get.toNamed(RouteHelper.getWalletRoute());
                          } else {
                            Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.profile));
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: _StatCard(
                        icon: CupertinoIcons.chat_bubble_text_fill,
                        iconBg: const Color(0xFFFFE4E4),
                        iconColor: const Color(0xFFE84D4F),
                        title: 'Need help?',
                        subtitle: 'Support & chat',
                        onTap: () => Get.toNamed(RouteHelper.getSupportRoute()),
                      ),
                    ),
                  ]),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  // === Appearance section (LIGHT / DARK segmented control) ===
                  GetBuilder<ThemeController>(builder: (_) => _AppearanceSection()),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  // === Notifications toggle ===
                  isLoggedIn ? GetBuilder<AuthController>(builder: (authController) {
                    return _SettingsTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      trailing: Switch(
                        value: authController.notification,
                        onChanged: (bool? value) => Get.bottomSheet(const NotificationStatusChangeBottomSheet()),
                        activeColor: Theme.of(context).primaryColor,
                      ),
                      onTap: () => Get.bottomSheet(const NotificationStatusChangeBottomSheet()),
                    );
                  }) : const SizedBox(),
                  SizedBox(height: isLoggedIn ? Dimensions.paddingSizeSmall : 0),

                  // === Change password ===
                  isLoggedIn && Get.find<SplashController>().configModel!.centralizeLoginSetup!.manualLoginStatus! ? _SettingsTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Change password',
                    onTap: () => Get.toNamed(RouteHelper.getResetPasswordRoute(phone: '', email: '', token: '', page: 'password-change')),
                  ) : const SizedBox(),
                  SizedBox(height: isLoggedIn && Get.find<SplashController>().configModel!.centralizeLoginSetup!.manualLoginStatus! ? Dimensions.paddingSizeSmall : 0),

                  // === Delete account ===
                  isLoggedIn ? _SettingsTile(
                    icon: Icons.delete_outline_rounded,
                    title: 'Delete account',
                    iconColor: Theme.of(context).colorScheme.error,
                    onTap: () {
                      Get.dialog(ConfirmationDialog(icon: Images.support,
                        title: 'are_you_sure_to_delete_account'.tr,
                        description: 'it_will_remove_your_all_information'.tr, isLogOut: true,
                        onYesPressed: () => profileController.deleteUser(),
                      ), useSafeArea: false);
                    },
                  ) : const SizedBox(),
                  SizedBox(height: isLoggedIn ? Dimensions.paddingSizeLarge : 0),

                  // === Logout / Login ===
                  isLoggedIn ? _SettingsTile(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    iconColor: Theme.of(context).colorScheme.error,
                    onTap: () {
                      Get.dialog(ConfirmationDialog(
                        icon: Images.logOut,
                        title: 'logout'.tr,
                        description: 'are_you_sure_to_logout'.tr,
                        isLogOut: true,
                        onYesPressed: () => Get.find<AuthController>().clearSharedData(),
                      ), useSafeArea: false);
                    },
                  ) : _SettingsTile(
                    icon: Icons.login_rounded,
                    title: 'Login',
                    onTap: () async {
                      await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
                      if (AuthHelper.isLoggedIn()) {
                        profileController.getUserInfo();
                      }
                    },
                  ),

                  SizedBox(height: Dimensions.paddingSizeExtraLarge),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('${'version'.tr}:', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor)),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text(AppConstants.appVersion.toStringAsFixed(1), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor)),
                  ]),

                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                ]),
              ),
            ),

          ],
        );
      }),
    );
  }
}

/// Yellow gradient header with sun (theme toggle), bell (notifications),
/// avatar with initials, name and phone number — matches the screenshot.
class _ProfileHeader extends StatelessWidget {
  final bool isLoggedIn;
  final ProfileController profileController;
  const _ProfileHeader({required this.isLoggedIn, required this.profileController});

  @override
  Widget build(BuildContext context) {
    final double topPad = MediaQuery.of(context).padding.top;
    String initials = '';
    String fullName = '';
    String phone = '';
    if (isLoggedIn && profileController.userInfoModel != null) {
      final String f = profileController.userInfoModel!.fName ?? '';
      final String l = profileController.userInfoModel!.lName ?? '';
      fullName = '$f $l'.trim();
      initials = '${f.isNotEmpty ? f[0] : ''}${l.isNotEmpty ? l[0] : ''}'.toUpperCase();
      phone = profileController.userInfoModel!.phone ?? '';
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(Dimensions.paddingSizeDefault, topPad + 12, Dimensions.paddingSizeDefault, Dimensions.paddingSizeExtraLarge),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFFFDD876), Color(0xFFF8CB46)],
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Top row: sun (left) + bell (right)
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          InkWell(
            onTap: () => Get.find<ThemeController>().toggleTheme(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Get.isDarkMode ? CupertinoIcons.moon_stars_fill : CupertinoIcons.sun_max_fill,
                color: const Color(0xFF1C1C1C),
                size: 22,
              ),
            ),
          ),
          InkWell(
            onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.bell_fill,
                color: Color(0xFF1C1C1C),
                size: 22,
              ),
            ),
          ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        // Avatar + name + phone
        Row(children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: isLoggedIn && profileController.userInfoModel?.imageFullUrl != null && profileController.userInfoModel!.imageFullUrl!.isNotEmpty
              ? ClipOval(child: CustomImage(
                  placeholder: Images.guestIcon,
                  image: profileController.userInfoModel!.imageFullUrl!,
                  height: 64, width: 64, fit: BoxFit.cover,
                ))
              : Center(
                  child: initials.isEmpty
                    ? const Icon(CupertinoIcons.person_fill, size: 32, color: Color(0xFF1C1C1C))
                    : Text(initials, style: robotoBold.copyWith(color: const Color(0xFF1C1C1C), fontSize: 24)),
                ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                isLoggedIn ? (fullName.isNotEmpty ? fullName : 'Guest User') : 'guest_user'.tr,
                style: robotoBold.copyWith(fontSize: 20, color: const Color(0xFF1C1C1C)),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (isLoggedIn && phone.isNotEmpty)
                Text(phone, style: robotoRegular.copyWith(fontSize: 14, color: const Color(0xFF1C1C1C).withValues(alpha: 0.75)))
              else
                InkWell(
                  onTap: () async {
                    await Get.toNamed(RouteHelper.getSignInRoute(Get.currentRoute));
                    if (AuthHelper.isLoggedIn()) {
                      profileController.getUserInfo();
                    }
                  },
                  child: Text('login_to_view_all_feature'.tr, style: robotoRegular.copyWith(fontSize: 14, color: const Color(0xFF1C1C1C).withValues(alpha: 0.75))),
                ),
            ]),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          if (isLoggedIn)
            InkWell(
              onTap: () => Get.toNamed(RouteHelper.getUpdateProfileRoute()),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                child: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF1C1C1C)),
              ),
            ),
        ]),
      ]),
    );
  }
}

/// "Add your birthday" promo card with cake icon — matches the screenshot.
class _BirthdayCard extends StatelessWidget {
  final bool isLoggedIn;
  const _BirthdayCard({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3D6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF8CB46), width: 1),
      ),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF8CB46),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(CupertinoIcons.gift_fill, color: Color(0xFF1C1C1C), size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Add your birthday', style: robotoBold.copyWith(fontSize: 15, color: const Color(0xFF1C1C1C))),
            const SizedBox(height: 2),
            Text('Enter details', style: robotoRegular.copyWith(fontSize: 12, color: const Color(0xFF1C1C1C).withValues(alpha: 0.7))),
          ]),
        ),
        const Icon(Icons.keyboard_arrow_right_rounded, color: Color(0xFF1C1C1C), size: 26),
      ]),
    );
  }
}

/// Stat card with colored icon chip — matches "Your orders / Blinksy Money / Need help?" row.
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Function() onTap;
  const _StatCard({required this.icon, required this.iconBg, required this.iconColor, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.2), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 10),
          Text(title, style: robotoMedium.copyWith(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium!.color), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(subtitle, style: robotoBold.copyWith(fontSize: 15, color: Theme.of(context).textTheme.bodyLarge!.color), maxLines: 1, overflow: TextOverflow.ellipsis, textDirection: TextDirection.ltr),
        ]),
      ),
    );
  }
}

/// "Appearance" row with LIGHT/DARK segmented control — matches the screenshot.
class _AppearanceSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.2), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: Get.isDarkMode ? const Color(0xFF1F2430) : const Color(0xFFFFF3D6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Get.isDarkMode ? CupertinoIcons.moon_stars_fill : CupertinoIcons.sun_max_fill,
            color: Get.isDarkMode ? Colors.white : const Color(0xFFE0A800),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text('Appearance', style: robotoMedium.copyWith(fontSize: 15, color: Theme.of(context).textTheme.bodyMedium!.color)),
        ),
        // Segmented control
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Theme.of(context).disabledColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            _segmentButton(context, label: 'LIGHT', selected: !Get.isDarkMode, onTap: () {
              if (Get.isDarkMode) Get.find<ThemeController>().toggleTheme();
            }),
            _segmentButton(context, label: 'DARK', selected: Get.isDarkMode, onTap: () {
              if (!Get.isDarkMode) Get.find<ThemeController>().toggleTheme();
            }),
          ]),
        ),
      ]),
    );
  }

  Widget _segmentButton(BuildContext context, {required String label, required bool selected, required Function() onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF8CB46) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: robotoBold.copyWith(
            fontSize: 11,
            color: selected ? const Color(0xFF1C1C1C) : Theme.of(context).hintColor,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

/// A generic settings tile row: icon + title + optional trailing widget.
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? iconColor;
  final Widget? trailing;
  final Function() onTap;
  const _SettingsTile({required this.icon, required this.title, required this.onTap, this.iconColor, this.trailing});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.2), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Icon(icon, size: 22, color: iconColor ?? Theme.of(context).textTheme.bodyMedium!.color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: robotoMedium.copyWith(fontSize: 15, color: iconColor ?? Theme.of(context).textTheme.bodyMedium!.color)),
          ),
          trailing ?? const Icon(Icons.keyboard_arrow_right_rounded, color: Colors.grey, size: 22),
        ]),
      ),
    );
  }
}
