import 'package:flutter/material.dart';
import 'package:zabor/models/item.dart';
import 'package:easy_localization/easy_localization.dart';

import '../config/config.dart';
import '../models/customization_item.dart';
import '../models/rest_order_item.dart';
import '../models/restaurant.dart';
import '../utils/t1_string.dart';
import '../utils/utils.dart';

class TakeoutContent extends StatefulWidget {
  TakeoutContent({
    Key? key,
    this.orderState,
    this.orderingItems,
    this.mapCI,
    this.responses,
    this.isOrdering,
    this.onPaymentClick,
    this.onScan1,
    this.onScan2,
    this.isTag = false,
    this.onSendTagClick,
  }) : super(key: key);

  final int? orderState;
  final List<Item>? orderingItems;
  final Map<RestOrderItem, List<CustomizationItem>>? mapCI;
  final Responses? responses;
  final bool? isOrdering;
  final Function()? onPaymentClick;
  final Function(int upc)? onScan1;
  final Function(int upc)? onScan2;
  final bool? isTag;
  final Function()? onSendTagClick;

  @override
  State<TakeoutContent> createState() => _TakeoutContentState();
}

class _TakeoutContentState extends State<TakeoutContent> {
  double _width = 0.0;
  double _height = 0.0;
  int _selectedItemIdx = -1;

  TextEditingController _upcController1 = TextEditingController();
  TextEditingController _upcController2 = TextEditingController();

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

    return widget.orderingItems!.isEmpty
        ? Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: TextField(
                        controller: _upcController1,
                        keyboardType: TextInputType.number,
                        onSubmitted: (value) {
                          if (_upcController1.text.isNotEmpty) {
                            widget.onScan1!(int.parse(_upcController1.text));
                            _upcController1.clear();
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter UPC No',
                          hintStyle:
                              TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_upcController1.text.isNotEmpty) {
                        widget.onScan1!(int.parse(_upcController1.text));
                        _upcController1.clear();
                      }
                    },
                    child: Container(
                      color: Config().appColor,
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      child: Center(
                        child: Text(
                          'Scan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize:
                                isPortrait ? setFontSize(8) : setFontSize(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: TextField(
                        controller: _upcController2,
                        keyboardType: TextInputType.number,
                        onSubmitted: (value) {
                          if (_upcController2.text.isNotEmpty) {
                            widget.onScan2!(int.parse(_upcController2.text));
                            _upcController2.clear();
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter UPC No',
                          hintStyle:
                              TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_upcController2.text.isNotEmpty) {
                        widget.onScan2!(int.parse(_upcController2.text));
                        _upcController2.clear();
                      }
                    },
                    child: Container(
                      color: Config().appColor,
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      child: Center(
                        child: Text(
                          'Scan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize:
                                isPortrait ? setFontSize(8) : setFontSize(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
                                      color: Colors.green,
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
                                          : setFontSize(14),
                                      fontWeight: FontWeight.w500,
                                    ),
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
                                          : setFontSize(14),
                                      fontWeight: FontWeight.w500,
                                    ),
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
                                      color: Colors.green,
                                      size: isPortrait ? 12 : 25,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '\$${widget.orderingItems![i].itemPrice! * widget.orderingItems![i].quantity!}',
                                    style: TextStyle(
                                      fontSize: isPortrait
                                          ? setFontSize(8)
                                          : setFontSize(14),
                                      fontWeight: FontWeight.w500,
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
              ),
              const Divider(color: Colors.black, height: 1),
              _selectedItemIdx == -1
                  ? _unselectOrderingBottom()
                  : _selectOrderingBottom(),
              // _preOrderingBottomBar(),
              // _orderingBottom(),
            ],
          );
  }

  _unselectOrderingBottom() {
    return Column(
      children: [
        SizedBox(
          height: isPortrait ? setScaleHeight(40) : setScaleHeight(60),
          child: Stack(
            children: [
              _alignText(
                  alignment: Alignment.topLeft,
                  name: t1TakeOut.tr(),
                  fontSize: isPortrait ? setFontSize(6) : setFontSize(12),
                  fontWeight: FontWeight.normal),
              _alignText(
                  alignment: Alignment.bottomLeft,
                  name: 'Total:',
                  fontSize: isPortrait ? setFontSize(12) : setFontSize(16),
                  fontWeight: FontWeight.bold),
              _alignText(
                  alignment: Alignment.bottomRight,
                  name: '\$${_calculateOrderingItemPrice()}',
                  fontSize: isPortrait ? setFontSize(12) : setFontSize(16),
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
          children: [
            Expanded(
              child: GestureDetector(
                onTap: widget.isOrdering == true
                    ? null
                    : () {
                        if (widget.orderState == 2) {
                          // _onSendClick();
                          widget.onPaymentClick!();
                        }
                      },
                child: Container(
                  height: isPortrait ? setScaleHeight(30) : setScaleHeight(45),
                  color: Config().appColor,
                  child: Center(
                    child: widget.isOrdering == true
                        ? const CircularProgressIndicator()
                        : Text(
                            t1Payment.tr(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  isPortrait ? setFontSize(8) : setFontSize(16),
                            ),
                          ),
                  ),
                ),
              ),
            ),
            if (widget.isTag == true) const SizedBox(width: 2),
            if (widget.isTag == true)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    widget.onSendTagClick!();
                  },
                  child: Container(
                    height:
                        isPortrait ? setScaleHeight(30) : setScaleHeight(45),
                    color: Config().appColor,
                    child: Center(
                      child: Text(
                        t1Send.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize:
                              isPortrait ? setFontSize(8) : setFontSize(16),
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
              // _onSendClick();
            }
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
}
