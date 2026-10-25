import 'package:sixam_mart/util/blinkit_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/home/widgets/highlight_widget.dart';
import 'package:sixam_mart/features/home/widgets/views/category_view.dart';
import 'package:sixam_mart/features/home/widgets/views/recommended_store_view.dart';
import 'package:sixam_mart/features/home/widgets/views/top_offers_near_me.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/features/home/widgets/views/best_reviewed_item_view.dart';
import 'package:sixam_mart/features/home/widgets/views/best_store_nearby_view.dart';
import 'package:sixam_mart/features/home/widgets/views/item_that_you_love_view.dart';
import 'package:sixam_mart/features/home/widgets/views/just_for_you_view.dart';
import 'package:sixam_mart/features/home/widgets/views/most_popular_item_view.dart';
import 'package:sixam_mart/features/home/widgets/views/new_on_mart_view.dart';
import 'package:sixam_mart/features/home/widgets/views/special_offer_view.dart';
import 'package:sixam_mart/features/home/widgets/views/visit_again_view.dart';
import 'package:sixam_mart/features/home/widgets/banner_view.dart';
import 'package:sixam_mart/features/home/controllers/home_controller.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/util/dimensions.dart';

class FoodHomeScreen extends StatelessWidget {
  const FoodHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      /// Compact rounded banner sitting on the accent header colour
      Container(
        width: MediaQuery.of(context).size.width,
        color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeSmall, Dimensions.paddingSizeExtraSmall, Dimensions.paddingSizeSmall, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: const BannerView(isFeatured: false),
        ),
      ),

      /// Section: Category
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        child: CategoryView(),
      ),

      _wrapInGradientCard(context, const SpecialOfferView(isFood: true, isShop: false), BlinkitUi.sectionTint()),

      const SizedBox(height: 10),

      GetBuilder<HomeController>(builder: (homeController) {
        return (homeController.cashBackOfferList != null && homeController.cashBackOfferList!.isNotEmpty) ? Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2B2B2B), Color(0xFF1C1C1C)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 6))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Premium Rewards', style: robotoBold.copyWith(fontSize: 16, color: Colors.white)),
                  Icon(Icons.stars_rounded, color: BlinkitUi.red, size: 22),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 84,
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 20),
                scrollDirection: Axis.horizontal,
                itemCount: homeController.cashBackOfferList!.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 220,
                    margin: const EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(
                          homeController.cashBackOfferList![index].title ?? '',
                          style: robotoBold.copyWith(color: BlinkitUi.yellow, fontSize: 16),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Exclusive member benefit',
                          style: robotoRegular.copyWith(color: Colors.white70, fontSize: 11),
                        ),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ]),
        ) : const SizedBox();
      }),

      const SizedBox(height: 8),
      _wrapInWhiteCard(context, isLoggedIn ? const VisitAgainView(fromFood: true) : const SizedBox()),
      const SizedBox(height: 8),
      _wrapInWhiteCard(context, const RecommendedStoreView()),
      const JustForYouView(),
      const HighlightWidget(),
      const TopOffersNearMe(),
      _wrapInGradientCard(context, const BestReviewItemView(), BlinkitUi.sectionTint()),
      _wrapInWhiteCard(context, const BestStoreNearbyView()),
      const ItemThatYouLoveView(forShop: false),
      _wrapInGradientCard(context, const MostPopularItemView(isFood: true, isShop: false), BlinkitUi.sectionTint()),
      const NewOnMartView(isNewStore: true, isPharmacy: false, isShop: false),
      SizedBox(height: MediaQuery.of(context).size.height * 0.05),
    ]);
  }

  Widget _wrapInWhiteCard(BuildContext context, Widget child) {
    if(child is SizedBox && (child as SizedBox).width == null && (child as SizedBox).height == null) return const SizedBox();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: child,
    );
  }

  Widget _wrapInGradientCard(BuildContext context, Widget child, List<Color> colors) {
    if(child is SizedBox && (child as SizedBox).width == null && (child as SizedBox).height == null) return const SizedBox();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: child,
    );
  }
}
