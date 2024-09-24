import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zabor/blocs/add_to_cart_bloc.dart';
import 'package:zabor/blocs/basket_bloc.dart';
import 'package:zabor/blocs/close_order_bloc.dart';
import 'package:zabor/blocs/creditcard_bloc.dart';
import 'package:zabor/blocs/homepage_restaurant_bloc.dart';
import 'package:zabor/blocs/offer_bloc.dart';
import 'package:zabor/blocs/order_bloc.dart';
import 'package:zabor/blocs/payout_bloc.dart';
import 'package:zabor/blocs/place_order_bloc.dart';
import 'package:zabor/blocs/printer_bloc.dart';
import 'package:zabor/blocs/refund_bloc.dart';
import 'package:zabor/blocs/rest_table_section_bloc.dart';
import 'package:zabor/blocs/restaurant_menu_bloc.dart';
import 'package:zabor/blocs/tax_bloc.dart';

import 'blocs/dejavoo_terminal_bloc.dart';
import 'blocs/sign_in_bloc.dart';
import 'blocs/theme_bloc.dart';
import 'models/theme_model.dart';
import 'pages/splash.dart';

import 'dart:io';

// Louismuniz@gmail.com
//  joshua3758
Future<void> main() async {
  //Bloque de código adicionado por codepaeza para error en vencimiento certificado SSL pagina web API´S
  // Add this line before making any network requests
  // HttpClient().badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  HttpOverrides.global = MyHttpOverrides();
  // runApp(const MyApp());
  // Your code for network requests goes here

  WidgetsFlutterBinding.ensureInitialized();

  ByteData data =
      await PlatformAssetBundle().load('assets/lets-encrypt-r3.pem');
  SecurityContext.defaultContext
      .setTrustedCertificatesBytes(data.buffer.asUint8List());

  ///
  var prefs = await SharedPreferences.getInstance();
  String locale = prefs.getString('locale') ?? 'en';

  await EasyLocalization.ensureInitialized();

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://f14a796f5b51467dba7c3f8441e4c21d@o960068.ingest.sentry.io/6640061';
      options.tracesSampleRate = .5;
    },
    appRunner: () => runApp(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('es')],
        path: 'assets/translations',
        fallbackLocale: Locale(locale),
        // startLocale: const Locale('en'),
        useOnlyLangCode: true,
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
      SystemUiOverlay.bottom, //This line is used for showing the bottom bar
    ]);
    return ChangeNotifierProvider<ThemeBloc>(
      create: (_) => ThemeBloc(),
      child: Consumer<ThemeBloc>(
        builder: (_, mode, child) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<SignInBloc>(
                create: (context) => SignInBloc(),
              ),
              ChangeNotifierProvider<RestaurantMenuBloc>(
                create: (context) => RestaurantMenuBloc(),
              ),
              ChangeNotifierProvider<AddToCartBloc>(
                create: (context) => AddToCartBloc(),
              ),
              ChangeNotifierProvider<TaxBloc>(
                create: (context) => TaxBloc(),
              ),
              ChangeNotifierProvider<BasketBloc>(
                create: (context) => BasketBloc(),
              ),
              ChangeNotifierProvider<OfferBloc>(
                create: (context) => OfferBloc(),
              ),
              ChangeNotifierProvider<PlaceOrderBloc>(
                create: (context) => PlaceOrderBloc(),
              ),
              ChangeNotifierProvider<CloseOrderBloc>(
                create: (context) => CloseOrderBloc(),
              ),
              ChangeNotifierProvider<HomepageRestaurantBloc>(
                create: (context) => HomepageRestaurantBloc(),
              ),
              ChangeNotifierProvider<OrderBloc>(
                create: (context) => OrderBloc(),
              ),
              ChangeNotifierProvider<RestTableSectionBloc>(
                create: (context) => RestTableSectionBloc(),
              ),
              ChangeNotifierProvider<PrinterBloc>(
                create: (context) => PrinterBloc(),
              ),
              ChangeNotifierProvider<CreditCardBloc>(
                create: (context) => CreditCardBloc(),
              ),
              ChangeNotifierProvider<PayoutBloc>(
                create: (context) => PayoutBloc(),
              ),
              ChangeNotifierProvider<RefundBloc>(
                create: (context) => RefundBloc(),
              ),
              ChangeNotifierProvider<DejavooTerminalBloc>(
                create: (context) => DejavooTerminalBloc(),
              ),
            ],
            child: MaterialApp(
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              locale: context.locale,
              theme: ThemeModel().lightMode,
              darkTheme: ThemeModel().darkMode,
              themeMode:
                  mode.darkTheme == true ? ThemeMode.dark : ThemeMode.light,
              debugShowCheckedModeBanner: false,
              home: const SplashPage(),
            ),
          );
        },
      ),
    );
  }
}

//Bloque de código adicionado por codepaeza para error en vencimiento certificado SSL pagina web API´S
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
