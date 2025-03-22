import 'package:flutter/material.dart';

class ReusableTextFormField extends StatelessWidget {
  final String hintText;
  final Color borderColor;
  final double borderRadius;
  final double height;
  final double? width; // Optional width parameter.
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final Color cursorColor;
  final bool enabled;
  final bool obscureText;

  // Removed 'const' keyword since we're using runtime values.
  const ReusableTextFormField({
    super.key,
    this.hintText = 'Enter text',
    this.borderColor = Colors.black,
    this.borderRadius = 30,
    this.height = 54,
    this.width,
    this.controller,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    Color? cursorColor,
  })  : cursorColor = cursorColor ?? Colors.black;

  @override
  Widget build(BuildContext context) {
    // Compute final width at runtime.
    final double finalWidth = width ?? MediaQuery.sizeOf(context).width * 0.9;
    return SizedBox(
      height: height,
      width: finalWidth,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enableSuggestions: false,
        enabled: enabled,
        autocorrect: false,
        obscureText:  obscureText,
        cursorColor: cursorColor,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(color: borderColor),
          ),
        ),
      ),
    );
  }
}
