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
}
