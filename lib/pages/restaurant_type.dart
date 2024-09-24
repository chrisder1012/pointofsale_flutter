// import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:zabor/blocs/homepage_restaurant_bloc.dart';
import 'package:zabor/blocs/restaurant_menu_bloc.dart';
import 'package:zabor/blocs/sign_in_bloc.dart';
// import 'package:zabor/pages/home.dart';
import 'package:zabor/pages/petty_cash.dart';
import 'package:zabor/pages/petty_cash_query.dart';
import 'package:zabor/pages/print_register_page.dart';
// import 'package:zabor/pages/sign_in.dart';
import 'package:zabor/utils/location_service.dart';
import 'package:zabor/utils/next_screen.dart';
import 'package:zabor/utils/t1_string.dart';
import 'package:zabor/pages/petty_cash_close_page.dart';
import 'package:zabor/pages/petty_cash_close_query.dart';
// import 'package:zabor/pages/petty_cash.dart';
// import 'package:zabor/models/petty_cash.dart';

// import '../api/my_api.dart';
import '../config/config.dart';
// import '../db/database_handler.dart';
import '../services/services.dart';
import '../utils/snacbar.dart';
// import '../utils/location_service.dart';
import '../utils/utils.dart';
import 'home.dart';
import 'shift_open_close.dart';
import 'sign_in2.dart';
// import 'shift_open_close.dart';

class RestaurantTypePage extends StatefulWidget {
  const RestaurantTypePage({Key? key}) : super(key: key);

  @override
  State<RestaurantTypePage> createState() => _RestaurantTypePageState();
}

