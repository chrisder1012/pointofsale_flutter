
class PettyCashModel {
  int? id;
  String name;
  double valueEn;
  double valueCo;
  int quantity;
  //bool isEn = true;

  double get totalEn => quantity * valueEn;
  double get totalCo => quantity * valueCo;


  PettyCashModel(
    this.id,
    this.name,
    this.valueEn,
    this.valueCo,
    this.quantity,
  );

  /*factory PettyCashModel.fromJson(dynamic d) {
    return PettyCashModel(
      id: d['id'],
      name: d['name'],
      quantity: d['quantity'],
      valueEn: d['valueEn'],
      valueCo: d['valueCo'],
    );
  }*/

  /*Map<String, dynamic> toJson() =>
      {
        'id': id,
        'name': name,
        'quantity': quantity,
        'valueEn': valueEn,
        'valueCo': valueCo,
        };*/
   Map<String, dynamic> toMap() => {
     'id': (id == 0) ? null : id,
     'name': name,
     'valueEn': valueEn,
     'valueCo': valueCo,
     'quantity': quantity,
   };



}