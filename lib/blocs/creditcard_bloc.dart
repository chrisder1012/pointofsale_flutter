import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:xml2json/xml2json.dart';
import 'package:zabor/blocs/add_to_cart_bloc.dart';

class CreditCardBloc extends ChangeNotifier {
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  String? _acntLast;
  String? get acntLast => _acntLast;

  String? _responseType;
  String? get responseType => _responseType;

  Future payCreadit(double amount, int refId, PaymentMethod pm) async {
    try {
      var data = {
        "amount": amount.toString(),
        "paymentType": pm == PaymentMethod.ath ? "Debit" : "Credit",
        "transType": "Sale",
        "tip": 0.0.toString(),
        "cashbackAmount": 0.0.toString(),
        "frequency": "OneTime",
        "customFee": 0.0.toString(),
        "refId": refId.toString(),
        "printReceipt": "Customer",
        // 'resid': 39.toString()
      };

      // Dio dio = Dio();

      // var res = await dio.request('https://api.zaboreats.com/api/pay-credit',
      //     data: data,
      //     options: Options(method: "GET", contentType: "application/json"));

      var request = http.Request(
        'GET',
        Uri.parse("https://api.zaboreats.com/api/pay-credit"),
      )..headers.addAll({
          HttpHeaders.contentTypeHeader: "application/json",
          "callMethod": "DOCTOR_AVAILABILITY",
        });
      request.body = jsonEncode(data);
      http.StreamedResponse res = await request.send();

      var xml = await res.stream.bytesToString();

      // Create a client transformer
      final myTransformer = Xml2Json();
      myTransformer.parse(xml);
      var json = myTransformer.toParker();
      var decode = jsonDecode(json);
      print(decode);

      if (res.statusCode == 200) {
        if (decode['xmp']['response']['Message'] == 'Error') {
          _hasError = true;
          _errorCode = 'Error: ${decode['xmp']['response']['RespMSG']}';
        } else if (decode['xmp']['response']['Message'] == 'Approved') {
          _hasError = false;
          _responseType = decode['xmp']['response']['Message'];
          _acntLast = _getAcntLast4(decode['xmp']['response']['ExtData']);
        } else {
          _hasError = false;
          _responseType = decode['xmp']['response']['Message'];
          notifyListeners();
        }
      } else {
        _hasError = true;
        _errorCode = 'Failed';
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
  }

  String? _getAcntLast4(String extData) {
    var list = extData.split(',');
    var acnt =
        list.firstWhereOrNull((element) => element.contains('AcntLast4'));
    if (acnt == null) return null;
    return acnt.split('=').last;
  }
}
