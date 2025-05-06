import 'package:flutter/material.dart';
import 'package:fossevents/data/types.dart';
import 'package:fossevents/main_page.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'data/files.dart';

final String copyright = """FOSS event logger.
Copyright (C) 2025-present Janosch Lion

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.""";

void main() {
  initializeDateFormatting();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FOSSevents',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange, brightness: MediaQuery.platformBrightnessOf(context))),
      home: FutureBuilder(
        future: Files.loadDatabase(),
        builder: (context, snapshot) {
          EventDatabase? data = snapshot.data;
          if (snapshot.hasData && data != null) {
            return MyHomePage(db: data);
          }
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(Icons.error, size: 64, color: Colors.red), Text(snapshot.error.toString())],
                ),
              ),
            );
          }
          return Scaffold(
            body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), Text("Loading database...")])),
          );
        },
      ),
    );
  }
}
