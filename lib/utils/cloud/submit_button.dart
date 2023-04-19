import 'dart:math' show max;

import 'package:attendance/constants/map_key.dart';
import 'package:attendance/extensions/date_time.dart';
import 'package:attendance/extensions/iterable.dart';
import 'package:attendance/helpers/loading/loading_screen.dart';
import 'package:attendance/utils/auth/firebase_provider.dart';
import 'package:attendance/utils/auth/user.dart';
import 'package:attendance/utils/cloud/firebase_storage.dart';
import 'package:attendance/utils/cloud/storage_exceptions.dart';
import 'package:attendance/utils/cloud/user_info.dart';
import 'package:attendance/utils/cloud/validation.dart';
import 'package:attendance/utils/popup_message.dart';
import 'package:flutter/material.dart';

Future<void> submitAttendance(
  BuildContext context,
  Iterable<UserInfo> allUserInfo,
) async {
  AuthUser user = FirebaseAuthProvider().currentUser!;
  final cloudService = FirebaseStorage();

  UserInfo? userInfo = allUserInfo.firstWhereOrNull((e) => e.userId == user.id);

  if (userInfo == null) {
    try {
      await cloudService.createUserInfo(
        userId: user.id,
        userName: user.name!,
      );
    } catch (_) {}
    return;
  }

  LoadingScreen().show(context: context, text: "Checking prev...");
  await checkPrevAttendance(userInfo);

  if (context.mounted) {
    LoadingScreen().show(context: context, text: "Device Validating");
  }
  final validDevice = await deviceValidate(userInfo);
  if (!validDevice[validKey]) {
    if (context.mounted) showErorr(context, validDevice[messageKey]);
    LoadingScreen().hide();
    return;
  }

  if (context.mounted) {
    LoadingScreen().show(context: context, text: "Location Validating");
  }
  final validLocation = await locationValidation();
  if (!validLocation[validKey]) {
    if (context.mounted) showErorr(context, validLocation[messageKey]);
    LoadingScreen().hide();
    return;
  }

  if (context.mounted) {
    LoadingScreen().show(context: context, text: "Time Validating");
  }
  final validTime = await timeValidation();
  if (!validTime[validKey]) {
    if (context.mounted) showErorr(context, validTime[messageKey]);
    LoadingScreen().hide();
    return;
  }

  if (context.mounted) {
    LoadingScreen().show(context: context, text: "Workday checking");
  }
  var workday = await cloudService.getUserWorkday(userId: user.id);
  if (workday == null) {
    try {
      await cloudService.createUserWorkday(
        userId: user.id,
        userName: user.name!,
      );
      workday = await cloudService.getUserWorkday(userId: user.id);
      if (workday == null) {
        if (context.mounted) {
          showErorr(context, "Something went wrong with the user workday!");
        }
        LoadingScreen().hide();
        return;
      }
    } catch (_) {
      if (context.mounted) {
        showErorr(context, "Something went wrong with the user workday!");
      }
      LoadingScreen().hide();
      return;
    }
  }

  if (context.mounted) {
    LoadingScreen().show(context: context, text: "Submitting...");
  }
  final refech = await cloudService.getUserInfo(userId: userInfo.id);

  int todyAbsent = refech?.numberOfAbsent ?? userInfo.numberOfAbsent;
  int todyLate = refech?.numberOfLate ??
      userInfo.numberOfLate + (validTime[lateKey] ? 1 : 0);
  if (!workday.today(DateTime.now().weekDay)) {
    todyAbsent > 0 ? todyAbsent -= 1 : todyLate = max(0, todyLate - 3);
  }
  try {
    await cloudService.addAttendace(
      userId: user.id,
      day: DateTime.now(),
      status: validTime[lateKey] ? "late" : "present",
    );
    await cloudService.updateUserInfo(
      id: userInfo.id,
      numberOfLate: todyLate,
      numberOfAbsent: todyAbsent,
    );
    if (context.mounted) {
      showSuccess(context, "The attendance was submitted successfully.");
    }
  } on AlreadyCreatedException catch (_) {
    if (context.mounted) {
      showErorr(context, "You have already submitted today's attendance!");
    }
  } catch (_) {
    if (context.mounted) {
      showErorr(
        context,
        "Something went wrong with the attendance submission!",
      );
    }
  }

  LoadingScreen().hide();
}
