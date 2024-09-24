class RestDiscount {
  int? id;
  String? reason;
  int? isPercentage;
  double? amount;

  RestDiscount({
    this.id,
    this.reason,
    this.isPercentage,
    this.amount,
  });

  factory RestDiscount.fromJson(dynamic d) {
    return RestDiscount(
      id: d['id'],
      reason: d['reason'],
      isPercentage: d['isPercentage'],
      amount: d['amount'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reason': reason,
        'isPercentage': isPercentage,
        'amount': amount,
      };
}
