import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:zabor/api/my_api.dart';
import 'package:zabor/models/basket.dart';
import 'package:zabor/models/item.dart';
import 'package:zabor/models/rest_order_item.dart';
import 'package:zabor/models/rest_table.dart';
import 'package:zabor/models/tax.dart';
// import 'package:zabor/pages/calculator_screen.dart';
import 'package:zabor/pages/sign_in.dart';
import 'package:zabor/pages/summary_page.dart';
import 'package:zabor/pages/summary_total_page.dart';
import 'package:zabor/utils/t1_string.dart';

import '../blocs/basket_bloc.dart';
// import '../blocs/sign_in_bloc.dart';
import '../blocs/sign_in_bloc.dart';
import '../blocs/tax_bloc.dart';
import '../config/config.dart';
import '../db/database_handler.dart';
import '../models/cart.dart';
import '../models/compliment_item.dart';
import '../models/customization_item.dart';
import '../models/rest_order.dart';
import '../services/services.dart';
import '../utils/next_screen.dart';
import '../utils/snacbar.dart';
import '../utils/utils.dart';
import 'sign_in2.dart';
// import 'order_page.dart';

enum PaymentStatus { paid, unpaid, all }

class UnpaidPageTable extends StatefulWidget {
  const UnpaidPageTable({
    Key? key,
    this.orderState,
    this.restTable,
    this.personNum,
    this.restOrder,
    this.cart,
    //this.responses,
    this.tables,
  }) : super(key: key);

  final int? orderState;
  final RestTable? restTable;
  final int? personNum;
  final RestOrder? restOrder;
  final Cart? cart;
  //final Responses? responses;
  final List<RestTable>? tables;

  @override
  State<UnpaidPageTable> createState() => _UnpaidPageStateTable();
}

