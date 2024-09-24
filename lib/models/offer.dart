class Offer {
  int? id;
  int? resId;
  String? userType;
  int? percentage;
  int? moa;
  int? mpd;
  String? disCondition;
  DateTime? createdAt;

  Offer({
    this.id,
    this.resId,
    this.userType,
    this.percentage,
    this.moa,
    this.mpd,
    this.disCondition,
    this.createdAt,
  });

  factory Offer.fromJson(dynamic d) {
    return Offer(
      id: d['id'],
      resId: d['res_id'],
      userType: d['user_type'],
      percentage: d['percentage'],
      moa: d['moa'],
      mpd: d['mpd'],
      disCondition: d['dis_condition'],
      createdAt: DateTime.parse(d["created_at"]),
    );
  }
}
