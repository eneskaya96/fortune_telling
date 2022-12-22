import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fortune_telling/result_page.dart';
import 'package:fortune_telling/tutorial_page_1.dart';
import 'package:universal_io/io.dart';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_player/video_player.dart';
import 'file_operations.dart';
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
  var readed_time;
  late String token;
  bool isFirstTime = false;

  getToken() async {
    token = (await FirebaseMessaging.instance.getToken())!;
  }

  @override
  void initState() {
    widget.storage.readTime().then((value) {
      setState(() {
        readed_time = DateTime.parse(value);
      });
    });

    widget.storage.readIsFirstTime().then((value) {
      setState(() {
        isFirstTime = value.toLowerCase() == 'true';
      });
    });

    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) =>
        setState(() {
          _timer_job();
        }));

    loadVideoPlayer();
  }

  void _timer_job(){
    // video ended
    if(controller.value.position == controller.value.duration) {

      String remaining_time = widget.storage.getRemainigTime(readed_time);

      // open tutorial page
      print(isFirstTime);
      if (isFirstTime){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context)
          =>  TutorialPage1(title: "Tutorial 1",
                            storage: widget.storage,)),
        );
      }
      else if (remaining_time == "0:0:0") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context)
          =>  MyHomePage(title: "HOME",
              storage: widget.storage)),
        );
      }
      else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context)
          =>  ResultPage(title: "RESULT",
              storage: widget.storage)),
        );
      }
      timer.cancel();

    }
  }

  void loadVideoPlayer(){
    controller = VideoPlayerController.asset('images/transition.mp4');
    controller.setVolume(0.0);
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
  void dispose() {
    if (Platform.isAndroid || Platform.isIOS) {
      _ad.dispose();
    }
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return false; //<-- SEE HERE
  }

  @override
  Widget build(BuildContext context) {
    return
      WillPopScope(
        onWillPop: _onWillPop,
        child:Scaffold(
          body: Center(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child:
                    Stack(
                        children: [
                          GestureDetector( // Image tapped
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
        ) ,
      );
  }
}


