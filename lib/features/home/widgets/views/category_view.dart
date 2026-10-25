import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/home/widgets/category_pop_up.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/common/widgets/title_widget.dart';
import 'package:sixam_mart/util/blinkit_ui.dart';

class CategoryView extends StatelessWidget {
  const CategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();

    return GetBuilder<SplashController>(builder: (splashController) {
      bool isPharmacy = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.pharmacy;
      bool isFood = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.food;
      bool isGrocery = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.grocery;

      return GetBuilder<CategoryController>(builder: (categoryController) {
        bool isShop = splashController.module != null && splashController.module!.moduleType.toString() == AppConstants.ecommerce;

        return (categoryController.categoryList != null && categoryController.categoryList!.isEmpty)
        ? const SizedBox() : isPharmacy ? PharmacyCategoryView(categoryController: categoryController)
          : isFood ? FoodCategoryView(categoryController: categoryController)
          : isGrocery ? GroceryCategoryView(categoryController: categoryController)
          : isShop ? ShopCategoryView(categoryController: categoryController) : Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 158,
                    child: categoryController.categoryList != null ? ListView.builder(
                      controller: scrollController,
                      itemCount: categoryController.categoryList!.length > 10 ? 10 : categoryController.categoryList!.length,
                      padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeDefault),
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeDefault),
                          child: InkWell(
                            onTap: () {
                              if(index == 9 && categoryController.categoryList!.length > 10) {
                                Get.toNamed(RouteHelper.getCategoryRoute());
                              } else {
                                Get.toNamed(RouteHelper.getCategoryItemRoute(
                                  categoryController.categoryList![index].id, categoryController.categoryList![index].name!,
                                ));
                              }
                            },
                            child: SizedBox(
                              width: 80,
                              child: Column(children: [
                                SizedBox(
                                  height: 75, width: 75,
                                  child: Stack(children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                      child: CustomImage(
                                        image: '${categoryController.categoryList![index].imageFullUrl}',
                                        height: 75, width: 75, fit: BoxFit.cover,
                                      ),
                                    ),

                                    (index == 9 && categoryController.categoryList!.length > 10) ? Positioned(
                                      right: 0, left: 0, top: 0, bottom: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Theme.of(context).primaryColor.withOpacity(0.4),
                                              Theme.of(context).primaryColor.withOpacity(0.6),
                                              Theme.of(context).primaryColor.withOpacity(0.4),
                                            ],
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '+${categoryController.categoryList!.length - 10}',
                                            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).cardColor),
                                            maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                                          ),
                                        )
                                      ),
                                    ) : const SizedBox(),

                                  ]),
                                ),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                Padding(
                                  padding: EdgeInsets.only(right: index == 0 ? Dimensions.paddingSizeExtraSmall : 0),
                                  child: Text(
                                    (index == 9 && categoryController.categoryList!.length > 10) ? 'see_all'.tr : categoryController.categoryList![index].name!,
                                    style: robotoMedium.copyWith(fontSize: 11, color: (index == 9 && categoryController.categoryList!.length > 10) ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium!.color),
                                    maxLines: Get.find<LocalizationController>().isLtr ? 2 : 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                                  ),
                                ),

                              ]),
                            ),
                          ),
                        );
                      },
                    ) : CategoryShimmer(categoryController: categoryController),
                  ),
                ),

                ResponsiveHelper.isMobile(context) ? const SizedBox() : categoryController.categoryList != null ? Column(
                  children: [
                    InkWell(
                      onTap: (){
                        showDialog(context: context, builder: (con) => Dialog(child: SizedBox(height: 550, width: 600, child: CategoryPopUp(
                          categoryController: categoryController,
                        ))));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text('view_all'.tr, style: TextStyle(fontSize: Dimensions.paddingSizeDefault, color: Theme.of(context).cardColor)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10,)
                  ],
                ): CategoryShimmer(categoryController: categoryController),
              ],
            ),

          ],
        );
      });
    }
    );
  }
}

