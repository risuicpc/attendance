import 'package:flutter/material.dart';

extension DateTimeExtension on DateTime {
  String get weekDay {
    const weekdayName = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"];
    return weekdayName[weekday - 1];
  }

  bool isAtSameDayAs(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isLessThen(DateTime other) {
    if (year < other.year) return true;
    if (year == other.year) {
      if (month < other.month) return true;
      if (month == other.month) {
        return day < other.day;
      }
    }
    return false;
  }
}

extension TimeOfDayExtension on TimeOfDay {
  bool isAfter(TimeOfDay other) {
    int currentTimeInt = (hour * 60 + minute);
    int otherTimeInt = (other.hour * 60 + other.minute);
    return currentTimeInt > otherTimeInt;
  }

  bool isBefore(TimeOfDay other) {
    int currentTimeInt = (hour * 60 + minute);
    int otherTimeInt = (other.hour * 60 + other.minute);
    return currentTimeInt < otherTimeInt;
  }

  bool isAllowSubmitAttendance(TimeOfDay end) {
    return !((isBefore(end) &&
            (TimeOfDay.now().isBefore(this) || TimeOfDay.now().isAfter(end))) ||
        (TimeOfDay.now().isAfter(end) && TimeOfDay.now().isBefore(this)));
  }
}
