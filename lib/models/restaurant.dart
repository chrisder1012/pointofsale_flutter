class Responses {
  int? minOrderValue;
  int? maxOrderValue;
  String? convenienceFeeType;
  double? convenienceFee;
  int? cod;
  String? name;
  int? status;
  String? longitude;
  String? latitude;
  String? foodTax;
  String? drinkTax;
  String? grandTax;
  int? id;
  int? resId;
  String? monopenTime;
  String? moncloseTime;
  String? tueopenTime;
  String? tuecloseTime;
  String? wedopenTime;
  String? wedcloseTime;
  String? thuopenTime;
  String? thucloseTime;
  String? friopenTime;
  String? fricloseTime;
  String? satopenTime;
  String? satcloseTime;
  String? sunopenTime;
  String? suncloseTime;
  String? createdAt;

  Responses({
    this.minOrderValue,
    this.maxOrderValue,
    this.convenienceFeeType,
    this.convenienceFee,
    this.cod,
    this.name,
    this.status,
    this.longitude,
    this.latitude,
    this.foodTax,
    this.drinkTax,
    this.grandTax,
    this.id,
    this.resId,
    this.monopenTime,
    this.moncloseTime,
    this.tueopenTime,
    this.tuecloseTime,
    this.wedopenTime,
    this.wedcloseTime,
    this.thuopenTime,
    this.thucloseTime,
    this.friopenTime,
    this.fricloseTime,
    this.satopenTime,
    this.satcloseTime,
    this.sunopenTime,
    this.suncloseTime,
    this.createdAt,
  });

  factory Responses.fromJson(dynamic d) {
    return Responses(
      minOrderValue: d['min_order_value'],
      maxOrderValue: d['max_order_value'],
      convenienceFeeType: d['convenience_fee_type'],
      convenienceFee: d['convenience_fee']?.toDouble(),
      cod: d['cod'],
      name: d['name'],
      status: d['status'],
      longitude: d['longitude'].toString(),
      latitude: d['latitude'].toString(),
      foodTax: d['food_tax']?.toString(),
      drinkTax: d['drink_tax']?.toString(),
      grandTax: d['grand_tax']?.toString(),
      id: d['id'],
      resId: d['res_id'],
      monopenTime: d['monopen_time'],
      moncloseTime: d['monclose_time'],
      tueopenTime: d['tueopen_time'],
      tuecloseTime: d['tueclose_time'],
      wedopenTime: d['wedopen_time'],
      wedcloseTime: d['wedclose_time'],
      thuopenTime: d['thuopen_time'],
      thucloseTime: d['thuclose_time'],
      friopenTime: d['friopen_time'],
      fricloseTime: d['friclose_time'],
      satopenTime: d['satopen_time'],
      satcloseTime: d['satclose_time'],
      sunopenTime: d['sunopen_time'],
      suncloseTime: d['sunclose_time'],
      createdAt: d['created_at'],
    );
  }

  Map<String, dynamic> toJson() => {
        'min_order_value': minOrderValue,
        'max_order_value': maxOrderValue,
        'convenience_fee_type': convenienceFeeType,
        'convenience_fee': convenienceFee,
        'cod': cod,
        'name': name,
        'status': status,
        'longitude': longitude,
        'latitude': latitude,
        'food_tax': foodTax,
        'drink_tax': drinkTax,
        'grand_tax': grandTax,
        'id': id,
        'res_id': resId,
        'monopen_time': monopenTime,
        'monclose_time': moncloseTime,
        'tueopen_time': tueopenTime,
        'tueclose_time': tuecloseTime,
        'wedopen_time': wedopenTime,
        'wedclose_time': wedcloseTime,
        'thuopen_time': thuopenTime,
        'thuclose_time': thucloseTime,
        'friopen_time': friopenTime,
        'friclose_time': fricloseTime,
        'satopen_time': satopenTime,
        'satclose_time': satcloseTime,
        'sunopen_time': sunopenTime,
        'sunclose_time': suncloseTime,
        'created_at': createdAt,
      };
}

class Restaurant {
  int? id;
  String? name;
  String? email;
  String? description;
  String? description_es;
  int? status;
  int? category;
  String? subcategory;
  int? created_by;
  String? restaurantpic;
  String? city;
  String? address;
  String? contact;
  String? website;
  String? latitude;
  String? longitude;
  int? avg_cost;
  int? claimed;
  int? min_order_value;
  int? max_order_value;
  int? cod;
  String? stripe_acc;
  int? cancel_charge;
  int? can_edit_pos;
  int? can_edit_menu;
  int? can_edit_reservation;
  int? can_edit_order;
  int? can_edit_discount;
  String? created_at;
  String? ath_acc;
  String? ath_secret;
  int? stripe_fee;
  String? convenience_fee_type;
  double? convenience_fee;
  String? food_tax;
  String? drink_tax;
  String? grand_tax;
  String? delivery_charge;
  double? base_delivery_distance;
  String? driver_fee;
  String? currency_code;
  String? imagesUploadedInfo;
  String? default_display_language_code;

