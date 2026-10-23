import 'package:sixam_mart/features/cab_booking/domain/models/vehicle_type_model.dart';
import 'package:sixam_mart/features/cab_booking/domain/models/ride_model.dart';
import 'package:sixam_mart/features/cab_booking/domain/repositories/cab_repository.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'dart:math';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/helper/marker_helper.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sixam_mart/features/cab_booking/home/screens/cab_home_screen.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/features/cab_booking/home/widgets/coupon_success_dialog.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/location/domain/models/zone_response_model.dart';


class CabController extends GetxController implements GetxService {
  final CabRepository cabRepository;
  CabController({required this.cabRepository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<VehicleTypeModel>? _vehicleTypes;
  List<VehicleTypeModel>? get vehicleTypes => _vehicleTypes;

  int _selectedVehicleIndex = 0;
  int get selectedVehicleIndex => _selectedVehicleIndex;

  double? _estimatedFare;
  double? get estimatedFare => _estimatedFare;

  LatLng? _sourceLatLng;
  LatLng? get sourceLatLng => _sourceLatLng;

  LatLng? _destinationLatLng;
  LatLng? get destinationLatLng => _destinationLatLng;

  String? _sourceAddress;
  String? get sourceAddress => _sourceAddress;

  String? _destinationAddress;
  String? get destinationAddress => _destinationAddress;

  CabRideModel? _rideDetails;
  CabRideModel? get rideDetails => _rideDetails;

  List<CabRideModel>? _rideList;
  List<CabRideModel>? get rideList => _rideList;

  CabRideModel? get activeRide {
    if (_rideList == null) return null;
    try {
      return _rideList!.firstWhere((ride) {
        // Active statuses based on backend logic
        bool isActive = ['pending', 'accepted', 'ongoing', 'arrived', 'scheduled'].contains(ride.status);
        // Also check for completed but unconfirmed payment (exclude if already paid)
        bool isUnpaid = ride.status == 'completed' && (ride.paymentConfirmedByRider == false) && ride.paymentStatus != 'paid';
        
        return isActive || isUnpaid;
      });
    } catch (e) {
      return null;
    }
  }

  String? _couponCode;
  String? get couponCode => _couponCode;

  double _discount = 0.0;
  double get discount => _discount;

  String? _discountType;
  String? get discountType => _discountType;

  double _rawDiscount = 0.0;
  double get rawDiscount => _rawDiscount;

  double _taxAmount = 0.0;
  double get taxAmount => _taxAmount;

  double _taxPercentage = 0.0;
  double get taxPercentage => _taxPercentage;

  BitmapDescriptor? _riderMarkerIcon;
  BitmapDescriptor? get riderMarkerIcon => _riderMarkerIcon;

  Set<Marker> _markers = {};
  Set<Marker> get markers => _markers;

  String _paymentMethod = 'cash';
  String get paymentMethod => _paymentMethod;

  final Map<PolylineId, Polyline> _polyLines = {};
  Map<PolylineId, Polyline> get polyLines => _polyLines;

  final MarkerId fromMarkerId = const MarkerId('from_marker');
  final MarkerId toMarkerId = const MarkerId('to_marker');

  bool _showSelectionMode = false;
  bool get showSelectionMode => _showSelectionMode;

  double? _distance;
  double? get distance => _distance;

  double? _duration;
  double? get duration => _duration;

  Timer? _timer;

  DateTime? _scheduleAt;
  DateTime? get scheduleAt => _scheduleAt;

  void setScheduleAt(DateTime? time) {
    _scheduleAt = time;
    update();
  }

  void applyCoupon(String code) {
    _couponCode = code;
    calculateFare(fromCoupon: true);
  }

  void removeCoupon() {
    _couponCode = null;
    _discount = 0.0;
    calculateFare();
  }

  Future<void> getVehicleTypes() async {
    _isLoading = true;
    update();
    Response response = await cabRepository.getVehicleTypes();
    if (response.statusCode == 200) {
      _vehicleTypes = [];
      response.body.forEach((v) => _vehicleTypes!.add(VehicleTypeModel.fromJson(v)));
    }
    _isLoading = false;
    await getMyRides();
    update();
  }

  void selectVehicle(int index) {
    _selectedVehicleIndex = index;
    update();
    if (_sourceLatLng != null && _destinationLatLng != null) {
      calculateFare();
    }
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    update();
  }

  void toggleSelectionMode(bool status) {
    _showSelectionMode = status;
    if(!status) {
      _sourceLatLng = null;
      _destinationLatLng = null;
      _sourceAddress = null;
      _destinationAddress = null;
      _markers.clear();
      _polyLines.clear();
      _estimatedFare = null;
      _scheduleAt = null;
    }
    update();
  }

  Future<void> calculateFare({bool fromCoupon = false}) async {
    if (_vehicleTypes == null || _vehicleTypes!.isEmpty) return;
    
    _isLoading = true;
    update();
    
    _distance = Geolocator.distanceBetween(
      _sourceLatLng!.latitude, _sourceLatLng!.longitude, 
      _destinationLatLng!.latitude, _destinationLatLng!.longitude
    ) / 1000; // Convert to KM
    
    // Try to get real road distance
    Response distanceResponse = await cabRepository.getDistanceInMeter(_sourceLatLng!, _destinationLatLng!);
    if(distanceResponse.statusCode == 200 && distanceResponse.body['status'] == 'OK') {
       _distance = (distanceResponse.body['rows'][0]['elements'][0]['distance']['value'] / 1000).toDouble();
       _duration = (distanceResponse.body['rows'][0]['elements'][0]['duration']['value'] / 60).toDouble();
    } else {
      _duration = (_distance! * 2) + 5;
    }
    
    Response response = await cabRepository.calculateFare(
      _distance!, _duration!, _vehicleTypes![_selectedVehicleIndex].id!,
      couponCode: _couponCode,
    );
    
    if (response.statusCode == 200) {
      _estimatedFare = response.body['estimated_fare']?.toDouble();
      _discount = response.body['discount']?.toDouble() ?? 0.0;
      _discountType = response.body['discount_type'];
      _rawDiscount = response.body['raw_discount']?.toDouble() ?? 0.0;
      _taxAmount = response.body['tax_amount']?.toDouble() ?? 0.0;
      _taxPercentage = response.body['tax_percentage']?.toDouble() ?? 0.0;
      if(response.body['coupon_applied'] == false && _couponCode != null) {
        showCustomSnackBar('invalid_code_or'.tr);
        _couponCode = null;
        _discount = 0.0;
        _discountType = null;
        _rawDiscount = 0.0;
      } else if (fromCoupon && _discount > 0) {
        Get.dialog(CouponSuccessDialog(discount: _discount));
      }
    }
    _isLoading = false;
    update();
  }

  void setSource(LatLng latLng, String address, GoogleMapController? mapController) async {
    _sourceLatLng = latLng;
    _sourceAddress = address;
    update();
    if (_destinationLatLng != null) {
      await setFromToMarker(mapController, from: _sourceLatLng!, to: _destinationLatLng!);
      calculateFare();
    }
  }

  void setDestination(LatLng latLng, String address, GoogleMapController? mapController) async {
    _destinationLatLng = latLng;
    _destinationAddress = address;
    _showSelectionMode = true;
    update();
    if (_sourceLatLng != null) {
      await setFromToMarker(mapController, from: _sourceLatLng!, to: _destinationLatLng!);
      calculateFare();
    }
  }

  Future<void> setFromToMarker(GoogleMapController? mapController, {required LatLng from, required LatLng to}) async {
    _isLoading = true;
    update();

    final BitmapDescriptor fromMarkerIcon = await MarkerHelper.convertAssetToBitmapDescriptor(imagePath: Images.taxiPickup, height: 30);
    final BitmapDescriptor toMarkerIcon = await MarkerHelper.convertAssetToBitmapDescriptor(imagePath: Images.taxiDestination, height: 30);

    _markers = {};
    _markers.add(Marker(markerId: fromMarkerId, position: from, icon: fromMarkerIcon));
    _markers.add(Marker(markerId: toMarkerId, position: to, icon: toMarkerIcon));

    if(mapController != null) {
      LatLngBounds bounds = _boundsFromLatLngList([from, to]);
      mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    }

    await generatePolyLines(from: from, to: to);

    _isLoading = false;
    update();
  }

  Future<void> generatePolyLines({required LatLng from, required LatLng to}) async {
    _polyLines.clear();
    Response response = await cabRepository.getRouteBetweenCoordinates(from, to);
    
    // Debug log for troubleshooting
    if (response.statusCode == 200) {
      print('====> Polyline API Body: ${response.body}');
    } else {
      print('====> Polyline API Error: ${response.statusCode} - ${response.statusText}');
    }

    if (response.statusCode == 200 && response.body["routes"] != null && response.body["routes"].isNotEmpty) {
      String? encodedPolyline;
      
      final route = response.body['routes'][0];
      // Support for Routes API v2
      if (route['polyline'] != null && route['polyline']['encodedPolyline'] != null) {
        encodedPolyline = route['polyline']['encodedPolyline'];
      } 
      // Support for Directions API v1
      else if (route['overview_polyline'] != null && route['overview_polyline']['points'] != null) {
        encodedPolyline = route['overview_polyline']['points'];
      }

      if (encodedPolyline != null) {
        List<LatLng> polylineCoordinates = _decodeEncodedPolyline(encodedPolyline);
        
        PolylineId polyId = const PolylineId('my_polyline');
        Polyline polyline = Polyline(
          polylineId: polyId,
          points: polylineCoordinates,
          width: 7,
          color: Colors.blue[700]!,
        );
        _polyLines[polyId] = polyline;
      } else {
        // Fallback: draw a straight line if API fails to provide a path
        PolylineId polyId = const PolylineId('my_polyline');
        Polyline polyline = Polyline(
          polylineId: polyId,
          points: [from, to],
          width: 5,
          color: Colors.blue[300]!.withOpacity(0.5),
        );
        _polyLines[polyId] = polyline;
      }
    } else {
      // Fallback for API errors
      PolylineId polyId = const PolylineId('my_polyline');
      Polyline polyline = Polyline(
        polylineId: polyId,
        points: [from, to],
        width: 5,
        color: Colors.red[300]!.withOpacity(0.3),
      );
      _polyLines[polyId] = polyline;
    }
  }

  List<LatLng> _decodeEncodedPolyline(String encoded) {
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
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
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

  Future<int?> placeRideRequest() async {
    if (!AuthHelper.isLoggedIn()) {
      showCustomSnackBar('please_login_to_book_a_ride'.tr);
      Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.main));
      return null;
    }

    if (_sourceLatLng == null || _destinationLatLng == null) {
      showCustomSnackBar('select_pickup_and_destination'.tr);
      return null;
    }

    _isLoading = true;
    update();
    
    ZoneResponseModel responseModel = await Get.find<LocationController>().getZone(
      _sourceLatLng!.latitude.toString(), 
      _sourceLatLng!.longitude.toString(), 
      false
    );
    
    int? selectedZoneId;
    if (responseModel.isSuccess && responseModel.zoneData.isNotEmpty) {
      bool isCabActive = false;
      for (var zone in responseModel.zoneData) {
        if (zone.modules != null) {
          for (var module in zone.modules!) {
            if (module.moduleType == 'cab' && module.status == '1') {
              isCabActive = true;
              selectedZoneId = zone.id;
              break;
            }
          }
        }
        if (isCabActive) break;
      }
      
      if (!isCabActive) {
        _isLoading = false;
        update();
        showCustomSnackBar('Service not available in this area');
        return null;
      }
    } else {
      _isLoading = false;
      update();
      showCustomSnackBar('Service not available in this area');
      return null;
    }
    
    double distance = Geolocator.distanceBetween(
      _sourceLatLng!.latitude, _sourceLatLng!.longitude, 
      _destinationLatLng!.latitude, _destinationLatLng!.longitude
    ) / 1000;
    double duration = (distance * 2) + 5;

    double totalAmount = _estimatedFare ?? (_vehicleTypes != null && _selectedVehicleIndex < _vehicleTypes!.length ? (_vehicleTypes![_selectedVehicleIndex].baseFare ?? 0.0) : 0.0);

    Map<String, dynamic> body = {
      'pickup_lat': _sourceLatLng?.latitude,
      'pickup_lng': _sourceLatLng?.longitude,
      'destination_lat': _destinationLatLng?.latitude,
      'destination_lng': _destinationLatLng?.longitude,
      'pickup_address': _sourceAddress,
      'destination_address': _destinationAddress,
      'vehicle_type_id': _vehicleTypes![_selectedVehicleIndex].id,
      'zone_id': selectedZoneId,
      'total_amount': totalAmount,
      'distance': distance, 
      'duration': duration, 
      'coupon_code': _couponCode,
      'discount_amount': _discount,
      'tax_amount': _taxAmount,
      'tax_percentage': _taxPercentage,
      'payment_method': _paymentMethod,
      'schedule_at': _scheduleAt?.toIso8601String(),
    };

    Response response = await cabRepository.placeRideRequest(body);
    _isLoading = false;
    update();
    if (response.statusCode == 200) {
      return response.body['ride_id'];
    } else {
      String message = response.body['message'] ?? response.statusText;
      showCustomSnackBar(message);
    }
    return null;
  }

  Future<void> getRideDetails(int rideId) async {
    Response response = await cabRepository.getRideDetails(rideId);
    if (response.statusCode == 200) {
      _rideDetails = CabRideModel.fromJson(response.body);
      
      if(_rideDetails?.vehicleType?.typeName != null) {
        String type = _rideDetails!.vehicleType!.typeName!.toLowerCase();
        String image = Images.sedanCab;
        if(type.contains('bike')) {
          image = Images.deliveryBoy;
        } else if(type.contains('auto')) {
          image = Images.autoCab;
        }
        _riderMarkerIcon = await MarkerHelper.convertAssetToBitmapDescriptor(imagePath: image, height: 40);
      }
      
      update();
      
      if (_rideDetails?.status == 'completed' || _rideDetails?.status == 'canceled') {
        _polyLines.clear();
      } else if (_rideDetails?.pickupLat != null && _rideDetails?.dropLat != null) {
        LatLng origin = LatLng(_rideDetails!.pickupLat!, _rideDetails!.pickupLng!);
        LatLng destination = LatLng(_rideDetails!.dropLat!, _rideDetails!.dropLng!);
        
        if(_rideDetails?.vehicle?.lastLat != null && _rideDetails?.status != 'pending') {
           origin = LatLng(_rideDetails!.vehicle!.lastLat!, _rideDetails!.vehicle!.lastLng!);
           destination = _rideDetails!.status == 'ongoing' 
              ? LatLng(_rideDetails!.dropLat!, _rideDetails!.dropLng!)
              : LatLng(_rideDetails!.pickupLat!, _rideDetails!.pickupLng!);
        }
        
        generatePolyLines(from: origin, to: destination).then((_) => update());
      }
    }
  }

  Future<void> getMyRides() async {
    if (!AuthHelper.isLoggedIn()) return;
    _isLoading = true;
    update();
    Response response = await cabRepository.getMyRides();
    if (response.statusCode == 200) {
      _rideList = [];
      response.body.forEach((v) => _rideList!.add(CabRideModel.fromJson(v)));
    }
    _isLoading = false;
    update();
  }

  void startPolling(int rideId) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if(_rideDetails?.status == 'completed' || _rideDetails?.status == 'canceled') {
        timer.cancel();
      } else {
        getRideDetails(rideId);
      }
    });
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  Future<bool> cancelRide(int rideId, {String? reason}) async {
    _isLoading = true;
    update();
    Response response = await cabRepository.cancelRide(rideId, reason: reason);
    if (response.statusCode == 200) {
      await getRideDetails(rideId);
      await getMyRides();
      _polyLines.clear();
      showCustomSnackBar('ride_canceled_successfully'.tr, isError: false);
      _isLoading = false;
      update();
      return true;
    } else {
      showCustomSnackBar(response.statusText);
      _isLoading = false;
      update();
      return false;
    }
  }

  Future<void> sendSos(int rideId, double lat, double lng) async {
    _isLoading = true;
    update();
    Response response = await cabRepository.sendSos(rideId, lat, lng);
    if (response.statusCode == 200) {
      showCustomSnackBar('SOS alert sent successfully', isError: false);
    } else {
      showCustomSnackBar('Failed to send SOS alert');
    }
    _isLoading = false;
    update();
  }

  Future<void> updatePaymentMethod(int rideId, String method) async {
    _isLoading = true;
    update();
    Response response = await cabRepository.updatePaymentMethod(rideId, method);
    if (response.statusCode == 200) {
      _paymentMethod = method;
      await getRideDetails(rideId);
      showCustomSnackBar('payment_method_updated_successfully'.tr, isError: false);
    }
    _isLoading = false;
    update();
  }

  Future<void> submitReview(int rideId, int rating, String comment) async {
    _isLoading = true;
    update();
    Response response = await cabRepository.submitReview(rideId, rating, comment);
    if (response.statusCode == 200) {
      showCustomSnackBar('review_submitted_successfully'.tr, isError: false);
      Get.offAllNamed(RouteHelper.getInitialRoute());
    }
    _isLoading = false;
    update();
  }

  Future<void> payWithWallet(int rideId) async {
    _isLoading = true;
    update();
    Response response = await cabRepository.walletPayment(rideId);
    if (response.statusCode == 200) {
      await getRideDetails(rideId);
      showCustomSnackBar('payment_done_successfully'.tr, isError: false);
    } else {
      showCustomSnackBar(response.statusText);
    }
    _isLoading = false;
    update();
  }

  void payDigital(CabRideModel ride) {
    String url = '${AppConstants.baseUrl}/payment-mobile?customer_id=${ride.customerId}&ride_id=${ride.id}&amount=${ride.actualFare ?? ride.estimatedFare}&type=cab_ride&payment_method=${ride.paymentMethod}&payment_platform=${kIsWeb ? 'web' : 'app'}';
    
    if (kIsWeb) {
      String? hostname = html.window.location.hostname;
      String protocol = html.window.location.protocol;
      String selectedUrl = '$url&callback=$protocol//$hostname${RouteHelper.orderSuccess}?id=${ride.id}&status=';
      html.window.open(selectedUrl, "_self");
    } else {
      Get.toNamed(RouteHelper.getPaymentRoute(
        ride.id.toString(), ride.customerId, 'cab_ride', ride.actualFare ?? ride.estimatedFare ?? 0.0,
        false, ride.paymentMethod, guestId: '', addFundUrl: Uri.encodeComponent(url),
      ));
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
