
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:fortune_telling/styles.dart';
import 'package:universal_io/io.dart';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_player/video_player.dart';
import 'enums.dart';
import 'file_operations.dart';
import 'fortune_operations.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'ad_helper.dart';

import 'instagram_share.dart';


class ShareAndRePlayWidget {

  var adsWidget;
  var instagram;
  var screenWidth;
  var screenHeight;
  var context;

  ShareAndRePlayWidget(this.adsWidget,
      this.instagram,
      this.screenWidth,
      this.screenHeight,
      this.context);


  Widget shareOnInstagram(state, fortuneText) {
    if(state == "EndOfVideoState") {
      return  GestureDetector(
        onTap: () async{
          _showMaterialDialog(fortuneText);
        },
        child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(0.0, screenWidth/ 1.4, 0.0, 10.0),
            child: Container(
                alignment: Alignment.center,
                width: screenWidth / 15,
                height: screenHeight / 26,
                child: Image.asset("images/share_on_instagram_icon.png",
                  fit: BoxFit.contain,
                )
            )
        ),
      );
    }
    else if(state == "SecondChanceState") {
      return  GestureDetector(
        onTap: () async{
          _showMaterialDialog(fortuneText);
        },
        child: Container(
            alignment: Alignment.topRight,
            padding: EdgeInsets.fromLTRB(0.0, screenHeight/ 2.37, screenWidth/ 21.5, 0.0),
            child:Column(
              children: [
                GestureDetector(
                  onTap: () async{
                    _showMaterialDialog(fortuneText);
                  },
                  child: Container(
                      alignment: Alignment.center,
                      width: screenWidth / 15,
                      height: screenHeight / 26,
                      child: Image.asset("images/share_on_instagram_icon.png",
                        fit: BoxFit.contain,
                      )
                  ),
                ),
                Container(
                  width: screenWidth / 7,
                  alignment: Alignment.center,
                  child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(" Share on\n "
                          "Instagram",
                        textAlign: TextAlign.center,
                        style: shareIconText(context),
                      )
                  ),
                ),
                SizedBox(height: screenHeight / 100),
                GestureDetector(
                  onTap: () async{
                    adsWidget.showRewardedAds();
                  },
                  child: Container(
                      alignment: Alignment.center,
                      width: screenWidth / 15,
                      height: screenHeight / 26,
                      child: Image.asset("images/replay_icon.png",
                        fit: BoxFit.contain,
                      )
                  ),
                ),
                Container(
                  width: screenWidth / 8,
                  alignment: Alignment.center,
                  child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text("For more \n"
                          "Fortune",
                        textAlign: TextAlign.center,
                        style: shareIconText(context),
                      )
                  ),
                ),
              ],
            )
        ),
      );
    }
    else {
      return Container();
    }
  }

  void _showMaterialDialog(fortuneText) {
    showDialog(
        context: context,//this works
        builder: (context) =>
            Column(
              children: [
                const Spacer(),
                Container(
                  alignment: Alignment.center,
                  child: AlertDialog(
                    contentPadding: const EdgeInsets.fromLTRB(0.0, 0, 0.0, 0.0),
                    alignment: Alignment.center,
                    content: Container(
                        color: Colors.deepPurpleAccent,
                        width: screenWidth,
                        height: screenHeight / 1.4,
                        child: instagram.instaShare(fortuneText)
                    ),
                  ),
                ),
                GestureDetector(
                    onTap: () {
                      -instagram.share_on_instagram();
                    },
                    child:
                    Container(
                        alignment: Alignment.center,
                        child: Image.asset("images/share_grey.png",
                          width: screenWidth / 8,
                          fit: BoxFit.contain,
                        )
                    )
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child:
                    Container(
                        alignment: Alignment.center,
                        child: Image.asset("images/x.png",
                          width: screenWidth / 8,
                          fit: BoxFit.contain,
                        )
                    )
                ),
                const Spacer()
              ],
            )
    );
  }

}