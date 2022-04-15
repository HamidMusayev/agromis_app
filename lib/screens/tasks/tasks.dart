import 'dart:async';
import 'package:aqromis_application/data/operations/task_operations.dart';
import 'package:aqromis_application/models/task.dart';
import 'package:aqromis_application/screens/tasks/completed_tasks.dart';
import 'package:aqromis_application/screens/tasks/task_add.dart';
import 'package:aqromis_application/screens/tasks/task_detail.dart';
import 'package:aqromis_application/widgets/task_card.dart';
import 'package:flutter/material.dart';
import 'package:aqromis_application/text_constants.dart' as Constants;
import 'package:lottie/lottie.dart';

import '../../constants.dart';

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool loading = true;
  List<Task> tasks = [];

  @override
  void initState() {
    getTasks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Constants.tMyTasks, style: semibold16Style),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.history_rounded, size: kDefaultIconSize),
              tooltip: Constants.tTaskComplete,
              onPressed: gotoCompletedTasks)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(kDefaultRadius)),
        tooltip: Constants.tAddTask,
        child: const Icon(Icons.add_rounded, size: 40.0),
        backgroundColor: kTextColor,
        onPressed: () => gotoTaskAdd(),
      ),
      body: AnimatedCrossFade(
        duration: kAnimationDuration,
        crossFadeState:
            loading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        firstChild: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(
              child: Center(
                child: Lottie.asset('assets/lottie/loading.json', width: 70),
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
              task: tasks[i],
              onPress: () => gotoTaskDetail(tasks[i]),
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
        ),
      ),
    );
  }

  void getTasks() async {
    setState(() => loading = true);

    await TaskOperations.getTaskList(false).then((value) {
      if (value != false) {
        tasks = value;
        setState(() => loading = false);
      } else {
        ///TODO GET FROM LOCAL
      }
    });
  }

  FutureOr onGoBack(dynamic value) {
    getTasks();
  }

  void gotoTaskAdd() {
    Route route = MaterialPageRoute(builder: (context) => TaskAddScreen());
    Navigator.push(context, route).then(onGoBack);
  }

  void gotoTaskDetail(Task task) {
    Route route =
        MaterialPageRoute(builder: (context) => TaskDetailScreen(task));
    Navigator.push(context, route).then(onGoBack);
  }

  void gotoCompletedTasks() {
    Route route =
        MaterialPageRoute(builder: (context) => CompletedTasksScreen());
    Navigator.push(context, route).then(onGoBack);
  }
}
