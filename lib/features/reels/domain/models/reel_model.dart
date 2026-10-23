class ReelModel {
  int? id;
  int? storeId;
  int? itemId;
  String? videoUrl;
  int? status;
  String? createdAt;
  String? updatedAt;
  ReelItem? item;
  ReelStore? store;

  ReelModel({
    this.id,
    this.storeId,
    this.itemId,
    this.videoUrl,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.item,
    this.store,
  });

  ReelModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    storeId = json['store_id'];
    itemId = json['item_id'];
    videoUrl = json['video_url'];
    status = json['status'] is bool ? (json['status'] ? 1 : 0) : (json['status'] is int ? json['status'] : int.tryParse(json['status'].toString()));
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    item = json['item'] != null ? ReelItem.fromJson(json['item']) : null;
    store = json['store'] != null ? ReelStore.fromJson(json['store']) : null;
  }
}

class ReelItem {
  int? id;
  String? name;
  String? description;
  String? image;
  double? price;
  double? discount;
  String? discountType;
  int? storeId;
  int? moduleId;

  ReelItem({
    this.id,
    this.name,
    this.description,
    this.image,
    this.price,
    this.discount,
    this.discountType,
    this.storeId,
    this.moduleId,
  });

  ReelItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];
    image = json['image'];
    price = json['price']?.toDouble();
    discount = json['discount']?.toDouble();
    discountType = json['discount_type'];
    storeId = json['store_id'];
    moduleId = json['module_id'];
  }
}

class ReelStore {
  int? id;
  String? name;
  String? logo;
  int? moduleId;

  ReelStore({this.id, this.name, this.logo, this.moduleId});

  ReelStore.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    logo = json['logo'];
    moduleId = json['module_id'];
  }
}
