import 'package:flutter/cupertino.dart';

import '../api/my_api.dart';

class PayoutBloc extends ChangeNotifier {
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _message;
  String? get message => _message;

  Future payout(int resId, int cashierId, int shiftId, String description,
      String payoutTo, int amount) async {
    try {
      var data = {
        'resId': resId,
        'cashierId': cashierId,
        'shiftId': shiftId,
        'description': description,
        'payout_to': payoutTo,
        'amount': amount,
        'payout_type': "Wage Advance",
      };
      var res = await CallApi().postGetDataWithToken(data, 'payout');
      Map<String, dynamic> body = res.data!;

      if (res.statusCode == 200) {
        if (body['status']) {
          _hasError = false;
        } else {
          _hasError = true;
        }
        _message = body['message'];
        notifyListeners();
      } else if (res.statusCode == 401) {
        _hasError = true;
        _message = body['message'];
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      _message = 'Something went wrong';
      notifyListeners();
    }
  }
}
