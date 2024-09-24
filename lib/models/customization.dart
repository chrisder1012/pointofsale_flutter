import 'package:zabor/models/customization_item.dart';

class Customization {
  String? name;
  int? cusid;
  int? max;
  List<CustomizationItem>? items;

  Customization({
    this.name,
    this.cusid,
    this.max,
    this.items,
  });

  factory Customization.fromJson(dynamic d) {
    List<CustomizationItem>? items;
    if (d['items'] != null) {
      List<dynamic> snap = [];
      snap.addAll(d['items']);
      items = snap.map((e) => CustomizationItem.fromJson(e)).toList();
    }
    return Customization(
        name: d['name'], cusid: d['cusid'], max: d['max'], items: items);
  }
}
