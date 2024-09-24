import 'package:easy_localization/easy_localization.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:zabor/config/config.dart';
import 'package:zabor/pages/print_register_page.dart';
import 'package:network_tools/network_tools.dart';
import 'package:zabor/utils/next_screen.dart';
import 'package:zabor/utils/snacbar.dart';

import '../models/cart.dart';

printKichen(BuildContext context, Cart cart, String categoryName) async {
  var ipList = await Config.getPrinters() ?? [];

  if (ipList.isEmpty) {
    openSnacbar(context, 'Please register printer', onPressed: () {
      nextScreen(context, const PrintRegisterPage());
    });
    return;
  }

  List<String> devices = [];
  var kitchenIp = ipList[1];
  var port = Config().portNumber;

  final String subnet = kitchenIp.substring(0, kitchenIp.lastIndexOf('.'));
  final stream = PortScanner.customDiscover(subnet, portList: [port]);

  stream.listen((event) {
    devices.add(event.internetAddress.address);
  })
    ..onDone(() async {
      if (devices.contains(kitchenIp)) {
        const PaperSize paper = PaperSize.mm80;
        final profile = await CapabilityProfile.load();
        final printer = NetworkPrinter(paper, profile);

        final PosPrintResult res = await printer.connect(kitchenIp, port: port);

        if (res == PosPrintResult.success) {
          // // DEMO RECEIPT
          await printKitchenReceipt(context, printer, cart, categoryName);
          // await printDemoReceipt(printer);
          // TEST PRINT
          // await testReceipt(printer);
          printer.disconnect();
        }
      } else {
        openSnacbar(context, 'Not found kitchen printer device');
      }
    })
    ..onError((dynamic e) {
      openSnacbar(context, e.toString());
    });
}

Future<void> printKitchenReceipt(
    context, NetworkPrinter printer, Cart cart, String catName) async {
  var dt = DateTime.now();
  var date = DateFormat('MM/dd/yyyy').format(dt);
  var time = DateFormat('HH:mm:ss').format(dt);

  printer.hr(ch: '=', linesAfter: 1);
  printer.row([
    PosColumn(text: date, width: 6),
    PosColumn(
        text: time, width: 6, styles: const PosStyles(align: PosAlign.right)),
  ]);
  for (var item in cart.cart!) {
    printer.text('${item.quantity}  X  ${item.itemName}');
  }
  printer.text(catName, styles: const PosStyles(align: PosAlign.center));
  printer.hr(ch: '=', linesAfter: 1);
  printer.text('Ticket #: ${cart.id}');
  printer.hr(ch: '=', linesAfter: 1);

  openSnacbar(context, 'Kitchen printer done');
}

Future<void> printDemoReceipt(NetworkPrinter printer) async {
  // Print image
  // final ByteData data = await rootBundle.load('assets/rabbit_black.jpg');
  // final Uint8List bytes = data.buffer.asUint8List();
  // var image = decodeImage(bytes);
  // // printer.image(image!);

  printer.text('GROCERYLY',
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
      linesAfter: 1);

  printer.text('889  Watson Lane',
      styles: const PosStyles(align: PosAlign.center));
  printer.text('New Braunfels, TX',
      styles: const PosStyles(align: PosAlign.center));
  printer.text('Tel: 830-221-1234',
      styles: const PosStyles(align: PosAlign.center));
  printer.text('Web: www.example.com',
      styles: const PosStyles(align: PosAlign.center), linesAfter: 1);

  printer.hr();
  printer.row([
    PosColumn(text: 'Qty', width: 1),
    PosColumn(text: 'Item', width: 7),
    PosColumn(
        text: 'Price',
        width: 2,
        styles: const PosStyles(align: PosAlign.right)),
    PosColumn(
        text: 'Total',
        width: 2,
        styles: const PosStyles(align: PosAlign.right)),
  ]);

  printer.row([
    PosColumn(text: '2', width: 1),
    PosColumn(text: 'ONION RINGS', width: 7),
    PosColumn(
        text: '0.99', width: 2, styles: const PosStyles(align: PosAlign.right)),
    PosColumn(
        text: '1.98', width: 2, styles: const PosStyles(align: PosAlign.right)),
  ]);
  printer.row([
    PosColumn(text: '1', width: 1),
    PosColumn(text: 'PIZZA', width: 7),
    PosColumn(
        text: '3.45', width: 2, styles: const PosStyles(align: PosAlign.right)),
    PosColumn(
        text: '3.45', width: 2, styles: const PosStyles(align: PosAlign.right)),
  ]);
  printer.row([
    PosColumn(text: '1', width: 1),
    PosColumn(text: 'SPRING ROLLS', width: 7),
    PosColumn(
        text: '2.99', width: 2, styles: const PosStyles(align: PosAlign.right)),
    PosColumn(
        text: '2.99', width: 2, styles: const PosStyles(align: PosAlign.right)),
  ]);
  printer.row([
    PosColumn(text: '3', width: 1),
    PosColumn(text: 'CRUNCHY STICKS', width: 7),
    PosColumn(
        text: '0.85', width: 2, styles: const PosStyles(align: PosAlign.right)),
    PosColumn(
        text: '2.55', width: 2, styles: const PosStyles(align: PosAlign.right)),
  ]);
  printer.hr();

  printer.row([
    PosColumn(
        text: 'TOTAL',
        width: 6,
        styles: const PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        )),
    PosColumn(
        text: '\$10.97',
        width: 6,
        styles: const PosStyles(
          align: PosAlign.right,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        )),
  ]);

  printer.hr(ch: '=', linesAfter: 1);

  printer.row([
    PosColumn(
        text: 'Cash',
        width: 8,
        styles:
            const PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
    PosColumn(
        text: '\$15.00',
        width: 4,
        styles:
            const PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
  ]);
  printer.row([
    PosColumn(
        text: 'Change',
        width: 8,
        styles:
            const PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
    PosColumn(
        text: '\$4.03',
        width: 4,
        styles:
            const PosStyles(align: PosAlign.right, width: PosTextSize.size2)),
  ]);

  printer.feed(2);
  printer.text('Thank you!',
      styles: const PosStyles(align: PosAlign.center, bold: true));

  final now = DateTime.now();
  final formatter = DateFormat('MM/dd/yyyy H:m');
  final String timestamp = formatter.format(now);
  printer.text(timestamp,
      styles: const PosStyles(align: PosAlign.center), linesAfter: 2);

  // Print QR Code from image
  // try {
  //   const String qrData = 'example.com';
  //   const double qrSize = 200;
  //   final uiImg = await QrPainter(
  //     data: qrData,
  //     version: QrVersions.auto,
  //     gapless: false,
  //   ).toImageData(qrSize);
  //   final dir = await getTemporaryDirectory();
  //   final pathName = '${dir.path}/qr_tmp.png';
  //   final qrFile = File(pathName);
  //   final imgFile = await qrFile.writeAsBytes(uiImg.buffer.asUint8List());
  //   final img = decodeImage(imgFile.readAsBytesSync());

  //   printer.image(img);
  // } catch (e) {
  //   debugPrint(e);
  // }

  // Print QR Code using native function
  // printer.qrcode('example.com');

  printer.feed(1);
  printer.cut();
}
