import 'dart:async';

import 'package:fortune_telling/styles.dart';
import 'package:intl/intl.dart';

import 'package:universal_io/io.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter/material.dart';
import 'package:social_share/social_share.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui';


class InstagramShare {
  var screenWidth;
  var screenHeight;
  var context;
  late String date;

  // constructor
  InstagramShare(var screenWidth, var screenHeight, var context) {
    this.screenWidth = screenWidth;
    this.screenHeight = screenHeight;
    this.context = context;

    DateTime now = DateTime.now();
    var formatter = DateFormat('dd.MM.yyyy');
    date = formatter.format(now);
  }

  ScreenshotController screenshotController = ScreenshotController();

  Widget instaShare(String fortuneTextHolder) {
    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(249, 249, 250, 1.0),
        body: Center(
          child:
          Stack(
            children: [
              backgroundImageWidget(),
              logoWidget(),
              fortuneTellerTextWidget(),
              ellipseWidget(),
              shownFortuneAtTheEndOfVideoWidget(fortuneTextHolder),
              todaysFortuneTextWidget(),
            ],
          )
        ),
      )
    );
  }

  Future<String?> screenshot() async {
    var data = await screenshotController.capture();
    if (data == null) {
      print("xxx");
      return null;
    }
    final tempDir = await getTemporaryDirectory();
    final assetPath = '${tempDir.path}/temp.png';
    File file = await File(assetPath).create();
    await file.writeAsBytes(data);
    return file.path;
  }

  share_on_instagram() async {
    print("TA");
    var path = await screenshot();
    if (path == null) {
      print("qqqq");
      return;
    }
    SocialShare.shareInstagramStory(
      appId: "888268445701700",
      imagePath: path,
      backgroundTopColor: "#F9F9FA",
      backgroundBottomColor: "#F9F9FA",
    ).then((data) {
      print("cccccllll");
      print(data);
    }
    );
  }

  Widget shownFortuneAtTheEndOfVideoWidget(String fortuneTextHolder) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.fromLTRB(0.0, screenHeight / 80, 0.0, screenWidth/43),
      child: Container(
        alignment: Alignment.center,
        child: Text(
          fortuneTextHolder,
          style: endOfVideoTextStyle(context),
        ),
      ),
    );
  }

  Widget backgroundImageWidget(){
    return
      Container(
        child:GestureDetector(// Image tapped
          onTap: () async {
            print("TAaa");
          },
          child: SizedBox(
            child: Image.asset( "images/background_pattern.png" ,
              fit: BoxFit.fill,
            ),
          ),
        )
    );

  }

  Widget todaysFortuneTextWidget(){
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(0.0, screenHeight/ 2.20, 0.0, 0.0),
                alignment: Alignment.bottomCenter,
                child: Image.asset("images/yellow_rectangle.png",
                  width: screenWidth / 1.80,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(0.0, screenHeight/ 2.28 , 0.0, 10.0),
                child: Text("TODAY'S FORTUNE",
                  style: yellowBoldText(context),
                ),
              )
            ],
          ),
          Row(
            children: [
              const Spacer(),
              Container(
                  alignment: Alignment.center,
                  child: Container(
                      alignment: Alignment.center,
                      width: screenWidth / 15,
                      height: screenHeight / 26,
                      child: Image.asset("images/calender_icon.png",
                        fit: BoxFit.contain,
                      )
                  )
              ),
              SizedBox(width: screenWidth/43),
              Container(
                alignment: Alignment.center,
                child: Text(date,
                    style: generalBoldText(context, 20.0)
                ),
              ),
              const Spacer()
            ],
          )
        ],
      ),
    );
  }

  Widget ellipseWidget(){
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.fromLTRB(screenWidth/43, 0, screenWidth/43, 0.0),
        child: Container(
            alignment: Alignment.center,
            child: Image.asset("images/s_elips.png",
              fit: BoxFit.contain,
            )
        )
    );
  }

  Widget fortuneTellerTextWidget(){
    return Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.fromLTRB(0.0, screenHeight/ 9.1, 0.0, 0.0),
      child: Text("fortune \n teller",
        textAlign: TextAlign.center,
        style: generalBoldText(context, 20.0),
      ),
    );
  }

  Widget logoWidget(){
    return
      Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.fromLTRB(0.0, screenHeight/ 52.4, 0.0, 0.0),
        child: Image.asset( "images/logo.png" ,
          fit: BoxFit.cover,
          width: screenWidth/ 4.3,
        ),
      );
  }
}
