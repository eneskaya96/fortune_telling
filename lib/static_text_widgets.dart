import 'package:fortune_telling/styles.dart';
import 'package:flutter/material.dart';

class StaticTextWidgets{

  dynamic screenWidth, screenHeight, context;

  StaticTextWidgets(
      this.screenWidth,
      this.screenHeight,
      this.context);

  Widget tapHereTextWidget(state, remainingTime){
    if(state == "beginningState"){
      return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB(0.0, screenHeight / 4.0, 0.0, screenWidth/43),
          child: SizedBox(
              width: screenWidth / 3.5,
              child: FittedBox(
                fit: BoxFit.fitWidth,
                child: Text("Tap for fortune !",
                  style: generalBoldText(context, 20.0),
                ),
              )
          )
      );
    }
    else if(state == "SecondChanceState" || state == "DoNotHaveChanceState"){
      return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB(0.0, screenHeight / 1.66, 0.0, screenWidth/43),
          child: Column (
            children: [
              Container(
                  width: screenWidth / 2.5,
                  alignment: Alignment.center,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text("Remaining time to \n "
                        "the next day's fortune",
                      textAlign: TextAlign.center,
                      style: remainingTimeText(context),
                    ),
                  )
              ),
              SizedBox(
                height: screenHeight/ 250,
              ),
              Container(
                  alignment: Alignment.center,
                  width: screenWidth/4,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text(remainingTime,
                      textAlign: TextAlign.center,
                      style: remainingTimeT(context),
                    ),
                  )
              )
            ],
          )

      );
    }
    else {
      return Container();
    }
  }


  Widget mainPageBackgroundTextsWidget(state, yellowStickPath, boldMainText, softMainText){
    if(state == "beginningState" || state == "SecondChanceState" || state == "DoNotHaveChanceState"){
      return Container(
          padding: EdgeInsets.fromLTRB(0.0, screenHeight/ 5.4, 0.0, 10.0),
          child:
          Container(
            alignment: Alignment.center,
            //color: Colors.black,
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      //color: Colors.blue,
                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, screenHeight / 155.0),// 15
                      alignment: Alignment.bottomCenter,
                      height: screenHeight / 46.6 * 2,
                      child: Image.asset(yellowStickPath,
                        width:  screenWidth / 1.60,
                        height: screenHeight / 146.4, // padding + this should be equal to font size = 5
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      //color: Colors.red,
                        alignment: Alignment.bottomCenter,
                        height: screenHeight / 46.6 * 2, // should  be equal to text font size = 20
                        //width: 200,
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(boldMainText,
                            style: generalBoldText(context, 35.0),
                          ),
                        )

                    )
                  ],
                ),
                SizedBox(
                  height: screenHeight / 100.4,
                ),
                Container(
                    alignment: Alignment.center,
                    width: screenWidth / 1.60,
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child:  Text(softMainText,
                        textAlign: TextAlign.center,
                        style:generalThinTextStyle(context, screenWidth / 23.88),
                      ),
                    )
                ),
              ],
            ),
          )
      );
    }
    else {
      return Container();
    }
  }

  Widget shownFortuneAtTheEndOfVideoWidget(state, fortuneText) {
    if(state == "beginningState"  || state == "videoShownState"  || state == "SecondChanceState"  || state == "EndOfVideoState"){
      return Container(
        alignment: Alignment.center,
        child: Container(
          alignment: Alignment.center,
          width: 150,
          height: 150,
          child: Text(
            fortuneText,
            textAlign: TextAlign.center,
            style: endOfVideoTextStyle(context),
          ),
        ),
      );
    }
    else{
      return  Container();
    }
  }

}