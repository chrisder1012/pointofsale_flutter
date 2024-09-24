import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:zabor/models/item.dart';
import 'package:zabor/models/rest_table.dart';
import 'package:zabor/models/restaurant.dart';

import '../config/config.dart';
import '../models/cart.dart';
import '../models/customization_item.dart';
import '../models/rest_order.dart';
import '../models/rest_order_item.dart';
import '../utils/t1_string.dart';
import '../utils/utils.dart';

class LeftOrderPage2 extends StatefulWidget {
  const LeftOrderPage2({
    Key? key,
    required this.orderState,
    required this.orderingItems,
    required this.orderedItems,
    this.mapCI,
    this.restTable,
    this.cart,
    this.responses,
    this.personNum,
    this.onCartClick,
    this.onPayClick,
    this.isCarting,
    this.isPaying,
    this.restOrder,
    this.isOrderLoading,
    this.onPaymentClick,
  }) : super(key: key);

  final int? orderState;
  final List<Item>? orderingItems;
  final List<Item>? orderedItems;
  final Map<RestOrderItem, List<CustomizationItem>>? mapCI;
  final RestTable? restTable;
  final Cart? cart;
  final RestOrder? restOrder;
  final Responses? responses;
  final int? personNum;
  final Function()? onCartClick;
  final Function()? onPayClick;
  final bool? isCarting;
  final bool? isPaying;
  final bool? isOrderLoading;
  final Function()? onPaymentClick;

  @override
  State<LeftOrderPage2> createState() => _LeftOrderPage2State();
}

