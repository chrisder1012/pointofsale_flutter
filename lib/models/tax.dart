class Tax {
  int? id;
  String? email;
  String? address;
  String? contact;
  String? city;
  String? foodTax;
  String? drinkTax;
  String? grandTax;
  String? deliveryCharge;
  double? baseDeliveryDistance;
  double? extraDeliveryCharge;
  String? driver_fee;
  String? fb_link;
  String? twitter_link;
  String? insta_link;
  String? created_date;

  Tax({
    this.id,
    this.foodTax,
    this.drinkTax,
    this.grandTax,
    this.deliveryCharge,
    this.baseDeliveryDistance,
    this.extraDeliveryCharge,
    this.address,
    this.city,
    this.contact,
    this.created_date,
    this.driver_fee,
    this.email,
    this.fb_link,
    this.insta_link,
    this.twitter_link,
  });

  factory Tax.fromJson(dynamic d) {
    return Tax(
      id: d['id'],
      email: d['email'],
      address: d['address'],
      contact: d['contact'],
      city: d['city'],
      foodTax: d['food_tax'],
      drinkTax: d['drink_tax'],
      grandTax: d['grand_tax'],
      deliveryCharge: d['delivery_charge'],
      baseDeliveryDistance:
          double.parse(d['base_delivery_distance'].toString()),
      extraDeliveryCharge: d['extra_delivery_charge'],
      driver_fee: d['driver_fee'],
      fb_link: d['fb_link'],
      twitter_link: d['twitter_link'],
      insta_link: d['insta_link'],
      created_date: d['created_date'],
    );
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'address': address,
        'contact': contact,
        'city': city,
        'food_tax': foodTax,
        'drink_tax': drinkTax,
        'grand_tax': grandTax,
        'delivery_charge': deliveryCharge,
        'base_delivery_distance': baseDeliveryDistance,
        'extra_delivery_charge': extraDeliveryCharge,
        'driver_fee': driver_fee,
        'fb_link': fb_link,
        'twitter_link': twitter_link,
        'insta_link': insta_link,
        'created_date': created_date,
      };
}
