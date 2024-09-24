import 'package:flutter/cupertino.dart';
import 'package:zabor/blocs/sign_in_bloc.dart';

import '../api/my_api.dart';
import '../config/config.dart';
import '../models/rest_order.dart';

class CloseOrderBloc extends ChangeNotifier {
  late SignInBloc sib;
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  bool _wantPrintForPay = true;
  bool get wantPrintForPay => _wantPrintForPay;

  set wantPrintForPay(value) {
    _wantPrintForPay = value;
  }

  int _orderState = 0;
  int get orderState => _orderState;

  set orderState(value) {
    _orderState = value;
  }

  List<dynamic> _ordersFromKiosk = [];

  List<dynamic> get ordersFromKiosk => _ordersFromKiosk;
  set ordersFromKiosk(value) {
    _ordersFromKiosk = value;
  }

  List<RestOrder> _restOrders = [];

  List<RestOrder> get restOrders => _restOrders;
  set restOrders(value) {
    _restOrders = value;
  }

  List<dynamic> _allOrdersFromKiosk = [];

  List<dynamic> get allOrdersFromKiosk => _restOrders;
  set allOrdersFromKiosk(value) {
    _allOrdersFromKiosk = value;
  }

  Future closeOrder(int userId) async {
    try {
      var res = await CallApi().getDataWithToken('clearCart?user_id=$userId');
      Map<String, dynamic> body = res.data!;

      if (body['status']) {
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

  //get orders from koisk
  getDataFromKiosk() async {
    _restOrders.clear();
    var userId = sib.uid!;

    print(["userId====:", userId]);

    var response = await CallApi().getDataWithToken(
        "get-unpaid-orders?user_id=$userId&paging=false&page=1&res_id=${Config.restaurantId}&order_by=kiosk");
    List<dynamic>? orders = response.data!["data"];
    _ordersFromKiosk = orders ?? [];

    _allOrdersFromKiosk = _ordersFromKiosk; //dummy variable
    // Showing only unpaid orders
    if (orders != null) {
      _ordersFromKiosk =
          orders.where((element) => element["payment_status"] == 0).toList();
    }
    notifyListeners();
  }
}
