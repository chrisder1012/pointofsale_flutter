import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:stripe_terminal/stripe_terminal.dart';

class Config {
  final String appName = 'Zabor POS';
  final String splashIcon = 'assets/images/rest_6.jpg';
  final String supportEmail = 'mrblab24@gmail.com';
  final String privacyPolicyUrl = 'https://www.mrb-lab.com/privacy-policy';
  final String ourWebsiteUrl = 'https://www.mrb-lab.com';
  final String iOSAppId = '000000';
  final int portNumber = 7200;

  //social links
  static const String facebookPageUrl = 'https://www.facebook.com/mrblab24';
  static const String youtubeChannelUrl =
      'https://www.youtube.com/channel/UCnNr2eppWVVo-NpRIy1ra7A';
  static const String twitterUrl = 'https://twitter.com/FlutterDev';

  //app theme color
  final Color appColor = Colors.deepPurple;
  final Color kYellowColor = Colors.amber[100]!;
  final Color kGreyColor100 = Colors.grey[100]!;
  final Color kGreyColor200 = Colors.grey[400]!;
  final Color kBlackColor = Colors.black;
  final Color kBlackColor54 = Colors.black45;
  final Color kBlackColor38 = Colors.black38;
  final Color kWhiteColor = Colors.white;
  final Color kGreenColor = Colors.green;
  final Color kGrey = Colors.grey;

  //Intro images
  final String introImage1 = 'assets/images/news1.png';
  final String introImage2 = 'assets/images/news6.png';
  final String introImage3 = 'assets/images/news7.png';

  //animation files
  final String doneAsset = 'assets/animation_files/done.json';

  //Language Setup
  final List<String> languages = ['English', 'Spanish', 'Arabic'];

  //initial categories - 4 only (Hard Coded : which are added already on your admin panel)
  final List initialCategories = [
    'Entertainment',
    'Sports',
    'Politics',
    'Travel'
  ];

  final int tableStart = 101;
  final int tableCount = 50;
  final int guestNumber = 12;

  static int? restaurantId = 0;
  final String apiBaseUrl = 'https://api.zaboreats.com/';

  final double defaultWidth = 411.4285;
  final double defaultHeight = 866.2857;

  static String storeName = '';
  static String? address,
      contact,
      city,
      storeNameImage,
      foodTax,
      drinkTax,
      grandTax;

  // Member type
  final List memberTypes = [
    'Not Member',
    'Discount Card',
    'Member Card',
    'Reward Card',
  ];

  // Database
  final String dbName = 'zabor_pos.db';

  static void setPrinters(List<String> value) async {
    final pref = await SharedPreferences.getInstance();
    pref.setStringList(SharedPrefKeys.isPrinter, value);
  }

  static Future<List<String>?> getPrinters() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getStringList(SharedPrefKeys.isPrinter);
  }

  static Future<void> setBool(String key, bool value) async {
    final pref = await SharedPreferences.getInstance();
    pref.setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    final pref = await SharedPreferences.getInstance();
    return pref.getBool(key);
  }

  static void setTerminalLocation(String value) async {
    final pref = await SharedPreferences.getInstance();
    pref.setString(SharedPrefKeys.terminalLocation, value);
  }

  static Future<String?> getTerminalLocation() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(SharedPrefKeys.terminalLocation);
  }

  // static void setReaderType(DiscoveryMethod type) async {
  //   final pref = await SharedPreferences.getInstance();
  //   pref.setString(SharedPrefKeys.readerType, describeEnum(type));
  // }

  // static Future<DiscoveryMethod> getReaderType() async {
  //   final pref = await SharedPreferences.getInstance();
  //   return DiscoveryMethod.values.firstWhere(
  //     (e) => pref.getString(SharedPrefKeys.readerType) == describeEnum(e),
  //     orElse: () => DiscoveryMethod.internet,
  //   );
  // }
}

class SharedPrefKeys {
  static String userLoggedIn = "userLoggedIn";
  static String userAccessToken = "userAccessToken";
  static String userModel = "userModel";
  static String deviceToken = "deviceToken";
  static String lastOrderId = "lastOrderId";
  static String isPrinter = "isPrinter";
  static String terminalLocation = "terminalLocation";
  static String readerType = "readerType";
}
