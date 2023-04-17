import 'package:flutter/material.dart';

extension StringExtension on String {
  String capitalize() {
    return split(' ')
        .map((e) => "${e[0].toUpperCase()}${e.substring(1).toLowerCase()}")
        .join(' ');
  }

  TimeOfDay get toTime {
    if (this == "") return TimeOfDay.now();
    final splitTime = split(":");
    return TimeOfDay(
      hour: int.parse(splitTime[0]),
      minute: int.parse(splitTime[1]),
    );
  }
}
