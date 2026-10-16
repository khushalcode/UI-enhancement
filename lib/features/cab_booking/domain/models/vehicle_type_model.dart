class VehicleTypeModel {
  int? id;
  String? typeName;
  String? image;
  int? capacity;
  double? baseFare;
  double? perKmCharge;
  double? perMinuteCharge;
  double? minFare;

  VehicleTypeModel({
    this.id,
    this.typeName,
    this.image,
    this.capacity,
    this.baseFare,
    this.perKmCharge,
    this.perMinuteCharge,
    this.minFare,
  });

  VehicleTypeModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    typeName = json['type_name'];
    image = json['image'];
    capacity = json['capacity'];
    baseFare = json['base_fare']?.toDouble();
    perKmCharge = json['per_km_charge']?.toDouble();
    perMinuteCharge = json['per_minute_charge']?.toDouble();
    minFare = json['min_fare']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type_name'] = typeName;
    data['image'] = image;
    data['capacity'] = capacity;
    data['base_fare'] = baseFare;
    data['per_km_charge'] = perKmCharge;
    data['per_minute_charge'] = perMinuteCharge;
    data['min_fare'] = minFare;
    return data;
  }
}
