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
import 'package:fossevents/data/types.dart';
import 'package:fossevents/widgets/date_time_picker.dart';

class Dialogs {
  static void showNoSelectionDialog(BuildContext context) {
    showAlertDialog(context: context, icon: Icon(Icons.warning, size: 64.0), title: Text("No selection!"));
  }

  static void showAlertDialog({required BuildContext context, Widget? icon, Widget? title, Widget? content}) {
    showDialog(
      context: context,
      builder:
          (context) =>
              AlertDialog(icon: icon, title: title, content: content, actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text("OK"))]),
    );
  }
}

class AddEditEventConfirmationDialog extends StatefulWidget {
  final Event? e;
  final String? eventType;
  final List<EventType> eventTypes;
  final Function(Event e)? onConfirmed;

  const AddEditEventConfirmationDialog({super.key, this.e, this.eventType, required this.eventTypes, this.onConfirmed});

  @override
  State<StatefulWidget> createState() => _AddEditEventConfirmationDialogState();
}

class _AddEditEventConfirmationDialogState extends State<AddEditEventConfirmationDialog> {
  late String? typeId;
  late DateTimeRange dateTimeRange;
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    typeId = widget.e?.typeId ?? widget.eventType;
    dateTimeRange = widget.e?.dateTimeRange ?? DateTimeRange(start: DateTime.now(), end: DateTime.now());
    noteController.text = widget.e?.note ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return ConfirmationDialog(
      title: Text(widget.e == null ? "Add event..." : "Edit event..."),
      content: Column(
        spacing: 8.0,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            spacing: 8.0,
            children: [
              Expanded(child: Text("Type:")),
              Expanded(
                flex: 2,
                child: DropdownMenu(
                  expandedInsets: EdgeInsetsGeometry.zero,
                  requestFocusOnTap: false,
                  dropdownMenuEntries: [
                    DropdownMenuEntry(value: null, label: "One-Time"),
                    for (EventType et in widget.eventTypes) DropdownMenuEntry(value: et.id, label: et.name),
                  ],
                  initialSelection: typeId,
                  onSelected: (value) {
                    typeId = value;
                  },
                ),
              ),
            ],
          ),
          Row(
            spacing: 8.0,
            children: [
              Expanded(child: Text("From:")),
              Expanded(
                flex: 2,
                child: DateTimePicker(
                  dateTime: dateTimeRange.start,
                  onDateChanged: (dt) {
                    setState(() {
                      dateTimeRange = DateTimeRange(start: dt, end: dateTimeRange.end.isAfter(dt) ? dateTimeRange.end : dt);
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            spacing: 8.0,
            children: [
              Expanded(child: Text("To:")),
              Expanded(
                flex: 2,
                child: DateTimePicker(
                  dateTime: dateTimeRange.end,
                  onDateChanged: (dt) {
                    setState(() {
                      dateTimeRange = DateTimeRange(start: dateTimeRange.start.isBefore(dt) ? dateTimeRange.start : dt, end: dt);
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            spacing: 8.0,
            children: [
              Expanded(child: Text("Note:")),
              Expanded(
                flex: 2,
                child: AnimatedSize(
                  duration: Duration(milliseconds: 100),
                  curve: Curves.easeInOut,
                  child: TextField(maxLines: null, controller: noteController),
                ),
              ),
            ],
          ),
        ],
      ),
      onConfirm: () {
        if (widget.onConfirmed != null) {
          widget.onConfirmed!(Event(typeId: typeId, dateTimeRange: dateTimeRange, note: noteController.text));
        }
      },
    );
  }
}

class AddEditTypeConfirmationDialog extends StatefulWidget {
  final EventType? et;
  final Function(EventType et)? onConfirmed;

  const AddEditTypeConfirmationDialog({super.key, this.et, this.onConfirmed});

  @override
  State<StatefulWidget> createState() => _AddEditTypeConfirmationDialogState();
}

class _AddEditTypeConfirmationDialogState extends State<AddEditTypeConfirmationDialog> {
  final TextEditingController nameController = TextEditingController();
  late EventFrequency frequency;
  final TextEditingController descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.et?.name ?? "";
    frequency = widget.et?.frequency ?? EventFrequency.yearly;
    descController.text = widget.et?.desc ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return ConfirmationDialog(
      title: Text(widget.et == null ? "Add event type..." : "Edit event type..."),
      content: Column(
        spacing: 8.0,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(spacing: 8.0, children: [Expanded(child: Text("Name:")), Expanded(flex: 2, child: TextField(controller: nameController))]),
          Row(
            spacing: 8.0,
            children: [
              Expanded(child: Text("Frequency:")),
              Expanded(
                flex: 2,
                child: DropdownMenu(
                  expandedInsets: EdgeInsetsGeometry.zero,
                  requestFocusOnTap: false,
                  dropdownMenuEntries: [for (EventFrequency ef in EventFrequency.values) DropdownMenuEntry(value: ef, label: ef.name)],
                  initialSelection: frequency,
                  onSelected: (value) {
                    frequency = value!;
                  },
                ),
              ),
            ],
          ),
          Row(
            spacing: 8.0,
            children: [
              Expanded(child: Text("Description:")),
              Expanded(
                flex: 2,
                child: AnimatedSize(
                  duration: Duration(milliseconds: 100),
                  curve: Curves.easeInOut,
                  child: TextField(maxLines: null, controller: descController),
                ),
              ),
            ],
          ),
        ],
      ),
      onConfirm: () {
        if (widget.onConfirmed != null) {
          widget.onConfirmed!(EventType(name: nameController.text, id: widget.et?.id, frequency: frequency, desc: descController.text));
        }
      },
    );
  }
}

class DeleteTypeConfirmationDialog extends StatefulWidget {
  final EventType et;
  final Function(bool deleteContainedEvents)? onConfirm;
  final Function? onCancel;

  const DeleteTypeConfirmationDialog({super.key, required this.et, this.onConfirm, this.onCancel});

  @override
  State createState() => _DeleteTypeConfirmationDialogState();
}

class _DeleteTypeConfirmationDialogState extends State<DeleteTypeConfirmationDialog> {
  bool? deleteContainedEvents = true;

  @override
  Widget build(BuildContext context) {
    return ConfirmationDialog(
      icon: Icon(Icons.question_mark_rounded, size: 48.0),
      title: Text("Delete Type"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Are you sure you want to delete the event type \"${widget.et.name}\" (ID: ${widget.et.id})?\nTHIS ACTION IS NOT UNDOABLE!"),
          SizedBox(height: 8.0),
          Tooltip(
            message:
                "If enabled, deletes all contained event instances as well.\nIf disabled, all contained instances will be moved to the \"Untyped\" category,\nand can be retyped by creating a type with a matching ID.",
            child: CheckboxListTile(
              title: Text("Delete contained events (recommended)."),
              value: deleteContainedEvents,
              onChanged: (value) {
                setState(() {
                  deleteContainedEvents = value;
                });
              },
            ),
          ),
        ],
      ),
      onConfirm: () {
        if (widget.onConfirm != null) {
          widget.onConfirm!(deleteContainedEvents!);
        }
      },
    );
  }
}

class ConfirmationDialog extends StatelessWidget {
  final Widget? icon;
  final Widget? title;
  final Widget? content;
  final bool popOnConfirm;
  final bool popOnCancel;
  final Function? onConfirm;
  final Function? onCancel;

  const ConfirmationDialog({super.key, this.icon, this.title, this.content, this.popOnConfirm = true, this.popOnCancel = true, this.onConfirm, this.onCancel});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: icon,
      title: title,
      content: content,
      actions: [
        TextButton(
          onPressed: () {
            if (popOnConfirm) {
              Navigator.of(context).pop();
            }
            if (onConfirm != null) onConfirm!();
          },
          child: Text("OK"),
        ),
        TextButton(
          onPressed: () {
            if (popOnCancel) {
              Navigator.of(context).pop();
            }
            if (onCancel != null) onCancel!();
          },
          child: Text("Cancel"),
        ),
      ],
    );
  }
}
