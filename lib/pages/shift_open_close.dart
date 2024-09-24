// import 'dart:convert';

// import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zabor/config/config.dart';
import 'package:zabor/utils/utils.dart';

import '../api/my_api.dart';
import '../blocs/homepage_restaurant_bloc.dart';
import '../db/database_handler.dart';

class ShiftOpenClose extends StatefulWidget {
  final bool isOpen;
  final int restId;
  final int cashierId;
  const ShiftOpenClose(
      {Key? key,
      required this.isOpen,
      required this.restId,
      required this.cashierId})
      : super(key: key);

  @override
  State<ShiftOpenClose> createState() => _ShiftOpenCloseState();
}

class _ShiftOpenCloseState extends State<ShiftOpenClose> {
  late TextEditingController controller;
  bool isForOpen = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    isForOpen = widget.isOpen;
    controller.addListener(() {
      setState(() {});
    });
  }

  _openShift() async {
    try {
      setState(() {
        isLoading = true;
      });
      final date = DateTime.now();
      final String dateFormat = DateFormat('yyyy-MM-dd hh:mm:ss').format(date);
      print(dateFormat);
      final data = {
        "date_time": dateFormat,
        "drawer_cash": double.parse(controller.text)
      };
      var res = await CallApi().postGetDataWithToken(
          data,
          'start-shift?resId=${widget.restId}&cashierId=${widget.cashierId}',
          widget.cashierId);
      print('_openShift ======= ${res.data}');
      setState(() {
        isLoading = false;
      });
      final int? id = res.data?['data']['shift_id'];
      if (id != null) Navigator.pop(context, id);
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  _closeShift(int shiftId) async {
    try {
      try {
        setState(() {
          isLoading = true;
        });
        final date = DateTime.now();
        final String dateFormat =
            DateFormat('yyyy-MM-dd hh:mm:ss').format(date);
        print(dateFormat);
        final data = {
          "shift_id": shiftId,
          "date_time": dateFormat,
          "drawer_cash": double.parse(controller.text)
        };
        var res = await CallApi().postGetDataWithToken(
            data,
            'close-shift?resId=${widget.restId}&cashierId=${widget.cashierId}',
            widget.cashierId);
        print('Shift close response $res');

        setState(() {
          isLoading = false;
        });
        Navigator.pop(context, true);
      } catch (e) {
        print(e);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final restBloc =
        Provider.of<HomepageRestaurantBloc>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: setScaleHeight(40),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              SizedBox(
                height: 40,
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  isForOpen
                      ? 'Specify cash amount at the\nbegining of shift'
                      : 'Specify cash amount to\nclose shift',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(height: 1.6),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 40),
                height: 54,
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: Colors.white),
                alignment: Alignment.center,
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: controller,
                  decoration: InputDecoration.collapsed(
                      hintText: 'Enter drawer amount'),
                ),
              ),
              SizedBox(
                width: setScaleWidth(120),
                height: setScaleHeight(42),
                child: IgnorePointer(
                  ignoring: isLoading,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: controller.text.isEmpty
                        ? null
                        : () {
                            if (isForOpen) {
                              // _openShift();
                              _openShiftForDb();
                            } else {
                              // _closeShift(restBloc.shiftId!);
                              _closeShiftForDb(restBloc.shiftId!);
                            }
                          },
                    child: isLoading
                        ? CircularProgressIndicator()
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              isForOpen ? 'Open Shift' : 'Close Shift',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Open shift
  _openShiftForDb() async {
    try {
      setState(() {
        isLoading = true;
      });
      final date = DateTime.now();
      final String dateFormat = DateFormat('yyyy-MM-dd hh:mm:ss').format(date);
      print(dateFormat);
      final data = {
        "restaurant_id": Config.restaurantId,
        "cashier_id": widget.cashierId,
        "open_date_time": dateFormat,
        "drawer_cash_on_open": double.parse(controller.text)
      };
      // var res = await CallApi().postGetDataWithToken(
      //     data,
      //     'start-shift?resId=${widget.restId}&cashierId=${widget.cashierId}',
      //     widget.cashierId);
      var dbHandler = DatabaseHandler();
      var res = await dbHandler.insertShift(data);
      print('_openShift ======= $res');
      setState(() {
        isLoading = false;
      });
      // final int? id = res.data?['data']['shift_id'];
      // if (id != null) Navigator.pop(context, id);
      if (res > 0) Navigator.pop(context, res);
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Close shift in local db
  _closeShiftForDb(int shiftId) async {
    try {
      try {
        setState(() {
          isLoading = true;
        });
        final date = DateTime.now();
        final String dateFormat =
            DateFormat('yyyy-MM-dd hh:mm:ss').format(date);
        print(dateFormat);
        final data = {
          "shift_id": shiftId,
          "close_date_time": dateFormat,
          "drawer_cash_on_close": double.parse(controller.text)
        };
        // var res = await CallApi().postGetDataWithToken(
        //     data,
        //     'close-shift?resId=${widget.restId}&cashierId=${widget.cashierId}',
        //     widget.cashierId);
        // print('Shift close response $res');
        var dbHandler = DatabaseHandler();
        var res = await dbHandler.closeShift(data);
        print('Shift close response $res');

        setState(() {
          isLoading = false;
        });
        if (res > 0) Navigator.pop(context, true);
      } catch (e) {
        print(e);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }
}
