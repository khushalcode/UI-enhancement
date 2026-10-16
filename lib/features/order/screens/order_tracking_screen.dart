import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:sixam_mart/common/controllers/theme_controller.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/location/widgets/permission_dialog_widget.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';
import 'package:sixam_mart/features/chat/domain/models/conversation_model.dart';
import 'package:sixam_mart/features/order/controllers/order_controller.dart';
import 'package:sixam_mart/features/order/domain/models/order_model.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/helper/marker_helper.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/menu_drawer.dart';
import 'package:sixam_mart/features/order/widgets/track_details_view_widget.dart';
import 'package:sixam_mart/features/order/widgets/tracking_stepper_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String? orderID;
  final String? contactNumber;
  const OrderTrackingScreen({super.key, required this.orderID, this.contactNumber});

  @override
  OrderTrackingScreenState createState() => OrderTrackingScreenState();
}

class OrderTrackingScreenState extends State<OrderTrackingScreen> with TickerProviderStateMixin {
  static const _kGoogleApiKey = 'AIzaSyBIEsqW044TREjZAr4Rgqr4zZ31qSR2LJQ';

  GoogleMapController? _controller;
  bool _isLoading = true;
  Set<Marker> _markers = HashSet<Marker>();
  Set<Polyline> _polylines = HashSet<Polyline>();
  Timer? _timer;
  bool showChatPermission = true;
  bool isHovered = false;

  // Driver animation
  LatLng? _driverPrev;
  LatLng? _driverCurr;
  double _driverBearing = 0;
  AnimationController? _moveController;
  Animation<double>? _moveAnimation;
  Timer? _bearingDebounce;

  // ETA / Distance
  String? _etaText;
  String? _distanceText;
  bool _fetchingRoute = false;

  void _loadData() async {
    await Get.find<LocationController>().getCurrentLocation(true, notify: false, defaultLatLng: LatLng(
      double.parse(AddressHelper.getUserAddressFromSharedPref()!.latitude!),
      double.parse(AddressHelper.getUserAddressFromSharedPref()!.longitude!),
    ));
    await Get.find<OrderController>().trackOrder(widget.orderID, null, true, contactNumber: widget.contactNumber);
  }

