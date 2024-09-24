import 'package:flutter/material.dart';

class OptionWidgetButton extends StatelessWidget {
  const OptionWidgetButton(
      {Key? key, this.onPressed, this.backgroundColor, this.text})
      : super(key: key);
  final String? text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        padding: MaterialStateProperty.all(EdgeInsets.zero),
        backgroundColor: MaterialStateProperty.all(backgroundColor),
      ),
      onPressed: onPressed,
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (Widget child, Animation<double> animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Text(
            text!,
            style: const TextStyle(fontSize: 30),
          ),
        ),
      ),
    );
  }
}
