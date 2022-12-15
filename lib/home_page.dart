import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
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

  String fortune = "";
  String textHolder = "";
  String timeTextHolder = "XXX";
  late DateTime readed_time ;


  loadVideoPlayer(){
    controller = VideoPlayerController.asset('images/newnew.mp4');
    controller.addListener(() {
      setState(() {});
    });
    controller.initialize().then((value){
      setState(() {});
    });
  }


  @override
  void initState() {
    widget.storage.readTime().then((value) {
      setState(() {
        readed_time = DateTime.parse(value);
      });
    });
    loadVideoPlayer();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) =>
        setState(() {
          //textHolder = DateTime.now().toIso8601String();
          var now = DateTime.now();
          print(now.toIso8601String() + "now");
          print(readed_time);

          var how_much_time_passed = now.difference(readed_time);
          var twenty_four_hour = const Duration(hours: 24);
          var remaining_time = twenty_four_hour - how_much_time_passed ;
          print(remaining_time);
          String sDuration = "${remaining_time.inHours}:${remaining_time.inMinutes.remainder(60)}:${(remaining_time.inSeconds.remainder(60))}";
          timeTextHolder = sDuration;

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
          }
        }));
    // Admod initialized if mobile
    if (Platform.isAndroid || Platform.isIOS) {
      WidgetsFlutterBinding.ensureInitialized();
      MobileAds.instance.initialize();
    }
    super.initState();

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

  late String token;
  getToken() async {
    token = (await FirebaseMessaging.instance.getToken())!;
  }

  @override
  void dispose() {
    if (Platform.isAndroid || Platform.isIOS) {
      _ad.dispose();
    }
    super.dispose();
  }

  Widget checkForAd() {
    if (isLoaded = true &  Platform.isAndroid || Platform.isIOS ) {
      return Container(
        width: _ad.size.width.toDouble(),
        height: _ad.size.height.toDouble(),
        alignment: Alignment.center,
        child: AdWidget(
          ad: _ad,
        ),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.pink,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child:
                Stack(
                  children: [
                    GestureDetector(
                        onTap: () {
                          get_fortune();
                          DateTime time = DateTime.now();
                          widget.storage.writeTime(time.toIso8601String());
                          readed_time = time;
                          controller.play();
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
                  ]
                ),
            ),
            checkForAd(),
          ],
        )
      ),
    );
  }
}


