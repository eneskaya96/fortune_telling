import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:universal_io/io.dart';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_player/video_player.dart';
import 'file_operations.dart';
import 'ad_helper.dart';
import 'home_page.dart';

class TransitionPage extends StatefulWidget {
  const TransitionPage({Key? key, required this.title, required this.storage}) : super(key: key);

  final String title;
  final CounterStorage storage;

  @override
  State<TransitionPage> createState() => _TransitionPageState();
}

class _TransitionPageState extends State<TransitionPage> {

  late VideoPlayerController controller;
  late Timer timer;

  late BannerAd _ad;
  bool isLoaded = false;

  loadVideoPlayer(){
    controller = VideoPlayerController.asset('images/transit.mp4');
    controller.addListener(() {
      setState(() {});
    });
    controller.initialize().then((value){
      setState(() {
        controller.play();
      });
    });
  }

  @override
  void initState() {
    loadVideoPlayer();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) =>
        setState(() {
          // video ended
          if(controller.value.position == controller.value.duration) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context)
              =>  MyHomePage(title: "TT",
                  storage: widget.storage)),
            );
            timer.cancel();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child:
                Stack(
                  children: [
                    GestureDetector(
                        onTap: () {
                          print("tapp");

                        }, // Image tapped
                        child: SizedBox(
                          child: VideoPlayer(controller),
                        ),
                    )
                  ]
                ),
            ),
          ],
        )
      ),
    );
  }
}


