import 'package:attendance/enums/action.dart' show WeekdayAction;
import 'package:attendance/helpers/loading/loading_screen.dart';
import 'package:attendance/api/cloud/firebase_storage.dart';
import 'package:attendance/api/cloud/storage_exceptions.dart';
import 'package:attendance/api/cloud/user_workday.dart';
import 'package:attendance/helpers/popup_message.dart';
import 'package:attendance/widget/appbar.dart';
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
      sunday: sunday,
    );

    String? successMessage;
    try {
      await _cloudService.updateUserWorkday(obj: workday);
      successMessage = 'Workday changed successfully!';
    } on PermissionDeniedException catch (_) {
      showErorr(
        context,
        'You does not have permission to change employee workday.',
      );
    } on CouldNotUpdateException catch (_) {
      showErorr(context, 'The process of changing has been canceled.');
    } finally {
      if (successMessage != null) {
        showSuccess(context, successMessage);
        Navigator.pop(context);
      }
    }
    LoadingScreen().hide();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(titleText: "Edit Workday"),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
                  checkBox(WeekdayAction.monday),
                  checkBox(WeekdayAction.tuesday),
                  checkBox(WeekdayAction.wednesday),
                  checkBox(WeekdayAction.thursday),
                  checkBox(WeekdayAction.friday),
                  checkBox(WeekdayAction.saturday),
                  checkBox(WeekdayAction.sunday),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: OutlinedButton(
                onPressed: _workdayUpdate,
                child: const Text("Update Workday"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row checkBox(WeekdayAction action) {
    String title() {
      switch (action) {
        case WeekdayAction.monday:
          return "Monday";
        case WeekdayAction.tuesday:
          return "Tuesday";
        case WeekdayAction.wednesday:
          return "Wednesday";
        case WeekdayAction.thursday:
          return "Thursday";
        case WeekdayAction.friday:
          return "Friday";
        case WeekdayAction.saturday:
          return "Saturday";
        default:
          return "Sunday";
      }
    }

    bool value() {
      switch (action) {
        case WeekdayAction.monday:
          return monday;
        case WeekdayAction.tuesday:
          return tuesday;
        case WeekdayAction.wednesday:
          return wednesday;
        case WeekdayAction.thursday:
          return thursday;
        case WeekdayAction.friday:
          return friday;
        case WeekdayAction.saturday:
          return saturday;
        default:
          return sunday;
      }
    }

    void onChanged(bool? value) {
      setState(() {
        switch (action) {
          case WeekdayAction.monday:
            monday = value!;
            return;
          case WeekdayAction.tuesday:
            tuesday = value!;
            return;
          case WeekdayAction.wednesday:
            wednesday = value!;
            return;
          case WeekdayAction.thursday:
            thursday = value!;
            return;
          case WeekdayAction.friday:
            friday = value!;
            return;
          case WeekdayAction.saturday:
            saturday = value!;
            return;
          default:
            sunday = value!;
        }
      });
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title(),
          style: const TextStyle(fontSize: 16),
        ),
        Checkbox(
          value: value(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
