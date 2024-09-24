import 'package:flutter/cupertino.dart';

import '../api/my_api.dart';

class DejavooTerminalBloc extends ChangeNotifier {
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _message;
  String? get message => _message;

  Future linkDevice(String deviceName, String tpn, int resId) async {
    try {
      var data = {
        'device_name': deviceName,
        'tpn': tpn,
        'res_id': resId,
      };
      var res = await CallApi()
          .postGetDataWithToken(data, 'link-device-magicpay-terminal');
      Map<String, dynamic> body = res.data!;

      if (res.statusCode == 200) {
        if (body['status']) {
          _hasError = false;
        } else {
          _hasError = true;
        }
        _message = body['msg'];
        notifyListeners();
      } else if (res.statusCode == 401) {
        _hasError = true;
        _message = body['msg'];
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      _message = 'Some Error has happened.';
      notifyListeners();
    }
  }
}
