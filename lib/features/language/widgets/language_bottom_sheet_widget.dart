import 'package:sixam_mart/features/language/widgets/language_card_widget.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:get/get.dart';

class LanguageBottomSheetWidget extends StatefulWidget {
  const LanguageBottomSheetWidget({super.key});

  @override
  State<LanguageBottomSheetWidget> createState() => _LanguageBottomSheetWidgetState();
}

class _LanguageBottomSheetWidgetState extends State<LanguageBottomSheetWidget> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocalizationController>(builder: (localizationController) {
      return Container(
        padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20),
          ),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Container(
            height: 5, width: 45,
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

          Column(crossAxisAlignment: CrossAxisAlignment.center, children: [

            Text(
              'choose_your_language'.tr, 
              style: robotoBold.copyWith(
                fontSize: 20, 
                letterSpacing: 0.3,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Text(
              'choose_your_language_to_proceed'.tr, 
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall, 
                color: Theme.of(context).disabledColor,
              ),
            ),

          ]),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ListView.builder(
                itemCount: localizationController.languages.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                itemBuilder: (context, index) {
                  return LanguageCardWidget(
                    languageModel: localizationController.languages[index],
                    localizationController: localizationController,
                    index: index, fromBottomSheet: true,
                  );
                },
              ),
            ),
          ),

          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault, horizontal: Dimensions.paddingSizeExtraLarge),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
              child: CustomButton(
                buttonText: 'update'.tr,
                onPressed: () {
                  if (localizationController.languages.isNotEmpty && localizationController.selectedLanguageIndex != -1) {
                    localizationController.saveCacheLanguage(Locale(
                      AppConstants.languages[localizationController.selectedLanguageIndex].languageCode!,
                      AppConstants.languages[localizationController.selectedLanguageIndex].countryCode,
                    ));
                  }
                  Get.back();
                },
              ),
            ),
          ),

        ]),

      );
    });
  }
}
