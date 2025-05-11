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

import 'package:flutter/material.dart';

class EventDatabase {
  List<Event> events = [];
  List<EventType> eventTypes = [];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> m = {};
    // Events
    List<Map<String, String>> eList = [];
    for (Event e in events) {
      eList.add(e.toJson());
    }
    m["events"] = eList;
    // Event Types
    List<Map<String, String>> etList = [];
    for (EventType et in eventTypes) {
      etList.add(et.toJson());
    }
    m["event_types"] = etList;

    return m;
  }

  static EventDatabase fromJson(Map<String, dynamic> json) {
    switch (json) {
      case {'events': List events, 'event_types': List eventTypes}:
        {
          EventDatabase db = EventDatabase();
          for (Map e in events) {
            db.events.add(Event.fromJson(e));
          }
          for (Map et in eventTypes) {
            db.eventTypes.add(EventType.fromJson(et));
          }
          return db;
        }
      case _:
        throw FormatException("Failed to create database from JSON data.");
    }
  }
}

class EventClassWrapper {
  final EventClass ec;
  final int idx;

  const EventClassWrapper(this.ec, this.idx);
}

interface class EventClass {}

class Event extends EventClass {
  String? typeId;
  late DateTimeRange dateTimeRange;
  String note;

  Event({required this.typeId, required DateTimeRange dateTimeRange, required this.note}) {
    this.dateTimeRange = DateTimeRange(start: dateTimeRange.start.toUtc(), end: dateTimeRange.end.toUtc());
  }

  Map<String, String> toJson() {
    return {
      "type_id": typeId ?? "null",
      "time_range_start": dateTimeRange.start.toUtc().toIso8601String(),
      "time_range_end": dateTimeRange.end.toUtc().toIso8601String(),
      "note": note,
    };
  }

  static Event fromJson(Map json) {
    switch (json) {
      case {'type_id': String? typeId, 'timestamp': String timestamp, 'note': String note}:
        {
          if (typeId == "null") {
            typeId = null;
          }
          DateTime dt = DateTime.parse(timestamp);
          return Event(typeId: typeId, dateTimeRange: DateTimeRange(start: dt, end: dt), note: note);
        }
      case {'type_id': String? typeId, 'time_range_start': String timeRangeStart, 'time_range_end': String timeRangeEnd, 'note': String note}:
        {
          if (typeId == "null") {
            typeId = null;
          }
          return Event(
            typeId: typeId,
            dateTimeRange: DateTimeRange(start: DateTime.parse(timeRangeStart).toUtc(), end: DateTime.parse(timeRangeEnd).toUtc()),
            note: note,
          );
        }
      case _:
        throw FormatException("Failed to create event from JSON data.");
    }
  }
}

class EventType extends EventClass {
  String name;
  late String id;
  EventFrequency frequency;
  String desc;

  EventType({required this.name, String? id, required this.frequency, required this.desc}) {
    if (id != null) {
      this.id = id;
    } else {
      String cId = "";
      cId = name.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_');
      this.id = cId;
    }
  }

  Map<String, String> toJson() {
    return {"name": name, "id": id, "frequency": frequency.toString(), "desc": desc};
  }

  static EventType fromJson(Map json) {
    switch (json) {
      case {'name': String name, 'id': String id, 'frequency': String frequency, 'desc': String desc}:
        {
          return EventType(name: name, id: id, frequency: EventFrequency.fromString(frequency), desc: desc);
        }
      case _:
        throw FormatException("Failed to create event type from JSON data.");
    }
  }
}

class EventTypeOther extends EventClass {
  String name;

  EventTypeOther({required this.name});
}

enum EventFrequency {
  daily,
  weekly,
  monthly,
  yearly;

  static EventFrequency fromString(String s) {
    return switch (s) {
      "daily" => EventFrequency.daily,
      "weekly" => EventFrequency.weekly,
      "monthly" => EventFrequency.monthly,
      "yearly" => EventFrequency.yearly,
      _ => throw FormatException("Can't convert string $s to event frequency."),
    };
  }

  @override
  String toString() {
    return name;
  }
}
