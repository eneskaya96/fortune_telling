import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CounterStorage {
  static const int  come_back_after_hour = 5;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/time.txt');
  }

  Future<String> readTime() async {
    try {
      final file = await _localFile;
      // Read the file
      final contents = await file.readAsString();
      if (contents.isEmpty){
        DateTime time = DateTime.now();
        time = time.add(const Duration(minutes: - come_back_after_hour - 10));
        writeTime(time.toIso8601String());
        return time.toIso8601String();
      }
      return contents;
    } catch (e) {
      // If encountering an error, return 0
      DateTime time = DateTime.now();
      time = time.add(const Duration(minutes: - come_back_after_hour - 10));
      writeTime(time.toIso8601String());
      return time.toIso8601String();
    }
  }

  Future<File> writeTime(String time) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$time');
  }

  String getRemainigTime(DateTime readedTime) {

    var now = DateTime.now();
    var howMuchTimePassed = now.difference(readedTime);
    var twentyFourHour = const Duration(minutes: come_back_after_hour);
    var remainingTime = twentyFourHour - howMuchTimePassed ;

    String sDuration = "0:0:0";
    if (remainingTime > const Duration(seconds: 0)) {
      sDuration = "${remainingTime.inHours}:${remainingTime.inMinutes.remainder(60)}:${(remainingTime.inSeconds.remainder(60))}";
    }
    return sDuration;
  }

}