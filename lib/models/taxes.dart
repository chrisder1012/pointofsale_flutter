class Taxes {
  String? foodTax;
  String? drinkTax;
  String? grandTax;

  Taxes({
    this.foodTax,
    this.drinkTax,
    this.grandTax,
  });

  factory Taxes.fromJson(dynamic d) {
    return Taxes(
      foodTax: d['food_tax'],
      drinkTax: d['drink_tax'],
      grandTax: d['grand_tax'],
    );
  }
}
