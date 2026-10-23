import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/onboard/controllers/onboard_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();

    Get.find<OnBoardingController>().getOnBoardingList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      body: GetBuilder<OnBoardingController>(
        builder: (onBoardingController) {
          return onBoardingController.onBoardingList.isNotEmpty ? Column(children: [

            Expanded(
              flex: 6,
              child: PageView.builder(
                itemCount: onBoardingController.onBoardingList.length,
                controller: _pageController,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.zero,
                    child: Image.asset(
                      onBoardingController.onBoardingList[index].imageUrl,
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                      height: double.infinity,
                    ),
                  );
                },
                onPageChanged: (index) {
                  onBoardingController.changeSelectIndex(index);
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -10))
                ],
              ),
              child: Column(children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _pageIndicators(onBoardingController, context),
                ),
                const SizedBox(height: 30),

                Text(
                  onBoardingController.onBoardingList[onBoardingController.selectedIndex].title,
                  style: robotoBold.copyWith(fontSize: 24, color: Theme.of(context).textTheme.bodyLarge?.color),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),

                Text(
                  onBoardingController.onBoardingList[onBoardingController.selectedIndex].description,
                  style: robotoRegular.copyWith(fontSize: 14, color: Theme.of(context).disabledColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                Row(children: [
                  onBoardingController.selectedIndex == 2
                      ? const SizedBox()
                      : Expanded(
                    child: TextButton(
                      onPressed: () => _configureToRouteInitialPage(),
                      child: Text(
                        'skip'.tr,
                        style: robotoMedium.copyWith(color: Theme.of(context).disabledColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFC3202), Color(0xFF0037C5)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          if (onBoardingController.selectedIndex != 2) {
                            _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                          } else {
                            _configureToRouteInitialPage();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                        ),
                        child: Text(
                          onBoardingController.selectedIndex != 2 ? 'next'.tr : 'get_started'.tr,
                          style: robotoBold.copyWith(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ]),
              ]),
            ),
          ]) : const SizedBox();
        },
      ),
    );
  }

  List<Widget> _pageIndicators(OnBoardingController onBoardingController, BuildContext context) {
    List<Widget> indicators = [];
    for (int i = 0; i < onBoardingController.onBoardingList.length; i++) {
      indicators.add(
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: i == onBoardingController.selectedIndex ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: i == onBoardingController.selectedIndex ? const Color(
                0xFF0037C5) : Theme.of(context).disabledColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
    return indicators;
  }

  void _configureToRouteInitialPage() async {
    Get.find<SplashController>().disableIntro();
    Get.offNamed(RouteHelper.getWelcomeRoute());
  }
}
