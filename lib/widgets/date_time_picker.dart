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
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 */

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimePicker extends StatefulWidget {
  final DateTime dateTime;
  final ValueChanged<DateTime> onDateChanged;

  const DateTimePicker({super.key, required this.dateTime, required this.onDateChanged});

  @override
  State<StatefulWidget> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  late DateTime dateTime;

  @override
  void initState() {
    super.initState();
    dateTime = widget.dateTime;
  }

  @override
  void didUpdateWidget(DateTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    dateTime = widget.dateTime;
  }

  @override
  Widget build(BuildContext context) {
    DateFormat df = DateFormat.yMd();
    DateFormat tf = DateFormat.Hm();
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () {
              showDatePicker(context: context, initialDate: dateTime, firstDate: DateTime.utc(0), lastDate: DateTime.now()).then((value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  dateTime = DateTime(value.year, value.month, value.day, dateTime.hour, dateTime.minute);
                  widget.onDateChanged(dateTime);
                });
              });
            },
            child: Text(df.format(dateTime)),
          ),
        ),
        Expanded(
          child: TextButton(
            onPressed: () {
              showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(dateTime)).then((value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  dateTime = DateTime(dateTime.year, dateTime.month, dateTime.day, value.hour, value.minute);
                  widget.onDateChanged(dateTime);
                });
              });
            },
            child: Text(tf.format(dateTime)),
          ),
        ),
      ],
    );
  }
}
