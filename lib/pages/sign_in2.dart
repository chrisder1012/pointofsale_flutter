import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:zabor/config/config.dart';
import 'package:zabor/models/restaurant_open_close_time.dart';
import 'package:zabor/pages/restaurant_type.dart';
import 'package:zabor/utils/next_screen.dart';
import 'package:zabor/utils/t1_string.dart';

import '../blocs/sign_in_bloc.dart';
import '../db/database_handler.dart';
import '../models/restaurant.dart';
import '../models/tax.dart';
import '../models/user.dart';
import '../services/services.dart';
import '../utils/snacbar.dart';
import '../utils/utils.dart';
import 'dejavoo_setting_screen.dart';

class SignIn2Page extends StatefulWidget {
  const SignIn2Page({Key? key, required this.isFirst}) : super(key: key);

  final bool? isFirst;

  @override
  State<SignIn2Page> createState() => _SignIn2PageState();
}

class _SignIn2PageState extends State<SignIn2Page> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();

  var _userIdController = TextEditingController();
  var _passwordController = TextEditingController();
  var _pinController = TextEditingController();

  var signInStart = false;
  var signInComplete = false;

  List<User> _employeeList = [
    // User(
    //     id: 001,
    //     name: 'Rafael Torres',
    //     password: '123456',
    //     profileimage: 'person1.jpeg',
    //     restaurantId: 39),
    // User(
    //     id: 002,
    //     name: 'Yan Li',
    //     password: '222222',
    //     profileimage: 'person1.jpeg',
    //     restaurantId: 39),
  ];

  final Tax _tax = Tax(
    email: 'rtc@zaboreats.com',
    address: "Urb. Alturas de Peñuelas 1 Calle 7 F 37",
    contact: "1-939-242-3206",
    city: "Peñuelas, P.R. 00624",
    foodTax: "0",
    drinkTax: "0",
    grandTax: "0",
    deliveryCharge: "0",
    baseDeliveryDistance: 0,
    extraDeliveryCharge: 0.5,
    driver_fee: "0",
    fb_link: "https://www.facebook.com/zaboreats/",
    twitter_link: "https://twitter.com/ZaborEats",
    insta_link: "https://www.instagram.com/zaboreats/",
    created_date: "2020-03-19 11:47:18",
  );

  final restaurant = Restaurant(
    id: 39,
    name: 'Las Cuevas Spot',
    email: 'alfredo4740@gmail.com',
    description: 'Food truck de comida criolla',
    description_es: 'Food truck de comida criollas',
    status: 1,
    category: 48,
    subcategory: '',
    created_by: 110,
    restaurantpic: 'restaurantpic/restaurantImage-1676650375102.jpeg',
    city: "Peñuelas",
    address: "Carr 132 Inter 385\\",
    contact: "787-579-3208",
    website: '',
    latitude: '18.46643510',
    longitude: '-66.71756020',
    avg_cost: 10,
    claimed: 0,
    min_order_value: 0,
    max_order_value: 1000,
    cod: 1,
    stripe_acc: 'acct_1OuGiVFD69Yl4EaB',
    cancel_charge: 1,
    can_edit_pos: 1,
    can_edit_menu: 1,
    can_edit_reservation: 1,
    can_edit_order: 1,
    can_edit_discount: 1,
    created_at: "2019-12-20 00:56:28",
    ath_acc: "c6f6bf2c41da32b8796534646f65649d45322c19",
    ath_secret: "xjgvmqdx3/g2hj+8rt11zlppjydrmoqp7yduefo",
    stripe_fee: 5,
    convenience_fee_type: "2",
    convenience_fee: 4,
    food_tax: "6",
    drink_tax: "10.5",
    grand_tax: "1",
    delivery_charge: "0",
    base_delivery_distance: 0,
    driver_fee: "0",
    currency_code: "PESOS",
    imagesUploadedInfo:
        "{\"paymentCardImages\":[{\"imageFilename\":\"pmtCardImage-1-1671065462146.png\",\"paymentCardType\":\"VISA\"}]}",
    default_display_language_code: "es",
  );

  final resOpenCloseTime = ResOpenCloseTime(
    id: 1,
    res_id: 39,
    monopen_time: "01:00",
    monclose_time: "23:00",
    tueopen_time: "01:00",
    tueclose_time: "23:00",
    wedopen_time: "01:00",
    wedclose_time: "23:00",
    thuopen_time: "01:00",
    thuclose_time: "23:00",
    friopen_time: "01:00",
    friclose_time: "23:00",
    satopen_time: "01:00",
    satclose_time: "23:00",
    sunopen_time: "01:00",
    sunclose_time: "23:00",
    created_at: "2019-12-27 15:51:18",
  );

  User? _selectedUser;
  final DatabaseHandler _dbHandler = DatabaseHandler();
  String _pin = '';

  @override
  void initState() {
    //
    if (widget.isFirst == true) {
      // addRestTable();
      // addRestDiscount();
      // addRestMemberType();
      // addRestCustomers();
    }

    ///
    _loadUsers();

    /// Load restaurant
    _loadRestaurant();

    _loadResOpenCloseTime();

    ///
    _loadTax();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    if (isPortrait) {
      scaleWidth = width / Config().defaultWidth;
      scaleHeight = height / Config().defaultHeight;
    } else {
      scaleWidth = width / Config().defaultHeight;
      scaleHeight = height / Config().defaultWidth;
    }

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: Color.fromRGBO(231, 234, 238, 1),
        border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SizedBox(
        width: width,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Employee Login',
                        style: TextStyle(
                            color: Config().appColor,
                            fontSize: 48,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 32),
                      // Container(
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(8),
                      //     border: Border.all(color: Config().appColor),
                      //   ),
                      //   child: DropdownButton<User>(
                      //     borderRadius: BorderRadius.circular(8),
                      //     underline: SizedBox(),
                      //     itemHeight: 80,
                      //     value: _selectedUser,
                      //     items: _employeeList.map((item) {
                      //       return DropdownMenuItem<User>(
                      //         value: item,
                      //         // child: Text(item.name!),
                      //         child: Container(
                      //           width: isPortrait ? width / 2 : width / 3,
                      //           // height: 80,
                      //           margin: const EdgeInsets.symmetric(vertical: 8),
                      //           child: ListTile(
                      //             leading: CircleAvatar(
                      //               radius: 25,
                      //               backgroundImage: Image.asset(
                      //                       'assets/images/${item.profileimage}')
                      //                   .image,
                      //             ),
                      //             title: Text(item.name!),
                      //             subtitle: Text(
                      //                 '@${item.name?.toLowerCase().replaceAll(" ", "")}'),
                      //           ),
                      //         ),
                      //       );
                      //     }).toList(),
                      //     onChanged: (value) {
                      //       setState(() {
                      //         _selectedUser = value;
                      //       });
                      //     },
                      //   ),
                      // ),
                      const SizedBox(height: 32),
                      Text(
                        'Enter your PIN to validate yourself.',
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 16),
                      Pinput(
                        controller: _pinController,
                        length: 6,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        submittedPinTheme: submittedPinTheme,
                        // validator: (s) {
                        //   return s == '222222' ? null : 'Pin is incorrect';
                        // },
                        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                        showCursor: false,
                        obscureText: true,
                        useNativeKeyboard: false,
                        onCompleted: (pin) {
                          _pin = pin;
                        },
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: width / 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _numberButton(
                              1,
                              onPressed: (text) {
                                _input(text);
                              },
                            ),
                            _numberButton(
                              2,
                              onPressed: (text) {
                                _input(text);
                              },
                            ),
                            _numberButton(
                              3,
                              onPressed: (text) {
                                _input(text);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: width / 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _numberButton(
                              4,
                              onPressed: (text) {
                                _input(text);
                              },
                            ),
                            _numberButton(
                              5,
                              onPressed: (text) {
                                _input(text);
                              },
                            ),
                            _numberButton(
                              6,
                              onPressed: (text) {
                                _input(text);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: width / 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _numberButton(
                              7,
                              onPressed: (text) {
                                _input(text);
                              },
                            ),
                            _numberButton(
                              8,
                              onPressed: (text) {
                                _input(text);
                              },
                            ),
                            _numberButton(
                              9,
                              onPressed: (text) {
                                _input(text);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: width / 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            TextButton(
                              onPressed: () {},
                              child: Text(''),
                            ),
                            _numberButton(
                              0,
                              onPressed: (text) {
                                _input(text);
                              },
                            ),
                            TextButton(
                              onPressed: () {
                                final value = _pinController.text;
                                if (value.isNotEmpty) {
                                  _pinController.text =
                                      value.substring(0, value.length - 1);
                                }
                              },
                              child: Icon(
                                Icons.backspace_outlined,
                                color: Colors.black,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: isPortrait ? width / 2 : width / 3,
                        height: setScaleHeight(30),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Config().appColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            _selectedUser = _employeeList.first;
                            if (_selectedUser?.password != _pin) {
                              openSnacbar(
                                  context, 'Error: Password is incorrect');
                            } else {
                              /// Save user data to Shared Preference
                              _saveUserToSP().then((value) {
                                nextScreenCloseOthers(
                                    context, const RestaurantTypePage());
                              });
                            }
                          },
                          child: Text(
                            'Login',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      // SizedBox(
                      //   width: width / 3 * 2,
                      //   child: Padding(
                      //     padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      //     child: ElevatedButton(
                      //       onPressed: () {
                      //         _handleSignInwithemailPassword();
                      //       },
                      //       style: ElevatedButton.styleFrom(
                      //           shape: RoundedRectangleBorder(
                      //               borderRadius: BorderRadius.circular(80.0)),
                      //           padding: const EdgeInsets.all(0.0),
                      //           elevation: 4,
                      //           textStyle:
                      //               const TextStyle(color: Colors.white)),
                      //       child: Container(
                      //         decoration: BoxDecoration(
                      //           color: Config().appColor,
                      //           borderRadius:
                      //               BorderRadius.all(Radius.circular(80.0)),
                      //         ),
                      //         child: Center(
                      //           child: Padding(
                      //             padding: const EdgeInsets.all(18.0),
                      //             child: signInStart
                      //                 ? const CircularProgressIndicator(
                      //                     backgroundColor: Colors.white,
                      //                   )
                      //                 : /*const*/ Text(
                      //                     tr(t1SignIn),
                      //                     style: TextStyle(
                      //                         fontSize: 18,
                      //                         color: Colors.white),
                      //                     textAlign: TextAlign.center,
                      //                   ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(height: 20),
                      // /*const*/ Text(
                      //   tr(t1ForgotPassword),
                      //   style: TextStyle(fontSize: 16),
                      // ),
                      // const SizedBox(height: 16),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: <Widget>[
                      //     /*const*/ Text(
                      //       tr(t1DoNotHaveAccount),
                      //       style: TextStyle(fontSize: 18),
                      //     ),
                      //     Container(
                      //       margin: const EdgeInsets.only(left: 4),
                      //       child: GestureDetector(
                      //         child: /*const*/ Text((t1SignUp).tr(),
                      //             style: TextStyle(
                      //                 fontSize: 18.0,
                      //                 decoration: TextDecoration.underline,
                      //                 color: Config().appColor)),
                      //         onTap: () {
                      //           nextScreen(context, const SignUpPage());
                      //         },
                      //       ),
                      //     )
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberButton(int number,
      {required Function(String value) onPressed}) {
    return TextButton(
        onPressed: () => onPressed(number.toString()),
        child: Text(
          number.toString(),
          style: TextStyle(
              color: Colors.black, fontSize: 40, fontWeight: FontWeight.w500),
        ));
  }

  _input(String text) {
    final value = _pinController.text + text;
    _pinController.text = value;
  }

  /// Load users from db
  _loadUsers() async {
    var users = await _dbHandler.retrieveAllUsers();
    if (users.isNotEmpty) {
      _employeeList.addAll(users);
      setState(() {});
    }
  }

  /// Load tax from db
  _loadTax() async {
    var taxs = await _dbHandler.getTax();
    if (taxs.isEmpty) {
      await _dbHandler.insertTax(_tax.toJson());
    }
  }

  _loadRestaurant() async {
    _dbHandler.getRestaurant().then((value) {
      if (value.isEmpty) {
        _dbHandler.insertRestaurant(restaurant.toJson());
      } else {
        print('===== Rest Id: ${value.first.id} =====');
      }
    });
  }

  _loadResOpenCloseTime() async {
    _dbHandler.getResOpenCloseTime(39).then((value) {
      if (value.isEmpty) {
        _dbHandler.insertResOpenCloseTime(resOpenCloseTime.toJson());
      } else {
        print('===== ResOpenCloseTime Id: ${value.first.id} =====');
      }
    });
  }

  /// Save user data to sp
  Future<void> _saveUserToSP() async {
    final SignInBloc sb = Provider.of<SignInBloc>(context, listen: false);
    final sp = await SharedPreferences.getInstance();

    sp.setInt('user_id', _selectedUser!.id!);
    sp.setString('user_name', _selectedUser!.name!);
    sp.setString('user_email', _selectedUser!.email!);
    sp.setString('user_name', _selectedUser!.email!);
    sp.setString('profile_image', _selectedUser!.profileimage!);
    sp.setInt('rest_id', 39);
    sp.setBool('signed_in', true);

    sb.setUserId(_selectedUser!.id!);
    sb.setUserEmail(_selectedUser!.email!);
    sb.setUserName(_selectedUser!.name!);
  }

  _afterSignIn() async {
    var pref = await SharedPreferences.getInstance();
    var firstLaunch = pref.getBool('firstLaunch') ?? false;
    if (!firstLaunch) {
      pref.setBool("firstLaunch", true);
      nextScreenReplace(context, DejavooSettingScreen());
    } else {
      nextScreenCloseOthers(context, const RestaurantTypePage());
    }
  }

  gotoDejavooPage() {
    nextScreenReplace(context, DejavooSettingScreen());
  }

  Future<dynamic> _dislogforId() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return EnterRestId();
        });
  }

  _handleSignInwithemailPassword() async {
    final SignInBloc sb = Provider.of<SignInBloc>(context, listen: false);

    if (formKey.currentState!.validate()) {
      await _dislogforId();

      formKey.currentState!.save();
      FocusScope.of(context).requestFocus(FocusNode());

      await AppService().checkInternet().then((hasInternet) async {
        if (hasInternet == false) {
          openSnacbar(context, 'no internet');
        } else {
          setState(() {
            signInStart = true;
          });

          var email = _userIdController.text;
          var pass = _passwordController.text;
          sb.signInwithEmailPassword(email, pass).then((_) async {
            if (sb.hasError == false) {
              sb.saveDataToSP();
              sb.setSignIn();
              setState(() {
                signInComplete = true;
              });
              _afterSignIn();
            } else {
              setState(() {
                signInStart = false;
              });
              openSnacbar(context, sb.errorCode);
            }
          });
        }
      });
    }
  }
}

class EnterRestId extends StatefulWidget {
  @override
  _EnterRestIdState createState() => _EnterRestIdState();
}

class _EnterRestIdState extends State<EnterRestId> {
  TextEditingController _controller = TextEditingController();
  SharedPreferences? sharedPreferences;
  @override
  void initState() {
    super.initState();
    _getRestId();
  }

  Future<dynamic> _getRestId() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      Config.restaurantId = sharedPreferences?.getInt('rest_id') ?? null;
    });
    _controller =
        TextEditingController(text: Config.restaurantId?.toString() ?? '');
    _controller.addListener(_addListener);
  }

  //String restId = '2037';
  //Modificado por codepaeza 12-04-2023
  //String restId = '2062';
  //String restId= '39';
  String restId = '';
  void _addListener() {
    setState(() {
      restId = _controller.text;
    });
  }

  void _addRest() async {
    sharedPreferences!.setInt('rest_id', int.parse(restId));
    setState(() {
      Config.restaurantId = int.parse(restId);
    });
    Navigator.pop(context, restId);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: /*const*/ InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  hintText: tr(t1RestaurantId),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: restId == ''
                      ? null
                      : () {
                          _addRest();
                        },
                  child: /*const*/ Text(
                    tr(t1Done),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
