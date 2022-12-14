import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fortune_telling/home_page.dart';
import 'package:social_share/social_share.dart';
import 'package:universal_io/io.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'file_operations.dart';
import 'package:path_provider/path_provider.dart';
import 'ad_helper.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({Key? key, required this.title, required this.storage}) : super(key: key);

  final String title;
  final CounterStorage storage;

  @override
  State<ResultPage> createState() => _ResultPageState();
}


class _ResultPageState extends State<ResultPage> {

  late Timer timer;

  late BannerAd _ad;
  bool isLoaded = false;
  RewardedAd? _rewardedAd;

  String timeTextHolder = "XXX";
  late DateTime readed_time ;
  late String token;


  ScreenshotController screenshotController = ScreenshotController();

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




  getToken() async {
    token = (await FirebaseMessaging.instance.getToken())!;
  }

  @override
  void initState() {
    super.initState();

    widget.storage.readTime().then((value) {
      setState(() {
        readed_time = DateTime.parse(value);
      });
    });
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) =>
        setState(() {
          _timer_job();
        }));


    _loadBanner();
    _loadRewardedAd();

  }

  void _timer_job(){
    String remaining_time = widget.storage.getRemainigTime(readed_time);
    timeTextHolder = remaining_time;
    if (remaining_time == "0:0:0") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context)
        =>  MyHomePage(state: "HOME",
            storage: widget.storage)),
      );
      timer.cancel();
    }
  }
  void _loadBanner() {
    // Admod initialized if mobile
    if (Platform.isAndroid || Platform.isIOS) {
      WidgetsFlutterBinding.ensureInitialized();
      MobileAds.instance.initialize();
    }

    if (AdHelper.bannerAdUnitId != "UnsupportedPlatform"){
      _ad = BannerAd(
        size: AdSize.banner,
        adUnitId: AdHelper.bannerAdUnitId,
        request: AdRequest(),
        listener: BannerAdListener(
            onAdLoaded: (_) {
              setState(() {
                isLoaded = true;
              });
            },
            onAdFailedToLoad: (_, error) {
              print("Ad failed to load error $error");
            }
        ),
      );
      _ad.load();
    }
  }
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              setState(() {
                ad.dispose();
                _rewardedAd = null;
              });
              _loadRewardedAd();
            },
          );

          setState(() {
            _rewardedAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load a rewarded ad: ${err.message}');
        },
      ),
    );
  }

  @override
  void dispose() {
    if (Platform.isAndroid || Platform.isIOS) {
      _ad.dispose();
      _rewardedAd?.dispose();
    }
    super.dispose();
  }

  Widget checkForAd() {
    if (isLoaded = true &  Platform.isAndroid || Platform.isIOS ) {
      return Container(
        width: _ad.size.width.toDouble(),
        height: _ad.size.height.toDouble(),
        alignment: Alignment.center,
        child: AdWidget(
          ad: _ad,
        ),
      );
    }
    else { return CircularProgressIndicator(); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
          style: GoogleFonts.montserrat(
            textStyle: Theme.of(context).textTheme.headline4,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color.fromRGBO(0, 0, 0, 0.7),
          ),
        ),
        backgroundColor: Colors.yellowAccent,
        automaticallyImplyLeading: false
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child:
                Column(
                  children: [
                    Container(
                        alignment: Alignment.topCenter,
                        child: Text(
                          timeTextHolder,
                          style: GoogleFonts.montserrat(
                            textStyle: Theme.of(context).textTheme.headline4,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: const Color.fromRGBO(0, 0, 0, 0.7),
                          ),
                        )
                    ),
                    _buildFloatingActionButton(),
                    Container(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () async {
                          print("ccccc");
                          var path = await screenshot();
                          if (path == null) {
                            print("qqqq");
                            return;
                          }
                          SocialShare.shareInstagramStory(
                            appId: "888268445701700",
                            imagePath: path,
                            backgroundTopColor: "#ffffff",
                            backgroundBottomColor: "#000000",
                          ).then((data) {
                            print("cccccllll");
                            print(data);
                          });
                        },
                        child: Text('SHARE ON INSTAGRAM'),
                      ),
                    ),
                    Screenshot(
                      controller: screenshotController,
                      child: Text("This text will be captured as image"),
                    ),
                  ]
                ),
            ),
            checkForAd(),
          ],
        )
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return ( _rewardedAd != null) ? FloatingActionButton.extended(
      backgroundColor: Colors.yellowAccent,
      onPressed: () {
        _rewardedAd?.show(
          onUserEarnedReward: (_, reward) {
            if (reward.amount >= 0){
              DateTime time = DateTime.now() ;
              // must be bigger than come_bach_after_hour of storage const variable
              const int come_bach_after_hour =  6;
              time = time.add(const Duration(minutes: - come_bach_after_hour));
              widget.storage.writeTime(time.toIso8601String());
              readed_time = time;
            }
          },
        );
      },
      label: Text('Get One More Chance',
                  style: GoogleFonts.montserrat(
                    textStyle: Theme.of(context).textTheme.headline4,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color.fromRGBO(0, 0, 0, 0.7),
                  ),
      ),
    )
    : const CircularProgressIndicator();
  }

}


