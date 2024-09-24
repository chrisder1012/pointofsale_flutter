import 'package:flutter/material.dart';

import '../utils/utils.dart';

topbarItem(
    {required String? title,
    required Color? bgColor,
    required Function()? onTap}) {
  return Expanded(
    flex: 1,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        color: bgColor,
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title!,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isPortrait ? setFontSize(8) : setFontSize(15),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
