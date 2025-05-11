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
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fossevents/data/files.dart';
import 'package:fossevents/data/types.dart';
import 'package:fossevents/dialogs.dart';
import 'package:fossevents/extensions.dart';
import 'package:fossevents/main.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MyHomePage extends StatefulWidget {
  final EventDatabase db;

  const MyHomePage({super.key, required this.db});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  TreeSliverNode<EventClassWrapper>? selectedNode;
  final TreeSliverController treeController = TreeSliverController();
  late List<TreeSliverNode<EventClassWrapper>> tree = getEventTree(widget.db);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    await Files.saveDatabase(widget.db);
    return AppExitResponse.exit;
  }

  @override
  Widget build(BuildContext context) {
    DateFormat df = DateFormat.yMd();
    return Scaffold(
      appBar: AppBar(
        title: Text("${df.format(DateTime.now())} UTC+${DateTime.now().timeZoneOffset.inHours}:00, ${df.format(DateTime.timestamp())} UTC"),
        actions: [
          IconButton(
            onPressed: () {
              EventClass? ec = selectedNode?.content.ec;
              String? selectedEventType;
              if (ec is EventType) {
                selectedEventType = ec.id;
              }
              if (ec is Event) {
                selectedEventType = ec.typeId;
              }
              showDialog(
                context: context,
                builder:
                    (context) => AddEditEventConfirmationDialog(
                      eventType: selectedEventType,
                      eventTypes: widget.db.eventTypes,
                      onConfirmed: (e) {
                        widget.db.events.add(e);
                        updateTree();
                      },
                    ),
              );
            },
            icon: Icon(Icons.add),
            tooltip: "Add new event instance.",
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AddEditTypeConfirmationDialog(
                      onConfirmed: (et) {
                        widget.db.eventTypes.add(et);
                        updateTree();
                      },
                    ),
              );
            },
            icon: Icon(Icons.new_label),
            tooltip: "Add new event type.",
          ),
          IconButton(
            onPressed: () {
              TreeSliverNode<EventClassWrapper>? selection = selectedNode;
              if (selection == null) {
                Dialogs.showNoSelectionDialog(context);
              } else {
                EventClass ec = selection.content.ec;
                if (ec is Event) {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AddEditEventConfirmationDialog(
                          e: ec,
                          eventTypes: widget.db.eventTypes,
                          onConfirmed: (e) {
                            widget.db.events[selection.content.idx] = e;
                            updateTree();
                          },
                        ),
                  );
                } else if (ec is EventType) {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AddEditTypeConfirmationDialog(
                          et: ec,
                          onConfirmed: (et) {
                            widget.db.eventTypes[selection.content.idx] = et;
                            updateTree();
                          },
                        ),
                  );
                }
              }
            },
            icon: Icon(Icons.edit),
            tooltip: "Edit selection.",
          ),
          IconButton(onPressed: () => deleteSelection(), icon: Icon(Icons.delete), tooltip: "Delete selection."),
          PopupMenuButton(
            itemBuilder:
                (context) => <PopupMenuEntry>[
                  PopupMenuItem(
                    onTap: () {
                      updateTree();
                    },
                    child: Tooltip(
                      message: "Reload event tree and remove selection.",
                      child: Row(children: [Icon(Icons.refresh), SizedBox(width: 4.0), Text("Reload GUI")]),
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      Files.saveDatabase(widget.db);
                    },
                    child: Tooltip(
                      message: "Save database to internal storage. (Happens automatically on exit.)",
                      child: Row(children: [Icon(Icons.save), SizedBox(width: 4.0), Text("Save database")]),
                    ),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    onTap: () {
                      FilePicker.platform.pickFiles(allowedExtensions: ["json"], withData: true, lockParentWindow: true).then((value) {
                        if (value != null && value.files.isNotEmpty) {
                          Uint8List? bytes = value.files[0].bytes;
                          if (bytes == null) {
                            return;
                          }
                          EventDatabase db = EventDatabase.fromJson(jsonDecode(utf8.decode(bytes)));
                          for (EventType iet in db.eventTypes) {
                            bool exists = false;
                            for (EventType et in widget.db.eventTypes) {
                              if (iet.id == et.id) {
                                exists = true;
                                break;
                              }
                            }
                            if (exists) {
                              continue;
                            }
                            widget.db.eventTypes.add(iet);
                          }
                          for (Event ie in db.events) {
                            bool exists = false;
                            for (Event e in widget.db.events) {
                              if (ie.typeId == e.typeId && ie.dateTimeRange == e.dateTimeRange && ie.note == e.note) {
                                exists = true;
                              }
                            }
                            if (exists) {
                              continue;
                            }
                            widget.db.events.add(ie);
                          }
                          updateTree();
                        }
                      });
                    },
                    child: Tooltip(
                      message: "Import database from file.",
                      child: Row(children: [Icon(Icons.open_in_browser), SizedBox(width: 4.0), Text("Import database")]),
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      FilePicker.platform.saveFile(
                        fileName: "FOSSevents_Export_${DateFormat("y_M_d").format(DateTime.now())}.json",
                        allowedExtensions: ["json"],
                        bytes: utf8.encode(jsonEncode(widget.db.toJson())),
                        lockParentWindow: true,
                      );
                    },
                    child: Tooltip(
                      message: "Export database to file.",
                      child: Row(children: [Icon(Icons.save_alt), SizedBox(width: 4.0), Text("Export database")]),
                    ),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    onTap: () {
                      PackageInfo.fromPlatform().then((value) {
                        if (!context.mounted) {
                          return;
                        }
                        showAboutDialog(
                          context: context,
                          applicationName: value.appName,
                          applicationVersion: "v${value.version}",
                          applicationIcon: SvgPicture(SvgAssetLoader("assets/icon/icon.svg"), width: 96.0),
                          applicationLegalese: copyright,
                        );
                      });
                    },
                    child: Row(children: [Icon(Icons.info), SizedBox(width: 4.0), Text("About")]),
                  ),
                ],
            icon: Icon(Icons.menu),
            tooltip: "Other options.",
          ),
        ],
        actionsPadding: EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            TreeSliver<EventClassWrapper>(
              controller: treeController,
              tree: tree,
              treeNodeBuilder: (context, node, animationStyle) => eventClassTreeNodeBuilder(context, node as TreeSliverNode<EventClassWrapper>, animationStyle),
            ),
          ],
        ),
      ),
    );
  }

  void deleteSelection() {
    TreeSliverNode<EventClassWrapper>? selection = selectedNode;
    if (selection == null) {
      Dialogs.showNoSelectionDialog(context);
    } else {
      EventClass ec = selection.content.ec;
      if (ec is Event) {
        showDialog(
          context: context,
          builder:
              (context) => ConfirmationDialog(
                icon: Icon(Icons.question_mark_rounded, size: 48.0),
                title: Text("Delete Instance"),
                content: Text(
                  "Are you sure you want to delete the selected event instance (${ec.dateTimeRange.toReadableString()})?\nTHIS ACTION IS NOT UNDOABLE!",
                ),
                onConfirm: () {
                  widget.db.events.remove(ec);
                  updateTree();
                },
              ),
        );
      } else if (ec is EventType) {
        showDialog(
          context: context,
          builder:
              (context) => DeleteTypeConfirmationDialog(
                et: ec,
                onConfirm: (deleteContainedEvents) {
                  widget.db.eventTypes.remove(ec);
                  if (deleteContainedEvents) {
                    widget.db.events.removeWhere((element) => element.typeId == ec.id);
                  }
                  updateTree();
                },
              ),
        );
      }
    }
  }

  void updateTree() {
    setState(() {
      selectedNode = null;
      tree = getEventTree(widget.db);
    });
  }

  Widget eventClassTreeNodeBuilder(BuildContext context, TreeSliverNode<EventClassWrapper> node, AnimationStyle toggleAnimationStyle) {
    final Duration animationDuration = toggleAnimationStyle.duration ?? TreeSliver.defaultAnimationDuration;
    final Curve animationCurve = toggleAnimationStyle.curve ?? TreeSliver.defaultAnimationCurve;
    final int index = TreeSliverController.of(context).getActiveIndexFor(node)!;
    final EventClass ec = node.content.ec;
    ThemeData theme = Theme.of(context);
    List<Widget> children = [
      // Icon for parent nodes
      TreeSliver.wrapChildToToggleNode(
        node: node,
        child: SizedBox.square(
          dimension: 30.0,
          child:
              node.children.isNotEmpty
                  ? AnimatedRotation(
                    key: ValueKey<int>(index),
                    turns: node.isExpanded ? 0.25 : 0.0,
                    duration: animationDuration,
                    curve: animationCurve,
                    // Renders a unicode right-facing arrow. >
                    child: const Icon(Icons.arrow_forward_ios, size: 14),
                  )
                  : null,
        ),
      ),
      // Spacer
      const SizedBox(width: 8.0),
      // Content
      if (ec is Event)
        Text(
          ec.typeId == null
              ? "${ec.note} (${ec.dateTimeRange.toReadableString()})"
              : "${ec.dateTimeRange.toReadableString()}${ec.note.isEmpty ? "" : " (${ec.note})"}",
        )
      else if (ec is EventType)
        Tooltip(message: ec.desc, child: Text(ec.name))
      else if (ec is EventTypeOther)
        Text(ec.name),
    ];
    if (ec is! EventTypeOther) {
      children.addAll([
        Expanded(child: SizedBox()),
        TextButton(
          onPressed: () {
            setState(() {
              EventClass ec = node.content.ec;
              if (ec is! EventTypeOther) {
                selectedNode = node;
              }
            });
          },
          child: Text("Select"),
        ),
        SizedBox(width: 12.0),
      ]);
    }
    return ColoredBox(
      color:
          (selectedNode == node) ? (theme.brightness == Brightness.light ? theme.colorScheme.surfaceDim : theme.colorScheme.surfaceBright) : Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            treeController.toggleNode(node);
            EventClass ec = node.content.ec;
            if (ec is! EventTypeOther) {
              selectedNode = node;
            }
          });
        },
        child: Row(children: children),
      ),
    );
  }

  List<TreeSliverNode<EventClassWrapper>> getEventTree(EventDatabase db) {
    List<bool> listed = List.generate(db.events.length, (index) => false, growable: false);
    List<TreeSliverNode<EventClassWrapper>> tree = [];
    // Typed
    for (int i = 0; i < db.eventTypes.length; i++) {
      EventType et = db.eventTypes[i];
      List<TreeSliverNode<EventClassWrapper>> eList = [];
      for (int j = 0; j < db.events.length; j++) {
        Event e = db.events[j];
        if (e.typeId == et.id) {
          eList.add(TreeSliverNode(EventClassWrapper(e, j)));
          listed[j] = true;
        }
      }
      tree.add(TreeSliverNode(EventClassWrapper(et, i), children: eList));
    }
    // One-Time
    {
      List<TreeSliverNode<EventClassWrapper>> eList = [];
      for (int i = 0; i < db.events.length; i++) {
        Event e = db.events[i];
        if (e.typeId == null) {
          eList.add(TreeSliverNode(EventClassWrapper(e, i)));
          listed[i] = true;
        }
      }
      tree.add(TreeSliverNode(EventClassWrapper(EventTypeOther(name: "One-Time"), -1), children: eList));
    }
    // Untyped
    {
      List<TreeSliverNode<EventClassWrapper>> eList = [];
      for (int i = 0; i < db.events.length; i++) {
        Event e = db.events[i];
        if (!listed[i]) {
          eList.add(TreeSliverNode(EventClassWrapper(e, i)));
        }
      }
      tree.add(TreeSliverNode(EventClassWrapper(EventTypeOther(name: "Untyped"), -1), children: eList));
    }
    return tree;
  }
}
