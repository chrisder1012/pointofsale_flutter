import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:zabor/blocs/add_to_cart_bloc.dart';
import 'package:zabor/blocs/payout_bloc.dart';
import 'package:zabor/blocs/refund_bloc.dart';
import 'package:zabor/blocs/rest_table_section_bloc.dart';

import 'package:zabor/config/config.dart';
import 'package:zabor/db/database_handler.dart';
import 'package:zabor/models/rest_order.dart';
import 'package:zabor/models/rest_table.dart';
import 'package:zabor/models/rest_table_section.dart';
import 'package:zabor/pages/cart_page.dart';
import 'package:zabor/pages/dejavoo_setting_screen.dart';
import 'package:zabor/pages/management_table_page.dart';
// import 'package:zabor/pages/order_page.dart';
import 'package:zabor/pages/print_register_page.dart';
import 'package:zabor/pages/restaurant_type.dart';
import 'package:zabor/pages/sales_report_page.dart';
import 'package:zabor/pages/sign_in.dart';
import 'package:zabor/pages/unpaid_page.dart';
import 'package:zabor/pages/table_orders_page.dart';
import 'package:zabor/utils/t1_string.dart';

import '../blocs/basket_bloc.dart';
import '../blocs/close_order_bloc.dart';
import '../blocs/homepage_restaurant_bloc.dart';
import '../blocs/order_bloc.dart';
import '../blocs/sign_in_bloc.dart';
import '../blocs/tax_bloc.dart';
import '../models/basket.dart';
import '../models/cart.dart';
import '../models/compliment_item.dart';
import '../models/customization_item.dart';
import '../models/item.dart';
import '../models/keep_item.dart';
import '../models/rest_order_item.dart';
import '../models/tax.dart';
import '../services/services.dart';
import '../utils/next_screen.dart';
import '../utils/snacbar.dart';
import '../utils/utils.dart';
import 'package:zabor/models/petty_cash.dart';
import 'package:zabor/models/petty_cash_close.dart';
import 'package:zabor/models/restaurant.dart';

import '../widget/close_app_dialog.dart';
import '../widget/dialog_widgets.dart';
import 'sales_summary_report.dart';
import 'shift_open_close.dart';
import 'sign_in2.dart';

class HomePage extends StatefulWidget {
  final bool goNext;
  const HomePage({Key? key, this.goNext = false}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _payoutToCtrl = TextEditingController();
  final TextEditingController _payoutAmountCtrl = TextEditingController();
  final TextEditingController _payoutDescriptionCtrl = TextEditingController();
  final TextEditingController _returnReasonCtrl = TextEditingController();
  final TextEditingController _returnOrderNumberCtrl = TextEditingController();
  final TextEditingController _returnAmountCtrl = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  final List _selectedIndexs = [];

  final DatabaseHandler _dbHandler = DatabaseHandler();
  final List<RestTable> _restTables = [];
  final List<RestOrder> _restOrders = [];
  List<Cart> _carts = [];
  List<PettyCashModel> pettyCashModel = [];
  List<PettyCashCloseModel> pettyCashCloseModel = [];

  final Map<RestOrderItem, List<CustomizationItem>> _mapCI = {};

  double _width = 0.0;
  double printWidth = 512;

  bool isTapDown = false;
  bool _isLoadedTable = false;
  bool _isLoadingTable = true;
  bool _isLoadedCart = false;
  bool _isPayout = false;
  bool _isRefunded = false;
  bool _isNoInternet = false;

  GlobalKey globalPayoutKey = GlobalKey();
  GlobalKey globalRefundKey = GlobalKey();

  final _channel =
      WebSocketChannel.connect(Uri.parse('wss://api.zaboreats.com/ws'));

  // var isPortrait = false;

  ///
  /// Get orders from db
  ///
  _getDataFromDb() {
    // Rest Order
    _dbHandler.retireveRestOrders().then((value) {
      _restOrders.clear();
      for (var element in value) {
        if (element.tableGroupId == Config.restaurantId) {
          _restOrders.add(element);
        }
      }
      setState(() {});
    });
  }

  ///
  /// Load tables from db
  ///
  Future<List<RestTable>> _loadTablesFromDb(BuildContext context) async {
    var result = await _dbHandler.retireveRestTable();
    if (result.isEmpty) {
      openSnacbar(context,
          'The restaurant table is empty. please add table in table management.');
      return [];
    }
    _restTables.clear();
    for (var element in result) {
      if (element.tableGroupId == Config.restaurantId) {
        _restTables.add(element);
      }
    }
    print('===== Rest table: ${_restTables.length} =====');

    return _restTables;
  }

  ///
  /// Delete tables from db
  ///
  Future<void> _deleteTablesFromDb() async {
    await _dbHandler.deleteAllTables();
  }

  _loadRestaurantTableSection() async {
    await _handleRestaurantTable();
  }

  _loadCarts(String userId) async {
    await _handleGetCarts(Config.restaurantId.toString(), userId);
  }

  @override
  void initState() {
    // Check rest tables and insert all rest tables to db
    if (widget.goNext) {
      Future.delayed(Duration.zero, () async {
        var result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CartPage(
              orderState: 2,
              tables: _restTables,
            ),
          ),
        );

        if (result == true) {
          _getDataFromDb();
        }
      });
    }
    Future.delayed(
      Duration.zero,
      () async {
        var list = await _loadTablesFromDb(context);
        if (list.length > 0) {
          _getCartsFromDb();
        }
        setState(() {});
      },
    );

    // _deleteTablesFromDb();
    // _loadRestaurantTableSection();

