import 'package:flutter/cupertino.dart';
import 'package:zabor/models/basket.dart';

import '../api/my_api.dart';

class BasketBloc extends ChangeNotifier {
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  Basket? _basket;
  Basket? get basket => _basket;

  Future getBasket(var userId) async {
    try {
      var res = await CallApi().getDataWithToken('getcart/?user_id=$userId');
      Map<String, dynamic> body = res.data!;

      if (res.statusCode == 200) {
        if (body['status']) {
          _basket = Basket.fromJson(body['data']);
          _hasError = false;
          notifyListeners();
        } else {
          _hasError = true;
          _errorCode = body['msg'];
          notifyListeners();
        }
      } else if (res.statusCode == 401) {
        _hasError = true;
        _errorCode = body['message'];
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
  }
}
