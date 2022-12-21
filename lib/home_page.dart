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

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, required this.storage}) : super(key: key);

  final String title;
  final CounterStorage storage;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

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

  final List<String> entries = <String>['A', 'B', 'C'];
  final List<int> colorCodes = <int>[600, 500, 100];


  getToken() async {
    token = (await FirebaseMessaging.instance.getToken())!;
  }

  @override
  void initState() {
    super.initState();

    widget.storage.readTime().then((value) {
      setState(() {
        readed_time = DateTime.parse(value);
      });
    });
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) =>
        setState(() {
          _timer_job();
        }));

    _loadBanner();
    _loadVideoPlayer();
  }

  void _timer_job() {
    timeTextHolder = widget.storage.getRemainigTime(readed_time);

    // Write time to
    if(controller.value.position >=
        controller.value.duration - const Duration(seconds: 9) &&
        controller.value.position <
            controller.value.duration - const Duration(seconds: 2)) {
      print('video almost Ended');
      textHolder = fortune;
    }
    else if(controller.value.position >=
        controller.value.duration - const Duration(seconds: 2) ) {
      print('video Ended');
      textHolder = '';
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context)
        =>  ResultPage(title: "Result Page",
            storage: widget.storage)),
      );
      timer.cancel();
    }
  }


  @override
  void dispose() {
    if (Platform.isAndroid || Platform.isIOS) {
      _ad.dispose();
    }
    super.dispose();
  }

  _loadVideoPlayer(){
    controller = VideoPlayerController.asset('images/newnew.mp4');
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
        request: AdRequest(),
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
      });
    } else { print("RESPONSE can not obtained "); }
  }

  Widget fortunes_dates(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: entries.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          height: 50,
          color: Colors.amber[colorCodes[index]],
          child: Center(child: Text('Entry ${entries[index]}')),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }

  Widget ff(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceAround,
      children: [
        Container(
          width: 50.0,
          height: 50.0,
          color: Colors.green,
        ),
        SizedBox(width: 20), // TODO: make orantılı
        Container(
          width: 50.0,
          height: 50.0,
          color: Colors.red,
        ),
        SizedBox(width: 20), // TODO: make orantılı
        Container(
          width: 50.0,
          height: 50.0,
          color: Colors.blue,
        ),
        SizedBox(width: 20), // TODO: make orantılı
        Container(
          width: 50.0,
          height: 50.0,
          color: Colors.green,
        ),
        SizedBox(width: 20), // TODO: make orantılı
        Container(
          width: 50.0,
          height: 50.0,
          color: Colors.pink,
        ),
        SizedBox(width: 20), // TODO: make orantılı
        Container(
          width: 50.0,
          height: 50.0,
          color: Colors.green,
        ),
        SizedBox(width: 20), // TODO: make orantılı
        Container(
          width: 50.0,
          height: 50.0,
          color: Colors.red,
        ),
        SizedBox(width: 20), // TODO: make orantılı
        Container(
          width: 50.0,
          height: 50.0,
          color: Colors.blue,
        ),
        SizedBox(width: 20), // TODO: make orantılı
        Container(
          width: 50.0,
          height: 50.0,
          color: Colors.green,
        ),
        SizedBox(width: 20), // TODO: make orantılı
        Container(
          width: 50.0,
          height: 50.0,
          color: Colors.pink,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
          style: GoogleFonts.montserrat(
            textStyle: Theme.of(context).textTheme.headline4,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color.fromRGBO(0, 0, 0, 0.7),
          ),
        ),
        backgroundColor: Colors.yellowAccent,
        automaticallyImplyLeading: false
      ),
      body: Center(
        child:
          Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    if (tappable) {
                      tappable = false;

                      get_fortune();
                      DateTime time = DateTime.now();
                      widget.storage.writeTime(time.toIso8601String());
                      readed_time = time;
                      controller.play();
                    }

                  }, // Image tapped
                  child: SizedBox(
                    child: VideoPlayer(controller),
                  ),
                ),
                Container(
                    alignment: Alignment.center,
                    child: Text(
                      textHolder,
                      style: GoogleFonts.montserrat(
                        textStyle: Theme.of(context).textTheme.headline4,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: const Color.fromRGBO(255, 255, 255, 0.7),
                      ),
                    )
                ),
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
                        decoration: const BoxDecoration(
                          image: DecorationImage(image: AssetImage("images/yball.png"), fit: BoxFit.cover),
                        ),
                        child: SingleChildScrollView(
                            controller: scrollController,
                              child: Container(
                                child: Column(
                                  children: [
                                    Text("ENES"),
                                    Text("ENES2"),
                                    SingleChildScrollView(
                                      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                                      scrollDirection: Axis.horizontal,
                                      child: ff(context),
                                    ),
                                    Text("ENES3"),
                                  ],
                                )
                              ),
                            )
                              /*
                              Column(
                                children: [
                                  ListView(
                                    // This next line does the trick.
                                    controller: scrollController,
                                    scrollDirection: Axis.horizontal,
                                    children: <Widget>[
                                      Container(
                                        width: 160.0,
                                        height: 160.0,
                                        color: Colors.red,
                                      ),
                                      Container(
                                        width: 160.0,
                                        height: 160.0,
                                        color: Colors.blue,
                                      ),
                                      Container(
                                        width: 160.0,
                                        height: 160.0,
                                        color: Colors.green,
                                      ),
                                      Container(
                                        width: 160.0,
                                        height: 160.0,
                                        color: Colors.yellow,
                                      ),
                                      Container(
                                        width: 160.0,
                                        height: 160.0,
                                        color: Colors.orange,
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                               */

                      );
                  },
                ),
                checkForAd(),
              ]
          )
      ),
    );
  }
}


