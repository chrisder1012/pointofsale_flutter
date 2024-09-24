import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/my_api.dart';
import '../config/config.dart';
import '../db/database_handler.dart';
import '../pages/home.dart';
import '../pages/petty_cash.dart';
import '../pages/shift_open_close.dart';
import '../utils/next_screen.dart';

class HomepageRestaurantBloc extends ChangeNotifier {
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  int? _shiftId;
  int? get shiftId => _shiftId;

  bool loadingShiftStatus = false;

  Future getRestaurant(Position position) async {
    try {
      var data = {
        "latitude": "${position.latitude}",
        "longitude": "${position.longitude}",
      };
      var res =
          await CallApi().postGetDataWithToken(data, 'homepageRestaurant');
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

  Future getCurrentShift() async {
    try {
      var res = await CallApi()
          .getDataWithToken('get-current-shift?resId=${Config.restaurantId}');

      if (res.statusCode == 200) {
        final currentShiftData = res.data ?? {};
        _shiftId = currentShiftData['data']['id'];
      } else {
        _hasError = true;
        _errorCode = res.statusMessage;
      }
      notifyListeners();
    } catch (e) {
      print(e);
      _hasError = true;
      _errorCode = "Something went wrong";
      notifyListeners();
    }
  }

  checkShiftStatus(cashierId, BuildContext context) async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    try {
      loadingShiftStatus = true;
      notifyListeners();
      var res = await CallApi().getDataWithToken(
          'shift-status?resId=${Config.restaurantId}&cashierId=$cashierId&shiftId=$_shiftId',
          userId: cashierId);
      final shiftStausData = res.data ?? {};
      print(shiftStausData);
      loadingShiftStatus = false;
      notifyListeners();
      final data = shiftStausData['data'];
      if (data['shift_status'] != 'opened') {
        final int? shiftId0 = await nextScreen(
            context,
            ShiftOpenClose(
              restId: Config.restaurantId!,
              isOpen: true,
              cashierId: cashierId,
            ));
        if (shiftId0 != null) {
          _shiftId = shiftId0;
          print('shift idddd here????? $shiftId0');
          localStorage.setInt('shiftId', shiftId0);

          // Mou inserted
          // nextScreen(context, const PettyCash());
          //

          nextScreen(context, const HomePage());
        }
      } else {
        _shiftId = data['shift_id'];

        nextScreen(context, const HomePage());
      }
    } catch (e) {
      loadingShiftStatus = false;
      notifyListeners();

      final int? shiftId0 = await nextScreen(
          context,
          ShiftOpenClose(
            restId: Config.restaurantId!,
            isOpen: true,
            cashierId: cashierId,
          ));
      if (shiftId0 != null) {
        _shiftId = shiftId0;
        localStorage.setInt('shiftId', shiftId0);

        // Mou inserted
        // nextScreen(context, const PettyCash());
        //

        nextScreen(context, const HomePage());
      }
      print(e);
    }
  }

  Future<int> getCurrentShiftFromDB(int restId) async {
    DatabaseHandler _dbHandler = DatabaseHandler();
    var shiftId = await _dbHandler.getCurrenShiftId(restId);

    notifyListeners();

    return shiftId;
  }

  Future<String> checkShiftStatusFromDB(BuildContext context, int cashierId,
      int shiftId, int restaurantId) async {
    DatabaseHandler _dbHandler = DatabaseHandler();
    SharedPreferences localStorage = await SharedPreferences.getInstance();

    var ret =
        await _dbHandler.checkShiftStatus(restaurantId, cashierId, shiftId);

    notifyListeners();

    if (ret == 'Closed') {
      final int? shiftId0 = await nextScreen(
          context,
          ShiftOpenClose(
            restId: Config.restaurantId!,
            isOpen: true,
            cashierId: cashierId,
          ));
      if (shiftId0 != null) {
        _shiftId = shiftId0;
        print('shift idddd here????? $shiftId0');
        localStorage.setInt('shiftId', shiftId0);

        // Mou inserted
        // nextScreen(context, const PettyCash());
        //

        nextScreen(context, const HomePage());
      }
    } else if (ret == 'Opened') {
      nextScreen(context, const HomePage());
    }

    return ret;
  }

  void setShiftId(int shiftId) {
    _shiftId = shiftId;
  }
}
