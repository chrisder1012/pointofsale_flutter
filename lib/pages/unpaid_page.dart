import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zabor/api/my_api.dart';
import 'package:zabor/models/basket.dart';
import 'package:zabor/models/item.dart';
import 'package:zabor/models/rest_order_item.dart';
import 'package:zabor/models/rest_table.dart';
import 'package:zabor/models/tax.dart';
import 'package:zabor/pages/calculator_screen.dart';
import 'package:zabor/pages/sign_in.dart';
import 'package:zabor/pages/summary_page.dart';
import 'package:zabor/utils/t1_string.dart';

import '../blocs/basket_bloc.dart';
// import '../blocs/sign_in_bloc.dart';
import '../blocs/close_order_bloc.dart';
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

class UnpaidPage extends StatefulWidget {
  const UnpaidPage({Key? key}) : super(key: key);

  @override
  State<UnpaidPage> createState() => _UnpaidPageState();
}

class _UnpaidPageState extends State<UnpaidPage> with TickerProviderStateMixin {
  final DatabaseHandler _dbHandler = DatabaseHandler();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController? _tabController;
  List<RestOrder> _restOrders = [];
  final List<RestOrderItem> _restOrderItems = [];
  final List<RestTable> _restTables = [];
  final List<Item> _items = [];
  List<dynamic>? _ordersFromKiosk = [];
  List<dynamic>? _allOrdersFromKiosk = [];

