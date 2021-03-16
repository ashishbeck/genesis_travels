import 'package:flutter/material.dart';

Color appColor = Colors.deepOrange;
Color appWhite = Color(0xfff5f5f5);
Color appGrey = Colors.grey;

RoundedRectangleBorder roundShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0));
RoundedRectangleBorder bottomSheetShape =
    RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)));

InputDecoration textFieldDecoration = new InputDecoration(
  contentPadding: EdgeInsets.only(top: 15.0, left: 20.0),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: appColor, width: 2.0),
    borderRadius: const BorderRadius.all(
      const Radius.circular(30.0),
    ),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: appColor, width: 2.0),
    borderRadius: const BorderRadius.all(
      const Radius.circular(30.0),
    ),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
    borderRadius: const BorderRadius.all(
      const Radius.circular(30.0),
    ),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red, width: 2.0),
    borderRadius: const BorderRadius.all(
      const Radius.circular(30.0),
    ),
  ),
  filled: true,
  fillColor: appWhite,
  counterText: ""
);
