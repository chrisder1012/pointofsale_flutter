import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
// import 'package:http/http.dart' as http;

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zabor/models/basket.dart';
import 'package:zabor/models/cart.dart';
import 'package:zabor/models/keep_item.dart';
import 'package:zabor/models/rest_customer.dart';
import 'package:zabor/models/rest_order.dart';
import 'package:zabor/models/rest_table.dart';
import 'package:zabor/models/restaurant.dart';
import 'package:zabor/models/tax.dart';
import 'package:zabor/pages/home.dart';
import 'package:zabor/pages/left_order_page.dart';
// import 'package:zabor/pages/loading_screen.dart';
import 'package:zabor/pages/print_register_page.dart';
import 'package:zabor/pages/right_menu_page.dart';
import 'package:zabor/pages/sign_in.dart';
import 'package:zabor/pages/summary_page.dart';
import 'package:zabor/pages/takeout_content.dart';
import 'package:zabor/utils/t1_string.dart';
import 'package:zabor/widget/dialog_widgets.dart';

import '../blocs/add_to_cart_bloc.dart';
import '../blocs/basket_bloc.dart';
import '../blocs/close_order_bloc.dart';
import '../blocs/restaurant_menu_bloc.dart';
import '../blocs/sign_in_bloc.dart';
import '../blocs/tax_bloc.dart';
import '../config/config.dart';
import '../db/add_rest_customers.dart';
import '../db/database_handler.dart';
import '../models/compliment_item.dart';
import '../models/customization.dart';
import '../models/customization_item.dart';
import '../models/group.dart';
import '../models/item.dart';
import '../models/menu_item.dart';
import '../models/rest_order_item.dart';
// import '../print/kitchen_print.dart';
import '../services/services.dart';
import '../utils/next_screen.dart';
import '../utils/snacbar.dart';
import '../utils/utils.dart';
import '../widget/topbar_icon_widget.dart';
import '../widget/topbar_item_widget.dart';
import 'sign_in2.dart';

class CartPage extends StatefulWidget {
  const CartPage({
    Key? key,
    this.orderState,
    this.restTable,
    this.personNum,
    this.restOrder,
    this.cart,
    this.responses,
    this.tables,
    this.isTag = false,
    this.isRetrieve = false,
  }) : super(key: key);
  final int? orderState;
  final RestTable? restTable;
  final int? personNum;

