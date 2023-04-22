import 'package:attendance/enums/action.dart' show TimeAction;
import 'package:attendance/extensions/date_time.dart';
import 'package:attendance/extensions/strings.dart';
import 'package:attendance/helpers/loading/loading_screen.dart';
import 'package:attendance/api/cloud/firebase_storage.dart';
import 'package:attendance/api/cloud/setting.dart';
import 'package:attendance/api/cloud/storage_exceptions.dart';
import 'package:attendance/helpers/popup_message.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddSatting extends StatefulWidget {
  const AddSatting({required this.setNotify, this.setting, super.key});
  final Setting? setting;
  final ValueChanged<bool> setNotify;

  @override
  State<AddSatting> createState() => _AddSattingState();
}

class _AddSattingState extends State<AddSatting> {
  late final Setting? _setting;
  final _cloudService = FirebaseStorage();
  TextEditingController starttime = TextEditingController();
  TextEditingController latetime = TextEditingController();
  TextEditingController endtime = TextEditingController();
  final List<String> timeName = ["Start Time", "Late Time", "End Time"];

  @override
  void initState() {
    _setting = widget.setting;
    starttime.text = _setting?.startTime ?? "";
    latetime.text = _setting?.lateTime ?? "";
    endtime.text = _setting?.endTime ?? "";
    super.initState();
  }

  void _submitTime() async {
    if (starttime.text.isEmpty ||
        latetime.text.isEmpty ||
        endtime.text.isEmpty) {
      showErorr(context, 'Timestamp must not be empty.');
      return;
    }

    if ((starttime.text.toTime.isBefore(endtime.text.toTime) &&
            (latetime.text.toTime.isBefore(starttime.text.toTime) ||
                latetime.text.toTime.isAfter(endtime.text.toTime))) ||
        (latetime.text.toTime.isAfter(endtime.text.toTime) &&
            latetime.text.toTime.isBefore(starttime.text.toTime))) {
      showErorr(
        context,
        "Ensure that the late time falls within the range of start and end time.",
      );
      return;
    }
    if (!context.mounted) return;

    LoadingScreen().show(context: context, text: "Changing...");
    String? successMessage;

    try {
      if (_setting == null) {
        await _cloudService.createSetting(
          startTime: starttime.text,
          lateTime: latetime.text,
          endTime: endtime.text,
        );
      } else {
        await _cloudService.updateSettingTimestamp(
          id: _setting!.id,
          startTime: starttime.text,
          lateTime: latetime.text,
          endTime: endtime.text,
        );
      }
      successMessage = 'Timestamp has been updated successfully.';
      widget.setNotify(false);
    } on PermissionDeniedException catch (_) {
      showErorr(context, 'You does not have permission to set time.');
    } on CouldNotCreateException catch (_) {
      showErorr(
        context,
        'The process for setting the timestamp has been canceled.',
      );
    } on AlreadyCreatedException catch (_) {
      showErorr(context, 'Timestamp has been already created.');
    } finally {
      if (successMessage != null) showSuccess(context, successMessage);
    }
    LoadingScreen().hide();
  }

  TimeOfDay _pickInitialTime(TimeAction action) {
    switch (action) {
      case TimeAction.starttime:
        return starttime.text.toTime;
      case TimeAction.latetime:
        return latetime.text.toTime;
      default:
        return endtime.text.toTime;
    }
  }

  void _pickTime(TimeAction action) async {
    TimeOfDay? pickedTime = await showTimePicker(
      initialTime: _pickInitialTime(action),
      context: context,
    );

    if (pickedTime != null && context.mounted) {
      DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context));
      String formattedTime = DateFormat('HH:mm:ss').format(parsedTime);
      switch (action) {
        case TimeAction.starttime:
          starttime.text = formattedTime;
          break;
        case TimeAction.latetime:
          latetime.text = formattedTime;
          break;
        case TimeAction.endtime:
          endtime.text = formattedTime;
          break;
        default:
      }
    }
  }

  TextEditingController _controller(TimeAction action) {
    switch (action) {
      case TimeAction.starttime:
        return starttime;
      case TimeAction.latetime:
        return latetime;
      default:
        return endtime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Column(
        children: [
          const Text(
            'Attendance Time',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: timeName.length,
            itemBuilder: (context, index) {
              final title = timeName[index];
              final action = index == 0
                  ? TimeAction.starttime
                  : index == 1
                      ? TimeAction.latetime
                      : TimeAction.endtime;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 85,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _controller(action),
                  decoration: InputDecoration(
                    icon: const Icon(Icons.timer),
                    labelText: title,
                  ),
                  readOnly: true,
                  onTap: () => _pickTime(action),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 85, top: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _submitTime,
                  child: const Text("Set Time"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
