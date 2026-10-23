import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:sixam_mart/features/reels/domain/models/reel_model.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';

class ReelItemWidget extends StatefulWidget {
  final ReelModel reel;
  const ReelItemWidget({super.key, required this.reel});

  @override
  State<ReelItemWidget> createState() => _ReelItemWidgetState();
}

class _ReelItemWidgetState extends State<ReelItemWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    String url = '${AppConstants.baseUrl}/storage/app/public/product-reels/${widget.reel.videoUrl}';
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_controller.value.isPlaying) {
      _controller.pause();
      _isPlaying = false;
    } else {
      _controller.play();
      _isPlaying = true;
    }
    setState(() {});
  }

  Future<void> _navigateWithModuleCheck(int? moduleId, String route) async {
    _controller.pause();
    setState(() {
      _isPlaying = false;
    });

    if (moduleId != null) {
      SplashController splashController = Get.find<SplashController>();
      if (splashController.module == null || splashController.module!.id != moduleId) {
        if (splashController.moduleList != null) {
          for (var module in splashController.moduleList!) {
            if (module.id == moduleId) {
              await splashController.setModule(module);
              break;
            }
          }
        }
      }
    }

    await Get.toNamed(route);
    
    _controller.play();
    setState(() {
      _isPlaying = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _controller.value.isInitialized
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                )
              : const Center(child: CircularProgressIndicator(color: Colors.white)),
          
          if (!_isPlaying)
            const Center(
              child: Icon(Icons.play_arrow, size: 80, color: Colors.white54),
            ),

          // Bottom Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.reel.store != null)
                    InkWell(
                      onTap: () {
                        _navigateWithModuleCheck(widget.reel.store!.moduleId, RouteHelper.getStoreRoute(id: widget.reel.store!.id, page: 'item'));
                      },
                      child: Row(
                        children: [
                          ClipOval(
                            child: CustomImage(
                              image: '${AppConstants.baseUrl}/storage/app/public/store/${widget.reel.store!.logo}',
                              height: 40, width: 40, fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Text(
                            widget.reel.store!.name ?? '',
                            style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  if (widget.reel.item != null)
                    Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            child: CustomImage(
                              image: '${AppConstants.baseUrl}/storage/app/public/product/${widget.reel.item!.image}',
                              height: 60, width: 60, fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.reel.item!.name ?? '',
                                  style: robotoMedium.copyWith(color: Colors.white),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                Row(
                                  children: [
                                    Text(
                                      PriceConverter.convertPrice(
                                        widget.reel.item!.price ?? 0,
                                        discount: widget.reel.item!.discount,
                                        discountType: widget.reel.item!.discountType,
                                      ),
                                      style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge),
                                    ),
                                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                    if ((widget.reel.item!.discount ?? 0) > 0)
                                      Text(
                                        PriceConverter.convertPrice(widget.reel.item!.price ?? 0),
                                        style: robotoRegular.copyWith(
                                          color: Colors.white70,
                                          fontSize: Dimensions.fontSizeSmall,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          CustomButton(
                            width: 100,
                            height: 40,
                            buttonText: 'Buy Now',
                            onPressed: () {
                              _navigateWithModuleCheck(widget.reel.item!.moduleId, RouteHelper.getItemDetailsRoute(widget.reel.item!.id, false));
                            },
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 80), // Space for bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
