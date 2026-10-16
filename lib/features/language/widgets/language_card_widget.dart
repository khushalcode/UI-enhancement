import 'package:flutter/material.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/language/domain/models/language_model.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class LanguageCardWidget extends StatelessWidget {
  final LanguageModel languageModel;
  final LocalizationController localizationController;
  final int index;
  final bool fromBottomSheet;
  final bool fromWeb;
  const LanguageCardWidget({super.key, required this.languageModel, required this.localizationController, required this.index, this.fromBottomSheet = false, this.fromWeb = false});

  @override
  Widget build(BuildContext context) {
    bool isSelected = localizationController.selectedLanguageIndex == index;
    bool isListMode = fromBottomSheet || fromWeb;

    if (isListMode) {
      return Padding(
        padding: EdgeInsets.only(bottom: fromBottomSheet ? Dimensions.paddingSizeSmall : 0),
        child: InkWell(
          onTap: () {
            if (fromBottomSheet) {
              localizationController.setLanguage(Locale(
                AppConstants.languages[index].languageCode!,
                AppConstants.languages[index].countryCode,
              ), fromBottomSheet: fromBottomSheet);
            }
            localizationController.setSelectLanguageIndex(index);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: isSelected 
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.05) 
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : Theme.of(context).disabledColor.withValues(alpha: 0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Theme.of(context).disabledColor.withValues(alpha: 0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(
                      languageModel.imageUrl!, 
                      width: 38, 
                      height: 26, 
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),

                Expanded(
                  child: Text(
                    languageModel.languageName!, 
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: isSelected 
                          ? Theme.of(context).primaryColor 
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: isSelected 
                      ? const Center(
                          child: Icon(
                            Icons.check, 
                            color: Colors.white, 
                            size: 14,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: () {
        if (fromBottomSheet) {
          localizationController.setLanguage(Locale(
            AppConstants.languages[index].languageCode!,
            AppConstants.languages[index].countryCode,
          ), fromBottomSheet: fromBottomSheet);
        }
        localizationController.setSelectLanguageIndex(index);
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor.withValues(alpha: 0.05) 
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor 
                : Theme.of(context).disabledColor.withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Image.asset(
                          languageModel.imageUrl!, 
                          width: 34, 
                          height: 24, 
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Flexible(
                      child: Text(
                        languageModel.languageName!, 
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: isSelected 
                              ? Theme.of(context).primaryColor 
                              : Theme.of(context).textTheme.bodyLarge?.color,
                        ), 
                        maxLines: 1, 
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, 
                    color: Theme.of(context).primaryColor,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }
}