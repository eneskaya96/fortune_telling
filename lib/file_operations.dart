import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CounterStorage {
  static const int  come_back_after_hour = 5;

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFileTime async {
    final path = await _localPath;
    return File('$path/time.txt');
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
        return "X";
      }
      return contents;
    } catch (e) {
      // If encountering an error
      return "X";
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

    // Write the file
    return file.writeAsString(fortune);
  }

  Future<File> writeIsFirstTime(String isFirstTime) async {
    final file = await _localFileIsFirstTime;

    // Write the file
    return file.writeAsString('$isFirstTime');
  }

  Future<File> writeTime(String time) async {
    final file = await _localFileTime;

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