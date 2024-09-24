import 'package:flutter/material.dart';

import '../utils/utils.dart';

topbarIconItem(
    {required Color? bgColor,
    required IconData? iconData,
    required Function()? onPressed}) {
  return Container(
    width: isPortrait ? setScaleHeight(40) : setScaleHeight(50),
    color: bgColor,
    child: Center(
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          iconData,
          color: Colors.black,
          size: setScaleHeight(20),
        ),
      ),
    ),
  );
}
