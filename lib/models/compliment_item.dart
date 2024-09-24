class ComplimentItem {
  int? id;
  int? orderId;
  int? cartItemId;
  String? optionName;
  double? optionPrice;
  int? ciId;

  ComplimentItem({
    this.id,
    this.orderId,
    this.cartItemId,
    this.optionName,
    this.optionPrice,
    this.ciId,
  });

  factory ComplimentItem.fromJson(dynamic d) {
    return ComplimentItem(
      id: d['id'],
      orderId: d['orderId'],
      cartItemId: d['cartItemId'],
      optionName: d['option_name'],
      optionPrice: double.parse(d['option_price'].toString()),
      ciId: d['ci_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderId': orderId,
        'cartItemId': cartItemId,
        'option_name': optionName,
        'option_price': optionPrice,
        'ci_id': ciId,
      };
}