  final RestOrder? restOrder;
  final Cart? cart;
  final Responses? responses;
  final List<RestTable>? tables;
  final bool? isTag;
  final bool? isRetrieve;

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with TickerProviderStateMixin {
  final DatabaseHandler _dbHandler = DatabaseHandler();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _keepController = TextEditingController();

  int personNumber = 0;
  int orderState = 0;
  int? tableId;
  String? tableName;
  int? tableGroupId;
  bool _takeoutProcessing = false;
  bool _isDineIn = false;
  // late AddToCartBloc _addToCartBloc;

  //////////////////////////////////////////////////////////
  ///         Right Menu
  //////////////////////////////////////////////////////////
  final List<Group> _groups = [];
  final List<MItem> _menuItems = [];

  final Map<MItem, int> _mapItem = {};
  final List<Customization> _customizations = [];

  Responses? _res;

  var _isMenuLoaded = false;

  //////////////////////////////////////////////////////////
  ///             Order
  //////////////////////////////////////////////////////////
  final List<Item> _orderingItems = [];
  final List<Item> _orderedItems = [];

  final List<Item> _prevCartItems = [];

  var transactionTime = DateTime.now();

  Cart? _cart;
  Cart? printCart;

  RestOrder? _restOrder;
  Tax? _tax;
  RestCustomer? _selectRestCustomer;
  Basket? _basket;
  int? userId;

  final List<RestOrder> _restOrders = [];
  final List<RestOrderItem> _restOrderItems = [];
  final List<RestCustomer> _restCustomers = [];

  final Map<RestOrderItem, List<CustomizationItem>> _mapCI = {};

  var _isOrderLoading = false;

  var _width = 0.0;
  var _height = 0.0;

  var _carting = false;
  bool _paying = false;
  bool wantPrintForPay = false;

  /// Menu group

  // var _curGroupName = '';

  //////////////////////////////////////////////////////////
  ///         Right Menu
  //////////////////////////////////////////////////////////
  _initMenuState() async {
    // Get group data
    await _handleGroupData();

    // Check rest customers and insert all rest customers to db
    _dbHandler.initializeDB().whenComplete(() async {
      var restCustomers = await _dbHandler.retireveRestCustomer();
      if (restCustomers.isEmpty) {
        addRestCustomers().whenComplete(() async {});
      }
    });
  }

  //////////////////////////////////////////////////////////
  ///         Left Order
  //////////////////////////////////////////////////////////
  _initOrderState() async {
    _cart = widget.cart ?? Cart();
    print(t1OrderState.tr() + "$orderState");
    if (orderState == 1) {
      print("Init Cart==00: ${_cart!.id}");
      _orderedProcess(widget.restOrder!.id!);
    } else {
      await _getDataFromDb();
    }

    print("Init Cart==11: ${_cart!.id}");
  }

  ///
  /// Make Ordering Item
  ///
  _saveOrderingItem(Cart cart) {
    var newCart = cart;
    print(t1SavingOrder.tr());
    print(newCart.cart!.length);
    print(["_restOrderItems.length:", _restOrderItems.length]);
    _restOrderItems.clear();
    for (var element in newCart.cart!) {
      var roi = RestOrderItem();
      // roi.customizations = element.customizations;
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
      _mapCI[roi] = element.customization!;
    }

    setState(() {});
  }

  ///
  /// Get tables from db
  ///
  Future<void> _getDataFromDb() async {
    try {
      // Rest Customer
      await _dbHandler.retireveRestCustomer().then((value) async {
        _restCustomers.addAll(value);
      });
      // Rest Order
      await _dbHandler.retireveRestOrders().then((value) {
        _restOrders.addAll(value);
      });

      print("_restCustomers $_restCustomers");
      print("_restOrders $_restOrders");
    } catch (e) {
      ///
    }
  }

  ///
  /// Get cart from rest order
  ///
  _getCartFromRestOrder(RestOrder restOrder) {
    _cart ??= Cart();

    _cart!.cart = [];
    _cart!.id = restOrder.cartId;
    _cart!.userId = restOrder.userId;
    _cart!.resId = restOrder.resId;
    _cart!.foodTax = restOrder.foodTax;
    _cart!.drinkTax = restOrder.drinkTax;
    _cart!.tax = restOrder.tax;
    _cart!.convienienceFee = restOrder.convienenceFee;
    _cart!.total = restOrder.total;
    _cart!.subtotal = restOrder.subTotal;
    _cart!.cod = restOrder.cod;
  }

  ///
  /// Get carts from rest order items
  ///
  _getCartItemsFromRestOrderItem(
      List<RestOrderItem> rois, List<ComplimentItem> cis) {
    // Get customization items
    Map<int, List<CustomizationItem>> mapCustomItem = {};
    for (var element in cis) {
      if (mapCustomItem[element.cartItemId!] == null) {
        mapCustomItem[element.cartItemId!] = [];
      }
      var ci = CustomizationItem();
      ci.optionName = element.optionName;
      ci.optionPrice = element.optionPrice;
      ci.optionId = element.ciId;
      mapCustomItem[element.cartItemId!]!.add(ci);
    }

    for (var element in rois) {
      var cartItem = Item();
      cartItem.itemId = element.itemId;
      cartItem.itemName = element.itemName;
      cartItem.itemPrice = element.price;
      cartItem.taxtype = element.taxtype;
      cartItem.isFood = element.isFood;
      cartItem.isState = element.isState;
      cartItem.isCity = element.isCity;
      cartItem.note = element.note;
      cartItem.quantity = element.quantity;
      cartItem.customization = [];
      if (mapCustomItem[element.id] != null) {
        cartItem.customization!.addAll(mapCustomItem[element.id]!);
      }
      // Add item
      _cart!.cart!.add(cartItem);
    }
  }

  ///
  /// Pre process for ordered
  ///
  Future<void> _orderedProcess(int id) async {
    // Get current order
    await _dbHandler.retireveRestOrder(id).then((restOrder) async {
      _restOrder = restOrder;
      // Get cart from order
      await _getCartFromRestOrder(restOrder);
      // Rest Order Item
      await _dbHandler.retireveRestOrderItemFromOrderId(id).then((rois) async {
        // _restOrderItems.addAll(rois);
        //
        // Compliment items
        await _dbHandler.retireveComplimentItemFromOrderId(id).then((value) {
          // _complimentItems.addAll(value);
          //
          _getCartItemsFromRestOrderItem(rois, value);
          //
          _handleGetTax();
        });
        setState(() {});
      });
    });
  }

  @override
  void initState() {
    orderState = widget.orderState!;

    final CloseOrderBloc cob =
        Provider.of<CloseOrderBloc>(context, listen: false);
    cob.orderState = widget.orderState!;

    if (widget.cart != null) {
      if (widget.cart!.cart != null) {
        _orderedItems.addAll(widget.cart!.cart!);
        _orderingItems.addAll(widget.cart!.cart!);

        _prevCartItems.addAll(widget.cart!.cart!);
      }
    }

    printCart = null;

    userId = context.read<SignInBloc>().uid;
    if (orderState != 2) {
      personNumber = widget.personNum!;
      tableId = widget.restTable!.id;
      tableName = widget.restTable!.name;
      tableGroupId = widget.restTable!.tableGroupId;
    } else {
      // Takeout
      personNumber = 1;
      tableId = -1;
      tableName = t1TakeOut.tr();
      tableGroupId = -1;
    }

    // menu init state
    _initMenuState();

    // order init state
    _initOrderState();

    // print('widget.restOrder ${widget.restOrder!.cartId}');

    if (widget.isRetrieve == true) {
      Future.delayed(Duration(seconds: 1)).then((value) => _retrieveDialog());
    }

    super.initState();
  }

  GlobalKey kitchenPrintKey2 = GlobalKey();
  GlobalKey kitchenPrintKey3 = GlobalKey();
  GlobalKey globalCustomerKey = GlobalKey();
  double printWidth = 512;
  double sysWidth = 0;
  String? orderNo;
  Widget printDivider({double? width}) {
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

  Widget kitchenDataWidget(Cart printData) {
    return Container(
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
              Text(t1Kitchen.tr(),
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.w600))
            ]),
            Container(
              width: printWidth - 30,
              child: printDivider(width: printWidth - 30),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(t1TableNum.tr(), style: TextStyle(fontSize: 25)),
                  Text((widget.restTable?.num ?? "").toString(),
                      style: TextStyle(fontSize: 25)),
                ],
              ),
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
                  Text(t1POS.tr(), style: TextStyle(fontSize: 20)),
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

            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              child: Text(
                t1TableNo.tr() +
                    "${widget.restTable?.num == null ? '#' : widget.restTable!.num}",
                style: TextStyle(fontSize: 30),
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
    );
  }

  Widget wdPrintGlobalData(Cart printData) {
    Cart pCart = Cart();
    pCart.cart = [];
    pCart.cart!.addAll(printData.cart ?? []);

    if (pCart.cart!.length > 0) {
      pCart.cart = pCart.cart?.where((item) => item.print2 == 1).toList();
    }
    return SingleChildScrollView(
        child: RepaintBoundary(
      key: globalCustomerKey,
      child: kitchenDataWidget(pCart),
    ));
  }

  Widget wdPrintKitchenData2(Cart printData) {
    Cart pCart = Cart();
    pCart.cart = [];
    pCart.cart!.addAll(printData.cart ?? []);

    if (pCart.cart!.length > 0) {
      pCart.cart = pCart.cart?.where((item) => item.print2 == 1).toList();
    }

    return SingleChildScrollView(
        child: RepaintBoundary(
      key: kitchenPrintKey2,
      child: kitchenDataWidget(pCart),
    ));
  }

  Widget wdPrintKitchenData3(Cart printData) {
    Cart pCart = Cart();
    pCart.cart = [];
    pCart.cart!.addAll(printData.cart ?? []);

    if (pCart.cart!.length > 0) {
      pCart.cart = pCart.cart?.where((item) => item.print3 == 1).toList();
    }

    return SingleChildScrollView(
        child: RepaintBoundary(
      key: kitchenPrintKey3,
      child: kitchenDataWidget(pCart),
    ));
  }

  bool callPrint = false;

  bool _isLoaded = false;
  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;

    isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    // _addToCartBloc = Provider.of<AddToCartBloc>(context, listen: true);

    if (isPortrait) {
      scaleWidth = _width / Config().defaultWidth;
      scaleHeight = _height / Config().defaultHeight;
    } else {
      scaleWidth = _width / Config().defaultHeight;
      scaleHeight = _height / Config().defaultWidth;
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[800],
      body: Stack(
        children: [
          SafeArea(
            child: Stack(
              children: [
                printCart == null ? Container() : wdPrintGlobalData(printCart!),
                printCart == null
                    ? Container()
                    : wdPrintKitchenData2(printCart!),
                printCart == null
                    ? Container()
                    : wdPrintKitchenData3(printCart!),
                Container(
                  color: Colors.grey[900],
                  child: _body(),
                ),
              ],
            ),
          ),
          !_isLoaded
              ? SizedBox.shrink()
              : Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: Colors.white,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
        ],
      ),
    );
  }

  _body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _topBar(),
        _content(),
        // _bottomBar(),
      ],
    );
  }

  _topBar() {
    if (orderState == 0) {
      return _topBar0();
    }
    if (orderState == 1) {
      return _topBar1();
    }
    if (orderState == 2) return _topBar2();
  }

  _topBar0() {
    return SizedBox(
      width: _width,
      height: setScaleHeight(50),
      child: Row(
        children: [
          topbarIconItem(
              bgColor: const Color(0xFF519991),
              iconData: Icons.arrow_back,
              onPressed: () {
                if (_orderingItems.isEmpty) {
                  Navigator.pop(context, false);
                } else {
                  _exitDialog();
                }
              }),
          topbarItem(
            title: t1Clear.tr(),
            bgColor: Colors.deepOrange,
            onTap: () {
              if (_orderingItems.isNotEmpty) {
                _orderingItems.clear();

                // Added by Zohaib
                _restOrderItems.clear();
                print(t1ClearingItems.tr());
                print(_restOrderItems.length);
                setState(() {});
              }
            },
          ),
          topbarItem(
              title: t1Course.tr(), bgColor: Colors.greenAccent, onTap: () {}),
          topbarItem(title: t1hold.tr(), bgColor: Colors.green, onTap: () {}),
          topbarItem(
              title: t1Table.tr(),
              bgColor: Colors.yellow,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ),
                );
              }),
          topbarIconItem(
              bgColor: Colors.cyan,
              iconData: Icons.group_outlined,
              onPressed: () {
                _changeNumberOfPersons();
              }),
          topbarIconItem(
              bgColor: Colors.teal,
              iconData: Icons.search_outlined,
              onPressed: () {}),
        ],
      ),
    );
  }

  _topBar1() {
    return SizedBox(
      width: _width,
      height: setScaleHeight(50),
      child: Row(
        children: [
          topbarIconItem(
              bgColor: const Color(0xFF519991),
              iconData: Icons.arrow_back,
              onPressed: () {
                if (_orderingItems.isEmpty) {
                  Navigator.pop(context, false);
                } else {
                  _exitDialog();
                }
              }),
          topbarItem(
            title: t1Fire.tr(),
            bgColor: Colors.deepOrange,
            onTap: () {},
          ),
          topbarItem(
              title: t1NewOrder.tr(), bgColor: Colors.green, onTap: () {}),
          topbarItem(
              title: t1Split.tr(), bgColor: Colors.orangeAccent, onTap: () {}),
          topbarItem(
              title: t1Customer.tr(), bgColor: Colors.yellow, onTap: () {}),
          topbarIconItem(
              bgColor: Colors.cyan,
              iconData: Icons.group_outlined,
              onPressed: () {
                _changeNumberOfPersons();
              }),
          topbarIconItem(
              bgColor: Colors.teal,
              iconData: Icons.search_outlined,
              onPressed: () {}),
        ],
      ),
    );
  }

  _topBar2() {
    return SizedBox(
      width: _width,
      height: setScaleHeight(50),
      child: Row(
        children: [
          topbarIconItem(
              bgColor: const Color(0xFF519991),
              iconData: Icons.arrow_back,
              onPressed: () {
                if (_orderingItems.isEmpty) {
                  Navigator.pop(context, false);
                } else {
                  _exitDialog();
                }
              }),
          topbarItem(
            title: t1Clear.tr(),
            bgColor: Colors.deepOrange,
            onTap: () {
              if (_orderingItems.isNotEmpty) {
                _orderingItems.clear();
                // Added by Zohaib
                _restOrderItems.clear();
                print(t1ClearingItems.tr());
                print(_restOrderItems.length);
                setState(() {});
              }
            },
          ),
          topbarItem(
              title: t1DineIn.tr(),
              bgColor: Colors.orangeAccent,
              onTap: () {
                _dineIn();
              }),
          topbarItem(
              title: t1Table.tr(),
              bgColor: Colors.yellow,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ),
                );
              }),
          topbarIconItem(
              bgColor: Colors.teal,
              iconData: Icons.search_outlined,
              onPressed: () {}),
        ],
      ),
    );
  }

  // Show exit dialog
  _exitDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            // backgroundColor: const Color(0xFF2d2f35),
            elevation: 0,
            shape: RoundedRectangleBorder(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                dialogTitle(MediaQuery.of(context).size.width,
                    title: t1WantExit.tr()),
                Row(
                  children: [
                    dialogButton(
                        name: t1Cancel.tr(),
                        backgroundColor: Colors.redAccent,
                        onClick: () {
                          Navigator.pop(context);
                        }),
                    dialogButton(
                        name: t1Confirm.tr(),
                        backgroundColor: Colors.greenAccent,
                        onClick: () {
                          Navigator.pop(context);
                          Navigator.pop(context, false);
                        }),
                  ],
                )
              ],
            ),
          );
        });
  }

  _content() {
    print(["orderState:", orderState]);
    return Expanded(
      child: Row(
        children: [
          orderState == 2 ? _takeoutContent() : _leftContent(),
          const VerticalDivider(width: 1, color: Colors.black),
          _rightContent(),
        ],
      ),
    );
  }

  _addCart(int upc) {
    MItem? menuItem;
    for (var group in _groups) {
      menuItem =
          group.items?.firstWhereOrNull((item) => item.upcNo == upc.toString());
      if (menuItem != null) break;
    }
    // var menuItem =
    //     _menuItems.firstWhereOrNull((item) => item.upcNo == upc.toString());
    if (menuItem == null) return;
    print('===== UPC No: ${menuItem.upcNo} =====');
    var item = _convertItem(menuItem);
    _orderingItems.add(item);
    // _curGroupName = group.name!;
    if (orderState != 2) {
      if (printCart == null) {
        printCart = Cart();
        printCart?.cart = [];
        printCart?.cart!.add(item);
      } else {
        printCart?.cart?.add(item);
      }
    }

    setState(() {});
  }

  _takeoutContent() {
    return SizedBox(
      width: isPortrait ? _width / 2 : _width / 3,
      child: TakeoutContent(
        orderState: orderState,
        responses: _res,
        mapCI: _mapCI,
        orderingItems: _orderingItems,
        isOrdering: _takeoutProcessing,
        onScan1: (upc) {
          _addCart(upc);
        },
        onScan2: (upc) {
          _addCart(upc);
        },
        isTag: widget.isTag,
        onSendTagClick: () async {
          if (_orderingItems.isNotEmpty) {
            var res = await _tagsDialog();
            if (res == true) {
              _keepItem(_keepController.text);
              _keepController.clear();
              Navigator.pop(context);
            }
          }
        },
        onPaymentClick: () async {
          if (_orderingItems.isEmpty) {
            return;
          }
          if (widget.isTag!) {
            var res = await _tagsDialog();
            if (res == null || res == false) {
              return;
            } else {
              _keepItem(_keepController.text);
              _keepController.clear();
            }
          }
          if (!kDebugMode) {
            var strPrinters = await Config.getPrinters();
            if (strPrinters == null) {
              openSnacbar(
                context,
                t1NoPrinterData.tr(),
                onPressed: () {
                  nextScreen(context, const PrintRegisterPage());
                },
              );
            }
          }

          final CloseOrderBloc cob =
              Provider.of<CloseOrderBloc>(context, listen: false);

          if (orderState != 2) {
            wantPrintForPay = await showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16.0))),
                    // backgroundColor: Colors.amber,
                    contentPadding: EdgeInsets.all(20),
                    //elevation: 10,
                    elevation: 0,
                    content: Text(
                      t1WantPrintReceipt.tr(),
                      style: TextStyle(
                        fontSize: setFontSize(isPortrait ? 25 : 35),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: /*const*/
                            Text(t1Yes.tr(), style: TextStyle(fontSize: 20)),
                      ),
                      SizedBox(width: 15),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange[400]),
                        child: /*const*/
                            Text(t1No.tr(), style: TextStyle(fontSize: 20)),
                      ),
                      SizedBox(width: 15),
                    ],
                  );
                });
            print(["wantPrintForPay==cart_page 925", wantPrintForPay]);

            cob.wantPrintForPay = wantPrintForPay;
          } else {
            cob.orderState = 2;
          }

          await _cartProcess(isPay: true);
          _pay(isPay: true);
        },
      ),
    );
  }

  _leftContent() {
    // print("_res ${_res!.id}");
    // print("_res ${widget.responses!.id}");
    return SizedBox(
      width: isPortrait ? _width / 2 : _width / 3,
      child: LeftOrderPage(
        orderState: orderState,
        orderedItems: _orderedItems,
        orderingItems: _orderingItems,
        mapCI: _mapCI,
        restTable: widget.restTable,
        responses: _res ?? widget.responses,
        cart: _cart,
        personNum: personNumber,
        onPayClick: _payClick,
        onCartClick: _cartClick,
        onPaymentClick: _paymentClick,
        isCarting: _carting,
        isPaying: _paying,
        restOrder: _restOrder ?? widget.restOrder,
        isOrderLoading: _isOrderLoading,
        onScan1: (upc) {
          _addCart(upc);
        },
        onScan2: (upc) {
          _addCart(upc);
        },
      ),
    );
  }

  Item _convertItem(MItem mItem) {
    Item item = Item();
    item.itemId = mItem.itemId;
    item.itemName = mItem.itemName;
    item.itemPrice = mItem.itemPrice;
    item.customization = [];
    // if (mItem.customizations != null) {
    //   item.customization!.addAll(mItem.customizations);
    // }
    item.quantity = 1;
    item.taxvalue = (mItem.isCity! ? double.parse(_res!.grandTax!) : 0.0) +
        (mItem.isFood! ? double.parse(_res!.foodTax!) : 0.0) +
        (mItem.isState! ? double.parse(_res!.drinkTax!) : 0.0);
    item.taxtype = mItem.taxtype;
    item.isCity = mItem.isCity;
    // tempCartItem.is_show = cartItem.isShow;
    item.isFood = mItem.isFood;
    item.isState = mItem.isState;
    // tempCartItem.is_note = cartItem.isNote;
    item.note = '';
    return item;
  }

  Future _payClick() async {
    print("In payment click");
    var strPrinters = await Config.getPrinters();
    if (strPrinters == null && !kDebugMode) {
      openSnacbar(
        context,
        t1NoPrinterData.tr(),
        onPressed: () {
          nextScreen(context, const PrintRegisterPage());
        },
      );
    } else {
      wantPrintForPay = await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16.0))),
              // backgroundColor: Colors.amber,
              contentPadding: EdgeInsets.all(16),
              //elevation: 10,
              elevation: 0,
              content: Text(
                t1WantPrintReceipt.tr(),
                style: TextStyle(
                  color: Config().appColor,
                  fontSize: setFontSize(isPortrait ? 25 : 35),
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: Text(
                    t1Yes.tr(),
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: setFontSize(isPortrait ? 20 : 30),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text(
                    t1No.tr(),
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: setFontSize(isPortrait ? 15 : 30),
                    ),
                  ),
                ),
              ],
            );
          });
      print(["wantPrintForPay==cart_page 1000", wantPrintForPay]);
      final CloseOrderBloc cob =
          Provider.of<CloseOrderBloc>(context, listen: false);
      cob.wantPrintForPay = wantPrintForPay;
      // _cartProcess(isPay: true);

      var restOrder = _restOrder ?? widget.restOrder;
      setState(() {
        _selectOrder = restOrder;
      });
      _pay(isPay: true);
    }
  }

  Future _cartClick() async {
    var strPrinters = await Config.getPrinters();

    if (strPrinters == null && !kDebugMode) {
      openSnacbar(
        context,
        t1NoPrinterData.tr(),
        onPressed: () {
          nextScreen(context, const PrintRegisterPage());
        },
      );
    } else {
      _cartProcess();
    }
  }

  _paymentClick() {
    if (_cart == null || _tax == null) return;
    print("move summarny by 001--onPaymentClick");
    nextScreen(
        context,
        SummaryPage(
          cart: _cart,
          tax: _tax,
          deliveryMode: 2,
          paymentMode: 1,
          restOrder: _restOrder!,
        ));
  }

  _rightContent() {
    return Container(
      color: Colors.grey[300],
      width: isPortrait ? _width / 2 - 1 : _width * 2 / 3 - 1,
      child: RightMenuPage(
        groups: _groups,
        menuItems: _menuItems,
        isMenuLoaded: _isMenuLoaded,
        mapItem: _mapItem,
        // orderingItems: _orderingItems,
        customization: _customizations,
        responses: _res,
        onItemSeleted: (item, group) {
          _orderingItems.add(item);
          // _curGroupName = group.name!;
          if (orderState != 2) {
            if (printCart == null) {
              printCart = Cart();
              printCart?.cart = [];
              printCart?.cart!.add(item);
            } else {
              printCart?.cart?.add(item);
            }
          }

          setState(() {});
        },
      ),
    );
  }

  /// Cart Process
  Future<int> _cartProcess({bool isPay = false}) async {
    int cartId = 0;
    bool isExistCart = false;

    double foodTax = 0.0;
    double drinkTax = 0.0;
    double total = 0.0;
    double tax = 0.0;
    double subTotal = 0.0;
    double convinieceFee = 0.0;

    Cart cart = _cart ?? Cart();
    if (_cart != null && _cart?.id != null) {
      isExistCart = true;
    }

    cart.cart = [];
    if (_orderingItems.length > 0) {
      setState(() {
        _takeoutProcessing = true;
      });
    }
    cart.cart!.addAll(_orderingItems);
    for (var ele in cart.cart!) {
      double itemPrice = 0.0;
      // double singleObjectPrice = 0.0;
      if (ele.customization != null) {
        for (var elementCust in ele.customization!) {
          itemPrice += elementCust.optionPrice! * ele.quantity!;
          // singleObjectPrice += elementCust.optionPrice;
        }
      }
      ele.itemPrice = ele.itemPrice! + itemPrice;
      if (ele.isFood!) {
        foodTax += (double.parse(_res!.foodTax!) / 100) *
            (ele.itemPrice! * ele.quantity!);
      }
      if (ele.isCity!) {
        tax += (double.parse(_res!.grandTax!) / 100) *
            (ele.itemPrice! * ele.quantity!);
      }
      if (ele.isState!) {
        drinkTax += (double.parse(_res!.drinkTax!) / 100) *
            (ele.itemPrice! * ele.quantity!);
      }
      subTotal += ele.itemPrice! * ele.quantity!;
    }

    if (_res!.convenienceFeeType == '2') {
      convinieceFee = ((subTotal * _res!.convenienceFee!) / 100);
    } else {
      if (_res!.convenienceFee != null) {
        convinieceFee = _res!.convenienceFee?.toDouble() ?? 0.0;
      }
    }
    subTotal = subTotal + foodTax + drinkTax + convinieceFee;
    total = subTotal + tax;
    cart.foodTax = foodTax;

    cart.tax = tax;
    cart.subtotal = subTotal;
    cart.total = total;
    cart.drinkTax = drinkTax;
    cart.foodTax = foodTax;
    cart.convienienceFee = double.parse(convinieceFee.toStringAsFixed(2));
    cart.userId = userId;
    cart.resId = _res!.resId;
    cart.tableId = tableId;
    if (!isExistCart) {
      // _handleAddCart(cart, isPay: isPay); //use later
      cartId = await _saveCartToDb(cart);
      if (cartId > 0 && !isPay) {
        Navigator.pop(context, true);
      }
    } else {
      // _handleUpdateCart(cart);
      var res = await _updateCartToDb(cart);
      cartId = cart.id!;
      if (res && !isPay) {
        Navigator.pop(context, true);
      }
    }
    return cartId;
  }

  RestOrder _getRestOrder(Cart cart) {
    var restOrder = RestOrder();

    // Customer info
    if (_selectRestCustomer == null) {
      restOrder.customerId = 0;
    } else {
      restOrder.customerId = _selectRestCustomer!.id;
      restOrder.customerName = _selectRestCustomer!.name;
    }

    // OrderNum and invoiceNum
    var orderNum = '';
    var invoiceNum = '';

    if (_restOrders.isEmpty) {
      orderNum = 1.toString().padLeft(5, '0');
      invoiceNum = 1.toString().padLeft(5, '0');
    } else {
      orderNum = (_restOrders.last.id! + 1).toString().padLeft(5, '0');
      invoiceNum = (_restOrders.last.id! + 1).toString().padLeft(5, '0');
    }
    restOrder.orderNum = orderNum;
    restOrder.invoiceNum = invoiceNum;

    // Table id and number
    restOrder.tableId = tableId;
    restOrder.tableName = tableName;
    restOrder.tableGroupId = tableGroupId;
    restOrder.personNum = personNumber;

    // Status
    restOrder.status = 0;

    // WaiterName init with Admin
    restOrder.waiterName = 'Admin';

    // MinimumCharge init with 0.0
    restOrder.minimumCharge = 0.0;

    // SubTotal price and amount
    restOrder.subTotal = _calculateItemPrice();
    restOrder.amount = _calculateItemPrice();

    // DiscountAmt and serviceAmt init with 0.0
    restOrder.discountAmt = restOrder.serviceAmt = 0.0;

    // tax1, tax2, tax3
    restOrder.tax1Amt = restOrder.tax1TotalAmt = 0.0;
    restOrder.tax2Amt = restOrder.tax2TotalAmt = 0.0;
    restOrder.tax3Amt = restOrder.tax3TotalAmt = 0.0;

    // DeliveryFee
    restOrder.deliveryFee = 0.0;

    // ServicePercentage and discountPercentage
    restOrder.servicePercentage = restOrder.discountPercentage = 0.0;

    // MinimumChargeType and minimumChargeSet
    restOrder.minimumChargeType = 0;
    restOrder.minimumChargeSet = 0.0;

    // OrderCount
    restOrder.orderCount = 0;

    // ReceiptPrintId
    restOrder.receiptPrinterId = 11;

    // OrderType and orderMemberType
    restOrder.orderType = restOrder.orderMemberType = 0;

    // TaxStatus and customerOrderStatus
    restOrder.taxStatus = restOrder.customerOrderStatus = 0;

    // OrderTime, UpdateTimeStamp, kdsOrderTime and transaction
    restOrder.transactionTime =
        DateFormat("yyyy-MM-dd HH:mm:ss").format(transactionTime);

    var curTime = DateTime.now();
    restOrder.updateTimeStamp = DateFormat("HH:mm").format(curTime);
    restOrder.kdsOrderTime = DateFormat("yyyy-MM-dd HH:mm").format(curTime);
    restOrder.orderTime = restOrder.kdsOrderTime;

    // Cart
    restOrder.cartId = cart.id;
    restOrder.userId = cart.userId;
    restOrder.resId = cart.resId;
    restOrder.foodTax = cart.foodTax;
    restOrder.drinkTax = cart.drinkTax;
    restOrder.tax = cart.tax;
    restOrder.convienenceFee = cart.convienienceFee;
    restOrder.total = restOrder.subTotal;
    if (cart.cod != null) {
      restOrder.cod = cart.cod;
    }
    return restOrder;
  }

  _processing(Cart cart, {bool isPay = false}) async {
    print("_processing $isPay");
    try {
      _saveOrderingItem(cart);

      var restOrder = _getRestOrder(cart);

      // Added by Zohaib
      if (widget.restOrder != null) {
        await _dbHandler
            .deleteRestOrder(widget.restOrder!.id!)
            .then((value) async {
          await _dbHandler
              .deleteRestOrderItemViaOrderId(widget.restOrder!.id!)
              .then((value) async {
            await _dbHandler
                .deleteComplimentItemViaOrderId(widget.restOrder!.id!)
                .then((value) {});
          });
        });
      }

      print("Rest Items===cartpage _saveorderfunction");
      print(_restOrderItems.length);

      List<ComplimentItem> compliItems = [];
      for (var element in _restOrderItems) {
        var orderItem = RestOrderItem();
        orderItem.orderId = 0; // Order Id
        orderItem.itemId = element.itemId; // itemId
        orderItem.itemName = element.itemName; // itemName
        orderItem.price = element.price; // price
        orderItem.qty = element.quantity?.toDouble(); // quantity
        orderItem.orderTime =
            DateFormat("yyyy-MM-dd HH:mm").format(transactionTime); // orderTime
        orderItem.status = 0; // Status
        orderItem.discountAmt = 0.0; // discountAmt
        orderItem.discountPercentage = 0.0; // discountPercentage
        orderItem.isGift = 0;
        orderItem.giftRewardPoint = 0.0;
        orderItem.printerIds = '21';
        orderItem.sequence = 0;

        orderItem.taxtype = element.taxtype;
        orderItem.isShow = element.isShow;
        orderItem.isFood = element.isFood;
        orderItem.isState = element.isState;
        orderItem.isCity = element.isCity;
        orderItem.isNote = element.isNote;
        orderItem.note = element.note;
        orderItem.quantity = element.quantity;
        orderItem.taxvalue = element.taxvalue;

        for (var ci in _mapCI[element]!) {
          var compliItem = ComplimentItem();
          compliItem.orderId = restOrder.id;
          compliItem.cartItemId = orderItem.itemId;
          compliItem.optionName = ci.optionName;
          compliItem.optionPrice = ci.optionPrice;
          compliItem.ciId = ci.optionId;
          compliItems.add(compliItem);
        }
      }

      if (orderState == 2 && _isDineIn == false) {
        setState(() {
          _selectOrder = restOrder;
        });
        // Take out
        //
        // _getCartItemsFromRestOrderItem(_restOrderItems, compliItems);
        //
        _handleGetTax();

        // Print
        Future.delayed(Duration(seconds: 3), () {
          if (mounted)
            setState(() {
              _isLoaded = false;
            });
        });
        setState(() {
          if (printCart == null) {
            printCart = cart;
          }
          callPrint = true;
        });
      } else {
        setState(() {
          _isLoaded = true;
        });
        //
        Future.delayed(Duration(seconds: 3), () {
          if (mounted)
            setState(() {
              _isLoaded = false;
            });
        });

        print(["wantPrintForPay===:", wantPrintForPay]);

        if (!isPay) {
          setState(() {
            if (printCart == null) {
              printCart = cart;
            }
            callPrint = true;
          });

          print(["printKitchenData====:", printCart]);
          await printKitchenData();
          Navigator.pop(context, true);
        } else {
          setState(() {
            _selectOrder = restOrder;
          });
          await _pay(isPay: isPay);
          setState(() {
            if (printCart == null) {
              printCart = cart;
            }
            callPrint = true;
          });
          print(["wantPrintForPay====:", wantPrintForPay]);
        }
      }
    } catch (e, s) {
      print(e);
      print(s);
    }
  }

  Uint8List? capturedBytes;
  Future<String> convertImageToBase64(GlobalKey globalTmpKey) async {
    if (globalTmpKey.currentContext == null) return "";
    RenderRepaintBoundary boundary = globalTmpKey.currentContext!
        .findRenderObject()! as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    capturedBytes = byteData!.buffer.asUint8List();
    final imageEncoded = base64.encode(capturedBytes!);
    return imageEncoded;
  }

  Future<void> printKitchenData() async {
    print("Data is printed => ${printCart == null}");
    try {
      await Future.delayed(Duration(seconds: 3));
      List<String> imageLst = ["", "", "", "", "", ""];

      // imageLst[0] = await convertImageToBase64(globalCustomerKey);
      imageLst[1] = await convertImageToBase64(kitchenPrintKey2);
      imageLst[2] = await convertImageToBase64(kitchenPrintKey3);

      List<String> strPrinters = await Config.getPrinters() ?? [];
      print("Printers length ${strPrinters.length}");
      if (strPrinters.isEmpty) return showPrintAlert();

      var dio = Dio();
      for (var i = 0; i < strPrinters.length; i++) {
        if (i == 0 || i == strPrinters.length - 1) continue;

        if (strPrinters[i].isEmpty) continue;

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
        if (imageLst[i] != "") {
          try {
            dio.post("http://localhost:7200", data: data);
            print('Print sent');
            // openSnacbar(context, "print Success");
          } catch (e) {
            print('Print sent failed $e');
            openSnacbar(context, "print failed");
          }

          await Future.delayed(const Duration(seconds: 2));
        }
      }
      // setState(() {});
    } catch (e) {
      print(e.toString());
    }
  }

  // Future<void> printKitchenData() async {
  //   print("Data is printed => ${printCart == null}");
  //   try {
  //     await Future.delayed(Duration(seconds: 3));
  //     List<String> imageLst = ["", "", "", "", "", ""];

  //     var baseData = await convertImageToBase64(kitchenPrintKey);

  //     List<String> strPrinters = await Config.getPrinters() ?? [];
  //     print("Printers length ${strPrinters.length}");
  //     if (strPrinters.isEmpty) return showPrintAlert();

  //     var dio = Dio();
  //     for (var i = 0; i < strPrinters.length; i++) {
  //       if (i == 0 || i == strPrinters.length - 1) continue;

  //       if (strPrinters[i].isEmpty) continue;

  //       imageLst[i] = baseData;

  //       var data = {};
  //       if (strPrinters[i].split(".").length == 4) {
  //         data = {"image": imageLst[i], "text": "", "printer": strPrinters[i]};
  //       } else {
  //         data = {
  //           "image": imageLst[i],
  //           "text": "",
  //           "printer": strPrinters[i],
  //           "printerType": 3
  //         };
  //       }
  //       if (imageLst[i] != "") {
  //         try {
  //           dio.post("http://localhost:7200", data: data);
  //           print('Print sent');
  //           // openSnacbar(context, "print Success");
  //         } catch (e) {
  //           print('Print sent failed $e');
  //           openSnacbar(context, "print failed");
  //         }

  //         await Future.delayed(const Duration(seconds: 2));
  //       }
  //     }
  //     // setState(() {});
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  _calculateItemPrice() {
    double foodTax = 0.0;
    double drinkTax = 0.0;
    double total = 0.0;
    double tax = 0.0;
    double subTotal = 0.0;
    double convinieceFee = 0.0;

    if (_orderingItems.isNotEmpty) {
      for (var ele in _orderingItems) {
        double itemPrice = 0.0;
        // double singleObjectPrice = 0.0;
        ele.itemPrice = ele.itemPrice! + itemPrice;
        if (ele.isFood!) {
          foodTax += (double.parse(_res!.foodTax!) / 100) *
              (ele.itemPrice! * ele.quantity!);
        }
        if (ele.isCity!) {
          tax += (double.parse(_res!.grandTax!) / 100) *
              (ele.itemPrice! * ele.quantity!);
        }
        if (ele.isState!) {
          drinkTax += (double.parse(_res!.drinkTax!) / 100) *
              (ele.itemPrice! * ele.quantity!);
        }
        subTotal += ele.itemPrice! * ele.quantity!;
      }
      if (_res!.convenienceFeeType == '2') {
        convinieceFee = ((subTotal * _res!.convenienceFee!) / 100);
      } else {
        if (_res!.convenienceFee != null) {
          convinieceFee = _res!.convenienceFee!;
        }
      }
      subTotal = subTotal + foodTax + drinkTax + tax + convinieceFee;
      total = subTotal;
    }

    return double.parse(total.toStringAsFixed(2));
  }

  ///////////////////////////////////////////////////////////////
  ///                      Left Order
  ///////////////////////////////////////////////////////////////

  // Handle to cart
  _handleAddCart(Cart cart, {bool isPay = false}) async {
    print("_handleAddCart $isPay");
    final AddToCartBloc acb =
        Provider.of<AddToCartBloc>(context, listen: false);

    await AppService().checkInternet().then((hasInternet) async {
      if (hasInternet == false) {
        openSnacbar(context, 'no internet');
      } else {
        setState(() {
          if (isPay) {
            _paying = true;
          } else {
            _carting = true;
          }
        });
        final userId = context.read<SignInBloc>().uid;
        acb.addToCart(cart, userId, tableId: tableId).then((_) async {
          if (acb.hasError == false) {
            // Edited by Zohaib
            if (cart.id == null) {
              cart.id = acb.id;
            }

            //
            _processing(cart, isPay: isPay);
            // Navigator.pop(context, true);
          } else {
            if (acb.errorCode == "Auth failed") {
              openSnacbar(context, t1SessionExpired, onPressed: () {
                nextScreenCloseOthers(
                    context, const SignIn2Page(isFirst: false));
              });
            } else {
              openSnacbar(context, acb.errorCode);
            }
          }
          setState(() {
            if (isPay) {
              _paying = false;
            } else {
              _carting = false;
            }
          });
        });
      }
    });
  }

  // Handle to update cart
  _handleUpdateCart(Cart cart) async {
    final AddToCartBloc acb =
        Provider.of<AddToCartBloc>(context, listen: false);

    await AppService().checkInternet().then((hasInternet) async {
      if (hasInternet == false) {
        openSnacbar(context, 'no internet');
      } else {
        setState(() {
          _carting = true;
        });
        acb.updateCart(cart).then((_) async {
          if (acb.hasError == false) {
            // Edited by Zohaib
            if (cart.id == null) {
              cart.id = acb.id;
            }

            _processing(cart);
            // Navigator.pop(context, true);
          } else {
            if (acb.errorCode == "Auth failed") {
              openSnacbar(context, t1SessionExpired, onPressed: () {
                nextScreenCloseOthers(
                    context, const SignIn2Page(isFirst: false));
              });
            } else {
              openSnacbar(context, acb.errorCode);
            }
          }
          setState(() {
            _carting = false;
          });
        });
      }
    });
  }

  // Handle to get tax
  Future<void> _handleGetTax({bool isPay = false}) async {
    print("_handleGetTax");
    final TaxBloc tb = Provider.of<TaxBloc>(context, listen: false);

    await AppService().checkInternet().then((hasInternet) async {
      if (hasInternet == false) {
        openSnacbar(context, 'no internet');
      } else {
        tb.getTax().then((_) async {
          if (tb.hasError == false) {
            _tax = tb.tax;
            // if (widget.isOrdered == false) {
            await _handleGetBasket(isPay: isPay);
            // }
          } else {
            openSnacbar(context, tb.errorCode);
          }
          setState(() {});
        });
      }
    });
  }

  // Handle to get tax
  _handleGetBasket({bool isPay = false}) async {
    print("_handleGetBasket");
    final BasketBloc bb = Provider.of<BasketBloc>(context, listen: false);
    final userId = context.read<SignInBloc>().uid;

    await AppService().checkInternet().then((hasInternet) async {
      if (hasInternet == false) {
        openSnacbar(context, 'no internet');
      } else {
        setState(() {
          _isOrderLoading = true;
          _takeoutProcessing = true;
        });
        bb.getBasket(userId).then((_) async {
          if (bb.hasError == false) {
            _basket = bb.basket;

            if (orderState != 2 && isPay == true) {
              _cart!.drinkTax = double.parse(_basket!.drinkTax.toString());
              _cart!.foodTax = double.parse(_basket!.foodTax.toString());
              // _cart!.resId = _basket!.resId;
              _cart!.resId = Config.restaurantId;
              _cart!.subtotal = _basket!.subtotal;
              _cart!.tax = _basket!.tax;
              _cart!.total = _basket!.total;
              _cart!.userId = _basket!.userId;
              _cart!.cod = _basket!.cod;
              // _saveOrderingItem(_cart!);
              _orderedItems.addAll(_cart!.cart!);

              nextScreen(
                  context,
                  SummaryPage(
                    cart: _cart,
                    tax: _tax,
                    deliveryMode: 2,
                    restOrder: _selectOrder!,
                    paymentMode: 2, //Cambia de 1 a 2 codepaeza 31/05/2023
                  )).then((value) {
                Navigator.of(context).pop();
              });
            }
            if (orderState == 2) {
              print("orderState-=2: 1648");
              var restOrder = _getRestOrder(_cart!);
              // var restOrder = _selectOrder;
              nextScreen(
                  context,
                  SummaryPage(
                    cart: _cart,
                    tax: _tax,
                    deliveryMode: 2,
                    paymentMode: 1,
                    restOrder: restOrder,
                  ));
            }
          } else {
            if (bb.errorCode == "Auth failed") {
              openSnacbar(context, t1SessionExpired, onPressed: () {
                nextScreenCloseOthers(
                    context, const SignIn2Page(isFirst: false));
              });
            } else {
              // openSnacbar(context, bb.errorCode);
            }
          }
          setState(() {
            _isOrderLoading = false;
            _takeoutProcessing = false;
          });
        });
      }
    });
  }

  // Change number of persons
  _changeNumberOfPersons() {
    _numberController.text = personNumber.toString();
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                dialogTitle(MediaQuery.of(context).size.width,
                    title: t1ChangeNumberOfPersons),
                dialogController(editingController: _numberController),
                Row(
                  children: [
                    dialogButton(
                        name: t1Cancel.tr(),
                        backgroundColor: Colors.red,
                        onClick: () {
                          Navigator.pop(context);
                        }),
                    dialogButton(
                        name: t1Save.tr(),
                        backgroundColor: Colors.green,
                        onClick: () async {
                          if (_formKey.currentState!.validate()) {
                            if (orderState == 0) {
                              personNumber = int.parse(_numberController.text);
                            } else if (orderState == 1) {
                              personNumber = int.parse(_numberController.text);
                              await _dbHandler.updateRestOrder(
                                  _restOrder!.id!, personNumber);
                            }
                            Navigator.pop(context);
                          }
                        }),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Keep dialog
  _tagsDialog() async {
    return await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                dialogTitle(MediaQuery.of(context).size.width,
                    title: t1Keep.tr()),
                dialogController(
                    editingController: _keepController, hintText: 'Tag name'),
                GestureDetector(
                  onTap: () {
                    if (_keepController.text.isNotEmpty) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: Container(
                    color: Colors.red,
                    height: setScaleHeight(40),
                    child: Center(
                      child: Text(
                        t1Save,
                        style: TextStyle(
                          fontSize: setFontSize(16),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _tagDialogItem() {
    return Container(
      color: Colors.white,
      height: isPortrait ? setScaleHeight(250) : setScaleHeight(200),
      padding: const EdgeInsets.all(8),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: _orderingItems.length,
        itemBuilder: (_, i) {
          return GestureDetector(
            onTap: () {},
            child: Container(
              width: _width,
              height: isPortrait ? setScaleHeight(40) : setScaleHeight(60),
              decoration: BoxDecoration(
                // color: _selectedItemIdx == -1
                //     ? Colors.white
                //     : _selectedItemIdx == i
                //         ? Colors.orange[400]
                //         : Colors.white,
                color: Colors.white,
                border: Border.all(
                  color: Colors.grey[700]!,
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    width: isPortrait ? setScaleWidth(30) : setScaleWidth(60),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            var qty = _orderingItems[i].quantity;
                            if (qty! > 1) {
                              _orderingItems[i].quantity = qty - 1;
                            } else {
                              _mapCI.remove(_orderingItems[i]);
                              _orderingItems.removeAt(i);
                            }
                            setState(() {});
                          },
                          child: Icon(
                            Icons.remove,
                            color: Colors.blue,
                            size: isPortrait ? 12 : 25,
                          ),
                        ),
                        SizedBox(
                          width: 5 * scaleWidth,
                        ),
                        Text(
                          _orderingItems[i].quantity.toString(),
                          style: TextStyle(
                              fontSize: isPortrait
                                  ? setFontSize(8)
                                  : setFontSize(14)),
                        ),
                      ],
                    ),
                  ),
                  VerticalDivider(
                    color: Colors.grey[700],
                    width: 1,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // if (_selectedItemIdx == i) {
                        //   _selectedItemIdx = -1;
                        // } else {
                        //   _selectedItemIdx = i;
                        // }
                        // setState(() {});
                      },
                      child: Container(
                        padding: EdgeInsets.all(isPortrait ? 4.0 : 8.0),
                        child: Text(
                          _orderingItems[i].itemName!,
                          style: TextStyle(
                              fontSize: isPortrait
                                  ? setFontSize(8)
                                  : setFontSize(14)),
                        ),
                      ),
                    ),
                  ),
                  VerticalDivider(
                    color: Colors.grey[700],
                    width: 1,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.all(4),
                    width: isPortrait ? setScaleWidth(50) : setScaleWidth(100),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _orderingItems[i].quantity =
                                _orderingItems[i].quantity! + 1;
                            // _calculateTotalPrice();
                            setState(() {});
                          },
                          child: Icon(
                            Icons.add,
                            color: Colors.black,
                            size: isPortrait ? 12 : 25,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '\$${_orderingItems[i].itemPrice! * _orderingItems[i].quantity!}',
                          style: TextStyle(
                              fontSize: isPortrait
                                  ? setFontSize(8)
                                  : setFontSize(14)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Retrieve dialog
  _retrieveDialog() async {
    List<KeepItem> keepItems = await _dbHandler.retireveKeepItems();
    if (keepItems.isEmpty) {
      openSnacbar(context, t1NoData.tr());
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                dialogTitle(MediaQuery.of(context).size.width,
                    title: t1Retrieve.tr()),
                ListView.builder(
                  physics: const ScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: keepItems.length,
                  itemBuilder: ((context, index) {
                    return Column(
                      children: [
                        dialogCart(
                          time: keepItems[index].time.toString(),
                          note: keepItems[index].note,
                          price:
                              '\$${_getPrice(keepItems[index].item!).toString()}',
                          closeItemClick: () async {
                            await _dbHandler
                                .deleteKeepItem(keepItems[index].id!);
                            Navigator.pop(context);
                          },
                          itemClick: () async {
                            _orderingItems.clear();
                            List<Item> items =
                                _getItems(keepItems[index].item!);
                            _orderingItems.addAll(items);
                            await _dbHandler
                                .deleteKeepItem(keepItems[index].id!);
                            setState(() {});
                            Navigator.pop(context);
                          },
                        ),
                        const Divider(height: 1, color: Colors.grey),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //
  List<Item> _getItems(String keepItem) {
    List<dynamic> snap = [];
    snap.addAll(jsonDecode(keepItem));
    List<Item> items = snap.map((e) => Item.fromJson2(e)).toList();
    return items;
  }

  // calculate total price of items
  _getPrice(String keepItem) {
    var items = _getItems(keepItem);
    var price = 0.0;
    for (var element in items) {
      price += element.itemPrice!;
    }
    return price;
  }

  // keep item
  _keepItem(String note) async {
    var jsonEnc = jsonEncode(_orderingItems);
    var time = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    var item = KeepItem(item: jsonEnc, note: note, time: time);

    await _dbHandler.insertKeepItem([item]);
  }

  // Dine In  - Cenar En
  _dineIn() {
    if (widget.tables!.isEmpty) {
      openSnacbar(context, t1NoTables.tr());
      return;
    }

    if (_orderingItems.isEmpty) {
      openSnacbar(context, t1PleaseAdd.tr());
      return;
    }

    var tables = widget.tables;

    showDialog(
      context: context,
      barrierColor: Colors.white.withOpacity(0),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                dialogTitle(MediaQuery.of(context).size.width, title: t1DineIn),
                GridView.builder(
                  padding: EdgeInsets.zero,
                  physics: const ScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isPortrait ? 3 : 7,
                    crossAxisSpacing: 0.5,
                    mainAxisSpacing: 0.5,
                    childAspectRatio: 1,
                  ),
                  itemCount: tables!.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _isDineIn = true;
                        });

                        tableId = tables[index].id;
                        tableName = tables[index].name;
                        tableGroupId = tables[index].tableGroupId;

                        _cartProcess();

                        Navigator.pop(context);
                      },
                      child: Container(
                        color: Colors.white,
                        child: Center(
                          child: Text(
                            tables[index].name!,
                            // style: TextStyle(
                            //   fontSize: isPortrait ? 8 : 14,
                            // ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  ///////////////////////////////////////////////////////////////
  ///                      Right Menu
  ///////////////////////////////////////////////////////////////

  // Handle to get group
  Future<void> _handleGroupData() async {
    final RestaurantMenuBloc rmb =
        Provider.of<RestaurantMenuBloc>(context, listen: false);

    await AppService().checkInternet().then((hasInternet) async {
      if (hasInternet == false) {
        openSnacbar(context, 'no internet');
      } else {
        print('===== food list =====');
        rmb.restaurantMenu(Config.restaurantId).then((_) async {
          if (rmb.hasError == false) {
            _groups.clear();

            // Updated By Zohaib
            // Adding only 1 menu group as per request
            // rmb.groups!.forEach((element) {
            //   if(element.groupId == 1686){
            //     _groups.add(element);
            //   }
            // });
            // print(rmb.groups);
            _groups.addAll(rmb.groups!);

            // print(_groups[1].items![0].itemName);

            _customizations.addAll(rmb.customization!);

            _res = rmb.res;

            var ret = await _dbHandler.retireveRestResponse();
            if (ret.isEmpty) {
              _dbHandler.insertRestResponse([_res!]);
            } else {
              var isFind = false;
              for (var item in ret) {
                if (item.resId == Config.restaurantId) {
                  isFind = true;
                  break;
                }
              }
              if (!isFind) {
                _dbHandler.insertRestResponse([_res!]);
              }
            }

            _setMapItem();
          } else {
            openSnacbar(context, rmb.errorCode);
          }
          setState(() {
            _isMenuLoaded = true;
          });
        });
      }
    });
  }

  // set map with count
  _setMapItem() {
    for (var element in _groups) {
      var items = element.items!;
      for (var e in items) {
        _mapItem[e] = 0;
      }
    }
  }

  Future<void> showPrintAlert() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(t1EnterIpOrName.tr()),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(t1Yes),
              )
            ],
          );
        });
  }

  RestOrder? _selectOrder;

  _pay({isPay = false}) async {
    setState(() {});
    // Get cart from order
    // if (!isPay) _getCartFromRestOrder(_selectOrder!);
    //
    // _handleGetTax(isPay: isPay);
    print("cart_page _pay function");

    if (_cart == null || _cart?.id == null) {
      /// Save cart
      var id = await _cartProcess(isPay: true);

      /// Get cart
      _cart = await _getCartFromId(id);
    }

    /// Get tax
    await _getTaxFromDb();

    if (orderState != 2) {
      var restOrder = _getRestOrder(_cart!);
      nextScreen(
          context,
          SummaryPage(
            cart: _cart,
            tax: _tax,
            deliveryMode: 2,
            restOrder: restOrder,
            paymentMode: 2, //Cambia de 1 a 2 codepaeza 31/05/2023
          )).then((value) {
        Navigator.of(context).pop();
      });
    } else {
      var restOrder = _getRestOrder(_cart!);
      // var restOrder = _selectOrder;
      nextScreen(
          context,
          SummaryPage(
            cart: _cart,
            tax: _tax,
            deliveryMode: 2,
            paymentMode: 1,
            restOrder: restOrder,
          ));
    }
  }

  Future<Cart?> _getCartFromId(int cartId) async {
    return await _dbHandler.retireveCart(cartId);
  }

  /// Get tax from db
  _getTaxFromDb() async {
    var taxs = await _dbHandler.getTax();
    if (taxs.isNotEmpty) {
      _tax = taxs.first;
    }
  }

  /// Save cart to db
  Future<int> _saveCartToDb(Cart cart) async {
    int id = 0;
    var res = await _dbHandler.insertCart(cart);
    if (!res) {
      openSnacbar(context, 'Error: Save');
    } else {
      var carts = await _dbHandler.retireveCarts();
      id = carts.last.id!;
    }
    return id;
  }

  /// Update cart to db
  Future<bool> _updateCartToDb(Cart cart) async {
    var cartMap = cart.toJson();
    var itemMap = cart.cart?.map((e) => e.toJson()).toList();
    var jsonString = jsonEncode(itemMap);

    cartMap['cart'] = jsonString;
    var res = await _dbHandler.updateCart(cartMap, cart.id!);

    if (!res) {
      openSnacbar(context, 'Error: Update');
    }
    return res;
  }
}
