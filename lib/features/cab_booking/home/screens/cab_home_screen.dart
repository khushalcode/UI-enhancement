import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/features/coupon/controllers/coupon_controller.dart';
import 'package:sixam_mart/features/cab_booking/home/controllers/cab_controller.dart';
import 'package:sixam_mart/features/cab_booking/domain/models/vehicle_type_model.dart';
import 'package:sixam_mart/features/location/screens/pick_map_screen.dart';
import 'package:sixam_mart/features/cab_booking/home/screens/cab_ride_details_screen.dart';
import 'package:sixam_mart/features/cab_booking/home/screens/cab_history_screen.dart';
import 'package:sixam_mart/features/cab_booking/home/screens/cab_location_picker_screen.dart';
import 'package:sixam_mart/features/cab_booking/home/widgets/running_cab_ride_widget.dart';
import 'package:sixam_mart/features/notification/controllers/notification_controller.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/features/profile/controllers/profile_controller.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/notification/controllers/notification_controller.dart';

class CabHomeScreen extends StatefulWidget {
  const CabHomeScreen({super.key});

  @override
  State<CabHomeScreen> createState() => _CabHomeScreenState();
}

class _CabHomeScreenState extends State<CabHomeScreen> {
  GoogleMapController? _mapController;
  final LatLng _initialPosition = const LatLng(19.0760, 72.8777); 
  final TextEditingController _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Get.find<CabController>().getVehicleTypes();
    Get.find<CouponController>().getTaxiCouponList();
    if(AuthHelper.isLoggedIn()) {
      Get.find<NotificationController>().getNotificationList(true);
      Get.find<CabController>().getMyRides();
      
      // Set default source address from saved user address
      var userAddress = AddressHelper.getUserAddressFromSharedPref();
      if(userAddress != null && userAddress.address != null) {
        LatLng latLng = LatLng(double.parse(userAddress.latitude!), double.parse(userAddress.longitude!));
        Get.find<CabController>().setSource(latLng, userAddress.address!, null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CabController>(builder: (cabController) {
      return WillPopScope(
        onWillPop: () async {
          if (cabController.showSelectionMode) {
            cabController.toggleSelectionMode(false);
            return false;
          }
          return true;
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).cardColor,
          bottomNavigationBar: cabController.showSelectionMode ? null : Container(
            height: 70,
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFC3202), Color(0xFF0037C5)],
                begin: Alignment.centerLeft, end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(35),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 25, offset: const Offset(0, 5))],
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _buildBottomNavItem(Icons.home_filled, 'Home', true, () {}),
              _buildBottomNavItem(Icons.notifications_active_outlined, 'Notifications', false, () => Get.toNamed(RouteHelper.getNotificationRoute())),
              _buildBottomNavItem(Icons.directions_car_filled_outlined, 'My Rides', false, () => Get.to(() => const CabHistoryScreen())),
              _buildBottomNavItem(Icons.account_balance_wallet_outlined, 'Wallet', false, () => Get.toNamed(RouteHelper.getWalletRoute())),
            ]),
          ),
          body: Stack(children: [
            
            /// Permanent Map Background (avoids SurfaceView errors)
            GoogleMap(
              initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 15),
              onMapCreated: (controller) => _mapController = controller,
              zoomControlsEnabled: false,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              polylines: Set<Polyline>.of(cabController.polyLines.values),
              markers: cabController.markers,
            ),

            /// Initial View (Home) - Overlayed on map
            if (!cabController.showSelectionMode) Container(
              color: Theme.of(context).cardColor,
              child: _buildInitialView(cabController),
            ),

            /// Selection Mode UI
            if (cabController.showSelectionMode) _buildSelectionOverlays(cabController),
            if (cabController.showSelectionMode) Positioned.fill(child: _buildSelectionBottomSheet(cabController)),
            
            if (cabController.showSelectionMode) Positioned(
              top: MediaQuery.of(context).padding.top + 10, left: 15,
              child: InkWell(
                onTap: () => cabController.toggleSelectionMode(false),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
                  child: const Icon(Icons.arrow_back, color: Colors.black),
                ),
              ),
            ),
          ]),
        ),
      );
    });
  }

  Widget _buildInitialView(CabController cabController) {
    return Column(children: [
      /// Professional Header (Back to Module)
      _buildHeader(context),

      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            /// Active Ride Info
            if (cabController.activeRide != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.blue[700]!, Colors.blue[400]!]),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.directions_car, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 15),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Active Ride Found', style: robotoBold.copyWith(color: Colors.white, fontSize: 16)),
                    Text('Ride ID: #${cabController.activeRide!.id}', style: robotoRegular.copyWith(color: Colors.white70, fontSize: 12)),
                  ])),
                  ElevatedButton(
                    onPressed: () => Get.to(() => CabRideDetailsScreen(rideId: cabController.activeRide!.id!)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, foregroundColor: Colors.blue[700],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                    ),
                    child: const Text('View', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ]),
              ),
              const SizedBox(height: 15),
            ],

            /// Header Search Bar
            const SizedBox(height: 10),
            InkWell(
              onTap: () => Get.to(() => CabLocationPickerScreen(isPickup: false)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 2, offset: const Offset(0, 1)),
                  ],
                  border: Border.all(color: Colors.grey[100]!),
                ),
                child: Row(children: [
                  Icon(Icons.search_rounded, color: Theme.of(context).primaryColor, size: 24),
                  const SizedBox(width: 15),
                  Text('Where are you going?', style: robotoMedium.copyWith(fontSize: 16, color: Colors.black54)),
                  const Spacer(),
                  InkWell(
                    onTap: () => _selectScheduleTime(context, cabController),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: cabController.scheduleAt != null ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.grey[50],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cabController.scheduleAt != null ? Theme.of(context).primaryColor : Colors.transparent, width: 0.5),
                      ),
                      child: Row(children: [
                        Icon(
                          Icons.calendar_month_rounded, 
                          size: 16, 
                          color: cabController.scheduleAt != null ? Theme.of(context).primaryColor : Colors.black54
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cabController.scheduleAt != null 
                            ? '${cabController.scheduleAt!.day} ${_getMonthName(cabController.scheduleAt!.month)} ${cabController.scheduleAt!.hour.toString().padLeft(2, '0')}:${cabController.scheduleAt!.minute.toString().padLeft(2, '0')}' 
                            : 'Later', 
                          style: robotoBold.copyWith(
                            fontSize: 13, 
                            color: cabController.scheduleAt != null ? Theme.of(context).primaryColor : Colors.black54
                          )
                        ),
                      ]),
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 30),

            /// Recent Locations
            if (cabController.rideList != null && cabController.rideList!.isNotEmpty) ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cabController.rideList!.length > 2 ? 2 : cabController.rideList!.length,
                separatorBuilder: (context, index) => const Divider(height: 30, color: Colors.grey, thickness: 0.1, indent: 40),
                itemBuilder: (context, index) {
                  final ride = cabController.rideList![index];
                  String locationName = ride.dropLocation ?? 'Recent Location';
                  
                  return InkWell(
                    onTap: () {
                      if (ride.dropLocation != null && ride.dropLat != null && ride.dropLng != null) {
                        cabController.setSource(
                          LatLng(ride.dropLat!, ride.dropLng!),
                          ride.dropLocation!,
                          _mapController,
                        );
                        showCustomSnackBar('pickup_location_set_from_history'.tr, isError: false);
                        Get.to(() => CabLocationPickerScreen(isPickup: false));
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
                          child: Icon(Icons.history_rounded, color: Colors.black54, size: 20),
                        ),
                        const SizedBox(width: 15),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(locationName.split(',').first, style: robotoBold.copyWith(fontSize: 15, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(locationName, style: robotoRegular.copyWith(fontSize: 13, color: Colors.black38), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ])),
                        Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[300]),
                      ]),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
            ],

            /// Promo Section
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Everything in minutes', style: robotoBold.copyWith(fontSize: 18, letterSpacing: -0.5)),
              InkWell(
                onTap: () => Get.to(() => const CabLocationPickerScreen(isPickup: false)),
                child: Text('Enter Address', style: robotoMedium.copyWith(fontSize: 14, color: Theme.of(context).primaryColor)),
              ),
            ]),
            const SizedBox(height: 15),
            
            SizedBox(
              height: 220,
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                /// Large Featured Card
                Expanded(flex: 1, child: _buildServiceCard(
                  title: 'Affordable',
                  subtitle: 'Budget rides',
                  image: Images.affordable,
                  color: const Color(0xFFE3F2FD),
                  isFull: true,
                  tag: 'NEW',
                )),
                const SizedBox(width: 15),
                
                /// Two Small Cards Column
                Expanded(flex: 1, child: Column(children: [
                  Expanded(child: _buildServiceCard(
                    title: 'Secure',
                    subtitle: 'Safety first',
                    image: Images.secure,
                    color: const Color(0xFFE8F5E9),
                  )),
                  const SizedBox(height: 15),
                  Expanded(child: _buildServiceCard(
                    title: 'Fast',
                    subtitle: 'On-time',
                    image: Images.fast,
                    color: const Color(0xFFFFF3E0),
                  )),
                ])),
              ]),
            ),

            const SizedBox(height: 20),
            const RunningCabRideWidget(),

            const SizedBox(height: 100),
          ]),
        ),
      ),
    ]);
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 15, right: 15, bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => Get.find<SplashController>().setModule(null),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
              child: Icon(Icons.grid_view_rounded, color: Theme.of(context).primaryColor, size: 22),
            ),
          ),
          Text('Cab Booking', style: robotoBold.copyWith(fontSize: 18)),
          InkWell(
            onTap: () => Get.toNamed(RouteHelper.getProfileRoute()),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
              child: ClipOval(
                child: GetBuilder<ProfileController>(builder: (profileController) {
                  return (profileController.userInfoModel?.imageFullUrl != null && profileController.userInfoModel!.imageFullUrl!.isNotEmpty) 
                    ? CustomImage(image: profileController.userInfoModel!.imageFullUrl!, height: 36, width: 36, fit: BoxFit.cover)
                    : Container(height: 36, width: 36, color: Colors.grey[200], child: Icon(Icons.person, color: Theme.of(context).primaryColor, size: 24));
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionOverlays(CabController cabController) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10, left: 15, right: 15,
      child: Column(children: [
        /// Pickup Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Row(children: [
            const Icon(Icons.circle, color: Colors.green, size: 12),
            const SizedBox(width: 15),
            Expanded(child: Text(cabController.sourceAddress ?? 'Pickup location', style: robotoRegular.copyWith(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis)),
            InkWell(
              onTap: () => Get.to(() => CabLocationPickerScreen(isPickup: true)),
              child: const Icon(Icons.edit_outlined, size: 20, color: Colors.black54),
            ),
          ]),
        ),
        const SizedBox(height: 10),
        /// Drop Card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Row(children: [
            const Icon(Icons.circle, color: Colors.orange, size: 12),
            const SizedBox(width: 15),
            Expanded(child: Text(cabController.destinationAddress ?? 'Drop location', style: robotoBold.copyWith(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis)),
            InkWell(
              onTap: () => Get.to(() => CabLocationPickerScreen(isPickup: false)),
              child: const Icon(Icons.edit_outlined, size: 20, color: Colors.black54),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildSelectionBottomSheet(CabController cabController) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 15)],
          ),
          child: Stack(children: [
            /// Scrollable Content
            Column(children: [
              const SizedBox(height: 10),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 15),
              
              /// Promo Banner
              GetBuilder<CouponController>(builder: (couponController) {
                String promoText = 'You get ₹20 off & 20 coins cashback!'; // Default
                if (couponController.taxiCouponList != null && couponController.taxiCouponList!.isNotEmpty) {
                  var coupon = couponController.taxiCouponList![0];
                  promoText = 'Apply Coupon ${coupon.code} and get ${coupon.discount}${coupon.discountType == 'percent' ? '%' : '₹'} off';
                }
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                  decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(10)),
                  child: Row(children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 10),
                    Expanded(child: Text(promoText, style: robotoMedium.copyWith(color: Colors.green[700], fontSize: 13))),
                  ]),
                );
              }),
              
              /// Vehicle List
              Expanded(
                child: cabController.vehicleTypes != null ? ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 180),
                  itemCount: cabController.vehicleTypes!.length,
                  itemBuilder: (context, index) {
                    final type = cabController.vehicleTypes![index];
                    bool isSelected = cabController.selectedVehicleIndex == index;
                    return GestureDetector(
                      onTap: () => cabController.selectVehicle(index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: isSelected ? Colors.blue[700]! : Colors.grey[100]!, width: isSelected ? 2 : 1),
                        ),
                        child: Row(children: [
                          CustomImage(
                            image: '${AppConstants.baseUrl}/storage/app/public/cab/type/${type.image}',
                            height: 50, width: 70,
                          ),
                          const SizedBox(width: 15),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Flexible(child: Text(type.typeName ?? '', style: robotoBold.copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
                              const SizedBox(width: 5),
                              const Icon(Icons.person, size: 14, color: Colors.black54),
                              Text(' ${type.capacity ?? 1}', style: robotoRegular.copyWith(fontSize: 12, color: Colors.black54)),
                              if(index == 0) ...[
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.cyan[50], borderRadius: BorderRadius.circular(5)),
                                  child: Text('FASTEST', style: robotoBold.copyWith(color: Colors.cyan[700], fontSize: 10)),
                                ),
                              ],
                            ]),
                            Text('Quick ${type.typeName} rides', style: robotoRegular.copyWith(fontSize: 12, color: Colors.grey)),
                            Text('4 mins away • Drop in ${cabController.duration?.toStringAsFixed(0) ?? 10} mins', style: robotoRegular.copyWith(fontSize: 12, color: Colors.blueGrey)),
                          ])),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Builder(builder: (context) {
                              double distance = cabController.distance ?? 0;
                              double duration = cabController.duration ?? 0;
                              double fare = (type.baseFare ?? 0) + (distance * (type.perKmCharge ?? 0)) + (duration * (type.perMinuteCharge ?? 0));
                              if (fare < (type.minFare ?? 0)) fare = type.minFare ?? 0;
                              
                              return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                Row(children: [
                                  Text(PriceConverter.convertPrice(fare), style: robotoBold.copyWith(fontSize: 18)),
                                  const SizedBox(width: 5),
                                  InkWell(
                                    onTap: () => _showPriceBreakdown(cabController, type),
                                    child: Icon(Icons.info_outline, size: 16, color: Theme.of(context).primaryColor),
                                  ),
                                ]),
                                Text(PriceConverter.convertPrice(fare * 1.5), style: robotoRegular.copyWith(fontSize: 12, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                              ]);
                            }),
                          ]),
                        ]),
                      ),
                    );
                  },
                ) : const Center(child: CircularProgressIndicator()),
              ),
            ]),

            /// Fixed Bottom Controls (Payment & Action)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                color: Colors.white,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  /// Bottom Row (Payment & Coupon)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[200]!),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(children: [
                      /// Payment Selector
                      Expanded(child: InkWell(
                        onTap: () => _showPaymentBottomSheet(cabController),
                        child: Row(children: [
                          Icon(cabController.paymentMethod == 'wallet' ? Icons.account_balance_wallet_outlined : Icons.payments_outlined, color: Colors.black, size: 22),
                          const SizedBox(width: 8),
                          Text(cabController.paymentMethod.capitalizeFirst!, style: robotoBold.copyWith(fontSize: 14)),
                          const Icon(Icons.keyboard_arrow_right, size: 20),
                        ]),
                      )),
                      
                      Container(width: 1, height: 30, color: Colors.grey[300]),
                      
                      /// Coupon Selector
                      Expanded(child: InkWell(
                        onTap: () => Get.toNamed(RouteHelper.getCouponRoute()),
                        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          const Icon(Icons.percent, color: Colors.black54, size: 20),
                          const SizedBox(width: 5),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(cabController.couponCode ?? 'DISCOUNT', style: robotoBold.copyWith(fontSize: 14)),
                            Text('Coupon applied', style: robotoRegular.copyWith(fontSize: 10, color: Colors.grey)),
                          ])),
                          const Icon(Icons.keyboard_arrow_right, size: 20),
                        ]),
                      )),
                    ]),
                  ),

                  /// Action Button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: SizedBox(
                      width: double.infinity, height: 55,
                      child: ElevatedButton(
                        onPressed: cabController.isLoading ? null : () async {
                          int? rideId = await cabController.placeRideRequest();
                          if (rideId != null) Get.to(() => CabRideDetailsScreen(rideId: rideId));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF24AE5F),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          elevation: 0,
                        ),
                        child: Text('Book ${cabController.vehicleTypes != null ? cabController.vehicleTypes![cabController.selectedVehicleIndex].typeName : "Ride"}', 
                          style: robotoBold.copyWith(color: Colors.black, fontSize: 18)),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ]),
        );
      },
    );
  }

  void _showPaymentBottomSheet(CabController cabController) {
    SplashController splashController = Get.find<SplashController>();
    ProfileController profileController = Get.find<ProfileController>();
    bool cashEnabled = splashController.configModel!.cashOnDelivery!;
    bool digitalEnabled = splashController.configModel!.digitalPayment!;
    bool walletEnabled = splashController.configModel!.customerWalletStatus == 1;
    double walletBalance = profileController.userInfoModel?.walletBalance ?? 0.0;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Select Payment Method', style: robotoBold.copyWith(fontSize: 18)),
          const SizedBox(height: 20),
          
          if(cashEnabled) _buildPaymentOption(Icons.payments_outlined, 'Cash', cabController.paymentMethod == 'cash', () {
            cabController.setPaymentMethod('cash');
            Get.back();
          }),
          
          if(walletEnabled && walletBalance > 0) _buildPaymentOption(Icons.account_balance_wallet_outlined, 'Wallet (${PriceConverter.convertPrice(walletBalance)})', cabController.paymentMethod == 'wallet', () {
            cabController.setPaymentMethod('wallet');
            Get.back();
          }),
          
          if(digitalEnabled) _buildPaymentOption(Icons.language, 'Online', cabController.paymentMethod == 'online', () {
            cabController.setPaymentMethod('online');
            Get.back();
          }),
          
          if(!cashEnabled && !digitalEnabled && (!walletEnabled || walletBalance <= 0))
            Text('No payment method available', style: robotoRegular.copyWith(color: Colors.red)),

          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _buildPaymentOption(IconData icon, String title, bool isSelected, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isSelected ? Colors.blue : Colors.black),
      title: Text(title, style: robotoMedium.copyWith(color: isSelected ? Colors.blue : Colors.black)),
      trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.blue) : null,
    );
  }

  Widget _buildServiceCard({
    required String title, 
    required String subtitle, 
    required String image, 
    required Color color, 
    bool isFull = false,
    String? tag,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        /// Background Image
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.only(top: isFull ? 40 : 20, left: isFull ? 10 : 20),
            child: Image.asset(image, fit: isFull ? BoxFit.contain : BoxFit.cover, alignment: isFull ? Alignment.bottomRight : Alignment.center),
          ),
        ),

        /// Text Overlay with Gradient for Legibility
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.8),
                Colors.white.withOpacity(0.1),
                Colors.transparent,
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (tag != null) Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: const Color(0xFFFFCC33), borderRadius: BorderRadius.circular(8)),
              child: Text(tag, style: robotoBold.copyWith(fontSize: 10, color: Colors.black)),
            ),
            Text(title, style: robotoBold.copyWith(fontSize: isFull ? 22 : 18, color: Colors.black, height: 1.1)),
            const SizedBox(height: 4),
            Text(subtitle, style: robotoRegular.copyWith(fontSize: 12, color: Colors.black54)),
          ]),
        ),
        
        /// Subtle Shine Effect
        Positioned(
          top: -50, right: -50,
          child: Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildMiniCard({required String title, required String image, required Color color}) {
    return Container(
      height: 90,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        Center(child: Opacity(opacity: 0.1, child: Image.asset(image, fit: BoxFit.contain, height: 60))),
        Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset(image, height: 35),
            const SizedBox(height: 8),
            Text(title, style: robotoBold.copyWith(fontSize: 13)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: isSelected ? Colors.white : Colors.white70, size: 24),
        const SizedBox(height: 4),
        Text(label, style: robotoRegular.copyWith(color: isSelected ? Colors.white : Colors.white70, fontSize: 10)),
      ]),
    );
  }

  void _selectScheduleTime(BuildContext context, CabController cabController) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        DateTime finalDateTime = DateTime(
          pickedDate.year, pickedDate.month, pickedDate.day,
          pickedTime.hour, pickedTime.minute,
        );
        if (finalDateTime.isBefore(DateTime.now())) {
          showCustomSnackBar('cannot_select_past_time'.tr);
        } else {
          cabController.setScheduleAt(finalDateTime);
        }
      }
    }
  }

  void _showPriceBreakdown(CabController cabController, VehicleTypeModel type) {
    double distance = cabController.distance ?? 0;
    double duration = cabController.duration ?? 0;
    double baseFare = type.baseFare ?? 0;
    double distanceFare = distance * (type.perKmCharge ?? 0);
    double durationFare = duration * (type.perMinuteCharge ?? 0);
    double subTotal = baseFare + distanceFare + durationFare;
    if (subTotal < (type.minFare ?? 0)) subTotal = type.minFare ?? 0;

    double taxPercentage = cabController.taxPercentage;
    double discount = cabController.discount;
    double taxAmount = cabController.taxAmount;
    double totalFare = cabController.estimatedFare ?? (subTotal - discount + taxAmount);

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('price_breakdown'.tr, style: robotoBold.copyWith(fontSize: 18)),
            const SizedBox(height: 20),
            _buildBreakdownRow('base_fare'.tr, baseFare),
            _buildBreakdownRow('${'distance_fare'.tr} (${distance.toStringAsFixed(2)} km)', distanceFare),
            if(durationFare > 0) _buildBreakdownRow('${'time_fare'.tr} (${duration.toStringAsFixed(0)} mins)', durationFare),
            const Divider(),
            _buildBreakdownRow('Sub Total'.tr, subTotal),
            if(discount > 0) _buildBreakdownRow(
              'Discount'.tr + (cabController.discountType == 'percent' ? ' (${cabController.rawDiscount.toStringAsFixed(0)}%)' : ''), 
              -discount, color: Colors.green,
            ),
            _buildBreakdownRow('Tax'.tr + ' ($taxPercentage%)', taxAmount),
            const Divider(thickness: 2),
            _buildBreakdownRow('total_fare'.tr, totalFare, isBold: true),
            const SizedBox(height: 20),
            TextButton(onPressed: () => Get.back(), child: Text('Close'.tr, style: robotoBold)),
          ]),
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, double amount, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: isBold ? robotoBold : robotoRegular),
        Text(PriceConverter.convertPrice(amount), style: (isBold ? robotoBold : robotoRegular).copyWith(color: color)),
      ]),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
