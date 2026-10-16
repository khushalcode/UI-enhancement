class CabRideModel {
  int? id;
  int? customerId;
  int? riderId;
  int? vehicleId;
  int? vehicleTypeId;
  String? pickupLocation;
  double? pickupLat;
  double? pickupLng;
  String? dropLocation;
  double? dropLat;
  double? dropLng;
  double? distance;
  double? duration;
  double? estimatedFare;
  double? actualFare;
  double? taxAmount;
  double? taxPercentage;
  String? otp;
  String? status;
  String? paymentStatus;
  String? paymentMethod;
  bool? paymentConfirmedByRider;
  String? paymentConfirmedAt;
  bool? isReviewed;
  String? scheduleAt;
  String? createdAt;
  String? updatedAt;
  String? cancelReason;
  String? couponCode;
  double? couponDiscountAmount;
  Customer? customer;
  Rider? rider;
  Vehicle? vehicle;
  VehicleType? vehicleType;
  Review? review;

  CabRideModel({
    this.id,
    this.customerId,
    this.riderId,
    this.vehicleId,
    this.vehicleTypeId,
    this.pickupLocation,
    this.pickupLat,
    this.pickupLng,
    this.dropLocation,
    this.dropLat,
    this.dropLng,
    this.distance,
    this.duration,
    this.estimatedFare,
    this.actualFare,
    this.taxAmount,
    this.taxPercentage,
    this.otp,
    this.status,
    this.paymentStatus,
    this.paymentMethod,
    this.paymentConfirmedByRider,
    this.paymentConfirmedAt,
    this.isReviewed,
    this.scheduleAt,
    this.createdAt,
    this.updatedAt,
    this.cancelReason,
    this.couponCode,
    this.couponDiscountAmount,
    this.customer,
    this.rider,
    this.vehicle,
    this.vehicleType,
    this.review,
  });

  CabRideModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerId = json['customer_id'];
    riderId = json['rider_id'];
    vehicleId = json['vehicle_id'];
    vehicleTypeId = json['vehicle_type_id'];
    pickupLocation = json['pickup_location'];
    pickupLat = double.tryParse(json['pickup_lat'].toString());
    pickupLng = double.tryParse(json['pickup_lng'].toString());
    dropLocation = json['drop_location'];
    dropLat = double.tryParse(json['drop_lat'].toString());
    dropLng = double.tryParse(json['drop_lng'].toString());
    distance = double.tryParse(json['distance'].toString());
    duration = double.tryParse(json['duration'].toString());
    estimatedFare = double.tryParse(json['estimated_fare'].toString());
    actualFare = double.tryParse(json['actual_fare'].toString());
    taxAmount = double.tryParse(json['tax_amount'].toString());
    taxPercentage = double.tryParse(json['tax_percentage'].toString());
    otp = json['otp'].toString();
    status = json['status'];
    paymentStatus = json['payment_status'];
    paymentMethod = json['payment_method'];
    paymentConfirmedByRider = json['payment_confirmed_by_rider'] == 1 || json['payment_confirmed_by_rider'] == true;
    paymentConfirmedAt = json['payment_confirmed_at'];
    isReviewed = json['is_reviewed'] ?? (json['reviews'] != null && json['reviews'].length > 0);
    scheduleAt = json['schedule_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    cancelReason = json['cancel_reason'];
    couponCode = json['coupon_code'];
    couponDiscountAmount = double.tryParse(json['coupon_discount_amount'].toString());
    customer = json['customer'] != null ? Customer.fromJson(json['customer']) : null;
    rider = json['rider'] != null ? Rider.fromJson(json['rider']) : null;
    vehicle = json['vehicle'] != null ? Vehicle.fromJson(json['vehicle']) : null;
    vehicleType = json['vehicle_type'] != null ? VehicleType.fromJson(json['vehicle_type']) : null;
    review = json['review'] != null ? Review.fromJson(json['review']) : ((json['reviews'] != null && json['reviews'].length > 0) ? Review.fromJson(json['reviews'][0]) : null);
  }
}

class Review {
  int? id;
  int? rideId;
  int? rating;
  String? comment;
  String? createdAt;

  Review({this.id, this.rideId, this.rating, this.comment, this.createdAt});

  Review.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    rideId = json['ride_id'];
    rating = int.tryParse(json['rating'].toString());
    comment = json['comment'];
    createdAt = json['created_at'];
  }
}

class VehicleType {
  int? id;
  String? typeName;
  String? image;

  VehicleType({this.id, this.typeName, this.image});

  VehicleType.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    typeName = json['type_name'];
    image = json['image'];
  }
}

class Customer {
  int? id;
  String? fName;
  String? lName;
  String? phone;
  String? image;

  Customer({this.id, this.fName, this.lName, this.phone, this.image});

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fName = json['f_name'];
    lName = json['l_name'];
    phone = json['phone'];
    image = json['image'];
  }
}

class Rider {
  int? id;
  String? fName;
  String? lName;
  String? phone;
  String? image;
  double? avgRating;
  int? ratingCount;

  Rider({this.id, this.fName, this.lName, this.phone, this.image, this.avgRating, this.ratingCount});

  Rider.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fName = json['f_name'];
    lName = json['l_name'];
    phone = json['phone'];
    image = json['image_full_url'] ?? json['image'];
    avgRating = double.tryParse(json['avg_rating'].toString());
    ratingCount = int.tryParse(json['rating_count'].toString());
  }

  String? get imageFullUrl => image; // Simple getter for now, backend usually sends full url in this module
}

class Vehicle {
  int? id;
  String? brand;
  String? model;
  String? licensePlate;
  double? lastLat;
  double? lastLng;

  Vehicle({this.id, this.brand, this.model, this.licensePlate, this.lastLat, this.lastLng});

  Vehicle.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    brand = json['brand'];
    model = json['model'];
    licensePlate = json['license_plate'];
    lastLat = double.tryParse(json['last_lat'].toString());
    lastLng = double.tryParse(json['last_lng'].toString());
  }
}