class _RestaurantTypePageState extends State<RestaurantTypePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var _width = 0.0;
  var _height = 0.0;

  bool _isLoading = false;

  int _shiftId = 0;

  final List<String> _restaurants = [
    t1FoodTruck.tr(),
  ];

  @override
  void initState() {
    /// Get current shift id
    _getCurrentShiftId();

    // _handleGetCurrentShift();
    _getRestDetails();
    super.initState();
  }

  Future<dynamic> _getRestDetails() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      Config.restaurantId = sharedPreferences.getInt('rest_id') ?? null;
    });
    _getRemoteRestDetails();
  }

  _getRemoteRestDetails() async {
    final RestaurantMenuBloc rmb =
        Provider.of<RestaurantMenuBloc>(context, listen: false);

    await AppService().checkInternet().then((hasInternet) async {
      if (hasInternet == false) {
        openSnacbar(context, 'no internet');
      } else {
        rmb.restaurantDetail(Config.restaurantId).then((_) async {
          if (rmb.hasError == false) {
            var decode = rmb.restDetail;
            var mapData = decode['restaurantDetail'];
            print('::::::: ======> rest name ${mapData[0]['restaurant_name']}');

            setState(() {
              Config.city = mapData[0]['city']?.toString() ?? '';
              Config.contact = mapData[0]['contact']?.toString() ?? '';
              Config.address = mapData[0]['address']?.toString() ?? '';
              Config.storeName = mapData[0]['restaurant_name'];
              Config.storeNameImage = mapData[0]['restaurantpic'];
              Config.foodTax = mapData[0]['food_tax'];
              Config.drinkTax = mapData[0]['drink_tax'];
              Config.grandTax = mapData[0]['grand_tax'];
            });
            print('_getRemoteRestDetails ======== end');
          } else {
            openSnacbar(context, rmb.errorCode);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final restBloc = Provider.of<HomepageRestaurantBloc>(context);
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;

    isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final SignInBloc sb = context.read<SignInBloc>();

    if (isPortrait) {
      scaleWidth = _width / Config().defaultWidth;
      scaleHeight = _height / Config().defaultHeight;
    } else {
      scaleWidth = _width / Config().defaultHeight;
      scaleHeight = _height / Config().defaultWidth;
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Config().appColor,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            t1Restaurants.tr(),
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              nextScreen(context, const PrintRegisterPage());
            },
            icon: Icon(
              Icons.print,
              size: setScaleHeight(15),
            ),
          ),
          Container(
            width: setScaleHeight(50),
            color: Config().appColor,
            child: Center(
              child: PopupMenuButton(
                itemBuilder: ((context) {
                  return [
                    PopupMenuItem<int>(
                      value: 0,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(t1Logout.tr()),
                      ),
                    ),
                    PopupMenuItem<int>(
                      value: 1,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(t1cashirIn.tr()),
                      ),
                    ),
                    PopupMenuItem<int>(
                      value: 2,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(t1cashirOut.tr()),
                      ),
                    ),
                    PopupMenuItem<int>(
                      value: 3,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Ver Arqueo Inicio'),
                      ),
                    ),
                    PopupMenuItem<int>(
                      value: 4,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Ver Arqueo Cierre'),
                      ),
                    ),
                  ];
                }),
                icon: Icon(
                  Icons.more_vert,
                  size: setScaleHeight(15),
                ),
                onSelected: (index) {
                  if (index == 0) {
                    sb.signout();
                    nextScreenCloseOthers(
                        context, const SignIn2Page(isFirst: false));
                  } else if (index == 1) {
                    nextScreen(context, const PettyCash());
                  } else if (index == 2) {
                    nextScreen(context, const PettyCashClose());
                  } else if (index == 3) {
                    nextScreen(context, const PettyCashQuery());
                  } else if (index == 4) {
                    nextScreen(context, const PettyCashCloseQuery());
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : IgnorePointer(
              ignoring: restBloc.loadingShiftStatus,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _body(restBloc),
                  if (restBloc.loadingShiftStatus) CircularProgressIndicator(),
                ],
              ),
            ),
    );
  }

  _body(HomepageRestaurantBloc restBloc) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const ScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isPortrait ? 3 : 6,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.4,
      ),
      itemCount: _restaurants.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () async {
            final userId = context.read<SignInBloc>().uid;
            // restBloc.checkShiftStatus(userId, context);
            final shiftId = restBloc.shiftId ?? 0;
            if (shiftId > 0) {
              restBloc.checkShiftStatusFromDB(
                  context, userId!, shiftId, Config.restaurantId!);
            } else {
              SharedPreferences localStorage =
                  await SharedPreferences.getInstance();
              final int? shiftId0 = await nextScreen(
                  context,
                  ShiftOpenClose(
                    restId: Config.restaurantId!,
                    isOpen: true,
                    cashierId: userId!,
                  ));
              if (shiftId0 != null) {
                _shiftId = shiftId0;
                print('shift idddd here????? $shiftId0');
                localStorage.setInt('shiftId', shiftId0);

                // Mou inserted
                nextScreen(context, const PettyCash());
                //

                nextScreen(context, const HomePage());
              }
            }
          },
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                    color: Config().kBlackColor54,
                    blurRadius: 5,
                    spreadRadius: 0.5),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Stack(
                children: [
                  // Align(
                  //   alignment: Alignment.topCenter,
                  //   child: Container(
                  //     margin: EdgeInsets.only(bottom: setScaleHeight(26)),
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(5),
                  //       image: DecorationImage(
                  //         fit: BoxFit.fill,
                  //         image: AssetImage('assets/images/rest_6.jpg'),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  Align(
                    // alignment: Alignment.bottomCenter,
                    alignment: Alignment.center,
                    child: Text(
                      _restaurants[index],
                      style: TextStyle(
                        fontSize: setFontSize(16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Handle to cart
  _handleGetRestaurant() async {
    final HomepageRestaurantBloc hrb =
        Provider.of<HomepageRestaurantBloc>(context, listen: false);

    await AppService().checkInternet().then((hasInternet) async {
      if (hasInternet == false) {
        openSnacbar(context, 'no internet');
      } else {
        var pos = await determinePosition();
        hrb.getRestaurant(pos).then((_) async {
          if (hrb.hasError == false) {
          } else {
            openSnacbar(context, hrb.errorCode);
          }
          // setState(() {
          // });
        });
      }
    });
  }

  // Handle to get current shift
  _handleGetCurrentShift() async {
    final HomepageRestaurantBloc hrb =
        Provider.of<HomepageRestaurantBloc>(context, listen: false);

    await AppService().checkInternet().then((hasInternet) async {
      if (hasInternet == false) {
        openSnacbar(context, 'no internet');
      } else {
        setState(() {
          _isLoading = true;
        });
        hrb.getCurrentShift().then((_) async {
          if (hrb.hasError == false) {
          } else {
            openSnacbar(context, hrb.errorCode);
          }

          setState(() {
            _isLoading = false;
          });
        });
      }
    });
  }

  /// Get current shift id
  _getCurrentShiftId() async {
    final sp = await SharedPreferences.getInstance();
    var restId = sp.getInt('rest_id') ?? 0;
    Config.restaurantId = restId;

    final HomepageRestaurantBloc hrb =
        Provider.of<HomepageRestaurantBloc>(context, listen: false);
    _shiftId = await hrb.getCurrentShiftFromDB(restId);
    hrb.setShiftId(_shiftId);
    setState(() {});
    print('===== Current shift Id: $_shiftId =====');
  }
}
