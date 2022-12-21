import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fortune_telling/tutorial_page_3.dart';
import 'file_operations.dart';

class TutorialPage2 extends StatefulWidget {
  const TutorialPage2({Key? key, required this.title, required this.storage}) : super(key: key);

  final String title;
  final CounterStorage storage;

  @override
  State<TutorialPage2> createState() => _TutorialPage2State();
}


class _TutorialPage2State extends State<TutorialPage2> {

  late Timer timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) =>
        setState(() {
          _timer_job();
        }));
  }

  void _timer_job(){
    print("Timer");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: FittedBox(
                  child: Image.asset('images/tutorial_page_2.jpg'),
                fit: BoxFit.fill,
              )
          ),
          Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 14 / 23,
              ),
              Row(
                children: [
                  const Spacer(),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 4 / 10,
                    width: MediaQuery.of(context).size.width * 4 / 10,
                    child: TextButton(
                      child: const Text('', style: TextStyle(fontSize: 20.0),),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context)
                          =>  TutorialPage3(title: "Tutorial 3",
                            storage: widget.storage,)),
                        );
                      },
                    ),
                  )
                ],
              )
            ],
          )
        ],
      )
    );
  }

}


