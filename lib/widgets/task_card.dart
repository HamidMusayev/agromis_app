import 'package:aqromis_application/constants.dart';
import 'package:aqromis_application/models/task.dart';
import 'package:flutter/material.dart';
import 'package:aqromis_application/text_constants.dart' as constants;

class TaskCard extends StatefulWidget {
  final Task task;
  final Function onPress;

  const TaskCard({required this.task, required this.onPress});
  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> widget.onPress.call(),
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 12.0, top: 12.0, bottom: 12.0),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(kDefaultRadius),
                color: getColor(widget.task.readState!)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Icon(Icons.location_on_rounded,
                        size: kDefaultIconSize, color: kWhiteColor),
                    Flexible(
                      child: Text(
                          '${widget.task.gardenName!} - ${widget.task.type!}',
                          style: semibold16WhiteStyle,
                          overflow: TextOverflow.fade,
                          softWrap: true),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(constants.tTaskAuthor + widget.task.createdUser!,
                          style: light12WhiteStyle),
                      Text(constants.tTaskStartDate + widget.task.startDate,
                          style: light12WhiteStyle),
                      Text(constants.tTaskEndDate + widget.task.endDate,
                          style: light12WhiteStyle),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 12,
            right: 0,
            child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        bottomLeft: Radius.circular(15.0)),
                    color: Colors.black26),
                child: Text(widget.task.readedRFIDCount.toString(),
                    style: semibold16WhiteStyle)),
          ),
          Positioned(
            right: 0.0,
            bottom: 0.0,
            child: Icon(getIcon(widget.task.readState!),
                color: Colors.white30, size: kLargeIconSize),
          )
        ],
      ),
    );
  }

  Color getColor(int colorType) {
    switch (colorType) {
      case 0:
        return Colors.blue.withOpacity(0.9);
      case 1:
        return Colors.amber.withOpacity(0.9);
      case 2:
        return Colors.green.withOpacity(0.9);
      default:
        return kBlueColor;
    }
  }

  IconData getIcon(int iconType) {
    switch (iconType) {
      case 0:
        return Icons.play_arrow_rounded;
      case 1:
        return Icons.pause_rounded;
      case 2:
        return Icons.stop_rounded;
      default:
        return Icons.play_arrow_rounded;
    }
  }
}