class PharmacyCategoryView extends StatelessWidget {
  final CategoryController categoryController;
  const PharmacyCategoryView({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        height: 160,
        child: categoryController.categoryList != null ? ListView.builder(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeDefault),
          itemCount: categoryController.categoryList!.length > 10 ? 10 : categoryController.categoryList!.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, right: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeDefault),
              child: InkWell(
                onTap: () {
                  if(index == 9 && categoryController.categoryList!.length > 10) {
                    Get.toNamed(RouteHelper.getCategoryRoute());
                  } else {
                    Get.toNamed(RouteHelper.getCategoryItemRoute(
                      categoryController.categoryList![index].id, categoryController.categoryList![index].name!,
                    ));
                  }
                },
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                child: Container(
                  width: 70,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(100), topRight: Radius.circular(100)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.3),
                        Theme.of(context).cardColor.withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: Column(children: [

                    Stack(
                      children: [

                        ClipRRect(
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(100), topRight: Radius.circular(100)),
                          child: CustomImage(
                            image: '${categoryController.categoryList![index].imageFullUrl}',
                            height: 60, width: double.infinity, fit: BoxFit.cover,
                          ),
                        ),

                        (index == 9 && categoryController.categoryList!.length > 10) ? Positioned(
                          right: 0, left: 0, top: 0, bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(100), topRight: Radius.circular(100)),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Theme.of(context).primaryColor.withOpacity(0.4),
                                  Theme.of(context).primaryColor.withOpacity(0.6),
                                  Theme.of(context).primaryColor.withOpacity(0.4),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '+${categoryController.categoryList!.length - 10}',
                                style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).cardColor),
                                maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                              ),
                            )
                          ),
                        ) : const SizedBox(),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Expanded(child: Text(
                      (index == 9 && categoryController.categoryList!.length > 10) ? 'see_all'.tr :  categoryController.categoryList![index].name!,
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall,
                      color: (index == 9 && categoryController.categoryList!.length > 10) ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyMedium!.color),
                      maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                    )),
                  ]),
                ),
              ),
            );
          },
        ) : PharmacyCategoryShimmer(categoryController: categoryController),
      ),
    ]);
  }
}

