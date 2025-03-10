import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget button({String? title, onPressed, color, textColor, width}) {
  return SizedBox(
    height: 32,
    width: width,
    child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        onPressed: onPressed,
        child: Text(
          title!,
          style: GoogleFonts.roboto(
            textStyle: TextStyle(
              color: textColor,
            ),
          ),
        )),
  );
}
