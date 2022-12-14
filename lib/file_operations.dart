import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import "dart:math";


class CounterStorage {
  static const int  comeBackAfterHour = 24;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFileTime async {
    final path = await _localPath;
    return File('$path/time.txt');
  }

  Future<String> getRandomFortune() async {
    final random = Random();
    final String response = await rootBundle.loadString('assets/fortunes.txt');
    List<String> listOfFortune = response.split("\n");
    var element = listOfFortune[random.nextInt(listOfFortune.length)];
    return element;
  }

  Future<File> get _localFileIsFirstTime async {
    final path = await _localPath;
    return File('$path/is_first_time.txt');
  }

  Future<File> get _localFileDates async {
    final path = await _localPath;
    return File('$path/dates.txt');
  }

  Future<File> _localFileFortunesDate(String date) async{
    final path = await _localPath;
    return File('$path/$date.txt');
  }

  Future<String> readTime() async {
    try {
      final file = await _localFileTime;
      // Read the file
      final contents = await file.readAsString();
      if (contents.isEmpty){
        DateTime time = DateTime.now();
        time = time.add(const Duration(hours: - comeBackAfterHour - 10));
        writeTime(time.toIso8601String());
        return time.toIso8601String();
      }
      return contents;
    } catch (e) {
      // If encountering an error, return 0
      DateTime time = DateTime.now();
      time = time.add(const Duration(hours: - comeBackAfterHour - 10));
      writeTime(time.toIso8601String());
      return time.toIso8601String();
    }
  }

  Future<String> readIsFirstTime() async {
    try {
      final file = await _localFileIsFirstTime;
      // Read the file
      final contents = await file.readAsString();
      if (contents.isEmpty){
        return "true";
      }
      return contents;
    } catch (e) {
      // If encountering an error
      return "true";
    }
  }

  Future<String> readDates() async {
    try {
      final file = await _localFileDates;
      // Read the file
      final contents = await file.readAsString();
      if (contents.isEmpty){
        return "";
      }
      return contents;
    } catch (e) {
      // If encountering an error
      return "";
    }
  }

  Future<String> readFortunesForDate(String date) async {
    try {
      final file = await _localFileFortunesDate(date);
      // Read the file
      final contents = await file.readAsString();
      if (contents.isEmpty){
        return "";
      }
      return contents;
    } catch (e) {
      // If encountering an error
      return "";
    }
  }

  Future<File> writeDates(String date) async {
    final file = await _localFileDates;

    // Write the file
    //return file.writeAsString(date, mode: FileMode.append);
    return file.writeAsString(date);
  }

  Future<File> writeFortuneForDate(String date, String fortune) async {
    final file = await _localFileFortunesDate(date);

    fortune = "$fortune\n";

    // Write the file
    return file.writeAsString(fortune, mode: FileMode.append);
  }

  Future<File> writeIsFirstTime(String isFirstTime) async {
    final file = await _localFileIsFirstTime;

    // Write the file
    return file.writeAsString(isFirstTime);
  }

  Future<File> writeTime(String time) async {
    final file = await _localFileTime;

    // Write the file
    return file.writeAsString(time);
  }

  String getRemainigTime(DateTime readedTime) {

    var now = DateTime.now();
    var howMuchTimePassed = now.difference(readedTime);
    var twentyFourHour = const Duration(hours: comeBackAfterHour);
    var remainingTime = twentyFourHour - howMuchTimePassed ;

    String sDuration = "00:00:00";
    if (remainingTime > const Duration(seconds: 0)) {
      sDuration = _printDuration(remainingTime);
    }
    return sDuration;
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

}