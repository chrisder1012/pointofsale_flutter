class RestCustomer {
  int? id;
  String? name;
  String? address1;
  String? address2;
  String? address3;
  String? zipCode;
  String? tel;
  String? email;
  double? expenseAmount;
  int? memberTypeId; // default 0
  double? prepaidAmount; // default 0.0
  double? rewardPoint; // default 0.0
  double? deliveryFee;

  RestCustomer({
    this.id,
    this.name,
    this.address1,
    this.address2,
    this.address3,
    this.zipCode,
    this.tel,
    this.email,
    this.expenseAmount,
    this.memberTypeId = 0,
    this.prepaidAmount = 0.0,
    this.rewardPoint = 0.0,
    this.deliveryFee,
  });

  factory RestCustomer.fromJson(dynamic d) {
    return RestCustomer(
      id: d['id'],
      name: d['name'],
      address1: d['address1'],
      address2: d['address2'],
      address3: d['address3'],
      zipCode: d['zipCode'],
      tel: d['tel'],
      email: d['email'],
      expenseAmount: d['expenseAmount'],
      memberTypeId: d['memberTypeId'],
      prepaidAmount: d['prepaidAmount'],
      rewardPoint: d['rewardPoint'],
      deliveryFee: d['deliveryFee'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address1': address1,
        'address2': address2,
        'address3': address3,
        'zipCode': zipCode,
        'tel': tel,
        'email': email,
        'expenseAmount': expenseAmount,
        'memberTypeId': memberTypeId,
        'prepaidAmount': prepaidAmount,
        'rewardPoint': rewardPoint,
        'deliveryFee': deliveryFee,
      };
}
