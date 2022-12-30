import 'package:flutter/material.dart';
import 'package:fortune_telling/tutorial_page_3.dart';
import 'animations.dart';
import 'file_operations.dart';

class TutorialPage2 extends StatefulWidget {
  const TutorialPage2({Key? key, required this.title, required this.storage}) : super(key: key);

  final String title;
  final CounterStorage storage;

  @override
  State<TutorialPage2> createState() => _TutorialPage2State();
}


class _TutorialPage2State extends State<TutorialPage2> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: FittedBox(
                  fit: BoxFit.fill,
                  child: Image.asset('images/tutorial_page_2.jpg'),
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
                              TutorialPage3(title: "Tutorial 3", storage: widget.storage),
                              context
                          ),
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


