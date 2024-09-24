// import 'dart:async';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:lottie/lottie.dart';
// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';
// import 'package:stripe_terminal/stripe_terminal.dart';
// import 'package:zabor/api/my_api.dart';
// import 'package:zabor/config/config.dart';
// import 'package:zabor/models/cart.dart';
// import 'package:zabor/pages/payment_method.dart';
// import 'package:zabor/utils/next_screen.dart';

// enum TerminalState {
//   initlizingStripe,
//   noLocation,
//   searchingDevice,
//   connectingReader,
//   creatingPayment,
//   collectingPaymentMethod,
//   capturingPaymentMethod,
//   cancelingPaymentMethod,
// }

// class StripePaymentIntentResponse {
//   final bool success;
//   final StripePaymentIntent paymentIntent;

//   StripePaymentIntentResponse(this.success, this.paymentIntent);
//   static StripePaymentIntentResponse fromJson(Map data) {
//     return StripePaymentIntentResponse(
//       data["success"],
//       StripePaymentIntent.fromMap(data["data"]),
//     );
//   }
// }

// class PayUsingTerminal extends StatefulWidget {
//   final Cart cart;
//   const PayUsingTerminal({
//     Key? key,
//     required this.cart,
//   }) : super(key: key);

//   @override
//   State<PayUsingTerminal> createState() => _PayUsingTerminalState();
// }

// class _PayUsingTerminalState extends State<PayUsingTerminal> {
//   late StripeTerminal terminal;
//   TerminalState state = TerminalState.initlizingStripe;
//   final CallApi _paymentApi = CallApi('https://api.zaboreats.com/pmt/');
//   @override
//   void dispose() {
//     _timer?.cancel();
//     for (var element in _subs) {
//       element.cancel();
//     }
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     _initStripeTerminal();
//   }

//   String? locationId;
//   List<StripeReader> _readers = [];
//   StripeReader? connectedReader;
//   _initStripeTerminal() async {
//     locationId = await Config.getTerminalLocation();
//     if (locationId == null) {
//       setState(() {
//         state = TerminalState.noLocation;
//       });
//       return _showSnackBar(
//         "No Location saved on settings, visit settings to add terminal and come back to checkout",
//       );
//     }
//     setState(() {
//       state = TerminalState.initlizingStripe;
//     });

//     terminal = await StripeTerminal.getInstance(fetchToken: _getToken);
//     _subs.add(
//       terminal.onNativeLogs.listen((event) {
//         Sentry.addBreadcrumb(
//           Breadcrumb(message: event.message),
//         );
//       }),
//     );
//     connectedReader = await terminal.fetchConnectedReader();
//     setState(() {
//       _checkConnection();
//     });
//     if (connectedReader == null) {
//       _discoverReaders();
//     } else {
//       _startPaymentFlow();
//     }
//   }

//   Timer? _timer;

//   _checkConnection() {
//     _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
//       connectedReader = await terminal.fetchConnectedReader();
//       if (mounted) setState(() {});
//     });
//   }

//   final List<StreamSubscription> _subs = [];

//   DiscoveryMethod? method;
//   _discoverReaders() async {
//     method = await Config.getReaderType();
//     _subs.add(
//       terminal
//           .discoverReaders(
//         DiscoverConfig(
//           discoveryMethod: method!,
//           locationId: method == DiscoveryMethod.internet ? locationId : null,
//           simulated: kDebugMode,
//         ),
//       )
//           .listen(
//         (event) {
//           setState(() {
//             state = TerminalState.searchingDevice;
//             _readers = event;
//           });
//         },
//       ),
//     );
//   }

//   _startPaymentFlow() async {
//     setState(() {
//       state = TerminalState.creatingPayment;
//     });

//     Map data = {
//       "description":
//           "Payment for an order of cart ${widget.cart.id} by user id ${widget.cart.userId}",
//       "currency": "USD",
//       "amount": (widget.cart.total! * 100).toStringAsFixed(0),
//       "captureMethod": "manual",
//       "paymentMethodTypes": ["card_present"],
//       "currentLocationId": locationId,
//       "loggedInUser_Id": widget.cart.userId,
//       "currentReaderId": connectedReader?.serialNumber,
//     };

