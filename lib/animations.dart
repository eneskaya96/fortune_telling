import 'package:page_transition/page_transition.dart';
import 'package:flutter/material.dart';


PageTransition pageTransitionAnimation(StatefulWidget page, context){
  return PageTransition(
      type: PageTransitionType.rightToLeft,
      child: page ,
      duration: const Duration(milliseconds: 900),
      inheritTheme: true,
      ctx: context);
}