import 'dart:async';
import 'package:fortune_telling/tutorial_page_1.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'animations.dart';
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

  late DateTime _readTime;
  late String token;
  bool isFirstTime = false;

  int numberOfFortune = -1;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    widget.storage.readTime().then((value) {
      setState(() {
        _readTime = DateTime.parse(value);
      });
    });

    widget.storage.readIsFirstTime().then((value) {
      setState(() {
        isFirstTime = value.toLowerCase() == 'true';
      });
    });

    _getNumberOfFortunesForToday();

    timer = Timer.periodic(const Duration(milliseconds: 200), (Timer t) =>
        setState(() {
          _timerJob();
        }));
  }

  void _getNumberOfFortunesForToday(){
    String todayFortunes = "";
    List<String> listOfFortune;
    // read todays fortune number
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

  void _timerJob(){
    if(timer.tick > 33) {

      String remainingTime = widget.storage.getRemainigTime(_readTime);
      String _state = "beginningState";
      // open tutorial page
      if (isFirstTime){
        Navigator.push(
            context,
            pageTransitionAnimation(
                TutorialPage1(title: '', storage: widget.storage,),
                context
            )
        );
      }
      else {
        if (remainingTime == "00:00:00") {
          _state = "beginningState";
        }
        else if(numberOfFortune > 4) {
          _state = "DoNotHaveChanceState";
        }
        else {
          _state = "SecondChanceState";
        }
        Navigator.push(
            context,
            pageTransitionAnimation(
                MyHomePage(state: _state, storage: widget.storage,),
                context
            )
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


