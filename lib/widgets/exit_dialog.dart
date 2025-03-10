import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gad_fly/widgets/button.dart';
import 'package:google_fonts/google_fonts.dart';

Widget exitDialog(context) {
  Color white = Colors.white;
  Color black = Colors.black;
  Color grey = Colors.grey;
  Color appColorR = Color(0xFFFF006B);
  Color appColorP = Color(0xFF9C0C9E);
  return Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
          color: Colors.white12, borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Confirm',
            style: GoogleFonts.roboto(
              textStyle: const TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            'Are you sure you want to exit App?',
            style: GoogleFonts.roboto(
              textStyle: const TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 16,
                  fontWeight: FontWeight.w300),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              button(
                  color: appColorP,
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  title: 'Yes',
                  textColor: Colors.white),
              button(
                  color: grey,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  title: 'No',
                  textColor: Colors.white),
            ],
          )
        ],
      ),
    ),
  );
}
