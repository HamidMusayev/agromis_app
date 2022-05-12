import 'package:aqromis_application/data/operations/list.dart';
import 'package:aqromis_application/data/operations/task.dart';
import 'package:aqromis_application/data/shared_prefs.dart';
import 'package:aqromis_application/models/garden.dart';
import 'package:aqromis_application/models/task.dart';
import 'package:aqromis_application/models/task_type.dart';
import 'package:aqromis_application/models/user.dart';
import 'package:aqromis_application/screens/tasks/tasks.dart';
import 'package:aqromis_application/widgets/default_button.dart';
import 'package:flutter/material.dart';
import 'package:aqromis_application/text_constants.dart' as constants;
import 'package:lottie/lottie.dart';

import '../../constants.dart';

class TaskAddScreen extends StatefulWidget {
  @override
  _TaskAddScreenState createState() => _TaskAddScreenState();
}

class _TaskAddScreenState extends State<TaskAddScreen> {
  TaskType? selectedType;
  Garden? selectedGarden;
  TextEditingController titleTxt = TextEditingController();
  TextEditingController noteTxt = TextEditingController();
  bool loading = false;

  List<Garden> gardens = [];
  List<TaskType> tasktypes = [];

  @override
  void initState() {
    ListOperations.getGardenList().then(
        (value) => value != false ? setState(() => gardens = value) : null);
    ListOperations.getTaskTypeList().then(
        (value) => value != false ? setState(() => tasktypes = value) : null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text(constants.tAddTask, style: semibold16Style),
        ),
        body: Padding(
          padding: kSmallPadding,
          child: AnimatedCrossFade(
            duration: kAnimationDuration,
            firstChild: Column(
              children: <Widget>[
                Center(
                  child: Lottie.asset('assets/lottie/loading_small.json',
                      width: 200),
                ),
              ],
            ),
            secondChild: buildEntry(),
            crossFadeState: gardens.isEmpty || tasktypes.isEmpty
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
          ),
        ));
  }

  Future<bool> sendTask() async {
    Task task = Task.tosend(
        typeId: selectedType!.pin,
        gardenId: selectedGarden!.pin,
        startDate: ' ',
        endDate: ' ',
        name: titleTxt.text,
        description: noteTxt.text);
    User user = User.fromJson(await SharedData.readJson('user'));
    return await TaskOperations.addTask(task, user);
  }

  buildEntry() {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: const BoxDecoration(
              color: kInputFillColor,
              borderRadius: BorderRadius.all(kDefaultRadius)),
          child: DropdownButton<TaskType>(
            isExpanded: true,
            hint: const Text(constants.tTaskType, style: semibold16Style),
            value: selectedType,
            icon: const Icon(Icons.arrow_drop_down_rounded),
            iconSize: kDefaultIconSize,
            elevation: 2,
            underline: const SizedBox(),
            onChanged: (TaskType? newValue) =>
                setState(() => selectedType = newValue),
            items: tasktypes.map<DropdownMenuItem<TaskType>>((TaskType value) {
              return DropdownMenuItem<TaskType>(
                value: value,
                child: Text(value.name),
              );
            }).toList(),
          ),
        ),
        const Divider(color: kWhiteColor),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: const BoxDecoration(
              color: kInputFillColor,
              borderRadius: BorderRadius.all(kDefaultRadius)),
          child: DropdownButton<Garden>(
            isExpanded: true,
            hint: const Text(constants.tTaskGarden, style: semibold16Style),
            value: selectedGarden,
            icon: const Icon(Icons.arrow_drop_down_rounded),
            iconSize: kDefaultIconSize,
            elevation: 2,
            underline: const SizedBox(),
            onChanged: (Garden? newValue) =>
                setState(() => selectedGarden = newValue),
            items: gardens.map<DropdownMenuItem<Garden>>((Garden value) {
              return DropdownMenuItem<Garden>(
                value: value,
                child: Text(value.name),
              );
            }).toList(),
          ),
        ),
        const Divider(color: kWhiteColor),
        TextField(
            controller: titleTxt,
            maxLines: 1,
            decoration: const InputDecoration(hintText: constants.tAddTitle)),
        const Divider(color: kWhiteColor),
        TextField(
            controller: noteTxt,
            maxLines: 4,
            decoration: const InputDecoration(hintText: constants.tAddNote)),
        const Divider(
          color: kPrimaryColor,
          thickness: 2.0,
          indent: 40.0,
          endIndent: 40.0,
          height: 50.0,
        ),
        loading
            ? Center(
                child: Lottie.asset('assets/lottie/loading_small.json',
                    width: 150))
            : DefaultButton(
                text: constants.tCreate,
                textColor: kWhiteColor,
                backColor: kPrimaryColor,
                onPress: () {
                  if (selectedType == null) {
                    showAlert(constants.tTaskTypeError).timeout(
                        const Duration(seconds: 3),
                        onTimeout: () => Navigator.pop(context));
                  } else if (selectedGarden == null) {
                    showAlert(constants.tTaskGardenError).timeout(
                        const Duration(seconds: 3),
                        onTimeout: () => Navigator.pop(context));
                  } else if (noteTxt.text.trim().isEmpty || titleTxt.text.trim().isEmpty) {
                    showAlert(constants.tTaskNoteError).timeout(
                        const Duration(seconds: 3),
                        onTimeout: () => Navigator.pop(context));
                  } else {
                    setState(() => loading = true);
                    sendTask().then((value) => value
                        ? Navigator.pop(context, TasksScreen())
                        : showAlert(constants.tTaskAddError));
                  }
                },
              )
      ],
    );
  }

  Future<void> showAlert(String text) {
    setState(() => loading = false);
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black45,
      builder: (_) => AlertDialog(
        elevation: 0,
        titleTextStyle: semibold14Style,
        contentTextStyle: semibold14Style,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(kDefaultRadius)),
        title: Column(
          children: <Widget>[
            const Icon(Icons.info, color: kBlueColor, size: 50.0),
            const SizedBox(height: 12.0),
            Text(text, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
