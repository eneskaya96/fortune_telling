import 'dart:async';
import 'package:fortune_telling/result_page.dart';
import 'package:fortune_telling/tutorial_page_1.dart';
import 'package:page_transition/page_transition.dart';

import 'package:flutter/material.dart';
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

  late Timer timer;

  var readedTime;
  late String token;
  bool isFirstTime = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    widget.storage.readTime().then((value) {
      setState(() {
        readedTime = DateTime.parse(value);
      });
    });

    widget.storage.readIsFirstTime().then((value) {
      setState(() {
        isFirstTime = value.toLowerCase() == 'true';
      });
    });

    timer = Timer.periodic(const Duration(milliseconds: 200), (Timer t) =>
        setState(() {
          _timer_job();
        }));
  }

  void _timer_job(){
    if(timer.tick > 33) {

      String remainingTime = widget.storage.getRemainigTime(readedTime);

      // open tutorial page
      if (isFirstTime){
        Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.rightToLeft,
              child: TutorialPage1(title: "Tutorial 1",
                storage: widget.storage,),
              duration: const Duration(milliseconds: 300),
              inheritTheme: true,
              ctx: context),
        );
      }
      else if (remainingTime == "0:0:0") {
        Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.rightToLeft,
              child: MyHomePage(title: "HOME",
                  storage: widget.storage),
              duration: const Duration(milliseconds: 300),
              inheritTheme: true,
              ctx: context),
        );
      }
      else {
        Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.rightToLeft,
              child: ResultPage(title: "RESULT",
                  storage: widget.storage),
              duration: const Duration(milliseconds: 300),
              inheritTheme: true,
              ctx: context),
        );
      }
      timer.cancel();
    }
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
          body:
          SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: FittedBox(
                fit: BoxFit.fill,
                child: Image.asset( "images/transition_gif.gif" ,
                ),
              )
          ),
        ) ,
      );
  }
}


