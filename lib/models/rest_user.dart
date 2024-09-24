class RestUser {
  int? id;
  String? account;
  String? password;
  int? role;
  double? hourlyPay;

  RestUser({
    this.id,
    this.account,
    this.password,
    this.role,
    this.hourlyPay,
  });

  factory RestUser.fromJson(dynamic d) {
    return RestUser(
      id: d['id'],
      account: d['account'],
      password: d['password'],
      role: d['role'],
      hourlyPay: d['hourlyPay'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'account': account,
        'password': password,
        'role': role,
        'hourlyPay': hourlyPay,
      };
}
