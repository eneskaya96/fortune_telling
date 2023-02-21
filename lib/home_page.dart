import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:fortune_telling/styles.dart';
import 'package:fortune_telling/tap_button_or_video_widgets.dart';
import 'package:universal_io/io.dart';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_player/video_player.dart';
import 'background_image_widgets.dart';
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

  late BannerAd _ad;
  bool isLoaded = false;

  bool tappable = false;

  String fortune = "LOVE";
  String fortuneTextHolder = "";




  String fortunesHolder = "";
  bool created = false;

  final List<String> allFortunes = <String>[];

  late String _state ;


  // ignore: prefer_typing_uninitialized_variables
  late var _instagram;

  String boldMainText = "";
  String softMainText = "";

  late DateTime _readTime ;
  late String remainingTime = "0";

  RewardedAd? _rewardedAd;

  int numberOfFortune = 0;
  late String yellowStickPath = "";

  var fortuneOp;
  var calenderWidget;
  var tabButtonOrVideoWidget;


  // built in functions
  @override
  void initState() {
    super.initState();

    fortuneOp = FortuneOperations(fortuneOpCallback, widget.storage);

    calenderWidget = CalenderWidget(calenderCallback, widget.storage, fortuneOp, screenWidth, screenHeight, context);

    tabButtonOrVideoWidget = TapButtonOrVideoWidget(tapButtonOrVideoCallback, widget.storage, fortuneOp, screenWidth, screenHeight, context);

    _instagram = InstagramShare(screenWidth, screenHeight, context);

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

    _loadBanner();
    _loadRewardedAd();
    tabButtonOrVideoWidget.loadVideoPlayer();

  }

  // callbacks
  void calenderCallback(typeOfOp){
    if(typeOfOp == TypeOfCalenderOperations.rebuild){
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
      fortuneTextHolder = fortune;
    }
    else if(typeOfOp == TypeOfTapButtonOrVideoOperations.endOfVideoStateOccurs){
      _state= "EndOfVideoState";
    }

  }

  void fortuneOpCallback(typeOfOp, value) {
    setState(() {
      if(typeOfOp == TypeOfFortuneOperations.getLastFortune){
        fortuneTextHolder = value;
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


  Future<bool> _onWillPop() async {
    return false; //<-- SEE HERE
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
                  backgroundImageWidget(screenWidth, screenHeight),
                  tabButtonOrVideoWidget.tapButtonOrVideoWidget(_state, tappable, allFortunes),
                  shownFortuneAtTheEndOfVideoWidget(),
                  shareOnInstagram(),
                  logoWidget(),
                  mainPageBackgroundTextsWidget(),
                  tapHereTextWidget(),
                  calenderWidget.calenderMenuWidget(_state, allFortunes),
                  bannerAdWidget()
                ]
            )
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (Platform.isAndroid || Platform.isIOS) {
      _ad.dispose();
      _rewardedAd?.dispose();
    }
    super.dispose();
  }

  // widget functions
  Widget bannerAdWidget() {
    if ((_state == "beginningState" ||
        _state == "SecondChanceState" ||
        _state == "DoNotHaveChanceState" ) && isLoaded == true & (Platform.isAndroid || Platform.isIOS)) {
      return
        Column(
            children: [
              const Spacer(),
              Row(
                children: [
                  const Spacer(),
                  Container(
                    width: _ad.size.width.toDouble(),
                    height: _ad.size.height.toDouble(),
                    alignment: Alignment.topCenter,
                    child: AdWidget(
                      ad: _ad,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              SizedBox(height: (screenHeight / 50)),
            ]
        );
    }
    else {
      return Container();
    }
  }

  Widget tapHereTextWidget(){
    if(_state == "beginningState"){
      return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB(0.0, screenHeight / 4.0, 0.0, screenWidth/43),
          child:
          Container(
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
    else if(_state == "SecondChanceState" || _state == "DoNotHaveChanceState"){
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

  Widget mainPageBackgroundTextsWidget(){
    if(_state == "beginningState" || _state == "SecondChanceState" || _state == "DoNotHaveChanceState"){
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

  void _showMaterialDialog() {
    showDialog(
        context: context,//this works
        builder: (context) =>
            Column(
              children: [
                const Spacer(),
                Container(
                  alignment: Alignment.center,
                  child: AlertDialog(
                    contentPadding: const EdgeInsets.fromLTRB(0.0, 0, 0.0, 0.0),
                    alignment: Alignment.center,
                    content: Container(
                      color: Colors.deepPurpleAccent,
                      width: screenWidth,
                      height: screenHeight / 1.4,
                      child: _instagram.instaShare(fortuneTextHolder)
                    ),
                  ),
                ),
                GestureDetector(
                    onTap: () {
                      _instagram.share_on_instagram();
                    },
                    child:
                    Container(
                        alignment: Alignment.center,
                        child: Image.asset("images/share_grey.png",
                          width: screenWidth / 8,
                          fit: BoxFit.contain,
                        )
                    )
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child:
                    Container(
                        alignment: Alignment.center,
                        child: Image.asset("images/x.png",
                          width: screenWidth / 8,
                          fit: BoxFit.contain,
                        )
                    )
                ),
                const Spacer()
              ],
            )
        );
  }


  Widget shareOnInstagram() {
    if(_state == "EndOfVideoState") {
      return  GestureDetector(
        onTap: () async{
          _showMaterialDialog();
        },
        child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(0.0, screenWidth/ 1.4, 0.0, 10.0),
            child: Container(
                alignment: Alignment.center,
                width: screenWidth / 15,
                height: screenHeight / 26,
                child: Image.asset("images/share_on_instagram_icon.png",
                  fit: BoxFit.contain,
                )
            )
        ),
      );
    }
    else if(_state == "SecondChanceState") {
      return  GestureDetector(
        onTap: () async{
          _showMaterialDialog();
        },
        child: Container(
          alignment: Alignment.topRight,
          padding: EdgeInsets.fromLTRB(0.0, screenHeight/ 2.37, screenWidth/ 21.5, 0.0),
          child:Column(
            children: [
              GestureDetector(
                onTap: () async{
                  _showMaterialDialog();
                },
                child: Container(
                    alignment: Alignment.center,
                    width: screenWidth / 15,
                    height: screenHeight / 26,
                    child: Image.asset("images/share_on_instagram_icon.png",
                      fit: BoxFit.contain,
                    )
                ),
              ),
              Container(
                width: screenWidth / 7,
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(" Share on\n "
                      "Instagram",
                    textAlign: TextAlign.center,
                    style: shareIconText(context),
                  )
                ),
              ),
              SizedBox(height: screenHeight / 100),
              GestureDetector(
                onTap: () async{
                  _rewardedAd?.show(
                    onUserEarnedReward: (_, reward) {
                      if (reward.amount >= 0){
                        DateTime time = DateTime.now() ;
                        // must be bigger than come_bach_after_hour of storage const variable
                        const int comeBachAfterHour =  25;
                        time = time.add(const Duration(hours: - comeBachAfterHour));
                        widget.storage.writeTime(time.toIso8601String());
                        tappable = true;
                        _state = "beginningState";
                        _rebuild();
                      }
                    },
                  );
                },
                child: Container(
                    alignment: Alignment.center,
                    width: screenWidth / 15,
                    height: screenHeight / 26,
                    child: Image.asset("images/replay_icon.png",
                      fit: BoxFit.contain,
                    )
                ),
              ),
              Container(
                width: screenWidth / 8,
                alignment: Alignment.center,
                child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text("For more \n"
                        "Fortune",
                      textAlign: TextAlign.center,
                      style: shareIconText(context),
                    )
                ),
              ),
            ],
          )
        ),
      );
    }
    else {
      return Container();
    }
  }


  Widget logoWidget(){
    if(_state == "beginningState" || _state == "SecondChanceState" || _state == "DoNotHaveChanceState") {
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


  Widget shownFortuneAtTheEndOfVideoWidget() {
    if(_state == "beginningState"  || _state == "videoShownState"  || _state == "SecondChanceState"  || _state == "EndOfVideoState"){
      return Container(
        alignment: Alignment.center,
        child: Container(
          alignment: Alignment.center,
          child: Text(
            fortuneTextHolder,
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

  // inner functions
  void _timerJob() {

    // create date container and scroll
    if(created == false){
      DateTime now = DateTime.now();
      var formatter = DateFormat('yyyy-MMM-dd');
      String formattedDate = formatter.format(now);
      calenderWidget.reCreateDate(formattedDate);
      created = true;
    }

    remainingTime = widget.storage.getRemainigTime(_readTime);
    //print(_state);
    if (remainingTime == "00:00:00" && (_state == "SecondChanceState" || _state == "DoNotHaveChanceState")) {
      tappable = true;
      _state= "beginningState";
      _rebuild();
    }
  }

  void _loadBanner() {
    // Ad-mod initialized if mobile
    if (Platform.isAndroid || Platform.isIOS) {
      WidgetsFlutterBinding.ensureInitialized();
      MobileAds.instance.initialize();
    }

    if (AdHelper.bannerAdUnitId != "UnsupportedPlatform"){
      _ad = BannerAd(
        size: AdSize.banner,
        adUnitId: AdHelper.bannerAdUnitId,
        request: const AdRequest(),
        listener: BannerAdListener(
            onAdLoaded: (_) {
              setState(() {
                isLoaded = true;
              });
            },
            onAdFailedToLoad: (_, error) {}
        ),
      );
      _ad.load();
    }
  }


  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              setState(() {
                ad.dispose();
                _rewardedAd = null;
              });
              _loadRewardedAd();
            },
          );

          setState(() {
            _rewardedAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          if (kDebugMode) {
            print('Failed to load a rewarded ad: ${err.message}');
          }
        },
      ),
    );
  }



  void _rebuild() {
    if (_state == "beginningState") {
      tappable = true;
      yellowStickPath = "images/hello_stick.png";
      boldMainText = "Hello !";
      softMainText = "You are very close to knowing \n"
          "what will happen in your life \n"
          "today ...";
      fortuneTextHolder = "";
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
      fortuneTextHolder = "";
    }
    setState(() {
    });
  }

}
