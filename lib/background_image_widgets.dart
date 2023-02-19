import 'package:flutter/material.dart';


Widget backgroundImageWidget(screenWidth, screenHeight){
  return GestureDetector(// Image tapped
    child: SizedBox(
      width: screenWidth,
      height: screenHeight,
      child: Image.asset( "images/background_pattern.png" ,
        fit: BoxFit.fill,
      ),
    ),
  );
}