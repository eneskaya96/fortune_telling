import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:fortune_telling/share_and_replay_widgets.dart';
import 'package:fortune_telling/static_image_widgets.dart';
import 'package:fortune_telling/static_text_widgets.dart';
import 'package:fortune_telling/styles.dart';
import 'package:fortune_telling/tap_button_or_video_widgets.dart';
import 'package:universal_io/io.dart';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_player/video_player.dart';
import 'ads_widgets.dart';
import 'calenderWidgets.dart';
import 'enums.dart';
import 'file_operations.dart';
import 'fortune_operations.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'ad_helper.dart';

import 'instagram_share.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.state, required this.storage}) : super(key: key);

  final String state;
  final CounterStorage storage;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

  // Screen size in density independent pixels
  var screenWidth = (window.physicalSize.shortestSide / window.devicePixelRatio);
  var screenHeight = (window.physicalSize.longestSide / window.devicePixelRatio);

  late Timer timer;

  bool tappable = false;

  String fortune = "";
  String fortuneText = "";

  bool created = false;

  final List<String> allFortunes = <String>[];

  late String _state ;

  String boldMainText = "";
  String softMainText = "";

  late DateTime _readTime ;
  String remainingTime = "00:00:00";

  int numberOfFortune = 0;
  late String yellowStickPath = "";

  var fortuneOp;
  var calenderWidget;
  var tabButtonOrVideoWidget;
  var instagram;
  var adsWidget;
  var staticTextWidgets;
  var staticImageWidgets;
  var shareAndReplayWidgets;

  // built in functions
  @override
  void initState() {
    super.initState();

    fortuneOp = FortuneOperations(fortuneOpCallback, widget.storage);

    calenderWidget = CalenderWidget(calenderCallback, widget.storage, fortuneOp, screenWidth, screenHeight, context);

    tabButtonOrVideoWidget = TapButtonOrVideoWidget(tapButtonOrVideoCallback, widget.storage, fortuneOp, screenWidth, screenHeight, context);

    instagram = InstagramShare(screenWidth, screenHeight, context);

    adsWidget = AdsWidgets(adsCallback, widget.storage, screenWidth, screenHeight);

    staticTextWidgets = StaticTextWidgets(screenWidth, screenHeight, context);

    staticImageWidgets = StaticImageWidgets(screenWidth, screenHeight, context);

    shareAndReplayWidgets = ShareAndRePlayWidget(adsWidget, instagram, screenWidth, screenHeight, context);

    _state = widget.state;
    _rebuild();

    widget.storage.readTime().then((value) {
      setState(() {
        _readTime = DateTime.parse(value);
      });
    });
    calenderWidget.readDates();

    // in the opening show current day fortune
    String formattedDate = fortuneOp.getTodayDateFormatted();
    fortuneOp.readFortunesFromLocalStorage(formattedDate);

    timer = Timer.periodic(const Duration(milliseconds: 1000), (Timer t) =>
        setState(() {
          _timerJob();
        }));

    adsWidget.loadBanner();
    adsWidget.loadRewardedAd();
    tabButtonOrVideoWidget.loadVideoPlayer();

  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(249, 249, 250, 1.0),
        body: Center(
            child:
            Stack(
                children: [
                  staticImageWidgets.backgroundImageWidget(),
                  tabButtonOrVideoWidget.tapButtonOrVideoWidget(_state, tappable, allFortunes),
                  staticTextWidgets.shownFortuneAtTheEndOfVideoWidget(_state, fortuneText),
                  shareAndReplayWidgets.shareOnInstagram(_state, fortuneText),
                  staticImageWidgets.logoWidget(_state),
                  staticTextWidgets.mainPageBackgroundTextsWidget(_state, yellowStickPath, boldMainText, softMainText),
                  staticTextWidgets.tapHereTextWidget(_state, remainingTime),
                  calenderWidget.calenderMenuWidget(_state, allFortunes),
                  adsWidget.bannerAdWidget(_state)
                ]
            )
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return false; //<-- SEE HERE
  }

  @override
  void dispose() {
    adsWidget.dispose();
    super.dispose();
  }

  // callbacks
  void calenderCallback(typeOfOp){
    if(typeOfOp == TypeOfCalenderOperations.rebuild){
      _rebuild();
    }
  }

  void adsCallback(typeOfOp){
    if(typeOfOp == TypeOfAdOperations.rewardedAdShown){
      tappable = true;
      _state = "beginningState";
      _rebuild();
    }
  }

  void tapButtonOrVideoCallback(typeOfOp){
    if(typeOfOp == TypeOfTapButtonOrVideoOperations.tapButtonPressed){
      tappable = false;
      _state = "videoShownState";
      DateTime time = DateTime.now();
      _readTime = time;

    }
    else if(typeOfOp == TypeOfTapButtonOrVideoOperations.videoPressedAtTheEndOfVideo){
      if (numberOfFortune < 4){
        _state="SecondChanceState";
      }
      else {
        _state="DoNotHaveChanceState";
      }
      _rebuild();
    }
    else if(typeOfOp == TypeOfTapButtonOrVideoOperations.videoShownStateOccurs){
      fortuneText = fortune;
    }
    else if(typeOfOp == TypeOfTapButtonOrVideoOperations.endOfVideoStateOccurs){
      _state= "EndOfVideoState";
    }

  }

  void fortuneOpCallback(typeOfOp, value) {
    setState(() {
      if(typeOfOp == TypeOfFortuneOperations.getLastFortune){
        fortuneText= value;
      }
      else if(typeOfOp == TypeOfFortuneOperations.readFortunesFromLocalStorage){
        allFortunes.clear();
        List<String> lFortune = value.split("\n");
        for( var l in lFortune){
          if(l != ""){
            allFortunes.add(l);
          }
        }
      }
      else if(typeOfOp == TypeOfFortuneOperations.getFortune){
        fortune = value;
      }
      else if(typeOfOp == TypeOfFortuneOperations.getNumberOfFortunesForToday){
        numberOfFortune = value;
      }
    });
  }

  // inner functions
  void _timerJob() {
    // create date container and scroll
    if(created == false){
      String formattedDate = fortuneOp.getTodayDateFormatted();
      calenderWidget.reCreateDate(formattedDate);
      created = true;
    }

    remainingTime = widget.storage.getRemainigTime(_readTime);
    if (remainingTime == "00:00:00" && (_state == "SecondChanceState" || _state == "DoNotHaveChanceState")) {
      tappable = true;
      _state= "beginningState";
      _rebuild();
    }
  }

  void _rebuild() {
    if (_state == "beginningState") {
      tappable = true;
      yellowStickPath = "images/hello_stick.png";
      boldMainText = "Hello !";
      softMainText = "You are very close to knowing \n"
          "what will happen in your life \n"
          "today ...";
      fortuneText = "";
    }
    else if (_state == "SecondChanceState") {
      tappable = false;
      yellowStickPath = "images/hello_stick.png";
      boldMainText = "Today's fortune";
      softMainText = "What an amazing day awaits you !\n"
          "Now, you can share this fortune with \n"
          "your friends or get another fortune";
      fortuneOp.getLastFortune();
    }
    else if (_state == "DoNotHaveChanceState") {
      yellowStickPath = "images/stick_grey.png";
      boldMainText = "Sorry !";
      softMainText = "You have reached the daily \n"
          "fortune limit. Try again for a \n"
          "new fortune after 24 hours";
      fortuneText = "";
    }
    setState(() {
    });
  }

}
