import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/cab_booking/home/controllers/cab_controller.dart';
import 'package:sixam_mart/features/cab_booking/home/screens/cab_ride_details_screen.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';

class RunningCabRideWidget extends StatelessWidget {
  const RunningCabRideWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CabController>(builder: (cabController) {
      if (cabController.rideList == null || cabController.rideList!.isEmpty) {
        return const SizedBox();
      }

      // Find the most recent active ride
      final activeRide = cabController.rideList!.firstWhereOrNull(
        (ride) => ['pending', 'accepted', 'ongoing', 'scheduled'].contains(ride.status)
      );

      if (activeRide == null) {
        return const SizedBox();
      }

      return InkWell(
        onTap: () => Get.to(() => CabRideDetailsScreen(rideId: activeRide.id!)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 5)],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.directions_car, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Active Cab Ride', style: robotoBold),
                    Text(
                      activeRide.status == 'pending' ? 'Searching for driver...' : 
                      activeRide.status == 'scheduled' ? 'Booking Scheduled' :
                      activeRide.status == 'accepted' ? 'Driver is arriving' : 'Trip in progress',
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).primaryColor),
            ],
          ),
        ),
      );
    });
  }
}
