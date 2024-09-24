import 'package:flutter/cupertino.dart';

import '../api/my_api.dart';

class PrinterBloc extends ChangeNotifier {
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _msg;
  String? get msg => _msg;

  String? _errorCode;
  String? get errorCode => _errorCode;

  Future savePrinters(
      int resId,
      String printName2,
      String printIp2,
      String printName3,
      String printIp3,
      String printName4,
      String printIp4,
      String printName5,
      String printIp5,
      String printName6,
      String printIp6,
      String printName7,
      String printIp7) async {
    try {
      var data = {
        'resId': resId,
        'printer_2_name': printName2,
        'printer_2_ipaddress': printIp2,
        'printer_3_name': printName3,
        'printer_3_ipaddress': printIp3,
        'printer_4_name': printName4,
        'printer_4_ipaddress': printIp4,
        'printer_5_name': printName5,
        'printer_5_ipaddress': printIp5,
        'printer_6_name': printName6,
        'printer_6_ipaddress': printIp6,
        'printer_7_name': printName7,
        'printer_7_ipaddress': printIp7,
      };
      var res = await CallApi().postGetDataWithToken(data, 'savePrinters');
      Map<String, dynamic> body = res.data!;

      if (res.statusCode == 200) {
        if (body['status']) {
          _hasError = false;
          _msg = body['message'];
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
