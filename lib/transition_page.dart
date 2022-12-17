import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fortune_telling/result_page.dart';
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
      if (remaining_time == "0:0:0") {
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
    );
  }
}


