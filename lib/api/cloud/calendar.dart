import 'package:attendance/constants/cloud_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Calendar {
  final String id;
  final DateTime date;
  bool workday;

  Calendar({
    required this.id,
    required this.date,
    required this.workday,
  });

  Calendar.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        date = snapshot.data()[dateFieldName].toDate(),
        workday = snapshot.data()[workdayFieldName];
}

List<List<List<Calendar>>> fromListOfCalendar(Iterable<Calendar> calendar) {
  late List<List<List<Calendar>>> months = [];

  for (int i = 1; i <= 12; i++) {
    List<Calendar> days = calendar.where((e) => e.date.month == i).toList();
    days.sort((a, b) => a.date.compareTo(b.date));

    List<Calendar> week = [];
    List<List<Calendar>> month = [];

    int empty = days.first.date.weekday;
    for (int i = 1; i < empty; i++) {
      week.add(Calendar(id: "", date: DateTime.now(), workday: false));
    }
    for (var day in days) {
      week.add(day);
      if (week.length == 7) {
        month.add(week);
        week = [];
      }
    }
    if (week.isNotEmpty) {
      while (week.length < 7) {
        week.add(Calendar(id: "", date: DateTime.now(), workday: false));
      }
      month.add(week);
    }
    months.add(month);
  }
  return months;
}
