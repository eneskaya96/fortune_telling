import 'package:flutter/material.dart';

class StaticImageWidgets {

  dynamic screenWidth, screenHeight, context;

  StaticImageWidgets(this.screenWidth,
      this.screenHeight,
      this.context);


  Widget logoWidget(state){
    if(state == "beginningState" || state == "SecondChanceState" || state == "DoNotHaveChanceState") {
      return
        Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.fromLTRB(0.0, screenHeight/ 15.4, 0.0, 0.0),
          child: Image.asset( "images/logo.png" ,
            fit: BoxFit.cover,
            width: screenWidth/ 4.3,
          ),
        );
    }
    else {
      return Container();
    }
  }

  Widget backgroundImageWidget(){
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
}