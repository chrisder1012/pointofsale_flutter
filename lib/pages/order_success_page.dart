import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:zabor/blocs/add_to_cart_bloc.dart';
import 'package:zabor/config/config.dart';
import 'package:zabor/models/cart.dart';
import 'package:zabor/models/rest_order_payment.dart';
import 'package:zabor/models/rest_table.dart';
// import 'package:zabor/pages/cart_page.dart';
// import 'package:zabor/pages/summary_page.dart';
import 'package:zabor/utils/t1_string.dart';

import '../db/database_handler.dart';
// import '../utils/next_screen.dart';
import 'home.dart';
// import 'package:zabor/utils/t1_string.dart';

class OrderSuccessPage extends StatefulWidget {
  const OrderSuccessPage({
    Key? key,
    required this.orderNo,
    required this.tableName,
    required this.cart,
    required this.method,
    required this.price,
  }) : super(key: key);

  final int? orderNo;
  final String? tableName;
  final Cart? cart;
  final PaymentMethod method;
  final double? price;

  @override
  State<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage> {
  final String _orderConfirmedMessage = t1OrderSuccessfully.tr();
  final String _orderConfirmedMessage2 = t1OrderCall.tr();
  final String _orderConfirmedMessage3 = t1Thanks.tr();
  int? orderNo;

  //
  final DatabaseHandler _dbHandler = DatabaseHandler();

  @override
  void initState() {
    orderNo = widget.orderNo ?? 0;
    _saveOrderPayment();
    _loadTablesFromDb();
    _deleteDb();
    super.initState();
  }

  @override
  void dispose() {
    _restTables.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          // return Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
          //     LanguageScreen()), (Route<dynamic> route) => false);
          // nextScreenCloseOthers(context, const HomePage());
          // Navigator.popUntil(context, (route) => false);

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(
                        goNext: true,
                      )),
              (route) => false);
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // image1!,
                  // image2!,
                  Icon(
                    Icons.check_circle,
                    color: Config().appColor,
                    size: 150,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    orderNo == 0
                        ? _orderConfirmedMessage
                        : t1OrderNumNum.tr() +
                            '$orderNo' +
                            t1OrderProcessed.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    _orderConfirmedMessage2
                    // _orderConfirmedMessage ==
                    //         "Your order was processed successfully"
                    //     ? AppLocalizations.of(context)
                    //         .translate(_orderConfirmedMessage2)
                    //     : ""
                    ,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Text(
                    _orderConfirmedMessage3,

                    // _orderConfirmedMessage ==
                    //         "Your order was processed successfully"
                    //     ? AppLocalizations.of(context)
                    //         .translate(_orderConfirmedMessage3)
                    //     : "",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 30),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _deleteDb() async {
    List<int> roiIds = [];
    var orders = await _dbHandler.retireveRestOrders();
    for (var element in orders) {
      if (element.tableName == widget.tableName) {
        _dbHandler.deleteRestOrder(element.id!).then((_) {
          _dbHandler.retireveRestOrderItemFromOrderId(element.id!).then((rois) {
            for (var element in rois) {
              var roiId = element.id;
              roiIds.add(roiId!);
              _dbHandler.deleteRestOrderItem(roiId).then((_) {});
              if (element == rois.last) {
                _dbHandler
                    .retireveComplimentItemFromOrderId(element.id!)
                    .then((cis) {
                  for (var element in cis) {
                    if (roiIds.contains(element.cartItemId)) {
                      _dbHandler
                          .deleteComplimentItem(element.id!)
                          .then((value) {});
                    }
                  }
                });
              }
            }
          });
        });
      }
    }
  }

  _saveOrderPayment() async {
    var orderPayment = RestOrderPayment();
    orderPayment.orderId = widget.orderNo;
    orderPayment.amount = widget.price;
    orderPayment.table = widget.tableName;
    orderPayment.items = jsonEncode(widget.cart!.cart);
    orderPayment.paymentType = widget.method.index + 1;
    var time = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    orderPayment.time = time;

    await _dbHandler.insertRestOrderPayment([orderPayment]);
  }

  final List<RestTable> _restTables = [];
  Future<List<RestTable>> _loadTablesFromDb() async {
    var result = await _dbHandler.retireveRestTable();
    _restTables.clear();
    for (var element in result) {
      if (element.tableGroupId == Config.restaurantId) {
        _restTables.add(element);
      }
    }

    return _restTables;
    // setState(() {
    //   _isLoaded = true;
    // });
    // addRestTables().whenComplete(() async {
    // });
  }
}