  void _startApiCall() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await Get.find<OrderController>().timerTrackOrder(widget.orderID.toString(), contactNumber: widget.contactNumber);
      // Map & UI will refresh inside GetBuilder build via _applyTrack() call.
    });
  }

  @override
  void initState() {
    super.initState();
    // Use 2.5 seconds for animation duration to make it natural and smooth
    _moveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    _loadData();
    _startApiCall();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _timer?.cancel();
    _moveController?.dispose();
    _bearingDebounce?.cancel();
    super.dispose();
  }

  void onEntered(bool isHovered) {
    setState(() => this.isHovered = isHovered);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'order_tracking'.tr),
      endDrawer: const MenuDrawer(),endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<OrderController>(builder: (orderController) {
        OrderModel? track;
        if(orderController.trackModel != null) {
          track = orderController.trackModel;

          if(track!.orderType != 'parcel') {
            if (track.store!.storeBusinessModel == 'commission') {
              showChatPermission = true;
            } else if (track.store!.storeSubscription != null && track.store!.storeBusinessModel == 'subscription') {
              showChatPermission = track.store!.storeSubscription!.chat == 1;
            } else {
              showChatPermission = false;
            }
          } else {
            showChatPermission = AuthHelper.isLoggedIn();
          }
        }

        if (track != null && _controller != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _applyTrack(track!));
        }

        return track != null ? Stack(
          children: [
            SingleChildScrollView(
              physics: isHovered || !ResponsiveHelper.isDesktop(context) ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
              child: FooterView(
                child: Center(child: SizedBox(width: Dimensions.webMaxWidth, height: ResponsiveHelper.isDesktop(context) ? 700 : MediaQuery.of(context).size.height * 0.85, child: Stack(children: [

                  MouseRegion(
                    onEnter: (event) => onEntered(true),
                    onExit: (event) => onEntered(false),
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(target: LatLng(
                        double.parse(track!.deliveryAddress!.latitude!), double.parse(track.deliveryAddress!.longitude!),
                      ), zoom: 16),
                      minMaxZoomPreference: const MinMaxZoomPreference(0, 20),
                      zoomControlsEnabled: false,
                      markers: _markers,
                      polylines: _polylines,
                      onMapCreated: (GoogleMapController controller) async {
                        _controller = controller;
                        _isLoading = false;
                        await _initMarkersOnce(track!);
                      },
                      style: Get.isDarkMode ? Get.find<ThemeController>().darkMap : Get.find<ThemeController>().lightMap,
                    ),
                  ),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator()),

                  Positioned(
                    top: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
                    child: TrackingStepperWidget(status: track.orderStatus, takeAway: track.orderType == 'take_away'),
                  ),

                  Positioned(
                    right: 15, bottom: track.orderType != 'take_away' && track.deliveryMan == null ? 150 : 220,
                    child: InkWell(
                      onTap: () => _checkPermission(() async {
                        AddressModel address = await Get.find<LocationController>().getCurrentLocation(false, mapController: _controller);
                        await _centerOn(
                          LatLng(
                            double.parse(address.latitude!),
                            double.parse(address.longitude!),
                          ),
                          zoom: 16
                        );
                      }),
                      child: Container(
                        padding: const EdgeInsets.all( Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.white),
                        child: Icon(Icons.my_location_outlined, color: Theme.of(context).primaryColor, size: 25),
                      ),
                    ),
                  ),

                  if (_etaText != null || _distanceText != null)
                    Positioned(
                      top: 70, left: 12,
                      child: Chip(
                        label: Text(
                          [
                            if (_distanceText != null) _distanceText!,
                            if (_etaText != null) '• $_etaText'
                          ].join(' '),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                    ),

                  Positioned(
                    bottom: Dimensions.paddingSizeSmall, left: Dimensions.paddingSizeSmall, right: Dimensions.paddingSizeSmall,
                    child: TrackDetailsViewWidget(status: track.orderStatus, track: track, showChatPermission: showChatPermission, callback: () async{
                      bool takeAway = track?.orderType == 'take_away';
                      _timer?.cancel();
                      await Get.toNamed(RouteHelper.getChatRoute(
                        notificationBody: takeAway ? NotificationBodyModel(restaurantId: track!.store!.id, orderId: int.parse(widget.orderID!))
                            : NotificationBodyModel(deliverymanId: track!.deliveryMan!.id, orderId: int.parse(widget.orderID!)),
                        user: User(
                          id: takeAway ? track.store!.id : track.deliveryMan!.id,
                          fName: takeAway ? track.store!.name : track.deliveryMan!.fName,
                          lName: takeAway ? '' : track.deliveryMan!.lName,
                          imageFullUrl: takeAway ? track.store!.logoFullUrl : track.deliveryMan!.imageFullUrl,
                        ),
                      ));
                      _startApiCall();
                    }),
                  ),

                ]))),
              ),
            ),
          ],
        ) : const Center(child: CircularProgressIndicator());
      }),
    );
  }

  Future<void> _initMarkersOnce(OrderModel track) async {
    await _setMarkersAndFit(track, setCamera: true);
    await _drawRouteForCurrentPhase(track);
  }

  Future<void> _applyTrack(OrderModel track) async {
    await _setMarkersAndFit(track, setCamera: false);
    await _drawRouteForCurrentPhase(track);
  }

  Future<void> _setMarkersAndFit(OrderModel track, {bool setCamera = false}) async {
    try {
      final bool isRestaurantModule = track.moduleType == 'food';
      final bool isParcel = track.orderType == 'parcel';
      final bool isTakeAway = track.orderType == 'take_away';

      final Store? store = isParcel
          ? Store(
              latitude: track.receiverDetails!.latitude,
              longitude: track.receiverDetails!.longitude,
              address: track.receiverDetails!.address,
              name: track.receiverDetails!.contactPersonName)
          : track.store;

      final AddressModel? destination = isTakeAway
          ? (Get.find<LocationController>().position.latitude == 0
              ? track.deliveryAddress
              : AddressModel(
                  latitude: Get.find<LocationController>().position.latitude.toString(),
                  longitude: Get.find<LocationController>().position.longitude.toString(),
                  address: Get.find<LocationController>().address,
                ))
          : track.deliveryAddress;

      final BitmapDescriptor restaurantImageData = await MarkerHelper.convertAssetToBitmapDescriptor(
        width: (isRestaurantModule || isParcel) ? 30 : 50,
        imagePath: isParcel ? Images.userMarker : isRestaurantModule ? Images.restaurantMarker : Images.markerStore,
      );
      
      final driverBitmap = await BitmapDescriptor.asset(
        const ImageConfiguration(), 'assets/image/delivery_boy.png',
        width: 80,
      );

      final BitmapDescriptor destinationBitmap = await MarkerHelper.convertAssetToBitmapDescriptor(
        width: 32, imagePath: isTakeAway ? Images.myLocationMarker : Images.userMarker,
      );

      final Set<Marker> _new = {};

      if (destination != null) {
        _new.add(
          Marker(
            markerId: const MarkerId('destination'),
            position: LatLng(double.parse(destination.latitude!), double.parse(destination.longitude!)),
            infoWindow: InfoWindow(title: isParcel ? 'sender'.tr : 'Destination'.tr, snippet: destination.address),
            icon: destinationBitmap,
            zIndex: 2,
          ),
        );
      }

      if (store != null) {
        _new.add(
          Marker(
            markerId: const MarkerId('store'),
            position: LatLng(double.parse(store.latitude!), double.parse(store.longitude!)),
            infoWindow: InfoWindow(title: isParcel ? 'receiver'.tr : 'store'.tr, snippet: store.address),
            icon: restaurantImageData,
            zIndex: 1,
          ),
        );
      }

      if (track.deliveryMan != null && track.deliveryMan!.lat != null && track.deliveryMan!.lng != null) {
        final LatLng next = LatLng(
          double.tryParse(track.deliveryMan!.lat!) ?? 0,
          double.tryParse(track.deliveryMan!.lng!) ?? 0,
        );

        if (_driverCurr == null) {
          _driverPrev = next;
          _driverCurr = next;
          _driverBearing = 0;
          _new.add(_buildDriverMarker(next, driverBitmap, _driverBearing));
        } else if (next.latitude != _driverCurr!.latitude || next.longitude != _driverCurr!.longitude) {
          _driverPrev = _driverCurr;
          _driverCurr = next;
          final double bearing = _bearingBetween(_driverPrev!, _driverCurr!);
          _animateDriver(_driverPrev!, _driverCurr!, bearing, driverBitmap);
          _new.add(_buildDriverMarker(_driverCurr!, driverBitmap, bearing)); 
        } else {
          _new.add(_buildDriverMarker(_driverCurr!, driverBitmap, _driverBearing));
        }
      }

      setState(() => _markers = _new);

      if (setCamera && _controller != null) {
        final bounds = _computeBoundsFromMarkers(_new);
        if (bounds != null) {
          await _controller!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
        }
      }
    } catch (_) {}
  }

  Marker _buildDriverMarker(LatLng pos, BitmapDescriptor icon, double bearing) {
    return Marker(
      markerId: const MarkerId('delivery_boy'),
      position: pos,
      infoWindow: InfoWindow(title: 'delivery_man'.tr),
      anchor: const Offset(0.5, 0.5),
      flat: true,
      rotation: bearing,
      icon: icon,
      zIndex: 3,
    );
  }

  LatLngBounds? _computeBoundsFromMarkers(Set<Marker> markers) {
    if (markers.isEmpty) return null;
    double? minLat, minLng, maxLat, maxLng;
    for (final m in markers) {
      final p = m.position;
      minLat = (minLat == null) ? p.latitude : math.min(minLat, p.latitude);
      maxLat = (maxLat == null) ? p.latitude : math.max(maxLat, p.latitude);
      minLng = (minLng == null) ? p.longitude : math.min(minLng, p.longitude);
      maxLng = (maxLng == null) ? p.longitude : math.max(maxLng, p.longitude);
    }
    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }

  Future<void> _centerOn(LatLng target, {double zoom = 16}) async {
    if (_controller == null) return;
    await _controller!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: zoom)));
  }

  Future<void> _drawRouteForCurrentPhase(OrderModel track) async {
    if (_fetchingRoute) return;

    if (track.deliveryMan == null) {
      setState(() {
        _polylines.clear();
        _etaText = null;
        _distanceText = null;
      });
      return;
    }

    LatLng? origin;
    LatLng? dest;

    if (track.deliveryMan!.lat != null && track.deliveryMan!.lng != null) {
      final dLat = double.tryParse(track.deliveryMan!.lat ?? '');
      final dLng = double.tryParse(track.deliveryMan!.lng ?? '');
      if (dLat != null && dLng != null) {
        origin = LatLng(dLat, dLng);
      }
    }

    final bool isTakeAway = track.orderType == 'take_away';
    final AddressModel? destination = isTakeAway
        ? (Get.find<LocationController>().position.latitude == 0
            ? track.deliveryAddress
            : AddressModel(
                latitude: Get.find<LocationController>().position.latitude.toString(),
                longitude: Get.find<LocationController>().position.longitude.toString(),
                address: Get.find<LocationController>().address,
              ))
        : track.deliveryAddress;

    if (destination != null) {
      dest = LatLng(double.parse(destination.latitude!), double.parse(destination.longitude!));
    }

    if (origin == null || dest == null) {
      setState(() {
        _polylines.clear();
        _etaText = null;
        _distanceText = null;
      });
      return;
    }

    await _fetchAndRenderPolyline(origin, dest);
  }

  Future<void> _fetchAndRenderPolyline(LatLng origin, LatLng dest) async {
    _fetchingRoute = true;
    try {
      final url = 'https://maps.googleapis.com/maps/api/directions/json'
          '?origin=${origin.latitude},${origin.longitude}'
          '&destination=${dest.latitude},${dest.longitude}'
          '&mode=driving&key=$_kGoogleApiKey';
      
      final res = await http.get(Uri.parse(url));
      
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0];
          final overview = route['overview_polyline']?['points'];
          final legs = route['legs'];
          
          if (overview != null) {
            final points = _decodePolyline(overview);
            final polyline = Polyline(
              polylineId: const PolylineId('route'),
              points: points,
              width: 6,
              color: Theme.of(context).primaryColor,
              startCap: Cap.roundCap,
              endCap: Cap.roundCap,
              jointType: JointType.round,
            );
            setState(() {
              _polylines = {polyline};
            });
          }
          if (legs != null && (legs as List).isNotEmpty) {
            final leg = legs[0];
            final distText = leg['distance']?['text'];
            final durText = leg['duration']?['text'];
            setState(() {
              _distanceText = distText;
              _etaText = durText;
            });
          }
        } else {
          setState(() {
            _polylines.clear();
            _etaText = null;
            _distanceText = null;
          });
        }
      }
    } catch (_) {
    } finally {
      _fetchingRoute = false;
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }

  void _animateDriver(LatLng from, LatLng to, double bearing, BitmapDescriptor icon) {
    _moveController?.stop();
    _moveController?.reset();

    final tween = Tween<double>(begin: 0, end: 1);
    _moveAnimation = tween.animate(CurvedAnimation(parent: _moveController!, curve: Curves.easeInOut));

    _moveController!.addListener(() {
      final t = _moveAnimation!.value;
      final lat = from.latitude + (to.latitude - from.latitude) * t;
      final lng = from.longitude + (to.longitude - from.longitude) * t;
      final pos = LatLng(lat, lng);

      final newMarkers = _markers.where((m) => m.markerId != const MarkerId('delivery_boy')).toSet();
      newMarkers.add(_buildDriverMarker(pos, icon, bearing));
      setState(() => _markers = newMarkers);
    });

    _moveController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _driverBearing = bearing;
      }
    });

    _bearingDebounce?.cancel();
    _bearingDebounce = Timer(const Duration(milliseconds: 400), () async {
      await _centerDriverIfNeeded(to);
    });

    _moveController!.forward();
  }

  Future<void> _centerDriverIfNeeded(LatLng driver) async {
    if (_controller == null) return;
    try {
      final LatLngBounds visibleRegion = await _controller!.getVisibleRegion();
      if (!visibleRegion.contains(driver)) {
        final zoom = await _controller!.getZoomLevel();
        await _controller!.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: driver, zoom: zoom),
        ));
      }
    } catch (_) {}
  }

  double _bearingBetween(LatLng from, LatLng to) {
    final double lat1 = _degToRad(from.latitude);
    final double lon1 = _degToRad(from.longitude);
    final double lat2 = _degToRad(to.latitude);
    final double lon2 = _degToRad(to.longitude);

    final double dLon = lon2 - lon1;
    final double y = math.sin(dLon) * math.cos(lat2);
    final double x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    double brng = math.atan2(y, x);
    brng = _radToDeg(brng);
    return (brng + 360) % 360;
  }

  double _degToRad(double deg) => deg * (math.pi / 180.0);
  double _radToDeg(double rad) => rad * (180.0 / math.pi);

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr);
    } else if (permission == LocationPermission.deniedForever) {
      Get.dialog(const PermissionDialogWidget());
    } else {
      onTap();
    }
  }
}
