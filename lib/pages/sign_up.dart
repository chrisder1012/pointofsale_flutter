import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:zabor/blocs/sign_in_bloc.dart';
import 'package:zabor/config/config.dart';
import 'package:zabor/utils/t1_string.dart';

import '../services/services.dart';
import '../utils/snacbar.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();

  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var nameController = TextEditingController();
  var confirmPasswordController = TextEditingController();

  bool signUpStart = false;
  bool signUpComplete = false;

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
                            Text(t1CreateAccount.tr(),
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
                    controller: nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      hintText: t1FullName.tr(),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        //return 'Enter name';
                        return t1EnterName.tr();
                      }
                      return null;
                    },
                  ),
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
                      hintText: t1Email,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        //return 'Enter email';
                        return t1EnterEmailSignUp.tr();
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
                      hintText: t1Password.tr(),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        //return 'Enter Password';
                        return t1EnterPassword.tr();
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: TextFormField(
                    controller: confirmPasswordController,
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
                      hintText: t1ConfirmPassword.tr(),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        //return 'Enter password again';
                        return t1EnterPasswordAgain.tr();
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
                      _handleSignUp();
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
                          child: signUpStart
                              ? const CircularProgressIndicator(
                                  backgroundColor: Colors.white,
                                )
                              : /*const*/ Text(
                                  t1SignUp.tr(),
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    /*const*/ Text(
                      t1AlreadyAccount.tr(),
                      style: TextStyle(fontSize: 18),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      child: GestureDetector(
                        child: /*const*/ Text(t1SignIn.tr(),
                            style: TextStyle(
                                fontSize: 18.0,
                                decoration: TextDecoration.underline,
                                color: Config().appColor)),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    )
                  ],
                ),
                Container(
                  alignment: Alignment.bottomLeft,
                  margin: const EdgeInsets.only(
                      top: 30, left: 16, right: 16, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Image.asset('assets/images/t3_ic_sign2.png',
                          height: 50, width: 70),
                      Container(
                          margin: const EdgeInsets.only(top: 25, left: 10),
                          child: Image.asset('assets/images/t3_ic_sign4.png',
                              height: 50, width: 70)),
                      Container(
                          margin: const EdgeInsets.only(top: 25, left: 10),
                          child: Image.asset('assets/images/t3_ic_sign3.png',
                              height: 50, width: 70)),
                      Image.asset('assets/images/t3_ic_sign1.png',
                          height: 80, width: 80),
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

  _handleSignUp() async {
    final SignInBloc sb = Provider.of<SignInBloc>(context, listen: false);

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      FocusScope.of(context).requestFocus(FocusNode());

      await AppService().checkInternet().then((hasInternet) async {
        if (hasInternet == false) {
          openSnacbar(context, 'no internet');
        } else {
          setState(() {
            signUpStart = true;
          });

          var email = emailController.text;
          var pass = passwordController.text;
          var name = nameController.text;

          sb.signUpwithEmailPassword(name, email, pass).then((_) async {
            if (sb.hasError == false) {
              setState(() {
                signUpComplete = true;
              });
              openSnacbar(
                  context,
                  //'Successfully registered account, Please go to SignIn page');
                  t1SuccessfullyRegistered.tr());
            } else {
              setState(() {
                signUpStart = false;
              });
              openSnacbar(context, sb.errorCode);
            }
          });
        }
      });
    }
  }
}
