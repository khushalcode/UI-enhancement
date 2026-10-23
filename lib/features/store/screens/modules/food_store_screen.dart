import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/store/controllers/store_controller.dart';
import 'package:sixam_mart/features/category/controllers/category_controller.dart';
import 'package:sixam_mart/features/favourite/controllers/favourite_controller.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/features/home/widgets/views/special_offer_view.dart';
import 'package:sixam_mart/common/widgets/paginated_list_view.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/common/widgets/web_menu_bar.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/common/widgets/store_header_countdown_widget.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/features/checkout/screens/checkout_screen.dart';
import 'package:sixam_mart/features/store/widgets/bottom_cart_widget.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/features/store/widgets/store_details_screen_shimmer_widget.dart';
import 'package:sixam_mart/features/language/controllers/language_controller.dart';
import 'package:sixam_mart/features/store/widgets/customizable_space_bar_widget.dart';
import 'package:sixam_mart/features/store/widgets/store_description_view_widget.dart';

class FoodStoreScreen extends StatefulWidget {
  final Store? store;
  const FoodStoreScreen({super.key, required this.store});

  @override
  State<FoodStoreScreen> createState() => _FoodStoreScreenState();
}

class _FoodStoreScreenState extends State<FoodStoreScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      endDrawer: const MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      backgroundColor: Theme.of(context).cardColor,
      body: Center(
        child: Container(
          width: Dimensions.webMaxWidth,
          color: Theme.of(context).cardColor,
          child: GetBuilder<StoreController>(builder: (storeController) {
            return GetBuilder<CategoryController>(builder: (categoryController) {
              Store? store = storeController.store ?? widget.store;
              if (store == null) return const Center(child: CircularProgressIndicator());
              
              if(storeController.store != null && storeController.store!.name != null && categoryController.categoryList != null) {
                if (storeController.categoryList == null) {
                  storeController.setCategoryList();
                }
              }

              bool showData = storeController.store != null && storeController.store!.name != null && categoryController.categoryList != null;
              return showData ? CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                          child: CustomImage(
                            image: '${store.coverPhotoFullUrl}',
                            fit: BoxFit.cover,
                            height: 250,
                            width: double.infinity,
                          ),
                        ),
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: Container(
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                              ),
                            ),
                          ),
                        ),
                        if (!ResponsiveHelper.isDesktop(context))
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 10,
                            left: 15,
                            child: InkWell(
                              onTap: () => Get.back(),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white, width: 1.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.chevron_left, color: Colors.white, size: 24),
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 20,
                          left: 15,
                          right: 15,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CustomImage(
                                    image: '${store.logoFullUrl}',
                                    height: 60, width: 60, fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      store.name ?? '',
                                      style: robotoBold.copyWith(fontSize: 18, color: Colors.white),
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      store.address ?? '',
                                      style: robotoRegular.copyWith(fontSize: 12, color: Colors.white70),
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Minimum Order Amount ${PriceConverter.convertPrice(store.minimumOrder)}',
                                      style: robotoRegular.copyWith(fontSize: 10, color: Colors.white70),
                                    ),
                                    StoreHeaderCountdownWidget(store: store),
                                  ],
                                ),
                              ),
                              GetBuilder<FavouriteController>(builder: (favouriteController) {
                                  bool isWished = favouriteController.wishStoreIdList.contains(store.id);
                                  return InkWell(
                                    onTap: () {
                                      if(AuthHelper.isLoggedIn()) {
                                        isWished ? favouriteController.removeFromFavouriteList(store.id, true)
                                            : favouriteController.addToFavouriteList(null, store.id, true);
                                      } else {
                                        showCustomSnackBar('you_are_not_logged_in'.tr);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withValues(alpha: 0.2),
                                      ),
                                      child: Icon(
                                        isWished ? Icons.favorite : Icons.favorite_border,
                                        color: isWished ? Theme.of(context).primaryColor : Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  );
                                }),
                                const SizedBox(width: 10),
                                AppConstants.webHostedUrl.isNotEmpty ? InkWell(
                                  onTap: () {
                                    storeController.shareStore();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(alpha: 0.2),
                                    ),
                                    child: const Icon(Icons.share, color: Colors.white, size: 20),
                                  ),
                                ) : const SizedBox(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.star, color: Theme.of(context).primaryColor, size: 16),
                                      const SizedBox(width: 5),
                                      Text('${store.avgRating?.toStringAsFixed(1) ?? '0.0'}', style: robotoBold.copyWith(fontSize: 14)),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text('${store.ratingCount}+ Ratings', style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).disabledColor)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.black87, size: 16),
                                  const SizedBox(height: 5),
                                  Text('Location', style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).disabledColor)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.flash_on, color: Theme.of(context).primaryColor, size: 16),
                                  const SizedBox(height: 5),
                                  Text('${store.deliveryTime}', style: robotoBold.copyWith(fontSize: 12)),
                                  const SizedBox(height: 5),
                                  Text('Delivery Time', style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).disabledColor)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search for items...',
                            hintStyle: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
                            prefixIcon: Icon(Icons.search, color: Theme.of(context).disabledColor),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onSubmitted: (val) {
                            if (val.trim().isNotEmpty) {
                              storeController.getStoreSearchItemList(val.trim(), store.id.toString(), 1, storeController.type);
                            }
                          },
                        ),
                      ),
                    ),
                  ),

                  if (storeController.categoryList != null && storeController.categoryList!.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Text('All Products', style: robotoBold.copyWith(fontSize: 16)),
                            ),
                            const SizedBox(height: 15),
                            SizedBox(
                              height: 90,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                itemCount: storeController.categoryList!.length,
                                itemBuilder: (context, index) {
                                  bool isSelected = storeController.categoryIndex == index;
                                  var cat = storeController.categoryList![index];
                                  return GestureDetector(
                                    onTap: () => storeController.setCategoryIndex(index),
                                    child: Container(
                                      width: 65,
                                      margin: const EdgeInsets.only(right: 15),
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 55, width: 55,
                                            decoration: BoxDecoration(
                                              color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.white,
                                              shape: BoxShape.circle,
                                              border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 1.5) : null,
                                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
                                            ),
                                            child: ClipOval(
                                              child: index == 0 ? Icon(Icons.category, color: Theme.of(context).primaryColor) :
                                              CustomImage(
                                                image: '${cat.imageFullUrl}',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            cat.name ?? '',
                                            style: robotoMedium.copyWith(
                                              fontSize: 10,
                                              color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                                            ),
                                            maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  SliverToBoxAdapter(
                    child: storeController.isSearching && storeController.storeSearchItemModel == null
                        ? const Center(child: CircularProgressIndicator())
                        : (!storeController.isSearching && storeController.storeItemModel == null)
                        ? const Center(child: CircularProgressIndicator())
                        : (storeController.isSearching ? storeController.storeSearchItemModel?.items?.isEmpty ?? true : storeController.storeItemModel?.items?.isEmpty ?? true)
                        ? const Center(child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('No items found'),
                        ))
                        : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : ResponsiveHelper.isTab(context) ? 4 : 2,
                              childAspectRatio: ResponsiveHelper.isDesktop(context) ? 0.75 : 0.85,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(15),
                            itemCount: (storeController.isSearching ? storeController.storeSearchItemModel?.items : storeController.storeItemModel?.items)?.length ?? 0,
                            itemBuilder: (context, index) {
                              var items = storeController.isSearching ? storeController.storeSearchItemModel?.items : storeController.storeItemModel?.items;
                              return CustomSpecialOfferCard(item: items![index]);
                            },
                          ),
                      ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 50)),
                ],
              ) : const StoreDetailsScreenShimmerWidget();
            });
          }),
        ),
      ),
      floatingActionButton: GetBuilder<StoreController>(
        builder: (storeController) {
          Store? store = storeController.store ?? widget.store;
          return Visibility(
            visible: storeController.showFavButton && Get.find<SplashController>().configModel!.moduleConfig!.module!.orderAttachment!
                && (store != null && store.prescriptionOrder!)
                && Get.find<SplashController>().configModel!.prescriptionStatus! && AuthHelper.isLoggedIn(),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                boxShadow: [BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.5), blurRadius: 10, offset: const Offset(2, 2))],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [

                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  width: storeController.currentState == true ? 0 : ResponsiveHelper.isDesktop(context) ? 180 : 150,
                  height: 30,
                  curve: Curves.linear,
                  child:  Center(
                    child: Text(
                      'prescription_order'.tr, textAlign: TextAlign.center,
                      style: robotoMedium.copyWith(color: Theme.of(context).primaryColor), maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                InkWell(
                  onTap: () {
                    Get.find<CheckoutController>().updateFirstTime();
                    Get.find<CheckoutController>().updateFirstTimeCodActive();
                    Get.toNamed(
                      RouteHelper.getCheckoutRoute('prescription', storeId: store!.id),
                      arguments: CheckoutScreen(fromCart: false, cartList: null, storeId: store.id),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Image.asset(Images.prescriptionIcon, height: 25, width: 25),
                  ),
                ),

              ]),
            ),
          );
        }
      ),
      bottomNavigationBar: GetBuilder<CartController>(builder: (cartController) {
        return cartController.cartList.isNotEmpty && !ResponsiveHelper.isDesktop(context) ? const BottomCartWidget() : const SizedBox();
      }),
    );
  }
}
