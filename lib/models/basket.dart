class Basket {
  int? minOrderValue;
  int? maxOrderValue;
  String? athAcc;
  int? cod;
  String? resName;
  int? id;
  int? userId;
  int? resId;
  double? foodTax;
  double? drinkTax;
  double? convenienceFee;
  double? subtotal;
  double? tax;
  double? total;
  int? ordered;
  String? createdDate;
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
  double? latitude;
  double? longitude;

  Basket({
    this.minOrderValue,
    this.maxOrderValue,
    this.athAcc,
    this.cod,
    this.resName,
    this.id,
    this.userId,
    this.resId,
    this.foodTax,
    this.drinkTax,
    this.convenienceFee,
    this.subtotal,
    this.tax,
    this.total,
    this.ordered,
    this.createdDate,
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
    this.latitude,
    this.longitude,
  });

  factory Basket.fromJson(dynamic d) {
    return Basket(
      minOrderValue: d['min_order_value'],
      maxOrderValue: d['max_order_value'],
      athAcc: d['ath_acc'],
      cod: d['cod'],
      resName: d['res_name'],
      id: d['id'],
      userId: d['user_id'],
      resId: d['res_id'],
      foodTax: double.tryParse(d['food_tax'].toString()),
      drinkTax: double.tryParse(d['drink_tax'].toString()),
      convenienceFee: double.tryParse(d['convenience_fee'].toString()),
      subtotal: double.tryParse(d['subtotal'].toString()),
      tax: double.tryParse(d['tax'].toString()),
      total: double.tryParse(d['total'].toString()),
      ordered: d['ordered'],
      createdDate: d['created_date'],
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
      latitude: double.tryParse(d['latitude'].toString()),
      longitude: double.tryParse(d['longitude'].toString()),
    );
  }
}
