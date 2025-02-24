import 'package:flutter/material.dart';

Widget elevatedButton(
    {String? title,
    onPressed,
    color,
    textColor,
    imageColor,
    borderColor,
    height,
    required double borderRadius,
    required double borderWidth,
    String? imageLink}) {
  return SizedBox(
    height: height,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        side: BorderSide(color: borderColor, width: borderWidth),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imageLink != null)
            Image.asset(
              imageLink,
              color: imageColor,
              width: 20,
              height: 20,
            ),
          if (imageLink != null)
            const SizedBox(
              width: 16,
            ),
          Text(
            title!,
            style: TextStyle(color: textColor),
          ),
        ],
      ),
    ),
  );
}
