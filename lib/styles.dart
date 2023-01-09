import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

TextStyle dateContainerStyle(context) {
  return GoogleFonts.carroisGothic(
      textStyle: Theme.of(context).textTheme.headline4,
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: const Color.fromRGBO(249, 249, 250, 1),
      backgroundColor: Colors.transparent
  );
}

TextStyle endOfVideoTextStyle(context, int lenOfFortune) {
  return GoogleFonts.carroisGothic(
    textStyle: Theme.of(context).textTheme.headline4,
    fontSize: 40 / lenOfFortune + 10,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );
}

TextStyle generalBoldText(context) {
  return GoogleFonts.gothicA1(
    textStyle: Theme.of(context).textTheme.headline4,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: const Color.fromRGBO(38, 38, 38, 1),
  );
}

TextStyle yellowBoldText(context) {
  return GoogleFonts.gothicA1(
    textStyle: Theme.of(context).textTheme.headline4,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: const Color.fromRGBO(250, 210, 64, 1),
  );
}

TextStyle generalThinTextStyle(context){
  return GoogleFonts.bodoniModa(
    textStyle: Theme.of(context).textTheme.headline4,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: const Color.fromRGBO(172, 172, 172, 1),
  );
}