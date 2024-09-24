import 'package:zabor/models/rest_member_type.dart';

import 'database_handler.dart';

Future<int> addRestMemberType() async {
  var dbHandler = DatabaseHandler();

  var membertype1 = RestMemberType(
    name: 'Reward Card',
    discountId: 0,
    memberPriceId: 0,
    isPrepaid: false,
    isReward: true,
    rewardPointUnit: 5.0,
  );
  var membertype2 = RestMemberType(
    name: 'Discount Card',
    discountId: 1,
    memberPriceId: 0,
    isPrepaid: false,
    isReward: false,
    rewardPointUnit: 1.0,
  );
  var membertype3 = RestMemberType(
    name: 'Member Card',
    discountId: 0,
    memberPriceId: 1,
    isPrepaid: false,
    isReward: false,
    rewardPointUnit: 1.0,
  );

  List<RestMemberType> rmts = [membertype1, membertype2, membertype3];
  return await dbHandler.insertRestMemberType(rmts);
}
