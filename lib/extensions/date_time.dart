import 'package:flutter/material.dart';

extension DateTimeExtension on DateTime {
  String get weekDay {
    const List<String> weekdayName = [
      "",
      "mon",
      "tue",
      "wed",
      "thu",
      "fri",
      "sat",
      "sun",
    ];
    return weekdayName[weekday];
  }

  bool isAtSameDayAs(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
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
}
