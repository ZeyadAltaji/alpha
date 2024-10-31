import 'package:alpha/GeneralFiles/General.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';



class BigButton extends StatelessWidget {
  final String text;
  final String badge;
  final String imagePath;
  final Color backgroundColor;
  final double height;
  final double fontSize;
  final double width;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final bool fontBold;
  final bool disabled;
 final VoidCallback? onPressed;
  final VoidCallback? onLongPress; // Added this line

  BigButton({
    Key? key,
    this.fontSize = 15,
    this.imagePath = 'images/error.png',
    this.fontBold = true,
    this.disabled = false,
    this.text = 'button',
    this.badge = '',
    this.backgroundColor = Colors.transparent,
    this.height = 40.0,
    this.width = 100.0,
    this.margin = const EdgeInsets.all(0.0),
    this.padding = const EdgeInsets.all(0.0),
    this.onPressed, 
    this.onLongPress, // Added this line

  }) : super(key: key);
  bool get isBadge => badge == "" ? false : true;
 @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        boxShadow: [
          BoxShadow(
            color: Colors.transparent,
            offset: Offset(2.0, 5.0),
            // blurRadius: 4,
          ),
        ],
      ),
      child: Opacity(
        opacity: disabled ? 0.2 : 1,
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 4,
                child: InkWell(
                  onTap: disabled ? () {} : onPressed,
                  onLongPress: onLongPress,
                  customBorder: CircleBorder(),
                  child: Card(
                    elevation: 12,
                    clipBehavior: Clip.hardEdge,
                    color: primaryColor.withOpacity(darkTheme ? 0.2 : 0.5),
                    shape: CircleBorder(side: BorderSide.none),
                    child: Padding(
                      padding: const EdgeInsets.all(0.2),
                      child: Card(
                        elevation: 12,
                        clipBehavior: Clip.hardEdge,
                        color: Colors.white.withOpacity(darkTheme ? 0.2 : 0.5),
                        shape: CircleBorder(side: BorderSide.none),
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Transform.rotate(
                            angle: 0.314,
                            child:badges.Badge(
                              showBadge: isBadge,
                              badgeContent: Text(badge),
                              child: Container(
                                width: 250,
                                height: 250,
                                padding: const EdgeInsets.all(13.0),
                                child: CachedNetworkImage(
                                  filterQuality: FilterQuality.high,
                                  placeholderFadeInDuration:
                                      Duration(milliseconds: 1000),
                                  imageUrl: imagePath,
                                  placeholder: (context, url) => new SizedBox(),
                                  errorWidget: (context, url, error) =>
                                      new Icon(Icons.error),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                child: Opacity(
                  opacity: disabled ? 0.2 : 1,
                  child: Center(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: fSize(0),
                        fontWeight: FontWeight.bold,
                        color: darkTheme
                            ? Colors.grey
                            : primaryColor.withAlpha(255),
                        // color: primaryColor,
                      ),
                      softWrap: true,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BigButton2 extends StatelessWidget {
  final String text;
  final String badge;
  final String imagePath;
  final Color backgroundColor;
  final double height;
  final double fontSize;
  final double width;
  final EdgeInsets margin;
  final EdgeInsets padding;
  final bool fontBold;
  final bool disabled;
  final VoidCallback? onPressed;

  BigButton2({
    Key? key,
    this.fontSize = 15,
    this.imagePath = 'images/error.png',
    this.fontBold = true,
    this.disabled = false,
    this.text = 'button',
    this.badge = '',
    this.backgroundColor = Colors.transparent,
    this.height = 40.0,
    this.width = 100.0,
    this.margin = const EdgeInsets.all(0.0),
    this.padding = const EdgeInsets.all(0.0),
    this.onPressed,
  }) : super(key: key);

  bool get isBadge => badge.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0), // Adjust as needed
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Change shadow color if needed
            offset: Offset(2.0, 5.0),
            blurRadius: 4,
          ),
        ],
      ),
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(backgroundColor),
          overlayColor: WidgetStateProperty.all<Color>(
              Colors.black.withOpacity(0.1)), // Change splash color if needed
          foregroundColor: WidgetStateProperty.all<Color>(Colors.black),
        ),
        onPressed: disabled ? null : onPressed,
        child: Opacity(
          opacity: disabled ? 0.5 : 1, // Provide visual feedback
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Card(
                      elevation: 12,
                      clipBehavior: Clip.hardEdge,
                      color: Colors.grey.withOpacity(0.2), // Adjust based on theme
                      shape: CircleBorder(side: BorderSide.none),
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Card(
                          elevation: 4,
                          clipBehavior: Clip.hardEdge,
                          color: Colors.white.withOpacity(0.6), // Adjust based on theme
                          shape: CircleBorder(side: BorderSide.none),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                badges.Badge(
                                  showBadge: isBadge,
                                  badgeContent: Text(
                                    badge,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  child: Container(
                                    width: 250,
                                    height: 250,
                                    padding: const EdgeInsets.all(13.0),
                                    child: Image(
                                      image: AssetImage(imagePath),
                                      width: double.infinity,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: fontBold ? FontWeight.bold : FontWeight.normal,
                      color: Colors.black,
                    ),
                    softWrap: true,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}