import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:zabor/utils/t1_string.dart';

import '../config/config.dart';
import '../utils/utils.dart';

class DeliveryPage extends StatefulWidget {
  const DeliveryPage({Key? key}) : super(key: key);

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // var isPortrait = false;

  // var scaleWidth = 0.0;
  // var scaleHeight = 0.0;

  var _width = 0.0;
  var _height = 0.0;

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
      appBar: AppBar(
        backgroundColor: Config().appColor,
        leading:
            IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back)),
        title: /*const*/ Text(t1Delivery.tr()),
      ),
      body: _body(),
    );
  }

  _body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _content(),
        // _saveButton(),
      ],
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
                        t1CashierPrinter.tr(),
                        style: TextStyle(
                          fontSize: setFontSize(14),
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(thickness: 1, color: Colors.grey),
                  Expanded(
                    child: TextFormField(
                      // controller: _ctrlCash,
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0),
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
                        t1KitchenPrinter.tr(),
                        style: TextStyle(
                          fontSize: setFontSize(14),
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(thickness: 1, color: Colors.grey),
                  Expanded(
                    child: TextFormField(
                      // controller: _ctrlKitchen,
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0),
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
                        t1AdminPrinter.tr(),
                        style: TextStyle(
                          fontSize: setFontSize(14),
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(thickness: 1, color: Colors.grey),
                  Expanded(
                    child: TextFormField(
                      // controller: _ctrlAdmin,
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 2.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1, color: Colors.grey),
            Row(
              children: [
                // Checkbox(value: addCash, onChanged: _onRememberMeChanged),
                Text(
                  t1AcceptCash.tr(),
                  style: TextStyle(fontSize: setFontSize(14)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
