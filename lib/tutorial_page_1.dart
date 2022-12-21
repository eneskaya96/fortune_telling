import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fortune_telling/tutorial_page_2.dart';
import 'file_operations.dart';

class TutorialPage1 extends StatefulWidget {
  const TutorialPage1({Key? key, required this.title, required this.storage}) : super(key: key);

  final String title;
  final CounterStorage storage;

  @override
  State<TutorialPage1> createState() => _TutorialPage1State();
}


class _TutorialPage1State extends State<TutorialPage1> {

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
                  child: Image.asset('images/tutorial_page_1.jpg'),
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
                          =>  TutorialPage2(title: "Tutorial 2",
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


