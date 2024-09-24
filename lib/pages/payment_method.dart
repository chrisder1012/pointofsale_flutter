import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:stripe_terminal/stripe_terminal.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:zabor/api/my_api.dart';
import 'package:zabor/models/terminal_location.dart';
import 'package:zabor/utils/t1_string.dart';

import '../config/config.dart';
import '../utils/utils.dart';

class PaymentConfigPage extends StatefulWidget {
  const PaymentConfigPage({Key? key}) : super(key: key);

  @override
  State<PaymentConfigPage> createState() => _PaymentConfigPageState();
}

class _PaymentConfigPageState extends State<PaymentConfigPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // DiscoveryMethod? selectedReaderType;
  String? terminalLocation;
  bool? canAcceptCash;
  List<TerminalLocation> locations = [];

  // var isPortrait = false;

  // var scaleWidth = 0.0;
  // var scaleHeight = 0.0;

  var _width = 0.0;
  var _height = 0.0;

  _getConfigurations() async {
    // selectedReaderType = await Config.getReaderType();
    terminalLocation = await Config.getTerminalLocation();
    canAcceptCash = await Config.getBool('canAcceptCash');
    setState(() {});
  }

  _getTerminalLocations() async {
    var resp = await CallApi('https://api.zaboreats.com/pmt/')
        .getDataWithToken("locations-list");
    setState(() {
      locations = (resp.data!["data"])
          .map<TerminalLocation>((t) => TerminalLocation.fromJson(t))
          .toList();
    });
  }

  bool get isReady {
    return /*selectedReaderType != null &&*/
        terminalLocation != null && canAcceptCash != null;
  }

  @override
  void initState() {
    _getConfigurations();
    _getTerminalLocations();
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
                "Payment Method Configuration",
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
                        t1Name.tr(),
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
                        t1Ip.tr(),
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
                        "Terminal Type",
                        style: TextStyle(
                          fontSize: setFontSize(14),
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(thickness: 1, color: Colors.grey),
                  // Expanded(
                  //   child: DropdownButtonFormField<DiscoveryMethod>(
                  //     items:
                  //         [DiscoveryMethod.internet, DiscoveryMethod.bluetooth]
                  //             .map(
                  //               (e) => DropdownMenuItem(
                  //                 value: e,
                  //                 child: Text(describeEnum(e).toUpperCase()),
                  //               ),
                  //             )
                  //             .toList(),
                  //     value: selectedReaderType,
                  //     decoration: const InputDecoration(
                  //         focusedBorder: UnderlineInputBorder(
                  //           borderSide:
                  //               BorderSide(color: Colors.blue, width: 2.0),
                  //         ),
                  //         hintText: "Selete Terminal Type"),
                  //     onChanged: (v) {
                  //       setState(() {
                  //         if (v != null) selectedReaderType = v;
                  //       });
                  //     },
                  //   ),
                  // ),
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
                        "Terminal Location",
                        style: TextStyle(
                          fontSize: setFontSize(14),
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(thickness: 1, color: Colors.grey),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      items: locations
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.id,
                              child: Text(e.displayName),
                            ),
                          )
                          .toList(),
                      value: terminalLocation,
                      onChanged: (v) {
                        setState(() {
                          if (v != null) terminalLocation = v;
                        });
                      },
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0),
                        ),
                        hintText: "Selete Terminal Location",
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
                        "Enable Cash Payment",
                        style: TextStyle(
                          fontSize: setFontSize(14),
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(thickness: 1, color: Colors.grey),
                  Checkbox(
                    value: canAcceptCash ?? false,
                    onChanged: (bool? value) {
                      setState(() {
                        canAcceptCash = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  _saveButton() {
    return GestureDetector(
      onTap: () async {
        if (isReady) {
          // Config.setReaderType(selectedReaderType!);
          Config.setTerminalLocation(terminalLocation!);
          await Config.setBool('canAcceptCash', canAcceptCash!);
          await showSavedAlert();
          Navigator.pop(context, true);
        }
      },
      child: Container(
        height: setScaleHeight(50),
        color: isReady ? Colors.green : Colors.grey,
        child: Center(
          child: Text(
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

  Future<void> showSavedAlert() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Payment method settings saved successfully'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            )
          ],
        );
      },
    );
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
}
