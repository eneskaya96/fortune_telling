import 'package:flutter/material.dart';
import 'animations.dart';
import 'file_operations.dart';
import 'home_page.dart';

class TutorialPage3 extends StatefulWidget {
  const TutorialPage3({Key? key, required this.title, required this.storage}) : super(key: key);

  final String title;
  final CounterStorage storage;

  @override
  State<TutorialPage3> createState() => _TutorialPage3State();
}


class _TutorialPage3State extends State<TutorialPage3> {


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
                  child: Image.asset('images/tutorial_page_3.jpg'),
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
                              MyHomePage(title: "HOME", storage: widget.storage),
                              context
                          ),
                        );
                        updateFirstTime();
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

  void updateFirstTime() {
    widget.storage.writeIsFirstTime("false");
  }

}


