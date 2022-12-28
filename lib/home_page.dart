import 'dart:async';
import 'dart:convert';
import 'package:fortune_telling/result_page.dart';
import 'package:universal_io/io.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_player/video_player.dart';
import 'file_operations.dart';
import 'http_request.dart';
import 'ad_helper.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.storage}) : super(key: key);

  final String title;
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

  late Timer timer;

  late BannerAd _ad;
  bool isLoaded = false;

  bool tappable = true;

  String fortune = "";
  String fortuneTextHolder = "";

  int selectedItemIndex = 0;
  late String selectedItem;

  String fortunesHolder = "";
  List<Widget> dateContainer =  <Widget>[];
  final List<String> _dates = <String>[];
  bool created = false;
  bool buttonPressed = false;

  double lenOfFortune = 4;

  // built in functions
  @override
  void initState() {
    super.initState();

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
                  logoWidget(),
                  mainPageBackgroundTextsWidget(),
                  tapHereTextWidget(),
                  calenderMenuWidget(),
                  bannerAdWidget(),
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
    }
    super.dispose();
  }

  // widget functions
  Widget bannerAdWidget() {
    if (buttonPressed != true && isLoaded == true & (Platform.isAndroid || Platform.isIOS)) {
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
              const SizedBox(height: 20), // TODO: make it scale
            ]
        );
    }
    else {
      return Container();
    }
  }

  Widget tapHereTextWidget(){
    if(buttonPressed != true){
      return Container(
          padding: const EdgeInsets.fromLTRB(0.0, 200.0, 0.0, 10.0),
          child:
          Container(
            alignment: Alignment.center,
            child: Text("Tap for fortune !",
              style: GoogleFonts.carroisGothic(
                textStyle: Theme.of(context).textTheme.headline4,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color.fromRGBO(38, 38, 38, 1),
              ),
            ),
          )
      );
    }
    else {
      return Container();
    }
  }

  Widget mainPageBackgroundTextsWidget(){
    if(buttonPressed != true){
      return Container(
          padding: const EdgeInsets.fromLTRB(0.0, 200.0, 0.0, 10.0),
          child:
          Container(
            alignment: Alignment.center,
            //color: Colors.black,
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      //color: Colors.blue,
                      child: Text("Hello !",
                        style: GoogleFonts.gothicA1(
                          textStyle: Theme.of(context).textTheme.headline4,
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          color: const Color.fromRGBO(38, 38, 38, 1),
                        ),
                      ),
                    ),
                    Container(
                      //color: Colors.red,
                      padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 10.0),
                      alignment: Alignment.bottomCenter,
                      child: Image.asset("images/hello_stick.png",
                        width: 180,
                        fit: BoxFit.cover,
                      ),
                    )
                  ],
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text("You are very close to knowing \n"
                      "what will happen in your life \n"
                      "today ...",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.bodoniModa(
                      textStyle: Theme.of(context).textTheme.headline4,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color.fromRGBO(172, 172, 172, 1),
                    ),
                  ),
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

  Widget tapButtonOrVideoWidget(){
    if(buttonPressed == true){
      return Container(
        color: const Color.fromRGBO(249, 249, 250, 1.0),
        alignment: Alignment.center,
        child: Container(
          alignment: Alignment.center,
          width: screenWidth,
          height: screenWidth,
          child: VideoPlayer(controller),
        ),
      );
    }
    else {
      return Container(
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {
            if (tappable) {
              tappable = false;
              buttonPressed = true;
              _rebuild();

              getFortune();
              DateTime time = DateTime.now();
              widget.storage.writeTime(time.toIso8601String());
              controller.play();
            }
          }, // Image tapped
          child: Container(
              alignment: Alignment.center,
              child: Image.asset("images/button.gif",
                width: screenWidth / 3,
                fit: BoxFit.contain,
              )
          )
        )
      );
    }
  }

  Widget logoWidget(){
    if(buttonPressed != true) {
      return Container(
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.fromLTRB(0.0, 75.0, 0.0, 10.0),
        child: Image.asset( "images/logo.png" ,
          fit: BoxFit.cover,
          width: 100,
        ),
      );
    }
    else {
      return Container();
    }
  }

  Widget calenderMenuWidget() {
    if(buttonPressed != true) {
      return DraggableScrollableSheet(
        initialChildSize: 0.25,
        maxChildSize: 0.85,
        minChildSize: 0.25,
        builder: (BuildContext context, ScrollController scrollController) {
          return
            DecoratedBox(
                decoration:  BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: const DecorationImage(
                      image: AssetImage("images/calender.png"),
                      fit: BoxFit.cover
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child:
                  Column(
                    children: [
                      const SizedBox(height: 10,),
                      Image.asset( "images/scrollThick.png" ,
                        fit: BoxFit.cover,
                        width: 200,
                      ),
                      Center(
                        child:SingleChildScrollView(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 10.0),
                          scrollDirection: Axis.horizontal,
                          child: datesWidget(context),
                        ),
                      ),
                      Text(fortunesHolder),
                    ],
                  ),
                )
            );
        },
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

  Widget shownFortuneAtTheEndOfVideoWidget() {
    if(fortune == ""){
      return  Container();
    }
    else{
      return Container(
        alignment: Alignment.center,
        color: Colors.red,
        width: 75,
        height: 20,
        child: Text(
          fortuneTextHolder,
          style: GoogleFonts.carroisGothic(
            textStyle: Theme.of(context).textTheme.headline4,
            fontSize: (40 / lenOfFortune),
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      );
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
                    style: myStyle()),
                Text(item.split("-")[1],
                    style: myStyle()),
                const Spacer(),
              ],
            ),
          )
        ],
      ),
    );
  }

  // styles
  myStyle() {
    return GoogleFonts.carroisGothic(
        textStyle: Theme.of(context).textTheme.headline4,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: const Color.fromRGBO(249, 249, 250, 1),
        backgroundColor: Colors.transparent
    );
  }

  // inner functions
  void _timerJob(String formattedDate) {

    // Write time to
    if(controller.value.position >=
        controller.value.duration - const Duration(seconds: 9) &&
        controller.value.position <
            controller.value.duration - const Duration(seconds: 2)) {
      fortuneTextHolder = fortune;
    }
    else if(controller.value.position >=
        controller.value.duration - const Duration(seconds: 2) ) {
      fortuneTextHolder = '';
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context)
        =>  ResultPage(title: "Result Page",
            storage: widget.storage)),
      );
      timer.cancel();
    }

    // create date container and scroll
    if(created == false){
      reCreateDate(formattedDate);
      created = true;
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
    widget.storage.readFortunesForDate(date).then((value) {
      setState(() {
        fortunesHolder = value;
      });
    });
  }

  Future<void> getFortune() async {
    String response = await get_fortune_();
    if (response.isNotEmpty) {
      setState(() {
        dynamic jj = jsonDecode(response);
        fortune = jj['data']['fortune'];

        lenOfFortune = fortune.length as double;

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
}


