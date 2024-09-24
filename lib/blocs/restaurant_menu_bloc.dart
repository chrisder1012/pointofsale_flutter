import 'package:flutter/cupertino.dart';
import 'package:zabor/config/json_group.dart';
import 'package:zabor/config/json_group_item.dart';
import 'package:zabor/models/customization.dart';
import 'package:zabor/models/group.dart';
import 'package:zabor/models/menu_item.dart';
import 'package:zabor/models/restaurant.dart';
import 'package:zabor/models/taxes.dart';

import '../api/my_api.dart';

class RestaurantMenuBloc extends ChangeNotifier {
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  List<Group>? _groups;
  List<Group>? get groups => _groups;

  List<Customization>? _customization;
  List<Customization>? get customization => _customization;

  Taxes? _taxes;
  Taxes? get taxes => _taxes;

  Responses? _res;
  Responses? get res => _res;

  var restDetail;

  Future restaurantMenu(id) async {
    try {
      var data = {
        'res_id': id,
      };

      print('restaurantMenu:::::: $id');

      var res = await CallApi().postGetDataWithToken(data, 'restaurant/menu/');
      Map<String, dynamic> body = res.data!;

      if (body['status']) {
        // Get group
        List<dynamic> snap = [];
        var data = body['data'];
        // print("Menu Data: ${data}");
        snap.addAll(data);
        _groups = snap.map((e) => Group.fromJson(e)).toList();

        // Get customizations
        var custom = body['customizations'];
        snap.clear();
        snap.addAll(custom);
        _customization = snap.map((e) => Customization.fromJson(e)).toList();

        // Restaurant
        _res = Responses.fromJson(body['res']);

        // Taxes
        _taxes = Taxes.fromJson(body['taxes']);

        _hasError = false;
        notifyListeners();
      } else {
        _hasError = true;
        _errorCode = body['msg'];
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
  }

  Future restaurantMenuByDB(id) async {
    try {
      var groups = menuGroups.map((e) => Group.fromJson(e)).toList();
      for (var group in groups) {
        var itemMaps =
            menuGroupItems.where((e) => e['group_id'] == group.id).toList();
        var items = itemMaps.map((e) => MItem.fromJson(e)).toList();
        group.items = [];
        group.items?.addAll(items);
      }
      var data = {
        'res_id': id,
      };

      print('restaurantMenu:::::: $id');

      var res = await CallApi().postGetDataWithToken(data, 'restaurant/menu/');
      Map<String, dynamic> body = res.data!;

      if (body['status']) {
        // Get group
        List<dynamic> snap = [];
        var data = body['data'];
        // print("Menu Data: ${data}");
        snap.addAll(data);
        _groups = snap.map((e) => Group.fromJson(e)).toList();

        // Get customizations
        var custom = body['customizations'];
        snap.clear();
        snap.addAll(custom);
        _customization = snap.map((e) => Customization.fromJson(e)).toList();

        // Restaurant
        _res = Responses.fromJson(body['res']);

        // Taxes
        _taxes = Taxes.fromJson(body['taxes']);

        _hasError = false;
        notifyListeners();
      } else {
        _hasError = true;
        _errorCode = body['msg'];
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
  }

  Future restaurantDetail(id) async {
    try {
      var data = {
        'res_id': id,
      };

      var res = await CallApi().postGetDataWithToken(data, 'restaurant-detail');
      Map<String, dynamic> body = res.data!;

      if (body['status']) {
        // Get group
        var data = body['data'];
        restDetail = data;
        _hasError = false;
        notifyListeners();
      } else {
        _hasError = true;
        _errorCode = body['msg'];
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
  }
}
