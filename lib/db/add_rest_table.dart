import '../config/config.dart';
import '../models/rest_table.dart';
import 'database_handler.dart';

Future<int> addRestTable() async {
  var dbHandler = DatabaseHandler();

  List<RestTable> tbs = [];
  var sequence = Config().tableCount;
  for (int i = 0; i < sequence; i++) {
    var restTb = RestTable(
      name: (Config().tableStart + i).toString(),
      tableGroupId: 1,
      sequence: sequence - i,
    );
    tbs.add(restTb);
  }
  return await dbHandler.insertRestTable(tbs);
}