class GroceryCategoryView extends StatelessWidget {
  final CategoryController categoryController;
  const GroceryCategoryView({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    if (categoryController.categoryList == null) {
      return GroceryCategoryShimmer(categoryController: categoryController);
    }
    
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.isDesktop(context) ? 8 : ResponsiveHelper.isTab(context) ? 6 : 4,
        crossAxisSpacing: Dimensions.paddingSizeSmall,
        mainAxisSpacing: Dimensions.paddingSizeDefault,
        childAspectRatio: ResponsiveHelper.isDesktop(context) ? 0.75 : 0.65, 
      ),
      itemCount: categoryController.categoryList!.length > 11 ? 12 : categoryController.categoryList!.length,
      itemBuilder: (context, index) {
        bool isSeeAll = index == 11 && categoryController.categoryList!.length > 12;
        return InkWell(
          onTap: () {
            if(isSeeAll) {
              Get.toNamed(RouteHelper.getCategoryRoute());
            } else {
              Get.toNamed(RouteHelper.getCategoryItemRoute(
                categoryController.categoryList![index].id, categoryController.categoryList![index].name!,
              ));
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(children: [
            AspectRatio(
              aspectRatio: 1.0,
              child: isSeeAll ? Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2), width: 1),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.grid_view_rounded,
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+${categoryController.categoryList!.length - 11}',
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ) : Container(
                decoration: BoxDecoration(
                  color: Get.find<ThemeController>().darkTheme 
                      ? Theme.of(context).disabledColor.withValues(alpha: 0.1) 
                      : const Color(0xFFECEEF2),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.only(top: 14, left: 6, right: 6, bottom: 2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CustomImage(
                    image: '${categoryController.categoryList![index].imageFullUrl}',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            Expanded(child: Text(
              isSeeAll ? 'see_all'.tr : categoryController.categoryList![index].name ?? '',
              style: robotoBold.copyWith(
                fontSize: 12,
                color: isSeeAll ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
              ),
              maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
            )),
          ]),
        );
      },
    );
  }
}

class GroceryCategoryShimmer extends StatelessWidget {
  final CategoryController categoryController;
  const GroceryCategoryShimmer({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.isDesktop(context) ? 8 : ResponsiveHelper.isTab(context) ? 6 : 4,
        crossAxisSpacing: Dimensions.paddingSizeSmall,
        mainAxisSpacing: Dimensions.paddingSizeDefault,
        childAspectRatio: ResponsiveHelper.isDesktop(context) ? 0.75 : 0.65,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Column(children: [
          AspectRatio(
            aspectRatio: 1.0,
            child: Shimmer(
              duration: const Duration(seconds: 2),
              enabled: true,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[300],
                ),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Shimmer(
            duration: const Duration(seconds: 2),
            enabled: true,
            child: Container(
              height: 12, width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey[300],
              ),
            ),
          ),
        ]);
      },
    );
  }
}

class FoodCategoryView extends StatelessWidget {
  final CategoryController categoryController;
  const FoodCategoryView({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    if (categoryController.categoryList == null) {
      return FoodCategoryShimmer(categoryController: categoryController);
    }

    final Color accent = BlinkitUi.accent();
    final int total = categoryController.categoryList!.length;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.isDesktop(context) ? 8 : ResponsiveHelper.isTab(context) ? 6 : 4,
        crossAxisSpacing: Dimensions.paddingSizeExtraSmall,
        mainAxisSpacing: Dimensions.paddingSizeExtraSmall,
        childAspectRatio: ResponsiveHelper.isDesktop(context) ? 0.9 : 0.82,
      ),
      itemCount: total > 11 ? 12 : total,
      itemBuilder: (context, index) {
        bool isSeeAll = index == 11 && total > 12;
        return InkWell(
          onTap: () {
            if(isSeeAll) {
              Get.toNamed(RouteHelper.getCategoryRoute());
            } else {
              Get.toNamed(RouteHelper.getCategoryItemRoute(
                categoryController.categoryList![index].id, categoryController.categoryList![index].name!,
              ));
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              height: 62, width: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSeeAll ? accent.withValues(alpha: 0.25) : Colors.white,
                border: Border.all(color: accent, width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: ClipOval(
                child: isSeeAll ? Center(
                  child: Text(
                    '+${total - 11}',
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: BlinkitUi.ink),
                  ),
                ) : CustomImage(
                  image: '${categoryController.categoryList![index].imageFullUrl}',
                  height: 62, width: 62, fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 4),

            Text(
              isSeeAll ? 'see_all'.tr : categoryController.categoryList![index].name ?? '',
              style: robotoMedium.copyWith(fontSize: 11, color: BlinkitUi.ink),
              maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
            ),
          ]),
        );
      },
    );
  }
}

class CategoryShimmer extends StatelessWidget {
  final CategoryController categoryController;
  const CategoryShimmer({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 8,
      padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall, top: Dimensions.paddingSizeDefault),
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1, vertical: Dimensions.paddingSizeDefault),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: true,
            child: SizedBox(
              width: 80,
              child: Column(children: [
                Container(
                  height: 75, width: 75,
                  margin: EdgeInsets.only(
                    left: index == 0 ? 0 : Dimensions.paddingSizeExtraSmall,
                    right: Dimensions.paddingSizeExtraSmall,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    color: Colors.grey[300],
                  )
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Padding(
                  padding: EdgeInsets.only(right: index == 0 ? Dimensions.paddingSizeExtraSmall : 0),
                  child: Container(
                    height: 10, width: 50,
                    color: Colors.grey[300],
                  ),
                ),

              ]),
            ),
          ),
        );
      },
    );
  }
}

