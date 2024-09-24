import 'package:flutter/material.dart';
import 'package:zabor/config/config.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:zabor/db/database_handler.dart';
import 'package:zabor/models/rest_order.dart';
import 'package:zabor/models/rest_table.dart';
// import 'package:zabor/pages/management_table_page.dart';

import 'package:zabor/utils/t1_string.dart';

import 'package:zabor/pages/unpaid_page_table.dart';

// import '../config/config.dart';
// import '../db/database_handler.dart';
import '../utils/utils.dart';

class TableOrdersPage extends StatefulWidget {
  const TableOrdersPage({Key? key}) : super(key: key);

  @override
  State<TableOrdersPage> createState() => _TableOrdersPageState();
}

class _TableOrdersPageState extends State<TableOrdersPage> {
  final DatabaseHandler _dbHandler = DatabaseHandler();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // final TextEditingController _addNameController = TextEditingController();

  final bool _isSaved = true;

  // var isPortrait = false;
  // var scaleWidth = 0.0;
  // var scaleHeight = 0.0;
  double _width = 0.0;
  double _height = 0.0;

  final List<RestTable> _restTables = [];
  final List<RestOrder> _restOrders = [];

  final List _selectedIndexs = [];

  // RestOrder? _selectOrder;
  //RestTable? _selectTable;

  //Cart? _cart;
  //Tax? _tax;
  //Basket? _basket;
  // int? _orderIndex;
  // int? _userId;

  _loadTablesFromDb() {
    _dbHandler.retireveRestTable().then((value) {
      _restTables.clear();
      for (var element in value) {
        if (element.tableGroupId == Config.restaurantId) {
          _restTables.add(element);
        }
      }
      setState(() {});
    });
  }

  _getDataFromDb() {
    // Rest Order
    _dbHandler.retireveRestOrders().then((value) {
      _restOrders.clear();
      for (var element in value) {
        if (element.tableGroupId == Config.restaurantId) {
          _restOrders.add(element);
        }
      }
      setState(() {});
    });
  }

  _isOrdered(String name, int groupId) {
    if (_restOrders.isEmpty) return false;
    var ret = false;
    for (int i = 0; i < _restOrders.length; i++) {
      if (_restOrders[i].tableName == name &&
          _restOrders[i].tableGroupId == groupId) {
        ret = true;
        break;
      }
    }
    return ret;
  }

  RestOrder? _getRestOrder(String name, int groupId) {
    RestOrder? restOrder;
    for (int i = 0; i < _restOrders.length; i++) {
      if (_restOrders[i].tableName == name &&
          _restOrders[i].tableGroupId == groupId) {
        restOrder = _restOrders[i];
        break;
      }
    }
    return restOrder;
  }

  @override
  void initState() {
    // Load table
    _loadTablesFromDb();
    _getDataFromDb();

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
      backgroundColor: Colors.grey[900],
      appBar: _appbar(),
      body: _body(),
    );
  }

  _body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _bodylist(),
      ],
    );
  }

  _appbar() {
    return AppBar(
      leading: IconButton(
          onPressed: () {
            Navigator.pop(context, _isSaved);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          )),
      backgroundColor: Config().appColor,
      title: /*const*/ Text(
        t1ShowOrdersTable.tr(),
      ),
    );
  }

  _bodylist() {
    return Expanded(
      child: FutureBuilder(
        future: _dbHandler.retireveRestTable(),
        //future:  _loadTablesFromDb(),
        builder: ((context, AsyncSnapshot<List<RestTable>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              physics: const ScrollPhysics(),
              padding: const EdgeInsets.all(12.0),
              shrinkWrap: true,
              //itemCount: _restTables.length,
              itemCount: snapshot.data?.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedIndexs.contains(index);

                return GestureDetector(
                  onTap: () {},
                  onTapDown: (value) {
                    setState(() {
                      if (!_selectedIndexs.contains(index)) {
                        _selectedIndexs.add(index);
                      }
                    });
                  },
                  onTapCancel: () {
                    setState(() {
                      if (_selectedIndexs.contains(index)) {
                        _selectedIndexs.remove(index);
                      }
                    });
                  },
                  onTapUp: (value) async {
                    setState(() {
                      if (_selectedIndexs.contains(index)) {
                        _selectedIndexs.remove(index);
                      }
                    });
                    // show dialog
                    if (_isOrdered(snapshot.data![index].name!,
                        snapshot.data![index].tableGroupId!)) {
                      // var responses = await _dbHandler.retireveRestResponse();
                      // var result = await Navigator.push(
                      //  context,
                      //  MaterialPageRoute(
                      //   builder: (context) => UnpaidPageTable(
                      // isOrdered: true,
                      //orderId: _getRestOrder(snapshot.data![index].name!,
                      //       snapshot.data![index].tableGroupId!)!
                      //   .id,
                      //     orderState: 0,
                      //     restTable: snapshot.data![index],
                      //       personNum: _getRestOrder(
                      //               snapshot.data![index].name!,
                      //               snapshot.data![index].tableGroupId!)!
                      //           .personNum,
                      //       response: responses[0],
                      //     ),
                      //  ),
                      // );
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UnpaidPageTable(
                            //orderState: 1,
                            orderState: 0,

                            restOrder: _getRestOrder(
                                snapshot.data![index].name!,
                                snapshot.data![index].tableGroupId!),
                            restTable: snapshot.data![index],
                            personNum: _getRestOrder(
                                    snapshot.data![index].name!,
                                    snapshot.data![index].tableGroupId!)!
                                .personNum,
                            //responses: responses[0],
                          ),
                        ),
                      );
                      _getDataFromDb();
                      // if (result == true) {
                      //   _getDataFromDb();
                      // }
                    } /*else {
              // _showNumberGuestsDialog(index);
              var result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UnpaidPageTable(
                        orderState: 0,
                        restTable: _restTables[index],
                        personNum: 1,
                      )));
              if (result == true) {
                _getDataFromDb();
              }
            }*/
                  },
                  child: Container(
                      alignment: Alignment.centerLeft,
                      height: setScaleHeight(60),
                      width: _width,
                      margin: const EdgeInsets.all(1),
                      padding: const EdgeInsets.only(left: 16),
                      color: _isOrdered(snapshot.data![index].name!,
                                  snapshot.data![index].tableGroupId!) ==
                              false
                          ? isSelected
                              ? Colors.grey[400]
                              : Colors.white
                          : Colors.orange[400],
                      child: Text(_restTables[index].name!,
                          style: TextStyle(
                            fontSize: setFontSize(14),
                          ))),
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }),
      ),
    );
  }
}
