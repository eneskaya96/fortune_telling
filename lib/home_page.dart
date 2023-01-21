import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:fortune_telling/styles.dart';
import 'package:universal_io/io.dart';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_player/video_player.dart';
import 'file_operations.dart';
import 'http_request.dart';
import 'ad_helper.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

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

  final ScrollController _scrollController = ScrollController();
  late VideoPlayerController controller;

  static const double minExtent = 0.23;
  static const double maxExtent = 0.84;

  double initialExtent = minExtent;

  late Timer timer;

  late BannerAd _ad;
  bool isLoaded = false;

  bool tappable = false;

  String fortune = "LOVE";
  String fortuneTextHolder = "";

  int selectedItemIndex = 0;
  late String selectedItem;
  bool showAllFortunes = false;

  String fortunesHolder = "";
  List<Widget> dateContainer =  <Widget>[];
  final List<String> _dates = <String>[];
  bool created = false;

  final List<String> allFortunes = <String>[];

  late String _state ;

  int lenOfFortune = 4;

  // ignore: prefer_typing_uninitialized_variables
  late var _instagram;

  String boldMainText = "";
  String softMainText = "";

  late DateTime _readTime ;
  late String remainingTime = "";

  RewardedAd? _rewardedAd;

  int numberOfFortune = 0;
  late String yellowStickPath = "";


  // built in functions
  @override
  void initState() {
    super.initState();
    widget.storage.readTime().then((value) {
      setState(() {
        _readTime = DateTime.parse(value);
      });
    });

    _state = widget.state;
    _rebuild();

    _instagram = InstagramShare(screenWidth, screenHeight, context);

    readDates();

    // in the opening show current day fortune
    DateTime now = DateTime.now();
    var formatter = DateFormat('yyyy-MMM-dd');
    String formattedDate = formatter.format(now);
    readFortunesFromLocalStorage(formattedDate);

    timer = Timer.periodic(const Duration(milliseconds: 1000), (Timer t) =>
        setState(() {
          _timerJob(formattedDate);
        }));

    _loadBanner();
    _loadRewardedAd();
    _loadVideoPlayer();

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
                  backgroundImageWidget(),
                  tapButtonOrVideoWidget(),
                  shownFortuneAtTheEndOfVideoWidget(),
                  shareOnInstagram(),
                  logoWidget(),
                  mainPageBackgroundTextsWidget(),
                  tapHereTextWidget(),
                  calenderMenuWidget(),
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
                      height: screenHeight / 1.55,
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
            padding: EdgeInsets.fromLTRB(0.0, screenHeight/ 3.3, 0.0, 10.0),
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

  Widget tapButtonOrVideoWidget(){
    if(_state == "beginningState" || _state == "SecondChanceState") {
      return Container(
          alignment: Alignment.center,
          child: GestureDetector(
              onTap: () {
                if (tappable) {
                  tappable = false;
                  _state = "videoShownState";
                  _getNumberOfFortunesForToday();
                  // in the opening show current day fortune
                  DateTime now = DateTime.now();
                  var formatter = DateFormat('yyyy-MMM-dd');
                  String formattedDate = formatter.format(now);
                  readFortunesFromLocalStorage(formattedDate);
                  _rebuild();

                  getFortune();
                  DateTime time = DateTime.now();
                  widget.storage.writeTime(time.toIso8601String());
                  _readTime = time;
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
    else if(_state == "videoShownState" || _state == "EndOfVideoState" ){
      return
        GestureDetector(
            onTap: () {
              if(_state == "EndOfVideoState"){
                if (numberOfFortune < 5){
                  _state="SecondChanceState";
                }
                else {
                  _state="DoNotHaveChanceState";
                }
                _rebuild();
              }
            },
            child: Container(
            padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, screenHeight/ 35),
            color: const Color.fromRGBO(249, 249, 250, 1.0),
            alignment: Alignment.center,
            child: Container(
              alignment: Alignment.center,
              width: screenWidth,
              height: screenWidth,
              child: VideoPlayer(controller),
            ),
          ),
        );
    }
    else if(_state == "DoNotHaveChanceState"){
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

  Widget calenderMenuWidget() {
    if(_state == "beginningState" || _state == "SecondChanceState" || _state == "DoNotHaveChanceState") {
      return  SizedBox.expand(
          child: NotificationListener<DraggableScrollableNotification>(
            onNotification: (DraggableScrollableNotification dSNotification)
            {
              if(dSNotification.extent>=0.50){

                setState(() {
                  showAllFortunes = true;
                  readFortunesFromLocalStorage(selectedItem);
                });
              }
              else if(dSNotification.extent<0.50){
                setState(() {
                  showAllFortunes = false;
                  readFortunesFromLocalStorage(selectedItem);
                });
              }
              return true;
            },
            child:
            DraggableScrollableSheet(
              minChildSize: minExtent,
              maxChildSize: maxExtent,
              initialChildSize: initialExtent,
              snap: true,
              builder: _draggableScrollableSheetBuilder,
            ),
          ));
    }
    else {
      return Container();
    }
  }

  Widget allFortunesWidget() {
    return Column(
      children: [
        for (var t in allFortunes)
          Column(
            children: [
              SizedBox(height: screenHeight / 50),
              Text(t,
              style: generalBoldTextWithFont(context, 20.0),),
              SizedBox(height: screenHeight / 50),
              Image.asset( "images/ellipse_yellow.png" ,
                fit: BoxFit.cover,
                width: screenWidth/ 50,
              ),
            ],
          ),
      ],
    );
  }

  Widget _draggableScrollableSheetBuilder(BuildContext context,
      ScrollController scrollController,) {
    return DecoratedBox(
        decoration:  BoxDecoration(
          borderRadius: BorderRadius.circular(0),
          image: const DecorationImage(
              image: AssetImage("images/calender.png"),
              fit: BoxFit.fill
          ),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          child:
          Column(
            children: [
              SizedBox(height: screenHeight/ 93.2),
              Image.asset( "images/scrollThick.png" ,
                fit: BoxFit.cover,
                width: screenWidth/ 2.15,
              ),
              Center(
                child:SingleChildScrollView(
                  controller: _scrollController,
                  reverse: true,
                  padding: EdgeInsets.fromLTRB(0.0, screenHeight/ 46.5, 0.0, screenHeight/ 46.5),
                  scrollDirection: Axis.horizontal,
                  child: datesWidget(context),
                ),
              ),
              SizedBox(height: screenHeight / 12,),
              Container(
                alignment: Alignment.center,
                child: allFortunesWidget()
              )

            ],
          ),
        )
    );
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

  Widget datesWidget(BuildContext context) {
    return Wrap(
      children: [
        for (var t in dateContainer)
          Wrap(
            children: [
              SizedBox(width: screenWidth / 20), // screenWidth / 20 = date spacer width
              SizedBox(
                  width: (screenWidth / 5) - (screenWidth / 20), // screenWidth / 5 - (screenWidth / 20) = date width
                  height: (screenWidth / 5) - (screenWidth / 20),
                  child: t
              ),
            ],
          ),
        SizedBox(width: screenWidth / 20),
      ],
    );
  }

  Widget dateContainerWidget(String item) {
    return GestureDetector(
      onTap: () {
        setState(() {
          reCreateDate(item);
          readFortunesFromLocalStorage(item);
        });
      }, // Image tapped
      child:
      Stack(
        children: [
          Image.asset( selectedItem == item ? "images/ellipse_yellow.png" : "images/ellipse_orange.png",
            fit: BoxFit.contain,
          ),
          Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                const Spacer(),
                Text(item.split("-")[2],
                    style: dateContainerStyle(context)),
                Text(item.split("-")[1],
                    style: dateContainerStyle(context)),
                const Spacer(),
              ],
            ),
          )
        ],
      ),
    );
  }
  
  // inner functions
  void _timerJob(String formattedDate) {

    // Write time to
    if(controller.value.position >=
        controller.value.duration - const Duration(seconds: 9)
        && _state == "videoShownState") {
      fortuneTextHolder = fortune;
    }

    if(controller.value.position >=
        controller.value.duration - const Duration(seconds: 6)
        && _state == "videoShownState") {
      _state= "EndOfVideoState";
    }

    // create date container and scroll
    if(created == false){
      reCreateDate(formattedDate);
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

  void _loadVideoPlayer(){
    controller = VideoPlayerController.asset('images/square_animation.mp4');
    controller.addListener(() {
      setState(() {});
    });
    controller.initialize().then((value){
      setState(() {});
    });
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
      _getLastFortune();
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

  void _scrollDown() {

    double margin = (screenWidth / 20) / 2;
    double jumpPosition = margin;

    if (selectedItemIndex <= 3){
      jumpPosition = jumpPosition;
    }
    else {
      double step = (screenWidth / 5);
      jumpPosition = jumpPosition + (selectedItemIndex - 3) * step;
    }

    if(jumpPosition > _scrollController.position.maxScrollExtent){
      jumpPosition = _scrollController.position.maxScrollExtent - margin;
    }

    // because of reverse
    jumpPosition = _scrollController.position.maxScrollExtent - jumpPosition;

    _scrollController.animateTo(
      jumpPosition,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  void readDates() {
    widget.storage.readDates().then((value) {
      setState(() {

        DateTime now = DateTime.now();
        DateTime twoDayAfterNow = now.add(const Duration(days: 2, minutes: 20));
        var formatter = DateFormat('yyyy-MMM-dd');

        DateTime startDate;
        // control initial date is empty case
        if (value == ""){
          startDate = now.add(const Duration(days: - 3));
        }
        else{
          startDate = formatter.parse(value);
          // if start date close to now date
          if (startDate.compareTo(now.add(const Duration(days: - 3))) > 0){
            startDate = now.add(const Duration(days: - 3));
          }
        }

        // clear _dates list
        _dates.clear();

        while ( startDate.compareTo(twoDayAfterNow) < 0) {
          String formattedDate = formatter.format(startDate);
          _dates.add(formattedDate);

          startDate = startDate.add(const Duration(days: 1));
        }
      });
    });
  }

  void reCreateDate(String sItem){
    selectedItem = sItem;
    dateContainer.clear();
    int count = 1;
    for (var item in _dates){
      dateContainer.add(dateContainerWidget(item));
      if(item == selectedItem){
        selectedItemIndex = count;
      }
      count = count + 1;
    }
    _scrollDown();
  }

  void readFortunesFromLocalStorage(String date){
    if(showAllFortunes){
      widget.storage.readFortunesForDate(date).then((value) {
        setState(() {
          allFortunes.clear();
          List<String> lFortune = value.split("\n");
          for( var l in lFortune){
            if(l != ""){
              allFortunes.add(l);
            }
          }
          print(allFortunes);
        });
      });
    }
    else {
      fortunesHolder = "";
    }
  }


  Future<void> getFortuneV1() async {
    String response = await get_fortune_();
    if (response.isNotEmpty) {
      setState(() {
        dynamic jj = jsonDecode(response);
        fortune = jj['data']['fortune'];

        lenOfFortune = fortune.length;

        // fortune to specific date
        DateTime now = DateTime.now();
        var formatter = DateFormat('yyyy-MMM-dd');
        String formattedDate = formatter.format(now);
        widget.storage.writeFortuneForDate(formattedDate, fortune);

        // add first date to dates table
        widget.storage.readDates().then((value) {
          setState(() {
            // if any date is included, pass
            if(value.length > 1){}
            else {
              widget.storage.writeDates(formattedDate);
            }
          });
        });
      });
    }
  }

  Future<void> getFortune() async {
    widget.storage.getRandomFortune().then((value) {
      setState(() {
        fortune = value;
        lenOfFortune = fortune.length;

        // fortune to specific date
        DateTime now = DateTime.now();
        var formatter = DateFormat('yyyy-MMM-dd');
        String formattedDate = formatter.format(now);
        widget.storage.writeFortuneForDate(formattedDate, fortune);

        // add first date to dates table
        widget.storage.readDates().then((value) {
          setState(() {
            // if any date is included, pass
            if(value.length > 1){}
            else {
              widget.storage.writeDates(formattedDate);
            }
          });
        });
      });
    });
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

  void _getLastFortune(){
    String todayFortunes = "";
    List<String> listOfFortune;
    // read today's fortune number
    DateTime now = DateTime.now();
    var formatter = DateFormat('yyyy-MMM-dd');
    String formattedDate = formatter.format(now);
    widget.storage.readFortunesForDate(formattedDate).then((value) {
      setState(() {
        todayFortunes = value;
        listOfFortune = todayFortunes.split("\n");
        if(listOfFortune.isNotEmpty){
          fortuneTextHolder = listOfFortune[listOfFortune.length - 2];
        }
      });
    });
  }

  void _getNumberOfFortunesForToday(){
    String todayFortunes = "";

    List<String> listOfFortune;
    // read today's fortune number
    DateTime now = DateTime.now();
    var formatter = DateFormat('yyyy-MMM-dd');
    String formattedDate = formatter.format(now);
    widget.storage.readFortunesForDate(formattedDate).then((value) {
      setState(() {
        todayFortunes = value;
        listOfFortune = todayFortunes.split("\n");
        numberOfFortune = listOfFortune.length - 1;
      });
    });
  }
}


