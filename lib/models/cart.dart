import 'dart:convert';

import 'item.dart';

class Cart {
  int? id;
  int? userId;
  int? resId;
  List<Item>? cart;
  double? foodTax;
  double? drinkTax;
  double? grandTax;
  double? tax;
  double? convienienceFee;
  double? total;
  double? subtotal;
  int? cod;
  int? ordered;
  int? tableId;
  String? createdAt;

  double get totalTax => foodTax! + drinkTax! + tax!;

  Cart({
    this.id,
    this.userId,
    this.resId,
    this.cart,
    this.foodTax,
    this.drinkTax,
    this.tax,
    this.convienienceFee,
    this.total,
    this.subtotal,
    this.cod,
    this.ordered,
    this.createdAt,
    this.tableId,
    this.grandTax,
  });

  factory Cart.fromJson(dynamic d) {
    List<dynamic> snap = json.decode(d['cart']);
    List<Item> items = List<Item>.from(snap.map((e) => Item.fromJson2(e)));

    return Cart(
      id: d['id'],
      userId: d['user_id'],
      resId: d['res_id'],
      cart: items,
      foodTax: d['food_tax'].toDouble(),
      drinkTax: d['drink_tax'].toDouble(),
      convienienceFee: d['convenience_fee'].toDouble(),
      tax: d['tax'].toDouble(),
      total: d['total'].toDouble(),
      subtotal: d['sub_total'].toDouble(),
      cod: d['cod'],
      ordered: d['ordered'],
      tableId: d['table_id'],
      createdAt: d['created_at'],
      grandTax: d['grand_tax'] == null ? 0.0 : d['grand_tax'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'res_id': resId,
        'cart': cart == null
            ? null
            : List<dynamic>.from(cart!.map((e) => e.toJson())),
        'food_tax': foodTax,
        'drink_tax': drinkTax,
        'tax': tax,
        'total': total,
        'sub_total': subtotal,
        // 'cod': cod,
        'convenience_fee': convienienceFee,
        // 'ordered': ordered,
        'table_id': tableId,
        'created_at': createdAt,
        // 'grand_tax': grandTax,
      };
}