  PaymentStatus selectedPaymentFilter = PaymentStatus.unpaid;
  final List<Tab> _tabs = [
    /*const*/ Tab(text: t1All.tr()),
    /*const*/ Tab(text: t1DineIn.tr()),
    const Tab(
      text: "Kiosk",
    )
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

  late CloseOrderBloc cob;

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

  //get orders from koisk
  _getDataFromKiosk(int userId) async {
    _restOrders.clear();
    userId = context.read<SignInBloc>().uid!;

    var response = await CallApi().getDataWithToken(
        "get-unpaid-orders?user_id=$userId&paging=true&page=1&res_id=${Config.restaurantId}");
    List<dynamic>? orders = response.data!["data"];
    _ordersFromKiosk = orders;

    _allOrdersFromKiosk = orders; //dummy variable
    // Showing only unpaid orders
    if (orders != null) {
      _ordersFromKiosk =
          orders.where((element) => element["payment_status"] == 0).toList();
      cob.ordersFromKiosk =
          orders.where((element) => element["payment_status"] == 0).toList();
    }
    setState(() {});
  }

  filterUnpaidOrders(int? paymentStatus) {
    //0 is unpaid ,1 is paid
    if (paymentStatus == 0) {
      _ordersFromKiosk = _allOrdersFromKiosk!
          .where((element) => element["payment_status"] == 0)
          .toList();
    } else if (paymentStatus == 1) {
      _ordersFromKiosk = _allOrdersFromKiosk!
          .where((element) => element["payment_status"] == 1)
          .toList();
    } else {
      _ordersFromKiosk = _allOrdersFromKiosk;
    }
    setState(() {});
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

  @override
  void initState() {
    cob = Provider.of<CloseOrderBloc>(context, listen: false);
    cob.sib = Provider.of<SignInBloc>(context, listen: false);
    _tabController = TabController(length: _tabs.length, vsync: this);
    _userId = context.read<SignInBloc>().uid;
    _getDataFromDb();
    _getRestTablesFromDb();
    // _getDataFromKiosk(_userId!);
    cob.getDataFromKiosk();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    cob = Provider.of<CloseOrderBloc>(context, listen: true);
    _ordersFromKiosk = cob.ordersFromKiosk;
    _allOrdersFromKiosk = cob.allOrdersFromKiosk;
    _restOrders = cob.restOrders;
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
      // backgroundColor: Colors.grey[900],
      appBar: _appbar(),
      body: _body(),
    );
  }

  _appbar() {
    return AppBar(
      toolbarHeight: setScaleHeight(40),
      leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: setScaleHeight(15),
          )),
      backgroundColor: Config().appColor,
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          t1Unpaid.tr(),
          style: TextStyle(fontSize: 22),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.search,
              color: Colors.white,
              size: setScaleHeight(15),
            ),
          ),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        labelStyle: TextStyle(fontSize: 22),
        labelColor: Colors.white,
        unselectedLabelStyle: TextStyle(fontSize: 22),
        unselectedLabelColor: Colors.white60,
        tabs: _tabs,
      ),
    );
  }

  _body() {
    return TabBarView(
      controller: _tabController,
      children: [
        _content(),
        Container(),
        _kiosk(),
      ],
    );
  }

  _kiosk() {
    return Container(
      width: _width * 6 / 10,
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: Scrollbar(
              thickness: 10,
              thumbVisibility: true,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  physics: const ClampingScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    //crossAxisCount: 2,
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    //childAspectRatio: 4 / 3,
                    childAspectRatio: 3 / 4,
                  ),
                  itemCount: _ordersFromKiosk!.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: (() {
                        _selectOrder = _restOrders[index];
                        _orderIndex = index;
                        setState(() {});
                      }),
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        // color: Colors.orange,
                        child: Container(
                          margin: EdgeInsets.only(
                              top: setScaleHeight(isPortrait ? 10 : 14)),
                          padding: EdgeInsets.only(
                            // top: setScaleHeight(isPortrait ? 12 : 20),
                            right: setScaleWidth(isPortrait ? 2 : 4),
                            left: setScaleWidth(isPortrait ? 2 : 4),
                            bottom: setScaleHeight(isPortrait ? 2 : 4),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color:
                                _ordersFromKiosk![index]["payment_status"] == 0
                                    ? Colors.amber
                                    : Colors.grey[400],
                            boxShadow: [
                              BoxShadow(
                                  color: Config().kBlackColor54,
                                  blurRadius: 5,
                                  spreadRadius: 0.5),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                _ordersFromKiosk![index]["id"]!.toString(),
                                style: TextStyle(
                                  fontSize: setFontSize(isPortrait ? 10 : 20),
                                ),
                              ),
                              Text(
                                _ordersFromKiosk![index]["order_status"]!
                                        .toString() +
                                    " | " +
                                    (_ordersFromKiosk![index]["payment_status"]!
                                                .toString() ==
                                            "0"
                                        ? "Unpaid"
                                        : "Paid"),
                                style: TextStyle(
                                  fontSize: setFontSize(isPortrait ? 10 : 20),
                                ),
                              ),
                              Divider(),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      for (dynamic cartItem
                                          in _ordersFromKiosk![index]
                                              ["cart"]) ...[
                                        // ListTile(
                                        //   title: Text(
                                        //     _ordersFromKiosk![index].toString(),
                                        //   ),
                                        // ),
                                        SizedBox(
                                          height: 50,
                                          child: ListTile(
                                            title: Text(
                                              cartItem["itemName"].toString(),
                                            ),
                                            subtitle: getCustomization(
                                                cartItem["customization"]),
                                            trailing: Text("x" +
                                                cartItem["quantity"]
                                                    .toString()),
                                          ),
                                        ),
                                      ],
                                      Divider(
                                        height: 1,
                                      ),
                                      SizedBox(
                                        height: 40,
                                        child: ListTile(
                                          title: Text("Sub-Total"),
                                          trailing: Text(
                                            _ordersFromKiosk![index]["subtotal"]
                                                .toString(),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 40,
                                        child: ListTile(
                                          title: Text(t1FoodTax.tr()),
                                          trailing: Text(
                                            _ordersFromKiosk![index]["food_tax"]
                                                .toString(),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 40,
                                        child: ListTile(
                                          title: Text(t1DrinkTax.tr()),
                                          trailing: Text(
                                            _ordersFromKiosk![index]
                                                    ["drink_tax"]
                                                .toString(),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 40,
                                        child: ListTile(
                                          title: Text(t1CityTax.tr()),
                                          trailing: Text(
                                            _ordersFromKiosk![index]["tax"]
                                                .toString(),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 40,
                                        child: ListTile(
                                          title: Text(t1Discount.tr()),
                                          trailing: Text(
                                            _ordersFromKiosk![index]["discount"]
                                                .toString(),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 40,
                                        child: ListTile(
                                          title: Text(t1ConvenienceFee.tr()),
                                          trailing: Text(
                                            _ordersFromKiosk![index]
                                                    ["convenience_fee"]
                                                .toString(),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 40,
                                        child: ListTile(
                                          title: Text(t1TotalFromAPI.tr()),
                                          trailing: Text(
                                            _ordersFromKiosk![index]["total"]
                                                .toString(),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 40,
                                        child: ListTile(
                                          title: Text(t1CalculatedTotal.tr()),
                                          trailing: Text(
                                            /*((_ordersFromKiosk![index]["subtotal"] +
                                                    _ordersFromKiosk![index]
                                                        ["food_tax"] +
                                                    _ordersFromKiosk![index]
                                                        ["drink_tax"] +
                                                    _ordersFromKiosk![index]["tax"] +
                                                    _ordersFromKiosk![index][
                                                        "convenience_fee"]) as double)*/

                                            //Modified codepaeza 17-04-2023
                                            ((_ordersFromKiosk![index]
                                                            ["subtotal"] +
                                                        _ordersFromKiosk![index]
                                                            ["food_tax"] +
                                                        _ordersFromKiosk![index]
                                                            ["drink_tax"] +
                                                        _ordersFromKiosk![index]
                                                            ["tax"] +
                                                        _ordersFromKiosk![index]
                                                            ["convenience_fee"])
                                                    as dynamic)
                                                .toStringAsFixed(2),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(),
                              TextButton(
                                onPressed: () async {
                                  nextScreen(
                                      //TODO: make models for kiosk order
                                      context,
                                      Calculator(
                                        forKioskOrder: true,
                                        total: double.parse(
                                            ((_ordersFromKiosk![index]
                                                            ["subtotal"] +
                                                        _ordersFromKiosk![index]
                                                            ["food_tax"] +
                                                        _ordersFromKiosk![index]
                                                            ["drink_tax"] +
                                                        _ordersFromKiosk![index]
                                                            ["tax"] +
                                                        _ordersFromKiosk![index]
                                                            ["convenience_fee"])
                                                    as dynamic)
                                                .toStringAsFixed(2)),
                                        orderNo: _ordersFromKiosk![index]["id"]!
                                            .toString(),
                                        userId: _userId!,
                                      ));
                                },
                                child: Text(
                                  //"Confirm Order",
                                  t1ConfirmOrder,
                                  style: TextStyle(
                                    fontSize: setFontSize(isPortrait ? 15 : 30),
                                    color: Colors.white,
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
              ),
            ),
          ),
        ],
      ),
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
            //Adicionado codepaeza 29/04/2023

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
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: (() {
                    _selectOrder = _restOrders[index];
                    _orderIndex = index;
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
                            color: _orderIndex == index
                                ? Colors.orange[400]
                                : Colors.grey[300],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _restOrders[index].tableName!,
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
                                    t1Amount.tr(),
                                    style: TextStyle(
                                      fontSize:
                                          setFontSize(isPortrait ? 10 : 20),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '\$${_restOrders[index].amount}',
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
                                    '${_restOrders[index].updateTimeStamp}',
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
                                NumberFormat('00000', 'en_US')
                                    .format(_restOrders[index].id),
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
                  style: TextStyle(
                    fontSize: setFontSize(isPortrait ? 10 : 20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '\$ ${_calculateTotalOrder().toString()}',
                  style: TextStyle(
                    fontSize: setFontSize(isPortrait ? 10 : 20),
                  ),
                ),
              ],
            ),
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
                        t1Pay.tr(),
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

  _pay() {
    setState(() {
      _isLoadingPay = true;
    });

    // Get cart from order
    _getCartFromRestOrder(_selectOrder!);
    //
    _handleGetTax(); //Comentado por codepaeza 10/05/2023- Descomentado 31/05/2023

    print(["unpaid_page", _selectOrder?.total]);
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
      //cartItem.customization!.addAll(mapCustomItem[element.id]!); //Comentado codepaeza 06/06/2023
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
            //if (widget.isOrdered == false) {  //Se retira comentario codepaeza 31/05/2023
            //Se inserta línea codepaeza 31/05/2023
            //if(_isLoadingPay== false){
            _handleGetBasket();
            print(
                "esta ejecutando linea 1081 -unpaid_page"); //se retira comentario codepaeza 31/05/2023
          } else {
            openSnacbar(context, tb.errorCode);
            print("envía mensaje error- unpaid_page");
          }
          setState(() {
            // _isLoaded = true;
            //_isLoadingPay = true; //Se inserta codepaeza 31/05/2023
          });
          //};
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
            print("Confirma bb.hasError == false - unpaid_page");
            _basket = bb.basket;
            print(_basket.toString() + '- unpaid-page');

            _cart!.id = _basket!.id;
            print(_cart!.id.toString() + '- unpaid_page');
            // _cart!.carts = widget.cart!.carts ?? _cart!.carts;
            _cart!.drinkTax = double.parse(_basket!.drinkTax.toString());
            print(_cart!.drinkTax.toString() + '- unpaid_page');

            _cart!.foodTax = double.parse(_basket!.foodTax.toString());
            print(_cart!.foodTax.toString() + 'unpaid_page');

            _cart!.resId = _basket!.resId;
            print(_cart!.resId.toString() + ' - unpaid_page');

            _cart!.resId = Config.restaurantId;
            print(_cart!.resId.toString() + ' -unpaid_page');

            _cart!.subtotal = _basket!.subtotal;
            print(_cart!.subtotal.toString() + '- unpaid_page');

            _cart!.tax = _basket!.tax;
            print(_cart!.tax.toString() + '- unpaid_page');

            _cart!.total = _basket!.total;
            print(_cart!.total.toString() + '- unpaid_page');

            _cart!.userId = _basket!.userId;
            print(_cart!.userId.toString() + '- unpaid_page');

            _cart!.cod = _basket!.cod;
            print(_cart!.cod.toString() + ' - unpaid_page');

            //_saveOrderingItem(_cart!);
            _items.addAll(_cart!.cart!);

            //
            _dbHandler
                .retireveComplimentItemFromOrderId(_selectOrder!.id!)
                .then((value) {
              //_complimentItems.addAll(value);

              _getCartItemsFromRestOrderItem(_restOrderItems, value);
              nextScreen(
                  context,
                  SummaryPage(
                    cart: _cart,
                    tax: _tax,
                    deliveryMode: 2,
                    restOrder: _selectOrder!,
                    paymentMode: 2, //Cambia de 1 a 2 codepaeza 31/05/2023
                  ));
            } //Comentado por estar asociado a dbhandler
                    ); //idem
            print(_cart.toString() + ' - unpaid_page');
            setState(() {
              _isLoadingPay = true;
              print("Confirma isLoadingPay = true - unpaid_page");
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
