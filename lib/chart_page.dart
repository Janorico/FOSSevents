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

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fossevents/data/types.dart';
import 'package:fossevents/extensions.dart';
import 'package:intl/intl.dart';

class ChartPage extends StatelessWidget {
  final EventDatabase db;
  final String typeId;

  const ChartPage({super.key, required this.db, required this.typeId});

  @override
  Widget build(BuildContext context) {
    EventType type = db.eventTypes.firstWhere((element) => element.id == typeId);
    List<Event> events = db.events.where((element) => element.typeId == typeId).toList(growable: false);
    events.sort((a, b) => a.dateTimeRange.start.compareTo(b.dateTimeRange.start));
    List<CandlestickSpot> spots = [];
    int startYear = events.first.dateTimeRange.start.year;
    for (Event e in events) {
      double year = e.dateTimeRange.start.year - startYear.toDouble();
      double start =
          e.dateTimeRange.start.month.toDouble() + ((e.dateTimeRange.start.day + (e.dateTimeRange.start.hour + e.dateTimeRange.start.minute / 60) / 24) / 31);
      double end = e.dateTimeRange.end.month.toDouble() + ((e.dateTimeRange.end.day + (e.dateTimeRange.end.hour + e.dateTimeRange.end.minute / 60) / 24) / 31);
      if (end - start < 0.1) {
        start -= 0.1;
        end += 0.1;
      }
      spots.add(CandlestickSpot(x: year, open: start, high: end, low: start, close: end));
    }
    return Scaffold(
      appBar: AppBar(title: Text("${type.name}, ${type.frequency.name}, (${type.desc})")),
      body: Padding(
        padding: EdgeInsetsGeometry.fromLTRB(10.0, 0.0, 10.0, 10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              type.frequency == EventFrequency.yearly
                  ? AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CandlestickChart(
                      CandlestickChartData(
                        candlestickSpots: spots,
                        minY: 1,
                        maxY: 12,
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) => Text(DateFormat.MMM().format(DateTime(0, value.toInt()))),
                              reservedSize: 35,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  : Text("Non-yearly frequencies aren't supported yet."),
              for (Event e in events) ListTile(title: Text(e.dateTimeRange.toReadableString()), subtitle: Text(e.note.isEmpty ? "(No note)" : e.note)),
            ],
          ),
        ),
      ),
    );
  }
}
