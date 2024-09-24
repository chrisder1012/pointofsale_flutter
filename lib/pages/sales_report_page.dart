import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:zabor/api/my_api.dart';
import 'package:zabor/models/cart.dart';
// import 'package:zabor/blocs/order_bloc.dart';
import 'package:zabor/models/item.dart';
import 'package:zabor/models/order.dart';
import 'package:zabor/models/rest_order_payment.dart';
import 'package:zabor/models/petty_cash.dart';
import 'package:zabor/models/petty_cash_close.dart';

import '../blocs/homepage_restaurant_bloc.dart';
import '../db/database_handler.dart';
import 'dart:ui' as ui;

import 'package:zabor/utils/t1_string.dart';

import '../blocs/sign_in_bloc.dart';
import '../config/config.dart';
import '../services/services.dart';
import '../utils/snacbar.dart';
import '../utils/utils.dart';

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({Key? key}) : super(key: key);

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  final DatabaseHandler _dbHandler = DatabaseHandler();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  double printWidth = 512;

  var _width = 0.0;
  var _height = 0.0;
  var _isLoading = false;
  GlobalKey salesKey = GlobalKey();

  int? userId;
  String?
      userEmail; //adicionado codepaeza 19/05/2023 para traer email user de la api
  String?
      userName; //adicionado codepaeza 19/05/2023 para traer nombre user de la api
  double?
      pettyCash; //adicionado codepaeza 19/05/2023 para traer valor total de arqueo inicial
  double?
      pettyCashClose; //adicionado codepaeza 19/05/2023 para traer valor total de arqueo cierre

  final List<RestOrderPayment> _sales = [];
  final List<Order> _orders = [];
  List<PettyCashModel> pettyCashModel = [];
  List<PettyCashCloseModel> pettyCashCloseModel = [];

  Map<String, dynamic>? shiftReportDatas;

  bool _hasOrder = false;

  _loadSales() {
    var date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _dbHandler.retireveOrderPayments().then((value) {
      for (var element in value) {
        if (element.time!.contains(date)) {
          _sales.add(element);
        }
      }
      setState(() {});
    });
  }

  double totalCoClose = 0;
  double totalCo = 0;

  getTotalCoClose() {
    pettyCashCloseModel.forEach((element) {
      totalCoClose = totalCoClose + element.totalCoClose;
    });
    return totalCoClose;
  }

  getTotalCo() {
    pettyCashModel.forEach((element) {
      totalCo = totalCo + element.totalCo;
    });
    return totalCo;
  }

  double get totalEn =>
      pettyCashModel.map((e) => e.totalEn).reduce((a, b) => a + b);

  // double get totalCo =>
  //     pettyCashModel.map((e) => e.totalCo).reduce((a, b) => a + b);

  double get totalEnClose =>
      pettyCashCloseModel.map((e) => e.totalEnClose).reduce((a, b) => a + b);

  // double get totalCoClose =>
  //     pettyCashCloseModel.map((e) => e.totalCoClose).reduce((a, b) => a + b);

  double cashDiff = 0.0;

  @override
  void initState() {
    userId = context.read<SignInBloc>().uid!;
    userEmail =
        context.read<SignInBloc>().email!; //Adicionado codepaeza 19/05/2023
    userName =
        context.read<SignInBloc>().name!; //Adicionado codepaeza 19/05/2023

    //pettyCash= widget.totalCo; //Se adiciona para traer el valor total de dinero arqueo inicial desde petty_cash.dart
    //pettyCashClose= widget.totalCoClose;
    // _handleGetOrders();
    // _loadSales();

    ///
    _handleShiftReportFromDB();

    showData();
    showDataClose();

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
      // backgroundColor: Colors.grey[900],
      appBar: _appbar(),
      body: shiftReportDatas == null
          ? Container()
          : _hasOrder == false
              ? Container()
              : _body(),
    );
  }

  _appbar() {
    return AppBar(
      toolbarHeight: setScaleHeight(40),
      centerTitle: true,
      leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: setScaleHeight(18),
          )),
      backgroundColor: Config().appColor,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            onPressed: () async {
              // await nextScreen(context, LoadingScreen());
              await printThirdData();
            },
            icon: Icon(
              Icons.print,
              size: setScaleHeight(18),
            ),
          ),
        )
      ],
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          t1SalesReport.tr(),
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  _body() {
    return SingleChildScrollView(
      physics: const ScrollPhysics(),
      child: RepaintBoundary(
        key: salesKey,
        child: Container(
          width: printWidth + 65,
          color: Colors.white,
          child: _isLoading == true
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      // child: _header(),
                      child: Text(
                        'Shift Report',
                        style: TextStyle(
                            //fontSize: 30,
                            fontSize: 40,
                            fontWeight: FontWeight.w500),
                      ),
                    ),

                    _shiftOpenAt(),
                    _shiftCloseAt(),
                    //Adicionado codepaeza 19/05/2023 para ingresar info user en reporte
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _userInfo(),
                    ),
                    //Fin de adición codepaeza

                    //Adicionado codepaeza 19/05/2023 para ingresar info arqueos en reporte
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: _pettyInfo(),
                    // ),
                    //Fin de adición codepaeza
                    const Divider(height: 1, color: Colors.grey),
                    _salesSummary(),
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: ListView.builder(
                    //     physics: const ScrollPhysics(),
                    //     shrinkWrap: true,
                    //     itemCount: _orders.length,
                    //     itemBuilder: (context, index) {
                    //       return Column(
                    //         children: const [],
                    //       );
                    //     },
                    //   ),
                    // ),
                    Text(
                      // _orders.isNotEmpty ? '*' * 200 : 'No data',
                      shiftReportDatas != null ? '*' * 200 : 'No data',
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      // _orders.isNotEmpty ? 'Done' : '',
                      shiftReportDatas != null ? 'Done' : '',
                      style: TextStyle(
                        //fontSize: 30,
                        fontSize: 40,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  _header() {
    return Column(
      children: [
        const Text(
          '*** $shiftReport ***',
          style: TextStyle(
            //fontSize: 30,
            fontSize: 40,
          ),
        ),
        Text(
          DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.now()),
          style: TextStyle(
            //fontSize: 30,
            fontSize: 40,
          ),
        ),
      ],
    );
  }

  _shiftOpenAt() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Opened At',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(
          width: 20,
        ),
        _dateTimeForMat(
            shiftReportDatas!['data']['report'][0]['shiftStartDate'],
            shiftReportDatas!['data']['report'][0]['shiftStartTime']),
      ],
    );
  }

  _shiftCloseAt() {
    if (shiftReportDatas!['data']['report'][0]['shiftEndDate'] == null) {
      return Container();
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Closed At',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(
          width: 20,
        ),
        _dateTimeForMat(shiftReportDatas!['data']['report'][0]['shiftEndDate'],
            shiftReportDatas!['data']['report'][0]['shiftEndTime']),
      ],
    );
  }

  _dateTimeForMat(String d, String t) {
    String dateString = d;
    // Parse the input date string into a DateTime object.
    DateTime date = DateFormat("yyyy-MM-dd").parse(dateString);

    // Format the DateTime object as a string in your desired format.
    String formattedDate = DateFormat('yMd').format(date);
    String timeString = t;

    // Split the time string into hours, minutes, and seconds.
    List<String> timeParts = timeString.split(':');
    int hours = int.parse(timeParts[0]);
    int minutes = int.parse(timeParts[1]);
    int seconds = int.parse(timeParts[2]);

    // Create a DateTime object with the time values.
    DateTime dateTime =
        DateTime(date.year, date.month, date.day, hours, minutes, seconds);

    // Format the DateTime object as a string in your desired format.
    String formattedTime = DateFormat("hh:mm a").format(dateTime);
    return Text(
      formattedDate + ' ' + formattedTime,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  //Adicionado codepaeza 19/05/2023 para ingresar info user en reporte
  _userInfo() {
    return Column(
      children: [
        const Text(
          //'*** $t1DailyClosingReport ***',
          '***Información Usuario***',
          style: TextStyle(
            //fontSize: 30,
            fontSize: 40,
          ),
        ),
        Text(
          //DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.now()),
          userEmail!,
          style: TextStyle(
            //fontSize: 30,
            fontSize: 40,
          ),
        ),
        Text(
          //DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.now()),
          userName!,
          style: TextStyle(
            //fontSize: 30,
            fontSize: 40,
          ),
        ),
      ],
    );
  }

  //Adicionado codepaeza 19/05/2023 para ingresar info  arqueos en reporte
  _pettyInfo() {
    return Column(
      children: [
        const Text(
          //'*** $t1DailyClosingReport ***',
          '***Valores Arqueos***',
          style: TextStyle(
            //fontSize: 30,
            fontSize: 40,
          ),
        ),
        Text(
          //DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.now()),
          'Arqueo Inicio: \$${getTotalCo()}',
          style: TextStyle(
            //fontSize: 30,
            fontSize: 40,
          ),
        ),
        Text(
          //DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.now()),
          'Arqueo Cierre: \$$totalCoClose',
          style: TextStyle(
            //fontSize: 30,
            fontSize: 40,
          ),
        ),
        Text(
          //DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.now()),
          // 'Efectivo Ventas: COL '+(cashDiff=totalCoClose-totalCo).toString(),
          'Efectivo Ventas: COL ' +
              (cashDiff = getTotalCoClose() - getTotalCo()).toString(),
          style: TextStyle(
            //fontSize: 30,
            fontSize: 40,
          ),
        ),
      ],
    );
  }

  _salesSummary() {
    return Column(
      children: [
        // Sub header
        Text(
          '-' * 200,
          overflow: TextOverflow.ellipsis,
        ),
        // /*const*/ Text(
        //   t1SalesSummary.tr(),
        //   style: TextStyle(
        //     //fontSize: 30,
        //     fontSize: 40,
        //   ),
        // ),
        /*const*/ Text(
          'Orders',
          style: TextStyle(
            //fontSize: 30,
            fontSize: 40,
          ),
        ),
        // /*const*/ Text(
        //   t1RefundsListedSeparately.tr(),
        //   style: TextStyle(
        //     //fontSize: 30,
        //     fontSize: 40,
        //   ),
        // ),
        Text(
          '-' * 200,
          overflow: TextOverflow.ellipsis,
        ),
        // Body
        shiftReportDatas == null
            ? /*const*/ Text(t1NoData.tr())
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  // children: _getOrderList(),
                  children: _getOrderListByItem(),
                ),
              ),
        // Total payments received summary
        Text(
          '=' * 50,
          overflow: TextOverflow.ellipsis,
        ),
        // /*const*/ Text(
        //   t1TotalPaymentsReceivedSummary.tr(),
        //   style: TextStyle(
        //     //fontSize: 30,
        //     fontSize: 40,
        //   ),
        // ),
        // Text(
        //   '=' * 50,
        //   overflow: TextOverflow.ellipsis,
        // ),
        shiftReportDatas == null
            ? Container()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: _shiftCashStatus(),
                ),
              ),
      ],
    );
  }

  _getOrderList() {
    List<Widget> widgets = [];
    final orders = shiftReportDatas!['data']['orders'];
    for (final order in orders) {
      var widget = Row(
        children: [
          Expanded(
              child: Text(
            'Order #${order['order_id']}',
            style: TextStyle(
              //fontSize: 30,
              fontSize: 40,
            ),
          )),
          Text(
            '\$${order['total']}',
            textAlign: TextAlign.right,
            style: TextStyle(
              //fontSize: 30,
              fontSize: 40,
            ),
          ),
        ],
      );

      widgets.add(widget);

      for (final item in order['items']) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            children: [
              Expanded(
                  child: Text(
                'Item ${item['itemName']}',
                style: TextStyle(
                  //fontSize: 30,
                  fontSize: 20,
                ),
              )),
              Text(
                '\$${item['itemPrice']}',
                textAlign: TextAlign.right,
                style: TextStyle(
                  //fontSize: 30,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ));
      }
    }
    return widgets;
  }

  _getOrderListByItem() {
    List<Widget> widgets = [];
    final orders = shiftReportDatas!['data']['orders'];
    for (final order in orders) {
      ///
      var itemMaps = jsonDecode(order['cart']) as List;
      // for (final item in order['items']) {
      for (final item in itemMaps) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            children: [
              Expanded(
                  child: Text(
                '${item['itemName']}',
                style: TextStyle(
                  fontSize: 30,
                  // fontSize: 20,
                ),
              )),
              Text(
                '\$${item['itemPrice']}',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 30,
                  // fontSize: 20,
                ),
              ),
            ],
          ),
        ));
      }

      var spaceWidget = SizedBox(height: 10);
      widgets.add(spaceWidget);

      var widget = Row(
        children: [
          Expanded(
              child: Text(
            'Invoice #${order['invoice_number']}',
            textAlign: TextAlign.right,
            style: TextStyle(
              //fontSize: 30,
              fontSize: 20,
            ),
          )),
          Text(
            '     \$${order['total']}',
            textAlign: TextAlign.right,
            style: TextStyle(
              //fontSize: 30,
              fontSize: 20,
            ),
          ),
        ],
      );

      widgets.add(widget);

      widgets.add(spaceWidget);
    }
    return widgets;
  }

  _shiftCashStatus() {
    List<Widget> widgets = [];
    final report = shiftReportDatas!['data']['report'][0];
    final openCash = Row(
      children: [
        Expanded(
            child: Text(
          'Open Cash',
          style: TextStyle(
            //fontSize: 30,
            fontSize: 40,
          ),
        )),
        Text(
          '\$${report['openTimeDrawerCash']}',
          textAlign: TextAlign.right,
          style: TextStyle(
            //fontSize: 30,
            fontSize: 40,
          ),
        ),
      ],
    );
    final closeCash = Row(
      children: [
        Expanded(
            child: Text(
          'Closed Cash',
          style: TextStyle(
            //fontSize: 30,
            fontSize: 40,
          ),
        )),
        Text(
          '\$${report['closeTimeDrawerCash'] ?? 0}',
          textAlign: TextAlign.right,
          style: TextStyle(
            //fontSize: 30,
            fontSize: 40,
          ),
        ),
      ],
    );

    final totalSales = Row(
      children: [
        Expanded(
            child: Text(
          'Total Sales',
          style: TextStyle(
            //fontSize: 30,
            fontSize: 40,
          ),
        )),
        Text(
          '\$${report['total_sales_amount']}',
          textAlign: TextAlign.right,
          style: TextStyle(
            //fontSize: 30,
            fontSize: 40,
          ),
        ),
      ],
    );
    widgets.add(totalSales);
    widgets.add(Divider(
      thickness: 3,
    ));
    widgets.add(openCash);
    if (report['closeTimeDrawerCash'] != null) {
      widgets.add(closeCash);
    }
    if (report['closeTimeDrawerCash'] != null) {
      widgets.add(Divider(
        thickness: 3,
      ));

      final cashInHand = report['closeTimeDrawerCash'] ?? 0.0;

      final openCashPlusSales =
          report['total_sales_amount'] + report['openTimeDrawerCash'];

      final differenceCash = cashInHand - openCashPlusSales;
      final difference = Row(
        children: [
          Expanded(
              child: Text(
            'Difference',
            style: TextStyle(
              //fontSize: 30,
              fontSize: 40,
            ),
          )),
          Text(
            '\$${differenceCash.toStringAsFixed(2)}',
            textAlign: TextAlign.right,
            style: TextStyle(
              //fontSize: 30,
              fontSize: 40,
            ),
          ),
        ],
      );
      widgets.add(difference);
    }

    return widgets;
  }

  _getItemList() {
    double totalTax = 0.0;
    double netSales = 0.0;
    List<Widget> widgets = [];
    Map<String, double> itemMap = {};
    for (var order in _orders) {
      List<dynamic> snap = [];
      snap.addAll(jsonDecode(order.cart!));
      List<Item> items = snap.map((e) => Item.fromJson2(e)).toList();
      for (var item in items) {
        if (itemMap[item.itemName!] == null) {
          itemMap[item.itemName!] = item.itemPrice! * item.quantity!;
        } else {
          itemMap[item.itemName!] =
              itemMap[item.itemName!]! + item.itemPrice! * item.quantity!;
        }
      }
      totalTax += order.tax!;
    }
    itemMap.forEach((key, value) {
      netSales += value;
      var widget = Row(
        children: [
          Expanded(
              flex: 3,
              child: Text(
                key,
                style: TextStyle(
                  //fontSize: 30,
                  fontSize: 40,
                ),
              )),
          Expanded(
              flex: 1,
              child: Text(
                value.toStringAsFixed(2),
                textAlign: TextAlign.right,
                style: TextStyle(
                  //fontSize: 30,
                  fontSize: 40,
                ),
              )),
        ],
      );
      widgets.add(widget);
    });

    // Net Sales
    var underlineWidget = Row(
      children: [
        const Spacer(),
        Text('--' * (netSales.toString().length + 1)),
      ],
    );
    var netSaleWidget = Row(
      children: [
        /*const*/ Expanded(
            flex: 3,
            child: Text(
              t1NetSales.tr(),
              style: TextStyle(
                //fontSize: 30,
                fontSize: 40,
              ),
            )),
        Expanded(
            flex: 1,
            child: Text(
              '\$$netSales',
              textAlign: TextAlign.right,
              style: TextStyle(
                //fontSize: 30,
                fontSize: 40,
              ),
            )),
      ],
    );
    var varianceWidget = Row(
      children: /*const*/ [
        Expanded(
            flex: 3,
            child: Text(
              t1Variance.tr(),
              style: TextStyle(
                //fontSize: 30,
                fontSize: 40,
              ),
            )),
        Expanded(
            flex: 1,
            child: Text(
              '\$0.0',
              textAlign: TextAlign.right,
              style: TextStyle(
                //fontSize: 30,
                fontSize: 40,
              ),
            )),
      ],
    );

    widgets.add(underlineWidget);
    widgets.add(netSaleWidget);
    widgets.add(varianceWidget);

    // Total Taxes
    underlineWidget = Row(
      children: [
        const Spacer(),
        Text('--' * (netSales.toString().length + 1)),
      ],
    );

    var taxesWidget = Row(
      children: [
        /*const*/ Expanded(
            flex: 3,
            child: Text(
              t1TotalTaxes.tr(),
              style: TextStyle(
                //fontSize: 30,
                fontSize: 40,
              ),
            )),
        Expanded(
            flex: 1,
            child: Text(
              '\$${totalTax.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: TextStyle(
                //fontSize: 30,
                fontSize: 40,
              ),
            )),
      ],
    );
    widgets.add(underlineWidget);
    widgets.add(taxesWidget);

    // Total
    underlineWidget = Row(
      children: [
        const Spacer(),
        Text('=' * (netSales.toString().length + 1)),
      ],
    );

    var totalWidget = Row(
      children: [
        /*const*/ Expanded(
            flex: 3,
            child: Text(
              t1TotalPoint.tr(),
              style: TextStyle(
                //fontSize: 30,
                fontSize: 40,
              ),
            )),
        Expanded(
            flex: 1,
            child: Text(
              '\$${(netSales + totalTax).toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: TextStyle(
                //fontSize: 30,
                fontSize: 40,
              ),
            )),
      ],
    );
    widgets.add(underlineWidget);
    widgets.add(totalWidget);

    return widgets;
  }

  _totalPaymentsReceivedSummary() {
    var visaTotal = 0.0;
    var mastercardTotal = 0.0;
    var devitcardTotal = 0.0;
    var creditcardTotal = 0.0;
    var cashTotal = 0.0;

    int visaCount = 0;
    int mastercardCount = 0;
    int devitcardCount = 0;
    int creditcardCount = 0;
    int cashCount = 0;

    List<Widget> widgets = [];

    for (var order in _orders) {
      switch (order.paymentMode) {
        case 2:
          cashTotal += order.total!;
          cashCount += 1;
          break;
        case 1:
          creditcardTotal += order.total!;
          break;
        case 3:
          devitcardTotal += order.total!;
          break;
        default:
      }
    }

    // Visa widget
    _paymentSummaryWidget(widgets, t1Visa.tr(), visaTotal, visaCount);
    // MasterCard widget
    _paymentSummaryWidget(
        widgets, t1MasterCard.tr(), mastercardTotal, mastercardCount);
    // DevitCard widget
    _paymentSummaryWidget(
        widgets, t1DevitCard.tr(), devitcardTotal, devitcardCount);
    // CreditCard widget
    _paymentSummaryWidget(
        widgets, t1CreditCard.tr(), creditcardTotal, creditcardCount);
    // Cash widget
    _paymentSummaryWidget(widgets, t1Cash.tr(), cashTotal, cashCount);

    var totalPayments = visaTotal +
        mastercardTotal +
        devitcardTotal +
        creditcardTotal +
        cashTotal;
    var length = totalPayments.toString().length + 1;

    // Total payments
    var underlineWidget = Row(
      children: [
        const Spacer(),
        Text('=' * length),
      ],
    );
    var totalWidget = Row(
      children: [
        /*const*/ Expanded(
            flex: 3,
            child: Text(
              t1TotalPayments.tr(),
              style: TextStyle(
                //fontSize: 30,
                fontSize: 40,
              ),
            )),
        Expanded(
            flex: 1,
            child: Text(
              '\$${totalPayments.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: TextStyle(
                //fontSize: 30,
                fontSize: 40,
              ),
            )),
      ],
    );
    widgets.add(underlineWidget);
    widgets.add(totalWidget);

    return widgets;
  }

  _paymentSummaryWidget(
      List<Widget>? widgets, String paymentName, double price, int count) {
    var paymentWidget = Row(
      children: [
        Expanded(
            flex: 3,
            child: Text(
              '$paymentName:',
              style: TextStyle(
                //fontSize: 30,
                fontSize: 40,
              ),
            )),
        FittedBox(
            child: Text(
          '\$$price',
          textAlign: TextAlign.right,
          style: TextStyle(
            //fontSize: 30,
            fontSize: 40,
          ),
        )),
      ],
    );
    var countWidget = Row(
      children: [
        Text(
          '\t\t\t$count Counts(s)',
          textAlign: TextAlign.right,
          style: TextStyle(
            //fontSize: 20,
            fontSize: 40,
          ),
        ),
      ],
    );

    widgets!.add(paymentWidget);
    widgets.add(countWidget);
  }

  Uint8List? capturedBytes;
  Future<String> convertImageToBase64(GlobalKey globalTmpKey) async {
    if (globalTmpKey.currentContext == null) return "";
    RenderRepaintBoundary boundary = globalTmpKey.currentContext!
        .findRenderObject()! as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    capturedBytes = byteData!.buffer.asUint8List();
    final imageEncoded = base64.encode(capturedBytes!);
    return imageEncoded;
  }

  Future<void> printThirdData() async {
    try {
      List<String> imageLst = [""];

      imageLst[0] = await convertImageToBase64(salesKey);

      print(["sales report_page: 00", imageLst[0]]);

      var dio = Dio();
      List<String> strPrinters = await Config.getPrinters() ?? [];
      if (strPrinters.isEmpty) return showPrintAlert();
      for (var i = 0; i < imageLst.length; i++) {
        if (strPrinters[i].isEmpty) continue;
        var data = {};
        if (strPrinters[i].split(".").length == 4) {
          data = {"image": imageLst[0], "text": "", "printer": strPrinters[i]};
        } else {
          data = {
            "image": imageLst[0],
            "text": "",
            "printer": strPrinters[i],
            "printerType": 3
          };
        }
        print(data);
        try {
          await dio.post("http://localhost:7200", data: data);
          // openSnacbar(context, "print Success");
        } catch (e) {
          openSnacbar(context, "print failed");
        }

        await Future.delayed(const Duration(seconds: 2));
      }
      setState(() {});
    } catch (e) {
      setState(() {});
    }
  }

  showPrintAlert() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('You have to register printers'),
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

  // Handle to get orders
  _handleGetOrders() async {
    try {
      // final OrderBloc ob = Provider.of<OrderBloc>(context, listen: false);
      final restBloc =
          Provider.of<HomepageRestaurantBloc>(context, listen: false);

      final signInBloc = Provider.of<SignInBloc>(context, listen: false);

      await AppService().checkInternet().then((hasInternet) async {
        if (hasInternet == false) {
          openSnacbar(context, 'no internet');
        } else {
          setState(() {
            _isLoading = true;
          });
          final res = await CallApi().getDataWithToken(
              "/shift-report?resId=${Config.restaurantId}&cashierId=${signInBloc.uid}&shiftId=${restBloc.shiftId}&order_by='cashier','kiosk'");
          print(res.data);
          //
          if (res.data?['msg'] == null) {
            _hasOrder = true;
          } else {
            _hasOrder = false;
          }

          setState(() {
            shiftReportDatas = res.data == null ? null : res.data;
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        // _isAddedCart = true;
      });
    }
  }

  ///
  Future<bool> _handleShiftReportFromDB() async {
    try {
      /// Get current shift id
      int shiftId = await _dbHandler.getCurrenShiftId(Config.restaurantId!);
      if (shiftId == 0) {
        return false;
      }
      ;

      /// Get cart"s by ordered
      var orders = await _dbHandler.getOrders(shiftId, Config.restaurantId!);
      if (orders.isEmpty) {
        return false;
      }

      ///
      double totalSalesAmount = 0.0;
      double totalFoodTax = 0.0;
      double totalConvenienceFee = 0.0;
      int itemCount = 0;

      for (var order in orders) {
        totalSalesAmount += order.total!;
        totalFoodTax += order.foodTax!;
        totalConvenienceFee += order.convenienceFee!;
        var cartString = order.cart ?? "";
        if (cartString.isEmpty) continue;
        var cartMap = jsonDecode(cartString) as List;
        for (var cart in cartMap) {
          itemCount += cart['quantity'] as int;
        }
      }

      var reportMap = await _getReportMap(shiftId, userId!, totalSalesAmount,
          totalFoodTax, totalConvenienceFee, itemCount);

      /// Get orders map
      var ordersMap = orders.map((e) => e.toJson()).toList();

      var map = {
        "status": true,
        "data": {
          "report": [reportMap],
          "orders": ordersMap,
        }
      };

      if (map['msg'] == null) {
        _hasOrder = true;
      } else {
        _hasOrder = false;
      }

      setState(() {
        shiftReportDatas = map;
        // _isLoading = false;
      });

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Get report map
  Future<Map<String, dynamic>?> _getReportMap(
      int shiftId,
      int userId,
      double total,
      double totalFoodTax,
      double totalConvenienceFee,
      int quantity) async {
    /// Get shift information
    var shiftMap = await _dbHandler.getShift(Config.restaurantId!, shiftId);
    if (shiftMap == null) return null;

    String? openDateTime = shiftMap['open_date_time'];
    String openDate = openDateTime!.split(' ')[0];
    String openTime = openDateTime.split(' ')[1];

    String? closeDateTime = shiftMap['close_date_time'];

    var reportMap = {
      "restaurantId": Config.restaurantId!,
      "restaurantName": "Las Cuevas Spot",
      "paymentStatus": "UNPAID",
      "cashierId": userId,
      "shiftId": shiftId,
      "shiftDate": openDate,
      "perDayShiftId": 1,
      "shiftStartDate": openDate,
      "shiftStartTime": openTime,
      "shiftEndDate": null,
      "shiftEndTime": null,
      "openTimeDrawerCash": shiftMap['drawer_cash_on_open'],
      "closeTimeDrawerCash": shiftMap['drawer_cash_on_close'],
      "total_sales_amount": total,
      "total_food_tax": totalFoodTax,
      "total_liquor_tax": 9.54,
      "total_generic_tax": 3.39,
      "total_convenience_fee": totalConvenienceFee,
      "quantity_items_sold": quantity
    };

    return reportMap;
  }

  Future showData() async {
    await _dbHandler.initializeDB();
    pettyCashModel = await _dbHandler.retirevePettyAmounts();
    setState(() {
      pettyCashModel = pettyCashModel;
    });
  }

  Future showDataClose() async {
    await _dbHandler.initializeDB();
    pettyCashCloseModel = await _dbHandler.retirevePettyCloseAmounts();
    setState(() {
      pettyCashCloseModel = pettyCashCloseModel;
    });
  }
}
