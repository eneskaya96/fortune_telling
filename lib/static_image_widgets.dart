import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:fortune_telling/styles.dart';
import 'package:universal_io/io.dart';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_player/video_player.dart';
import 'enums.dart';
import 'file_operations.dart';
import 'fortune_operations.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'ad_helper.dart';

import 'instagram_share.dart';


class StaticImageWidgets {

  var screenWidth;
  var screenHeight;
  var context;

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