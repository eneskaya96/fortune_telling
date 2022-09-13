import 'dart:convert';

import 'package:flutter/material.dart';
import 'http_request.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

  String textHolder = 'YOUR FORTUNE: ...';


  Future<void> get_fortune() async {
    String response = await get_fortune_();
    if (response.isNotEmpty) {
      setState(() {
        dynamic jj = jsonDecode(response);
        print(jj.runtimeType);
        print(jj['data']['fortune']);
        textHolder = jj['data']['fortune'];
      });
    }
    else {
      print("RESPONSE can not obtained ");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: (){
                get_fortune();
              },
              child: const Text('Get Fortune'),
            ),
            Container(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Text('$textHolder',
                    style: TextStyle(fontSize: 21)
                )
            ),
          ],
        ),
      ),
    );
  }
}
