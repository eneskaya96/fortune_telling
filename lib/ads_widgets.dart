
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


class AdsWidgets{

  Function callback;
  CounterStorage storage;

  var screenWidth;
  var screenHeight;

  AdsWidgets(this.callback, this.storage, this.screenWidth, this.screenHeight);

  late BannerAd _ad;
  bool isLoaded = false;
  RewardedAd? _rewardedAd;


  Widget bannerAdWidget(state) {
    if ((state == "beginningState" ||
        state == "SecondChanceState" ||
        state == "DoNotHaveChanceState" ) && isLoaded == true & (Platform.isAndroid || Platform.isIOS)) {
      return
        Column(
            children: [
              const Spacer(),
              Row(
                children: [
                  const Spacer(),
                  Container(
                    width: _ad.size.width.toDouble(),
                    height: _ad.size.height.toDouble(),
                    alignment: Alignment.topCenter,
                    child: AdWidget(
                      ad: _ad,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              SizedBox(height: (screenHeight/50)),
            ]
        );
    }
    else {
      return Container();
    }
  }
  void dispose(){
    if (Platform.isAndroid || Platform.isIOS) {
      _ad.dispose();
      _rewardedAd?.dispose();
    }
  }
  void showRewardedAds(){
    _rewardedAd?.show(
      onUserEarnedReward: (_, reward) {
        if (reward.amount >= 0){
          DateTime time = DateTime.now() ;
          // must be bigger than come_bach_after_hour of storage const variable
          const int comeBachAfterHour =  25;
          time = time.add(const Duration(hours: - comeBachAfterHour));
          storage.writeTime(time.toIso8601String());
          callback(TypeOfAdOperations.rewardedAdShown);
        }
      },
    );
  }

  void loadBanner() {
    // Ad-mod initialized if mobile
    if (Platform.isAndroid || Platform.isIOS) {
      WidgetsFlutterBinding.ensureInitialized();
      MobileAds.instance.initialize();
    }

    if (AdHelper.bannerAdUnitId != "UnsupportedPlatform"){
      _ad = BannerAd(
        size: AdSize.banner,
        adUnitId: AdHelper.bannerAdUnitId,
        request: const AdRequest(),
        listener: BannerAdListener(
            onAdLoaded: (_) {
              isLoaded = true;
            },
            onAdFailedToLoad: (_, error) {}
        ),
      );
      _ad.load();
    }
  }

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              loadRewardedAd();
            },
          );
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (err) {
          if (kDebugMode) {
            print('Failed to load a rewarded ad: ${err.message}');
          }
        },
      ),
    );
  }
}