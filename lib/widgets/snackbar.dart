import 'package:flutter/material.dart';

void snackBar(text, context) {
  var whiteColor = Colors.white;
  var blackColor = Colors.black;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Center(
      child: Text(
        text,
        style: TextStyle(
          color: blackColor,
          fontSize: 14,
        ),
      ),
    ),
    duration: const Duration(seconds: 1),
    backgroundColor: whiteColor,
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.05,
        right: MediaQuery.of(context).size.width * 0.05,
        bottom: MediaQuery.of(context).size.height * 0.1),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
    ),
  ));
}
