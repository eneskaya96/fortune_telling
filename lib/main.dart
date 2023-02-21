import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fortune_telling/push_notification.dart';
import 'package:fortune_telling/transition_page.dart';
import 'file_operations.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificationService().setupInteractedMessage();

  runApp(const MyApp());
  RemoteMessage? initialMessage =
  await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    // App received a notification when it was killed
    print("object");
  }
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fortune Teller',
      theme: ThemeData(
        scaffoldBackgroundColor:  const Color.fromRGBO(248,185,51, 1.0),
      ),
      home: TransitionPage(title: "TODAY's MOTTO", storage: CounterStorage()),

    );
  }
}