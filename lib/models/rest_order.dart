class RestOrder {
  int? id;
  int? cartId; ////////////////////
  int? userId;
  int? resId;
  double? foodTax;
  double? drinkTax;
  double? tax;
  double? convienenceFee;
  double? total;
  //double? subtotal;
  int? cod; /////////////////////
  String? orderTime;
  String? endTime;
  int? customerId;
  String? customerName;
  String? orderNum;
  String? invoiceNum;
  int? tableId;
  String? tableName;
  int? tableGroupId;
  int? personNum;
  int? status;
  int? openOrderStatus;
  int? printReceipt;
  String? remark;
  String? waiterName;
  String? cashierName;
  String? cancelReason;
  String? cancelPerson;
  double? minimumCharge;
  double? subTotal;
  double? discountAmt;
  double? serviceAmt;
  double? rounding;
  double? tax1Amt;
  double? tax1TotalAmt;
  String? tax1Name;
  double? tax2Amt;
  double? tax2TotalAmt;
  String? tax2Name;
  double? tax3Amt;
  double? tax3TotalAmt;
  String? tax3Name;
  double? deliveryFee;
  String? serviceFeeName;
  double? servicePercentage;
  String? discountReason;
  double? discountPercentage;
  double? amount;
  int? minimumChargeType;
  double? minimumChargeSet;
  double? processFee;
  double? cashDiscount;
  int? splitType; // default 0
  String? receiptNote;
  int? orderCount; // default 0
  int? receiptPrinterId;
  int? deliveryStatus; // default 0
  String? deliveryTime;
  String? deliveriedTime;
  String? deliveryman;
  String? deliveryArriveDate;
  String? deliveryArriveTime;
  String? customerPhone;
  int? orderType;
  int? orderMemberType;
  String? refundReason;
  int? taxStatus;
  int? customerOrderStatus;
  String? refundTime;
  String? kitchenBarcode;
  int? hasRefund; // default 0
  int? hasVoidItem; // default 0
  int? hasAllItemServed; // default 0
  int? hasAllItemCooked; // default 0
  int? hasCookedItem; // default 0
  int? hasHoldItem; // default 0
  int? hasFiredItem; // default 0
  String? updateTimeStamp;
  int? cashCloseOutId; // default 0
  String? kdsOrderTime;
  String? transactionTime;
  String? transactionReason;

  RestOrder({
    this.id,
    this.cartId,
    this.userId,
    this.resId,
    this.foodTax,
    this.drinkTax,
    this.tax,
    this.convienenceFee,
    this.total,
    this.cod,
    this.orderTime,
    this.endTime,
    this.customerId,
    this.customerName,
    this.orderNum,
    this.invoiceNum,
    this.tableId,
    this.tableName,
    this.tableGroupId,
    this.personNum,
    this.status,
    this.openOrderStatus,
    this.printReceipt,
    this.remark,
    this.waiterName,
    this.cashierName,
    this.cancelReason,
    this.cancelPerson,
    this.minimumCharge,
    this.subTotal,
    this.discountAmt,
    this.serviceAmt,
    this.rounding,
    this.tax1Amt,
    this.tax1TotalAmt,
    this.tax1Name,
    this.tax2Amt,
    this.tax2TotalAmt,
    this.tax2Name,
    this.tax3Amt,
    this.tax3TotalAmt,
    this.tax3Name,
    this.deliveryFee,
    this.serviceFeeName,
    this.servicePercentage,
    this.discountReason,
    this.discountPercentage,
    this.amount,
    this.minimumChargeType,
    this.minimumChargeSet,
    this.processFee,
    this.cashDiscount,
    this.splitType = 0,
    this.receiptNote,
    this.orderCount = 0,
    this.receiptPrinterId,
    this.deliveryStatus = 0,
    this.deliveryTime,
    this.deliveriedTime,
    this.deliveryman,
    this.deliveryArriveDate,
    this.deliveryArriveTime,
    this.customerPhone,
    this.orderType,
    this.orderMemberType,
    this.refundReason,
    this.taxStatus,
    this.customerOrderStatus,
    this.refundTime,
    this.kitchenBarcode,
    this.hasRefund = 0,
    this.hasVoidItem = 0,
    this.hasAllItemServed = 0,
    this.hasAllItemCooked = 0,
    this.hasCookedItem = 0,
    this.hasHoldItem = 0,
    this.hasFiredItem = 0,
    this.updateTimeStamp,
    this.cashCloseOutId = 0,
    this.kdsOrderTime,
    this.transactionTime,
    this.transactionReason,
  });

  factory RestOrder.fromJson(dynamic d) {
    return RestOrder(
      id: d['id'],
      cartId: d['cartId'],
      userId: d['userId'],
      resId: d['resId'],
      foodTax: d['foodTax'],
      drinkTax: d['drinkTax'],
      tax: d['tax'],
      convienenceFee: d['convienenceFee'],
      total: d['total'],
      cod: d['cod'],
      orderTime: d['orderTime'],
      endTime: d['endTime'],
      customerId: d['customerId'],
      customerName: d['customerName'],
      orderNum: d['orderNum'],
      invoiceNum: d['invoiceNum'],
      tableId: d['tableId'],
      tableName: d['tableName'],
      tableGroupId: d['tableGroupId'],
      personNum: d['personNum'],
      status: d['status'],
      openOrderStatus: d['openOrderStatus'],
      printReceipt: d['printReceipt'],
      remark: d['remark'],
      waiterName: d['waiterName'],
      cashierName: d['cashierName'],
      cancelReason: d['cancelReason'],
      cancelPerson: d['cancelPerson'],
      minimumCharge: d['minimumCharge'],
      subTotal: d['subTotal'],
      discountAmt: d['discountAmt'],
      serviceAmt: d['serviceAmt'],
      rounding: d['rounding'],
      tax1Amt: d['tax1Amt'],
      tax1TotalAmt: d['tax1TotalAmt'],
      tax1Name: d['tax1Name'],
      tax2Amt: d['tax2Amt'],
      tax2TotalAmt: d['tax2TotalAmt'],
      tax2Name: d['tax2Name'],
      tax3Amt: d['tax3Amt'],
      tax3TotalAmt: d['tax3TotalAmt'],
      tax3Name: d['tax3Name'],
      deliveryFee: d['deliveryFee'],
      serviceFeeName: d['serviceFeeName'],
      servicePercentage: d['servicePercentage'],
      discountReason: d['discountReason'],
      discountPercentage: d['discountPercentage'],
      amount: d['amount'],
      minimumChargeType: d['minimumChargeType'],
      minimumChargeSet: d['minimumChargeSet'],
      processFee: d['processFee'],
      cashDiscount: d['cashDiscount'],
      splitType: d['splitType'],
      receiptNote: d['receiptNote'],
      orderCount: d['orderCount'],
      receiptPrinterId: d['receiptPrinterId'],
      deliveryStatus: d['deliveryStatus'],
      deliveryTime: d['deliveryTime'],
      deliveriedTime: d['deliveriedTime'],
      deliveryman: d['deliveryman'],
      deliveryArriveDate: d['deliveryArriveDate'],
      deliveryArriveTime: d['deliveryArriveTime'],
      customerPhone: d['customerPhone'],
      orderType: d['orderType'],
      orderMemberType: d['orderMemberType'],
      refundReason: d['refundReason'],
      taxStatus: d['taxStatus'],
      customerOrderStatus: d['customerOrderStatus'],
      refundTime: d['refundTime'],
      kitchenBarcode: d['kitchenBarcode'],
      hasRefund: d['hasRefund'],
      hasVoidItem: d['hasVoidItem'],
      hasAllItemServed: d['hasAllItemServed'],
      hasAllItemCooked: d['hasAllItemCooked'],
      hasCookedItem: d['hasCookedItem'],
      hasHoldItem: d['hasHoldItem'],
      hasFiredItem: d['hasFiredItem'],
      updateTimeStamp: d['updateTimeStamp'],
      cashCloseOutId: d['cashCloseOutId'],
      kdsOrderTime: d['kdsOrderTime'],
      transactionTime: d['transactionTime'],
      transactionReason: d['transactionReason'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'cartId': cartId,
        'userId': userId,
        'resId': resId,
        'foodTax': foodTax,
        'drinkTax': drinkTax,
        'tax': tax,
        'convienenceFee': convienenceFee,
        'total': total,
        'cod': cod,
        'orderTime': orderTime,
        'endTime': endTime,
        'customerId': customerId,
        'customerName': customerName,
        'orderNum': orderNum,
        'invoiceNum': invoiceNum,
        'tableId': tableId,
        'tableName': tableName,
        'tableGroupId': tableGroupId,
        'personNum': personNum,
        'status': status,
        'openOrderStatus': openOrderStatus,
        'printReceipt': printReceipt,
        'remark': remark,
        'waiterName': waiterName,
        'cashierName': cashierName,
        'cancelReason': cancelReason,
        'cancelPerson': cancelPerson,
        'minimumCharge': minimumCharge,
        'subTotal': subTotal,
        'discountAmt': discountAmt,
        'serviceAmt': serviceAmt,
        'rounding': rounding,
        'tax1Amt': tax1Amt,
        'tax1TotalAmt': tax1TotalAmt,
        'tax1Name': tax1Name,
        'tax2Amt': tax2Amt,
        'tax2TotalAmt': tax2TotalAmt,
        'tax2Name': tax2Name,
        'tax3Amt': tax3Amt,
        'tax3TotalAmt': tax3TotalAmt,
        'tax3Name': tax3Name,
        'deliveryFee': deliveryFee,
        'serviceFeeName': serviceFeeName,
        'servicePercentage': servicePercentage,
        'discountReason': discountReason,
        'discountPercentage': discountPercentage,
        'amount': amount,
        'minimumChargeType': minimumChargeType,
        'minimumChargeSet': minimumChargeSet,
        'processFee': processFee,
        'cashDiscount': cashDiscount,
        'splitType': splitType,
        'receiptNote': receiptNote,
        'orderCount': orderCount,
        'receiptPrinterId': receiptPrinterId,
        'deliveryStatus': deliveryStatus,
        'deliveryTime': deliveryTime,
        'deliveriedTime': deliveriedTime,
        'deliveryman': deliveryman,
        'deliveryArriveDate': deliveryArriveDate,
        'deliveryArriveTime': deliveryArriveTime,
        'customerPhone': customerPhone,
        'orderType': orderType,
        'orderMemberType': orderMemberType,
        'refundReason': refundReason,
        'taxStatus': taxStatus,
        'customerOrderStatus': customerOrderStatus,
        'refundTime': refundTime,
        'kitchenBarcode': kitchenBarcode,
        'hasRefund': hasRefund,
        'hasVoidItem': hasVoidItem,
        'hasAllItemServed': hasAllItemServed,
        'hasAllItemCooked': hasAllItemCooked,
        'hasCookedItem': hasCookedItem,
        'hasHoldItem': hasHoldItem,
        'hasFiredItem': hasFiredItem,
        'updateTimeStamp': updateTimeStamp,
        'cashCloseOutId': cashCloseOutId,
        'kdsOrderTime': kdsOrderTime,
        'transactionTime': transactionTime,
        'transactionReason': transactionReason,
      };
}
