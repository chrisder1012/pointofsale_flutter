import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import 'package:zabor/models/rest_table.dart';
import 'package:zabor/utils/snacbar.dart';
import 'package:zabor/utils/t1_string.dart';

import '../blocs/rest_table_section_bloc.dart';
import '../config/config.dart';
import '../db/database_handler.dart';
import '../models/rest_table_section.dart';
import '../services/services.dart';
import '../utils/utils.dart';

class ManagementTablePage extends StatefulWidget {
  const ManagementTablePage({Key? key}) : super(key: key);

  @override
  State<ManagementTablePage> createState() => _ManagementTablePageState();
}

class _ManagementTablePageState extends State<ManagementTablePage> {
  final DatabaseHandler _dbHandler = DatabaseHandler();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _addNameController = TextEditingController();
  final TextEditingController _addNumberController = TextEditingController();

  bool _isSaved = false;
  bool _isLoadingTable = false;
  bool _isLoadedTable = false;
  double _width = 0.0;
  double _height = 0.0;

  final List<RestTable> _restTables = [];

  @override
  void initState() {
    // Load table
    _loadTablesFromDb();
    // _handleRestaurantTable();

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
      body: _body(),
    );
  }

  _appbar() {
    return AppBar(
      toolbarHeight: setScaleHeight(40),
      leading: IconButton(
          onPressed: () {
            Navigator.pop(context, _isSaved);
          },
          icon: Icon(
            Icons.arrow_back,
            size: setScaleHeight(15),
          )),
      backgroundColor: Config().appColor,
      title: /*const*/ FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          t1Table.tr(),
          style: TextStyle(fontSize: 20),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            _showAddOrEditTableDialog(state: 0); // Insert
          },
          child: Row(
            children: /*const*/ [
              Icon(Icons.add, size: setScaleHeight(15)),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  t1Add.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            _showDeleteTablesDialog();
          },
          child: Row(
            children: /*const*/ [
              Icon(
                Icons.delete_outline,
                size: setScaleHeight(15),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  t1DeleteAll.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  _body() {
    return _isLoadingTable
        ? Center(child: CircularProgressIndicator())
        : ListView.separated(
            physics: const ScrollPhysics(),
            shrinkWrap: true,
            itemCount: _restTables.length,
            separatorBuilder: (context, index) {
              return const SizedBox(height: 2);
            },
            itemBuilder: ((context, index) {
              return ListTile(
                onTap: () {
                  _showAddOrEditTableDialog(
                      state: 1, restTable: _restTables[index]); // Edit
                },
                tileColor: Colors.white,
                title: Text(
                  _restTables[index].name!,
                  style: TextStyle(
                    fontSize: setFontSize(14),
                  ),
                ),
                subtitle: Text('Table number: ${_restTables[index].num}'),
                trailing: Text(
                  _restTables[index].tableGroupId!.toString(),
                ),
              );
            }),
          );
  }

  //
  _showAddOrEditTableDialog({int? state, RestTable? restTable}) {
    if (state == 1) {
      _addNameController.text = restTable!.name!;
      _addNumberController.text = restTable.num!.toString();
    } else {
      _addNameController.clear();
      _addNumberController.clear();
    }
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    state == 1 ? t1EditTable.tr() : t1AddTable.tr(),
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: setFontSize(18),
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _addNameController,
                        decoration: InputDecoration(hintText: 'Table name'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return t1CannotEmpty.tr();
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _addNumberController,
                        decoration: InputDecoration(hintText: 'Table number'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return t1CannotEmpty.tr();
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          color: Colors.blue,
                          height: setScaleHeight(30),
                          child: Center(
                            child: Text(
                              t1Cancel.tr(),
                              style: TextStyle(
                                fontSize: setFontSize(16),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    state == 1
                        ? Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                _deleteTable(restTable!.id!);
                                // _handleDeleteTableById(restTable!.id!);
                              },
                              child: Container(
                                color: Colors.green,
                                height: setScaleHeight(30),
                                child: Center(
                                  child: Text(
                                    t1Delete.tr(),
                                    style: TextStyle(
                                      fontSize: setFontSize(16),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            if (state == 0) {
                              Navigator.pop(context);
                              _saveTable();
                            } else {
                              _updateTable(restTable!.id!);
                            }
                          }
                          // Navigator.pop(context);
                        },
                        child: Container(
                          color: Colors.red,
                          height: setScaleHeight(30),
                          child: Center(
                            child: Text(
                              t1Save.tr(),
                              style: TextStyle(
                                fontSize: setFontSize(16),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Show ask dialog to delete all table
  _showDeleteTablesDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    t1DeleteAll.tr(),
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: setFontSize(18),
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Are you sure you want to delete tables?',
                    style: TextStyle(
                      fontSize: setFontSize(24),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          color: Colors.blue,
                          height: setScaleHeight(30),
                          child: Center(
                            child: Text(
                              t1No.tr(),
                              style: TextStyle(
                                fontSize: setFontSize(16),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.pop(context);
                          if (await _clearRestTable()) {
                            setState(() {});
                          }
                        },
                        child: Container(
                          color: Colors.red,
                          height: setScaleHeight(30),
                          child: Center(
                            child: Text(
                              t1Yes.tr(),
                              style: TextStyle(
                                fontSize: setFontSize(16),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Handle to add restaurant table section
  Future<bool> _handleAddRestTable(
      String restId, String name, String number) async {
    bool isAdded = false;
    final RestTableSectionBloc rtsb =
        Provider.of<RestTableSectionBloc>(context, listen: false);

    await AppService().checkInternet().then((hasInternet) async {
      if (hasInternet == false) {
        openSnacbar(context, 'no internet');
      } else {
        setState(() {
          _isLoadingTable = true;
        });
        rtsb.addTable(restId, name, number).then((_) async {
          if (rtsb.hasError == false) {
            List<RestTable> tables = [];
            for (var table in rtsb.tables) {
              var rt = RestTable(
                  name: table.sectionName,
                  num: int.parse(table.numberOfTable!),
                  tableGroupId: table.restaurantId);
              tables.add(rt);
            }
            _restTables.clear();
            _dbHandler.deleteAllTables().then((value) {
              _restTables.addAll(tables);
              _dbHandler.insertRestTable(_restTables).then((value) {
                _isSaved = true;
                Navigator.pop(context, true);
                setState(() {
                  _addNameController.clear();
                  _addNumberController.clear();
                });
              });
            });

            // var rt = RestTable(
            //     name: name,
            //     tableGroupId: Config.restaurantId,
            //     num: int.parse(number));
          } else {
            openSnacbar(context, rtsb.errorCode);
          }
          setState(() {
            _isLoadingTable = false;
          });
        });
      }
    });
    return isAdded;
  }

  // Handle to update restaurant table section
  Future<bool> _handleUpdateRestTable(
      int restId, int tableId, String name, String number) async {
    bool isUpdated = false;
    final RestTableSectionBloc rtsb =
        Provider.of<RestTableSectionBloc>(context, listen: false);

    await AppService().checkInternet().then((hasInternet) async {
      if (hasInternet == false) {
        openSnacbar(context, 'no internet');
      } else {
        setState(() {
          _isLoadingTable = true;
        });
        print('===== $tableId =====');
        rtsb
            .updateTable(restId.toString(), tableId.toString(), name, number)
            .then((_) async {
          if (rtsb.hasError == false) {
            List<RestTable> tables = [];
            for (var table in rtsb.tables) {
              var rt = RestTable(
                  id: table.sectionId,
                  name: table.sectionName,
                  num: int.parse(table.numberOfTable!),
                  tableGroupId: table.restaurantId);
              tables.add(rt);
            }
            _restTables.clear();
            _restTables.addAll(tables);

            _dbHandler.deleteAllTables().then((value) {
              _dbHandler.insertRestTable(_restTables).then((value) {
                _isSaved = true;
                Navigator.pop(context, true);
                setState(() {
                  _addNameController.clear();
                  _addNumberController.clear();
                });
              });
            });
          } else {
            openSnacbar(context, rtsb.errorCode);
          }
          setState(() {
            _isLoadingTable = false;
          });
        });
      }
    });
    return isUpdated;
  }

  _saveTable() async {
    // var restTable = RestTable(name: )
    var name = _addNameController.text;
    var number = _addNumberController.text;

    var isFind = false;
    for (var rt in _restTables) {
      if (rt.name == name || rt.num == number) {
        isFind = true;
        break;
      }
    }
    if (isFind) {
      openSnacbar(context, 'This table exists in table');
      return;
    }

    // _handleAddRestTable(Config.restaurantId.toString(), name, number);
    var tableId =
        await _addRestTable(Config.restaurantId!, name, int.parse(number));
    if (tableId > 0) {
      setState(() {});
    }
  }

  // Handle to get restaurant table section
  Future<void> _handleRestaurantTable() async {
    final RestTableSectionBloc rtsb =
        Provider.of<RestTableSectionBloc>(context, listen: false);

    await AppService().checkInternet().then((hasInternet) async {
      if (hasInternet == false) {
        openSnacbar(context, 'no internet');
        setState(() {
          _isLoadingTable = false;
          _isLoadedTable = false;
        });
      } else {
        rtsb.getTableByRestId(Config.restaurantId.toString()).then((_) async {
          _isLoadingTable = false;
          if (rtsb.hasError == false) {
            // Get table section if not exist in table db
            List<RestTableSection> tableSections = [];
            for (var table in rtsb.tables) {
              var rt = _restTables.firstWhereOrNull((rt) =>
                  (rt.tableGroupId == table.restaurantId) &&
                  (rt.name == table.sectionName));
              rt ?? tableSections.add(table);
            }

            // Switch table section to table
            List<RestTable> rts = [];
            for (var ts in tableSections) {
              var rt = RestTable(
                id: ts.sectionId,
                name: ts.sectionName,
                num: int.parse(ts.numberOfTable!),
                tableGroupId: ts.restaurantId,
              );
              rts.add(rt);
              _restTables.add(rt);
            }
            _restTables.sort(((a, b) => a.num!.compareTo(b.num!)));

            _saveTablesToDb(_restTables);

            _isLoadedTable = true;
          } else {
            openSnacbar(context, rtsb.errorCode);
            _isLoadedTable = false;
          }
          setState(() {});
        });
      }
    });
  }

  // Handle to get restaurant table section
  Future<void> _handleDeleteAllTable() async {
    final RestTableSectionBloc rtsb =
        Provider.of<RestTableSectionBloc>(context, listen: false);

    setState(() {
      _isLoadingTable = true;
      _isLoadedTable = false;
    });

    await AppService().checkInternet().then((hasInternet) async {
      if (hasInternet == false) {
        openSnacbar(context, 'no internet');
        setState(() {
          _isLoadingTable = false;
          _isLoadedTable = false;
        });
      } else {
        rtsb.deleteAllTable(Config.restaurantId.toString()).then((_) async {
          _isLoadingTable = false;
          if (rtsb.hasError == false) {
            _clearRestTable();

            _isSaved = true;
            _isLoadedTable = true;
          } else {
            openSnacbar(context, rtsb.errorCode);
            _isLoadedTable = false;
          }
          setState(() {});
        });
      }
    });
  }

  // Handle to get restaurant table section
  Future<void> _handleDeleteTableById(int tableId) async {
    final RestTableSectionBloc rtsb =
        Provider.of<RestTableSectionBloc>(context, listen: false);

    setState(() {
      _isLoadingTable = true;
      _isLoadedTable = false;
    });

    await AppService().checkInternet().then((hasInternet) async {
      if (hasInternet == false) {
        openSnacbar(context, 'no internet');
        setState(() {
          _isLoadingTable = false;
          _isLoadedTable = false;
        });
      } else {
        rtsb.deleteTable(Config.restaurantId!, tableId).then((_) async {
          _isLoadingTable = false;
          if (rtsb.hasError == false) {
            _deleteTable(tableId);
            _isSaved = true;
            _isLoadedTable = true;
          } else {
            openSnacbar(context, rtsb.errorCode);
            _isLoadedTable = false;
          }
          setState(() {});
        });
      }
    });
  }

  _loadTablesFromDb() {
    _dbHandler.retireveRestTable().then((value) {
      _restTables.clear();
      for (var element in value) {
        if (element.tableGroupId == Config.restaurantId) {
          _restTables.add(element);
        }
      }
      print('tables number: ${_restTables.length}');
      setState(() {});
    });
  }

  _saveTablesToDb(List<RestTable> rts) {
    _dbHandler.insertRestTable(rts).then((value) {
      print('===== The rest tables are save to db =====');
    });
  }

  _updateTable(int id) {
    var name = _addNameController.text;
    Map<String, Object> map = {};
    map['name'] = name;
    _dbHandler.updateRestTable(map, id).then((value) {
      Navigator.pop(context, true);
      _loadTablesFromDb();
    });
  }

  _deleteTable(int id) {
    _dbHandler.deleteRestTable(id).then((value) {
      _loadTablesFromDb();
    });
  }

  Future<bool> _clearRestTable() async {
    var ret = await _dbHandler.deleteRestTablesByRestId(Config.restaurantId!);
    if (ret == true) {
      _restTables.clear();
      openSnacbar(context, 'Success: delete all tables');
    } else {
      openSnacbar(context, 'Error: delete all tables');
    }
    return ret;
  }

  Future<int> _addRestTable(int restId, String name, int number) async {
    var restTable = RestTable(name: name, num: number, tableGroupId: restId);
    var ret = await _dbHandler.insertRestTable([restTable]);
    if (ret != 0) {
      openSnacbar(context, 'Success: Insert table');
      restTable.id = ret;
      _restTables.add(restTable);
    } else {
      openSnacbar(context, 'Error: Insert table');
    }
    return ret;
  }
}
