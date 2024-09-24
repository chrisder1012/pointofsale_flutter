import 'package:flutter/cupertino.dart';
// import 'package:stripe_terminal/stripe_terminal.dart';
import 'package:zabor/pages/summary_page.dart';

import '../api/my_api.dart';
import '../models/cart.dart';
import '../models/rest_order_item.dart';

class AddToCartBloc extends ChangeNotifier {
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  Cart? _cart;
  Cart? get cart => _cart;

  List<Cart> _carts = [];
  List<Cart> get carts => _carts;

  int? _id;
  int? get id => _id;

  Future addToCart(Cart cart, user, {int? tableId}) async {
    try {
      print('===== table id is : $tableId =====');
      var data = {
        'user_id': cart.userId,
        'res_id': cart.resId,
        'cart': cart.cart,
        'food_tax': cart.foodTax,
        'drink_tax': cart.drinkTax,
        'tax': cart.tax,
        'total': double.parse(cart.total!.toStringAsFixed(2)),
        'subtotal': double.parse(cart.subtotal!.toStringAsFixed(2)),
        'convenience_fee':
            double.parse(cart.convienienceFee!.toStringAsFixed(2)),
        'table_id': tableId,
      };

      // Edited by Zohaib
      if (cart.id != null) {
        data['id'] = cart.id;
      }

      var res = await CallApi().postGetDataWithToken(data, 'addtocart/', user);
      Map<String, dynamic> body = res.data!;

      if (res.statusCode == 200) {
        _id = body['insertId'];
        print('===== cart id: $_id =====');
        _hasError = false;
        notifyListeners();
      } else {
        _hasError = true;
        if (res.statusCode == 401) {
          _errorCode = body['message'];
        } else {
          _errorCode = body['msg'];
        }
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
  }

  Future getCartsById(String restId, String userId) async {
    try {
      var data = {
        'restro_id': restId,
        'user_id': userId,
      };

      var res = await CallApi().postGetDataWithToken(data, 'getcartbyrestid/');
      Map<String, dynamic> body = res.data!;

      if (res.statusCode == 200) {
        if (body['status']) {
          var d = body['data']['table_list'];
          List<dynamic> snap = [];
          snap.addAll(d);
          _carts.clear();
          _carts = snap.map((e) => Cart.fromJson(e)).toList();

          _hasError = false;
        } else {
          _hasError = true;
          _errorCode = body['msg'];
        }
        notifyListeners();
      } else {
        _hasError = true;
        if (res.statusCode == 401) {
          _errorCode = body['message'];
        } else {
          _errorCode = body['msg'];
        }
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      // _errorCode = e.toString();
      notifyListeners();
    }
  }

  Future updateCart(Cart cart) async {
    try {
      var data = {
        'cart_id': cart.id,
        'res_id': cart.resId,
        'user_id': cart.userId,
        'cart': cart.cart,
        'food_tax': cart.foodTax,
        'drink_tax': cart.drinkTax,
        'subtotal': cart.subtotal,
        'tax': cart.tax,
        'total': cart.total,
        'convenience_fee': cart.convienienceFee,
        'table_id': cart.tableId
      };

      var res = await CallApi().postGetDataWithToken(data, 'updatecart/');
      Map<String, dynamic> body = res.data!;

      if (res.statusCode == 200) {
        if (body['status']) {
          _hasError = false;
        } else {
          _hasError = true;
          _errorCode = body['msg'];
        }
        notifyListeners();
      } else {
        _hasError = true;
        if (res.statusCode == 401) {
          _errorCode = body['message'];
        } else {
          _errorCode = body['msg'];
        }
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
  }

  Cart cartModelLeft = Cart();

  Cart printModel = Cart();
  setCartModelLeft(value) {
    cartModelLeft = value;
    notifyListeners();
  }

  setPrintModel(Cart? value) {
    if (value != null) {
      printModel = value;
    }
    // notifyListeners();
  }

  setCartModel(value) {
    _cart = value;
  }

  bool isDineIn = false;
  PaymentMethod? isCard;
  String tags = "";
  PaymentOptions? paymentOptions;

  setValue(PaymentOptions paymentOptions) {
    this.paymentOptions = paymentOptions;
    notifyListeners();
  }

  // StripePaymentIntent? intent;
  // setPaymentIntent(StripePaymentIntent intent) {
  //   this.intent = intent;
  //   notifyListeners();
  // }

  int orderId = 12;
  String cardNumer = '4242';

  updateLast4Didgit(String val) {
    cardNumer = val;
    notifyListeners();
  }

  double calculateSubTotal(List<RestOrderItem> rois) {
    var subtotal = 0.0;
    for (var element in rois) {
      subtotal += element.price! * element.quantity!;
    }
    return subtotal;
  }
}

enum PaymentMethod {
  ath,
  card,
  cash,
  application, //Adicionado codepaeza 02/06/2023
}