class FoodCategoryShimmer extends StatelessWidget {
  final CategoryController categoryController;
  const FoodCategoryShimmer({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.isDesktop(context) ? 8 : ResponsiveHelper.isTab(context) ? 6 : 4,
        crossAxisSpacing: Dimensions.paddingSizeSmall,
        mainAxisSpacing: Dimensions.paddingSizeDefault,
        childAspectRatio: ResponsiveHelper.isDesktop(context) ? 0.75 : 0.65, 
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Column(children: [
          ClipOval(
            child: Shimmer(
              duration: const Duration(seconds: 2),
              enabled: true,
              child: Container(
                height: 70, width: 70,
                color: Colors.grey[300],
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Shimmer(
            duration: const Duration(seconds: 2),
            enabled: true,
            child: Container(
              height: 10, width: 50,
              color: Colors.grey[300],
            ),
          ),
        ]);
      },
    );
  }
}

class PharmacyCategoryShimmer extends StatelessWidget {
  final CategoryController categoryController;
  const PharmacyCategoryShimmer({super.key, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, left: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeDefault),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: true,
            child: Container(
              width: 70,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(100), topRight: Radius.circular(100)),
              ),
              child: Column(children: [

                Container(
                  height: 60, width: double.infinity,
                  margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(100), topRight: Radius.circular(100)),
                    color: Colors.grey[300],
                  )
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Expanded(
                  child: Container(
                    height: 10, width: 50,
                    color: Colors.grey[300],
                  ),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}

class ShopCategoryView extends StatefulWidget {
  final CategoryController categoryController;
  const ShopCategoryView({super.key, required this.categoryController});

  @override
  State<ShopCategoryView> createState() => _ShopCategoryViewState();
}

class _ShopCategoryViewState extends State<ShopCategoryView> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.categoryController.categoryList == null) {
      return const SizedBox();
    }
    if (widget.categoryController.categoryList!.isEmpty) {
      return const SizedBox();
    }

    final categories = widget.categoryController.categoryList!;
    const int itemsPerPage = 12;
    final int totalPages = (categories.length / itemsPerPage).ceil();

    int itemsToDisplay = categories.length > itemsPerPage ? itemsPerPage : categories.length;
    int rows = (itemsToDisplay / 4).ceil();
    final double itemWidth = (MediaQuery.of(context).size.width - (Dimensions.paddingSizeSmall * 2) - (Dimensions.paddingSizeSmall * 3)) / 4;
    final double itemHeight = itemWidth / 0.65;
    final double pageHeight = (rows * itemHeight) + ((rows > 0 ? rows - 1 : 0) * Dimensions.paddingSizeDefault) + (Dimensions.paddingSizeSmall * 2);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'categories'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
              ),
              if (totalPages > 1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentPage + 1}/$totalPages',
                    style: robotoBold.copyWith(color: Colors.white, fontSize: 10),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: pageHeight,
          child: PageView.builder(
            itemCount: totalPages,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, pageIndex) {
              final int startIndex = pageIndex * itemsPerPage;
              final int endIndex = (startIndex + itemsPerPage < categories.length)
                  ? startIndex + itemsPerPage
                  : categories.length;
              final pageCategories = categories.sublist(startIndex, endIndex);

              return GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: Dimensions.paddingSizeSmall,
                  mainAxisSpacing: Dimensions.paddingSizeDefault,
                  childAspectRatio: 0.65,
                ),
                itemCount: pageCategories.length,
                itemBuilder: (context, index) {
                  final category = pageCategories[index];
                  return InkWell(
                    onTap: () {
                      Get.toNamed(RouteHelper.getCategoryItemRoute(
                        category.id, category.name!,
                      ));
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 75,
                          height: 75,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFFDF5), Color(0xFFF9E8C3)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            border: Border.all(
                              color: const Color(0xFFECCB7A),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: CustomImage(
                                image: '${category.imageFullUrl}',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            category.name ?? '',
                            style: robotoBold.copyWith(
                              fontSize: 11,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}