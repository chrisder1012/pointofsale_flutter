class Order {
  int? id;
  int? userId;
  int? resId;
  int? cartId;
  String? orderHash;
  String? cart;
  double? foodTax;
  double? drinkTax;
  double? subtotal;
  double? tax;
  double? deliveryCharge;
  double? total;
  double? discount;
  double? withoutDiscount;
  String? delieverydate;
  String? timeSlots;
  int? orderCode;
  int? codeVerified;
  int? deliveryMode;
  String? deliveredBy;
  int? paymentMode;
  String? status;
  int? paymentStatus;
  String? paymentData;
  String? orderBy;
  String? cookingTime;
  String? orderissue;
  String? cancelledBy;
  String? createdDate;
  int? tbNum;
  double? convenienceFee;
  String? email;
  int? shiftId;
  int? invoiceNumber;

  Order({
    this.id,
    this.userId,
    this.resId,
    this.cartId,
    this.orderHash,
    this.cart,
    this.foodTax,
    this.drinkTax,
    this.subtotal,
    this.tax,
    this.deliveryCharge,
    this.total,
    this.discount,
    this.withoutDiscount,
    this.delieverydate,
    this.timeSlots,
    this.orderCode,
    this.codeVerified,
    this.deliveryMode,
    this.deliveredBy,
    this.paymentMode,
    this.status,
    this.paymentStatus,
    this.paymentData,
    this.orderBy,
    this.cookingTime,
    this.orderissue,
    this.cancelledBy,
    this.createdDate,
    this.tbNum,
    this.convenienceFee,
    this.email,
    this.shiftId,
    this.invoiceNumber,
  });

  factory Order.fromJson(dynamic d) {
    return Order(
      id: d['id'],
      userId: d['user_id'],
      resId: d['res_id'],
      cartId: d['cart_id'],
      orderHash: d['order_hash'],
      cart: d['cart'],
      foodTax: double.parse(d['food_tax'].toString()),
      drinkTax: double.parse(d['drink_tax'].toString()),
      subtotal: double.parse(d['subtotal'].toString()),
      tax: double.parse(d['tax'].toString()),
      deliveryCharge: double.parse(d['delivery_charge'].toString()),
      total: double.parse(d['total'].toString()),
      discount: double.parse(d['discount'].toString()),
      withoutDiscount: double.parse(d['without_discount'].toString()),
      delieverydate: d['delieverydate'],
      timeSlots: d['timeSlots'],
      orderCode: d['order_code'],
      codeVerified: d['code_verified'],
      deliveryMode: d['delivery_mode'],
      deliveredBy: d['delivered_by'],
      paymentMode: d['payment_mode'],
      status: d['status'],
      paymentStatus: d['payment_status'],
      paymentData: d['payment_data'],
      orderBy: d['order_by'],
      cookingTime: d['cooking_time'],
      orderissue: d['orderissue'],
      cancelledBy: d['cancelled_by'],
      createdDate: d['created_date'],
      tbNum: d['tb_num'],
      convenienceFee: double.parse(d['convenience_fee'].toString()),
      email: d['email'],
      shiftId: d['shift_id'],
      invoiceNumber: int.parse(d['invoice_number']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'res_id': resId,
        'cart_id': cartId,
        'order_hash': orderHash,
        'cart': cart,
        'food_tax': foodTax,
        'drink_tax': drinkTax,
        'subtotal': subtotal,
        'tax': tax,
        'delivery_charge': deliveryCharge,
        'total': total,
        'discount': discount,
        'without_discount': withoutDiscount,
        'delieverydate': delieverydate,
        'timeSlots': timeSlots,
        'order_code': orderCode,
        'code_verified': codeVerified,
        'delivery_mode': deliveryMode,
        'delivered_by': deliveredBy,
        'payment_mode': paymentMode,
        'status': status,
        'payment_status': paymentStatus,
        'payment_data': paymentData,
        'order_by': orderBy,
        'cooking_time': cookingTime,
        'orderissue': orderissue,
        'cancelled_by': cancelledBy,
        'created_date': createdDate,
        'tb_num': tbNum,
        'convenience_fee': convenienceFee,
        'email': email,
        'shift_id': shiftId,
        'invoice_number': invoiceNumber.toString(),
      };
}
