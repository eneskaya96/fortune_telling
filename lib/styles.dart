import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';



TextStyle generalBoldText(context, fontSize) {
  return GoogleFonts.didactGothic(
    textStyle: Theme.of(context).textTheme.headlineLarge,
    fontWeight: FontWeight.w700,
    color: const Color.fromRGBO(38, 38, 38, 1),
  );
}

TextStyle remainingTimeText(context) {
  return GoogleFonts.didactGothic(
    textStyle: Theme.of(context).textTheme.headlineLarge,
    fontWeight: FontWeight.w700,
    color: const Color.fromRGBO(172, 172, 172, 1),
  );
}

TextStyle remainingTimeT(context) {
  return GoogleFonts.bodoniModa(
    textStyle: Theme.of(context).textTheme.headlineLarge,
    fontWeight: FontWeight.w900,
    color: const Color.fromRGBO(172, 172, 172, 1),
  );
}

TextStyle remainingTimeWithFontSize(context, fontSize) {
  return GoogleFonts.bodoniModa(
    textStyle: Theme.of(context).textTheme.headlineLarge,
    fontSize: fontSize,
    fontWeight: FontWeight.w900,
    color: const Color.fromRGBO(172, 172, 172, 1),
  );
}

TextStyle generalBoldTextWithFont(context, fontSize) {
  return GoogleFonts.didactGothic(
    textStyle: Theme.of(context).textTheme.headlineLarge,
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    color: const Color.fromRGBO(38, 38, 38, 1),
  );
}

TextStyle generalThinTextStyle(context, fontSize){
  return GoogleFonts.bodoniModa(
    textStyle: Theme.of(context).textTheme.headlineLarge,
    fontWeight: FontWeight.w700,
    color: const Color.fromRGBO(172, 172, 172, 1),
  );
}

TextStyle shareIconText(context) {
  return GoogleFonts.didactGothic(
    textStyle: Theme.of(context).textTheme.headlineLarge,
    fontWeight: FontWeight.w400,
    color: const Color.fromRGBO(38, 38, 38, 1),
  );
}

TextStyle dateContainerStyle(context) {
  return GoogleFonts.didactGothic(
      textStyle: Theme.of(context).textTheme.headline4,
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: const Color.fromRGBO(249, 249, 250, 1),
      backgroundColor: Colors.transparent
  );
}

TextStyle endOfVideoTextStyle(context,) {
  return GoogleFonts.carroisGothic(
    textStyle: Theme.of(context).textTheme.headlineLarge,
    fontSize: 25 ,
    fontWeight: FontWeight.w700,
    color: Colors.white,
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

