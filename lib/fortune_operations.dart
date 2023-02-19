
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:fortune_telling/styles.dart';
import 'package:universal_io/io.dart';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_player/video_player.dart';
import 'background_image_widgets.dart';
import 'enums.dart';
import 'file_operations.dart';
import 'http_request.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'ad_helper.dart';

import 'instagram_share.dart';



class FortuneOperations{

  Function callback;
  CounterStorage storage;

  FortuneOperations(this.callback, this.storage);


  void getLastFortune(){
    // read today's fortune number
    String formattedDate = getTodayDateFormatted();
    storage.readFortunesForDate(formattedDate).then((value) {
      String lastFortune = "";
      String todayFortunes = value;
      List<String> listOfFortune = todayFortunes.split("\n");
      if(listOfFortune.isNotEmpty){
        lastFortune = listOfFortune[listOfFortune.length - 2];
      }
      callback(TypeOfFortuneOperations.getLastFortune ,lastFortune);
    });
  }

  void readFortunesFromLocalStorage(String date){
    storage.readFortunesForDate(date).then((value) {
      callback(TypeOfFortuneOperations.readFortunesFromLocalStorage ,value);
    });
  }

  void getFortune(allFortunes) {
    storage.getRandomFortune().then((value) {
      // if new fortune exists in today's fortune retry
      if (allFortunes.contains(value)){
        getFortune(allFortunes);
      }
      else {
        // fortune to specific date
        String formattedDate = getTodayDateFormatted();
        storage.writeFortuneForDate(formattedDate, value);

        // add first date to dates table
        storage.readDates().then((value) {
          if(value.length <= 1){storage.writeDates(formattedDate);}
        });
        callback(TypeOfFortuneOperations.getFortune, value);
      }
    });
  }

  void getNumberOfFortunesForToday(){
    // read today's fortune number
    String formattedDate = getTodayDateFormatted();
    storage.readFortunesForDate(formattedDate).then((value) {
      String todayFortunes = value;
      List<String> listOfFortune = todayFortunes.split("\n");
      callback(TypeOfFortuneOperations.getNumberOfFortunesForToday,  listOfFortune.length - 1);
    });
  }

  String getTodayDateFormatted() {
    DateTime now = DateTime.now();
    var formatter = DateFormat('yyyy-MMM-dd');
    String formattedDate = formatter.format(now);
    return formattedDate;
  }


/*
  Future<void> getFortuneV1() async {
    String response = await get_fortune_();
    if (response.isNotEmpty) {
      setState(() {
        dynamic jj = jsonDecode(response);
        fortune = jj['data']['fortune'];

        lenOfFortune = fortune.length;

        // fortune to specific date
        DateTime now = DateTime.now();
        var formatter = DateFormat('yyyy-MMM-dd');
        String formattedDate = formatter.format(now);
        widget.storage.writeFortuneForDate(formattedDate, fortune);

        // add first date to dates table
        widget.storage.readDates().then((value) {
          setState(() {
            // if any date is included, pass
            if(value.length > 1){}
            else {
              widget.storage.writeDates(formattedDate);
            }
          });
        });
      });
    }
  }
   */

}
