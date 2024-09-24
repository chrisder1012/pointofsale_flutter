class PettyCashCloseModel {
  int? id;
  String nameClose;
  double valueEnClose;
  double valueCoClose;
  int quantityClose;


  double get totalEnClose =>quantityClose * valueEnClose;
  double get totalCoClose =>quantityClose * valueCoClose;


  PettyCashCloseModel(
    this.id,
    this.nameClose,
    this.valueEnClose,
    this.valueCoClose,
    this.quantityClose,
  );

  Map<String, dynamic> toMap() => {
    'id': (id == 0) ? null : id,
    'nameClose': nameClose,
    'valueEnClose': valueEnClose,
    'valueCoClose': valueCoClose,
    'quantityClose': quantityClose,
  };

  /*
  factory PettyCashCloseModel.fromJson(dynamic d) {
    return PettyCashCloseModel(
      id: d['id'],
      nameClose: d['name_close'],
      quantityClose: d['quantity_close'],
      valueEnClose: d['valueEn_close'],
      valueCoClose: d['valueCo_close'],
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'name_close': nameClose,
        'quantity_close': quantityClose,
        'valueEn_close': valueEnClose,
        'valueCo_close': valueCoClose,
      };
      */
}
