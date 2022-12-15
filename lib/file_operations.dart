import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CounterStorage {
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

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      DateTime time = DateTime.now();
      writeTime(time.toIso8601String());
      return time.toIso8601String();
    }
  }

  Future<File> writeTime(String time) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$time');
  }
}