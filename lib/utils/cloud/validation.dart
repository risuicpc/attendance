import 'package:attendance/constants/map_key.dart';
import 'package:attendance/extensions/date_time.dart';
import 'package:attendance/extensions/strings.dart';
import 'package:attendance/utils/cloud/firebase_storage.dart';
import 'package:attendance/utils/cloud/user_info.dart';
import 'package:attendance/utils/device_info.dart';
import 'package:flutter/material.dart';

Future<Map<String, dynamic>> deviceValidate(UserInfo info) async {
  final device = await getDeviceInfo();

  if (info.androidId != device.androidId || info.deviceId != device.deviceId) {
    return {
      messageKey:
          'You cannot submit your attendance using this device. Please use the device registered with your account.',
      validKey: false
    };
  }
  return {validKey: true};
}

Future<Map<String, dynamic>> timeValidation() async {
  final setting = await FirebaseStorage().getSetting;
  if (setting == null) {
    return {
      messageKey: 'Attendance timestamp not set. Please contact staff.',
      validKey: false,
    };
  }

  final now = TimeOfDay.now();
  final startTime = setting.startTime.toTime;
  final lateTime = setting.lateTime.toTime;
  final endTime = setting.endTime.toTime;

  if (startTime.isBefore(endTime)) {
    if (now.isBefore(startTime) || now.isAfter(endTime)) {
      return {
        messageKey:
            "You arrived ${now.isAfter(endTime) ? "after" : "before"} the expected time",
        validKey: false,
      };
    } else {
      return {
        validKey: true,
        lateKey: now.isAfter(lateTime),
      };
    }
  } else {
    if (now.isAfter(endTime) && now.isBefore(startTime)) {
      return {
        messageKey: "You arrived after the expected time",
        validKey: false,
      };
    } else {
      bool late = now.isAfter(lateTime);
      if (!lateTime.isBefore(startTime)) {
        late = late || !now.isAfter(endTime);
      }
      return {validKey: true, lateKey: late};
    }
  }
}