    super.initState();
  }

  @override
  void dispose() {
    _restTables.clear();
    _restOrders.clear();
    pettyCashModel.clear();
    pettyCashCloseModel.clear();

    _channel.sink.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restBloc = Provider.of<HomepageRestaurantBloc>(context);
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    _width = width;

    isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    if (isPortrait) {
      scaleWidth = width / Config().defaultWidth;
      scaleHeight = height / Config().defaultHeight;
    } else {
      scaleWidth = width / Config().defaultHeight;
      scaleHeight = height / Config().defaultWidth;
    }
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[900],
      body: _body(restBloc),
    );
  }

  _body(HomepageRestaurantBloc restBloc) {
    // return Container();
    return Stack(
      children: [
        ///
        if (_isPayout) _printPayoutWidget(),
        if (_isRefunded) _printRefundWidget(),

        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _topBar(restBloc),
            _contentByApi(),
            // _content(),
          ],
        ),
      ],
    );
  }

  _topBar(HomepageRestaurantBloc restBloc) {
    var width = MediaQuery.of(context).size.width;

    return SizedBox(
      width: width,
      height: setScaleHeight(50),
      child: Row(
        children: [
          Container(
            width: setScaleHeight(50),
            color: const Color(0xFF519991),
            child: Center(
              child: IconButton(
                onPressed: () async {
                  var res = await _showExitDialog();
                  if (res == true) {
                    nextScreenCloseOthers(context, const RestaurantTypePage());
                    // Navigator.pop(context, false);
                  }
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: setScaleHeight(15),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              // Takeout
              onTap: (() async {
                var result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartPage(
                      orderState: 2,
                      tables: _restTables,
                    ),
                  ),
                );

                if (result == true) {
                  _getDataFromDb();
                }
              }),
              child: Container(
                color: const Color(0xFF77b068),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      t1Takeout.tr(),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              // Tags
              onTap: () async {
                var result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartPage(
                      orderState: 2,
                      tables: _restTables,
                      isTag: true,
                    ),
                  ),
                );
              },
              child: Container(
                color: Color.fromARGB(255, 157, 176, 104),
                child: /*const*/ Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      t1Keep.tr(),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              // Retrieve
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartPage(
                      orderState: 2,
                      tables: _restTables,
                      isRetrieve: true,
                    ),
                  ),
                );
              },
              child: Container(
                color: Color.fromARGB(255, 104, 165, 176),
                child: /*const*/ Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      t1Retrieve.tr(),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: (() async {
                var result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UnpaidPage(),
                  ),
                );
                if (result == true) {
                  _getDataFromDb();
                }
              }),
              child: Container(
                color: const Color(0xFFf2c442),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      t1Unpaid.tr(),
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: (() async {
                var result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TableOrdersPage(),
                  ),
                );
                if (result == true) {
                  _getDataFromDb();
                }
              }),
              child: Container(
                color: Colors.blueGrey,
                child: /*const*/ Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      //t1Unpaid.tr(),
                      "Detalle Mesas",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 50,
            color: const Color(0xFF5bacf0),
            child: Center(
              child: PopupMenuButton(
                itemBuilder: ((context) {
                  return [
                    PopupMenuItem<int>(
                        value: 12,
                        child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(t1TableManagement.tr()))),
                    PopupMenuItem<int>(
                        value: 17,
                        child: FittedBox(
                            fit: BoxFit.scaleDown, child: Text(t1Return.tr()))),
                    PopupMenuItem<int>(
                        value: 18,
                        child: FittedBox(
                            fit: BoxFit.scaleDown, child: Text(t1Payout.tr()))),
                    PopupMenuItem<int>(
                        value: 0,
                        child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(t1SalesReport.tr()))),
                    PopupMenuItem<int>(
                        value: 20,
                        child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(t1SalesSummary.tr()))),
                    // PopupMenuItem<int>(
                    //     value: 15,
                    //     child: FittedBox(
                    //         fit: BoxFit.scaleDown, child: Text('Close Shift'))),
                    PopupMenuItem<int>(
                        value: 1,
                        child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(t1Printer.tr()))),
                    PopupMenuItem<int>(
                        value: 3,
                        child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(t1Customer.tr()))),
                    PopupMenuItem<int>(
                        value: 9,
                        child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(t1ExportDb.tr()))),
                    PopupMenuItem<int>(
                        value: 10,
                        child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(t1ImportDb.tr()))),
                    PopupMenuItem<int>(
                        value: 11,
                        child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(t1Setting.tr()))),
                    PopupMenuItem<int>(
                        value: 16,
                        child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(t1Language.tr()))),
                    PopupMenuItem<int>(
                        value: 13,
                        child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(t1EmailUs.tr()))),
                    PopupMenuItem<int>(
                        value: 14,
                        child: FittedBox(
                            fit: BoxFit.scaleDown, child: Text(t1Logout.tr()))),
                  ];
                }),
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.black,
                  size: setScaleHeight(15),
                ),
                onSelected: (item) async {
                  if (item == 14) {
                    _handleSignOut();
                  } else if (item == 12) {
                    // Manage table
                    var result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ManagementTablePage()));
                    await _loadTablesFromDb(context);

                    setState(() {});
                  } else if (item == 20) {
                    var res = await nextScreen(context, SalesSummaryReport());
                    if (res == true) {
                      /// Check opened shift
                      var ret = await _checkOpenedShift();
                      if (ret) {
                        openSnacbar(context, 'The current shift is closed');
                        return;
                      }
                      print('===== close shift is $res =====');
                      var userId = context.read<SignInBloc>().uid;
                      final bool? shiftId0 = await nextScreen(
                          context,
                          ShiftOpenClose(
                              restId: Config.restaurantId!,
                              isOpen: false,
                              cashierId: context.read<SignInBloc>().uid!));
                      if (shiftId0 == true) {
                        openSnacbar(
                            context, 'Closed current shift successfully');

                        // _handleClearOrders(userId!);
                        // _handleClearCart(userId);
                        // make a new shift
                        restBloc.checkShiftStatus(userId, context);

                        await _deleteCarts();

                        var shiftId = await _dbHandler
                            .getCurrenShiftId(Config.restaurantId!);
                        restBloc.checkShiftStatusFromDB(
                            context, userId!, shiftId, Config.restaurantId!);
                      }
                    }
                  } else if (item == 0) {
                    nextScreen(context, SalesReportPage());
                  } else if (item == 15) {
                    var userId = context.read<SignInBloc>().uid;
                    final bool? shiftId0 = await nextScreen(
                        context,
                        ShiftOpenClose(
                            restId: Config.restaurantId!,
                            isOpen: false,
                            cashierId: context.read<SignInBloc>().uid!));
                    if (shiftId0 == true) {
                      openSnacbar(context, 'Closed current shift successfully');

                      await nextScreen(context, SalesReportPage());
                      _handleClearOrders(userId!);
                      _handleClearCart(userId);

                      // make a new shift
                      restBloc.checkShiftStatus(userId, context);
                    }
                  } else if (item == 1) {
                    nextScreen(context, const PrintRegisterPage());
                  } else if (item == 9) {
                    _saveDatabase();

                    /// Export db
                  } else if (item == 10) {
                    /// Import db
                    _importDatabase();
                  } else if (item == 11) {
                    nextScreen(context, DejavooSettingScreen(isFirst: false));
                  } else if (item == 16) {
                    _showLanguageDialog();
                  } else if (item == 17) {
                    _showReturnDialog();
                  } else if (item == 18) {
                    _showPayoutDialog();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Added by Zohaib
  ///
  /// Pre process for ordered
  ///
  int? orderId;
  Tax? _tax;
  Basket? _basket;
  Cart? _cart;
  final List<Item> _items = [];
  int? userId;
  // Ordered
  RestOrder? _restOrder;

  _handleGetTax() async {
    final TaxBloc tb = Provider.of<TaxBloc>(context, listen: false);

    await AppService().checkInternet().then((hasInternet) async {
      if (hasInternet == false) {
        if (!_isNoInternet) {
          _isNoInternet = true;
          openSnacbar(context, 'no internet');
        }
      } else {
        tb.getTax().then((_) async {
          if (tb.hasError == false) {
            _tax = tb.tax;
            // if (widget.isOrdered == false) {
            _handleGetBasket();
            // }
          } else {
            openSnacbar(context, tb.errorCode);
          }
          setState(() {
            // _isLoaded = true;
          });
        });
      }
    });
  }

  // Handle to get tax
  _handleGetBasket() async {
    final BasketBloc bb = Provider.of<BasketBloc>(context, listen: false);

    await AppService().checkInternet().then((hasInternet) async {
      if (hasInternet == false) {
        if (!_isNoInternet) {
          _isNoInternet = true;
          openSnacbar(context, 'no internet');
        }
      } else {
        userId = context.read<SignInBloc>().uid;
        bb.getBasket(userId).then((_) async {
          if (bb.hasError == false) {
            _basket = bb.basket;

            _cart!.id = _basket!.id;
            // if (widget.cart != null) {
            //   _cart!.cart = widget.cart!.cart;
            // }
            // _cart!.carts = widget.cart!.carts ?? _cart!.carts;
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
            _items.addAll(_cart!.cart!);

            setState(() {
              // isLoaded = true;
            });
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
            // _isLoaded = true;
          });
        });
      }
    });
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
      // print("iii");
      var cartItem = Item();

      cartItem.itemId = element.itemId;
      cartItem.itemName = element.itemName;
      cartItem.itemPrice = element.price;
      // cartItem.customizations = element.customizations;
      cartItem.taxtype = element.taxtype;
      // cartItem.itemQuantity = element.itemQuantity;
      // cartItem.itemPic = element.itemPic;
      // cartItem.itemDes = element.itemDes;
      // cartItem.is_show = element.isShow;

      cartItem.isFood = element.isFood;
      cartItem.isState = element.isState;
      cartItem.isCity = element.isCity;
      // cartItem.is_note = element.isNote;
      cartItem.note = element.note;
      cartItem.quantity = element.quantity;
      // cartItem.taxvalue = element.taxvalue;
      // print("iii4");

      cartItem.customization = [];
      if (mapCustomItem.containsKey(element.id)) {
        cartItem.customization!.addAll(mapCustomItem[element.id]!);
      }
      // print("item loops");

      // Add item
      _cart!.cart!.add(cartItem);

      // print("item loop ${_cart!.cart}");
    }
  }

  Future<void> _orderedProcess(
      {required int? orderId,
      required RestTable? restTable,
      required int? personNum,
      required Responses? response}) async {
    print("I was called?");
    // Get current order
    await _dbHandler.retireveRestOrder(orderId!).then((restOrder) async {
      print("restOrderss $restOrder");
      _restOrder = restOrder;
      // Get cart from order
      _getCartFromRestOrder(restOrder);
      //
      _handleGetTax();
      // Rest Order Item
      await _dbHandler
          .retireveRestOrderItemFromOrderId(orderId)
          .then((rois) async {
        // print(_cart!.id);
        // _restOrderItems.addAll(rois);
        //
        // Compliment items
        await _dbHandler
            .retireveComplimentItemFromOrderId(orderId)
            .then((value) {
          // _complimentItems.addAll(value);
          //
          _getCartItemsFromRestOrderItem(rois, value);
        });

        setState(() {});
      });
    });
  }

  _contentByApi() {
    var userId = context.read<SignInBloc>().uid;
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        physics: const ScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //crossAxisCount: isPortrait ? 3 : 6,
          crossAxisCount: isPortrait ? 2 : 4,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 3 / 2,
        ),
        itemCount: _restTables.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedIndexs.contains(index);
          return GestureDetector(
            onTapDown: (value) {
              setState(() {
                if (!_selectedIndexs.contains(index)) {
                  _selectedIndexs.add(index);
                }
              });
            },
            onTapCancel: () {
              setState(() {
                if (_selectedIndexs.contains(index)) {
                  _selectedIndexs.remove(index);
                }
              });
            },
            onTapUp: (value) async {
              setState(() {
                if (_selectedIndexs.contains(index)) {
                  _selectedIndexs.remove(index);
                }
              });
              if (_isOrdered(
                  _restTables[index].name!, _restTables[index].tableGroupId!)) {
                var responses = await _dbHandler.retireveRestResponse();
                RestOrder? ro = _getRestOrder(
                    _restTables[index].name!, _restTables[index].tableGroupId!);
                await _orderedProcess(
                    orderId: ro!.id,
                    restTable: _restTables[index],
                    personNum: ro.personNum,
                    response: responses.isEmpty ? null : responses[0]);

                var res = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartPage(
                      //orderState: 1,
                      orderState: 0,

                      restOrder: ro,
                      restTable: _restTables[index],
                      personNum: ro.personNum,
                      responses: responses.isEmpty ? null : responses[0],
                      cart: _getCart(_restTables[index].id!),
                    ),
                  ),
                );

                await _getCartsFromDb();
                setState(() {});
              } else {
                var res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CartPage(
                              orderState: 0,
                              restTable: _restTables[index],
                              personNum: 1,
                            )));
                await _getCartsFromDb();
                setState(() {});
              }
            },
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _isOrdered(_restTables[index].name!,
                            _restTables[index].tableGroupId!) ==
                        false
                    ? isSelected
                        ? Colors.grey[400]
                        : Colors.white
                    : Colors.orange[400],
                borderRadius: BorderRadius.circular(8),
              ),
              child: _isOrdered(_restTables[index].name!,
                          _restTables[index].tableGroupId!) ==
                      false
                  ? Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Stack(
                        children: [
                          Center(
                              child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    _restTables[index].name!,
                                    style: TextStyle(
                                        fontSize: setFontSize(16),
                                        fontWeight: FontWeight.w500),
                                  ))),
                          Align(
                              alignment: Alignment.topRight,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'No: ${_restTables[index].num.toString()}',
                                  style: TextStyle(
                                    fontSize: setFontSize(12),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Stack(
                        children: [
                          Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _restTables[index].name!,
                                style: TextStyle(
                                    fontSize: setFontSize(16),
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'No: ${_restTables[index].num.toString()}',
                                style: TextStyle(
                                  fontSize: setFontSize(12),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _getRestOrder(_restTables[index].name!,
                                        _restTables[index].tableGroupId!)!
                                    .waiterName!,
                                style: TextStyle(
                                  fontSize: setFontSize(12),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _getRestOrder(_restTables[index].name!,
                                        _restTables[index].tableGroupId!)!
                                    .waiterName!,
                                style: TextStyle(
                                  fontSize: setFontSize(12),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _getRestOrder(_restTables[index].name!,
                                        _restTables[index].tableGroupId!)!
                                    .personNum!
                                    .toString(),
                                style: TextStyle(
                                  fontSize: setFontSize(12),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _getRestOrder(_restTables[index].name!,
                                        _restTables[index].tableGroupId!)!
                                    .updateTimeStamp!,
                                style: TextStyle(
                                  fontSize: setFontSize(12),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '\$${_getRestOrder(_restTables[index].name!, _restTables[index].tableGroupId!)!.total}',
                                style: TextStyle(
                                  fontSize: setFontSize(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  _isOrdered(String name, int groupId) {
    if (_restOrders.isEmpty) return false;
    var ret = false;
    for (int i = 0; i < _restOrders.length; i++) {
      if (_restOrders[i].tableName == name &&
          _restOrders[i].tableGroupId == groupId) {
        ret = true;
        break;
      }
    }
    return ret;
  }

  RestOrder? _getRestOrder(String name, int groupId) {
    RestOrder? restOrder;
    for (int i = 0; i < _restOrders.length; i++) {
      if (_restOrders[i].tableName == name &&
          _restOrders[i].tableGroupId == groupId) {
        restOrder = _restOrders[i];
        break;
      }
    }
    return restOrder;
  }

  Cart? _getCart(int tableId) {
    var cart = _carts.firstWhereOrNull((element) => element.tableId == tableId);
    return cart;
  }

  ///
  /// Make Ordering Item
  ///
  List<RestOrderItem>? _getOrderingItem(Cart cart) {
    List<RestOrderItem> rois = [];
    var newCart = cart;

    for (var item in newCart.cart!) {
      var roi = RestOrderItem();
      roi.taxtype = item.taxtype;
      roi.isShow = item.isShow;
      roi.isFood = item.isFood;
      roi.isState = item.isState;
      roi.isCity = item.isCity;
      roi.isNote = item.isNote;
      roi.note = item.note;
      roi.quantity = item.quantity;
      roi.taxvalue = item.taxvalue;
      roi.itemName = item.itemName;
      roi.price = item.itemPrice;
      roi.itemId = item.itemId;
      rois.add(roi);
      if (item.customization != null) {
        _mapCI[roi] = item.customization!;
      }
    }

    return rois;
  }

  Future<List<RestOrder>> _getOrdersFromCart(List<Cart> carts) async {
    List<RestOrder> ros = [];

    try {
      for (int i = 0; i < carts.length; i++) {
        var cart = carts[i];

        // print('===== Cart Id: ${cart.id} =====');
        if (cart.ordered == 1) continue;

        // Get ordering items
        var rois = _getOrderingItem(cart);

        var ro = RestOrder();

        // Customer info
        ro.customerId = 0;
        ro.customerName = '';

        // OrderNum and invoiceNum
        ro.orderNum = (i + 1).toString().padLeft(5, '0');
        ro.invoiceNum = (i + 1).toString().padLeft(5, '0');

        // Table id and number
        ro.tableId = cart.tableId;
        var rt = _restTables.firstWhereOrNull((rt) => rt.id == ro.tableId);
        if (rt == null) continue;
        ro.tableName = rt.name;
        ro.tableGroupId = rt.tableGroupId;
        ro.personNum = 1;

        // Status
        ro.status = 0;

        // WaiterName init with Admin
        ro.waiterName = 'Admin';

        // MinimumCharge init with 0.0
        ro.minimumCharge = 0.0;

        // SubTotal price and amount
        ro.subTotal = _calculateItemPrice(cart);
        ro.amount = _calculateItemPrice(cart);

        // DiscountAmt and serviceAmt init with 0.0
        ro.discountAmt = ro.serviceAmt = 0.0;

        // tax1, tax2, tax3
        ro.tax1Amt = ro.tax1TotalAmt = 0.0;
        ro.tax2Amt = ro.tax2TotalAmt = 0.0;
        ro.tax3Amt = ro.tax3TotalAmt = 0.0;

        // DeliveryFee
        ro.deliveryFee = 0.0;

        // ServicePercentage and discountPercentage
        ro.servicePercentage = ro.discountPercentage = 0.0;

        // MinimumChargeType and minimumChargeSet
        ro.minimumChargeType = 0;
        ro.minimumChargeSet = 0.0;

        // OrderCount
        ro.orderCount = 0;

        // ReceiptPrintId
        ro.receiptPrinterId = 11;

        // OrderType and orderMemberType
        ro.orderType = ro.orderMemberType = 0;

        // TaxStatus and customerOrderStatus
        ro.taxStatus = ro.customerOrderStatus = 0;

        // OrderTime, UpdateTimeStamp, kdsOrderTime and transaction
        ro.transactionTime =
            DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());

        var curTime = DateTime.now();
        ro.updateTimeStamp = DateFormat("HH:mm").format(curTime);
        ro.kdsOrderTime = DateFormat("yyyy-MM-dd HH:mm").format(curTime);
        ro.orderTime = ro.kdsOrderTime;

        // Cart
        ro.cartId = cart.id;
        ro.userId = cart.userId;
        ro.resId = cart.resId;
        ro.foodTax = cart.foodTax;
        ro.drinkTax = cart.drinkTax;
        ro.tax = cart.tax;
        ro.convienenceFee = cart.convienienceFee;
        ro.total = ro.subTotal;
        if (cart.cod != null) {
          ro.cod = cart.cod;
        }

        List<RestOrder> orders = [ro];

        var orderId = await _dbHandler.insertRestOrder(orders);
        ro.id = orderId;

        // print("Rest Items===cartpage _saveorderfunction");
        // print(rois!.length);
        // Order items
        for (var roi in rois!) {
          var orderItem = RestOrderItem();
          orderItem.orderId = orderId; // Order Id
          // orderItem.categoryName = widget.
          orderItem.itemId = roi.itemId; // itemId
          orderItem.itemName = roi.itemName; // itemName
          orderItem.price = roi.price; // price
          orderItem.qty = roi.quantity?.toDouble(); // quantity
          orderItem.orderTime = DateFormat("yyyy-MM-dd HH:mm")
              .format(DateTime.now()); // orderTime
          orderItem.status = 0; // Status
          orderItem.discountAmt = 0.0; // discountAmt
          orderItem.discountPercentage = 0.0; // discountPercentage
          orderItem.isGift = 0;
          orderItem.giftRewardPoint = 0.0;
          orderItem.printerIds = '21';
          orderItem.sequence = 0;

          // orderItem.customizations = element.customizations;
          orderItem.taxtype = roi.taxtype;
          // orderItem.itemQuantity = element.itemQuantity;
          // orderItem.itemPic = element.itemPic;
          // orderItem.itemDes = element.itemDes;
          orderItem.isShow = roi.isShow;
          orderItem.isFood = roi.isFood;
          orderItem.isState = roi.isState;
          orderItem.isCity = roi.isCity;
          orderItem.isNote = roi.isNote;
          orderItem.note = roi.note;
          orderItem.quantity = roi.quantity;
          orderItem.taxvalue = roi.taxvalue;

          // orderItems.add(orderItem);
          var oiId = await _dbHandler.insertRestOrderItem([orderItem]);
          List<ComplimentItem> compliItems = [];
          for (var ci in _mapCI[roi]!) {
            var compliItem = ComplimentItem();
            compliItem.orderId = orderId;
            compliItem.cartItemId = oiId;
            compliItem.optionName = ci.optionName;
            compliItem.optionPrice = ci.optionPrice;
            compliItem.ciId = ci.optionId;
            compliItems.add(compliItem);
          }
          await _dbHandler.insertComplimentItem(compliItems);
          if (roi == rois.last) {
            ro.id = orderId;
            _orderedProcess1(ro.id!);
          }
        }

        ros.add(ro);
      }
      // _restOrders.addAll(ros);
    } catch (e) {
      print(e);
    }
    return ros;
  }

  double _calculateItemPrice(Cart cart) {
    double foodTax = 0.0;
    double drinkTax = 0.0;
    double total = 0.0;
    double tax = 0.0;
    double subTotal = 0.0;
    double convinieceFee = 0.0;

    if (cart.cart!.isNotEmpty) {
      for (var ele in cart.cart!) {
        double itemPrice = 0.0;
        // double singleObjectPrice = 0.0;
        ele.itemPrice = ele.itemPrice! + itemPrice;
        if (ele.isFood!) {
          foodTax += (cart.foodTax! / 100) * (ele.itemPrice! * ele.quantity!);
        }
        if (ele.isCity!) {
          tax += (cart.grandTax! / 100) * (ele.itemPrice! * ele.quantity!);
        }
        if (ele.isState!) {
          drinkTax += (cart.drinkTax! / 100) * (ele.itemPrice! * ele.quantity!);
        }
        subTotal += ele.itemPrice! * ele.quantity!;
      }
      // if (response.convenienceFeeType == '2') {
      //   convinieceFee = ((subTotal * response.convienienceFee!) / 100);
      // } else {
      //   if (response.convenienceFee != null) {
      //     convinieceFee = response.convenienceFee!;
      //   }
      // }
      convinieceFee = cart.convienienceFee!;

      subTotal = subTotal + foodTax + drinkTax + tax + convinieceFee;
      total = subTotal;
    }

    return double.parse(total.toStringAsFixed(2));
  }

  ///
  /// Pre process for ordered
  ///
  Future<void> _orderedProcess1(int id) async {
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

  // Handle to sign out
  _handleSignOut() async {
    final SignInBloc sb = Provider.of<SignInBloc>(context, listen: false);

    await AppService().checkInternet().then((hasInternet) {
      if (hasInternet == false) {
        if (!_isNoInternet) {
          _isNoInternet = true;
          openSnacbar(context, 'no internet');
        }
      } else {
        sb.userSignout().then((_) {
          if (sb.hasError == false) {
            sb.afterUserSignOut();
            nextScreenCloseOthers(context, const SignIn2Page(isFirst: false));
          } else {
            openSnacbar(context, sb.errorCode);
          }
        });
      }
    });
  }

  // Handle to get restaurant table section
  Future<void> _handleRestaurantTable() async {
    final RestTableSectionBloc rtsb =
        Provider.of<RestTableSectionBloc>(context, listen: false);

    await AppService().checkInternet().then((hasInternet) async {
      if (hasInternet == false) {
        if (!_isNoInternet) {
          _isNoInternet = true;
          openSnacbar(context, 'no internet');
        }
        setState(() {
          _isLoadingTable = false;
          _isLoadedTable = false;
        });
      } else {
        print('===== table list =====');
        rtsb.getTableByRestId(Config.restaurantId.toString()).then((_) async {
          _isLoadingTable = false;
          if (rtsb.hasError == false) {
            if (rtsb.tables.isNotEmpty) {
              _restTables.clear();
              for (var rts in rtsb.tables) {
                var rt = RestTable(
                  id: rts.sectionId,
                  name: rts.sectionName,
                  num: int.parse(rts.numberOfTable!),
                  tableGroupId: rts.restaurantId,
                );
                _restTables.add(rt);
              }
              _restTables.sort(((a, b) => a.num!.compareTo(b.num!)));

              // Save tables to db
              print('tables number: ${_restTables.length}');
              //_dbHandler.insertRestTable(rts);

              // await _dbHandler.deleteAllTables();
              // await _dbHandler.insertRestTable(_restTables);

              var userId = context.read<SignInBloc>().uid;
              // await _handleGetCarts(
              //     Config.restaurantId.toString(), userId.toString());
              var carts = await _dbHandler.retireveCartsFromUserRest(
                  userId!, Config.restaurantId!);
              _carts.clear();
              _carts.addAll(carts);
              var orders = await _getOrdersFromCart(carts);
              _restOrders.clear();
              _restOrders.addAll(orders);
            } else {
              if (_restTables.isNotEmpty) {
                _restTables.clear();
                await _deleteTablesFromDb();
              }
              openSnacbar(context,
                  "User has no restaurant table. please add table in management table");
            }

            _isLoadedTable = true;
          } else {
            openSnacbar(context, rtsb.errorCode);
            _isLoadedTable = false;
          }
          setState(() {});
        });
      }
    });
  }

  // Handle to get carts in table section
  Future<void> _handleGetCarts(String restId, String userId) async {
    final AddToCartBloc acb =
        Provider.of<AddToCartBloc>(context, listen: false);

    await AppService().checkInternet().then((hasInternet) async {
      if (hasInternet == false) {
        if (!_isNoInternet) {
          _isNoInternet = true;
          openSnacbar(context, 'no internet');
        }
      } else {
        acb.getCartsById(restId, userId).then((_) async {
          if (acb.hasError == false) {
            _carts.clear();
            _carts.addAll(acb.carts);
            var orders = await _getOrdersFromCart(acb.carts);
            _restOrders.clear();
            _restOrders.addAll(orders);
          } else {
            openSnacbar(context, acb.errorCode);
          }
          setState(() {
            _isLoadedCart = true;
          });
        });
      }
    });
  }

  _handleClearCart(int userId) async {
    final CloseOrderBloc cob =
        Provider.of<CloseOrderBloc>(context, listen: false);

    await AppService().checkInternet().then((hasInternet) async {
      if (hasInternet == false) {
        if (!_isNoInternet) {
          _isNoInternet = true;
          openSnacbar(context, 'no internet');
        }
      } else {
        cob.closeOrder(userId).then((_) async {
          if (cob.hasError == false) {
            _carts.clear();
            _restOrders.clear();
          } else {
            openSnacbar(context, cob.errorCode);
          }
          setState(() {});
        });
      }
    });
  }

  _handleClearOrders(int userId) async {
    final OrderBloc cob = Provider.of<OrderBloc>(context, listen: false);
    final restBloc =
        Provider.of<HomepageRestaurantBloc>(context, listen: false);

    await AppService().checkInternet().then((hasInternet) async {
      if (hasInternet == false) {
        if (!_isNoInternet) {
          _isNoInternet = true;
          openSnacbar(context, 'no internet');
        }
      } else {
        cob.deleteOrders(userId, restBloc.shiftId).then((_) async {
          if (cob.hasError == false) {
            print('===== Orders cleared successfully =====');
          } else {
            openSnacbar(context, cob.errorCode);
          }
        });
      }
    });
  }

  ///
  int _selectLang = 1;
  _showLanguageDialog() async {
    ///
    var prefs = await SharedPreferences.getInstance();
    var lang = prefs.getString('locale') ?? 'en';
    if (lang == 'en') {
      _selectLang = 1;
    } else {
      _selectLang = 2;
    }

    ///
    var res = await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          elevation: 0,
          shape: RoundedRectangleBorder(),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RadioListTile<int>(
                  title: Text(t1English.tr()),
                  value: 1,
                  groupValue: _selectLang,
                  onChanged: (value) {
                    _selectLang = value!;
                    prefs.setString('locale', 'en');
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<int>(
                  title: Text(t1Spanish.tr()),
                  value: 2,
                  groupValue: _selectLang,
                  onChanged: (value) {
                    _selectLang = value!;
                    prefs.setString('locale', 'es');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    ///
    setState(() {
      if (_selectLang == 1) {
        context.setLocale(const Locale('en'));
      } else {
        context.setLocale(const Locale('es'));
      }
    });
  }

  Future _showExitDialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          // backgroundColor: Colors.grey[900],
          elevation: 0,
          shape: RoundedRectangleBorder(),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                dialogTitle(MediaQuery.of(context).size.width,
                    title: "Are you sure you want to go back ?"),
                Row(
                  children: [
                    dialogButton(
                        name: t1Cancel.tr(),
                        backgroundColor: Colors.red,
                        onClick: () {
                          Navigator.pop(context, false);
                        }),
                    dialogButton(
                        name: t1Confirm.tr(),
                        backgroundColor: Colors.green,
                        onClick: () async {
                          Navigator.pop(context, true);
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

  _showPayoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          // backgroundColor: Colors.grey[900],
          elevation: 0,
          shape: RoundedRectangleBorder(),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                dialogTitle(MediaQuery.of(context).size.width, title: t1Payout),
                dialogController(
                    editingController: _payoutToCtrl, hintText: 'Payout To'),
                dialogController(
                    editingController: _payoutDescriptionCtrl,
                    hintText: 'Description'),
                dialogController(
                    editingController: _payoutAmountCtrl,
                    hintText: 'Amount',
                    isNumber: true),
                Row(
                  children: [
                    dialogButton(
                        name: t1Cancel.tr(),
                        backgroundColor: Colors.red,
                        onClick: () {
                          Navigator.pop(context);
                        }),
                    dialogButton(
                        name: t1Create.tr(),
                        backgroundColor: Colors.green,
                        onClick: () async {
                          if (_payoutToCtrl.text.isNotEmpty &&
                              _payoutDescriptionCtrl.text.isNotEmpty &&
                              _payoutAmountCtrl.text.isNotEmpty) {
                            var cashierId = context.read<SignInBloc>().uid;
                            var shiftId =
                                context.read<HomepageRestaurantBloc>().shiftId;
                            _handlePayout(
                              Config.restaurantId!,
                              cashierId!,
                              shiftId!,
                              _payoutDescriptionCtrl.text,
                              _payoutToCtrl.text,
                              int.parse(_payoutAmountCtrl.text),
                            );
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

  _showReturnDialog() {
    // var name = context.read<SignInBloc>().name;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          // backgroundColor: Colors.grey[900],
          elevation: 0,
          shape: RoundedRectangleBorder(),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                dialogTitle(MediaQuery.of(context).size.width, title: t1Return),
                dialogController(
                    editingController: _returnReasonCtrl, hintText: 'Reason'),
                dialogController(
                    editingController: _returnOrderNumberCtrl,
                    hintText: 'Order number',
                    isNumber: true),
                dialogController(
                    editingController: _returnAmountCtrl,
                    hintText: 'Amount',
                    isNumber: true),
                Row(
                  children: [
                    dialogButton(
                        name: t1Cancel.tr(),
                        backgroundColor: Colors.red,
                        onClick: () {
                          Navigator.pop(context);
                        }),
                    dialogButton(
                        name: t1Return.tr(),
                        backgroundColor: Colors.green,
                        onClick: () async {
                          if (_returnReasonCtrl.text.isNotEmpty &&
                              _returnAmountCtrl.text.isNotEmpty &&
                              _returnOrderNumberCtrl.text.isNotEmpty) {
                            var cashierId = context.read<SignInBloc>().uid;
                            var shiftId =
                                context.read<HomepageRestaurantBloc>().shiftId;
                            _handleRefund(
                                Config.restaurantId!,
                                cashierId!,
                                shiftId!,
                                _returnReasonCtrl.text,
                                "CASH",
                                int.parse(_returnAmountCtrl.text),
                                int.parse(_returnOrderNumberCtrl.text));
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

  // Handle to send payout
  Future<void> _handlePayout(int restId, int userId, int shiftId,
      String description, String payoutTo, int amount) async {
    final PayoutBloc pb = Provider.of<PayoutBloc>(context, listen: false);

    await AppService().checkInternet().then((hasInternet) async {
      if (hasInternet == false) {
        if (!_isNoInternet) {
          _isNoInternet = true;
          openSnacbar(context, 'no internet');
        }
      } else {
        pb
            .payout(restId, userId, shiftId, description, payoutTo, amount)
            .then((_) async {
          openSnacbar(context, pb.message);

          if (!pb.hasError) {
            /// print
            _cashier = context.read<SignInBloc>().name ?? '';
            _payoutDesc = description;
            _payoutAmount = amount;
            setState(() {
              _isPayout = true;
            });

            await printPayoutData();

            setState(() {
              _isPayout = false;
            });
          }

          _payoutAmountCtrl.clear();
          _payoutDescriptionCtrl.clear();
          _payoutToCtrl.clear();

          Navigator.pop(context);
        });
      }
    });
  }

  // Handle to send payout
  Future<void> _handleRefund(int restId, int userId, int shiftId, String reason,
      String refundMethod, int amount, int orderNumber) async {
    final RefundBloc rb = Provider.of<RefundBloc>(context, listen: false);

    await AppService().checkInternet().then((hasInternet) async {
      if (hasInternet == false) {
        if (!_isNoInternet) {
          _isNoInternet = true;
          openSnacbar(context, 'no internet');
        }
      } else {
        rb
            .refund(restId, userId, shiftId, reason, refundMethod, orderNumber,
                amount)
            .then((_) async {
          openSnacbar(context, rb.message);

          if (!rb.hasError) {
            /// print
            _cashier = context.read<SignInBloc>().name ?? '';
            _refundReason = reason;
            _refundOrderNumber = orderNumber;
            _refundAmount = amount;
            _refundMethod = refundMethod;
            setState(() {
              _isRefunded = true;
            });

            await printRefundData();

            setState(() {
              _isRefunded = false;
            });
          }

          _returnAmountCtrl.clear();
          _returnOrderNumberCtrl.clear();
          _returnReasonCtrl.clear();

          Navigator.pop(context);
        });
      }
    });
  }

  String _cashier = "";
  String _payoutDesc = "";
  int _payoutAmount = 0;

  ///
  Widget _printPayoutWidget() {
    return SingleChildScrollView(
      child: RepaintBoundary(
        key: globalPayoutKey,
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
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(t1Payout.tr(),
                      style:
                          TextStyle(fontSize: 35, fontWeight: FontWeight.w600))
                ]),
                Container(
                  width: printWidth - 30,
                  child: printDivider(width: printWidth - 30),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Text('Cashier:     ', style: TextStyle(fontSize: 25)),
                      Text(
                        _cashier,
                        style: TextStyle(fontSize: 25),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Description: ', style: TextStyle(fontSize: 25)),
                      Text(
                        _payoutDesc,
                        maxLines: 2,
                        style: TextStyle(fontSize: 25),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Text('Amount:      ', style: TextStyle(fontSize: 25)),
                      Text(
                        '\$$_payoutAmount',
                        style: TextStyle(fontSize: 25),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: printWidth - 30,
                  child: printDivider(width: printWidth - 30),
                ),
                SizedBox(height: 5),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Text('Date: ', style: TextStyle(fontSize: 25)),
                      Text(
                        '${DateFormat("MM/dd/yyyy hh:mm:ss").format(DateTime.now())}',
                        style: TextStyle(fontSize: 25),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _refundReason = "";
  int _refundOrderNumber = 0;
  int _refundAmount = 0;
  String _refundMethod = "";

  ///
  Widget _printRefundWidget() {
    return SingleChildScrollView(
      child: RepaintBoundary(
        key: globalRefundKey,
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
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(t1Return.tr(),
                      style:
                          TextStyle(fontSize: 35, fontWeight: FontWeight.w600))
                ]),
                Container(
                  width: printWidth - 30,
                  child: printDivider(width: printWidth - 30),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Text('Cashier:   ', style: TextStyle(fontSize: 25)),
                      Text(
                        _cashier,
                        style: TextStyle(fontSize: 25),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Reason:   ', style: TextStyle(fontSize: 25)),
                      Text(
                        _refundReason,
                        maxLines: 2,
                        style: TextStyle(fontSize: 25),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Text('Order:    ', style: TextStyle(fontSize: 25)),
                      Text(
                        '$_refundOrderNumber',
                        style: TextStyle(fontSize: 25),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Text('Amount:      ', style: TextStyle(fontSize: 25)),
                      Text(
                        '\$$_refundAmount',
                        style: TextStyle(fontSize: 25),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Text('Method:   ', style: TextStyle(fontSize: 25)),
                      Text(
                        _refundMethod,
                        style: TextStyle(fontSize: 25),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: printWidth - 30,
                  child: printDivider(width: printWidth - 30),
                ),
                SizedBox(height: 5),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Text('Date: ', style: TextStyle(fontSize: 25)),
                      Text(
                        '${DateFormat("MM/dd/yyyy hh:mm:ss").format(DateTime.now())}',
                        style: TextStyle(fontSize: 25),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget printDivider({double? width}) {
    var sysWidth = MediaQuery.of(context).size.width;
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

  Future<void> printPayoutData() async {
    try {
      await Future.delayed(Duration(seconds: 3));
      List<String> imageLst = ["", "", "", "", "", ""];

      imageLst[0] = await convertImageToBase64(globalPayoutKey);

      List<String> strPrinters = await Config.getPrinters() ?? [];
      if (strPrinters.isEmpty) return showPrintAlert();

      if (strPrinters[0].isEmpty) return;

      var dio = Dio();
      var data = {};
      if (strPrinters[0].split(".").length == 4) {
        data = {"image": imageLst[0], "text": "", "printer": strPrinters[0]};
      } else {
        data = {
          "image": imageLst[0],
          "text": "",
          "printer": strPrinters[0],
          "printerType": 3
        };
      }
      if (imageLst[0] != "") {
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
      // setState(() {});
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> printRefundData() async {
    try {
      await Future.delayed(Duration(seconds: 3));
      List<String> imageLst = ["", "", "", "", "", ""];

      imageLst[0] = await convertImageToBase64(globalRefundKey);

      List<String> strPrinters = await Config.getPrinters() ?? [];
      if (strPrinters.isEmpty) return showPrintAlert();

      if (strPrinters[0].isEmpty) return;

      var dio = Dio();
      var data = {};
      if (strPrinters[0].split(".").length == 4) {
        data = {"image": imageLst[0], "text": "", "printer": strPrinters[0]};
      } else {
        data = {
          "image": imageLst[0],
          "text": "",
          "printer": strPrinters[0],
          "printerType": 3
        };
      }
      if (imageLst[0] != "") {
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
      // setState(() {});
    } catch (e) {
      print(e.toString());
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

  /// Tags dialog
  _tagsDialog(List<Item> cartedItems) {
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
                    title: t1Keep.tr()),
                _tagDialogItem(cartedItems),
                dialogController(editingController: _tagsController),
                dialogButton(
                  name: t1Save,
                  backgroundColor: Colors.red,
                  onClick: () {
                    if (_tagsController.text.isNotEmpty &&
                        cartedItems.isNotEmpty) {
                      _keepItem(_tagsController.text, cartedItems);
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// keep item
  _keepItem(String note, List<Item> cartedItems) async {
    var jsonEnc = jsonEncode(cartedItems);
    var time = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    var item = KeepItem(item: jsonEnc, note: note, time: time);

    await _dbHandler.insertKeepItem([item]);
  }

  /// Tag dialog item
  _tagDialogItem(List<Item> cartedItems) {
    return Container(
      color: Colors.white,
      height: isPortrait ? setScaleHeight(250) : setScaleHeight(200),
      padding: const EdgeInsets.all(8),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: cartedItems.length,
        itemBuilder: (_, i) {
          return GestureDetector(
            onTap: () {},
            child: Container(
              width: _width,
              height: isPortrait ? setScaleHeight(40) : setScaleHeight(60),
              decoration: BoxDecoration(
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
                            var qty = cartedItems[i].quantity;
                            if (qty! > 1) {
                              cartedItems[i].quantity = qty - 1;
                            } else {
                              _mapCI.remove(cartedItems[i]);
                              cartedItems.removeAt(i);
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
                          cartedItems[i].quantity.toString(),
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
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.all(isPortrait ? 4.0 : 8.0),
                        child: Text(
                          cartedItems[i].itemName!,
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
                            cartedItems[i].quantity =
                                cartedItems[i].quantity! + 1;
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
                          '\$${cartedItems[i].itemPrice! * cartedItems[i].quantity!}',
                          style: TextStyle(
                            fontSize:
                                isPortrait ? setFontSize(8) : setFontSize(14),
                          ),
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

  /// Retrieve dialog
  _retrieveDialog(List<Item> cartedItems) async {
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
                            cartedItems.clear();
                            List<Item> items =
                                _getItems(keepItems[index].item!);
                            cartedItems.addAll(items);
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

  /// calculate total price of tag items
  _getPrice(String keepItem) {
    var items = _getItems(keepItem);
    var price = 0.0;
    for (var element in items) {
      price += element.itemPrice!;
    }
    return price;
  }

  // get tag items from json
  List<Item> _getItems(String keepItem) {
    List<dynamic> snap = [];
    snap.addAll(jsonDecode(keepItem));
    List<Item> items = snap.map((e) => Item.fromJson2(e)).toList();
    return items;
  }

  /// Get carts from db
  _getCartsFromDb() async {
    var carts = await _dbHandler.retireveCarts();

    _carts.clear();
    _carts.addAll(carts);
    var orders = await _getOrdersFromCart(carts);
    _restOrders.clear();
    _restOrders.addAll(orders);
  }

  /// Save database file
  _saveDatabase() async {
    final dbFolder = await getDatabasesPath();
    File source1 = File('$dbFolder/zabor_pos.db');

    Directory copyTo = Directory("storage/emulated/0/Download");
    if ((await copyTo.exists())) {
      // print("Path exist");
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
    } else {
      print("not exist");
      if (await Permission.storage.request().isGranted) {
        // Either the permission was already granted before or the user just granted it.
        await copyTo.create();
      } else {
        print('Please give permission');
      }
    }

    String newPath = "${copyTo.path}/zabor_pos.db";
    await source1.copy(newPath);
    openSnacbar(context, 'The db file is saved to Download folder');
  }

  ///
  _importDatabase() async {
    var databasesPath = await getDatabasesPath();
    var dbPath = path.join(databasesPath, 'zabor_pos.db');

    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File source = File(result.files.single.path!);
      await source.copy(dbPath);
    } else {
      // User canceled the picker
    }
  }

  /// Check opened shift
  Future<bool> _checkOpenedShift() async {
    var shiftId = await _dbHandler.getCurrenShiftId(Config.restaurantId!);
    var shiftMap =
        await _dbHandler.getShift(Config.restaurantId!, shiftId) ?? {};
    if (shiftMap['drawer_cash_on_close'] == null) {
      return false;
    }
    return true;
  }

  /// Delete all carts by shift Id
  _deleteCarts() async {
    await _dbHandler.clearCarts();
  }
}
