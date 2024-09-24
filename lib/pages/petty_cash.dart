import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:zabor/models/petty_cash.dart';
import 'package:zabor/utils/t1_string.dart';

import '../db/database_handler.dart';
import 'package:flutter/rendering.dart';
// import 'package:zabor/utils/next_screen.dart';

class PettyCash extends StatefulWidget {
  const PettyCash({Key? key}) : super(key: key);

  @override
  State<PettyCash> createState() => _PettyCashState();
}

class _PettyCashState extends State<PettyCash> {
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // final GlobalKey<FormState> _formKey = GlobalKey<
  // FormState>(); //Adicionado codepaeza 22/05/2023
  bool isEN = true;

  //Adicionado codepaeza 18/05/2023
  final DatabaseHandler _dbHandler = DatabaseHandler();
  // final bool _isSaved = true;
  int? userId;

  @override
  void initState() {
    _savePetty();
    super.initState();
  }

  List<PettyCashModel> _pettyCash = [
    PettyCashModel(0, t1Bill1.tr(), 1.0, 1, 0),
    /* //name: "1 Dollar",
      id: 1,
      name: t1Bill1.tr(),
      valueEn: 1.0,
      valueCo: 1000,
      quantity: 0,
    ),*/
    // PettyCashModel(1, t1Bill2.tr(), 2.0, 1000, 0),
    /* //name: "2 Dollar",
      id: 2,
      name: t1Bill2.tr(),
      valueEn: 2.0,
      valueCo: 2000,
      quantity: 0,
    ),*/
    PettyCashModel(2, t1Bill5.tr(), 5.0, 5, 0),
    /*  //name: "5 Dollar",
      id: 3,
      name: t1Bill5.tr(),
      valueEn: 5.0,
      valueCo: 5000,
      quantity: 0,
    ),*/
    PettyCashModel(3, t1Bill10.tr(), 10.0, 10, 0),
    /*//name: "10 Dollar",
      id: 4,
      name: t1Bill10.tr(),
      valueEn: 10.0,
      valueCo: 10000,
      quantity: 0,
    ),*/
    // PettyCashModel(4, t1Bill20.tr(), 20.0, 20000, 0),
    /* //name: "20 Dollar",
      id: 5,
      name: t1Bill20.tr(),
      valueEn: 20.0,
      valueCo: 20000,
      quantity: 0,
    ),*/
    PettyCashModel(5, t1Bill50.tr(), 50.0, 50, 0),
    /* //name: "50 Dollar",
      id: 6,
      name: t1Bill50.tr(),
      valueEn: 50.0,
      valueCo: 50000,
      quantity: 0,
    ),*/
    PettyCashModel(6, t1Bill100.tr(), 100.0, 100, 0),
    /*//name: "100 Dollar",
      id: 7,
      name: t1Bill100.tr(),
      valueEn: 100.0,
      valueCo: 100000,
      quantity: 0,
    ),*/
    PettyCashModel(7, t1Coin1.tr(), 0.01, 0.01, 0),
    /* //name: "1 Cent",
      id: 8,
      name: t1Coin1.tr(),
      valueEn: 0.01,
      valueCo: 50,
      quantity: 0,
    ),*/
    PettyCashModel(8, t1Coin5.tr(), 0.05, 0.05, 0),
    /*//name: "5 Cents",
      id: 9,
      name: t1Coin5.tr(),
      valueEn: 0.05,
      valueCo: 100,
      quantity: 0,
    ),*/
    PettyCashModel(9, t1Coin10.tr(), 0.1, 0.1, 0),
    /*//name: "10 Cents",
      id: 10,
      name: t1Coin10.tr(),
      valueEn: 0.1,
      valueCo: 200,
      quantity: 0,
    ),*/
    PettyCashModel(10, t1Coin25.tr(), 0.25, 0.25, 0),
    /* //name: "25 Cents",
      id: 11,
      name: t1Coin25.tr(),
      valueEn: 0.25,
      valueCo: 500,
      quantity: 0,
    ),*/
    // PettyCashModel(11, t1Coin50.tr(), 0.5, 1000, 0),
    /*//name: "50 Cents",
      id: 12,
      name: t1Coin50.tr(),
      valueEn: 0.5,
      valueCo: 1000,
      quantity: 0,
    ),*/
  ];

  //Modificado por codepaeza 04-04-2023
  double get totalEn =>
      _pettyCash.map((e) => e.totalEn).reduce((a, b) => a + b);

  double get totalCo =>
      _pettyCash.map((e) => e.totalCo).reduce((a, b) => a + b);

/*
  void changeLanguage() {
    setState(() {
      isEn=!isEn;
      isEn ? context.setLocale(const Locale('en')) : context.setLocale(const Locale('es'));
    });
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          t1CashEntry.tr(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.amber,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _savePetty();
          Navigator.pop(context);
        },
        icon: Icon(Icons.save),
        label: Text("\$$totalCo"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              DateFormat("yyyy-MM-dd").format(DateTime.now()),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: ListTile(
                      title: Text(
                        _pettyCash[index].name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          onChanged: (value) {
                            if (value == '') {
                              value = '0';
                            }
                            setState(() {
                              _pettyCash[index].quantity = int.parse(value);
                            });
                          },
                          decoration: InputDecoration(
                            hintText: t1EnterQuantity.tr(),
                            // labelText: "Quantity",
                            border: OutlineInputBorder(),
                          ),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      trailing: Text(_pettyCash[index].totalCo.toString()),
                    ),
                  ),
                );
              },
              itemCount: _pettyCash.length,
            ),
          ),
        ],
      ),
    );
  }

  _savePetty() async {
    for (int index = 0; index <= 11; index++) {
      var petty = PettyCashModel(
          _pettyCash[index].id!.toInt(),
          _pettyCash[index].name.toString(),
          _pettyCash[index].valueEn.toDouble(),
          _pettyCash[index].valueCo.toDouble(),
          _pettyCash[index].quantity.toInt());
      await _dbHandler.insertPettyAmounts(petty);
    }
  }
}
