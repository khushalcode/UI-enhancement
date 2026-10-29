import 'package:sixam_mart/features/home/widgets/views/bestsellers_view.dart';
import 'package:sixam_mart/util/blinkit_ui.dart';
import 'package:flutter/material.dart';
import 'package:sixam_mart/features/home/widgets/highlight_widget.dart';
import 'package:sixam_mart/features/home/widgets/views/product_with_categories_view.dart';
import 'package:sixam_mart/features/home/widgets/views/best_store_nearby_view.dart';
import 'package:sixam_mart/features/home/widgets/views/common_condition_view.dart';
import 'package:sixam_mart/features/home/widgets/views/just_for_you_view.dart';
import 'package:sixam_mart/features/home/widgets/views/middle_section_banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/new_on_mart_view.dart';
import 'package:sixam_mart/features/home/widgets/views/promotional_banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/recommended_store_view.dart';
import 'package:sixam_mart/features/home/widgets/views/top_offers_near_me.dart';
import 'package:sixam_mart/features/home/widgets/views/visit_again_view.dart';
import 'package:sixam_mart/features/home/widgets/banner_view.dart';
import 'package:sixam_mart/features/home/widgets/views/category_view.dart';
import 'package:sixam_mart/helper/auth_helper.dart';

class PharmacyHomeScreen extends StatelessWidget {
  const PharmacyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      Container(
        width: MediaQuery.of(context).size.width,
        color: Theme.of(context).disabledColor.withValues(alpha: 0.1),
        child:  const Column(
          children: [
            BannerView(isFeatured: false),
            SizedBox(height: 12),
          ],
        ),
      ),

      const SizedBox(height: 8),
      const BestsellersView(),
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      const CategoryView(),
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      isLoggedIn ? _wrapInGradientCard(context, const VisitAgainView(), BlinkitUi.sectionTint()) : const SizedBox(),
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      const RecommendedStoreView(),
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      const ProductWithCategoriesView(),
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      const HighlightWidget(),
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      const MiddleSectionBannerView(),
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      _wrapInGradientCard(context, const BestStoreNearbyView(), BlinkitUi.sectionTint()),
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      const JustForYouView(),
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      const TopOffersNearMe(),
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      const NewOnMartView(isShop: false, isPharmacy: true, isNewStore: true),
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      const CommonConditionView(),
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      const PromotionalBannerView(),
      SizedBox(height: MediaQuery.of(context).size.height * 0.05),
    ]);
  }

  Widget _wrapInGradientCard(BuildContext context, Widget child, List<Color> colors) {
    if(child is SizedBox && (child as SizedBox).width == null && (child as SizedBox).height == null) return const SizedBox();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: child,
    );
  }
}
