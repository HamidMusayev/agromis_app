import 'dart:async';

import 'package:aqromis_application/data/operations/task.dart';
import 'package:aqromis_application/models/task.dart';
import 'package:aqromis_application/screens/tasks/task_detail.dart';
import 'package:aqromis_application/widgets/task_card.dart';
import 'package:flutter/material.dart';
import 'package:aqromis_application/text_constants.dart' as constants;
import 'package:lottie/lottie.dart';

import '../../constants.dart';

class CompletedTasksScreen extends StatefulWidget {
  @override
  _CompletedTasksScreenState createState() => _CompletedTasksScreenState();
}

class _CompletedTasksScreenState extends State<CompletedTasksScreen> {
  bool loading = true;
  List<Task> tasks = [];

  @override
  void initState() {
    getTasks();
    super.initState();
  }

  void getTasks() async {
    setState(() => loading = true);

    await TaskOperations.getTaskList(true).then((value) {
      if (value != false) {
        tasks = value;
        setState(() => loading = false);
      } else {
        ///TODO GET FROM LOCAL
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(constants.tTaskComplete, style: semibold16Style)),
      body: AnimatedCrossFade(
        duration: kAnimationDuration,
        crossFadeState:
            loading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        firstChild: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(
              child: Center(
                child: Lottie.asset('assets/lottie/loading.json', width: 200),
              ),
            )
          ],
        ),
        secondChild: ListView.separated(
          shrinkWrap: true,
          itemCount: tasks.length,
          padding: kSmallPadding,
          itemBuilder: (context, i) {
            return TaskCard(
                task: tasks[i], onPress: () => gotoTaskDetail(tasks[i]));
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        ),
      ),
    );
  }

  FutureOr onGoBack(dynamic value) {
    getTasks();
  }

  void gotoTaskDetail(Task task) {
    Route route =
        MaterialPageRoute(builder: (context) => TaskDetailScreen(task));
    Navigator.push(context, route).then(onGoBack);
  }
}
