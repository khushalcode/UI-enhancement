import 'package:sixam_mart/common/widgets/custom_asset_image_widget.dart';
import 'package:sixam_mart/features/language/screens/web_language_screen.dart';
import 'package:sixam_mart/features/language/widgets/language_card_widget.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:get/get.dart';

class ChooseLanguageScreen extends StatefulWidget {
  final bool fromMenu;
  const ChooseLanguageScreen({super.key, this.fromMenu = false});

  @override
  State<ChooseLanguageScreen> createState() => _ChooseLanguageScreenState();
}

class _ChooseLanguageScreenState extends State<ChooseLanguageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (widget.fromMenu || ResponsiveHelper.isDesktop(context)) ? CustomAppBar(title: 'language'.tr, backButton: true) : null,
      endDrawer: const MenuDrawer(), endDrawerEnableOpenDragGesture: false,
      backgroundColor: Theme.of(context).cardColor,
      body: GetBuilder<LocalizationController>(builder: (localizationController) {
        return ResponsiveHelper.isDesktop(context) ? const WebLanguageScreen() : Stack(
          children: [
            // Abstract Background Elements
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Theme.of(context).primaryColor.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              const SizedBox(height: 60),

              // Animated Top Icon
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.8, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  height: 100, width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 5, offset: const Offset(0, 5))
                    ],
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withValues(alpha: 0.8),
                        Theme.of(context).primaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(Icons.translate_rounded, color: Colors.white, size: 45),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              Text('choose_your_language'.tr, style: robotoBold.copyWith(fontSize: 24, letterSpacing: 0.5)),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text('choose_your_language_to_proceed'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.8,
                    crossAxisSpacing: Dimensions.paddingSizeDefault,
                    mainAxisSpacing: Dimensions.paddingSizeDefault,
                  ),
                  itemCount: localizationController.languages.length,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                  itemBuilder: (context, index) {
                    return LanguageCardWidget(
                      languageModel: localizationController.languages[index],
                      localizationController: localizationController,
                      index: index,
                    );
                  },
                ),
              ),

              // Premium Next Button
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withValues(alpha: 0.8),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: Dimensions.webMaxWidth,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        if(localizationController.selectedLanguageIndex != -1)
                          BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.4), blurRadius: 15, spreadRadius: 0, offset: const Offset(0, 5))
                      ],
                      gradient: LinearGradient(
                        colors: localizationController.selectedLanguageIndex != -1 
                          ? [Theme.of(context).primaryColor.withValues(alpha: 0.8), Theme.of(context).primaryColor]
                          : [Theme.of(context).disabledColor.withValues(alpha: 0.5), Theme.of(context).disabledColor.withValues(alpha: 0.5)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: TextButton(
                      onPressed: () {
                        if(localizationController.languages.isNotEmpty && localizationController.selectedLanguageIndex != -1) {
                          localizationController.setLanguage(Locale(
                            AppConstants.languages[localizationController.selectedLanguageIndex].languageCode!,
                            AppConstants.languages[localizationController.selectedLanguageIndex].countryCode,
                          ));
                          if (widget.fromMenu) {
                            Navigator.pop(context);
                          } else {
                            Get.offNamed(RouteHelper.getOnBoardingRoute());
                          }
                        }else {
                          showCustomSnackBar('select_a_language'.tr);
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('next'.tr, style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge, letterSpacing: 1)),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            ]),
          ],
        );
      }),

    );
  }
}
