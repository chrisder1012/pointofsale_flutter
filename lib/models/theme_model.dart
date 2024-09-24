import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/config.dart';

class ThemeModel {
  final ThemeData _lightBase = ThemeData.light();
  ThemeData get lightMode => _lightBase.copyWith(
        primaryColor: Config().appColor,
        iconTheme: _lightBase.iconTheme.copyWith(color: Colors.grey[900]),
        scaffoldBackgroundColor: Colors.grey[300],
        primaryColorDark: Colors.grey[800],
        primaryColorLight: Colors.white,
        secondaryHeaderColor: Colors.grey[600],
        shadowColor: Colors.grey[200],
        backgroundColor: Colors.white,
        appBarTheme: _lightBase.appBarTheme.copyWith(
          color: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          actionsIconTheme: IconThemeData(color: Colors.white),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          toolbarTextStyle: TextTheme(
            headline6: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.6,
              wordSpacing: 1,
              color: Colors.white,
            ),
          ).bodyText2,
          titleTextStyle: TextTheme(
            headline6: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.6,
              wordSpacing: 1,
              color: Colors.white,
            ),
          ).headline6,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
        textTheme: _lightBase.textTheme.copyWith(
          subtitle1: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.grey[900],
          ),
        ),
        bottomNavigationBarTheme: _lightBase.bottomNavigationBarTheme.copyWith(
          backgroundColor: Colors.white,
          selectedItemColor: Config().appColor,
          unselectedItemColor: Colors.grey[500],
        ),
        colorScheme: _lightBase.colorScheme.copyWith(
          secondary: Config().appColor,
          brightness: Brightness.light,
        ),
        popupMenuTheme: _lightBase.popupMenuTheme
            .copyWith(textStyle: TextStyle(fontSize: 20, color: Colors.black)),
      );

  final ThemeData _darkBase = ThemeData.dark();

  ThemeData get darkMode => _darkBase.copyWith(
        primaryColor: Config().appColor,
        iconTheme: _darkBase.iconTheme.copyWith(color: Colors.white),
        scaffoldBackgroundColor: const Color(0xff303030),
        primaryColorDark: Colors.grey[300],
        primaryColorLight: Colors.grey[800],
        secondaryHeaderColor: Colors.grey[400],
        shadowColor: const Color(0xff282828),
        backgroundColor: Colors.grey[900],
        appBarTheme: _darkBase.appBarTheme.copyWith(
          color: Colors.grey[900],
          elevation: 0,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          actionsIconTheme: const IconThemeData(color: Colors.white),
          systemOverlayStyle: SystemUiOverlayStyle.light,
          toolbarTextStyle: const TextTheme(
            headline6: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              letterSpacing: -0.6,
              wordSpacing: 1,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ).bodyText2,
          titleTextStyle: const TextTheme(
            headline6: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              letterSpacing: -0.6,
              wordSpacing: 1,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ).headline6,
        ),
        textTheme: _darkBase.textTheme.copyWith(
          subtitle1: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        snackBarTheme: _darkBase.snackBarTheme.copyWith(
          behavior: SnackBarBehavior.floating,
        ),
        bottomNavigationBarTheme: _darkBase.bottomNavigationBarTheme.copyWith(
          backgroundColor: Colors.grey[900],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey[500],
        ),
        colorScheme: _lightBase.colorScheme.copyWith(
          secondary: Config().appColor,
          brightness: Brightness.dark,
        ),
      );
}
