import 'package:flutter/material.dart';

Widget textFormFieldWidget(
    {controller,
    cursorColor,
    textStyleColor,
    isDense,
    focusedBorderColor,
    labelText,
    labelColor}) {
  return TextFormField(
    controller: controller,
    cursorColor: cursorColor,
    // enableInteractiveSelection: false,
    keyboardType: TextInputType.emailAddress,
    style: TextStyle(color: textStyleColor),
    decoration: InputDecoration(
      isDense: isDense,
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: focusedBorderColor)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: focusedBorderColor)),
      contentPadding: const EdgeInsets.all(15.0),
      labelText: labelText,
      labelStyle: TextStyle(fontSize: 14, color: labelColor),
    ),
  );
}
