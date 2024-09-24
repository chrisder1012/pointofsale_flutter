import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:stripe_terminal/stripe_terminal.dart';
import 'package:zabor/blocs/close_order_bloc.dart';
import 'package:zabor/blocs/creditcard_bloc.dart';
import 'package:zabor/models/rest_order.dart';
import 'package:zabor/models/rest_order_item.dart';
import 'package:zabor/models/tax.dart';
import 'package:zabor/pages/calculator_screen.dart';
import 'package:zabor/pages/left_summary_page.dart';
// import 'package:zabor/pages/loading_screen.dart';
import 'package:zabor/pages/order_success_page.dart';
// import 'package:zabor/pages/pay_using_terminal.dart';
import 'package:zabor/utils/next_screen.dart';
import 'package:zabor/utils/t1_string.dart';
import 'package:zabor/widget/topbar_icon_widget.dart';
import 'package:zabor/widget/topbar_item_widget.dart';

import '../blocs/add_to_cart_bloc.dart';
import '../blocs/homepage_restaurant_bloc.dart';
// import '../blocs/offer_bloc.dart';
import '../blocs/place_order_bloc.dart';
import '../blocs/sign_in_bloc.dart';
import '../config/config.dart';
import '../db/database_handler.dart';
import '../models/cart.dart';
import '../models/offer.dart';
import '../models/restaurant.dart';
import '../models/user.dart';
import '../services/services.dart';
import '../utils/snacbar.dart';
import '../utils/utils.dart';

// Image? image1;

Image? image2;

class SummaryPage extends StatefulWidget {
  const SummaryPage({
    Key? key,
    /*required*/ this.cart,
    this.response,
    required this.tax,
    this.isWithoutLogin = false,
    required this.deliveryMode,
    required this.paymentMode,
    required this.restOrder,
  }) : super(key: key);

  final Cart? cart;
  final Responses? response;
  final Tax? tax;
  final bool isWithoutLogin;
  final int? deliveryMode;
  final int? paymentMode; // 1 = Online; 2 = Cash on delivery
  final RestOrder restOrder;

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Offer> _offers = [];
  final List<RestOrderItem> _restOrderItems = [];
  List<String>? stripeToken;
  // Map<String, dynamic>? authorizeDict;
  Cart? _cart;
  User? _user;
  String? orderNo;
  Cart? _printCartModel;
  String? _acntNumber;
  String _invoiceNumber = "";

  //
  final DatabaseHandler _dbHandler = DatabaseHandler();

  GlobalKey globalKey = GlobalKey();
  GlobalKey globalCustomerKey = GlobalKey();
  GlobalKey globalKitchenKey = GlobalKey();
  GlobalKey globalAdminKey = GlobalKey();

  // var scaleWidth = 0.0;
  // var scaleHeight = 0.0;
  var _width = 0.0;
  var _height = 0.0;
  // var _total = 0.0;

  var _amount = '';
  var _appliedIndex = -1;
  var selectOffer = -1;
  bool canAcceptCash = true; //Modificado codepaeza 02/06/2023
  bool canAcceptDejavoo = true;

  PaymentOptions paymentOption = PaymentOptions();

  var _isLoaded = false;
  var _loadingPlaceOrderState = false;
  var _orderPlaced = false;
  final _isPrint = false;

  String _orderConfirmedMessage = "Your order was processed successfully";

  @override
  void initState() {
    _addToCartBloc = Provider.of<AddToCartBloc>(context, listen: false);
    print(["summary: sss", widget.restOrder.toJson()]);
    orderNo = widget.restOrder.invoiceNum;
    _cart = widget.cart!;
    print(["cart list:", _cart?.cart]);
    _amount = (widget.cart!.total! +
            (widget.deliveryMode == 2
                ? 0
                //: double.parse((widget.tax!.deliveryCharge ?? "0"))))
                : int.parse((widget.tax!.deliveryCharge ?? "0"))))
        .toStringAsFixed(2);
    // _total = _cart!.total!;

    /// Get user
    Future.delayed(Duration()).then((value) async {
      var sp = await SharedPreferences.getInstance();
      var userId = sp.getInt('user_id') ?? 0;
      var dbHandler = DatabaseHandler();
      _user = await dbHandler.retrieveUser(userId);
      setState(() {});
    });
    // _user = context.read<SignInBloc>().user;

    //_handleOffer();
    checkCashEnable();
    setState(() {});
    Config.getBool("canAcceptCash").then((value) {
      setState(() {
        canAcceptCash = value ?? true;
      });
    });
    Config.getBool("dejavoo").then((value) {
      setState(() {
        canAcceptDejavoo = value ?? false;
      });
    });
    _addToCartBloc.setPrintModel(_cart);
    final CloseOrderBloc cob =
        Provider.of<CloseOrderBloc>(context, listen: false);
    print(["cob.wantPrintForPay=====;;:", cob.wantPrintForPay]);
    if (cob.orderState != 2) {
      Future.delayed(Duration(seconds: 1), () {
        if (cob.wantPrintForPay) {
          printCustomData();
        }
      });
    }
    super.initState();
  }

  _getOrderItemsFromCart() {
    _restOrderItems.clear();
    for (var element in _cart!.cart!) {
      var roi = RestOrderItem();
      roi.taxtype = element.taxtype;
      // roi.itemQuantity = element.itemQuantity;
      // roi.itemPic = element.itemPic;
      // roi.itemDes = element.itemDes;
      roi.isShow = element.isShow;
      roi.isFood = element.isFood;
      roi.isState = element.isState;
      roi.isCity = element.isCity;
      roi.isNote = element.isNote;
      roi.note = element.note;
      roi.quantity = element.quantity;
      roi.taxvalue = element.taxvalue;
      roi.itemName = element.itemName;
      roi.price = element.itemPrice;
      roi.itemId = element.itemId;
      _restOrderItems.add(roi);
    }
  }

