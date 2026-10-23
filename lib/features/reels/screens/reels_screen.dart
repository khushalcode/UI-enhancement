import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/reels/controllers/reels_controller.dart';
import 'package:sixam_mart/features/reels/widgets/reel_item_widget.dart';
import 'package:sixam_mart/common/widgets/custom_loader.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    Get.find<ReelsController>().getReelsList(1, true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GetBuilder<ReelsController>(builder: (reelsController) {
        if (reelsController.reelsList == null) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (reelsController.reelsList!.isEmpty) {
          return Center(
            child: Text(
              'no_reels_found'.tr,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
        }

        return Center(
          child: Container(
            width: context.width > 700 ? 450 : context.width,
            child: PageView.builder(
              scrollDirection: Axis.vertical,
              controller: _pageController,
              itemCount: reelsController.reelsList!.length,
              onPageChanged: (index) {
                if (index == reelsController.reelsList!.length - 1 && !reelsController.isLoading) {
                  // Pagination - fetch more
                }
              },
              itemBuilder: (context, index) {
                return ReelItemWidget(reel: reelsController.reelsList![index]);
              },
            ),
          ),
        );
      }),
    );
  }
}
