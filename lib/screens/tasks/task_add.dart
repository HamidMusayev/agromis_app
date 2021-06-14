import 'package:aqromis_application/data/operations/list_operations.dart';
import 'package:aqromis_application/data/operations/task_operations.dart';
import 'package:aqromis_application/data/shared_prefs.dart';
import 'package:aqromis_application/models/garden.dart';
import 'package:aqromis_application/models/task.dart';
import 'package:aqromis_application/models/task_type.dart';
import 'package:aqromis_application/models/user.dart';
import 'package:aqromis_application/screens/tasks/tasks.dart';
import 'package:aqromis_application/widgets/default_button.dart';
import 'package:flutter/material.dart';
import 'package:aqromis_application/text_constants.dart' as Constants;
import 'package:lottie/lottie.dart';

import '../../constants.dart';
import '../../size_config.dart';

class TaskAddScreen extends StatefulWidget {
  @override
  _TaskAddScreenState createState() => _TaskAddScreenState();
}

class _TaskAddScreenState extends State<TaskAddScreen> {
  TaskType selectedType;
  Garden selectedGarden;
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
        title: Text(Constants.tAddTask, style: semibold16Style),
      ),
      body: Padding(
        padding: kSmallPadding,
        child: AnimatedCrossFade(
          duration: kAnimationDuration,
          firstChild: Column(
            children: <Widget>[
              Center(child: Lottie.asset("assets/lottie/loading_small.json", width: getProportionateScreenWidth(200.0))),
            ],
          ),
          secondChild: buildEntry(),
          crossFadeState: gardens.isEmpty || tasktypes.isEmpty ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        ),
      )
    );
  }

  Future<bool> sendTask() async {
    Task task = Task.tosend(
        typeId: selectedType.pin,
        gardenId: selectedGarden.pin,
        startDate: " ",
        endDate: " ",
        name: titleTxt.text,
        description: noteTxt.text);
    User user = User.fromJson(await SharedData.readJson("user"));
    return await TaskOperations.addTask(task, user);
  }

  buildEntry() {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
              color: kInputFillColor,
              borderRadius: BorderRadius.all(kDefaultRadius)),
          child: DropdownButton<TaskType>(
            isExpanded: true,
            hint: Text(Constants.tTaskType, style: semibold16Style),
            value: selectedType,
            icon: Icon(Icons.arrow_drop_down_rounded),
            iconSize: kDefaultIconSize,
            elevation: 2,
            underline: SizedBox(),
            onChanged: (TaskType newValue) =>
                setState(() => selectedType = newValue),
            items: tasktypes.map<DropdownMenuItem<TaskType>>((TaskType value) {
              return DropdownMenuItem<TaskType>(
                value: value,
                child: Text(value.name),
              );
            }).toList(),
          ),
        ),
        Divider(color: kWhiteColor),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
              color: kInputFillColor,
              borderRadius: BorderRadius.all(kDefaultRadius)),
          child: DropdownButton<Garden>(
            isExpanded: true,
            hint: Text(Constants.tTaskGarden, style: semibold16Style),
            value: selectedGarden,
            icon: Icon(Icons.arrow_drop_down_rounded),
            iconSize: kDefaultIconSize,
            elevation: 2,
            underline: SizedBox(),
            onChanged: (Garden newValue) => setState(() => selectedGarden = newValue),
            items: gardens.map<DropdownMenuItem<Garden>>((Garden value) {
              return DropdownMenuItem<Garden>(
                value: value,
                child: Text(value.name),
              );
            }).toList(),
          ),
        ),
        Divider(color: kWhiteColor),
        TextField(
            controller: titleTxt,
            maxLines: 1,
            decoration: InputDecoration(hintText: Constants.tAddTitle)),
        Divider(color: kWhiteColor),
        TextField(
            controller: noteTxt,
            maxLines: 4,
            decoration: InputDecoration(hintText: Constants.tAddNote)),
        Divider(color: kPrimaryColor, thickness: 2.0, indent: 40.0, endIndent: 40.0, height: 50.0,),
        loading ? Center(child: Lottie.asset("assets/lottie/loading_small.json", width: getProportionateScreenWidth(150.0))) :
        DefaultButton(
          text: Constants.tCreate,
          textColor: kWhiteColor,
          backColor: kPrimaryColor,
          onPress: () {
            if (selectedType == null) {
              showAlert(Constants.tTaskTypeError).timeout(
                  Duration(seconds: 3),
                  onTimeout: () => Navigator.pop(context));
            } else if (selectedGarden == null) {
              showAlert(Constants.tTaskGardenError).timeout(
                  Duration(seconds: 3),
                  onTimeout: () => Navigator.pop(context));
            } else if (noteTxt == null || noteTxt.text.trim().isEmpty) {
              showAlert(Constants.tTaskNoteError).timeout(
                  Duration(seconds: 3),
                  onTimeout: () => Navigator.pop(context));
            } else {
              setState(() => loading = true);
              sendTask().then((value) => value
                  ? Navigator.pop(context, TasksScreen())
                  : showAlert(Constants.tTaskAddError));
            }
          },
        )
      ],
    );
  }

  Future<void> showAlert(String text) {
    setState(()=> loading = false);
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black45,
      builder: (_) => AlertDialog(
        elevation: 0,
        titleTextStyle: semibold14Style,
        contentTextStyle: semibold14Style,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(kDefaultRadius)),
        title: Column(
          children: <Widget>[
            Icon(Icons.info, color: kBlueColor, size: 50.0),
            SizedBox(height: 12.0),
            Text(text, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
