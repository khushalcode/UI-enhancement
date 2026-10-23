import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/features/cab_booking/home/controllers/cab_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/features/chat/domain/models/conversation_model.dart' as chat;
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/features/cab_booking/home/screens/cab_home_screen.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/features/cab_booking/domain/models/ride_model.dart';

class CabRideDetailsScreen extends StatefulWidget {
  final int rideId;
  const CabRideDetailsScreen({super.key, required this.rideId});

  @override
  State<CabRideDetailsScreen> createState() => _CabRideDetailsScreenState();
}

class _CabRideDetailsScreenState extends State<CabRideDetailsScreen> {
  GoogleMapController? _mapController;
  bool _reviewDialogShown = false;

  @override
  void initState() {
    super.initState();
    Get.find<CabController>().getRideDetails(widget.rideId);
    Get.find<CabController>().startPolling(widget.rideId);
  }

  @override
  void dispose() {
    Get.find<CabController>().stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CabController>(builder: (cabController) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          Get.offAllNamed(RouteHelper.getInitialRoute());
        },
        child: Scaffold(
          appBar: CustomAppBar(
            title: 'Ride Details',
            onBackPressed: () => Get.offAllNamed(RouteHelper.getInitialRoute()),
          ),
          floatingActionButton: (cabController.rideDetails?.status != 'completed' && cabController.rideDetails?.status != 'canceled') ? FloatingActionButton(
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: Row(children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.red),
                    const SizedBox(width: 10),
                    const Text('Emergency SOS'),
                  ]),
                  content: const Text('Are you in an emergency? This will notify our safety team and provide your location.'),
                  actions: [
                    TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        cabController.sendSos(cabController.rideDetails!.id!, cabController.rideDetails!.pickupLat!, cabController.rideDetails!.pickupLng!);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('SEND SOS', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                )
              );
            },
            backgroundColor: Colors.red,
            child: const Icon(Icons.sos, color: Colors.white, size: 30),
          ) : null,
          body: GetBuilder<CabController>(builder: (cabController) {
            if (cabController.rideDetails == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final ride = cabController.rideDetails!;

            return Stack(
              children: [
                // Map
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(ride.pickupLat ?? 0, ride.pickupLng ?? 0),
                    zoom: 14,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                    _fitMarkers(cabController.rideDetails);
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  markers: _getMarkers(ride, cabController),
                  polylines: Set<Polyline>.of(cabController.polyLines.values),
                ),

                // Ride Details Sheet
                DraggableScrollableSheet(
                  initialChildSize: 0.45,
                  minChildSize: 0.35,
                  maxChildSize: 0.7,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 5)],
                      ),
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        children: [
                          Center(
                            child: Container(
                              width: 50, height: 5,
                              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(5)),
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ride.status?.toUpperCase() ?? 'PENDING', style: robotoBold.copyWith(
                                    color: (ride.status == 'pending' || ride.status == 'scheduled' || ride.status == 'accepted') ? Colors.orange : (ride.status == 'canceled' || ride.status == 'rejected' ? Colors.red : Colors.green),
                                    fontSize: Dimensions.fontSizeLarge,
                                  )),
                                  Text('Ride ID: #${ride.id}', style: robotoRegular.copyWith(color: Theme.of(context).disabledColor)),
                                  if (ride.status == 'canceled' && ride.cancelReason != null && ride.cancelReason!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Text('Reason: ${ride.cancelReason}', style: robotoRegular.copyWith(color: Colors.red, fontSize: Dimensions.fontSizeSmall)),
                                    ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                                ),
                                child: Column(
                                  children: [
                                    Text('OTP', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                    Text(ride.otp ?? '----', style: robotoBold.copyWith(fontSize: 22, color: Theme.of(context).primaryColor)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 30),

                          // Addresses
                          Row(children: [
                            const Icon(Icons.circle, color: Colors.green, size: 12),
                            const SizedBox(width: 10),
                            Expanded(child: Text(ride.pickupLocation ?? '', style: robotoRegular, maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ]),
                          const Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: SizedBox(height: 20, child: VerticalDivider(width: 2, thickness: 1)),
                          ),
                          Row(children: [
                            const Icon(Icons.location_on, color: Colors.red, size: 16),
                            const SizedBox(width: 10),
                            Expanded(child: Text(ride.dropLocation ?? '', style: robotoRegular, maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ]),
                          const SizedBox(height: Dimensions.paddingSizeLarge),

                          // Driver Details
                          if (ride.rider != null) ...[
                            Container(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(ride.rider?.image ?? '', width: 50, height: 50, errorBuilder: (c, e, s) => Image.asset(Images.placeholder, width: 50, height: 50)),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${ride.rider?.fName} ${ride.rider?.lName}', style: robotoBold),
                                        Row(children: [
                                          Icon(Icons.star, color: Colors.amber, size: 14),
                                          const SizedBox(width: 5),
                                          Text(ride.rider?.avgRating?.toStringAsFixed(1) ?? '0.0', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                                          const SizedBox(width: 5),
                                          Text('(${ride.rider?.ratingCount ?? 0})', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                                        ]),
                                        Text((ride.vehicle?.licensePlate != null && ride.vehicle?.licensePlate != 'Pending') ? ride.vehicle!.licensePlate! : 'Vehicle info pending', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                                      ],
                                    ),
                                  ),
                                  if (ride.status != 'completed' && ride.status != 'canceled') ...[
                                    IconButton(
                                      icon: const Icon(Icons.call, color: Colors.green),
                                      onPressed: () async {
                                        String url = 'tel:${ride.rider?.phone}';
                                        if (await canLaunchUrlString(url)) {
                                          await launchUrlString(url);
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.message, color: Theme.of(context).primaryColor),
                                      onPressed: () {
                                        Get.toNamed(RouteHelper.getChatRoute(
                                          notificationBody: NotificationBodyModel(
                                            deliverymanId: ride.rider?.id,
                                            type: 'delivery_man',
                                            notificationType: NotificationType.message,
                                          ),
                                          user: chat.User(
                                            id: ride.rider?.id,
                                            fName: ride.rider?.fName,
                                            lName: ride.rider?.lName,
                                            imageFullUrl: ride.rider?.imageFullUrl,
                                          ),
                                        ));
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ] else ...[
                             Center(
                               child: Column(children: [
                                 const CircularProgressIndicator(),
                                 const SizedBox(height: 10),
                                 Text('Searching for Driver', style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
                               ]),
                             ),
                          ],
                          
                          if (ride.status == 'pending' || ride.status == 'scheduled' || ride.status == 'accepted') ...[
                            const SizedBox(height: Dimensions.paddingSizeDefault),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: cabController.isLoading ? null : () {
                                  TextEditingController reasonController = TextEditingController();
                                  Get.dialog(
                                    AlertDialog(
                                      title: const Text('Cancel Ride'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('Are you sure you want to cancel this ride request?'),
                                          const SizedBox(height: Dimensions.paddingSizeLarge),
                                          TextField(
                                            controller: reasonController,
                                            decoration: InputDecoration(
                                              hintText: 'Enter cancellation reason (optional)',
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                            maxLines: 3,
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(onPressed: () => Get.back(), child: const Text('No')),
                                        TextButton(onPressed: () {
                                          Get.back();
                                          cabController.cancelRide(ride.id!, reason: reasonController.text.trim());
                                        }, child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red))),
                                      ],
                                    )
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: cabController.isLoading 
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                                  : Text('Cancel Ride', style: robotoBold),
                              ),
                            ),
                          ],

                          const SizedBox(height: Dimensions.paddingSizeLarge),
                          
                          // Fare Breakdown
                          Container(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(10)),
                            child: Column(children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text('Subtotal'.tr, style: robotoRegular),
                                Text(PriceConverter.convertPrice((ride.estimatedFare ?? 0) - (ride.taxAmount ?? 0) + (ride.couponDiscountAmount ?? 0)), style: robotoRegular),
                              ]),
                              if((ride.couponDiscountAmount ?? 0) > 0) ...[
                                const SizedBox(height: 5),
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text('${'Discount'.tr} (${ride.couponCode})', style: robotoRegular.copyWith(color: Colors.green)),
                                  Text('-${PriceConverter.convertPrice(ride.couponDiscountAmount ?? 0)}', style: robotoRegular.copyWith(color: Colors.green)),
                                ]),
                              ],
                              const SizedBox(height: 5),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text('${'Tax'.tr} (${ride.taxPercentage ?? 0}%)', style: robotoRegular),
                                Text(PriceConverter.convertPrice(ride.taxAmount ?? 0), style: robotoRegular),
                              ]),
                              const Divider(),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text('Total Fare'.tr, style: robotoBold),
                                Text(PriceConverter.convertPrice(ride.estimatedFare), style: robotoBold.copyWith(fontSize: 20, color: Theme.of(context).primaryColor)),
                              ]),
                            ]),
                          ),


                          if (ride.status == 'completed' && ride.paymentStatus != 'paid') ...[
                            const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                            Text('Select Payment Method', style: robotoBold),
                            const SizedBox(height: 10),
                            Row(children: [
                              Expanded(child: _paymentMethodCard(context, 'cash', 'Cash', Icons.money_rounded, ride.paymentMethod == 'cash', () {
                                cabController.updatePaymentMethod(ride.id!, 'cash');
                              })),
                              const SizedBox(width: 10),
                              Expanded(child: _paymentMethodCard(context, 'digital_payment', 'Online', Icons.payment_rounded, ride.paymentMethod == 'digital_payment', () {
                                cabController.updatePaymentMethod(ride.id!, 'digital_payment');
                              })),
                              const SizedBox(width: 10),
                              Expanded(child: _paymentMethodCard(context, 'wallet', 'Wallet', Icons.account_balance_wallet_rounded, ride.paymentMethod == 'wallet', () {
                                cabController.updatePaymentMethod(ride.id!, 'wallet');
                              })),
                            ]),
                            const SizedBox(height: 20),
                            
                            if (ride.paymentMethod != 'cash')
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (ride.paymentMethod == 'wallet') {
                                      cabController.payWithWallet(ride.id!);
                                    } else if (ride.paymentMethod == 'digital_payment') {
                                      cabController.payDigital(ride);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: Text('Pay Now (${PriceConverter.convertPrice(ride.actualFare ?? ride.estimatedFare)})', style: robotoBold.copyWith(color: Colors.white)),
                                ),
                              ),

                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.blue.withOpacity(0.2))),
                              child: Row(children: [
                                const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                                const SizedBox(width: 10),
                                Expanded(child: Text(
                                  ride.paymentMethod == 'cash' 
                                    ? 'Please pay cash to the rider and wait for confirmation.'
                                    : 'Please complete your payment to finish the booking.', 
                                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.blue),
                                )),
                              ]),
                            ),
                          ],

                          if (ride.status == 'completed' && ride.paymentStatus == 'paid') ...[
                            Builder(builder: (context) {
                              bool isReviewed = ride.isReviewed ?? false;
                              
                              if(!isReviewed && !_reviewDialogShown) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if(mounted && !_reviewDialogShown) {
                                    _reviewDialogShown = true;
                                    _showReviewDialog(context, ride);
                                  }
                                });
                              }

                              return Column(children: [
                                const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _showReviewDialog(context, ride),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: Text(isReviewed ? 'Edit Your Review' : 'Rate Your Ride', style: robotoBold.copyWith(color: Colors.white)),
                                  ),
                                ),
                              ]);
                            }),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          }),
        ),
      );
    });
  }

  Set<Marker> _getMarkers(CabRideModel ride, CabController cabController) {
    Set<Marker> markers = {};
    
    markers.add(Marker(
      markerId: const MarkerId('pickup'),
      position: LatLng(ride.pickupLat ?? 0, ride.pickupLng ?? 0),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    ));

    markers.add(Marker(
      markerId: const MarkerId('destination'),
      position: LatLng(ride.dropLat ?? 0, ride.dropLng ?? 0),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));

    if (ride.vehicle?.lastLat != null) {
      LatLng riderLoc = LatLng(ride.vehicle!.lastLat!, ride.vehicle!.lastLng!);
      markers.add(Marker(
        markerId: const MarkerId('rider'),
        position: riderLoc,
        icon: cabController.riderMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        rotation: 0,
      ));
      
      // Animate camera to rider if ride is active
      if(ride.status != 'completed' && ride.status != 'canceled') {
         _mapController?.animateCamera(CameraUpdate.newLatLng(riderLoc));
      }
    }
    
    return markers;
  }

  void _fitMarkers(CabRideModel? ride) {
    if (ride == null || _mapController == null) return;
    
    List<LatLng> points = [
      LatLng(ride.pickupLat ?? 0, ride.pickupLng ?? 0),
      LatLng(ride.dropLat ?? 0, ride.dropLng ?? 0),
    ];
    
    if (ride.vehicle?.lastLat != null) {
      points.add(LatLng(ride.vehicle!.lastLat!, ride.vehicle!.lastLng!));
    }

    LatLngBounds bounds = _boundsFromLatLngList(points);
    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > (x1 ?? 0)) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > (y1 ?? 0)) y1 = latLng.longitude;
        if (latLng.longitude < (y0 ?? 0)) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
  }

  Widget _paymentMethodCard(BuildContext context, String id, String title, IconData icon, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.2)),
        ),
        child: Column(children: [
          Icon(icon, color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor),
          const SizedBox(height: 5),
          Text(title, style: robotoMedium.copyWith(color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor, fontSize: Dimensions.fontSizeSmall)),
        ]),
      ),
    );
  }

  void _showReviewDialog(BuildContext context, CabRideModel ride) {
    int selectedRating = ride.review?.rating ?? 5;
    final TextEditingController commentController = TextEditingController(text: ride.review?.comment ?? '');

    Get.dialog(
      StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(ride.isReviewed == true ? 'Edit Your Review' : 'Rate Your Trip'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 30,
                    ),
                    onPressed: () => setState(() => selectedRating = index + 1),
                  );
                }),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write your feedback (optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Later')),
            ElevatedButton(
              onPressed: () {
                Get.find<CabController>().submitReview(ride.id!, selectedRating, commentController.text);
                Get.back();
              },
              child: Text(ride.isReviewed == true ? 'Update' : 'Submit'),
            ),
          ],
        );
      }),
    );
  }
}