class _LeftOrderPage2State extends State<LeftOrderPage2>
    with TickerProviderStateMixin {
  // var scaleWidth = 0.0;
  // var scaleHeight = 0.0;
  var _width = 0.0;
  var _height = 0.0;

  // var isPortrait = false;

  var _selectedItemIdx = -1;
  var _selectedOrderItemIdx = -1;
  TabController? _tabController;

  //

  bool showProgress = false;

  @override
  void initState() {
    _tabController = TabController(
        length: 1, vsync: this, initialIndex: widget.orderState == 1 ? 1 : 0);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.cart);
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

    return DefaultTabController(
      length: 2,
      child: _content(),
    );
  }

  _content() {
    return Column(
      children: [
        SizedBox(
          height: setScaleHeight(50),
          child: TabBar(
            controller: _tabController,
            labelStyle: TextStyle(
                fontSize: isPortrait ? setFontSize(10) : setFontSize(14)),
            labelColor: const Color(0xFFeca43b),
            unselectedLabelStyle: TextStyle(
                fontSize: isPortrait ? setFontSize(10) : setFontSize(14)),
            unselectedLabelColor: const Color(0xFFa8813b),
            tabs: /*const*/ [
              //Tab(text: t1Ordering.tr()),
              Tab(text: 'Hacer pedido'),
              //Tab(text: t1Ordered.tr()),
              // Tab(text: 'Pedido'),
            ],
          ),
        ),
        Flexible(
          child: TabBarView(
            controller: _tabController,
            physics:
                const ScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            dragStartBehavior: DragStartBehavior.start,
            children: [
              _orderingTab(),
              // _orderedTab(),
            ],
          ),
        ),
      ],
    );
  }

  _orderingTab() {
    return widget.orderingItems!.isEmpty
        ? Column(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.topCenter,
                  child: Text(
                    t1NoRecords.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isPortrait ? setFontSize(8) : setFontSize(14),
                    ),
                  ),
                ),
              ),
              const Divider(color: Colors.black, height: 1),
              _unselectOrderingBottom(),
            ],
          )
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: widget.orderingItems!.length,
                  itemBuilder: (_, i) {
                    return GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: _width,
                        height: isPortrait
                            ? setScaleHeight(40)
                            : setScaleHeight(60),
                        decoration: BoxDecoration(
                          color: _selectedItemIdx == -1
                              ? Colors.white
                              : _selectedItemIdx == i
                                  ? Colors.orange[400]
                                  : Colors.white,
                          border: Border.all(
                            color: Colors.grey[700]!,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              width: isPortrait
                                  ? setScaleWidth(30)
                                  : setScaleWidth(60),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      var qty =
                                          widget.orderingItems![i].quantity;
                                      if (qty! > 1) {
                                        widget.orderingItems![i].quantity =
                                            qty - 1;
                                      } else {
                                        widget.mapCI!
                                            .remove(widget.orderingItems![i]);
                                        widget.orderingItems!.removeAt(i);
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
                                    widget.orderingItems![i].quantity
                                        .toString(),
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
                                  if (_selectedItemIdx == i) {
                                    _selectedItemIdx = -1;
                                  } else {
                                    _selectedItemIdx = i;
                                  }
                                  setState(() {});
                                },
                                child: Container(
                                  padding:
                                      EdgeInsets.all(isPortrait ? 4.0 : 8.0),
                                  child: Text(
                                    widget.orderingItems![i].itemName!,
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
                              width: isPortrait
                                  ? setScaleWidth(50)
                                  : setScaleWidth(100),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      widget.orderingItems![i].quantity =
                                          widget.orderingItems![i].quantity! +
                                              1;
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
                                    '\$${widget.orderingItems![i].itemPrice! * widget.orderingItems![i].quantity!}',
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
              ),
              const Divider(color: Colors.black, height: 1),
              _selectedItemIdx == -1
                  ? _unselectOrderingBottom()
                  : _selectOrderingBottom(),
            ],
          );
  }

  _unselectOrderingBottom() {
    double height = isPortrait && MediaQuery.of(context).size.height > 1000
        ? setScaleHeight(55)
        : setScaleHeight(60);

    return Column(
      children: [
        SizedBox(
          height: height,
          child: Stack(
            children: [
              _alignText(
                  alignment: Alignment.topLeft,
                  name: t1TotalPoints.tr() + '${widget.restTable!.name}',
                  fontSize: isPortrait ? setFontSize(6) : setFontSize(12),
                  fontWeight: FontWeight.normal),
              _alignText(
                  alignment: Alignment.bottomLeft,
                  name: 'Total:',
                  fontSize: isPortrait ? setFontSize(12) : setFontSize(18),
                  fontWeight: FontWeight.bold),
              _alignText(
                  alignment: Alignment.bottomRight,
                  name: '\$${_calculateOrderingItemPrice()}',
                  fontSize: isPortrait ? setFontSize(12) : setFontSize(18),
                  fontWeight: FontWeight.bold),
              Align(
                alignment: Alignment.topRight,
                child: Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                  size: isPortrait ? 10.0 : 20.0,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (widget.orderState == 0) {
                    if (widget.orderingItems!.isEmpty) return;
                    widget.onPayClick!();
                  }
                },
                child: Container(
                  height: isPortrait ? setScaleHeight(30) : setScaleHeight(50),
                  color: const Color(0xFFd64d38),
                  child: Center(
                    child: widget.isPaying == true
                        ? const CircularProgressIndicator()
                        : Text(
                            t1Pay.tr(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  isPortrait ? setFontSize(8) : setFontSize(14),
                            ),
                          ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (widget.orderState == 0) {
                    _onSendClick();
                  }
                },
                child: Container(
                  height: isPortrait ? setScaleHeight(30) : setScaleHeight(50),
                  color: const Color(0xFFd64d38),
                  child: Center(
                    child: widget.isCarting == true
                        ? const CircularProgressIndicator()
                        : Text(
                            t1Send.tr(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  isPortrait ? setFontSize(8) : setFontSize(14),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  _selectOrderingBottom() {
    return Column(
      children: [
        SizedBox(
          height: isPortrait ? setScaleHeight(30) : setScaleHeight(50),
          child: Row(
            children: [
              _orderedBottomFunction(
                  name: t1Clear.tr(),
                  color: const Color(0xFFe57245),
                  onTap: () {}),
              _orderedBottomFunction(
                  name: t1Quantity.tr(),
                  color: const Color(0xFFfaeb64),
                  onTap: () {}),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            if (widget.orderState == 0) {
              _onSendClick();
            }
            //Agregado codepaeza 23-04-2023
            if (widget.orderState == 1) {
              _onSendClick();
            }
            //
          },
          child: Container(
            height: isPortrait ? setScaleHeight(30) : setScaleHeight(50),
            color: const Color(0xFF914bb0),
            child: Center(
              child: Text(
                t1KitchenNote.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isPortrait ? setFontSize(8) : setFontSize(14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  ///
  /// AlignText for ordering and ordered bottom
  ///
  _alignText({
    AlignmentGeometry? alignment,
    String? name,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return Align(
      alignment: alignment!,
      child: Text(
        name!,
        style: TextStyle(
          fontSize: setFontSize(fontSize!),
          color: Colors.white,
          fontWeight: fontWeight,
        ),
      ),
    );
  }

  ///
  ///
  ///
  _orderedBottomFunction({String? name, Color? color, Function()? onTap}) {
    return Expanded(
      flex: 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          color: color,
          height: isPortrait ? setScaleHeight(30) : setScaleHeight(50),
          child: Text(
            name!,
            style: TextStyle(
              fontSize: isPortrait ? setFontSize(8) : setFontSize(14),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  _calculateOrderingItemPrice() {
    double foodTax = 0.0;
    double drinkTax = 0.0;
    double total = 0.0;
    double tax = 0.0;
    double subTotal = 0.0;
    double convinieceFee = 0.0;

    if (widget.orderingItems!.isNotEmpty) {
      for (var ele in widget.orderingItems!) {
        double itemPrice = 0.0;
        // double singleObjectPrice = 0.0;
        ele.itemPrice = ele.itemPrice! + itemPrice;
        if (ele.isFood! && widget.responses != null) {
          foodTax += (double.parse(widget.responses!.foodTax!) / 100) *
              (ele.itemPrice! * ele.quantity!);
        }
        if (ele.isCity! && widget.responses != null) {
          tax += (double.parse(widget.responses!.grandTax!) / 100) *
              (ele.itemPrice! * ele.quantity!);
        }
        if (ele.isState! && widget.responses != null) {
          drinkTax += (double.parse(widget.responses!.drinkTax!) / 100) *
              (ele.itemPrice! * ele.quantity!);
        }
        subTotal += ele.itemPrice! * ele.quantity!;
      }

      if (widget.responses?.convenienceFeeType == '2') {
        convinieceFee = ((subTotal * widget.responses!.convenienceFee!) / 100);
      } else {
        if (widget.responses?.convenienceFee != null) {
          convinieceFee = widget.responses!.convenienceFee!;
        }
      }
      subTotal = subTotal + foodTax + drinkTax + tax + convinieceFee;
      total = subTotal;
    }

    return double.parse(total.toStringAsFixed(2));
  }

  _calculateOrderedItemPrice() {
    double foodTax = 0.0;
    double drinkTax = 0.0;
    double total = 0.0;
    double tax = 0.0;
    double subTotal = 0.0;
    double convinieceFee = 0.0;

    if (widget.orderedItems!.isNotEmpty) {
      for (var ele in widget.orderedItems!) {
        double itemPrice = 0.0;
        // double singleObjectPrice = 0.0;
        ele.itemPrice = ele.itemPrice! + itemPrice;
        if (ele.isFood!) {
          foodTax += (double.parse(widget.responses!.foodTax!) / 100) *
              (ele.itemPrice! * ele.quantity!);
        }
        if (ele.isCity!) {
          tax += (double.parse(widget.responses!.grandTax!) / 100) *
              (ele.itemPrice! * ele.quantity!);
        }
        if (ele.isState!) {
          drinkTax += (double.parse(widget.responses!.drinkTax!) / 100) *
              (ele.itemPrice! * ele.quantity!);
        }
        subTotal += ele.itemPrice! * ele.quantity!;
      }
      if (widget.responses!.convenienceFeeType == '2') {
        convinieceFee = ((subTotal * widget.responses!.convenienceFee!) / 100);
      } else {
        if (widget.responses!.convenienceFee != null) {
          convinieceFee = widget.responses!.convenienceFee!;
        }
      }
      subTotal = subTotal + foodTax + drinkTax + tax + convinieceFee;
      total = subTotal;
    }

    return double.parse(total.toStringAsFixed(2));
  }

  ///
  /// _onSendClick
  ///
  _onSendClick() {
    if (widget.orderingItems!.isEmpty) return;

    widget.onCartClick!();
  }

  _orderedTab() {
    return widget.isOrderLoading == true
        ? const Center(child: CircularProgressIndicator())
        : widget.orderedItems!.isEmpty
            ? Column(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.topCenter,
                      child: Text(
                        t1NoRecords.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize:
                              isPortrait ? setFontSize(8) : setFontSize(14),
                        ),
                      ),
                    ),
                  ),
                  const Divider(color: Colors.black, height: 1),
                  _unselectedOrderedBottom(),
                ],
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: widget.orderedItems!.length,
                      itemBuilder: (_, i) {
                        return GestureDetector(
                          onTap: () {
                            if (_selectedOrderItemIdx == i) {
                              _selectedOrderItemIdx = -1;
                            } else {
                              _selectedOrderItemIdx = i;
                            }
                            setState(() {});
                          },
                          child: Container(
                            width: _width,
                            height: setScaleHeight(isPortrait ? 40 : 60),
                            decoration: BoxDecoration(
                              color: _selectedOrderItemIdx == -1
                                  ? Colors.white
                                  : _selectedOrderItemIdx == i
                                      ? Colors.orange[400]
                                      : Colors.white,
                              border: Border.all(
                                color: Colors.grey[700]!,
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  width: setScaleWidth(isPortrait ? 30 : 60),
                                  child: Text(
                                    widget.orderedItems![i].quantity!
                                        .toInt()
                                        .toString(),
                                    style: TextStyle(
                                        fontSize:
                                            setFontSize(isPortrait ? 8 : 14)),
                                  ),
                                ),
                                VerticalDivider(
                                  color: Colors.grey[700],
                                  width: 1,
                                ),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      widget.orderedItems![i].itemName!,
                                      style: TextStyle(
                                          fontSize:
                                              setFontSize(isPortrait ? 8 : 14)),
                                    ),
                                  ),
                                ),
                                VerticalDivider(
                                  color: Colors.grey[700],
                                  width: 1,
                                ),
                                Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.all(4),
                                  width: setScaleWidth(isPortrait ? 50 : 100),
                                  child: Text(
                                    '\$${widget.orderedItems![i].itemPrice! * widget.orderedItems![i].quantity!}',
                                    style: TextStyle(
                                        fontSize:
                                            setFontSize(isPortrait ? 8 : 14)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(color: Colors.black, height: 1),
                  _selectedOrderItemIdx == -1
                      ? _unselectedOrderedBottom()
                      : _selectedOrderBottom(),
                ],
              );
  }

  ///
  /// Ordered unselect bottom
  ///
  _unselectedOrderedBottom() {
    return Column(
      children: [
        SizedBox(
          height: isPortrait ? setScaleHeight(40) : setScaleHeight(60),
          child: Stack(
            children: [
              _alignText(
                alignment: Alignment.topLeft,
                name: t1TotalPoints.tr() + '${widget.restTable!.name}',
                fontSize: setFontSize(isPortrait ? 6 : 12),
                fontWeight: FontWeight.normal,
              ),
              _alignText(
                  alignment: Alignment.bottomLeft,
                  name: 'Total:',
                  fontSize: setFontSize(isPortrait ? 12 : 18),
                  fontWeight: FontWeight.bold),
              _alignText(
                  alignment: Alignment.bottomRight,
                  name: '\$${_calculateOrderedItemPrice()}',
                  fontSize: setFontSize(isPortrait ? 12 : 18),
                  fontWeight: FontWeight.bold),
              widget.restOrder == null
                  ? Container()
                  : _alignText(
                      alignment: Alignment.topCenter,
                      name:
                          t1OrderPoints.tr() + '${widget.restOrder!.orderNum}',
                      fontSize: setFontSize(isPortrait ? 6 : 12),
                      fontWeight: FontWeight.normal,
                    ),
              Align(
                alignment: Alignment.topRight,
                child: Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                  size: isPortrait ? 10 : 20,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: isPortrait ? setScaleHeight(30) : setScaleHeight(50),
          child: GestureDetector(
            onTap: () {
              //
              widget.onPaymentClick!();
              // _onPaymentClick(); //
            },
            child: Container(
              color: const Color(0xffd64d38),
              child: Center(
                child: Text(
                  t1Payment.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isPortrait ? setFontSize(8) : setFontSize(14),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  ///
  /// Ordered select bottom
  ///
  _selectedOrderBottom() {
    return SizedBox(
      height: setScaleHeight(isPortrait ? 90 : 150),
      child: Column(
        children: [
          Row(
            children: [
              _orderedBottomFunction(
                  name: t1Void.tr(),
                  color: const Color(0xFFfaeb64),
                  onTap: () {}),
              _orderedBottomFunction(
                  name: t1OneMore.tr(),
                  color: const Color(0xFF6d54b6),
                  onTap: () {}),
            ],
          ),
          Row(
            children: [
              _orderedBottomFunction(
                  name: t1Mark.tr(),
                  color: const Color(0xFFd2da5f),
                  onTap: () {}),
              _orderedBottomFunction(
                  name: t1Transfer.tr(),
                  color: const Color(0xFF914bb0),
                  onTap: () {}),
            ],
          ),
          Row(
            children: [
              _orderedBottomFunction(
                  name: t1Discount.tr(),
                  color: const Color(0xFF77b068),
                  onTap: () {}),
              _orderedBottomFunction(
                  name: t1Price.tr(),
                  color: const Color(0xFF4a8ceb),
                  onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }
}
