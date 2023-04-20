import 'dart:math' show sin, cos, pi, asin, sqrt;

import 'package:attendance/extensions/date_time.dart';
import 'package:attendance/extensions/strings.dart';
import 'package:attendance/utils/cloud/firebase_storage.dart';
import 'package:attendance/utils/cloud/user_info.dart';
import 'package:attendance/utils/determine_position.dart';
import 'package:attendance/utils/device_info.dart';
import 'package:flutter/material.dart';

Future<int> checkPrevAttendance(UserInfo userInfo) async {
  final storage = FirebaseStorage();
  final lastAtend = await storage.getAttendace(userId: userInfo.userId);
  final yesterday = DateTime.now().subtract(const Duration(days: 1));

  int absent = 0;
  if (lastAtend != null && lastAtend.day.isLessThen(yesterday)) {
    DateTime last = lastAtend.day;
    final workday = await storage.getUserWorkday(userId: userInfo.userId);

    while (last.isLessThen(yesterday)) {
      last = last.add(const Duration(days: 1));
      if (workday != null && workday.today(last.weekDay)) {
        try {
          await storage.addAttendace(
            userId: userInfo.userId,
            day: last,
            status: "absent",
          );
          absent += 1;
        } catch (_) {}
      }
    }

    if (absent > 0) {
      try {
        await storage.updateUserInfo(
          id: userInfo.id,
          numberOfLate: userInfo.numberOfLate,
          numberOfAbsent: userInfo.numberOfAbsent + absent,
        );
      } catch (_) {}
    }
  }
  return absent;
}

Future<void> deviceValidate(UserInfo info) async {
  final device = await getDeviceInfo();
  if (info.androidId != device.androidId || info.deviceId != device.deviceId) {
    throw 'You cannot submit your attendance using this device. Please use the device registered with your account.';
  }
}

Future<void> locationValidation() async {
  final officeLocation = await FirebaseStorage().getLocation;
  if (officeLocation == null) {
    throw 'Work place not registered. Please contact staff.';
  }

  try {
    final position = await getCurrentPosition();
    double lat1 = officeLocation.latitude;
    double long1 = officeLocation.longitude;

    double lat2 = position.latitude;
    double long2 = position.longitude;
    double dist = distance(lat1, lat2, long1, long2);
    if (dist * 1000 > officeLocation.distance) {
      throw "You are within ${(dist * 1000).round().toString()} meters of the office, and it is necessary to attend the office to submit your attendance.";
    }
  } catch (e) {
    throw e.toString();
  }
}

Future<bool> timeValidation() async {
  final setting = await FirebaseStorage().getSetting;
  if (setting == null) {
    throw 'Attendance timestamp not set. Please contact staff.';
  }

  final now = TimeOfDay.now();
  final startTime = setting.startTime.toTime;
  final lateTime = setting.lateTime.toTime;
  final endTime = setting.endTime.toTime;

  if (startTime.isBefore(endTime)) {
    if (now.isBefore(startTime) || now.isAfter(endTime)) {
      throw "You arrived ${now.isAfter(endTime) ? "after" : "before"} the expected time";
    } else {
      return now.isAfter(lateTime);
    }
  } else {
    if (now.isAfter(endTime) && now.isBefore(startTime)) {
      throw "You arrived after the expected time";
    } else {
      bool late = now.isAfter(lateTime);
      if (!lateTime.isBefore(startTime)) {
        late = late || !now.isAfter(endTime);
      }
      return late;
    }
  }
}

double radians(double degree) => ((pi / 180) * degree);

double distance(double lat1, double lat2, double long1, double long2) {
  // radians which converts from degrees to radians.
  lat1 = radians(lat1);
  lat2 = radians(lat2);
  long1 = radians(long1);
  long2 = radians(long2);

  // Haversine formula
  double dlon = long2 - long1;
  double dlat = lat2 - lat1;
  double sinLat = sin(dlat / 2);
  double sinLong = sin(dlon / 2);
  double a = sinLat * sinLat + cos(lat1) * cos(lat2) * sinLong * sinLong;

  double c = 2 * asin(sqrt(a));

  // Radius of earth in kilometers. Use 3956 for miles
  double r = 6371;

  return c * r;
}
