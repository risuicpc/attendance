import 'package:attendance/extensions/date_time.dart';
import 'package:attendance/extensions/strings.dart';
import 'package:attendance/utils/cloud/firebase_storage.dart';
import 'package:attendance/utils/cloud/setting.dart';

Stream<bool> getAttendancePermission(bool emit) async* {
  bool prevValue = false;

  while (emit) {
    await Future<void>.delayed(const Duration(seconds: 1));
    Setting? setting = await FirebaseStorage().getSetting;
    if (setting != null) {
      String start = setting.startTime;
      String end = setting.endTime;

      bool currentValue = start.toTime.isAllowSubmitAttendance(end.toTime);
      if (prevValue != currentValue) {
        prevValue = currentValue;
      }
      yield currentValue;
    }
  }
}
