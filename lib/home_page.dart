import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:universal_io/io.dart';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_player/video_player.dart';
import 'http_request.dart';
import 'ad_helper.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

  late VideoPlayerController controller;

  String fortune = "";
  String textHolder = "";

  late Timer timer;

  late BannerAd _ad;
  bool isLoaded = false;



  loadVideoPlayer(){
    controller = VideoPlayerController.asset('images/animation.mp4');
    controller.addListener(() {
      setState(() {});
    });
    controller.initialize().then((value){
      setState(() {});
    });

  }


  @override
  void initState() {
    loadVideoPlayer();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) =>
        setState(() {
          //textHolder = DateTime.now().toIso8601String();
          print(textHolder);

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


  Future<String?> result_fortune() {
    return showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('AlertDialog Title'),
            content:  Text(textHolder),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
              ),
            ],
          );
        }
    );
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
    else {
      return CircularProgressIndicator();
    }
  }

  Future<void> get_fortune() async {
    String response = await get_fortune_();
    if (response.isNotEmpty) {
      setState(() {
        dynamic jj = jsonDecode(response);
        print(jj.runtimeType);
        print(jj['data']['fortune']);
        fortune = jj['data']['fortune'];
        //result_fortune();
      });
    }
    else {
      print("RESPONSE can not obtained ");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.deepPurpleAccent,
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
                          controller.play();
                        }, // Image tapped
                        child: AspectRatio(
                          aspectRatio: 0.60,
                          child: VideoPlayer(controller),
                        ),
                      ),
                    Container(
                        alignment: Alignment.center,
                        child: Text(
                          textHolder,
                          style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold, fontSize: 22.0),
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


