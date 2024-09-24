import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zabor/blocs/add_to_cart_bloc.dart';
import 'package:zabor/db/database_handler.dart';
import 'package:zabor/models/cart.dart';
import 'package:zabor/models/order.dart';
import 'package:zabor/models/tax.dart';
import 'package:zabor/models/user.dart';

import '../api/my_api.dart';

class PlaceOrderBloc extends ChangeNotifier {
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  String? _msg;
  String? get msg => _msg;

  int? _orderId;
  int? get orderId => _orderId;

  String? _invoiceNumber;
  String? get invoiceNumber => _invoiceNumber;

  Order? _order;
  Order? get order => _order;

  Future placeOrder(
      User user,
      Cart cart,
      int deliveryMode,
      PaymentMethod method,
      String tvNumber,
      int selectOffer,
      Tax tax,
      int shiftId) async {
    try {
      String amountAfterTax = (cart.subtotal! + cart.tax!).toStringAsFixed(2);

      print(amountAfterTax.toString() + ' amountAfterTax - place_order_bloc');
      print('===== Payment method: $method =====');

      var name = user.name!.split(' ');
      var data = {
        'address': {
          'firstname': user.name!.split(' ')[0],
          'lastname': name.length == 1 ? '' : user.name!.split(' ')[1],
          "country": null, //values["country"],
          "phone": user.phone ?? '863-604-6313',
          "email": user.email,
          "city": user.city ?? 'penulas',
          "pincode": null, //values["pincode"],
          "houseno": user.address ?? 'calle 5, penulas',
          "address": user.address ?? 'calle 5, penulas',
          "user_id": user.id,
          "formattedAddress": user.address ?? 'calle 5, penulas',
          "lat": user.latitude ?? 18.05785585,
          "lng": user.longitude ?? 66.05785585,
          "id": -1
        },
        "total": (cart.total! +
                double.parse(
                    deliveryMode == 2 ? "0" : (tax.deliveryCharge ?? "0")))
            .toStringAsFixed(2),
        "cart": cart.toJson()["cart"],
        "cart_id": cart.id,
        "res_id": cart.resId,
        "payment_mode": method.index,
        "delivery_mode": deliveryMode,
        "tb_num": tvNumber,
        "selectOffer": selectOffer,
        "extra": {
          "convenience_fee": cart.convienienceFee,
          "food_tax": cart.foodTax,
          "drink_tax": cart.drinkTax,
          "subtotal": cart.subtotal,
          "amountAfterTax": double.parse(amountAfterTax),
          "tax": cart.tax,
          "delivery_charge":
              deliveryMode == 2 ? "0" : (tax.deliveryCharge ?? "0")
        },
        "user_id": user.id,
        'shift_id': shiftId
      };

      print('===== Shift Id: $shiftId =====');

      print(data.toString());
      var res = await CallApi().postGetDataWithToken(data, 'placeorder');
      Map<String, dynamic> body = res.data!;
      if (body['status']) {
        _hasError = false;
        _msg = body['msg'];
        _orderId = body['order_id'];
        _invoiceNumber = body['invoice_number'];

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

  Future placeOrderByDb(
      User user,
      Cart cart,
      int deliveryMode,
      PaymentMethod method,
      String tvNumber,
      int selectOffer,
      Tax tax,
      int shiftId) async {
    try {
      String amountAfterTax = (cart.subtotal! + cart.tax!).toStringAsFixed(2);

      print(amountAfterTax.toString() + ' amountAfterTax - place_order_bloc');
      print('===== Payment method: $method =====');

      /// Cart map
      var cartMap = cart.cart?.map((e) => e.toJson()).toList();
      var jsonString = jsonEncode(cartMap);

      /// Total
      var total = (cart.total! +
              double.parse(
                  deliveryMode == 2 ? "0" : (tax.deliveryCharge ?? "0")))
          .toStringAsFixed(2);

      var name = user.name!.split(' ');
      var data = {
        'address': {
          'firstname': user.name!.split(' ')[0],
          'lastname': name.length == 1 ? '' : user.name!.split(' ')[1],
          "country": null, //values["country"],
          "phone": user.phone ?? '863-604-6313',
          "email": user.email,
          "city": user.city ?? 'penulas',
          "pincode": null, //values["pincode"],
          "houseno": user.address ?? 'calle 5, penulas',
          "address": user.address ?? 'calle 5, penulas',
          "user_id": user.id,
          "formattedAddress": user.address ?? 'calle 5, penulas',
          "lat": user.latitude ?? 18.05785585,
          "lng": user.longitude ?? 66.05785585,
          "id": -1
        },
        "total": total,
        "cart": cart.toJson()["cart"],
        "cart_id": cart.id,
        "res_id": cart.resId,
        "payment_mode": method.index,
        "delivery_mode": deliveryMode,
        "tb_num": tvNumber,
        "selectOffer": selectOffer,
        "extra": {
          "convenience_fee": cart.convienienceFee,
          "food_tax": cart.foodTax,
          "drink_tax": cart.drinkTax,
          "subtotal": cart.subtotal,
          "amountAfterTax": double.parse(amountAfterTax),
          "tax": cart.tax,
          "delivery_charge":
              deliveryMode == 2 ? "0" : (tax.deliveryCharge ?? "0")
        },
        "user_id": user.id,
        'shift_id': shiftId
      };

      /// Payment data map
      var paymentDataJson = jsonEncode(data);

      /// Created date
      var curTime = DateTime.now();
      var createdDate = DateFormat("yyyy-MM-dd HH:mm").format(curTime);

      /// Create invoice number
      var resInteger = NumberFormat('0000');
      var orderInteger = NumberFormat('000');
      var sp = await SharedPreferences.getInstance();
      var prevOrderId = sp.getInt('order_id') ?? 0;
      var invoice =
          '${resInteger.format(cart.resId)}${resInteger.format(shiftId)}${orderInteger.format(prevOrderId + 1)}';

      var order = {
        "user_id": cart.userId,
        "res_id": cart.resId,
        "cart_id": cart.id,
        "order_hash": "V9VjfMcUTtdoEaF3GzXZ9tijzzgqHtAU",
        "cart": jsonString,
        "food_tax": cart.foodTax,
        "drink_tax": cart.drinkTax,
        "subtotal": cart.subtotal,
        "tax": cart.tax,
        "delivery_charge":
            deliveryMode == 2 ? "0" : (tax.deliveryCharge ?? "0"),
        "total": total,
        "discount": 0,
        "without_discount": total,
        "delieverydate": null,
        "timeSlots": null,
        "order_code": 296641,
        "code_verified": 0,
        "delivery_mode": deliveryMode,
        "delivered_by": null,
        "payment_mode": method.index,
        "status": "received",
        "payment_status": 0,
        "payment_data": paymentDataJson,
        "order_by": "app",
        "cooking_time": null,
        "orderissue": null,
        "cancelled_by": null,
        "created_date": createdDate,
        "tb_num": null,
        "convenience_fee": cart.convienienceFee,
        "email": null,
        "shift_id": shiftId,
        "invoice_number": invoice,
        "res_name": "Las Cuevas Spot",
        // "restaurantpic": "restaurantpic/restaurantImage-1676650375102.jpeg"
      };

      var dbHander = DatabaseHandler();
      var orderId = await dbHander.insertOrder(order);
      if (orderId > 0) {
        _hasError = false;
        _msg = 'Ordered';
        _orderId = orderId;
        _invoiceNumber = invoice;
      } else {
        _hasError = true;
        _errorCode = 'Order Error';
      }
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
  }

  Future getOrderById(int orderId) async {
    try {
      var data = {'orderId': orderId};

      print(data.toString());
      var res = await CallApi().postGetDataWithToken(data, 'getOrderById');
      Map<String, dynamic> body = res.data!;
      if (body['status']) {
        _hasError = false;
        _msg = body['msg'];
        List list = body['data'];
        if (list.isEmpty) {
          _hasError = true;
          _msg = 'no data';
        } else {
          _order = list.map((e) => Order.fromJson(e)).toList().first;
        }

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
