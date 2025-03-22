import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final Widget? child;

  const CustomButton({
    required this.text, super.key,
    this.onPressed,
    this.padding,
    this.child,
    this.borderRadius = 8.0,
    this.backgroundColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      ),
      onPressed: onPressed,
      child: child ??  Text(
        text,
        style: textStyle ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }
}
