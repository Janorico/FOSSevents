import 'dart:convert';
import 'dart:io';

import 'package:fossevents/data/types.dart';
import 'package:path_provider/path_provider.dart';

class Files {
  static String? _dbPath;

  static Future<String> get dbPath async {
    _dbPath ??= "${(await getApplicationSupportDirectory()).path}/data/db.json";
    return _dbPath!;
  }

  static Future<EventDatabase> loadDatabase() async {
    return databaseFromFile(await dbPath);
  }

  static Future<EventDatabase> databaseFromFile(String path) async {
    File f = File(path);
    if (!await f.exists()) {
      return EventDatabase();
    }
    return EventDatabase.fromJson(jsonDecode(await f.readAsString()));
  }

  static Future saveDatabase(EventDatabase db) async {
    return databaseToFile(db, await dbPath);
  }

  static Future databaseToFile(EventDatabase db, String path) async {
    File f = File(path);
    await f.parent.create(recursive: true);
    await f.writeAsString(jsonEncode(db.toJson()), flush: true);
  }
}
