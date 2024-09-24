import 'package:zabor/models/rest_discount.dart';

import 'database_handler.dart';

Future<int> addRestDiscount() async {
  var dbHandler = DatabaseHandler();

  var discount1 = RestDiscount(
    reason: 'VIP',
    isPercentage: 1,
    amount: 25.0,
  );
  var discount2 = RestDiscount(
    reason: 'Coupon 5',
    isPercentage: 0,
    amount: 5.0,
  );
  var discount3 = RestDiscount(
    reason: 'Coupon 10',
    isPercentage: 0,
    amount: 10.0,
  );
  var discount4 = RestDiscount(
    reason: 'Coupon 15',
    isPercentage: 0,
    amount: 15.0,
  );
  var discount5 = RestDiscount(
    reason: 'Happy hour',
    isPercentage: 1,
    amount: 30.0,
  );

  List<RestDiscount> rds = [
    discount1,
    discount2,
    discount3,
    discount4,
    discount5
  ];
  return await dbHandler.insertRestDiscount(rds);
}
