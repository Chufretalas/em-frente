import 'dart:math';

import 'package:flutter/material.dart';

import '../db/activity_db_helper.dart';
import '../models/activity.dart';
import '../models/db_datetime.dart';
import '../screens/activity_form.dart';
import 'delete_confirmation_dialog.dart';

const List<Color> BG_COLORS = [
  Color.fromARGB(255, 80, 123, 145),
  Color.fromARGB(255, 68, 106, 126),
  Color.fromARGB(255, 97, 138, 159),
  Color.fromARGB(255, 77, 128, 155),
  Color.fromARGB(255, 63, 103, 124),
  Color.fromARGB(255, 90, 138, 162),
];

class ActivityViewCard extends StatefulWidget {
  final Activity activity;
  final Function refetchActivities;
  final bool isLast;

  const ActivityViewCard(
      {Key? key,
      required this.activity,
      required this.refetchActivities,
      this.isLast = false})
      : super(key: key);

  @override
  State<ActivityViewCard> createState() => _ActivityViewCardState();
}

class _ActivityViewCardState extends State<ActivityViewCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, left: 16, top: 16),
      child: Padding(
        padding:
            widget.isLast ? const EdgeInsets.only(bottom: 80) : EdgeInsets.zero,
        child: Material(
          elevation: 8,
          shadowColor: Colors.black87,
          color: BG_COLORS[Random().nextInt(BG_COLORS.length)],
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: EdgeInsets.only(right: 14, left: 14, top: 8, bottom: 8),
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  widget.activity.doneToday
                      ? Icon(
                          Icons.check_circle_sharp,
                          color: Color.fromARGB(255, 108, 227, 81),
                          size: 28,
                        )
                      : Icon(
                          Icons.cancel_sharp,
                          color: Color.fromARGB(255, 236, 74, 74),
                          size: 28,
                        ),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          widget.activity.name,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                            "Days completed: ${widget.activity.daysDone.length}"),
                      ],
                    ),
                  ),
                  InkWell(
                    child: GestureDetector(
                      child: const Icon(Icons.edit, size: 24,),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ActivityForm.editMode(
                              editActivity: widget.activity,
                            ),
                          ),
                        );
                        widget.refetchActivities();
                      },
                    ),
                  ),
                ],
              ),
            ),
            onLongPress: () async {
              var response = await showDialog(
                context: context,
                builder: (dialogContext) => DeleteConfirmationDialog(
                  title: "Delete activity",
                  description: "This action cannot be undone, are you sure?",
                ),
              );
              if (response is bool && response == true) {
                ActivityDbHelper.instance.deleteActivity(widget.activity.id!);
              }
              widget.refetchActivities();
            },
            onTap: () async {
              await ActivityDbHelper.instance.toggleDate(
                dbDatetime: DbDatetime(
                  date: DateTime.now(),
                  activityId: widget.activity.id!,
                ),
              );
              setState(() {
                widget.activity.doneToday
                    ? widget.activity.daysDone.removeLast()
                    : widget.activity.daysDone.add(
                        DbDatetime(
                          date: DateTime.now(),
                          activityId: widget.activity.id!,
                        ),
                      );
                widget.activity.doneToday = !widget.activity.doneToday;
              });
            },
          ),
        ),
      ),
    );
  }
}
