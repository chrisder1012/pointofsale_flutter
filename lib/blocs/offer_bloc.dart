import 'package:flutter/cupertino.dart';
import 'package:zabor/models/offer.dart';

import '../api/my_api.dart';

class OfferBloc extends ChangeNotifier {
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  List<Offer>? _offers;
  List<Offer>? get offers => _offers;

  Future getDiscount(var userId, var resId) async {
    try {
      var res = await CallApi()
          .getDataWithToken('getDiscounts/?user_id=$userId&res_id=$resId');
      Map<String, dynamic> body = res.data!;

      if (body['status']) {
        List<dynamic> snap = [];
        snap.addAll(body['data']);
        _offers = snap.map((e) => Offer.fromJson(e)).toList();

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
