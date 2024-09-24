import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:zabor/config/config.dart';
import 'package:zabor/pages/restaurant_type.dart';
import 'package:zabor/pages/sign_up.dart';
import 'package:zabor/utils/next_screen.dart';
import 'package:zabor/utils/t1_string.dart';

import '../blocs/sign_in_bloc.dart';
import '../services/services.dart';
import '../utils/snacbar.dart';
import 'dejavoo_setting_screen.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key, required this.isFirst}) : super(key: key);

  final bool? isFirst;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();

  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  var signInStart = false;
  var signInComplete = false;

  @override
  void initState() {
    //
    if (widget.isFirst == true) {
      // addRestTable();
      // addRestDiscount();
      // addRestMemberType();
      // addRestCustomers();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: (MediaQuery.of(context).size.height) / 3.5,
                  child: Stack(
                    children: <Widget>[
                      Image.asset('assets/images/ic_background_1.png',
                          fit: BoxFit.fill,
                          width: MediaQuery.of(context).size.width),
                      Container(
                        margin: const EdgeInsets.only(left: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: /*const*/ <Widget>[
                            Text(t1Zabro.tr(),
                                style: TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.topRight,
                  margin: const EdgeInsets.only(right: 45),
                  transform: Matrix4.translationValues(0.0, -40.0, 0.0),
                  child: Image.asset('assets/images/t3_ic_icon.png',
                      height: 70, width: 70),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      hintText: t1Email.tr(),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return t1EnterEmail.tr();
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      hintText: tr(t1Password),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return tr(t1EnterPassword);
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: ElevatedButton(
                    onPressed: () {
                      _handleSignInwithemailPassword();
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(80.0)),
                        padding: const EdgeInsets.all(0.0),
                        elevation: 4,
                        textStyle: const TextStyle(color: Colors.white)),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: <Color>[
                          Color(0xFF673AB7),
                          Color(0xFF947ac3),
                          // Color(0xFFfc4a1a),
                          // Color(0xFFf7b733),
                        ]),
                        borderRadius: BorderRadius.all(Radius.circular(80.0)),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: signInStart
                              ? const CircularProgressIndicator(
                                  backgroundColor: Colors.white,
                                )
                              : /*const*/ Text(
                                  tr(t1SignIn),
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                /*const*/ Text(
                  tr(t1ForgotPassword),
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    /*const*/ Text(
                      tr(t1DoNotHaveAccount),
                      style: TextStyle(fontSize: 18),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      child: GestureDetector(
                        child: /*const*/ Text((t1SignUp).tr(),
                            style: TextStyle(
                                fontSize: 18.0,
                                decoration: TextDecoration.underline,
                                color: Config().appColor)),
                        onTap: () {
                          nextScreen(context, const SignUpPage());
                        },
                      ),
                    )
                  ],
                ),
                Container(
                  alignment: Alignment.bottomLeft,
                  margin: const EdgeInsets.only(
                      top: 50, left: 16, right: 16, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Image.asset('assets/images/t3_ic_sign2.png',
                              height: 50, width: 70),
                          Container(
                            margin: const EdgeInsets.only(top: 25, left: 10),
                            child: Image.asset('assets/images/t3_ic_sign4.png',
                                height: 50, width: 70),
                          ),
                        ],
                      ),
                      Image.asset(
                        'assets/images/t3_ic_sign1.png',
                        height: 80,
                        width: 80,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
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

          var email = emailController.text;
          var pass = passwordController.text;
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
