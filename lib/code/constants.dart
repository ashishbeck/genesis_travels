import 'package:flutter/material.dart';

Color appColor = Color(0xffE31E24);
Color appWhite = Color(0xfff5f5f5);
Color appGrey = Colors.grey;
String countryCode = "+91";

RoundedRectangleBorder roundShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0));
RoundedRectangleBorder taskShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0));
RoundedRectangleBorder appBarShape = RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)));
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
    borderSide: BorderSide(width: 2.0),
    borderRadius: const BorderRadius.all(
      const Radius.circular(30.0),
    ),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.green, width: 2.0),
    borderRadius: const BorderRadius.all(
      const Radius.circular(30.0),
    ),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.green, width: 2.0),
    borderRadius: const BorderRadius.all(
      const Radius.circular(30.0),
    ),
  ),
  errorStyle: TextStyle(color: Colors.green),
  filled: true,
  fillColor: appWhite,
  counterText: ""
);
