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


class CalenderWidget {

  bool showAllFortunes = false;
  late String selectedItem;
  int selectedItemIndex = 0;

  static const double minExtent = 0.23;
  static const double maxExtent = 0.84;
  double initialExtent = minExtent;

  final ScrollController _scrollController = ScrollController();

  late List<String> allFortunes = <String>[];
  List<Widget> dateContainer =  <Widget>[];
  final List<String> _dates = <String>[];


  Function callback;
  CounterStorage storage;
  var fortuneOp;

  var screenWidth;
  var screenHeight;
  var context;

  CalenderWidget(this.callback,
      this.storage,
      this.fortuneOp,
      this.screenWidth,
      this.screenHeight,
      this.context);


  Widget calenderMenuWidget(state, allFortunes) {
    this.allFortunes = allFortunes;
    if(state == "beginningState" || state == "SecondChanceState" || state == "DoNotHaveChanceState") {
      return  SizedBox.expand(
          child: NotificationListener<DraggableScrollableNotification>(
            onNotification: (DraggableScrollableNotification dSNotification)
            {
              if(dSNotification.extent>=0.50){

                showAllFortunes = true;
                fortuneOp.readFortunesFromLocalStorage(selectedItem);
              }
              else if(dSNotification.extent<0.50){
                showAllFortunes = false;
                fortuneOp.readFortunesFromLocalStorage(selectedItem);
              }
              return true;
            },
            child:
            DraggableScrollableSheet(
              minChildSize: minExtent,
              maxChildSize: maxExtent,
              initialChildSize: initialExtent,
              snap: true,
              builder: _draggableScrollableSheetBuilder,
            ),
          ));
    }
    else {
      return Container();
    }
  }

  Widget _draggableScrollableSheetBuilder(BuildContext context,
      ScrollController scrollController) {
    return DecoratedBox(
        decoration:  BoxDecoration(
          borderRadius: BorderRadius.circular(0),
          image: const DecorationImage(
              image: AssetImage("images/calender.png"),
              fit: BoxFit.fill
          ),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          child:
          Column(
            children: [
              SizedBox(height: screenHeight/ 93.2),
              Image.asset( "images/scrollThick.png" ,
                fit: BoxFit.cover,
                width: screenWidth/ 2.15,
              ),
              Center(
                child:SingleChildScrollView(
                  controller: _scrollController,
                  reverse: true,
                  padding: EdgeInsets.fromLTRB(0.0, screenHeight/ 46.5, 0.0, screenHeight/ 46.5),
                  scrollDirection: Axis.horizontal,
                  child: datesWidget(context),
                ),
              ),
              SizedBox(height: screenHeight / 12,),
              Container(
                  alignment: Alignment.center,
                  child: allFortunesWidget(allFortunes)
              )
            ],
          ),
        )
    );
  }

  Widget allFortunesWidget(allFortunes) {
    return Column(
      children: [
        for (int i = 0; i < allFortunes.length ; i++)
          Column(
            children: [
              SizedBox(height: screenHeight / 50),
              Text(allFortunes[i],
                style: generalBoldTextWithFont(context, 20.0),),
              SizedBox(height: screenHeight / 50),
              if(i != allFortunes.length - 1)
                Image.asset( "images/ellipse_yellow.png" ,
                  fit: BoxFit.cover,
                  width: screenWidth/ 50,
                ),
            ],
          ),
      ],
    );
  }

  Widget dateContainerWidget(String item) {
    return GestureDetector(
      onTap: () {
        reCreateDate(item);
        fortuneOp.readFortunesFromLocalStorage(item);
        callback(TypeOfCalenderOperations.rebuild);
      }, // Image tapped
      child:
      Stack(
        children: [
          Image.asset( selectedItem == item ? "images/ellipse_yellow.png" : "images/ellipse_orange.png",
            fit: BoxFit.contain,
          ),
          Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                const Spacer(),
                Text(item.split("-")[2],
                    style: dateContainerStyle(context)),
                Text(item.split("-")[1],
                    style: dateContainerStyle(context)),
                const Spacer(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget datesWidget(BuildContext context) {
    return Wrap(
      children: [
        for (var t in dateContainer)
          Wrap(
            children: [
              SizedBox(width: screenWidth / 20), // screenWidth / 20 = date spacer width
              SizedBox(
                  width: (screenWidth / 5) - (screenWidth / 20), // screenWidth / 5 - (screenWidth / 20) = date width
                  height: (screenWidth / 5) - (screenWidth / 20),
                  child: t
              ),
            ],
          ),
        SizedBox(width: screenWidth / 20),
      ],
    );
  }

  void reCreateDate(String sItem){
    selectedItem = sItem;
    dateContainer.clear();
    int count = 1;
    for (var item in _dates){
      dateContainer.add(dateContainerWidget(item));
      if(item == selectedItem){
        selectedItemIndex = count;
      }
      count = count + 1;
    }
    _scrollDown();
  }

  void readDates() {
    storage.readDates().then((value) {

      DateTime now = DateTime.now();
      DateTime twoDayAfterNow = now.add(const Duration(days: 2, minutes: 20));
      var formatter = DateFormat('yyyy-MMM-dd');

      DateTime startDate;
      // control initial date is empty case
      if (value == ""){
        startDate = now.add(const Duration(days: - 3));
      }
      else{
        startDate = formatter.parse(value);
        // if start date close to now date
        if (startDate.compareTo(now.add(const Duration(days: - 3))) > 0){
          startDate = now.add(const Duration(days: - 3));
        }
      }

      // clear _dates list
      _dates.clear();

      while ( startDate.compareTo(twoDayAfterNow) < 0) {
        String formattedDate = formatter.format(startDate);
        _dates.add(formattedDate);

        startDate = startDate.add(const Duration(days: 1));
      }

    });
  }

  void _scrollDown() {

    double margin = (screenWidth / 20) / 2;
    double jumpPosition = margin;

    if (selectedItemIndex <= 3){
      jumpPosition = jumpPosition;
    }
    else {
      double step = (screenWidth / 5);
      jumpPosition = jumpPosition + (selectedItemIndex - 3) * step;
    }

    if(jumpPosition > _scrollController.position.maxScrollExtent){
      jumpPosition = _scrollController.position.maxScrollExtent - margin;
    }

    // because of reverse
    jumpPosition = _scrollController.position.maxScrollExtent - jumpPosition;

    _scrollController.animateTo(
      jumpPosition,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

}