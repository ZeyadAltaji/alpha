import 'package:flutter/material.dart';

class ShadowText extends StatelessWidget {
  ShadowText(this.data, {this.style}) : assert(data != null);

  final String? data;
  final TextStyle? style;

  Widget build(BuildContext context) {
    return Text(
      data!,
      style: style!.copyWith(
        // color: primaryColor,
        shadows: [
          Shadow(
            blurRadius: 15.0,
            color: Colors.black87,
            offset: Offset(5.0, 5.0),
          ),
        ],
      ),
    );
  }
}