//     var res =
//         await _paymentApi.postData(data, 'create-terminal-payment-intent');
//     Map<String, dynamic> body = res.data!;

//     if (body["success"]) {
//       intent = StripePaymentIntent.fromMap(body["data"]);
//       _capturePaymentMethod();
//     }
//   }

//   _capturePaymentMethod() async {
//     await terminal
//         .setReaderDisplay(
//       ReaderDisplay(
//         type: DisplayType.cart,
//         cart: DisplayCart(
//           currency: "USD",
//           lineItems: widget.cart.cart!
//               .map(
//                 (e) => DisplayLineItem(
//                   description: e.itemName!,
//                   quantity: e.quantity!,
//                   amount: (e.itemPrice! * 100).round(),
//                 ),
//               )
//               .toList(),
//           tax: (widget.cart.totalTax * 100).round(),
//           total: (widget.cart.total! * 100).round(),
//         ),
//       ),
//     )
//         .catchError((e, s) {
//       Sentry.captureException(e, stackTrace: s);
//     });
//     setState(() {
//       state = TerminalState.collectingPaymentMethod;
//     });
//     terminal.collectPaymentMethod(intent!.clientSecret!).then((intent) {
//       _confirmPaymentIntent();
//     }).catchError((e) {
//       if (e is PlatformException) {
//         _showSnackBar(e.message ?? "Something went wrong");
//       } else {
//         _showSnackBar("Something went wrong");
//       }
//     });
//   }

//   StripePaymentIntent? intent;

//   _confirmPaymentIntent() async {
//     setState(() {
//       state = TerminalState.capturingPaymentMethod;
//     });
//     Map data = {
//       "paymentIntentId": intent!.id,
//       "captureMethod": "manual",
//       "paymentMethodTypes": ["card_present"],
//       "currentLocationId": locationId,
//       "loggedInUser_Id": widget.cart.userId,
//       "currentReaderId": connectedReader?.serialNumber,
//     };

//     var res =
//         await _paymentApi.postData(data, 'capture-terminal-payment-intent');
//     Map<String, dynamic> body = res.data!;
//     if (body["success"]) {
//       intent = StripePaymentIntent.fromMap(body["data"]);
//       Navigator.pop(context, intent);
//     }
//   }

//   _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior: SnackBarBehavior.floating,
//         backgroundColor: Colors.red,
//         duration: const Duration(seconds: 5),
//       ),
//     );
//   }

//   Future<String> _getToken() async {
//     var res = await _paymentApi.postData({}, 'terminal-connection-token');
//     Map<String, dynamic> body = res.data!;
//     return body["data"]["secret"];
//   }

