import 'dart:async';
import 'dart:math';
import 'package:aqromis_application/data/operations/task.dart';
import 'package:aqromis_application/models/task.dart';
import 'package:aqromis_application/widgets/action_button.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:aqromis_application/text_constants.dart' as constants;
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:soundpool/soundpool.dart';
import 'package:uhf_c72_plugin/tag_epc.dart';
import 'package:uhf_c72_plugin/uhf_c72_plugin.dart';

import '../../constants.dart';
import '../../widgets/action_button.dart';
import 'tasks.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  const TaskDetailScreen(this.task);

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState(task);
}

class _TaskDetailScreenState extends State<TaskDetailScreen>
    with SingleTickerProviderStateMixin {
  Task task;
  _TaskDetailScreenState(this.task);

  late ConfettiController _controllerCenter;
  late AnimationController _animateSuccess;
  bool animateSuccess = false;
  bool animate2 = false;
  bool animate3 = false;
  List<TagEpc> _data = [];

  Soundpool pool = Soundpool.fromOptions(
      options: const SoundpoolOptions(streamType: StreamType.notification));

  @override
  void initState() {
    super.initState();
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 8));
    _animateSuccess = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    if (task.readState == 1) setState(() => task.readState = 0);
  }

  @override
  void dispose() {
    stopConnection();
    _controllerCenter.dispose();
    super.dispose();
  }

  Path drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  Future<void> stopConnection() async {
    await UhfC72Plugin.clearData;
    bool? str = await UhfC72Plugin.isStarted;
    if (str ?? false) {
      await UhfC72Plugin.stop;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkColor,
      appBar: AppBar(
          backgroundColor: kDarkColor,
          iconTheme: const IconThemeData(color: kWhiteColor),
          toolbarTextStyle: const TextTheme(
                  headline6: TextStyle(color: kWhiteColor, fontSize: 18))
              .bodyText2,
          titleTextStyle: const TextTheme(
                  headline6: TextStyle(color: kWhiteColor, fontSize: 18))
              .headline6),
      body: Stack(
        children: <Widget>[
          Container(
            padding: kSmallPadding,
            child: animateSuccess
                ? Center(
                    child: Column(
                    children: <Widget>[
                      Lottie.asset('assets/lottie/success.json',
                          width: 250, controller: _animateSuccess),
                      const Text(constants.tTaskCompletedSuccess,
                          style: headingWhiteStyle),
                    ],
                  ))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                          widget.task.readState == 0
                              ? constants.tTaskDetail
                              : widget.task.readState == 2
                                  ? constants.tTaskCompleted
                                  : constants.tResumingTask,
                          style: headingWhiteStyle),
                      Text(task.description, style: light14WhiteStyle),
                      const SizedBox(height: 12.0),
                      Row(
                        children: <Widget>[
                          const Icon(Icons.location_on_rounded,
                              size: 24.0, color: kWhiteColor),
                          Text(task.gardenName!, style: light14WhiteStyle),
                          const SizedBox(width: 12.0),
                          const Icon(Icons.receipt_rounded,
                              size: 24.0, color: kWhiteColor),
                          Text(task.type!, style: light14WhiteStyle),
                        ],
                      ),
                      const Spacer(),
                      Text((task.readedRFIDCount! + _data.length).toString(),
                          style: rfidStyle),
                      const Text(constants.tReadedRFID,
                          style: light16WhiteStyle),
                      const Spacer(),
                      task.readState == 2
                          ? buildCompleted()
                          : AnimatedCrossFade(
                              firstChild: Column(
                                children: <Widget>[
                                  ActionButton(
                                    loading: animate3,
                                    color: kRedColor,
                                    text: constants.tFinish,
                                    icon: Icons.stop_rounded,
                                    onPress: () async {
                                      setState(() => animate3 = true);
                                      await UhfC72Plugin.clearData;
                                      await UhfC72Plugin.stop;

                                      await TaskOperations.changeTaskState(
                                              task.id!, 2)
                                          .then((value) async {
                                        if (value == false) {
                                          print(
                                              'CANT CAHNGED DUE CONNECTION ERORR');
                                        } else {
                                          await TaskOperations.addRFIDToTask(
                                                  task, _data)
                                              .then((value) {
                                            if (value == false) {
                                              print('ERROR');
                                            } else {
                                              setState(
                                                  () => animateSuccess = true);
                                              _animateSuccess.forward().then(
                                                    (value) => Navigator.pop(
                                                      context,
                                                      TasksScreen(),
                                                    ),
                                                  );
                                            }
                                          });
                                        }
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 8.0),
                                  ActionButton(
                                    loading: animate2,
                                    color: kBlueColor,
                                    text: constants.tPause,
                                    icon: Icons.pause_rounded,
                                    onPress: () async {
                                      setState(() => animate2 = true);
                                      await UhfC72Plugin.clearData;
                                      await UhfC72Plugin.stop;
                                      await TaskOperations.addRFIDToTask(
                                              task, _data)
                                          .then((value) {
                                        if (value == false) {
                                          print('ERROR');
                                        } else {
                                          _animateSuccess.forward().then(
                                              (value) => Navigator.pop(
                                                  context, TasksScreen()));
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                              secondChild: ActionButton(
                                loading: false,
                                color: kBlueColor,
                                text: constants.tStart,
                                icon: Icons.play_arrow_rounded,
                                onPress: task.readState == 1
                                    ? () async {
                                        UhfC72Plugin.clearData;
                                        UhfC72Plugin.tagsStatusStream
                                            .receiveBroadcastStream()
                                            .listen(updateTags);
                                        await UhfC72Plugin.startContinuous
                                            .then((value) async {
                                          if (value ?? false) {
                                            setState(() => task.readState = 1);
                                          }
                                        });
                                      }
                                    : () async {
                                        UhfC72Plugin.clearData;
                                        UhfC72Plugin.tagsStatusStream
                                            .receiveBroadcastStream()
                                            .listen(updateTags);
                                        await UhfC72Plugin.startContinuous
                                            .then((value) async {
                                          if (value ?? false) {
                                            setState(() => task.readState = 1);
                                            await TaskOperations
                                                    .changeTaskState(
                                                        task.id!, 1)
                                                .then((value) => value != false
                                                    ? print('CHANGED')
                                                    : print(
                                                        'CANT CHANGED DUE CONNECTION'));
                                          }
                                        });
                                      },
                              ),
                              crossFadeState: task.readState == 0
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 500))
                    ],
                  ),
          ),
          Positioned(
            top: 52,
            left: 18,
            child: ConfettiWidget(
              confettiController: _controllerCenter,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                kGreenColor,
                kBlueColor,
                kRedColor,
                kYellowColor,
              ],
              createParticlePath: drawStar,
            ),
          ),
          Positioned(
            top: 52,
            right: -40,
            child: Icon(
              Icons.speaker_phone_rounded,
              size: 220,
              color: kWhiteColor.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  void updateTags(dynamic result) {
    _controllerCenter.stop();
    int old = _data.length;
    setState(() => _data = TagEpc.parseTags(result));
    int end = _data.length;
    if (old != end) {
      _controllerCenter.play();
      playSound();
    }
  }

  buildCompleted() {
    return ActionButton(
      loading: false,
      color: kPrimaryColor,
      text: constants.tTaskCompleted,
      icon: Icons.check_rounded,
      onPress: () async {},
    );
  }

  Future playSound() async {
    int soundId = await rootBundle
        .load('assets/sounds/barcodebeep.ogg')
        .then((ByteData soundData) {
      return pool.load(soundData);
    });
    await pool.play(soundId);
  }
}
