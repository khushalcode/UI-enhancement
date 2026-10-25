import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/util/blinkit_ui.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

/// Presentation-only module switcher (icon + label + underline) so every module
/// screen can switch modules. Uses the existing SplashController.switchModule.
class ModuleTabsBar extends StatelessWidget {
  const ModuleTabsBar({super.key});

  static bool isVisible(SplashController s) {
    return s.configModel != null && s.configModel!.module == null && s.moduleList != null && s.moduleList!.length > 1;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(builder: (splashController) {
      if (!isVisible(splashController)) return const SizedBox();
      return Container(
        color: BlinkitUi.accent(),
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: SizedBox(
          height: 62,
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
      );
    });
  }
}
