import 'package:flutter/material.dart';

class ElevatedButtonWidget extends StatelessWidget {
  final Widget child;
  final bool showProgressIndicator;
  final double? height, width, borderWidth, elevation;
  final double borderRadius;
  final Function()? onPressed;
  final EdgeInsetsGeometry? margin, padding;
  final Color? backgroundColor, borderSide;
  final double loadingSize;

  const ElevatedButtonWidget(
      {required this.child,
      this.width,
      this.height,
      this.borderWidth = 0.0,
      this.elevation,
      this.borderRadius = 2.0,
      this.showProgressIndicator = false,
      required this.onPressed,
      this.backgroundColor = Colors.transparent,
      this.borderSide = Colors.transparent,
      this.margin,
      this.padding,
      this.loadingSize = 30});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? 52,
      margin: margin,
      decoration: BoxDecoration(
          color: onPressed == null ? null : backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius)),
      child: AbsorbPointer(
        absorbing: showProgressIndicator,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: padding,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius)),
            side: BorderSide(
                color: borderSide ?? Colors.transparent,
                width: borderWidth ?? 0),
            elevation: 0,
          ),
          onPressed: onPressed,
          child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (Widget child, Animation<double> animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: showProgressIndicator
                  ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Padding(
                      padding: padding ?? EdgeInsets.zero,
                      child: child,
                    )),
        ),
      ),
    );
  }
}