//   String? serialNumber;
//   Widget getStatus() {
//     TextStyle textStyle = const TextStyle(
//       fontWeight: FontWeight.bold,
//       fontSize: 25,
//     );
//     switch (state) {
//       case TerminalState.noLocation:
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(
//               MdiIcons.emoticonSad,
//               size: 100,
//               color: Colors.amber,
//             ),
//             const SizedBox(height: 30),
//             Text(
//               "No Terminal Device Configured",
//               style: textStyle,
//             ),
//             TextButton.icon(
//               onPressed: () async {
//                 bool? saved = await nextScreen(
//                   context,
//                   const PaymentConfigPage(),
//                 );
//                 if (saved != null) {
//                   _initStripeTerminal();
//                 }
//               },
//               icon: const Icon(MdiIcons.cog),
//               label: const Text("Configure"),
//             )
//           ],
//         );
//       case TerminalState.initlizingStripe:
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Lottie.asset(
//               "assets/lottie/network_call.json",
//               width: MediaQuery.of(context).size.width / 2,
//             ),
//             Text(
//               "Preparing terminal",
//               style: textStyle,
//             )
//           ],
//         );
//       case TerminalState.searchingDevice:
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Lottie.asset(
//               "assets/lottie/searching.json",
//               width: MediaQuery.of(context).size.width / 2,
//             ),
//             if (_readers.isEmpty)
//               Text(
//                 "Searching for terminals",
//                 style: textStyle,
//               )
//             else
//               Text(
//                 "Select a reader to connect to it",
//                 style: textStyle,
//               ),
//           ],
//         );
//       case TerminalState.connectingReader:
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Lottie.asset(
//               "assets/lottie/connecting.json",
//               width: MediaQuery.of(context).size.width / 2,
//             ),
//             Text(
//               "Connecting to the reader with serial number $serialNumber",
//               style: textStyle,
//             )
//           ],
//         );
//       case TerminalState.creatingPayment:
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Lottie.asset(
//               "assets/lottie/network_call.json",
//               width: MediaQuery.of(context).size.width / 2,
//             ),
//             Text(
//               "Preparing the payment",
//               style: textStyle,
//             )
//           ],
//         );
//       case TerminalState.collectingPaymentMethod:
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Lottie.asset(
//               "assets/lottie/swipe_card.json",
//               width: MediaQuery.of(context).size.width / 2,
//             ),
//             Text(
//               "Please read the payment method",
//               style: textStyle,
//             )
//           ],
//         );

//       case TerminalState.capturingPaymentMethod:
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Lottie.asset(
//               "assets/lottie/network_call.json",
//               width: MediaQuery.of(context).size.width / 2,
//             ),
//             Text(
//               "Processing the payment",
//               style: textStyle,
//             )
//           ],
//         );
//       case TerminalState.cancelingPaymentMethod:
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Lottie.asset(
//               "assets/lottie/network_call.json",
//               width: MediaQuery.of(context).size.width / 2,
//             ),
//             Text(
//               "Cancelling the payment",
//               style: textStyle,
//             )
//           ],
//         );
//       default:
//         return Text(
//           describeEnum(state).toUpperCase(),
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 50,
//           ),
//         );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Pay using register"),
//         backgroundColor: Colors.teal,
//         toolbarHeight: 100,
//         iconTheme: const IconThemeData(color: Colors.black, size: 50),
//         leadingWidth: 100,
//         centerTitle: true,
//         titleTextStyle: const TextStyle(
//           color: Colors.black,
//           fontSize: 20,
//           fontWeight: FontWeight.w600,
//         ),
//         actions: [
//           Container(
//             width: 150,
//             color: Colors.orange,
//             child: IconButton(
//               onPressed: () async {
//                 bool? saved = await nextScreen(
//                   context,
//                   const PaymentConfigPage(),
//                 );
//                 if (saved != null) {
//                   _initStripeTerminal();
//                 }
//               },
//               icon: const Icon(MdiIcons.cog),
//             ),
//           )
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (state == TerminalState.searchingDevice) ...[
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   "Select Readers",
//                   style: Theme.of(context).textTheme.titleLarge,
//                 ),
//               ),
//               ..._readers.map(
//                 (e) => ListTile(
//                     title: Text(
//                       e.label ?? describeEnum(e.deviceType).toUpperCase(),
//                     ),
//                     subtitle: Text(e.serialNumber),
//                     onTap: () async {
//                       setState(() {
//                         state = TerminalState.connectingReader;
//                       });

//                       bool connected = false;
//                       if (method == DiscoveryMethod.internet) {
//                         connected = await terminal
//                             .connectToInternetReader(e.serialNumber);
//                       } else if (method == DiscoveryMethod.bluetooth) {
//                         setState(() {
//                           serialNumber = e.serialNumber;
//                         });
//                         connected = await terminal.connectBluetoothReader(
//                           e.serialNumber,
//                           locationId: locationId,
//                         );
//                       } else {
//                         _showSnackBar("Unsupported reader type");
//                       }
//                       if (connected) {
//                         connectedReader = await terminal.fetchConnectedReader();
//                         setState(() {});
//                         await _startPaymentFlow();
//                       }
//                     }),
//               )
//             ],
//             if (connectedReader != null) ...[
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   "Connected Reader",
//                   style: Theme.of(context).textTheme.titleLarge,
//                 ),
//               ),
//               ListTile(
//                 title: Text(
//                   connectedReader!.label ??
//                       describeEnum(connectedReader!.deviceType).toUpperCase(),
//                 ),
//                 subtitle: Text(connectedReader!.serialNumber),
//                 tileColor: Colors.green.withOpacity(.4),
//               ),
//             ],
//             Expanded(
//               child: Center(
//                 child: getStatus(),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
