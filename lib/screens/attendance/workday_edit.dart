import 'package:attendance/helpers/loading/loading_screen.dart';
import 'package:attendance/utils/cloud/firebase_storage.dart';
import 'package:attendance/utils/cloud/storage_exceptions.dart';
import 'package:attendance/utils/cloud/user_workday.dart';
import 'package:attendance/utils/popup_message.dart';
import 'package:flutter/material.dart';

class WorkdayEdit extends StatefulWidget {
  const WorkdayEdit({super.key, required this.workday});
  final UserWorkday workday;

  @override
  State<WorkdayEdit> createState() => _WorkdayEditState();
}

class _WorkdayEditState extends State<WorkdayEdit> {
  final _cloudService = FirebaseStorage();
  late bool monday;
  late bool tuesday;
  late bool wednesday;
  late bool thursday;
  late bool friday;
  late bool saturday;
  late bool sunday;

  @override
  void initState() {
    super.initState();
    monday = widget.workday.monday;
    tuesday = widget.workday.tuesday;
    wednesday = widget.workday.wednesday;
    thursday = widget.workday.thursday;
    friday = widget.workday.friday;
    saturday = widget.workday.saturday;
    sunday = widget.workday.sunday;
  }

  Future<void> _workdayUpdate() async {
    if (!context.mounted) return;
    LoadingScreen().show(context: context, text: 'Changing...');
    final workday = UserWorkday(
        id: widget.workday.id,
        userId: widget.workday.userId,
        userName: widget.workday.userName,
        monday: monday,
        tuesday: tuesday,
        wednesday: wednesday,
        thursday: thursday,
        friday: friday,
        saturday: saturday,
        sunday: sunday);
    try {
      await _cloudService.updateUserWorkday(obj: workday);
      // ignore: use_build_context_synchronously
      showSuccess(context, 'Workday changed successfully!');
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } on PermissionDeniedException catch (_) {
      showErorr(
        context,
        'You does not have permission to change employee workday.',
      );
    } on CouldNotUpdateException catch (_) {
      showErorr(context, 'The process of changing has been canceled.');
    }
    LoadingScreen().hide();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Workday")),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              "Change ${widget.workday.userName}'s working day here.",
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: Column(
                children: [
                  checkBox("Monday"),
                  checkBox("Tuesday"),
                  checkBox("Wednesday"),
                  checkBox("Thursday"),
                  checkBox("Friday"),
                  checkBox("Saturday"),
                  checkBox("Sunday"),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _workdayUpdate,
                child: const Text("Update Workday"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row checkBox(String title) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.green;
    }

    bool value() => title == "Monday"
        ? monday
        : title == "Tuesday"
            ? tuesday
            : title == "Wednesday"
                ? wednesday
                : title == "Thursday"
                    ? thursday
                    : title == "Friday"
                        ? friday
                        : title == "Saturday"
                            ? saturday
                            : sunday;

    void onChanged(bool? value) {
      setState(() {
        switch (title) {
          case "Monday":
            monday = value!;
            break;
          case "Tuesday":
            tuesday = value!;
            break;
          case "Wednesday":
            wednesday = value!;
            break;
          case "Thursday":
            thursday = value!;
            break;
          case "Friday":
            friday = value!;
            break;
          case "Saturday":
            saturday = value!;
            break;
          default:
            sunday = value!;
        }
      });
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
        Checkbox(
          checkColor: Colors.white,
          fillColor: MaterialStateProperty.resolveWith(getColor),
          value: value(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
