class RestMemberType {
  int? id;
  String? name;
  int? discountId;
  int? memberPriceId;
  bool? isPrepaid;
  bool? isReward;
  double? rewardPointUnit;

  RestMemberType({
    this.id,
    this.name,
    this.discountId,
    this.memberPriceId,
    this.isPrepaid,
    this.isReward,
    this.rewardPointUnit,
  });

  factory RestMemberType.fromJson(dynamic d) {
    return RestMemberType(
      id: d['id'],
      name: d['name'],
      discountId: d['discountId'],
      memberPriceId: d['memberPriceId'],
      isPrepaid: d['isPrepaid'],
      isReward: d['isReward'],
      rewardPointUnit: d['rewardPointUnit'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'discountId': discountId,
        'memberPriceId': memberPriceId,
        'isPrepaid': isPrepaid,
        'isReward': isReward,
        'rewardPointUnit': rewardPointUnit,
      };
}
