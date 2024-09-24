import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zabor/models/user.dart';

import '../api/my_api.dart';

class SignInBloc extends ChangeNotifier {
  SignInBloc() {
    checkSignIn();
    initPackageInfo();
  }

  final GoogleSignIn _googlSignIn = GoogleSignIn();

  final bool _guestUser = false;
  bool get guestUser => _guestUser;

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  User? _user;
  User? get user => _user;

  String? _name;
  String? get name => _name;

  int? _uid;
  int? get uid => _uid;

  String? _token;
  String? get token => _token;

  String? _email;
  String? get email => _email;

  String? _imageUrl;
  String? get imageUrl => _imageUrl;

  String? _signInProvider;
  String? get signInProvider => _signInProvider;

  String? timestamp;

  String _appVersion = '0.0';
  String get appVersion => _appVersion;

  String _packageName = '';
  String get packageName => _packageName;

  void initPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _appVersion = packageInfo.version;
    _packageName = packageInfo.packageName;
    notifyListeners();
  }

  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googlSignIn.signIn();
    if (googleUser != null) {
      // try {
      //   final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      //   final AuthCredential credential = GoogleAuthProvider.credential(
      //     accessToken: googleAuth.accessToken,
      //     idToken: googleAuth.idToken,
      //   );

      //   User userDetails = (await _firebaseAuth.signInWithCredential(credential)).user!;

      //   this._name = userDetails.displayName;
      //   this._email = userDetails.email;
      //   this._imageUrl = userDetails.photoURL;
      //   this._uid = userDetails.uid;
      //   this._signInProvider = 'google';

      //   _hasError = false;
      //   notifyListeners();
      // } catch (e) {
      //   _hasError = true;
      //   _errorCode = e.toString();
      //   notifyListeners();
      // }
    } else {
      _hasError = true;
      notifyListeners();
    }
  }

  Future signInwithFacebook() async {
    // User currentUser;
    // final LoginResult facebookLoginResult = await FacebookAuth.instance.login(permissions: ['email', 'public_profile']);
    // if(facebookLoginResult.status == LoginStatus.success){
    //   final _accessToken = await FacebookAuth.instance.accessToken;
    //   if(_accessToken != null){
    //     try{
    //       final AuthCredential credential = FacebookAuthProvider.credential(_accessToken.token);
    //       final User user = (await _firebaseAuth.signInWithCredential(credential)).user!;
    //       assert(user.email != null);
    //       assert(user.displayName != null);
    //       assert(!user.isAnonymous);
    //       await user.getIdToken();
    //       currentUser = _firebaseAuth.currentUser!;
    //       assert(user.uid == currentUser.uid);

    //       this._name = user.displayName;
    //       this._email = user.email;
    //       this._imageUrl = user.photoURL;
    //       this._uid = user.uid;
    //       this._signInProvider = 'facebook';

    //       _hasError = false;
    //       notifyListeners();
    //     }catch(e){
    //       _hasError = true;
    //       _errorCode = e.toString();
    //       notifyListeners();
    //     }

    //   }
    // }else{
    //   _hasError = true;
    //   _errorCode = 'cancel or error';
    //   notifyListeners();
    // }
  }

  Future signUpwithEmailPassword(name, userEmail, userPassword) async {
    try {
      var data = {
        'name': name,
        'email': userEmail,
        'password': userPassword,
        'role': 'user'
      };

      var res = await CallApi().postData(data, 'registration/');
      Map<String, dynamic> body = res.data!;

      if (body['status']) {
        _hasError = false;
        notifyListeners();
      } else {
        _hasError = true;
        _errorCode = body['errors'][0]['msg'];
        notifyListeners();
      }
    } catch (e) {
      _hasError = true;
      _errorCode = e.toString();
      notifyListeners();
    }
  }

  Future signInwithEmailPassword(userEmail, userPassword) async {
    try {
      var data = {
        'email': userEmail,
        'password': userPassword,
      };

      var res = await CallApi().postData(data, 'cashier/login/');
      Map<String, dynamic> body = res.data!;

      if (body['status']) {
        saveUserToSP(body['data']['user']);
        _user = User.fromJson(body['data']['user']);
        _token = body['data']['token'];
        _email = _user!.email;
        _name = _user!.name;
        _uid = _user!.id;

        _signInProvider = 'email';

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

  Future saveUserToSP(var user) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();

    await sp.setString('user', json.encode(user));
  }

  Future getUserFromSp() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    dynamic user = json.decode(sp.getString('user')!);
    _user = User.fromJson(user);
    notifyListeners();
  }

  Future saveDataToSP() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString('token', _token!);
    await sp.setString('email', _email!);
    await sp.setString('username', _name!);
    await sp.setInt('uid', _uid!);
  }

  Future getDataFromSp() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _token = sp.getString('token');
    _email = sp.getString('email');
    _name = sp.getString('username');
    _uid = sp.getInt('uid');
    notifyListeners();
  }

  signout() {
    clearAllData();
    _isSignedIn = false;
    notifyListeners();
  }

  Future clearAllData() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
  }

  Future userSignout() async {
    var data = {};

    var res = await CallApi().postGetDataWithToken(data, 'logout/');
    Map<String, dynamic> body = res.data!;

    if (res.statusCode == 200) {
      _hasError = false;
      notifyListeners();
    } else {
      _hasError = true;
      _errorCode = body['msg'];
      notifyListeners();
    }
  }

  Future afterUserSignOut() async {
    await userSignout().then((value) async {
      await clearAllData();
      _isSignedIn = false;
      notifyListeners();
    });
  }

  Future setSignIn() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool('signed_in', true);
    _isSignedIn = true;
    notifyListeners();
  }

  void checkSignIn() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    _isSignedIn = sp.getBool('signed_in') ?? false;
    notifyListeners();
  }

  setUserId(int userId) {
    _uid = userId;
  }

  setUserEmail(String email) {
    _email = email;
  }

  setUserName(String name) {
    _name = name;
  }
}
