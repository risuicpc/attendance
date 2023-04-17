import 'package:attendance/extensions/strings.dart';
import 'package:attendance/helpers/loading/loading_screen.dart';
import 'package:attendance/utils/cloud/firebase_storage.dart';
import 'package:attendance/utils/cloud/setting.dart';
import 'package:attendance/utils/cloud/storage_exceptions.dart';
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
    if (!context.mounted) return;

    LoadingScreen().show(context: context, text: "Changing...");

    if (starttime.text.isEmpty ||
        latetime.text.isEmpty ||
        endtime.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Timestamp must not be empty.'),
      ));
      return;
    }

    try {
      if (_setting == null) {
        await _cloudService.createSetting(
          startTime: starttime.text,
          lateTime: latetime.text,
          endTime: endtime.text,
        );
      } else {
        await _cloudService.updateSettingTimestamp(
          id: _setting?.id,
          startTime: starttime.text,
          lateTime: latetime.text,
          endTime: endtime.text,
        );
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.green,
        content: Text('Timestamp has been updated successfully.'),
      ));
      widget.setNotify(false);
    } on PermissionDeniedException catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('You does not have permission to set time.'),
      ));
    } on CouldNotCreateException catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content:
              Text('The process for setting the timestamp has been canceled.'),
        ),
      );
    } on AlreadyCreatedException catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Timestamp has been already created.'),
      ));
    }
    LoadingScreen().hide();
  }

  TimeOfDay pickInitialTime(String name) {
    switch (name) {
      case "start_time":
        return starttime.text.toTime;
      case "late_time":
        return latetime.text.toTime;
      default:
        return endtime.text.toTime;
    }
  }

  void _pickTime(String name) async {
    if (!context.mounted) return;

    TimeOfDay? pickedTime = await showTimePicker(
      initialTime: pickInitialTime(name),
      context: context,
    );

    if (pickedTime != null) {
      // ignore: use_build_context_synchronously
      DateTime parsedTime = DateFormat.jm().parse(pickedTime.format(context));
      String formattedTime = DateFormat('HH:mm:ss').format(parsedTime);
      switch (name) {
        case "start_time":
          starttime.text = formattedTime;
          break;
        case "late_time":
          latetime.text = formattedTime;
          break;
        case "end_time":
          endtime.text = formattedTime;
          break;
        default:
      }
    }
  }

  TextEditingController _controller(String name) {
    switch (name) {
      case "start_time":
        return starttime;
      case "late_time":
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
              final name = title.replaceAll(" ", "_").toLowerCase();
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 85,
                  vertical: 8,
                ),
                child: TextField(
                  controller: _controller(name),
                  decoration: InputDecoration(
                    icon: const Icon(Icons.timer),
                    labelText: title,
                  ),
                  readOnly: true,
                  onTap: () => _pickTime(name),
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
