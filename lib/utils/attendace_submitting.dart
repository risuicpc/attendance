import 'dart:math' show max;

import 'package:attendance/api/auth/firebase_provider.dart';
import 'package:attendance/api/auth/user.dart';
import 'package:attendance/api/cloud/firebase_storage.dart';
import 'package:attendance/api/cloud/storage_exceptions.dart';
import 'package:attendance/api/cloud/user_info.dart';
import 'package:attendance/extensions/date_time.dart';
import 'package:attendance/helpers/loading/loading_screen.dart';
import 'package:attendance/utils/date_time.dart';
import 'package:attendance/utils/validation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<void> attendanceSubmitting(
  BuildContext context,
  UserInfo? userInfo,
) async {
  AuthUser user = FirebaseAuthProvider().currentUser!;
  final cloudService = FirebaseStorage();
  final now = await currentLocalTime;
  bool isLate = false;

  if (userInfo == null) {
    throw "The information you provided did not create properly. Please contact the staff for assistance.";
  }
  int lateUntilToday = userInfo.numberOfLate;
  int absentUntilToday = userInfo.numberOfAbsent;

  if (context.mounted) {
    LoadingScreen().show(context: context, text: "Checking prev...");
  }
  absentUntilToday += await checkPrevAttendance(userInfo, now);

  if (context.mounted) {
    LoadingScreen().show(context: context, text: "Device Validating");
  }
  try {
    await deviceValidate(userInfo);
  } catch (e) {
    throw e.toString();
  }

  if (context.mounted) {
    LoadingScreen().show(context: context, text: "Location Validating");
  }
  try {
    await locationValidation();
  } catch (e) {
    throw e.toString();
  }

  if (context.mounted) {
    LoadingScreen().show(context: context, text: "Time Validating");
  }
  try {
    isLate = await timeValidation(now);
  } catch (e) {
    throw e.toString();
  }

  if (context.mounted) {
    LoadingScreen().show(context: context, text: "Workday checking");
  }
  var workday = await cloudService.getUserWorkday(userId: user.id);
  if (workday == null) {
    try {
      await cloudService.createUserWorkday(
        userId: user.id,
        userName: user.name ?? "No name",
      );
      workday = await cloudService.getUserWorkday(userId: user.id);
      if (workday == null) {
        throw "Something went wrong with the user workday!";
      }
    } catch (_) {
      throw "Something went wrong with the user workday!";
    }
  }

  if (context.mounted) {
    LoadingScreen().show(context: context, text: "Submitting...");
  }

  String formattedTime = DateFormat.yMd().format(now);
  DateTime today = DateFormat.yMd().parse(formattedTime);
  final todayCalendar = await cloudService.getCalendar(today);

  lateUntilToday += isLate ? 1 : 0;
  if (!workday.today(now.weekDay) ||
      (todayCalendar != null && !todayCalendar.workday)) {
    absentUntilToday > 0
        ? absentUntilToday -= 1
        : lateUntilToday = max(0, lateUntilToday - 3);
  }
  try {
    await cloudService.addAttendace(
      userId: user.id,
      day: now,
      status: isLate ? "late" : "present",
    );
    await cloudService.updateUserInfo(
      id: userInfo.id,
      numberOfLate: lateUntilToday,
      numberOfAbsent: absentUntilToday,
    );
  } on AlreadyCreatedException catch (_) {
    throw "You have already submitted today's attendance!";
  } catch (_) {
    throw "Something went wrong with the attendance submission!";
  }
}