  ///
  /// Get orders from db
  ///
  _getOrderItemsFromDb(int orderId) {
    // Rest Order Items
    _dbHandler.retireveRestOrderItemFromOrderId(orderId).then((value) {
      _restOrderItems.clear();
      _restOrderItems.addAll(value);
      // setState(() {});
    });
  }

  bool isCashEnable = true;
  checkCashEnable() {
    SharedPreferences.getInstance().then((value) {
      setState(() {
        isCashEnable = value.getBool('cash_enable') ?? true;
      });
    });
  }

  Uint8List? capturedBytes;
  Future<String> convertImageToBase64(GlobalKey globalTmpKey) async {
    // if (globalTmpKey.currentContext == null) return "";
    // RenderRepaintBoundary boundary = globalTmpKey.currentContext!
    //     .findRenderObject()! as RenderRepaintBoundary;
    // if (boundary.debugNeedsPaint) {
    //   print("Waiting for boundary to be painted.");
    //   await Future.delayed(const Duration(milliseconds: 20));
    //   return convertImageToBase64(globalTmpKey);
    // }
    // ui.Image image = await boundary.toImage();
    // ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    // capturedBytes = byteData!.buffer.asUint8List();
    // final imageEncoded = base64.encode(capturedBytes!);
    // return imageEncoded;
    if (globalTmpKey.currentContext == null) return "";
    RenderRepaintBoundary boundary = globalTmpKey.currentContext!
        .findRenderObject()! as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    capturedBytes = byteData!.buffer.asUint8List();
    final imageEncoded = base64.encode(capturedBytes!);
    return imageEncoded;
  }

  Future<void> printThirdData() async {
    try {
      List<String> imageLst = ["", "", "", "", "", ""];

      var cashierData = await convertImageToBase64(globalCustomerKey);
      var kitchenData = await convertImageToBase64(globalKitchenKey);

      print(["summary_page: 00", cashierData]);
      print(["summary_page: 11", kitchenData]);

      var dio = Dio();
      List<String> strPrinters = await Config.getPrinters() ?? [];
      print("Printers length ${strPrinters.length}");
      if (strPrinters.isEmpty) {
        _addToCartBloc.setPrintModel(Cart());
        return showPrintAlert();
      }

      for (var i = 0; i < strPrinters.length; i++) {
        if (i == strPrinters.length - 1) continue;
        if (strPrinters[i].isEmpty || strPrinters[i] == '0.0.0.0') continue;

        if (i == 0) {
          imageLst[i] = cashierData;
        } else {
          imageLst[i] = kitchenData;
        }

        var data = {};
        if (strPrinters[i].split(".").length == 4) {
          data = {"image": imageLst[i], "text": "", "printer": strPrinters[i]};
        } else {
          data = {
            "image": imageLst[i],
            "text": "",
            "printer": strPrinters[i],
            "printerType": 3
          };
        }
        print("In printing ${strPrinters[i]}");
        try {
          await dio.post("http://localhost:7200", data: data);
          // openSnacbar(context, "print Success");
        } catch (e) {
          openSnacbar(context, "print failed");
        }

        await Future.delayed(const Duration(seconds: 2));
      }
      setState(() {});
      _addToCartBloc.setPrintModel(Cart());
    } catch (e) {
      openSnacbar(context, 'Kitchen printer error $e');
      setState(() {});
    }
  }

  Future<void> printCustomData() async {
    try {
      List<String> imageLst = ["", "", "", ""];

      imageLst[0] = await convertImageToBase64(globalCustomerKey);
      print(["summary_page:custom print data 11", imageLst[0]]);

      var dio = Dio();
      List<String> strPrinters = await Config.getPrinters() ?? [];
      print("Printers length ${strPrinters.length}");
      if (strPrinters.isEmpty) {
        _addToCartBloc.setPrintModel(Cart());
        return showPrintAlert();
      }
      for (var i = 0; i < strPrinters.length; i++) {
        if (strPrinters[i].isEmpty || strPrinters[i] == '0.0.0.0') continue;
        if (i == 1) break;
        var data = {};
        if (strPrinters[i].split(".").length == 4) {
          data = {"image": imageLst[i], "text": "", "printer": strPrinters[i]};
        } else {
          data = {
            "image": imageLst[i],
            "text": "",
            "printer": strPrinters[i],
            "printerType": 3
          };
        }
        print("In printing ${strPrinters[i]}");
        try {
          await dio.post("http://localhost:7200", data: data);
          // openSnacbar(context, "print Success");
        } catch (e) {
          openSnacbar(context, "print failed");
        }

        await Future.delayed(const Duration(seconds: 2));
      }
    } catch (e) {
      openSnacbar(context, 'Kitchen printer error $e');
      setState(() {});
    }
  }

