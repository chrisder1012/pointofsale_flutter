class MItem {
  int? id;
  int? itemId;
  String? itemName;
  double? itemPrice;
  String? customizations;
  String? taxtype;
  int? itemQuantity;
  String? itemPic;
  String? itemDes;
  bool? isShow;
  bool? isFood;
  bool? isState;
  bool? isCity;
  bool? isNote;
  String? upcNo;
  int? print2;
  int? print3;
  int? print4;
  int? print5;
  int? print6;
  int? print7;

  MItem({
    this.id,
    this.itemId,
    this.itemName,
    this.itemPrice,
    this.customizations,
    this.taxtype,
    this.itemQuantity,
    this.itemPic,
    this.itemDes,
    this.isShow,
    this.isFood,
    this.isState,
    this.isCity,
    this.isNote,
    this.upcNo,
    this.print2,
    this.print3,
    this.print4,
    this.print5,
    this.print6,
    this.print7,
  });

  factory MItem.fromJson(dynamic d) {
    return MItem(
      id: d['id'],
      itemId: d['item_id'],
      itemName: d['item_name'],
      itemPrice: double.parse(d['item_price'].toString()),
      customizations: d['customizations'],
      taxtype: d['taxtype'],
      itemQuantity: d['item_quantity'],
      itemPic: d['item_pic'],
      itemDes: d['item_des'],
      isShow: d['is_show'],
      isFood: d['is_food'],
      isState: d['is_state'],
      isCity: d['is_city'],
      isNote: d['is_note'],
      upcNo: d['upc_no'],
      print2: d['printer_2'],
      print3: d['printer_3'],
      print4: d['printer_4'],
      print5: d['printer_5'],
      print6: d['printer_6'],
      print7: d['printer_7'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'item_id': itemId,
        'item_name': itemName,
        'item_price': itemPrice,
        'customizations': customizations,
        'item_quantity': itemQuantity,
        'item_pic': itemPic,
        'item_des': itemDes,
        'is_show': isShow,
        'is_food': isFood,
        'is_state': isState,
        'is_city': isCity,
        'is_note': isNote,
        'upc_no': upcNo,
        'printer_2': print2,
        'printer_3': print3,
        'printer_4': print4,
        'printer_5': print5,
        'printer_6': print6,
        'printer_7': print7,
      };
}
