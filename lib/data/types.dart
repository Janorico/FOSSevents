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
  DateTime dateTime;
  String note;

  Event({required this.typeId, required this.dateTime, required this.note});

  Map<String, String> toJson() {
    return {"type_id": typeId ?? "null", "timestamp": dateTime.toUtc().toIso8601String(), "note": note};
  }

  static Event fromJson(Map json) {
    switch (json) {
      case {'type_id': String? typeId, 'timestamp': String dateTime, 'note': String note}:
        {
          if (typeId == "null") {
            typeId = null;
          }
          return Event(typeId: typeId, dateTime: DateTime.parse(dateTime).toUtc(), note: note);
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
