class RestOrderPayment {
  int? id;
  int? orderId;
  String? table;
  String? items;
  double? amount;
  int? paymentType;
  String? time;

  RestOrderPayment({
    this.id,
    this.orderId,
    this.table,
    this.items,
    this.amount,
    this.paymentType,
    this.time,
  });

  factory RestOrderPayment.fromJson(dynamic d) {
    return RestOrderPayment(
      id: d['id'],
      orderId: d['order_id'],
      items: d['items'],
      paymentType: d['payment_type'],
      amount: d['amount'],
      table: d['table_name'],
      time: d['time'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_id': orderId,
        'items': items,
        'payment_type': paymentType,
        'amount': amount,
        'table_name': table,
        'time': time,
      };
}
