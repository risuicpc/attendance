import 'package:attendance/api/cloud/firebase_storage.dart';
import 'package:attendance/api/cloud/setting.dart';
import 'package:attendance/extensions/date_time.dart';
import 'package:attendance/extensions/strings.dart';
import 'package:flutter/material.dart' show TimeOfDay;

Stream<bool> getAttendancePermission(bool emit) async* {
  bool prevValue = false;
  bool first = true;

  while (emit) {
    Setting? setting = await FirebaseStorage().getSetting;
    if (setting != null) {
      String start = setting.startTime;
      String end = setting.endTime;

      late TimeOfDay now = TimeOfDay.now();

      bool currentValue = start.toTime.isAllowSubmitAttendance(now, end.toTime);
      if (prevValue != currentValue || first) {
        prevValue = currentValue;
        yield currentValue;
      }
    } else {
      yield prevValue;
    }
    await Future<void>.delayed(const Duration(seconds: 1));
    if (first) first = false;
  }
}
