import 'package:sixam_mart/util/blinkit_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/features/flash_sale/widgets/flash_sale_view_widget.dart';
import 'package:sixam_mart/features/home/widgets/highlight_widget.dart';
import 'package:sixam_mart/features/home/widgets/views/banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/best_reviewed_item_view.dart';
import 'package:sixam_mart/features/home/widgets/views/best_store_nearby_view.dart';
import 'package:sixam_mart/features/home/widgets/views/category_view.dart';
import 'package:sixam_mart/features/home/widgets/views/promo_code_banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/item_that_you_love_view.dart';
import 'package:sixam_mart/features/home/widgets/views/just_for_you_view.dart';
import 'package:sixam_mart/features/home/widgets/views/most_popular_item_view.dart';
import 'package:sixam_mart/features/home/widgets/views/new_on_mart_view.dart';
import 'package:sixam_mart/features/home/widgets/views/middle_section_banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/recommended_store_view.dart';
import 'package:sixam_mart/features/home/widgets/views/special_offer_view.dart';
import 'package:sixam_mart/features/home/widgets/views/promotional_banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/top_offers_near_me.dart';
import 'package:sixam_mart/features/home/widgets/views/visit_again_view.dart';
import 'package:sixam_mart/helper/auth_helper.dart';


class GroceryHomeScreen extends StatelessWidget {
  const GroceryHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Container(
        width: MediaQuery.of(context).size.width,
        decoration: Get.find<ThemeController>().darkTheme ? null : BoxDecoration(
          gradient: LinearGradient(
            colors: [BlinkitUi.accent(), BlinkitUi.accent()],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child:  const Column(
          children: [
            SizedBox(height: 10),
            BannerView(isFeatured: false),
            SizedBox(height: 20),
          ],
        ),
      ),

      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      const CategoryView(),
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      isLoggedIn ? const VisitAgainView() : const SizedBox(),
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      const RecommendedStoreView(),
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      _wrapInGradientCard(context, const SpecialOfferView(isFood: false, isShop: false), [const Color(0xFFFFF9E6), const Color(0xFFFFEFA7)]),
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      const HighlightWidget(),
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      const FlashSaleViewWidget(),
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      const BestStoreNearbyView(),
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      const MostPopularItemView(isFood: false, isShop: false),
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      const MiddleSectionBannerView(),
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      const BestReviewItemView(),
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      const JustForYouView(),
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      const TopOffersNearMe(),
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      const ItemThatYouLoveView(forShop: false),
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      isLoggedIn ? const PromoCodeBannerView() : const SizedBox(),
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      const NewOnMartView(isPharmacy: false, isShop: false),
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      const PromotionalBannerView(),
      SizedBox(height: MediaQuery.of(context).size.height * 0.05),
    ]);
  }

  Widget _wrapInGradientCard(BuildContext context, Widget child, List<Color> colors) {
    if(child is SizedBox && (child as SizedBox).width == null && (child as SizedBox).height == null) return const SizedBox();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
