import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    Key? key,
    this.backgroundColor,
    required this.title,
    required this.onPressed,
  }) : super(key: key);

  final Color? backgroundColor;
  final String title;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    Color backColor = backgroundColor ?? Colors.orange;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(0),
          backgroundColor: backColor,
          minimumSize: const Size(double.infinity, 120),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 30,
            color:
                backColor.computeLuminance() < .5 ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
