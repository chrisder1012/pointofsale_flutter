import 'package:flutter/material.dart';
import 'package:zabor/models/rest_order.dart';
import 'package:easy_localization/easy_localization.dart';

import '../models/rest_order_item.dart';
import '../utils/t1_string.dart';
import '../utils/utils.dart';

class LeftSummaryPage extends StatefulWidget {
  const LeftSummaryPage({
    Key? key,
    required this.restOrder,
    required this.restOrderItems,
  }) : super(key: key);

  final RestOrder? restOrder;
  final List<RestOrderItem>? restOrderItems;

  @override
  State<LeftSummaryPage> createState() => _LeftSummaryPageState();
}

class _LeftSummaryPageState extends State<LeftSummaryPage> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      width: width * 4 / 10 - 1,
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
                      t1TableInSummaryPage.tr() +
                          '${widget.restOrder?.tableName}, ${widget.restOrder?.personNum} ' +
                          t1GuestsInSummaryPage.tr(),
                      style: TextStyle(
                        fontSize: setFontSize(isPortrait ? 10 : 16),
                      ),
                    ),
                    // Text(
                    //   //'Invoice: ${widget.restOrder?.invoiceNum}',
                    //   t1InvoiceInSummaryPage.tr() +
                    //       '${widget.restOrder?.cartId}',
                    //   style: TextStyle(
                    //     fontSize: setFontSize(isPortrait ? 10 : 16),
                    //   ),
                    // ),
                    Text(
                      //'Time: ${widget.restOrder?.orderTime}',
                      t1TimeInSummaryPage.tr() +
                          '${widget.restOrder?.orderTime}',
                      style: TextStyle(
                        fontSize: setFontSize(isPortrait ? 10 : 16),
                      ),
                    ),
                    widget.restOrderItems!.isEmpty
                        ? Container()
                        : const Divider(height: 1, color: Colors.grey),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.restOrderItems!.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            Text(
                              ' ${widget.restOrderItems![index].quantity}  ${widget.restOrderItems![index].itemName}',
                              style: TextStyle(
                                fontSize: setFontSize(isPortrait ? 10 : 16),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '\$ ${widget.restOrderItems![index].price}',
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
                            //'Qty: ${_calculateTotalQty(widget.restOrderItems!)}',
                            t1QtyInSummaryPage.tr() +
                                '${_calculateTotalQty(widget.restOrderItems!)}',
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
                                        //'$t1Subtotal:',
                                        t1SubtotalPoints.tr(),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize:
                                              setFontSize(isPortrait ? 10 : 16),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '\$${_calculateSubTotal(widget.restOrderItems!)}',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize:
                                              setFontSize(isPortrait ? 10 : 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Row(
                                //   children: [
                                //     Expanded(
                                //       child: Text(
                                //         '$t1StateRate:',
                                //         textAlign: TextAlign.right,
                                //         style: TextStyle(
                                //           fontSize:
                                //               setFontSize(isPortrait ? 10 : 16),
                                //         ),
                                //       ),
                                //     ),
                                //     Expanded(
                                //       child: Text(
                                //         '\$${(widget.restOrder!.amount! - _calculateSubTotal(widget.restOrderItems!)).toStringAsFixed(2)}',
                                //         textAlign: TextAlign.right,
                                //         style: TextStyle(
                                //           fontSize:
                                //               setFontSize(isPortrait ? 10 : 16),
                                //         ),
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                // Food Tax
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        //'$t1FoodTax:',
                                        t1FoodTaxPoints.tr(),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize:
                                              setFontSize(isPortrait ? 10 : 16),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '\$${widget.restOrder!.foodTax!.toStringAsFixed(2)}',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize:
                                              setFontSize(isPortrait ? 10 : 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Drink Tax
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        //'$t1DrinkTax:',
                                        t1DrinkTaxPoints.tr(),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize:
                                              setFontSize(isPortrait ? 10 : 16),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '\$${widget.restOrder!.drinkTax!.toStringAsFixed(2)}',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize:
                                              setFontSize(isPortrait ? 10 : 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // City Tax
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        //'$t1CityTax:',
                                        t1CityTaxPoints.tr(),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize:
                                              setFontSize(isPortrait ? 10 : 16),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '\$${widget.restOrder!.tax!.toStringAsFixed(2)}',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize:
                                              setFontSize(isPortrait ? 10 : 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Convenience Fee
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        //'$t1ConvenienceFee:',
                                        t1ConvenienceFeePoints.tr(),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize:
                                              setFontSize(isPortrait ? 10 : 16),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '\$${widget.restOrder!.convienenceFee!.toStringAsFixed(2)}',
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
                                        //'$t1Total:',
                                        t1TotalPoints.tr(),
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
                                        '\$${widget.restOrder!.amount}',
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
        ],
      ),
    );
  }

  _calculateTotalQty(List<RestOrderItem> rois) {
    var qty = 0;
    for (var element in rois) {
      qty += element.quantity!;
    }
    return qty;
  }

  _calculateSubTotal(List<RestOrderItem> rois) {
    var subtotal = 0.0;
    for (var element in rois) {
      subtotal += element.price! * element.quantity!;
    }
    return subtotal;
  }
}
