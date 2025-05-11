/*
 * FOSS event logger.
 * Copyright (C) 2025-present Janosch Lion
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 */

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
