import 'package:alpha/GeneralFiles/General.dart';
import 'package:flutter/material.dart';

class Button extends MaterialButton {
  final String text;
  final Color backgroundColor;
  final double height;
  final double fontSize;
  final double width;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final IconData? icon; // Change IconData to IconData?
  final bool fontBold;

  Button({
    Key? key,
    double? size,
    this.fontSize = 15,
    this.fontBold = false,
    this.text = 'button',
    this.icon, // Leave this as nullable
    Color? color,
    this.backgroundColor = Colors.green,
    bool autofocus = false,
    Widget? child,
    this.height = 40.0,
    this.width = 100.0,
    this.margin = const EdgeInsets.all(0.0),
    this.padding = const EdgeInsets.all(0.0),
    VoidCallback? onPressed,
  })  : super(
            key: key,
            autofocus: autofocus,
            color: color,
            onPressed: onPressed,
            child: child);

  bool get hasIcon => icon != null;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 5, right: 10),
      child: ButtonTheme(
        minWidth: (width - width * .101),
        height: height * .08,
        child: TextButton(
          child: Container(
            height: height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                hasIcon
                    ? Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Icon(
                          icon,
                          size: 30,
                          color: color,
                        ),
                      )
                    : SizedBox(
                        height: 0,
                        width: 0,
                      ),
                Directionality(
                  textDirection: direction,
                  child: Container(
                    padding: EdgeInsets.only(left: 0, right: 0),
                    child: Text(
                      text,
                      style: fontBold
                          ? TextStyle(
                              color: darkTheme ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: fSize(3))
                          : TextStyle(
                              color: darkTheme ? Colors.white : Colors.black,
                              fontWeight: FontWeight.normal,
                              fontSize: fSize(3)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          style: ButtonStyle(
            backgroundColor:
                WidgetStateProperty.all<Color>(Colors.transparent),
            overlayColor:
                WidgetStateProperty.all<Color>(Colors.grey[300]!), //splash
            foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
