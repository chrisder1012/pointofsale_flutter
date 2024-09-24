import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:zabor/blocs/printer_bloc.dart';

import 'package:zabor/utils/t1_string.dart';

import '../config/config.dart';
import '../services/services.dart';
import '../utils/snacbar.dart';
import '../utils/utils.dart';

class PrintRegisterPage extends StatefulWidget {
  const PrintRegisterPage({Key? key}) : super(key: key);

  @override
  State<PrintRegisterPage> createState() => _PrintRegisterPageState();
}

class _PrintRegisterPageState extends State<PrintRegisterPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _ctrlCash = TextEditingController();
  final TextEditingController _ctrlKitchen1 = TextEditingController();
  final TextEditingController _ctrlKitchen2 = TextEditingController();
  final TextEditingController _ctrlKitchen3 = TextEditingController();
  final TextEditingController _ctrlKitchen4 = TextEditingController();
  // final TextEditingController _ctrlBluetooth = TextEditingController();

  final TextEditingController _ctrlAdmin = TextEditingController();

  // var isPortrait = false;

  // var scaleWidth = 0.0;
  // var scaleHeight = 0.0;

  var _width = 0.0;
  var _height = 0.0;

  bool _isLoading = false;

  _getPrinterIPs() async {
    var ips = await Config.getPrinters();
    if (ips != null) {
      setState(() {
        _ctrlCash.text = ips[0];
        _ctrlKitchen1.text = ips[1];
        _ctrlKitchen2.text = ips[2];
        _ctrlKitchen3.text = ips[3];
        _ctrlKitchen4.text = ips[4];
        _ctrlAdmin.text = ips[5];
        // _ctrlBluetooth.text = ips[3];
      });
    }
  }

  @override
  void initState() {
    _getPrinterIPs();

    super.initState();
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
      backgroundColor: Colors.white,
      body: _body(),
    );
  }

  _body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _topBar(),
        _content(),
        const Spacer(),
        _saveButton(),
      ],
    );
  }

  _topBar() {
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
                onPressed: () {
                  Navigator.pop(context, false);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: setScaleWidth(16)),
              color: const Color(0xFFe57245),
              child: Text(
                t1PrintRegister.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: setFontSize(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _content() {
    return SingleChildScrollView(
      physics: const ScrollPhysics(),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            IntrinsicHeight(
              child: Row(
                children: [
                  SizedBox(
                    width: _width / 3,
                    child: Center(
                      child: Text(
                        t1Name,
                        style: TextStyle(
                          fontSize: setFontSize(16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(thickness: 1, color: Colors.grey),
                  Expanded(
                    child: Center(
                      child: Text(
                        t1Ip,
                        style: TextStyle(
                          fontSize: setFontSize(16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1, color: Colors.grey),
            IntrinsicHeight(
              child: Row(
                children: [
                  SizedBox(
                    width: _width / 3,
                    child: Center(
                      child: Text(
                        '1. ${t1CashierPrinter.tr()}',
                        style: TextStyle(
                          fontSize: setFontSize(14),
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(thickness: 1, color: Colors.grey),
                  Expanded(
                    child: TextFormField(
                      controller: _ctrlCash,
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1, color: Colors.grey),
            IntrinsicHeight(
              child: Row(
                children: [
                  SizedBox(
                    width: _width / 3,
                    child: Center(
                      child: Text(
                        '2. ${t1KitchenPrinter.tr()}',
                        style: TextStyle(
                          fontSize: setFontSize(14),
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(thickness: 1, color: Colors.grey),
                  Expanded(
                    child: TextFormField(
                      controller: _ctrlKitchen1,
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1, color: Colors.grey),
            IntrinsicHeight(
              child: Row(
                children: [
                  SizedBox(
                    width: _width / 3,
                    child: Center(
                      child: Text(
                        '3. ${t1KitchenPrinter.tr()}',
                        style: TextStyle(
                          fontSize: setFontSize(14),
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(thickness: 1, color: Colors.grey),
                  Expanded(
                    child: TextFormField(
                      controller: _ctrlKitchen2,
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1, color: Colors.grey),
            IntrinsicHeight(
              child: Row(
                children: [
                  SizedBox(
                    width: _width / 3,
                    child: Center(
                      child: Text(
                        '4. ${t1KitchenPrinter.tr()}',
                        style: TextStyle(
                          fontSize: setFontSize(14),
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(thickness: 1, color: Colors.grey),
                  Expanded(
                    child: TextFormField(
                      controller: _ctrlKitchen3,
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1, color: Colors.grey),
            IntrinsicHeight(
              child: Row(
                children: [
                  SizedBox(
                    width: _width / 3,
                    child: Center(
                      child: Text(
                        '5. ${t1KitchenPrinter.tr()}',
                        style: TextStyle(
                          fontSize: setFontSize(14),
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(thickness: 1, color: Colors.grey),
                  Expanded(
                    child: TextFormField(
                      controller: _ctrlKitchen4,
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1, color: Colors.grey),
            IntrinsicHeight(
              child: Row(
                children: [
                  SizedBox(
                    width: _width / 3,
                    child: Center(
                      child: Text(
                        '6. ${t1AdminPrinter.tr()}',
                        style: TextStyle(
                          fontSize: setFontSize(14),
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(thickness: 1, color: Colors.grey),
                  Expanded(
                    child: TextFormField(
                      controller: _ctrlAdmin,
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1, color: Colors.grey),
            // IntrinsicHeight(
            //   child: Row(
            //     children: [
            //       SizedBox(
            //         width: _width / 3,
            //         child: Center(
            //           child: Text(
            //             "Bluetooth Printer",
            //             style: TextStyle(
            //               fontSize: setFontSize(14),
            //             ),
            //           ),
            //         ),
            //       ),
            //       const VerticalDivider(thickness: 1, color: Colors.grey),
            //       Expanded(
            //         child: TextFormField(
            //           controller: _ctrlBluetooth,
            //           decoration: const InputDecoration(
            //             // hintText: "Printer Name",
            //             focusedBorder: UnderlineInputBorder(
            //               borderSide:
            //                   BorderSide(color: Colors.blue, width: 2.0),
            //             ),
            //           ),
            //           keyboardType: TextInputType.number,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // const Divider(thickness: 1, color: Colors.grey),

            // Row(
            //   children: [
            //     Checkbox(value: addCash, onChanged: _onRememberMeChanged),
            //     Text(
            //       t1AcceptCash,
            //       style: TextStyle(fontSize: setFontSize(14)),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

  _saveButton() {
    return GestureDetector(
      onTap: () async {
        if (!_isLoading) {
          if (_ctrlCash.text == "" &&
              _ctrlKitchen1.text == "" &&
              _ctrlKitchen2.text == "" &&
              _ctrlKitchen3.text == "" &&
              _ctrlKitchen4.text == "" &&
              _ctrlAdmin.text == "") return;
          // List<String> result = [
          //   _ctrlCash.text,
          //   _ctrlKitchen1.text,
          //   _ctrlKitchen2.text,
          //   _ctrlKitchen3.text,
          //   _ctrlKitchen4.text,
          //   _ctrlAdmin.text,
          //   // _ctrlBluetooth.text
          // ];
          _handleSavePrinter(
            Config.restaurantId!,
            'printer_2_name',
            _ctrlCash.text.isEmpty ? '0.0.0.0' : _ctrlCash.text,
            'printer_3_name',
            _ctrlKitchen1.text.isEmpty ? '0.0.0.0' : _ctrlKitchen1.text,
            'printer_4_name',
            _ctrlKitchen2.text.isEmpty ? '0.0.0.0' : _ctrlKitchen2.text,
            'printer_5_name',
            _ctrlKitchen3.text.isEmpty ? '0.0.0.0' : _ctrlKitchen3.text,
            'printer_6_name',
            _ctrlKitchen4.text.isEmpty ? '0.0.0.0' : _ctrlKitchen4.text,
            'printer_7_name',
            _ctrlAdmin.text.isEmpty ? '0.0.0.0' : _ctrlAdmin.text,
          );

          // await showPrintAlert();
        }
      },
      child: Container(
        height: setScaleHeight(50),
        color: Colors.green,
        child: Center(
          child: _isLoading
              ? CircularProgressIndicator()
              : Text(
                  t1Save,
                  style: TextStyle(
                    fontSize: setFontSize(16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> showPrintAlert() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Printer was registered successfully'),
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

  bool addCash = false;
  void _onRememberMeChanged(bool? newValue) => setState(() {
        addCash = newValue!;

        if (addCash) {
          SharedPreferences.getInstance()
              .then((value) => value.setBool('cash_enable', true));
        } else {
          SharedPreferences.getInstance()
              .then((value) => value.setBool('cash_enable', false));
        }
      });

  getCashEnableOrFalse() {
    SharedPreferences.getInstance().then((value) => setState(() {
          addCash = value.getBool('cash_enable') ?? false;
        }));
  }

  // Handle to save printers
  Future<void> _handleSavePrinter(
      int resId,
      String printname2,
      String printip2,
      String printname3,
      String printip3,
      String printname4,
      String printip4,
      String printname5,
      String printip5,
      String printname6,
      String printip6,
      String printname7,
      String printip7) async {
    final PrinterBloc pb = Provider.of<PrinterBloc>(context, listen: false);

    await AppService().checkInternet().then((hasInternet) async {
      if (hasInternet == false) {
        openSnacbar(context, 'no internet');
      } else {
        setState(() {
          _isLoading = true;
        });
        pb
            .savePrinters(
                resId,
                printname2,
                printip2,
                printname3,
                printip3,
                printname4,
                printip4,
                printname5,
                printip5,
                printname6,
                printip6,
                printname7,
                printip7)
            .then((_) async {
          if (pb.hasError == false) {
            openSnacbar(context, pb.msg);

            Config.setPrinters(
                [printip2, printip3, printip4, printip5, printip6, printip7]);
          } else {
            openSnacbar(context, pb.errorCode);
          }
          setState(() {
            _isLoading = false;
          });
        });
      }
    });
  }
}
