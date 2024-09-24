import 'package:flutter/cupertino.dart';
import 'package:zabor/models/order.dart';

import '../api/my_api.dart';

class OrderBloc extends ChangeNotifier {
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  int? _status;
  int? get status => _status;

  List<Order>? _orders;
  List<Order>? get orders => _orders;

  Future getOrders(var userId, var shiftId) async {
    try {
      var res = await CallApi()
          .getDataWithToken('get-orders?user_id=$userId&shift_id=$shiftId');
      Map<String, dynamic> body = res.data!;

      _status = res.statusCode;
      if (_status == 200) {
        if (body['status']) {
          List<dynamic> snap = [];
          snap.addAll(body['data']);
          _orders = snap.map((e) => Order.fromJson(e)).toList();

          _hasError = false;
          notifyListeners();
        } else {
          _hasError = true;
          _errorCode = body['msg'];
          notifyListeners();
        }
      } else if (_status == 401) {
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

  Future deleteOrders(var userId, var shiftId) async {
    try {
      var data = {
        'user_id': userId,
        'shift_id': shiftId,
      };

      var res = await CallApi().deleteData('clearOrders', data);
      Map<String, dynamic> body = res.data!;

      _status = res.statusCode;
      if (_status == 200) {
        if (body['status']) {
          _hasError = false;
          notifyListeners();
        } else {
          _hasError = true;
          _errorCode = body['msg'];
          notifyListeners();
        }
      } else if (_status == 401) {
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
