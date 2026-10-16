import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/cab_booking/home/controllers/cab_controller.dart';
import 'package:sixam_mart/features/cab_booking/home/screens/cab_ride_details_screen.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';

class CabHistoryScreen extends StatefulWidget {
  const CabHistoryScreen({super.key});

  @override
  State<CabHistoryScreen> createState() => _CabHistoryScreenState();
}

class _CabHistoryScreenState extends State<CabHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.find<AuthController>().isLoggedIn()) {
        Get.find<CabController>().getMyRides();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

    return Scaffold(
      appBar: CustomAppBar(title: 'ride_history'.tr, backButton: true),
      backgroundColor: Theme.of(context).cardColor.withOpacity(0.95),
      body: !isLoggedIn ? _buildLoginPrompt() : GetBuilder<CabController>(builder: (cabController) {
        if (cabController.rideList == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (cabController.rideList!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_car_outlined, size: 80, color: Theme.of(context).disabledColor.withOpacity(0.3)),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Text('No rides booked yet', style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
          itemCount: cabController.rideList!.length,
          itemBuilder: (context, index) {
            final ride = cabController.rideList![index];
            return InkWell(
              onTap: () => Get.to(() => CabRideDetailsScreen(rideId: ride.id!)),
              child: Container(
                margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${'ride_id'.tr}: #${ride.id}', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                            Text(ride.scheduleAt != null ? 'Scheduled for: ${ride.scheduleAt}' : (ride.createdAt?.split('T')[0] ?? ''), 
                              style: robotoRegular.copyWith(color: ride.scheduleAt != null ? Colors.cyan : Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeExtraSmall)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(ride.status!).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            ride.status?.toUpperCase() ?? 'PENDING',
                            style: robotoBold.copyWith(
                              color: _getStatusColor(ride.status!),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    
                    Row(
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.circle, color: Colors.green, size: 12),
                            Container(height: 20, width: 2, color: Theme.of(context).disabledColor.withOpacity(0.3)),
                            const Icon(Icons.location_on, color: Colors.red, size: 14),
                          ],
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ride.pickupLocation ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 15),
                              Text(ride.dropLocation ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                      child: Divider(thickness: 0.5),
                    ),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.timer_outlined, size: 14, color: Theme.of(context).disabledColor),
                            const SizedBox(width: 5),
                            Text('Distance: ${ride.distance}km', style: robotoRegular.copyWith(color: Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
                          ],
                        ),
                        Text(PriceConverter.convertPrice(ride.estimatedFare), style: robotoBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 100, color: Theme.of(context).primaryColor.withOpacity(0.2)),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Text('Sign in required', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge)),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              'Please sign in to view your ride history and track your bookings.',
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(color: Theme.of(context).disabledColor),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraLarge),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.main)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text('Sign In', style: robotoBold.copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.blue;
      case 'accepted': return Colors.orange;
      case 'ongoing': return Colors.deepPurple;
      case 'completed': return Colors.green;
      case 'canceled': return Colors.red;
      case 'scheduled': return Colors.cyan;
      default: return Colors.grey;
    }
  }
}