  Restaurant({
    this.address,
    this.ath_acc,
    this.ath_secret,
    this.avg_cost,
    this.base_delivery_distance,
    this.can_edit_discount,
    this.can_edit_menu,
    this.can_edit_order,
    this.can_edit_pos,
    this.can_edit_reservation,
    this.cancel_charge,
    this.category,
    this.city,
    this.claimed,
    this.cod,
    this.contact,
    this.convenience_fee,
    this.convenience_fee_type,
    this.created_at,
    this.created_by,
    this.currency_code,
    this.default_display_language_code,
    this.delivery_charge,
    this.description,
    this.description_es,
    this.drink_tax,
    this.driver_fee,
    this.email,
    this.food_tax,
    this.grand_tax,
    this.id,
    this.imagesUploadedInfo,
    this.latitude,
    this.longitude,
    this.max_order_value,
    this.min_order_value,
    this.name,
    this.restaurantpic,
    this.status,
    this.stripe_acc,
    this.stripe_fee,
    this.subcategory,
    this.website,
  });

  factory Restaurant.fromJson(dynamic d) {
    return Restaurant(
      id: d['id'],
      name: d['name'],
      email: d['email'],
      description: d['description'],
      description_es: d['description_es'],
      status: d['status '],
      category: d['category'],
      subcategory: d['subcategory'],
      created_by: d['created_by'],
      restaurantpic: d['restaurantpic'],
      city: d['city'],
      address: d['address'],
      contact: d['contact'],
      website: d['website'],
      latitude: d['latitude'],
      longitude: d['longitude'],
      avg_cost: d['avg_cost'],
      claimed: d['claimed '],
      min_order_value: d['min_order_value'],
      max_order_value: d['max_order_value'],
      cod: d['cod'],
      stripe_acc: d['stripe_acc'],
      cancel_charge: d['cancel_charge'],
      can_edit_pos: d['can_edit_pos'],
      can_edit_menu: d['can_edit_menu'],
      can_edit_reservation: d['can_edit_reservation'],
      can_edit_order: d['can_edit_order'],
      can_edit_discount: d['can_edit_discount'],
      created_at: d['created_at'],
      ath_acc: d['ath_acc'],
      ath_secret: d['ath_secret'],
      stripe_fee: d['stripe_fee'],
      convenience_fee_type: d['convenience_fee_type'],
      convenience_fee: d['convenience_fee'],
      food_tax: d['food_tax'],
      drink_tax: d['drink_tax'],
      grand_tax: d['grand_tax'],
      delivery_charge: d['delivery_charge'],
      base_delivery_distance: d['base_delivery_distance'],
      driver_fee: d['driver_fee'],
      currency_code: d['currency_code'],
      imagesUploadedInfo: d['imagesUploadedInfo'],
      default_display_language_code: d['default_display_language_code'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'description': description,
        'description_es': description_es,
        'status': status,
        'category': category,
        'subcategory': subcategory,
        'created_by': created_by,
        'restaurantpic': restaurantpic,
        'city': city,
        'address': address,
        'contact': contact,
        'website': website,
        'latitude': latitude,
        'longitude': longitude,
        'avg_cost': avg_cost,
        'claimed ': claimed,
        'min_order_value': min_order_value,
        'max_order_value': max_order_value,
        'cod': cod,
        'stripe_acc': stripe_acc,
        'cancel_charge': cancel_charge,
        'can_edit_pos': can_edit_pos,
        'can_edit_menu': can_edit_menu,
        'can_edit_reservation': can_edit_reservation,
        'can_edit_order': can_edit_order,
        'can_edit_discount': can_edit_discount,
        'created_at': created_at,
        'ath_acc': ath_acc,
        'ath_secret': ath_secret,
        'stripe_fee': stripe_fee,
        'convenience_fee_type': convenience_fee_type,
        'convenience_fee': convenience_fee,
        'food_tax': food_tax,
        'drink_tax': drink_tax,
        'grand_tax': grand_tax,
        'delivery_charge': delivery_charge,
        'base_delivery_distance': base_delivery_distance,
        'driver_fee': driver_fee,
        'currency_code': currency_code,
        'imagesUploadedInfo': imagesUploadedInfo,
        'default_display_language_code': default_display_language_code,
      };
}
