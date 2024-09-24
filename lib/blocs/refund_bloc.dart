import 'package:flutter/cupertino.dart';

import '../api/my_api.dart';

class RefundBloc extends ChangeNotifier {
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _message;
  String? get message => _message;

  Future refund(int resId, int cashierId, int shiftId, String reason,
      String refundMethod, int orderNumber, int amount) async {
    try {
      var data = {
        'resId': resId,
        'cashierId': cashierId,
        'shiftId': shiftId,
        'reason': reason,
        'order_number': orderNumber,
        'amount': amount,
        'refund_method': "CASH",
      };
      var res = await CallApi().postGetDataWithToken(data, 'refund');
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
