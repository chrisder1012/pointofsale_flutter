import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:zabor/models/petty_cash.dart';
// import 'package:zabor/utils/t1_string.dart';
// import 'package:zabor/pages/petty_cash.dart';
import '../db/database_handler.dart';
import 'package:flutter/rendering.dart';
// import 'package:zabor/utils/next_screen.dart';

class PettyCashQuery extends StatefulWidget {
  const PettyCashQuery({Key? key}) : super(key: key);

  @override
  State<PettyCashQuery> createState() => _PettyCashQueryState();
}

class _PettyCashQueryState extends State<PettyCashQuery> {
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); //Adicionado codepaeza 22/05/2023
  List<PettyCashModel> pettyCashModel = [];

  bool isEN = true;

  //Adicionado codepaeza 18/05/2023
  final DatabaseHandler _dbHandler = DatabaseHandler();
  // final bool _isSaved = true;
  int? userId;

  //Modificado por codepaeza 04-04-2023
  double get totalEn =>
      pettyCashModel.map((e) => e.totalEn).reduce((a, b) => a + b);

  double get totalCo =>
      pettyCashModel.map((e) => e.totalCo).reduce((a, b) => a + b);

  void conditionNull() {
    if (pettyCashModel.length == 0) {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    conditionNull();
    showData();
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
          'Consulta Arqueo Inicio',
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
              itemCount:
                  (pettyCashModel.isNotEmpty) ? pettyCashModel.length : 0,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: ListTile(
                      title: Text(
                        pettyCashModel[index].name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          pettyCashModel[index].quantity.toString(),
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

  Future showData() async {
    await _dbHandler.initializeDB();
    pettyCashModel = await _dbHandler.retirevePettyAmounts();
    setState(() {
      pettyCashModel = pettyCashModel;
    });
  }
}
