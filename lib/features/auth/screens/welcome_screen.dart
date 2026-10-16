import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: context.width,
        height: context.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5E9), // Light green tint
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Top Right Skip Button
              Positioned(
                top: Dimensions.paddingSizeDefault,
                right: Dimensions.paddingSizeDefault,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFE3231), Color(0xFFFE3231)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.find<SplashController>().disableIntro();
                      await Get.find<AuthController>().guestLogin();
                      if (AddressHelper.getUserAddressFromSharedPref() != null) {
                        Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: true));
                      } else {
                        Get.find<LocationController>().navigateToLocationScreen(RouteHelper.welcome, offNamed: true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                    ),
                    child: Text(
                      'Skip',
                      style: robotoBold.copyWith(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),

              // Main Content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500), // Responsive for web/desktop
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo
                        Image.asset(Images.logo, width: 200),
                        const SizedBox(height: Dimensions.paddingSizeExtraOverLarge),

                        // Welcome Text
                        Text(
                          'Welcome To Deokart',
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeOverLarge,
                            color: Theme.of(context).primaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Text(
                          'Discover and get great sale',
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).disabledColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 50),

                        // Log In Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.welcome));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              'Log In',
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeLarge),

                        // Sign Up Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () {
                              Get.toNamed(RouteHelper.getSignUpRoute());
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              ),
                            ),
                            child: Text(
                              'Sign Up',
                              style: robotoBold.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
