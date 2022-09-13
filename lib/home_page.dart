import 'package:flutter/material.dart';
import 'http_request.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

  Future<void> get_fortune() async {
    String response = await get_fortune_();
    print("BUTTON PRESSED");
    if (response.compareTo('YES') == 0) {
      print("Can not login " + response );
    }
    else {
      print("Can not login ");
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
          ],
        ),
      ),
    );
  }
}
