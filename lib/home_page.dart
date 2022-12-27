import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
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

// Screen size in real pixels
  var screenWidthPixels = window.physicalSize.shortestSide;
  var screenHeightPixels = window.physicalSize.longestSide;

  final ScrollController _scrollController = new ScrollController();
  late VideoPlayerController controller;

  late Timer timer;

  late BannerAd _ad;
  bool isLoaded = false;

  bool tappable = true;

  String fortune = "";
  String textHolder = "";
  String timeTextHolder = "XXX";
  late DateTime readed_time ;
  late String token;

  int selectedItemIndex = 0;
  String selectedItem = '2022-Dec-23';

  String fortunesHolder = "";
  List<Widget> tiles =  <Widget>[];
  bool created = false;
  bool buttonPressed = false;

  double lenOfFortune = 4;


  final List<String> _dates = <String>[];


  getToken() async {
    token = (await FirebaseMessaging.instance.getToken())!;
  }

  @override
  void initState() {
    super.initState();

    readDates();

    // in the opening show current day fortune
    DateTime now = DateTime.now();
    var formatter = DateFormat('yyyy-MMM-dd');
    String formattedDate = formatter.format(now);
    showFortunes(formattedDate);

    widget.storage.readTime().then((value) {
      setState(() {
        readed_time = DateTime.parse(value);
      });
    });
    timer = Timer.periodic(const Duration(milliseconds: 1000), (Timer t) =>
        setState(() {
          _timer_job(formattedDate);
        }));

    _loadBanner();
    _loadVideoPlayer();
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

  void _timer_job(String formattedDate) {
    timeTextHolder = widget.storage.getRemainigTime(readed_time);

    // Write time to
    if(controller.value.position >=
        controller.value.duration - const Duration(seconds: 9) &&
        controller.value.position <
            controller.value.duration - const Duration(seconds: 2)) {
      textHolder = fortune;
    }
    else if(controller.value.position >=
        controller.value.duration - const Duration(seconds: 2) ) {
      textHolder = '';
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

  void reCreateDate(String sItem){
    selectedItem = sItem;
    tiles.clear();
    int count = 1;
    for (var item in _dates){
      //print("item " + item);
      tiles.add(mytile(item));
      if(item == selectedItem){
        selectedItemIndex = count;
      }
      count = count + 1;
    }
    _scrollDown();
  }
  @override
  void dispose() {
    if (Platform.isAndroid || Platform.isIOS) {
      _ad.dispose();
    }
    super.dispose();
  }

  void _loadVideoPlayer(){
    controller = VideoPlayerController.asset('images/animasyon.mp4');
    controller.addListener(() {
      setState(() {});
    });
    controller.initialize().then((value){
      setState(() {});
    });
  }
  void _loadBanner() {
    // Admod initialized if mobile
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
            onAdFailedToLoad: (_, error) {
              print("Ad failed to load error $error");
            }
        ),
      );
      _ad.load();
    }
  }

  Widget checkForAd() {
    if (isLoaded = true &  Platform.isAndroid || Platform.isIOS ) {
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
              SizedBox(height: 20), // TODO: make orantılı
            ]
        );
    }
    else { return CircularProgressIndicator(); }
  }

  Future<void> get_fortune() async {
    String response = await get_fortune_();
    if (response.isNotEmpty) {
      setState(() {
        dynamic jj = jsonDecode(response);
        fortune = jj['data']['fortune'];

        lenOfFortune = fortune.length as double;
        print("lenOfFortune" + lenOfFortune.toString());

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
    } else { print("RESPONSE can not obtained "); }
  }

  void showFortunes(String date){
    widget.storage.readFortunesForDate(date).then((value) {
      setState(() {
        fortunesHolder = value;
      });
    });
  }

  Widget fortunes_dates(BuildContext context) {
    return Wrap(
      children: [
        for (var t in tiles)
          Wrap(
            children: [
              SizedBox(width: screenWidth / 20), // screenWidth / 20 = date spacer width
              Container(
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

  Future<bool> _onWillPop() async {
    return false; //<-- SEE HERE
  }

  Widget mainPageBackgroundTexts(){
    if(buttonPressed != true){
      return Container(
          padding: EdgeInsets.fromLTRB(15.0, 185.0, 0.0, 10.0),
          width: 200,
          height: 270,
          child:
          Container(
            alignment: Alignment.topLeft,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  child: Text("Hello !",
                    style: GoogleFonts.montserrat(
                      textStyle: Theme.of(context).textTheme.headline4,
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      color: const Color.fromRGBO(0, 0, 0, 0.7),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  child: Text("You are very close \n"
                      "knowing what will happen \n"
                      "in your life today",
                    style: GoogleFonts.montserrat(
                      textStyle: Theme.of(context).textTheme.headline4,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color.fromRGBO(0, 0, 0, 0.7),
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

  Widget main_background(){
    if(buttonPressed == true){
      return Container(
        width: screenWidthPixels,
        height: screenHeightPixels,
        child: VideoPlayer(controller),
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

              get_fortune();
              DateTime time = DateTime.now();
              widget.storage.writeTime(time.toIso8601String());
              readed_time = time;
              controller.play();
            }
          }, // Image tapped
          child: Container(
              width: 200,
              height: 200,
              alignment: Alignment.center,
              child: Image.asset("images/button.gif",
                fit: BoxFit.fill,)
          )
        )
      );
    }
  }

  void _rebuild() {
    setState(() {
    });
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
                    GestureDetector(
                      onTap: () {
                       print("tt");
                      }, // Image tapped
                      child: SizedBox(
                        width: screenWidthPixels,
                        height: screenHeightPixels,
                        child: Image.asset( "images/background_pattern.png" ,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    main_background(),
                    Container(
                        alignment: Alignment.center,
                        child: resultFortuneWidget(),
                    ),
                    Container(
                      alignment: Alignment.topCenter,
                      padding: EdgeInsets.fromLTRB(0.0, 75.0, 0.0, 10.0),
                      child: Image.asset( "images/logo.png" ,
                        width: 100,
                        height: 100,
                        fit: BoxFit.fill,
                      ),
                    ),
                    mainPageBackgroundTexts(),
                    Container(
                        alignment: Alignment.topCenter,
                        child: Text(
                          timeTextHolder,
                          style: GoogleFonts.montserrat(
                            textStyle: Theme.of(context).textTheme.headline4,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: const Color.fromRGBO(0, 0, 0, 0.7),
                          ),
                        )
                    ),
                    DraggableScrollableSheet(
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
                                  Container(
                                    child: Column(
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
                                            padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 10.0),
                                            scrollDirection: Axis.horizontal,
                                            child: fortunes_dates(context),
                                          ),
                                        ),
                                        Text(fortunesHolder),
                                      ],
                                    )
                                ),
                              )
                          );
                      },
                    ),
                    checkForAd(),
                  ]
              )
          ),
        ),
    );
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

  myStyle() {
    return GoogleFonts.montserrat(
        textStyle: Theme.of(context).textTheme.headline4,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: const Color.fromRGBO(0, 0, 0, 0.7),
        backgroundColor: Colors.transparent
    );
  }

  Widget mytile(String item) {
    return GestureDetector(
      onTap: () {
        setState(() {
          reCreateDate(item);
          showFortunes(item);
        });
      }, // Image tapped
      child:
      Stack(
        children: [
          Image.asset( selectedItem == item ? "images/elips_yellow.png" : "images/elips_orange.png",
            fit: BoxFit.contain,
          ),
          Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                Spacer(),
                Text(item.split("-")[2],
                    style: myStyle()),
                Text(item.split("-")[1],
                    style: myStyle()),
                Spacer(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget resultFortuneWidget() {
    if(fortune == ""){
      return  Text(
          textHolder,
          style: GoogleFonts.montserrat(
            textStyle: Theme.of(context).textTheme.headline4,
            fontSize: (40 / lenOfFortune),
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
      );
    }
    else{
      return Container(
        alignment: Alignment.center,
        color: Colors.red,
        width: 75,
        height: 20,
        child: Text(
          textHolder,
          style: GoogleFonts.montserrat(
            textStyle: Theme.of(context).textTheme.headline4,
            fontSize: (40 / lenOfFortune),
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      );
    }
  }
}


