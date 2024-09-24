import 'package:flutter/cupertino.dart';
import 'package:zabor/models/rest_table_section.dart';

import '../api/my_api.dart';

class RestTableSectionBloc extends ChangeNotifier {
  List<RestTableSection> _tables = [];
  List<RestTableSection> get tables => _tables;

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  Future getTableByRestId(String restaurantId) async {
    try {
      var data = {
        "restro_id": restaurantId,
      };
      var res =
          await CallApi().postGetDataWithToken(data, 'getrestrotablebyid');
      Map<String, dynamic> body = res.data!;

      if (res.statusCode == 200) {
        if (body['status']) {
          var d = body['data']['table_list'];

          List<dynamic> snap = [];
          snap.addAll(d);
          _tables = snap.map((e) => RestTableSection.fromJson(e)).toList();
          _tables.sort(((a, b) => int.parse(a.numberOfTable!)
              .compareTo(int.parse(b.numberOfTable!))));

          _hasError = false;
          notifyListeners();
        } else {
          _hasError = true;
          _errorCode = body['msg'];
          notifyListeners();
        }
      } else if (res.statusCode == 401) {
        _hasError = true;
        _errorCode = body['message'];
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
  }

  Future addTable(String restaurantId, String name, String number) async {
    try {
      var data = {
        "restro_id": restaurantId,
        "section_name": name,
        "no_of_table": number,
      };
      var res = await CallApi().postGetDataWithToken(data, 'addrestrotable');
      Map<String, dynamic> body = res.data!;

      if (res.statusCode == 200) {
        if (body['status'] && body['msg'] == 'Inserted Successfully') {
          var d = body['table_list'];

          List<dynamic> snap = [];
          snap.addAll(d);
          _tables.clear();
          _tables = snap.map((e) => RestTableSection.fromJson(e)).toList();
          _tables.sort(((a, b) => int.parse(a.numberOfTable!)
              .compareTo(int.parse(b.numberOfTable!))));

          _hasError = false;
          notifyListeners();
        } else {
          _hasError = true;
          _errorCode = body['msg'];
          notifyListeners();
        }
      } else if (res.statusCode == 401) {
        _hasError = true;
        _errorCode = body['message'];
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
  }

  Future deleteAllTable(String restaurantId) async {
    try {
      var data = {
        "restro_id": restaurantId,
      };
      var res =
          await CallApi().postGetDataWithToken(data, 'deleteallrestrotables');
      Map<String, dynamic> body = res.data!;

      if (res.statusCode == 200) {
        if (body['status'] &&
            body['msg'] ==
                'restaurant sections are cleared and tables are deleted') {
          _hasError = false;
          notifyListeners();
        } else {
          _hasError = true;
          _errorCode = body['msg'];
          notifyListeners();
        }
      } else {
        _hasError = true;
        _errorCode = body['message'];
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
  }

  Future deleteTable(int restaurantId, int tableId) async {
    try {
      var data = {
        "restro_id": restaurantId,
        "table_id": tableId,
      };
      var res =
          await CallApi().postGetDataWithToken(data, 'deleterestrotablebyid');
      Map<String, dynamic> body = res.data!;

      if (res.statusCode == 200) {
        if (body['status']) {
          _hasError = false;
          notifyListeners();
        } else {
          _hasError = true;
          _errorCode = body['msg'];
          notifyListeners();
        }
      } else {
        _hasError = true;
        _errorCode = body['message'];
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
  }

  Future updateTable(
      String restaurantId, String tableId, String name, String number) async {
    try {
      var data = {
        "restro_id": restaurantId,
        "section_id": tableId,
        "section_name": name,
        "no_of_table": number,
      };
      var res = await CallApi().postGetDataWithToken(data, 'updaterestrotable');
      Map<String, dynamic> body = res.data!;

      if (res.statusCode == 200) {
        if (body['status'] && body['msg'] == 'Inserted Successfully') {
          var d = body['table_list'];

          List<dynamic> snap = [];
          snap.addAll(d);
          _tables.clear();
          _tables = snap.map((e) => RestTableSection.fromJson(e)).toList();
          _tables.sort(((a, b) => int.parse(a.numberOfTable!)
              .compareTo(int.parse(b.numberOfTable!))));

          _hasError = false;
          notifyListeners();
        } else {
          _hasError = true;
          _errorCode = body['msg'];
          notifyListeners();
        }
      } else if (res.statusCode == 401) {
        _hasError = true;
        _errorCode = body['message'];
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
  }
}
