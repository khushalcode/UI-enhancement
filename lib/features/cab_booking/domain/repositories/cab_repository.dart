import 'package:sixam_mart/api/api_client.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CabRepository {
  final ApiClient apiClient;
  CabRepository({required this.apiClient});

  Future<Response> getVehicleTypes() async {
    return await apiClient.getData('/api/v1/cab/vehicle-types');
  }

  Future<Response> calculateFare(double distance, double duration, int vehicleTypeId, {String? couponCode}) async {
    return await apiClient.postData('/api/v1/cab/calculate-fare', {
      'distance': distance,
      'duration': duration,
      'vehicle_type_id': vehicleTypeId,
      'coupon_code': couponCode,
    });
  }

  Future<Response> placeRideRequest(Map<String, dynamic> body) async {
    return await apiClient.postData('/api/v1/cab/place-request', body);
  }

  Future<Response> getRideDetails(int rideId) async {
    return await apiClient.getData('/api/v1/cab/ride-details/$rideId');
  }

  Future<Response> getMyRides() async {
    return await apiClient.getData('/api/v1/cab/my-rides');
  }
  Future<Response> getRouteBetweenCoordinates(LatLng origin, LatLng destination) async {
    return await apiClient.getData('${AppConstants.directionUri}'
        '?origin_lat=${origin.latitude}&origin_lng=${origin.longitude}'
        '&destination_lat=${destination.latitude}&destination_lng=${destination.longitude}');
  }

  Future<Response> getDistanceInMeter(LatLng originLatLng, LatLng destinationLatLng) async {
    return await apiClient.getData(
      '${AppConstants.distanceMatrixUri}?origin_lat=${originLatLng.latitude}&origin_lng=${originLatLng.longitude}'
          '&destination_lat=${destinationLatLng.latitude}&destination_lng=${destinationLatLng.longitude}&mode=DRIVE',
      handleError: false,
    );
  }

  Future<Response> cancelRide(int rideId, {String? reason}) async {
    Map<String, dynamic> body = {'ride_id': rideId};
    if (reason != null && reason.isNotEmpty) {
      body['cancel_reason'] = reason;
    }
    return await apiClient.postData('/api/v1/cab/cancel-ride', body);
  }

  Future<Response> sendSos(int rideId, double lat, double lng) async {
    return await apiClient.postData('/api/v1/cab/sos', {
      'ride_id': rideId,
      'lat': lat,
      'lng': lng,
    });
  }

  Future<Response> updatePaymentMethod(int rideId, String paymentMethod) async {
    return await apiClient.postData('/api/v1/cab/update-payment-method', {
      'ride_id': rideId,
      'payment_method': paymentMethod,
    });
  }

  Future<Response> submitReview(int rideId, int rating, String comment) async {
    return await apiClient.postData('/api/v1/cab/submit-review', {
      'ride_id': rideId,
      'rating': rating,
      'comment': comment,
    });
  }

  Future<Response> walletPayment(int rideId) async {
    return await apiClient.postData('/api/v1/cab/wallet-payment', {'ride_id': rideId});
  }
}
