import 'package:zabor/models/customization_item.dart';

class Item {
  // int? id;
  int? itemId;
  String? itemName;
  double? itemPrice;
  List<CustomizationItem>? customization;
  // String? customizations;
  int? quantity;
  String? taxtype;
  String? note;
  double? taxvalue;
  // int? itemQuantity;
  // String? itemPic;
  // String? itemDes;
  bool? isShow;
  bool? isFood;
  bool? isState;
  bool? isCity;
  bool? isNote;
  int? print2;
  int? print3;
  int? print4;
  int? print5;
  int? print6;
  int? print7;

  Item({
    this.itemId,
    this.itemName,
    this.itemPrice,
    // this.customizations,
    this.taxtype,
    // this.itemQuantity,
    // this.itemPic,
    // this.itemDes,
    this.isShow,
    this.isFood,
    this.isState,
    this.isCity,
    this.isNote,
    this.note,
    this.quantity,
    this.taxvalue,
    this.customization,
    this.print2,
    this.print3,
    this.print4,
    this.print5,
    this.print6,
    this.print7,
  });

  factory Item.fromJson(dynamic d) {
    return Item(
      itemId: d['item_id'],
      itemName: d['item_name'],
      itemPrice: d['item_price'],
      // customizations: d['customizations'],
      customization: d["customization"] == null
          ? null
          : List<CustomizationItem>.from(
              d["customization"].map((x) => CustomizationItem.fromJson(x))),
      taxtype: d['taxtype'],
      // itemQuantity: d['item_quantity'],
      // itemPic: d['item_pic'],
      // itemDes: d['item_des'],
      isShow: d['is_show'],
      isFood: d['is_food'],
      isState: d['is_state'],
      isCity: d['is_city'],
      isNote: d['is_note'],
      print2: d['printer_2'],
      print3: d['printer_3'],
      print4: d['printer_4'],
      print5: d['printer_5'],
      print6: d['printer_6'],
      print7: d['printer_7'],
    );
  }

  factory Item.fromJson2(dynamic d) {
    return Item(
      itemId: d['itemId'],
      itemName: d['itemName'],
      itemPrice: d['itemPrice'].toDouble(),
      // customizations: d['customizations'],
      customization: d["customization"] == null
          ? null
          : List<CustomizationItem>.from(
              d["customization"].map((x) => CustomizationItem.fromJson2(x))),
      taxtype: d['taxtype'],
      taxvalue: d['taxvalue'] == null ? null : d['taxvalue'].toDouble(),
      quantity: d['quantity'],
      note: d['note'],
      // itemQuantity: d['item_quantity'],
      // itemPic: d['item_pic'],
      // itemDes: d['item_des'],
      isShow: d['is_show'],
      isFood: d['is_food'],
      isState: d['is_state'],
      isCity: d['is_city'],
      isNote: d['is_note'],
      print2: d['printer_2'],
      print3: d['printer_3'],
      print4: d['printer_4'],
      print5: d['printer_5'],
      print6: d['printer_6'],
      print7: d['printer_7'],
    );
  }

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'itemName': itemName,
        'itemPrice': itemPrice,
        // 'customizations': customizations,
        "customization": customization == null
            ? null
            : List<dynamic>.from(customization!.map((x) => x.toJson())),
        'quantity': quantity,
        'taxtype': taxtype,
        'taxvalue': taxvalue,
        'note': note,
        // 'item_quantity': itemQuantity,
        // 'item_pic': itemPic,
        // 'item_des': itemDes,
        'is_city': isCity,
        'is_state': isState,
        'is_food': isFood,
        'is_note': isNote,
        // 'is_show': is_show,
        'printer_2': print2,
        'printer_3': print3,
        'printer_4': print4,
        'printer_5': print5,
        'printer_6': print6,
        'printer_7': print7,
      };
}
