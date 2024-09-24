import 'package:flutter/material.dart';

void openSnacbar(context, snacMessage, {Function()? onPressed}) {

  print(["snacMessage===9900:",snacMessage]);
  if(snacMessage!=null)
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Container(
        alignment: Alignment.centerLeft,
        height: 60,
        child: Text(
          snacMessage,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ),
      action: SnackBarAction(
        label: 'OK',
        textColor: Colors.blueAccent,
        onPressed: onPressed ?? () {},
      ),
    ),
  );
}
