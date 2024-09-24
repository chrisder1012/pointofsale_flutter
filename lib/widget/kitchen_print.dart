import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../blocs/add_to_cart_bloc.dart';
import '../models/cart.dart';

class KitchenPrint extends StatelessWidget {
  final Cart printData;
  final GlobalKey globalKitchenKey;
  final String? orderNo;
  final AddToCartBloc? addToCartBloc;
  const KitchenPrint(
      {Key? key,
      required this.printData,
      required this.globalKitchenKey,
      required this.orderNo,
      required this.addToCartBloc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    style: TextStyle(fontSize: 70, fontWeight: FontWeight.w600))
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
                        style: TextStyle(fontSize: 40)),
                    Text("Kiosk", style: TextStyle(fontSize: 40)),
                    Text("${DateFormat("hh:mm:ss a").format(DateTime.now())}",
                        style: TextStyle(fontSize: 40)),
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
                                          style: TextStyle(fontSize: 50)),
                                      Text(value.itemName!,
                                          style: TextStyle(fontSize: 50))
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
                                                          fontSize: 44)),
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

              Padding(
                padding: EdgeInsets.symmetric(vertical: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Order type: ", style: TextStyle(fontSize: 40)),
                    SizedBox(width: 20),
                    Text('Dine in', style: TextStyle(fontSize: 40)),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                child: Text(
                  "Order #: ${orderNo == null ? '#' : orderNo}",
                  style: TextStyle(fontSize: 60),
                ),
              ),
              if (addToCartBloc?.isDineIn ?? false)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Tags :${addToCartBloc!.tags}",
                          style: TextStyle(fontSize: 40)),
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
