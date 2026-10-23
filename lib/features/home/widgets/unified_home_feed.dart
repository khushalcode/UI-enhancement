import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/flash_sale/widgets/flash_sale_view_widget.dart';
import 'package:sixam_mart/features/home/widgets/highlight_widget.dart';
import 'package:sixam_mart/features/home/widgets/views/banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/best_reviewed_item_view.dart';
import 'package:sixam_mart/features/home/widgets/views/best_store_nearby_view.dart';
import 'package:sixam_mart/features/home/widgets/views/category_view.dart';
import 'package:sixam_mart/features/home/widgets/views/item_that_you_love_view.dart';
import 'package:sixam_mart/features/home/widgets/views/just_for_you_view.dart';
import 'package:sixam_mart/features/home/widgets/views/middle_section_banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/most_popular_item_view.dart';
import 'package:sixam_mart/features/home/widgets/views/new_on_mart_view.dart';
import 'package:sixam_mart/features/home/widgets/views/promo_code_banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/promotional_banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/recommended_store_view.dart';
import 'package:sixam_mart/features/home/widgets/views/special_offer_view.dart';
import 'package:sixam_mart/features/home/widgets/views/top_offers_near_me.dart';
import 'package:sixam_mart/features/home/widgets/views/visit_again_view.dart';
import 'package:sixam_mart/helper/auth_helper.dart';

/// A unified home feed shown when no module is selected yet.
///
/// It pulls small content features from every module (grocery, food, parcel,
/// pharmacy, shop) into a single scrollable feed, so the home screen feels
/// rich and interactive instead of showing only the giant module cards.
///
/// This is a UI-only composition — every child widget keeps its own existing
/// controllers, API calls and routing. Nothing about the data flow changes.
class UnifiedHomeFeed extends StatelessWidget {
  const UnifiedHomeFeed({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = AuthHelper.isLoggedIn();
    final double vSpace = MediaQuery.of(context).size.height * 0.02;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Featured banner carousel (existing API: featuredBannerList)
      const BannerView(isFeatured: true),
      SizedBox(height: vSpace),

      // Category strip — quick entry into any category
      const CategoryView(),
      SizedBox(height: vSpace),

      // "Powered by Exclusive Deals" — gradient card with discounted items
      const SpecialOfferView(isFood: false, isShop: false),
      SizedBox(height: vSpace),

      // Visit again (only if logged in)
      isLoggedIn ? const VisitAgainView() : const SizedBox(),
      SizedBox(height: isLoggedIn ? vSpace : 0),

      // Recommended stores across all modules
      const RecommendedStoreView(),
      SizedBox(height: vSpace),

      // Flash sale widget (grocery-style countdown deals)
      const FlashSaleViewWidget(),
      SizedBox(height: vSpace),

      // Highlight widget — promotional splash banner
      const HighlightWidget(),
      SizedBox(height: vSpace),

      // Best stores nearby — covers food / grocery / pharmacy stores
      const BestStoreNearbyView(),
      SizedBox(height: vSpace),

      // Most popular items across modules
      const MostPopularItemView(isFood: false, isShop: false),
      SizedBox(height: vSpace),

      // Middle section promotional banner
      const MiddleSectionBannerView(),
      SizedBox(height: vSpace),

      // Best reviewed items
      const BestReviewItemView(),
      SizedBox(height: vSpace),

      // Just for you
      const JustForYouView(),
      SizedBox(height: vSpace),

      // Top offers near me
      const TopOffersNearMe(),
      SizedBox(height: vSpace),

      // Items that you love
      const ItemThatYouLoveView(forShop: false),
      SizedBox(height: vSpace),

      // Promo code banner (only if logged in)
      isLoggedIn ? const PromoCodeBannerView() : const SizedBox(),
      SizedBox(height: isLoggedIn ? vSpace : 0),

      // New on mart — newly added stores across modules
      const NewOnMartView(isPharmacy: false, isShop: false),
      SizedBox(height: vSpace),

      // Promotional banner (bottom of feed)
      const PromotionalBannerView(),
      SizedBox(height: vSpace * 2.5),
    ]);
  }
}
