import 'package:flutter/material.dart';

class AppInkWell extends StatelessWidget {
  const AppInkWell({
    super.key,
    required this.onTap,
    required this.child,
    // this.hoverColor,
    // this.pressedColor,
    // this.onSecondaryTap,
  });

  final void Function()? onTap;
  final Widget child;
  // final void Function()? onSecondaryTap;
  // final Color? hoverColor;
  // final Color? pressedColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: child,
    );
  }
}
