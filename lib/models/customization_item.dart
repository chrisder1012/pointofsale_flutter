class CustomizationItem {
  // int? id;
  String? optionName;
  double? optionPrice;
  int? optionId;

  CustomizationItem({
    // this.id,
    this.optionName,
    this.optionPrice,
    this.optionId,
  });

  factory CustomizationItem.fromJson(dynamic d) {
    return CustomizationItem(
      // id: d['id'],
      optionName: d['option_name'],
      optionPrice: double.parse(d['option_price'].toString()),
      optionId: d['ci_id'],
    );
  }

  factory CustomizationItem.fromJson2(dynamic d) {
    return CustomizationItem(
      // id: d['id'],
      optionName: d['option_name'],
      optionPrice: double.parse(d['option_price'].toString()),
      optionId: d['option_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        // 'id': id,
        'option_id': optionId,
        'option_name': optionName,
        'option_price': optionPrice,
      };
}
