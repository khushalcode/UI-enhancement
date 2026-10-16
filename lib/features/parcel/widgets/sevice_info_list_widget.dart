import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/parcel/controllers/parcel_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class ServiceInfoListWidget extends StatelessWidget {
  final ParcelController parcelController;
  const ServiceInfoListWidget({super.key, required this.parcelController});

  @override
  Widget build(BuildContext context) {
    List<String>? title;
    List<String>? subTitle;
    if(parcelController.videoContentDetails != null && parcelController.videoContentDetails!.bannerContents != null && parcelController.videoContentDetails!.bannerContents!.isNotEmpty) {
      title = [];
      subTitle = [];
      for(int i=0; i<parcelController.videoContentDetails!.bannerContents!.length; i++) {
        if(i%2 == 0){
          title.add(parcelController.videoContentDetails!.bannerContents![i].value ?? '');
        } else {
          subTitle.add(parcelController.videoContentDetails!.bannerContents![i].value ?? '');
        }
      }
    } else {
      // Fallback to hardcoded 3 points
      title = [
        'Select the service',
        'Fill in the information',
        'And now wait for the delivery!'
      ];
      subTitle = [
        'Effortless Parcel Ordering: Get Started Now!',
        'Fill in the receiver\'s information and the type of product.',
        'Being delivered and wait for your parcel to be picked up!'
      ];
    }
    return parcelController.videoContentDetails != null ? ListView.builder(
      physics: const ScrollPhysics(),
      shrinkWrap: true,
      itemCount: title!.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(children: [
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),

              Flexible(child: Text(title![index], style: robotoBold, maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
          ),

          Container(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: 22.5),
            margin: EdgeInsets.only(left: Get.find<LocalizationController>().isLtr ? 18 : 0, right: Get.find<LocalizationController>().isLtr ? 0 : 18),
            decoration: BoxDecoration(
              border: index == title.length - 1 ? null : Border(left: Get.find<LocalizationController>().isLtr ? BorderSide(width: 1, color: Theme.of(context).disabledColor)
                  : BorderSide.none, right: Get.find<LocalizationController>().isLtr ? BorderSide.none : BorderSide(width: 1, color: Theme.of(context).disabledColor)),
            ),
            child: Text(
              subTitle![index],
              style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
              textAlign: TextAlign.justify,
            ),
          ),
        ]);
      },
    ) : const SizedBox();
  }
}