class _UnpaidPageStateTable extends State<UnpaidPageTable>
    with TickerProviderStateMixin {
  final DatabaseHandler _dbHandler = DatabaseHandler();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController? _tabController;
  final List<RestOrder> _restOrders = [];
  final List<RestOrderItem> _restOrderItems = [];
  final List<RestTable> _restTables = [];
  final List<Item> _items = [];
  // List<dynamic>? _ordersFromKiosk = [];
  // List<dynamic>? _allOrdersFromKiosk = [];
  // List<dynamic>? _ordersfromTable = [];

  int personNumber = 0;
  int orderState = 0;
  int? tableId;
  String? tableName;
  int? tableGroupId;
  // bool _takeoutProcessing = false;
  // bool _isDineIn = false;

  PaymentStatus selectedPaymentFilter = PaymentStatus.all;
  final List<Tab> _tabs = [
    /*const*/ Tab(text: t1All.tr()),
    ////*const*/ Tab(text: t1DineIn.tr()),
    // const Tab(
    //text: "Kiosk",
    // )
  ];

  RestOrder? _selectOrder;
  Cart? _cart;
  Tax? _tax;
  Basket? _basket;
  int? _orderIndex;
  int? _userId;

  // var scaleWidth = 0.0;
  // var scaleHeight = 0.0;
  var _width = 0.0;
  var _height = 0.0;

  // var isPortrait = false;
  var _isLoadingPay = false;
  // var _isLoaded = false;

//Filtro implementado para visualizar las órdenes por mesa
  RestOrder? _getRestOrderTable(String name) {
    RestOrder? restOrder;
    for (int i = 0; i < _restOrders.length; i++) {
      if (_restOrders[i].tableName == widget.restTable!.name) {
        //if (_restOrders[i].tableName == 'mesa_prueba_5') {
        restOrder = _restOrders[i];
        break;
      }
    }
    return restOrder;
  }

  ///
  /// Get rest table from db
  ///
  _getRestTablesFromDb() {
    _dbHandler.retireveRestTable().then((value) {
      _restTables.clear();
      _restTables.addAll(value);
      setState(() {});
    });
  }

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
      _selectOrder = value.first;
      _orderIndex = 0;
      setState(() {});
    });
  }

  //Consulta en base de datos para llamar las órdenes por mesa
  _getDataOrdersTableFromDb() {
    // Rest Order
    _dbHandler.retireveRestOrders().then((value) {
      _restOrders.clear();
      for (var element in value) {
        if (element.tableGroupId == Config.restaurantId &&
            element.tableName == widget.restTable!.name) {
          _restOrders.add(element);
        }
      }
      _selectOrder = value.last;
      _orderIndex = 0;
      setState(() {});
    });
  }

  ///
  /// Get orders from db
  ///
  _getOrderItemsFromDb(int orderId) {
    // Rest Order Items
    _dbHandler.retireveRestOrderItemFromOrderId(orderId).then((value) {
      _restOrderItems.clear();
      _restOrderItems.addAll(value);
      setState(() {});
    });
  }

  RestOrder? _getRestOrder(String? name, int? groupId) {
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

  @override
  void initState() {
    orderState = widget.orderState!;
    tableId = widget.restTable!.id;
    //userId = context.read<SignInBloc>().uid;
    if (orderState != 0 && tableId != null) {
      personNumber = widget.personNum!;
      //tableId = widget.restTable!.id;
      tableName = widget.restTable!.name;
      tableGroupId = widget.restTable!.tableGroupId;

      _tabController = TabController(length: _tabs.length, vsync: this);
      _userId = context.read<SignInBloc>().uid;

      //_getRestOrder(tableName!, tableGroupId!);
      _getRestOrderTable(tableName!);
    } else {
      personNumber = 1;
      tableId = -1;
      tableName = t1TakeOut.tr();
      tableGroupId = -1;

      _tabController = TabController(length: _tabs.length, vsync: this);
      _userId = context.read<SignInBloc>().uid;
      _getRestOrderTable(tableName!);
      //_getDataFromDb();
      _getDataOrdersTableFromDb();
      //_getRestTablesFromDb();

      //_getDataFromKiosk(_userId!);

      super.initState();
    }
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;

    isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

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
      appBar: _appbar(),
      body: _body(),
    );
  }

  _appbar() {
    return AppBar(
      leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          )),
      backgroundColor: Config().appColor,
      title: /*const*/ Text(
          //t1Unpaid.tr(),
          "Ordenes Mesas"),
      bottom: TabBar(
        controller: _tabController,
        tabs: _tabs,
      ),
    );
  }

  _body() {
    return TabBarView(
      controller: _tabController,
      children: [
        _content(),
        //Container(),
        //_kiosk(),
      ],
    );
  }

  getCustomization(List customization) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (Map data in customization) Text(data["option_name"].toString())
    ]);
  }

  _content() {
    return _isLoadingPay
        ? const Center(child: CircularProgressIndicator())
        : Row(
            children: [
              _leftContent(),
              const VerticalDivider(width: 1, color: Colors.grey),
              _selectOrder == null ? Container() : _rightContent(_selectOrder!),
            ],
          );
  }

  _leftContent() {
    return Container(
      width: _width * 6 / 10,
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              physics: const ScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                //crossAxisCount: 2,
                crossAxisCount: 1,
                crossAxisSpacing: 0.0,
                mainAxisSpacing: 0.0,
                //
                childAspectRatio: 10 / 3,
              ),
              itemCount: _restOrders.length,
              itemBuilder: (context, name) {
                return GestureDetector(
                  onTap: (() {
                    _selectOrder = _restOrders[name];
                    _orderIndex = name;
                    setState(() {});
                  }),
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    // color: Colors.orange,
                    child: Stack(
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                              top: setScaleHeight(isPortrait ? 10 : 14)),
                          padding: EdgeInsets.only(
                            top: setScaleHeight(isPortrait ? 12 : 20),
                            right: setScaleWidth(isPortrait ? 2 : 4),
                            left: setScaleWidth(isPortrait ? 2 : 4),
                            bottom: setScaleHeight(isPortrait ? 2 : 4),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: _orderIndex == /*index*/ name
                                ? Colors.orange[400]
                                : Colors.grey[300],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _restOrders[/*index*/ name].tableName!,
                                    style: TextStyle(
                                      fontSize:
                                          setFontSize(isPortrait ? 10 : 20),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    //t1Amount.tr(),
                                    'Valor Orden:',
                                    style: TextStyle(
                                      fontSize:
                                          setFontSize(isPortrait ? 10 : 20),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '\$${_restOrders[/*index*/ name].amount}',
                                    style: TextStyle(
                                      fontSize:
                                          setFontSize(isPortrait ? 10 : 20),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    t1Time.tr(),
                                    style: TextStyle(
                                      fontSize:
                                          setFontSize(isPortrait ? 10 : 20),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${_restOrders[/*index*/ name].updateTimeStamp}',
                                    style: TextStyle(
                                      fontSize:
                                          setFontSize(isPortrait ? 10 : 20),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            // height: setScaleHeight(20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.orange[400]),
                            padding: const EdgeInsets.all(4),
                            child: IntrinsicWidth(
                              child: Text(
                                //NumberFormat('00000', 'en_US')
                                NumberFormat('00000', 'es_CO')
                                    .format(_restOrders[/*index*/ name].id),
                                style: TextStyle(
                                    fontSize: setFontSize(isPortrait ? 12 : 24),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: Colors.grey),

          //Bloque de código prueba para capturar el dato que viene de TableOrdersPage
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: setScaleWidth(isPortrait ? 5 : 10),
            ),
            child: Row(
              children: [
                Text(
                  //{orderState}.toString(),
                  "Cantidad órdenes:",
                  style: TextStyle(
                    fontSize: setFontSize(isPortrait ? 10 : 20),
                  ),
                ),
                const Spacer(),
                Text(
                  //_restOrders.length.toString(),
                  //{widget.restTable!.name}.toString(),
                  "",
                  style: TextStyle(
                    fontSize: setFontSize(isPortrait ? 10 : 20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  //'\$ ${_calculateTotalOrder().toString()}',
                  {_restOrders.length}.toString(),
                  style: TextStyle(
                    fontSize: setFontSize(isPortrait ? 10 : 20),
                  ),
                ),
              ],
            ),
          ),

          //Fin de código de prueba

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: setScaleWidth(isPortrait ? 5 : 10),
            ),
            child: Row(
              children: [
                Text(
                  t1Total.tr(),
                  style: TextStyle(
                    fontSize: setFontSize(isPortrait ? 10 : 20),
                  ),
                ),
                const Spacer(),
                Text(
                  _restOrders.length.toString(),
                  //'1',
                  style: TextStyle(
                    fontSize: setFontSize(isPortrait ? 10 : 20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '\$ ${_calculateTotalOrder().toString()}',
                  //'${60669.0}',
                  style: TextStyle(
                    fontSize: setFontSize(isPortrait ? 10 : 20),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: setScaleWidth(isPortrait ? 5 : 10),
            ),

            //Se comenta codepaeza 09/06/2023 para deshabilitar opción botón azul
            /*
        child: Row(
        children: [

                /*child:*/ GestureDetector(
                  onTap: (() {
                    _payTotal();
                  }),
                  child: Container(
                    height: setScaleHeight(50),
                    width: setScaleWidth(220),
                    color: Colors.blue,
                    child: Center(
                      child: Text(
                        //t1Pay.tr(),
                        "Pagar Total Mesa",
                        style: TextStyle(
                          fontSize: setFontSize(isPortrait ? 12 : 20),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                  ]
        ),*/
          ),
        ],
      ),
    );
  }

  _rightContent(RestOrder restOrder) {
    _getOrderItemsFromDb(restOrder.id!);
    return Container(
      width: _width * 4 / 10 - 1,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const ScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Table: ${restOrder.tableName}, ${restOrder.personNum} Guests',
                      style: TextStyle(
                        fontSize: setFontSize(isPortrait ? 10 : 16),
                      ),
                    ),
                    Text(
                      'Invoice: ${restOrder.invoiceNum}',
                      style: TextStyle(
                        fontSize: setFontSize(isPortrait ? 10 : 16),
                      ),
                    ),
                    Text(
                      'Time: ${restOrder.orderTime}',
                      style: TextStyle(
                        fontSize: setFontSize(isPortrait ? 10 : 16),
                      ),
                    ),
                    _restOrderItems.isEmpty
                        ? Container()
                        : const Divider(height: 1, color: Colors.grey),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: _restOrderItems.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            Text(
                              '${index + 1} ${_restOrderItems[index].itemName}',
                              style: TextStyle(
                                fontSize: setFontSize(isPortrait ? 10 : 16),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '\$ ${_restOrderItems[index].price}',
                              style: TextStyle(
                                fontSize: setFontSize(isPortrait ? 10 : 16),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const Divider(height: 1, color: Colors.grey),
                    IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Qty: ${_calculateTotalQty(_restOrderItems)}',
                            style: TextStyle(
                              fontSize: setFontSize(isPortrait ? 10 : 16),
                            ),
                          ),
                          const Spacer(),
                          IntrinsicWidth(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '$t1Subtotal:',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize:
                                              setFontSize(isPortrait ? 10 : 16),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '\$${_calculateSubTotal(_restOrderItems)}',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize:
                                              setFontSize(isPortrait ? 10 : 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '$t1StateRate:',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize:
                                              setFontSize(isPortrait ? 10 : 16),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '\$${(restOrder.amount! - _calculateSubTotal(_restOrderItems)).toStringAsFixed(2)}',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize:
                                              setFontSize(isPortrait ? 10 : 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '$t1Total:',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize:
                                              setFontSize(isPortrait ? 12 : 18),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '\$${restOrder.amount}',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize:
                                              setFontSize(isPortrait ? 12 : 18),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              /*Expanded(
                child: Container(
                  height: setScaleHeight(50),
                  color: Colors.blue,
                  child: Center(
                    child: Text(
                      t1Void.tr(),
                      style: TextStyle(
                        fontSize: setFontSize(isPortrait ? 12 : 20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),*/
              Expanded(
                child: GestureDetector(
                  onTap: (() {
                    _pay();
                  }),
                  child: Container(
                    height: setScaleHeight(50),
                    color: Colors.red,
                    child: Center(
                      child: Text(
                        //t1Pay.tr(),
                        "Pagar Orden",
                        style: TextStyle(
                          fontSize: setFontSize(isPortrait ? 12 : 20),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

/*
      RestTable? _getRestTableFromOrder(int groupId, String name) {
        RestTable? restTable;
        for (var element in _restTables) {
          if (element.tableGroupId == groupId && element.name == name) {
            restTable = element;
          }
        }
        return restTable;
      }
*/
  _calculateSubTotal(List<RestOrderItem> rois) {
    var subtotal = 0.0;
    for (var element in rois) {
      subtotal += element.price!;
    }
    return subtotal;
  }

  _calculateTotalQty(List<RestOrderItem> rois) {
    var qty = 0;
    for (var element in rois) {
      qty += element.qty!.toInt();
    }
    return qty;
  }

  _calculateTotalOrder() {
    var total = 0.0;
    for (var element in _restOrders) {
      total += element.amount!;
    }
    return total;
  }

  _calculateTotalTaxOrder() {
    var total = 0.0;
    for (var element in _restOrders) {
      total += element.amount!;
    }
    return total;
  }

  _pay() {
    setState(() {
      _isLoadingPay = true;
    });

    // Get cart from order
    _getCartFromRestOrder(_selectOrder!);
    //
    _handleGetTax(); //Comentado codepaeza 31/05/2023
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
      cartItem.customization = [];
      //cartItem.customization!.addAll(mapCustomItem[element.id]!);

      // Add item
      _cart!.cart!.add(cartItem);
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

  // Handle to get tax
  _handleGetTax() async {
    final TaxBloc tb = Provider.of<TaxBloc>(context, listen: false);

    await AppService().checkInternet().then((hasInternet) async {
      if (hasInternet == false) {
        openSnacbar(context, 'no internet');
      } else {
        tb.getTax().then((_) async {
          if (tb.hasError == false) {
            _tax = tb.tax;
            // if (widget.isOrdered == false) {
            //if (_isLoadingPay == false) {
            _handleGetBasket();
            // }
          } else {
            openSnacbar(context, tb.errorCode);
          }
          setState(() {
            // _isLoaded = true;
          });
          //};
        });
      }
      ;
    });
  }

  _handleGetTaxTotal() async {
    final TaxBloc tb = Provider.of<TaxBloc>(context, listen: false);

    await AppService().checkInternet().then((hasInternet) async {
      if (hasInternet == false) {
        openSnacbar(context, 'no internet');
      } else {
        tb.getTax().then((_) async {
          if (tb.hasError == false) {
            _tax = tb.tax;
            // if (widget.isOrdered == false) {
            _handleGetBasketTotal();
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
        openSnacbar(context, 'no internet');
      } else {
        bb.getBasket(_userId).then((_) async {
          if (bb.hasError == false) {
            _basket = bb.basket;

            _cart!.id = _basket!.id;
            // _cart!.carts = widget.cart!.carts ?? _cart!.carts;
            _cart!.drinkTax = double.parse(_basket!.drinkTax.toString());
            _cart!.foodTax = double.parse(_basket!.foodTax.toString());

            _cart!.resId = _basket!.resId;
            _cart!.resId = Config.restaurantId;
            _cart!.subtotal = _basket!.subtotal;
            _cart!.tax = _basket!.tax;
            _cart!.total = _basket!.total;
            _cart!.userId = _basket!.userId;
            _cart!.cod = _basket!.cod;

            // _saveOrderingItem(_cart!);
            _items.addAll(_cart!.cart!);

            //
            _dbHandler
                .retireveComplimentItemFromOrderId(_selectOrder!.id!)
                .then((value) {
              // _complimentItems.addAll(value);
              //
              _getCartItemsFromRestOrderItem(_restOrderItems, value);
              nextScreen(
                  context,
                  SummaryPage(
                    cart: _cart,
                    tax: _tax,
                    deliveryMode: 2,
                    restOrder: _selectOrder!,
                    paymentMode: 2,
                  ));
            });
            setState(() {
              _isLoadingPay = true;
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
            _isLoadingPay = false;
          });
        });
      }
    });
  }

  _handleGetBasketTotal() async {
    final BasketBloc bb = Provider.of<BasketBloc>(context, listen: false);

    await AppService().checkInternet().then((hasInternet) async {
      if (hasInternet == false) {
        openSnacbar(context, 'no internet');
      } else {
        bb.getBasket(_userId).then((_) async {
          if (bb.hasError == false) {
            _basket = bb.basket;

            _cart!.id = _basket!.id;
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

            //
            _dbHandler
                .retireveComplimentItemFromOrderId(_selectOrder!.id!)
                .then((value) {
              // _complimentItems.addAll(value);
              //
              _getCartItemsFromRestOrderItem(_restOrderItems, value);
              // nextScreen(
              //     context,
              //     SummaryTotalPage(
              //       cart: _cart,
              //       tax: _tax,
              //       deliveryMode: 2,
              //       restOrder: _selectOrder!,
              //       paymentMode: 1,
              //     ));
            });
            setState(() {
              _isLoadingPay = false;
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
            _isLoadingPay = false;
          });
        });
      }
    });
  }
}
