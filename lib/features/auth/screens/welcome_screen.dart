import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/auth/widgets/auth_ui_kit.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class _WelcomeSlide {
  final IconData icon;
  final List<IconData> orbit;
  final String title;
  final String subtitle;
  const _WelcomeSlide(this.icon, this.orbit, this.title, this.subtitle);
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _index = 0;

  static const List<_WelcomeSlide> _slides = [
    _WelcomeSlide(Icons.shopping_basket_rounded, [Icons.local_drink_rounded, Icons.bakery_dining_rounded, Icons.eco_rounded],
      'Groceries in minutes', 'Fresh produce, staples and daily needs delivered to your door.'),
    _WelcomeSlide(Icons.ramen_dining_rounded, [Icons.local_pizza_rounded, Icons.lunch_dining_rounded, Icons.icecream_rounded],
      'Hot food, delivered fast', 'Order from stores nearby and follow your order live.'),
    _WelcomeSlide(Icons.local_pharmacy_rounded, [Icons.medication_rounded, Icons.inventory_2_rounded, Icons.delivery_dining_rounded],
      'Medicines and parcels too', 'Pharmacy runs and parcel pickups, all in one app.'),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _skip() async {
    Get.find<SplashController>().disableIntro();
    await Get.find<AuthController>().guestLogin();
    if (AddressHelper.getUserAddressFromSharedPref() != null) {
      Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: true));
    } else {
      Get.find<LocationController>().navigateToLocationScreen(RouteHelper.welcome, offNamed: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [AuthColors.yellow, Color(0xFFFBDD7A)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(children: [

                Padding(
                  padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeLarge, Dimensions.paddingSizeSmall, Dimensions.paddingSizeSmall, 0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Container(
                      height: 44, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                      child: Image.asset(Images.logo, fit: BoxFit.contain),
                    ),
                    TextButton(
                      onPressed: _skip,
                      style: TextButton.styleFrom(
                        foregroundColor: AuthColors.ink,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text('Skip', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: AuthColors.ink)),
                    ),
                  ]),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, i) => AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, _) {
                        double page = _index.toDouble();
                        if (_pageController.hasClients && _pageController.position.haveDimensions) {
                          page = _pageController.page ?? page;
                        }
                        final double scale = (1 - (page - i).abs() * 0.18).clamp(0.8, 1.0);
                        return _SlideView(slide: _slides[i], scale: scale);
                      },
                    ),
                  ),
                ),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeExtraLarge, 24, Dimensions.paddingSizeExtraLarge, Dimensions.paddingSizeExtraLarge),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, -6))],
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [

                    Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_slides.length, (i) {
                      final bool active = i == _index;
                      return GestureDetector(
                        onTap: () => _pageController.animateToPage(i,
                          duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 350), curve: Curves.easeOut),
                        child: AnimatedContainer(
                          duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                          height: 8, width: active ? 24 : 8,
                          decoration: BoxDecoration(
                            color: active ? AuthColors.ink : Theme.of(context).disabledColor.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    })),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    SizedBox(
                      width: double.infinity, height: 54,
                      child: ElevatedButton(
                        onPressed: () => Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.welcome)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
                        ),
                        child: Text('Log In', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    SizedBox(
                      width: double.infinity, height: 54,
                      child: OutlinedButton(
                        onPressed: () => Get.toNamed(RouteHelper.getSignUpRoute()),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AuthColors.ink, width: 1.4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusLarge)),
                        ),
                        child: Text('Sign Up', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: AuthColors.ink)),
                      ),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  final _WelcomeSlide slide;
  final double scale;
  const _SlideView({required this.slide, required this.scale});

  @override
  Widget build(BuildContext context) {
    const List<Alignment> spots = [Alignment(-0.85, -0.55), Alignment(0.9, -0.1), Alignment(-0.45, 0.85)];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

        Transform.scale(
          scale: scale,
          child: SizedBox(
            width: 250, height: 250,
            child: Stack(alignment: Alignment.center, children: [
              Container(
                width: 190, height: 190,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.7), shape: BoxShape.circle),
                child: Icon(slide.icon, size: 92, color: AuthColors.ink),
              ),
              for (int i = 0; i < slide.orbit.length; i++)
                Align(
                  alignment: spots[i],
                  child: Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 5))],
                    ),
                    child: Icon(slide.orbit[i], size: 26, color: AuthColors.ink),
                  ),
                ),
            ]),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        Text(slide.title, textAlign: TextAlign.center, style: robotoBold.copyWith(fontSize: 28, color: AuthColors.ink)),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        Text(slide.subtitle, textAlign: TextAlign.center,
          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: AuthColors.ink.withValues(alpha: 0.7))),
      ]),
    );
  }
}
