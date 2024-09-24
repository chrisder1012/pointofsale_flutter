import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:zabor/models/petty_cash_close.dart';
// import 'package:zabor/utils/t1_string.dart';
// import 'package:zabor/pages/petty_cash_close_page.dart';

import '../db/database_handler.dart';
import 'package:flutter/rendering.dart';
// import 'package:zabor/utils/next_screen.dart';

class PettyCashCloseQuery extends StatefulWidget {
  const PettyCashCloseQuery({Key? key}) : super(key: key);

  @override
  State<PettyCashCloseQuery> createState() => _PettyCashCloseQueryState();
}

class _PettyCashCloseQueryState extends State<PettyCashCloseQuery> {
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); //Adicionado codepaeza 22/05/2023
  List<PettyCashCloseModel> pettyCashCloseModel = [];

  bool isEN = true;

  //Adicionado codepaeza 18/05/2023
  final DatabaseHandler _dbHandler = DatabaseHandler();
  // final bool _isSaved = true;
  int? userId;

  //Modificado por codepaeza 04-04-2023
  double get totalEnClose =>
      pettyCashCloseModel.map((e) => e.totalEnClose).reduce((a, b) => a + b);

  double get totalCoClose =>
      pettyCashCloseModel.map((e) => e.totalCoClose).reduce((a, b) => a + b);

  void conditionNull() {
    if (pettyCashCloseModel.isEmpty) {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    conditionNull();
    showDataClose();
    super.initState();
  }

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
          //t1CashEntry.tr(),
          'Consulta Arqueo Cierre',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.amber,
      ),
      floatingActionButton: FloatingActionButton.extended(
        //onPressed: () {
        //Navigator.pop(context);
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.save),
        label: Text("\$$totalCoClose"),
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
              itemCount: (pettyCashCloseModel.isNotEmpty)
                  ? pettyCashCloseModel.length
                  : 0,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: ListTile(
                      title: Text(
                        pettyCashCloseModel[index].nameClose,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          pettyCashCloseModel[index].quantityClose.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future showDataClose() async {
    await _dbHandler.initializeDB();
    pettyCashCloseModel = await _dbHandler.retirevePettyCloseAmounts();
    setState(() {
      pettyCashCloseModel = pettyCashCloseModel;
    });
  }
}
