import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zabor/utils/utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zabor/utils/t1_string.dart';

import '../blocs/close_order_bloc.dart';
// import '../utils/utils.dart';
import '../api/my_api.dart';

class Calculator extends StatefulWidget {
  final double total;
  final String orderNo;
  final int userId;
  final bool forKioskOrder;
  //bool forTableOrder;

  Calculator({
    Key? key,
    required this.total,
    required this.orderNo,
    required this.userId,
    required this.forKioskOrder,
    //required this.forTableOrder,
  }) : super(key: key);

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  var userInput = '';
  var answer = '';

// Array of button
  final List<double> buttons = [
    //Lista modificada por codepaeza 08-04-2023
    5,
    10,
    20,
    50,
    100,
  ];

  // var _isLoaded = false;
  // var _loadingPlaceOrderState = false;
  // var _orderPlaced = false;
  // final _isPrint = false;
  late TextEditingController textEditingController;
  late CloseOrderBloc cob;

  @override
  void initState() {
    // TODO: implement initState
    buttons.insert(0, widget.total);
    textEditingController =
        TextEditingController(text: widget.total.toString());
    cob = Provider.of<CloseOrderBloc>(context, listen: false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: const Text("Cash Tendered"),
        title: Text(t1CashTendered.tr()),
        centerTitle: true,
      ), //AppBar
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          //Bloque Movido por codepaeza 08-04-2023
          Expanded(
            child: GridView.builder(
                itemCount: buttons.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isPortrait ? 6 : 8,
                  //Adicionado codepaeza 17-04-2023
                  childAspectRatio: 3 / 3,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      textEditingController.text = buttons[index].toString();
                      setState(() {});
                    },
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.amber,
                          border: Border.all(
                            color: Colors.amber,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      margin: EdgeInsets.all(4),
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Text(
                          "\$" + buttons[index].toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              autofocus: true,
              //autofocus: false, modificado por codepaeza 08-04-2023
              controller: textEditingController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                //hintText: "Enter cash tendered",
                hintText: t1EnterCashValue.tr(),
                // labelText: "Quantity",
                labelText: t1Quantity.tr(),
                border: OutlineInputBorder(),
              ),

              onSubmitted: ((value) {
                setState(() {
                  textEditingController.text = value;
                });
              }),
            ),
          ),

          // ListTile(
          //   leading: Icon(Icons.numbers),
          //   title: Text(
          //     widget.forKioskOrder ? t1OrdenNumber.tr() : t1Invoice.tr(),
          //     style: TextStyle(
          //       fontSize: setFontSize(isPortrait ? 10 : 20),
          //     ),
          //   ),
          //   subtitle: Text(
          //     widget.orderNo,
          //     style: TextStyle(
          //       fontSize: setFontSize(isPortrait ? 10 : 20),
          //     ),
          //   ),
          // ),
          ListTile(
            leading: Icon(Icons.monetization_on_outlined),
            title: Text(
              t1Total.tr(),
              style: TextStyle(
                fontSize: setFontSize(isPortrait ? 10 : 20),
              ),
            ),
            subtitle: Text(
              "\$" + widget.total.toString(),
              style: TextStyle(
                fontSize: setFontSize(isPortrait ? 10 : 20),
              ),
            ),
          ),
          if (textEditingController.text != "")
            ListTile(
              leading: Icon(Icons.money),
              title: Text(
                t1CashTendered.tr(),
                style: TextStyle(
                  fontSize: setFontSize(isPortrait ? 10 : 20),
                ),
              ),
              subtitle: Text(
                textEditingController.text,
                style: TextStyle(
                  fontSize: setFontSize(isPortrait ? 10 : 20),
                ),
              ),
            ),
          Divider(),
          if (textEditingController.text != "")
            ListTile(
              leading: Icon(Icons.currency_exchange_outlined),
              title: Text(
                t1Change.tr(),
                style: TextStyle(
                  fontSize: setFontSize(isPortrait ? 10 : 20),
                ),
              ),
              subtitle: Text(
                (double.parse(textEditingController.text) - widget.total)
                    .toStringAsFixed(2),
                style: TextStyle(
                  fontSize: setFontSize(isPortrait ? 10 : 20),
                ),
              ),
            ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.blue,
                      ),
                    ),
                    onPressed: () async {
                      if (widget.forKioskOrder) {
                        dynamic data = {
                          "orderstatus": 'received',
                          "payment_status": 1,
                          "orderId": widget.orderNo,
                          "issue": ''
                        };
                        print(data);
                        try {
                          await CallApi()
                              .postGetDataWithTokenAndClientPlatformHeader(
                                  data, "user/changeorderstatus", 'KIOSK');

                          cob.getDataFromKiosk();
                        } catch (e) {
                          print(e.toString());
                        }
                        await showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              // Future.delayed(Duration(seconds: 60), () {
                              //   Navigator.of(context).pop(true);
                              // });
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(32.0))),
                                backgroundColor: Colors.amber,
                                contentPadding: EdgeInsets.all(16),
                                //elevation: 10,
                                elevation: 20,
                                title: Text(
                                  t1ChangeNotif.tr(),
                                  style: TextStyle(
                                    fontSize: setFontSize(isPortrait ? 40 : 60),
                                  ),
                                ),
                                content: Text(
                                  "\$ " +
                                      (double.parse(
                                                  textEditingController.text) -
                                              widget.total)
                                          .toStringAsFixed(2),
                                  style: TextStyle(
                                    fontSize: setFontSize(isPortrait ? 60 : 80),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      t1Close.tr(),
                                      style: TextStyle(
                                        fontSize:
                                            setFontSize(isPortrait ? 20 : 40),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            });
                        Navigator.pop(context);
                      } else {
                        await showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              // _loadingPlaceOrderState = true;
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(32.0))),
                                backgroundColor: Colors.amber,
                                contentPadding: EdgeInsets.all(16),
                                elevation: 10,
                                title: Text(
                                  t1ChangeNotif.tr(),
                                  style: TextStyle(
                                    fontSize: setFontSize(isPortrait ? 40 : 60),
                                    color: Colors.black,
                                  ),
                                ),
                                content: Text(
                                  "\$ " +
                                      (double.parse(
                                                  textEditingController.text) -
                                              widget.total)
                                          .toStringAsFixed(2),
                                  style: TextStyle(
                                    fontSize: setFontSize(isPortrait ? 60 : 80),
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      print(
                                          'Envío orden para abir Summary Page - calculator_screen');
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      t1Close.tr(),
                                      style: TextStyle(
                                        fontSize:
                                            setFontSize(isPortrait ? 20 : 40),
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            });
                        Navigator.pop(context, true);
                        print('Primer cambio de pantalla - calculator_screen');
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        t1Confirm.tr(),
                        style: TextStyle(
                            //fontSize: setFontSize(isPortrait ? 10 : 20),
                            fontSize: setFontSize(isPortrait ? 35 : 70),
                            color: Colors.white),
                      ),
                    )),
              ) /*)*/,
              Expanded(
                child: OutlinedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      //Colors.amber,
                      //Modified codepaeza 17-04-23
                      Colors.orange,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      t1Cancel.tr(),
                      style: TextStyle(
                          //fontSize: setFontSize(isPortrait ? 10 : 20),
                          //Modificado codepaeza 17-04-2023
                          fontSize: setFontSize(isPortrait ? 35 : 70),
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  bool isOperator(String x) {
    if (x == '/' || x == 'x' || x == '-' || x == '+' || x == '=') {
      return true;
    }
    return false;
  }

// function to calculate the input operation
  void equalPressed() {
    // String finaluserinput = userInput;
    // finaluserinput = userInput.replaceAll('x', '*');

    // Parser p = Parser();
    // Expression exp = p.parse(finaluserinput);
    // ContextModel cm = ContextModel();
    // double eval = exp.evaluate(EvaluationType.REAL, cm);
    // answer = eval.toString();
  }
}

// creating Stateless Widget for buttons
