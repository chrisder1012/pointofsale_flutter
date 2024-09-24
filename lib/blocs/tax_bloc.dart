import 'package:flutter/cupertino.dart';
import 'package:zabor/models/tax.dart';

import '../api/my_api.dart';

class TaxBloc extends ChangeNotifier {
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  Tax? _tax;
  Tax? get tax => _tax;

  Future getTax() async {
    try {
      var res = await CallApi().getDataWithToken('getTaxs/');
      Map<String, dynamic> body = res.data!;

      if (body['status']) {
        _tax = Tax.fromJson(body['data']);

        _hasError = false;
        notifyListeners();
      } else {
        _hasError = true;
        _errorCode = body['msg'];
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
  }
}
