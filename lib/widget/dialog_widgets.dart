import 'package:flutter/material.dart';
import 'package:zabor/config/config.dart';

import '../utils/utils.dart';

dialogTitle(double width, {required String? title}) {
  return Container(
    height: setScaleHeight(40),
    width: width,
    padding: const EdgeInsets.all(8.0),
    color: Config().appColor,
    alignment: Alignment.center,
    child: Text(
      title!,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: setFontSize(20),
      ),
    ),
  );
}

dialogText({required String? name}) {
  return Container(
    color: Colors.white,
    padding: const EdgeInsets.all(8),
    child: Row(
      children: [
        Text(
          name!,
          style: TextStyle(
            fontSize: setFontSize(14),
          ),
        ),
      ],
    ),
  );
}

dialogController(
    {required TextEditingController? editingController,
    String? hintText,
    bool? isNumber = false}) {
  return Container(
    color: Colors.white,
    padding: const EdgeInsets.all(8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: editingController,
          keyboardType:
              isNumber == true ? TextInputType.number : TextInputType.text,
          // decoration: InputDecoration(),
          decoration: InputDecoration(hintText: hintText ?? ''),
          autofocus: true,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Cannot be empty';
            }
            return null;
          },
        ),
      ],
    ),
  );
}

dialogButton(
    {required String? name,
    Color? backgroundColor,
    required Function()? onClick}) {
  return Expanded(
    child: GestureDetector(
      onTap: onClick,
      child: Container(
        color: backgroundColor,
        height: setScaleHeight(40),
        child: Center(
          child: Text(
            name!,
            style: TextStyle(
              fontSize: setFontSize(16),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ),
  );
}

dialogCart({
  required String? time,
  required String? note,
  required String? price,
  required Function()? closeItemClick,
  required Function()? itemClick,
}) {
  return GestureDetector(
    onTap: itemClick,
    child: Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.white,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note!,
                style: TextStyle(
                  fontSize: setFontSize(14),
                ),
              ),
              Text(
                time!,
                style: TextStyle(
                  fontSize: setFontSize(12),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            price!,
            style: TextStyle(
              fontSize: setFontSize(14),
            ),
          ),
          IconButton(
            onPressed: closeItemClick,
            icon: Icon(
              Icons.close,
              color: Colors.grey,
              size: setScaleHeight(20),
            ),
          ),
        ],
      ),
    ),
  );
}
