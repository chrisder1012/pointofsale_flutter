import 'package:flutter/material.dart';
// import 'package:jwt_decode/jwt_decode.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zabor/pages/dejavoo_setting_screen.dart';
import 'package:zabor/pages/onboarding_screen.dart';
import 'package:zabor/pages/restaurant_type.dart';
import 'package:zabor/pages/sign_in.dart';

import '../blocs/sign_in_bloc.dart';
import '../config/config.dart';
import '../utils/next_screen.dart';
import 'sign_in2.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  afterSplash() async {
    final SignInBloc sb = context.read<SignInBloc>();
    await Future.delayed(const Duration(milliseconds: 1500));
    // await sb.getDataFromSp();
    // if (sb.token == null) {
    //   gotoOnboardingPage();
    // } else {
    //   var pref = await SharedPreferences.getInstance();
    //   var firstLaunch = pref.getBool('firstLaunch') ?? false;
    //   if (!firstLaunch) {
    //     pref.setBool("firstLaunch", true);
    //     gotoDejavooPage();
    //   } else {
    //     gotoHomePage();
    //   }
    // }
    var pref = await SharedPreferences.getInstance();
    var firstLaunch = pref.getBool('firstLaunch') ?? false;
    if (!firstLaunch) {
      pref.setBool("firstLaunch", true);
      gotoOnboardingPage();
    } else {
      nextScreenReplace(context, const SignIn2Page(isFirst: true));
    }
  }

  gotoDejavooPage() {
    nextScreenReplace(context, DejavooSettingScreen());
  }

  gotoHomePage() {
    final SignInBloc sb = context.read<SignInBloc>();
    if (sb.isSignedIn == true) {
      sb.getDataFromSp();
      sb.getUserFromSp();
    }
    nextScreenReplace(context, const RestaurantTypePage());
  }

  gotoOnboardingPage() {
    nextScreenReplace(context, OnBoardingScreen());
    // nextScreenReplace(context, const SignIn2Page(isFirst: true));
  }

  @override
  void initState() {
    afterSplash();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Center(
            child: Image(
          image: AssetImage(Config().splashIcon),
          fit: BoxFit.contain,
        )));
  }
}
