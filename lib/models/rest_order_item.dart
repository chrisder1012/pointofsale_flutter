class RestOrderItem {
  int? id;
  // String? customizations; ///////////////
  String? taxtype;
  // int? itemQuantity;
  // String? itemPic;
  // String? itemDes;
  bool? isShow;
  bool? isFood;
  bool? isState;
  bool? isCity;
  bool? isNote;
  String? note;
  int? quantity;
  double? taxvalue; ///////////////
  int? orderId;
  int? billId; // default 0
  String? departmentName;
  String? categoryName;
  int? categorySequence;
  int? itemId;
  String? itemName;
  String? kitchenItemName;
  double? price;
  double? cost; // default 0
  double? qty;
  String? remark;
  String? orderTime;
  String? endTime;
  String? cancelReason;
  int? status;
  int? discountable; // default 1
  double? discountAmt;
  double? discountPercentage;
  String? discountName;
  int? discountType; // default 0
  int? isGift;
  double? giftRewardPoint;
  String? kitchenBarcode;
  int? localPrinter; // default 0
  String? printerIds;
  String? printSeparate;
  int? sequence;
  String? unit;
  int? courseId;
  String? courseName;
  String? staffName;

  RestOrderItem({
    this.id,
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
    this.orderId,
    this.billId = 0,
    this.departmentName,
    this.categoryName,
    this.categorySequence,
    this.itemId,
    this.itemName,
    this.kitchenItemName,
    this.price,
    this.cost = 0,
    this.qty,
    this.remark,
    this.orderTime,
    this.endTime,
    this.cancelReason,
    this.status,
    this.discountable = 1,
    this.discountAmt,
    this.discountPercentage,
    this.discountName,
    this.discountType = 0,
    this.isGift,
    this.giftRewardPoint,
    this.kitchenBarcode,
    this.localPrinter = 0,
    this.printerIds,
    this.printSeparate,
    this.sequence,
    this.unit,
    this.courseId,
    this.courseName,
    this.staffName,
  });

  factory RestOrderItem.fromJson(dynamic d) {
    return RestOrderItem(
      id: d['id'],
      // customizations: d['customizations'],
      taxtype: d['taxtype'],
      // itemQuantity: d['itemQuantity'],
      // itemPic: d['itemPic'],
      // itemDes: d['itemDes'],
      isShow: d['isShow'] == 1 ? true : false,
      isFood: d['isFood'] == 1 ? true : false,
      isState: d['isState'] == 1 ? true : false,
      isCity: d['isCity'] == 1 ? true : false,
      isNote: d['isNote'] == 1 ? true : false,
      note: d['note'],
      quantity: d['quantity'],
      taxvalue: d['taxvalue'],
      orderId: d['orderId'],
      billId: d['billId'],
      departmentName: d['departmentName'],
      categoryName: d['categoryName'],
      categorySequence: d['categorySequence'],
      itemId: d['itemId'],
      itemName: d['itemName'],
      kitchenItemName: d['kitchenItemName'],
      price: d['price'],
      cost: d['cost'],
      qty: d['qty'],
      remark: d['remark'],
      orderTime: d['orderTime'],
      endTime: d['endTime'],
      cancelReason: d['cancelReason'],
      status: d['status'],
      discountable: d['discountable'],
      discountAmt: d['discountAmt'],
      discountPercentage: d['discountPercentage'],
      discountName: d['discountName'],
      discountType: d['discountType'],
      isGift: d['isGift'],
      giftRewardPoint: d['giftRewardPoint'],
      kitchenBarcode: d['kitchenBarcode'],
      localPrinter: d['localPrinter'],
      printerIds: d['printerIds'],
      printSeparate: d['printSeparate'],
      sequence: d['sequence'],
      unit: d['unit'],
      courseId: d['courseId'],
      courseName: d['courseName'],
      staffName: d['staffName'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        // 'customizations': customizations,
        'taxtype': taxtype,
        // 'itemQuantity': itemQuantity,
        // 'itemPic': itemPic,
        // 'itemDes': itemDes,
        'isShow': isShow,
        'isFood': isFood,
        'isState': isState,
        'isCity': isCity,
        'isNote': isNote,
        'note': note,
        'quantity': quantity,
        'taxvalue': taxvalue,
        'orderId': orderId,
        'billId': billId,
        'departmentName': departmentName,
        'categoryName': categoryName,
        'categorySequence': categorySequence,
        'itemId': itemId,
        'itemName': itemName,
        'kitchenItemName': kitchenItemName,
        'price': price,
        'cost': cost,
        'qty': qty,
        'remark': remark,
        'orderTime': orderTime,
        'endTime': endTime,
        'cancelReason': cancelReason,
        'status': status,
        'discountable': discountable,
        'discountAmt': discountAmt,
        'discountPercentage': discountPercentage,
        'discountName': discountName,
        'discountType': discountType,
        'isGift': isGift,
        'giftRewardPoint': giftRewardPoint,
        'kitchenBarcode': kitchenBarcode,
        'localPrinter': localPrinter,
        'printerIds': printerIds,
        'printSeparate': printSeparate,
        'sequence': sequence,
        'unit': unit,
        'courseId': courseId,
        'courseName': courseName,
        'staffName': staffName,
      };
}
