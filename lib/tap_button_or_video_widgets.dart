import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:fortune_telling/styles.dart';
import 'package:universal_io/io.dart';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_player/video_player.dart';
import 'background_image_widgets.dart';
import 'enums.dart';
import 'file_operations.dart';
import 'http_request.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'ad_helper.dart';

import 'instagram_share.dart';


class TapButtonOrVideoWidget{

  late VideoPlayerController controller;
  late Timer timer;

  Function callback;
  CounterStorage storage;
  var fortuneOp;

  var screenWidth;
  var screenHeight;
  var context;


  TapButtonOrVideoWidget(this.callback,
      this.storage,
      this.fortuneOp,
      this.screenWidth,
      this.screenHeight,
      this.context);

  Widget tapButtonOrVideoWidget(state, tappable, allFortunes){
    if(state == "beginningState" || state == "SecondChanceState") {
      return Container(
          alignment: Alignment.center,
          child: GestureDetector(
              onTap: () {
                if (tappable) {
                  timer = Timer.periodic(const Duration(milliseconds: 1000), (Timer t) =>
                      timerJob()
                  );

                  callback(TypeOfTapButtonOrVideoOperations.tapButtonPressed);
                  fortuneOp.getNumberOfFortunesForToday();

                  // in the opening show current day fortune
                  String formattedDate = fortuneOp.getTodayDateFormatted();
                  fortuneOp.readFortunesFromLocalStorage(formattedDate);

                  fortuneOp.getFortune(allFortunes);

                  DateTime time = DateTime.now();
                  storage.writeTime(time.toIso8601String());
                  controller.play();
                }
              }, // Image tapped
              child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.fromLTRB(screenWidth/ 60, screenHeight/ 150, 0.0, 0.0),
                  child: Image.asset("images/button.gif",
                    width: screenWidth / 2,
                    fit: BoxFit.contain,
                  )
              )
          )
      );
    }
    else if(state == "videoShownState" || state == "EndOfVideoState" ){
      return
        GestureDetector(
          onTap: () {
            if(state == "EndOfVideoState"){
              callback(TypeOfTapButtonOrVideoOperations.videoPressedAtTheEndOfVideo);
            }
          },
          child: Container(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, screenHeight/ 35),
              color: const Color.fromRGBO(249, 249, 250, 1.0),
              alignment: Alignment.center,
              child:
              Transform.scale(
                alignment: Alignment.center,
                scale: 1.08,
                child:Container(
                  alignment: Alignment.center,
                  width: screenWidth ,
                  height: screenWidth,
                  child: VideoPlayer(controller),
                ),
              )
          ),
        );
    }
    else if(state == "DoNotHaveChanceState"){
      return Container(
          alignment: Alignment.center,
          child: GestureDetector(
              onTap: () {
              }, // Image tapped
              child: Container(
                  alignment: Alignment.center,
                  child: Image.asset("images/square_grey_animation.gif",
                    width: screenWidth / 2,
                    fit: BoxFit.contain,
                  )
              )
          )
      );
    }
    else {
      return Container();
    }
  }

  void timerJob() {

    // Write time to
    if(controller.value.position >=
        controller.value.duration - const Duration(seconds: 9)) {
      callback(TypeOfTapButtonOrVideoOperations.videoShownStateOccurs);
    }

    if(controller.value.position >=
        controller.value.duration - const Duration(seconds: 6)) {
      timer.cancel();
      callback(TypeOfTapButtonOrVideoOperations.endOfVideoStateOccurs);
    }

  }

  void loadVideoPlayer(){
    controller = VideoPlayerController.asset('images/square_animation.mp4');
    controller.addListener(() {});
    controller.initialize().then((value){ });
  }
}