  showPrintAlert() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('You have to register printers'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Yes'),
              )
            ],
          );
        });
  }

  late AddToCartBloc _addToCartBloc;
  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;

    _addToCartBloc = Provider.of<AddToCartBloc>(context, listen: true);
    _printCartModel = _addToCartBloc.printModel;

    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    if (isPortrait) {
      scaleWidth = _width / Config().defaultWidth;
      scaleHeight = _height / Config().defaultHeight;
    } else {
      scaleWidth = _width / Config().defaultHeight;
      scaleHeight = _height / Config().defaultWidth;
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[900],
      body: _body(),
    );
  }

  _body() {
    print(["check print data exist:", _printCartModel!.cart]);
    return Stack(
      children: [
        _printCartModel!.cart == null
            ? Container()
            : wdPrintCustomerData(_addToCartBloc.printModel),
        _addToCartBloc.printModel.cart == null
            ? Container()
            : wdPrintKitchenData(_addToCartBloc.printModel),
        Positioned(
            child: Container(
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _topBar(),
                    _leftContent(),
                    _content(),
                  ],
                ))),
        _isLoaded
            ? Container(
                height: double.infinity,
                width: double.infinity,
                color: Colors.white,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : SizedBox.shrink()
      ],
    );
  }

  _topBar() {
    var width = MediaQuery.of(context).size.width;

    return _isPrint && _orderPlaced
        ? Container()
        : SizedBox(
            width: width,
            height: setScaleHeight(_isPrint ? 50 : 60),
            child: Row(
              children: [
                topbarIconItem(
                    bgColor: const Color(0xFF519991),
                    iconData: Icons.arrow_back,
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                topbarItem(
                    title: t1Surcharge.tr(),
                    bgColor: Colors.green,
                    onTap: () {}),
                topbarItem(
                    title: t1Gratuity.tr(),
                    bgColor: Colors.greenAccent,
                    onTap: () {}),
                topbarItem(
                    title: t1Discount.tr(),
                    bgColor: Colors.yellow,
                    onTap: () {
                      _offersDialog();
                    }),
                topbarItem(
                    title: t1Tax.tr(),
                    bgColor: Colors.orange,
                    onTap: () {
                      _offersDialog();
                    }),
                topbarItem(
                    title: t1Note.tr(),
                    bgColor: Colors.yellow[300],
                    onTap: () {
                      _offersDialog();
                    }),
                topbarItem(
                    title: t1PayLater.tr(),
                    bgColor: Colors.deepOrange,
                    onTap: () {
                      _offersDialog();
                    }),
              ],
            ),
          );
  }

  ///
  /// Dialog for offers
  ///
  _offersDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: getOffers(),
              ),
            ),
          );
        });
  }

  // _contents() {
  //   return Expanded(
  //     child: Row(
  //       children: [
  //         _leftContent(),
  //         const VerticalDivider(width: 1, color: Colors.black),
  //         _content(),
  //       ],
  //     ),
  //   );
  // }

  _leftContent() {
    // _getOrderItemsFromDb(widget.restOrder.id ?? 1);
    _getOrderItemsFromCart();
    return Expanded(
      flex: 1,
      child: Container(
        margin: EdgeInsets.all(16),
        width: isPortrait ? _width : _width,
        child: RepaintBoundary(
          key: globalKey,
          child: LeftSummaryPage(
            restOrder: widget.restOrder,
            restOrderItems: _restOrderItems,
          ),
        ),
      ),
    );
  }

  _content() {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: _width,
                padding: const EdgeInsets.all(8),
                color: Colors.white,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            t1PaymentMethod.tr(),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Divider(thickness: 1, color: Colors.grey),
                          ),
                        ],
                      ),
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            if (canAcceptCash) ...[
                              //Comentado codepaeza 02/06/2023
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      paymentOption.paymentMethod =
                                          PaymentMethod.cash;
                                    });
                                  },
                                  // behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    // height: setScaleHeight(isPortrait ? 30 : 50),
                                    color: paymentOption.paymentMethod ==
                                            PaymentMethod.cash
                                        ? Colors
                                            .yellowAccent //deepPurple  //Modificado codepaeza 02/06/2023
                                        : Colors.white,
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            MdiIcons.cash,
                                            size: 50,
                                          ),
                                          Text(
                                            t1Cash.tr(),
                                            style: TextStyle(
                                              fontSize: setFontSize(
                                                  isPortrait ? 8 : 14),
                                              fontWeight:
                                                  paymentOption.paymentMethod ==
                                                          PaymentMethod.cash
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const VerticalDivider(
                                  thickness: 1, color: Colors.grey),
                            ],
                            if (canAcceptDejavoo) ...[
                              Expanded(
                                child: GestureDetector(
                                  onTap: (() {
                                    setState(() {
                                      paymentOption.paymentMethod =
                                          PaymentMethod.card;
                                    });
                                  }),
                                  child: Container(
                                    // height: setScaleHeight(isPortrait ? 30 : 50),
                                    margin: EdgeInsets.all(8),

                                    color: paymentOption.paymentMethod ==
                                            PaymentMethod.card
                                        ? Colors.teal
                                        : Colors.white,
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            MdiIcons.creditCard,
                                            size: 50,
                                          ),
                                          Text(
                                            t1CreditCard.tr(),
                                            style: TextStyle(
                                              fontSize: setFontSize(
                                                  isPortrait ? 8 : 14),
                                              fontWeight:
                                                  paymentOption.paymentMethod ==
                                                          PaymentMethod.card
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const VerticalDivider(
                                  thickness: 1, color: Colors.grey),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      paymentOption.paymentMethod =
                                          PaymentMethod.ath;
                                    });
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    // height: setScaleHeight(isPortrait ? 30 : 50),
                                    margin: EdgeInsets.all(8),

                                    color: paymentOption.paymentMethod ==
                                            PaymentMethod.ath
                                        ? Colors.orange
                                        : Colors.white,
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            MdiIcons.walletGiftcard,
                                            size: 50,
                                          ),
                                          Text(
                                            t1DevitCard.tr(),
                                            style: TextStyle(
                                              fontSize: setFontSize(
                                                  isPortrait ? 8 : 14),
                                              fontWeight:
                                                  paymentOption.paymentMethod ==
                                                          PaymentMethod.ath
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const VerticalDivider(
                                  thickness: 1, color: Colors.grey),
                            ],
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    paymentOption.paymentMethod =
                                        PaymentMethod.application;
                                  });
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  // height: setScaleHeight(isPortrait ? 30 : 50),
                                  margin: EdgeInsets.all(8),

                                  color: paymentOption.paymentMethod ==
                                          PaymentMethod.application
                                      ? Colors.blueAccent
                                      : Colors.white,
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          MdiIcons.apps,
                                          size: 50,
                                        ),
                                        Text(
                                          //t1DevitCard.tr(),
                                          'Aplicación',
                                          style: TextStyle(
                                            fontSize: setFontSize(
                                                isPortrait ? 8 : 14),
                                            fontWeight: paymentOption
                                                        .paymentMethod ==
                                                    PaymentMethod.application
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(thickness: 1, color: Colors.grey),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Text(
                            t1CheckoutOption.tr(),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Divider(thickness: 1, color: Colors.grey),
                          ),
                        ],
                      ),
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: (() {
                                  setState(() {
                                    paymentOption.type = OrderType.dineIn;
                                  });
                                }),
                                child: Container(
                                  // height: setScaleHeight(isPortrait ? 30 : 50),
                                  margin: EdgeInsets.all(8),

                                  color: paymentOption.type == OrderType.dineIn
                                      ? Colors.pink
                                      : Colors.white,
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          MdiIcons.tableChair,
                                          size: 50,
                                        ),
                                        Text(
                                          t1DineIn.tr(),
                                          style: TextStyle(
                                            fontSize: setFontSize(
                                                isPortrait ? 8 : 14),
                                            fontWeight: paymentOption.type ==
                                                    OrderType.dineIn
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const VerticalDivider(
                                thickness: 1, color: Colors.grey),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    paymentOption.type = OrderType.takeOut;
                                  });
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  // height: setScaleHeight(isPortrait ? 30 : 50),
                                  margin: EdgeInsets.all(8),
                                  color: paymentOption.type == OrderType.takeOut
                                      ? Colors.indigo
                                      : Colors.white,
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          MdiIcons.run,
                                          size: 50,
                                        ),
                                        Text(
                                          t1TakeOut.tr(),
                                          style: TextStyle(
                                            fontSize: setFontSize(
                                                isPortrait ? 8 : 14),
                                            fontWeight: paymentOption.type ==
                                                    OrderType.takeOut
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (paymentOption.type == OrderType.takeOut) ...[
                        const Divider(color: Colors.transparent),
                        /*const*/ TextField(
                          decoration: InputDecoration(
                            labelText: t1Tags.tr(),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                      const Divider(thickness: 1, color: Colors.grey),
                      const SizedBox(height: 30),
                      if (paymentOption.paymentMethod ==
                          PaymentMethod.card) ...[
                        Row(
                          children: [
                            Text(
                              t1Tip.tr(),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Divider(thickness: 1, color: Colors.grey),
                            ),
                          ],
                        ),
                        IntrinsicHeight(
                          child: Row(
                              children: [0, 10, 15, 20]
                                  .mapIndexed(
                                    (i, e) => Expanded(
                                      child: IntrinsicHeight(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: (() {
                                                  setState(() {
                                                    paymentOption
                                                        .tipPercentage = e;
                                                  });
                                                }),
                                                child: Container(
                                                  height: setScaleHeight(
                                                    isPortrait ? 30 : 50,
                                                  ),
                                                  color: paymentOption
                                                              .tipPercentage ==
                                                          e
                                                      ? Color.lerp(
                                                          Colors.red,
                                                          Colors.green,
                                                          (e) / 20,
                                                        )
                                                      : Colors.white,
                                                  child: Center(
                                                    child: Text(
                                                      e == 0
                                                          ? t1NoTip.tr()
                                                          : "$e%",
                                                      style: TextStyle(
                                                          fontSize: setFontSize(
                                                              isPortrait
                                                                  ? 16
                                                                  : 25),
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (i != 3)
                                              const VerticalDivider(
                                                thickness: 1,
                                                color: Colors.grey,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList()),
                        ),
                        const Divider(thickness: 1, color: Colors.grey),
                      ],

                      // IntrinsicHeight(
                      //   child: Row(
                      //     children: [
                      //       SizedBox(
                      //         width: _width / 3 * 2,
                      //         child: Text(
                      //           '+ $t1Discount',
                      //           style: TextStyle(
                      //             color: Colors.grey,
                      //             fontSize: setFontSize(14),
                      //           ),
                      //         ),
                      //       ),
                      //       const VerticalDivider(thickness: 1, color: Colors.grey),
                      //       Expanded(
                      //         child: Text(
                      //           '\$${_discount.toStringAsFixed(2)}',
                      //           textAlign: TextAlign.right,
                      //           style: TextStyle(
                      //             color: Colors.grey,
                      //             fontSize: setFontSize(14),
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // const Divider(thickness: 1, color: Colors.grey),
                      // IntrinsicHeight(
                      //   child: Row(
                      //     children: [
                      //       SizedBox(
                      //         width: _width / 3 * 2,
                      //         child: Text(
                      //           t1PayableAmount,
                      //           style: TextStyle(
                      //             fontSize: setFontSize(18),
                      //             fontWeight: FontWeight.bold,
                      //           ),
                      //         ),
                      //       ),
                      //       const VerticalDivider(thickness: 1, color: Colors.grey),
                      //       Expanded(
                      //         child: Text(
                      //           '\$${double.parse(_amount).toStringAsFixed(2)}',
                      //           textAlign: TextAlign.right,
                      //           style: TextStyle(
                      //             fontSize: setFontSize(18),
                      //             fontWeight: FontWeight.bold,
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
            _bottomBar(),
          ],
        ),
      ),
    );
  }

  _bottomBar() {
    return GestureDetector(
      onTap: () {
        if (paymentOption.readyToPay) _placeOrder();
      },
      child: Container(
        height: setScaleHeight(60),
        color: !paymentOption.readyToPay ? Colors.grey : Colors.red,
        child: Center(
          child: _loadingPlaceOrderState
              ? /*const Center(child: CircularProgressIndicator())*/
              CircularProgressIndicator()
              : Text(
                  t1Pay.tr(),
                  style: TextStyle(
                    fontSize: setFontSize(isPortrait ? 10 : 16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  List<Widget> getOffers() {
    List<Widget> widgets = [];
    for (int i = 0; i < _offers.length; i++) {
      widgets.add(buildOfferDetailRow(i));
    }
    return widgets;
  }

  Widget buildOfferDetailRow(int index) {
    return Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FaIcon(
                FontAwesomeIcons.tags,
                size: 40,
                color: Config().appColor,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${_offers[index].userType == "all_users" ? 'All User Offer: ' : 'First User Offer: '} Get flat ${_offers[index].percentage ?? 0}% OFF on Order of \$${_offers[index].moa ?? 0} and Above (Max Discount: \$${_offers[index].mpd ?? 0})',
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            ElevatedButton(
                // color: Config.appColor,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Config().appColor),
                onPressed: () {
                  if (index == _appliedIndex) return;
                  calculateAmount(index);
                  Navigator.pop(context);
                },
                child: Text(index == _appliedIndex ? 'Applied' : 'Apply',
                    style: TextStyle(color: Config().kWhiteColor))),
          ],
        )
      ],
    );
  }

  calculateAmount(int index) {
    String amountWithoutTaxDelivery =
        (_cart!.subtotal! + _cart!.tax!).toStringAsFixed(2);
    if (double.parse(amountWithoutTaxDelivery) <
        double.parse(_offers[index].moa.toString())) {
      openSnacbar(
          _scaffoldKey, 'Minimum order should be of \$${_offers[index].moa}');
      return;
    }

    double discount = (double.parse(amountWithoutTaxDelivery) *
            double.parse(_offers[index].percentage.toString())) /
        100;
    if (discount > double.parse(_offers[index].mpd.toString())) {
      discount = double.parse(_offers[index].mpd.toString());
    }
    setState(() {
      _appliedIndex = index;
      // _total -= discount;
      _amount = (double.parse(_amount) - discount).toString();
      selectOffer = _offers[index].id!;
    });
  }

  _placeOrder() async {
    _addToCartBloc.setValue(paymentOption);

    if (paymentOption.paymentMethod == PaymentMethod.card) {
      // StripePaymentIntent? paymentIntent = await Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => PayUsingTerminal(
      //       cart: widget.cart!,
      //     ),
      //   ),
      // );
      // if (paymentIntent != null) {
      //   _addToCartBloc.setPaymentIntent(paymentIntent);
      _handleServerAndPrint(
        //Comentado codepaeza 31/05/2023
        method: PaymentMethod.card, //Comentado codepaeza 31/05/2023
      );
      // }
    } else if (paymentOption.paymentMethod == PaymentMethod.ath) {
      _handleServerAndPrint(method: PaymentMethod.ath);
    } else {
      setState(() {});
      bool changeTenderd = await showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return Calculator(
                  total: widget.restOrder.total!,
                  orderNo: widget.restOrder.id.toString(),
                  userId: _user!.id!,
                  forKioskOrder: false,
                );
              }) ??
          false;

      if (changeTenderd) //Comentado 31/05/2023 codepaeza
        //_handleServerAndPrint(method: paymentOption.paymentMethod!);  //Comentado 31/05/2023 codepaeza
        _handleServerAndPrint(method: PaymentMethod.cash);
      print(
          'Aquí se da la instrucción para ejecutar _handleServerAndPrint - summary_page');
      print(paymentOption);
    }
  }

  Future<bool> _handlePayWithCreditCard(Cart cart, PaymentMethod pm) async {
    bool isPaid = false;

    final CreditCardBloc ccb =
        Provider.of<CreditCardBloc>(context, listen: false);

    var hasInternet = await AppService().checkInternet();
    if (hasInternet == false) {
      openSnacbar(context, 'no internet');
    } else {
      setState(() {
        _loadingPlaceOrderState = true;
        print('Se está ejecutando PlaceOrderBloc');
      });
      await ccb.payCreadit(cart.total!, cart.id!, pm);
      if (ccb.hasError == false) {
        openSnacbar(context, ccb.responseType);
        if (ccb.responseType == 'Approved') {
          isPaid = true;
          _acntNumber = ccb.acntLast;
        }
      } else {
        openSnacbar(context, ccb.errorCode);
        print(ccb.errorCode);
      }
      setState(() {
        _loadingPlaceOrderState = false;
      });
    }

    return isPaid;
  }

  // Handle to server and print
  _handleServerAndPrint({
    required PaymentMethod method,
  }) async {
    final PlaceOrderBloc pob =
        Provider.of<PlaceOrderBloc>(context, listen: false);

    await AppService().checkInternet().then((hasInternet) async {
      if (hasInternet == false) {
        openSnacbar(context, 'no internet');
      } else {
        setState(() {
          _loadingPlaceOrderState = true;
          print('Se está ejecutando PlaceOrderBloc');
        });

        if (method == PaymentMethod.ath || method == PaymentMethod.card) {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.white,
                child: Center(
                  child: Image.asset('assets/images/card.png'),
                ),
              );
            },
          );
          bool isApprovedDebit = await _handlePayWithCreditCard(_cart!, method);

          Navigator.pop(context);

          if (isApprovedDebit) {
            pob
                .placeOrderByDb(
                    _user!,
                    _cart!,
                    widget.deliveryMode!,
                    method,
                    widget.restOrder.tableName!,
                    selectOffer,
                    widget.tax!,
                    Provider.of<HomepageRestaurantBloc>(context, listen: false)
                        .shiftId!)
                .then((_) async {
              if (pob.hasError == false) {
                _orderConfirmedMessage = pob.msg!;
                if (_orderConfirmedMessage == "your order has been Confirmed") {
                  // _orderConfirmedMessage = "Your order was processed successfully";
                  _orderConfirmedMessage =
                      "Your order # ${pob.orderId} was processed successfully";
                }

                _invoiceNumber = pob.invoiceNumber ?? "";

                ///
                // _handleGetOrderById(pob, pob.orderId!);

                setState(() {});
                await Future.delayed(const Duration(seconds: 2));

                // Close order
                await _handleCloseOrder(pob.orderId!, method);

                /// update cart
                _cart?.ordered = 1;
                await _dbHandler.updateCart(_cart!.toJson(), _cart!.id!);

                setState(() {
                  _isLoaded = true; //Descomentado
                  print(pob.orderId);
                });
              } else {
                openSnacbar(context, pob.errorCode);
                print(pob.errorCode);
              }
              setState(() {
                _loadingPlaceOrderState = false;
              });
            });
          }
        } else {
          pob
              .placeOrderByDb(
                  _user!,
                  _cart!,
                  widget.deliveryMode!,
                  method,
                  widget.restOrder.tableName!,
                  selectOffer,
                  widget.tax!,
                  Provider.of<HomepageRestaurantBloc>(context, listen: false)
                      .shiftId!)
              .then((_) async {
            if (pob.hasError == false) {
              _orderConfirmedMessage = pob.msg!;
              if (_orderConfirmedMessage == "your order has been Confirmed") {
                // _orderConfirmedMessage = "Your order was processed successfully";
                _orderConfirmedMessage =
                    "Your order # ${pob.orderId} was processed successfully";
              }

              _invoiceNumber = pob.invoiceNumber ?? "";

              ///
              // _handleGetOrderById(pob, pob.orderId!);

              setState(() {});
              await Future.delayed(const Duration(seconds: 2));

              // Close order
              await _handleCloseOrder(pob.orderId!, method);

              /// update cart
              _cart?.ordered = 1;
              await _dbHandler.updateCart({"ordered": 1}, _cart!.id!);

              setState(() {
                _isLoaded = true; //Descomentado
                print(pob.orderId);
              });
            } else {
              openSnacbar(context, pob.errorCode);
              print(pob.errorCode);
            }
            setState(() {
              _loadingPlaceOrderState = false;
            });
          });
        }
      }
    });
  }

  /// Get order by id
  _handleGetOrderById(PlaceOrderBloc pob, int orderId) {
    pob.getOrderById(orderId).then((value) async {
      if (pob.hasError) {
        openSnacbar(context, pob.errorCode);
      } else {
        var orderId = await _dbHandler.insertOrder(pob.order!.toJson());
        print('====== Saved order id: $orderId ======');
      }
    });
  }

  _handleCloseOrder(int orderId, PaymentMethod paymentMode) async {
    print("in close order");
    _addToCartBloc.setPrintModel(_cart);

    setState(() {
      // orderNo = orderId;
    });
    final CloseOrderBloc cob =
        Provider.of<CloseOrderBloc>(context, listen: false);

    if (cob.orderState == 2) {
      await printThirdData();
    } else {
      await printCustomData();
    }

    nextScreen(
      context,
      OrderSuccessPage(
        orderNo: orderId,
        tableName: widget.restOrder.tableName,
        cart: _cart,
        method: paymentMode,
        price: _cart!.total,
      ),
    );
    setState(() {
      _loadingPlaceOrderState = false;
      _orderPlaced = true;
    });
  }

  double printWidth = 512;
  double sysWidth = 0;

  Widget printDivider({dynamic width}) {
    sysWidth = MediaQuery.of(context).size.width;
    width ??= sysWidth;
    final dashCount = (width / (2 * 9)).floor();
    return Flex(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      direction: Axis.horizontal,
      children: List.generate(dashCount, (_) {
        return const SizedBox(
          width: 9,
          height: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(color: Colors.grey),
          ),
        );
      }),
    );
  }

  Widget wdPrintCustomerData(Cart printData) {
    // print("orderNo $orderNo");
    if (orderNo != null) {
      // print("Customer Printer");
    }
    return
        // orderNo == null ? Container() :
        SingleChildScrollView(
            child: RepaintBoundary(
                key: globalCustomerKey,
                child: Container(
                  width: printWidth + 65,
                  color: Colors.white,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    color: Colors.white,
                    width: printWidth,
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            Text(Config.storeName,
                                style: TextStyle(fontSize: 35),
                                textAlign: TextAlign.center),
                            Text.rich(TextSpan(
                                style: TextStyle(fontSize: 20),
                                text: Config.address ?? '',
                                children: [
                                  TextSpan(
                                    text: ' ',
                                  ),
                                  TextSpan(
                                    text: Config.city ?? '',
                                  ),
                                ])),
                            Text(Config.contact ?? '',
                                style: TextStyle(fontSize: 20))
                          ],
                        ),
                        Container(
                          width: printWidth - 30,
                          child: printDivider(width: printWidth - 30),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Invoice #: $_invoiceNumber",
                                  // "Order #: ${orderNo == null ? '#' : orderNo}",
                                  style: TextStyle(fontSize: 20)),
                              Text("POS", style: TextStyle(fontSize: 20))
                              // Text("online", style: TextStyle(fontSize: 20))
                            ],
                          ),
                        ),
                        if (_addToCartBloc.isDineIn)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Tags :${_addToCartBloc.tags}",
                                    style: TextStyle(fontSize: 20)),
                                // Text("online", style: TextStyle(fontSize: 20))
                              ],
                            ),
                          ),
                        Container(
                          width: printWidth - 30,
                          child: printDivider(width: printWidth - 30),
                        ),
                        Column(
                          children: [
                            ...printData.cart!
                                .asMap()
                                .map((key, value) => MapEntry(
                                    key,
                                    Container(
                                      child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 3),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                        "${value.quantity.toString()}X  ",
                                                        style: TextStyle(
                                                            fontSize: 20)),
                                                    Text(value.itemName ?? "",
                                                        style: TextStyle(
                                                            fontSize: 20))
                                                  ],
                                                ),
                                                Text(
                                                    "${value.quantity! * value.itemPrice!}",
                                                    style:
                                                        TextStyle(fontSize: 20))
                                              ],
                                            ),
                                            if (value.customization != null)
                                              Column(
                                                children: [
                                                  ...value.customization!
                                                      .asMap()
                                                      .map((key, value) =>
                                                          MapEntry(
                                                              key,
                                                              Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(5),
                                                                child: Text(value
                                                                    .optionName!),
                                                              )))
                                                      .values
                                                      .toList()
                                                ],
                                              )
                                          ],
                                        ),
                                      ),
                                    )))
                                .values
                                .toList(),
                            SizedBox(height: 15),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("SUB TOTAL:",
                                      style: TextStyle(fontSize: 22)),
                                  Text(
                                      // "\$${(_cartModel.subtotal - _cartModel.foodTax - _cartModel.convienienceFee - _cartModel.drinkTax - _cartModel.tax).toStringAsFixed(2)}",
                                      '\$${_addToCartBloc.calculateSubTotal(_restOrderItems).toStringAsFixed(2)}',
                                      style: TextStyle(fontSize: 22)),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Food Tax:",
                                      style: TextStyle(fontSize: 20)),
                                  // Text("\$${_cartModel.foodTax.toStringAsFixed(2)}",
                                  Text(
                                      '\$${widget.restOrder.foodTax!.toStringAsFixed(2)}',
                                      style: TextStyle(fontSize: 20))
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Drink Tax:",
                                      style: TextStyle(fontSize: 20)),
                                  Text(
                                      // "\$${_cartModel.drinkTax.toStringAsFixed(2)}",
                                      '\$${widget.restOrder.drinkTax!.toStringAsFixed(2)}',
                                      style: TextStyle(fontSize: 20))
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("City Tax:",
                                      style: TextStyle(fontSize: 20)),
                                  // Text("\$${_cartModel.tax.toStringAsFixed(2)}",
                                  Text(
                                      '\$${widget.restOrder.tax!.toStringAsFixed(2)}',
                                      style: TextStyle(fontSize: 20))
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Convinence fee:",
                                      style: TextStyle(fontSize: 20)),
                                  Text(
                                      '\$${widget.restOrder.convienenceFee!.toStringAsFixed(2)}',
                                      style: TextStyle(fontSize: 20))
                                ],
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 150,
                              child: Column(
                                children: [
                                  printDivider(width: 150),
                                  SizedBox(height: 5),
                                  printDivider(width: 150),
                                ],
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("TOTAL:", style: TextStyle(fontSize: 30)),
                              Text('\$${widget.restOrder.amount}',
                                  style: TextStyle(fontSize: 30))
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Visa Tendered:",
                                  style: TextStyle(fontSize: 20)),
                              Text('\$${widget.restOrder.amount}',
                                  style: TextStyle(fontSize: 20))
                            ],
                          ),
                        ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.end,
                        //   children: [
                        //     Container(
                        //       width: 150,
                        //       child: Column(
                        //         children: [
                        //           printDivider(width: 150),
                        //           SizedBox(height: 5),
                        //           printDivider(width: 150),
                        //         ],
                        //       ),
                        //     )
                        //   ],
                        // ),
                        if (_addToCartBloc.isCard == 1)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Last 4", style: TextStyle(fontSize: 20)),
                                SizedBox(width: 20),
                                Text("${_addToCartBloc.cardNumer}",
                                    style: TextStyle(fontSize: 20)),
                              ],
                            ),
                          ),
                        // if (_addToCartBloc.isCard == 0)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Payment: ", style: TextStyle(fontSize: 20)),
                              SizedBox(width: 20),
                              Text(
                                  _addToCartBloc.isCard == PaymentMethod.ath
                                      ? "ATH: $_acntNumber"
                                      : "Cash",
                                  style: TextStyle(fontSize: 20)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Order type: ",
                                  style: TextStyle(fontSize: 20)),
                              SizedBox(width: 20),
                              Text(
                                  _addToCartBloc.isDineIn == true
                                      ? 'Dine in'
                                      : "Take out",
                                  style: TextStyle(fontSize: 20)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  "${DateFormat("MM/dd/yyyy").format(DateTime.now())}",
                                  style: TextStyle(fontSize: 20)),
                              SizedBox(width: 20),
                              Text(
                                  "${DateFormat("hh:mm:ss a").format(DateTime.now())}",
                                  style: TextStyle(fontSize: 20)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Text("Thank you:",
                              style: TextStyle(fontSize: 20)),
                        ),
                      ],
                    ),
                  ),
                )));
  }

  Widget wdPrintKitchenData(Cart printData) {
    // print("Kitchen Printer");
    return SingleChildScrollView(
        child: RepaintBoundary(
      key: globalKitchenKey,
      child: Container(
        width: printWidth + 65,
        color: Colors.white,
        alignment: Alignment.centerLeft,
        child: Container(
          color: Colors.white,
          width: printWidth,
          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
            children: [
              Container(
                width: printWidth - 30,
                child: printDivider(width: printWidth - 30),
              ),
              SizedBox(height: 5),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("Kitchen",
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.w600))
              ]),
              Container(
                width: printWidth - 30,
                child: printDivider(width: printWidth - 30),
              ),
              // Padding(
              //   padding: EdgeInsets.symmetric(vertical: 10),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Text(
              //           "Server: ${employee != null ? employee.name : "Cashier"}",
              //           style: TextStyle(fontSize: 20)),
              //       Text("Station: 1", style: TextStyle(fontSize: 20)),
              //     ],
              //   ),
              // ),

              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${DateFormat("MM/dd/yyyy").format(DateTime.now())}",
                        style: TextStyle(fontSize: 20)),
                    Text("Kiosk", style: TextStyle(fontSize: 20)),
                    Text("${DateFormat("hh:mm:ss a").format(DateTime.now())}",
                        style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
              Container(
                width: printWidth - 30,
                child: printDivider(width: printWidth - 30),
              ),
              SizedBox(height: 5),
              Container(
                width: printWidth - 30,
                child: printDivider(width: printWidth - 30),
              ),
              Column(
                children: [
                  ...printData.cart!
                      .asMap()
                      .map((key, value) => MapEntry(
                          key,
                          Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 3),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text("${value.quantity.toString()}X  ",
                                          style: TextStyle(fontSize: 25)),
                                      Text(value.itemName!,
                                          style: TextStyle(fontSize: 25))
                                    ],
                                  ),
                                  if (value.customization != null)
                                    Column(
                                      children: [
                                        ...value.customization!
                                            .asMap()
                                            .map((key, value) => MapEntry(
                                                key,
                                                Container(
                                                  padding: EdgeInsets.all(5),
                                                  child: Text(value.optionName!,
                                                      style: TextStyle(
                                                          fontSize: 22)),
                                                )))
                                            .values
                                            .toList()
                                      ],
                                    )
                                ],
                              ),
                            ),
                          )))
                      .values
                      .toList(),
                  SizedBox(height: 15),
                ],
              ),
              Container(
                width: printWidth - 30,
                child: printDivider(width: printWidth - 30),
              ),
              SizedBox(height: 5),
              Container(
                width: printWidth - 30,
                child: printDivider(width: printWidth - 30),
              ),
              if (_addToCartBloc.isCard == 1)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Last 4", style: TextStyle(fontSize: 20)),
                      SizedBox(width: 20),
                      Text("${_addToCartBloc.cardNumer}",
                          style: TextStyle(fontSize: 20)),
                    ],
                  ),
                ),
              // if (_addToCartBloc.isCard == 0)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Payment: ", style: TextStyle(fontSize: 20)),
                    SizedBox(width: 20),
                    Text(
                        _addToCartBloc.isCard == PaymentMethod.ath
                            ? "ATH: $_acntNumber"
                            : "Cash",
                        style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Order type: ", style: TextStyle(fontSize: 20)),
                    SizedBox(width: 20),
                    Text(
                        _addToCartBloc.isDineIn == true
                            ? 'Dine in'
                            : "Take out",
                        style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                child: Text(
                  "Invoice #: $_invoiceNumber",
                  // "Order #: ${orderNo == null ? '#' : orderNo}",
                  style: TextStyle(fontSize: 30),
                ),
              ),
              if (_addToCartBloc.isDineIn)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Tags :${_addToCartBloc.tags}",
                          style: TextStyle(fontSize: 20)),
                      // Text("online", style: TextStyle(fontSize: 20))
                    ],
                  ),
                ),
              Container(
                width: printWidth - 30,
                child: printDivider(width: printWidth - 30),
              ),
              SizedBox(height: 5),
              Container(
                width: printWidth - 30,
                child: printDivider(width: printWidth - 30),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

enum OrderType {
  takeOut,
  dineIn,
}

class PaymentOptions {
  OrderType? type;
  String tags = "";
  PaymentMethod? paymentMethod;
  int? tipPercentage;

  PaymentOptions({
    this.type,
    this.paymentMethod,
    this.tipPercentage,
  });
  bool get readyToPay {
    return type != null && paymentMethod != null;
  }
}
