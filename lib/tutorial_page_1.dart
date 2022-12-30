import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fortune_telling/tutorial_page_2.dart';
import 'animations.dart';
import 'file_operations.dart';

class TutorialPage1 extends StatefulWidget {
  const TutorialPage1({Key? key, required this.title, required this.storage}) : super(key: key);

  final String title;
  final CounterStorage storage;

  @override
  State<TutorialPage1> createState() => _TutorialPage1State();
}


class _TutorialPage1State extends State<TutorialPage1> {

  @override
  void initState() {
    super.initState();
  }


  Future<bool> _onWillPop() async {
    return false; //<-- SEE HERE
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
            body: Stack(
              children: [
                SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: Image.asset('images/tutorial_page_1.jpg'),
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
                                pageTransitionAnimation(
                                    TutorialPage2(title: '', storage: widget.storage,),
                                    context
                                )
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

        ),
    );
  }
}


